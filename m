From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/6] xfrm: Fix crash with ipv6 IPsec tunnel and NAT.
Date: Thu, 15 May 2014 09:07:51 +0200
Message-ID: <1400137676-27565-2-git-send-email-steffen.klassert@secunet.com>
References: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44803 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792AbaEOHIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:08:20 -0400
In-Reply-To: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 xfrm output path is not aware that packets can be
rerouted by NAT to not use IPsec. We crash in this case
because we expect to have a xfrm state at the dst_entry.
This crash happens if the ipv6 layer does IPsec and NAT
or if we have an interfamily IPsec tunnel with ipv4 NAT.

We fix this by checking for a NAT rerouted packet in each
address family and dst_output() to the new destination
in this case.

Reported-by: Martin Pelikan <martin.pelikan@gmail.com>
Tested-by: Martin Pelikan <martin.pelikan@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_output.c |   32 ++++++++++++++++++--------------
 net/ipv6/xfrm6_output.c |   22 +++++++++++++---------
 2 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index baa0f63..f3800bf 100644
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
@@ -73,27 +70,34 @@ EXPORT_SYMBOL(xfrm4_prepare_output);
 
 int xfrm4_output_finish(struct sk_buff *skb)
 {
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+	skb->protocol = htons(ETH_P_IP);
+
+#ifdef CONFIG_NETFILTER
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
 #ifdef CONFIG_NETFILTER
-	if (!skb_dst(skb)->xfrm) {
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
-	struct dst_entry *dst = skb_dst(skb);
-	struct xfrm_state *x = dst->xfrm;
-
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb,
-			    NULL, dst->dev,
-			    x->outer_mode->afinfo->output_finish,
+			    NULL, skb_dst(skb)->dev, __xfrm4_output,
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
-- 
1.7.9.5
