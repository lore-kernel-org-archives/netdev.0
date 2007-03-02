From: John Heffner <jheffner@psc.edu>
Subject: Re: SWS for rcvbuf < MTU
Date: Fri, 02 Mar 2007 13:54:45 -0500
Message-ID: <45E872F5.2030102@psc.edu>
References: <200703021128.29208.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040008010602020004000103"
Cc: netdev@vger.kernel.org
To: Alex Sidorenko <alexandre.sidorenko@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:52163 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964793AbXCBSyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 13:54:50 -0500
In-Reply-To: <200703021128.29208.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040008010602020004000103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Alex Sidorenko wrote:
[snip]
> --- net/ipv4/tcp_output.c.orig  Wed May  3 20:40:43 2006
> +++ net/ipv4/tcp_output.c       Tue Jan 30 14:24:56 2007
> @@ -641,6 +641,7 @@
>   * Note, we don't "adjust" for TIMESTAMP or SACK option bytes.
>   * Regular options like TIMESTAMP are taken into account.
>   */
> +static const char *SWS_id_string="@#SWS-fix-2";
>  u32 __tcp_select_window(struct sock *sk)
>  {
>         struct tcp_opt *tp = &sk->tp_pinfo.af_tcp;
> @@ -682,6 +683,9 @@
>         window = tp->rcv_wnd;
>         if (window <= free_space - mss || window > free_space)
>                 window = (free_space/mss)*mss;
> +        /* A fix for small rcvbuf asid@hp.com */
> +       else if (mss == full_space && window < full_space/2)
> +               window = full_space/2;
> 
>         return window;
>  }

Good analysis of the problem, but the patch does not look quite right. 
In particular, you can't ever announce a zero window. :)

I think this attached patch does the correct SWS avoidance.

Thanks,
   -John


--------------040008010602020004000103
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="r-sws.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r-sws.patch"

Do receiver-side SWS avoidance for rcvbuf < MSS.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit 38d33181c93a28cf7fb2f9f3377305a04636c054
tree 503f8a9de6e78694bae9fc2eb1c9dd5d26a0b5ed
parent 562aa1d4c6a874373f9a48ac184f662fbbb06a04
author John Heffner <jheffner@psc.edu> Fri, 02 Mar 2007 13:47:44 -0500
committer John Heffner <jheffner@psc.edu> Fri, 02 Mar 2007 13:47:44 -0500

 net/ipv4/tcp_output.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dc15113..688b955 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1607,6 +1607,9 @@ u32 __tcp_select_window(struct sock *sk)
 		 */
 		if (window <= free_space - mss || window > free_space)
 			window = (free_space/mss)*mss;
+		else if (mss == full_space &&
+		         free_space > window + full_space/2)
+			window = free_space;
 	}
 
 	return window;

--------------040008010602020004000103--
