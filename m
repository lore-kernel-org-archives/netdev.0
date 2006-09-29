From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] IPv6/DCCP: Fix memory leak in dccp_v6_do_rcv()
Date: Thu, 28 Sep 2006 23:07:51 -0700
Message-ID: <20060928230751.99041004.akpm@osdl.org>
References: <200609290245.33618.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dccp@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@coreworks.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1764 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161285AbWI2GJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 02:09:03 -0400
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200609290245.33618.jesper.juhl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006 02:45:33 +0200
Jesper Juhl <jesper.juhl@gmail.com> wrote:

> 
> Coverity found what looks like a real leak in net/dccp/ipv6.c::dccp_v6_do_rcv()
> 
> We may leave via the return inside "if (sk->sk_state == DCCP_OPEN) {"
> but at that point we may have allocated opt_skb, but we never free it
> in that path before the return.
> 
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> ---
> 
>  net/dccp/ipv6.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- linux-2.6.18-git10-orig/net/dccp/ipv6.c	2006-09-28 22:40:07.000000000 +0200
> +++ linux-2.6.18-git10/net/dccp/ipv6.c	2006-09-29 02:35:15.000000000 +0200
> @@ -997,6 +997,8 @@ static int dccp_v6_do_rcv(struct sock *s
>  	if (sk->sk_state == DCCP_OPEN) { /* Fast path */
>  		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
>  			goto reset;
> +		if (opt_skb)
> +			__kfree_skb(opt_skb);
>  		return 0;
>  	}

Looks right to me.  But it'd be better coded as below, so we don't have
multiple deeply-nested return points (the cause of this bug) and duplicated
code.

otoh, it seems to me that opt_skb doesn't actually do anything and can be
removed?


diff -puN net/dccp/ipv6.c~ipv6-dccp-fix-memory-leak-in-dccp_v6_do_rcv net/dccp/ipv6.c
--- a/net/dccp/ipv6.c~ipv6-dccp-fix-memory-leak-in-dccp_v6_do_rcv
+++ a/net/dccp/ipv6.c
@@ -997,7 +997,7 @@ static int dccp_v6_do_rcv(struct sock *s
 	if (sk->sk_state == DCCP_OPEN) { /* Fast path */
 		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
 			goto reset;
-		return 0;
+		goto out;
 	}
 
 	if (sk->sk_state == DCCP_LISTEN) {
@@ -1013,9 +1013,7 @@ static int dccp_v6_do_rcv(struct sock *s
  		if (nsk != sk) {
 			if (dccp_child_process(sk, nsk, skb))
 				goto reset;
-			if (opt_skb != NULL)
-				__kfree_skb(opt_skb);
-			return 0;
+			goto out;
 		}
 	}
 
@@ -1026,9 +1024,10 @@ static int dccp_v6_do_rcv(struct sock *s
 reset:
 	dccp_v6_ctl_send_reset(skb);
 discard:
+	kfree_skb(skb);
+out:
 	if (opt_skb != NULL)
 		__kfree_skb(opt_skb);
-	kfree_skb(skb);
 	return 0;
 }
 
_

