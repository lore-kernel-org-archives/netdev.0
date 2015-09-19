From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] af_unix: return data from multiple SKBs on recv()
 with MSG_PEEK flag
Date: Sat, 19 Sep 2015 20:23:26 +0300
Message-ID: <55FD9A0E.1090804@cogentembedded.com>
References: <f7tvbb7zpbf.fsf@aconole.bos.csb>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Aaron Conole <aconole@bytheb.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:33531 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbbISRX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 13:23:29 -0400
Received: by lamp12 with SMTP id p12so45610689lam.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 10:23:27 -0700 (PDT)
In-Reply-To: <f7tvbb7zpbf.fsf@aconole.bos.csb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/18/2015 7:04 PM, Aaron Conole wrote:

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
> This was tested using the python socketpair() code attached to the
> bugzilla issue.
>
> Signed-off-by: Aaron Conole <aconole@bytheb.org>

    Your patch doesn't comply to the Linux CodingStyle.

> ---
>   net/unix/af_unix.c | 17+-
>   1 file changed, 15 insertions(+), 2 deletions(-)
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 03ee4d3..d2fd342 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2179,9 +2181,22 @@ unlock:
>   			if (UNIXCB(skb).fp)
>   				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
>
> -			sk_peek_offset_fwd(sk, chunk);
> +			if (skip)
> +			{

			if (skip) {

> +				sk_peek_offset_fwd(sk, chunk);
> +				skip -= chunk;
> +			}
>
> -			break;
> +			if (UNIXCB(skb).fp)
> +				break;
> +
> +			/* XXX - this is ugly; better would be rewrite the function  */
> +			last = skb;
> +			last_len = skb->len;
> +			unix_state_lock(&sk);
> +			skb = skb_peek_next(skb, &sk->sk_receive_queue);
> +			if (skb) goto again;

			if (skb)
				goto again;

> +			goto unlock;
>   		}
>   	} while (size);
>

MBR, Sergei
