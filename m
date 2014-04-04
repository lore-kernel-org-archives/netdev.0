From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: (patch needs review) NULL dereference in xfrm_output with NAT
Date: Fri, 4 Apr 2014 11:02:42 +0200
Message-ID: <20140404090242.GN32371@secunet.com>
References: <20140402103711.GJ5945@methuselah>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Martin Pelikan <martin.pelikan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34349 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799AbaDDJCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 05:02:53 -0400
Content-Disposition: inline
In-Reply-To: <20140402103711.GJ5945@methuselah>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2014 at 12:37:11PM +0200, Martin Pelikan wrote:
> Hi!
> 
> There was a protection fault caused by nf_xfrm_me_harder.  The xfrm layer
> shouldn't have been drinking during its packets' preNATal period, because
> the packets can MASQUERADE and give the layer complications during output.
> 

Thanks for the report! Looks like IPv6 does not handle NAT rerouted
IPsec interfamily packets correctly. We also have this problem with
the new IPv6 NAT support.

> 
> Obviously, this was caused by a packet being sent into an IPv4 flow in an
> IPv6 tunnel, on which a postrouting nftables SNAT rule was applied.  That
> rule changed the packet's mind about going through the tunnel, but it was
> too late.  xfrm_output_one() does indeed check the validity of xfrm_state
> in the chain of dst_entry's, but not the first one (Assuming if something
> got into xfrm layer means it actually wants at least one transform?)
> 
> Comments?  Fix below, but people need to re-check if it's the right spot.
> If you agree and can put your name on it, send me and e-mail and I'll try
> to send a patch from git.
> --
> Martin Pelikan
> 
> 
> --- ./net/xfrm/xfrm_output.c	2014-04-02 11:27:04.597375669 +0200
> +++ ./net/xfrm/xfrm_output.c	2014-04-02 11:26:33.399378335 +0200
> @@ -46,6 +46,10 @@
>  
>  	if (err <= 0)
>  		goto resume;
> +
> +	/* Netfilter NAT can make us not to do even the first transform. */
> +	if (x == NULL)
> +		return 0;
>  

Just returning 0 here is not sufficient, we need to dst_output() the
packet to its new destination. Does the patch below fix your problem?


diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index baa0f63..52df0e6 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -62,10 +62,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
-	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED;
-
-	skb->protocol = htons(ETH_P_IP);
+	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
 
 	return x->outer_mode->output2(x, skb);
 }
@@ -73,27 +70,36 @@ EXPORT_SYMBOL(xfrm4_prepare_output);
 
 int xfrm4_output_finish(struct sk_buff *skb)
 {
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+	skb->protocol = htons(ETH_P_IP);
+
 #ifdef CONFIG_NETFILTER
-	if (!skb_dst(skb)->xfrm) {
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
+#endif
+
+	return xfrm_output(skb);
+}
+
+static int __xfrm4_output(struct sk_buff *skb)
+{
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
+
+#ifdef CONFIG_NETFILTER
+	if (!x) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
 		return dst_output(skb);
 	}
-
-	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 #endif
 
-	skb->protocol = htons(ETH_P_IP);
-	return xfrm_output(skb);
+	return x->outer_mode->afinfo->output_finish(skb);
 }
 
 int xfrm4_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct xfrm_state *x = dst->xfrm;
 
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb,
-			    NULL, dst->dev,
-			    x->outer_mode->afinfo->output_finish,
+			    NULL, dst->dev, __xfrm4_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6cd625e..ba62433 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -114,12 +114,6 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
-#ifdef CONFIG_NETFILTER
-	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
-#endif
-
-	skb->protocol = htons(ETH_P_IPV6);
 	skb->local_df = 1;
 
 	return x->outer_mode->output2(x, skb);
@@ -128,11 +122,13 @@ EXPORT_SYMBOL(xfrm6_prepare_output);
 
 int xfrm6_output_finish(struct sk_buff *skb)
 {
+	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
+	skb->protocol = htons(ETH_P_IPV6);
+
 #ifdef CONFIG_NETFILTER
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 #endif
 
-	skb->protocol = htons(ETH_P_IPV6);
 	return xfrm_output(skb);
 }
 
@@ -142,6 +138,13 @@ static int __xfrm6_output(struct sk_buff *skb)
 	struct xfrm_state *x = dst->xfrm;
 	int mtu;
 
+#ifdef CONFIG_NETFILTER
+	if (!x) {
+		IP6CB(skb)->flags |= IP6SKB_REROUTED;
+		return dst_output(skb);
+	}
+#endif
+
 	if (skb->protocol == htons(ETH_P_IPV6))
 		mtu = ip6_skb_dst_mtu(skb);
 	else
@@ -165,6 +168,7 @@ static int __xfrm6_output(struct sk_buff *skb)
 
 int xfrm6_output(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL,
-		       skb_dst(skb)->dev, __xfrm6_output);
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb,
+			    NULL, skb_dst(skb)->dev, __xfrm6_output,
+			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
