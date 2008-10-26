From: Florian Westphal <fw@strlen.de>
Subject: Re: suspicious logic in tcp_make_synack()
Date: Sun, 26 Oct 2008 18:41:47 +0100
Message-ID: <20081026174147.GB27584@Chamillionaire.breakpoint.cc>
References: <20081026.010158.193698298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54955 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752602AbYJZRlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 13:41:55 -0400
Content-Disposition: inline
In-Reply-To: <20081026.010158.193698298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> I've been debugging something over the past few days and noticed
> something I can't explain in your change:
> 
> commit 33ad798c924b4a1afad3593f2796d465040aadd5
> Author: Adam Langley <agl@imperialviolet.org>
> Date:   Sat Jul 19 00:04:31 2008 -0700
> 
>     tcp: options clean up
> 
> specifically this hunk of the change:
> 
> @@ -2244,18 +2295,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
>  		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
>  	else
>  #endif
> -	TCP_SKB_CB(skb)->when = tcp_time_stamp;
> -	tcp_syn_build_options((__be32 *)(th + 1), dst_metric(dst, RTAX_ADVMSS), ireq->tstamp_ok,
> -			      ireq->sack_ok, ireq->wscale_ok, ireq->rcv_wscale,
> -			      TCP_SKB_CB(skb)->when,
> -			      req->ts_recent,
> -			      (
> -#ifdef CONFIG_TCP_MD5SIG
> -			       md5 ? &md5_hash_location :
> -#endif
> -			       NULL)
> -			      );
> -
> +	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
> 
> the code right above this stuff reads:
> 
> #ifdef CONFIG_SYN_COOKIES
> 	if (unlikely(req->cookie_ts))
> 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
> 	else
> #endif
> 
> The old code unconditionally built TCP options for the SYNACK, but now
> it doesn't build those options if req->cookie_ts, that call falls into
> the "else" branch, is that intentional?

I hope not 8-)

It essentially disables 4dfc2817025965a2fc78a18c50f540736a6b5c24
('[Syncookies]: Add support for TCP options via timestamps.'), thanks
for catching this.

> That req->cookie_ts test is meant to only control how
> TCP_SKB_CB(skb)->when gets calculated.

Yes. Moving the #ifdef CONFIG_SYN_COOKIES block allows syncookies
to use a tcp option subset again:

From: Florian Westphal <fw@strlen.de>
Date: Sun, 26 Oct 2008 16:25:11 +0100
Subject: [PATCH] syncookies: fix inclusion of tcp options in syn-ack

David Miller noticed that commit
33ad798c924b4a1afad3593f2796d465040aadd5 '(tcp: options clean up')
did not move the req->cookie_ts check.
This essentially disabled commit 4dfc2817025965a2fc78a18c50f540736a6b5c24
'[Syncookies]: Add support for TCP options via timestamps.'.

This restores the original logic.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_output.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e4c5ac9..ba85d88 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2279,6 +2279,11 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	}
 
 	memset(&opts, 0, sizeof(opts));
+#ifdef CONFIG_SYN_COOKIES
+	if (unlikely(req->cookie_ts))
+		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
+	else
+#endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	tcp_header_size = tcp_synack_options(sk, req, mss,
 					     skb, &opts, &md5) +
@@ -2304,11 +2309,6 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never scaled. */
 	th->window = htons(min(req->rcv_wnd, 65535U));
-#ifdef CONFIG_SYN_COOKIES
-	if (unlikely(req->cookie_ts))
-		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
-	else
-#endif
 	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);

