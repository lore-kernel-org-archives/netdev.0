From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] [net] af_unix: return data from multiple SKBs on
 recv() with MSG_PEEK flag
Date: Sun, 20 Sep 2015 09:46:04 -0700
Message-ID: <1442767564.29850.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442740705-16452-1-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Aaron Conole <aaron@bytheb.org>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34700 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbITQqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 12:46:07 -0400
Received: by padhy16 with SMTP id hy16so94353500pad.1
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 09:46:06 -0700 (PDT)
In-Reply-To: <1442740705-16452-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-09-20 at 05:18 -0400, Aaron Conole wrote:
> From: Aaron Conole <aaron@bytheb.org>
> 
> AF_UNIX sockets now return multiple skbs from recv() when MSG_PEEK flag
> is set.
> 
> This is referenced in kernel bugzilla #12323 @
> https://bugzilla.kernel.org/show_bug.cgi?id=12323
> 
> As described both in the BZ and lkml thread @
> http://lkml.org/lkml/2008/1/8/444 calling recv() with MSG_PEEK on an
> AF_UNIX socket only reads a single skb, where the desired effect is
> to return as much skb data has been queued, until hitting the recv
> buffer size (whichever comes first).
> 
> The modified MSG_PEEK path will now move to the next skb in the tree
> and jump to the again: label, rather than following the natural loop
> structure. This requires duplicating some of the loop head actions.
> 
> This was tested using the python socketpair python code attached to
> the bugzilla issue.
> 
> Signed-off-by: Aaron Conole <aaron@bytheb.org>
> ---
>  net/unix/af_unix.c | 19 +++++++++++++++++--
>  1 file changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 03ee4d3..988fbbd4 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2179,9 +2179,24 @@ unlock:
>  			if (UNIXCB(skb).fp)
>  				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
>  
> -			sk_peek_offset_fwd(sk, chunk);
> +			if (skip) {
> +				sk_peek_offset_fwd(sk, chunk);
> +				skip -= chunk;
> +			}
>  
> -			break;
> +			if (UNIXCB(skb).fp)
> +				break;
> +
> +			/* XXX - this is ugly; a better approach would be
> +			 * rewriting this function
> +			 */
> +			last = skb;
> +			last_len = skb->len;
> +			unix_state_lock(&sk);

I am wondering what this is expected to do, and how this code would
possibly not trigger a crash.

Are you 100% sure you tested this patch and code path ?

Before resending v3, please make sure to compile and test with
CONFIG_LOCKDEP=y. Add a temporary (in your tree, not final patch)

pr_err_once("went there at least one time\n");

(to make sure this code path was tested)

It might be time to get rid of unix_sk macro for a proper function to
avoid these kind of errors.

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 4a167b30a12f..cb1b9bbda332 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -63,7 +63,11 @@ struct unix_sock {
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
 };
-#define unix_sk(__sk) ((struct unix_sock *)__sk)
+
+static inline struct unix_sock *unix_sk(struct sock *sk)
+{
+	return (struct unix_sock *)sk;
+}
 
 #define peer_wait peer_wq.wait
 

Thanks.
