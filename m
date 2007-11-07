From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 19/24] [IPSEC]: Merge most of the output path
Date: Wed, 07 Nov 2007 22:08:36 +0800
Message-ID: <E1Ipla8-0001IO-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3761 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758033AbXKGO01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:26:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Merge most of the output path

As part of the work on asynchrnous cryptographic operations, we need to
be able to resume from the spot where they occur.  As such, it helps if
we isolate them to one spot.

This patch moves most of the remaining family-specific processing into
the common output code.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/dst.h       |    1 
 include/net/xfrm.h      |    1 
 net/ipv4/route.c        |    1 
 net/ipv4/xfrm4_output.c |   76 ++---------------------------------------------
 net/ipv4/xfrm4_policy.c |    1 
 net/ipv4/xfrm4_state.c  |    2 +
 net/ipv6/route.c        |    1 
 net/ipv6/xfrm6_output.c |   77 ++++--------------------------------------------
 net/ipv6/xfrm6_policy.c |    1 
 net/ipv6/xfrm6_state.c  |    2 +
 net/xfrm/xfrm_output.c  |   70 +++++++++++++++++++++++++++++++++++++++++--
 11 files changed, 88 insertions(+), 145 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 4df103b..13f7e32 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -98,6 +98,7 @@ struct dst_ops
 	struct dst_entry *	(*negative_advice)(struct dst_entry *);
 	void			(*link_failure)(struct sk_buff *);
 	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
+	int			(*local_out)(struct sk_buff *skb);
 	int			entry_size;
 
 	atomic_t		entries;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 448a57f..e674a78 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -259,6 +259,7 @@ struct xfrm_state_afinfo {
 	unsigned int		family;
 	unsigned int		proto;
 	unsigned int		eth_proto;
+	unsigned int		nf_post_routing;
 	struct module		*owner;
 	struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d5cbcee..db484a2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -166,6 +166,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.negative_advice =	ipv4_negative_advice,
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
+	.local_out =		ip_local_out,
 	.entry_size =		sizeof(struct rtable),
 };
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 0ffc3d0..2fb4efa 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -59,7 +59,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 		return err;
 
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
-	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
+	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED;
 
 	skb->protocol = htons(ETH_P_IP);
 
@@ -67,87 +67,19 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm4_prepare_output);
 
-static inline int xfrm4_output_one(struct sk_buff *skb)
-{
-	int err;
-
-	err = xfrm_output(skb);
-	if (err)
-		goto error_nolock;
-
-	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
-	err = 0;
-
-out_exit:
-	return err;
-error_nolock:
-	kfree_skb(skb);
-	goto out_exit;
-}
-
-static int xfrm4_output_finish2(struct sk_buff *skb)
-{
-	int err;
-
-	while (likely((err = xfrm4_output_one(skb)) == 0)) {
-		nf_reset(skb);
-
-		err = __ip_local_out(skb);
-		if (unlikely(err != 1))
-			break;
-
-		if (!skb->dst->xfrm)
-			return dst_output(skb);
-
-		err = nf_hook(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
-			      skb->dst->dev, xfrm4_output_finish2);
-		if (unlikely(err != 1))
-			break;
-	}
-
-	return err;
-}
-
 static int xfrm4_output_finish(struct sk_buff *skb)
 {
-	struct sk_buff *segs;
-
 #ifdef CONFIG_NETFILTER
 	if (!skb->dst->xfrm) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
 		return dst_output(skb);
 	}
-#endif
 
-	if (!skb_is_gso(skb))
-		return xfrm4_output_finish2(skb);
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
+#endif
 
 	skb->protocol = htons(ETH_P_IP);
-	segs = skb_gso_segment(skb, 0);
-	kfree_skb(skb);
-	if (unlikely(IS_ERR(segs)))
-		return PTR_ERR(segs);
-
-	do {
-		struct sk_buff *nskb = segs->next;
-		int err;
-
-		segs->next = NULL;
-		err = xfrm4_output_finish2(segs);
-
-		if (unlikely(err)) {
-			while ((segs = nskb)) {
-				nskb = segs->next;
-				segs->next = NULL;
-				kfree_skb(segs);
-			}
-			return err;
-		}
-
-		segs = nskb;
-	} while (segs);
-
-	return 0;
+	return xfrm_output(skb);
 }
 
 int xfrm4_output(struct sk_buff *skb)
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 1d75243..d6232df 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -237,6 +237,7 @@ static struct dst_ops xfrm4_dst_ops = {
 	.update_pmtu =		xfrm4_update_pmtu,
 	.destroy =		xfrm4_dst_destroy,
 	.ifdown =		xfrm4_dst_ifdown,
+	.local_out =		ip_local_out,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
 };
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 85f04b7..80292fb 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -11,6 +11,7 @@
 #include <net/xfrm.h>
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
+#include <linux/netfilter_ipv4.h>
 
 static struct xfrm_state_afinfo xfrm4_state_afinfo;
 
@@ -66,6 +67,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
 	.proto			= IPPROTO_IPIP,
 	.eth_proto		= htons(ETH_P_IP),
+	.nf_post_routing	= NF_IP_POST_ROUTING,
 	.owner			= THIS_MODULE,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7db3cdf..2c91ce6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -117,6 +117,7 @@ static struct dst_ops ip6_dst_ops = {
 	.negative_advice	=	ip6_negative_advice,
 	.link_failure		=	ip6_link_failure,
 	.update_pmtu		=	ip6_rt_update_pmtu,
+	.local_out		=	ip6_local_out,
 	.entry_size		=	sizeof(struct rt6_info),
 };
 
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 0f0ff51..a0a9249 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -66,6 +66,9 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 		return err;
 
 	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
+#ifdef CONFIG_NETFILTER
+	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
+#endif
 
 	skb->protocol = htons(ETH_P_IPV6);
 
@@ -73,80 +76,14 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm6_prepare_output);
 
-static inline int xfrm6_output_one(struct sk_buff *skb)
-{
-	int err;
-
-	err = xfrm_output(skb);
-	if (err)
-		goto error_nolock;
-
-	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
-	err = 0;
-
-out_exit:
-	return err;
-error_nolock:
-	kfree_skb(skb);
-	goto out_exit;
-}
-
-static int xfrm6_output_finish2(struct sk_buff *skb)
-{
-	int err;
-
-	while (likely((err = xfrm6_output_one(skb)) == 0)) {
-		nf_reset(skb);
-
-		err = __ip6_local_out(skb);
-		if (unlikely(err != 1))
-			break;
-
-		if (!skb->dst->xfrm)
-			return dst_output(skb);
-
-		err = nf_hook(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL,
-			      skb->dst->dev, xfrm6_output_finish2);
-		if (unlikely(err != 1))
-			break;
-	}
-
-	return err;
-}
-
 static int xfrm6_output_finish(struct sk_buff *skb)
 {
-	struct sk_buff *segs;
-
-	if (!skb_is_gso(skb))
-		return xfrm6_output_finish2(skb);
+#ifdef CONFIG_NETFILTER
+	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
+#endif
 
 	skb->protocol = htons(ETH_P_IPV6);
-	segs = skb_gso_segment(skb, 0);
-	kfree_skb(skb);
-	if (unlikely(IS_ERR(segs)))
-		return PTR_ERR(segs);
-
-	do {
-		struct sk_buff *nskb = segs->next;
-		int err;
-
-		segs->next = NULL;
-		err = xfrm6_output_finish2(segs);
-
-		if (unlikely(err)) {
-			while ((segs = nskb)) {
-				nskb = segs->next;
-				segs->next = NULL;
-				kfree_skb(segs);
-			}
-			return err;
-		}
-
-		segs = nskb;
-	} while (segs);
-
-	return 0;
+	return xfrm_output(skb);
 }
 
 int xfrm6_output(struct sk_buff *skb)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 50a3841..6ee0de1 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -253,6 +253,7 @@ static struct dst_ops xfrm6_dst_ops = {
 	.update_pmtu =		xfrm6_update_pmtu,
 	.destroy =		xfrm6_dst_destroy,
 	.ifdown =		xfrm6_dst_ifdown,
+	.local_out =		ip6_local_out,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
 };
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 90fef0a..bb09e85 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -14,6 +14,7 @@
 #include <net/xfrm.h>
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
+#include <linux/netfilter_ipv6.h>
 #include <net/dsfield.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -189,6 +190,7 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.proto			= IPPROTO_IPV6,
 	.eth_proto		= htons(ETH_P_IPV6),
+	.nf_post_routing	= NF_IP6_POST_ROUTING,
 	.owner			= THIS_MODULE,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.tmpl_sort		= __xfrm6_tmpl_sort,
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index b1efdc8..bcb3701 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -12,6 +12,7 @@
 #include <linux/errno.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/netfilter.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <net/dst.h>
@@ -40,7 +41,7 @@ err:
 	return err;
 }
 
-int xfrm_output(struct sk_buff *skb)
+static int xfrm_output_one(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
@@ -87,10 +88,73 @@ int xfrm_output(struct sk_buff *skb)
 
 	err = 0;
 
-error_nolock:
+out_exit:
 	return err;
 error:
 	spin_unlock_bh(&x->lock);
-	goto error_nolock;
+error_nolock:
+	kfree_skb(skb);
+	goto out_exit;
+}
+
+static int xfrm_output2(struct sk_buff *skb)
+{
+	int err;
+
+	while (likely((err = xfrm_output_one(skb)) == 0)) {
+		struct xfrm_state *x;
+
+		nf_reset(skb);
+
+		err = skb->dst->ops->local_out(skb);
+		if (unlikely(err != 1))
+			break;
+
+		x = skb->dst->xfrm;
+		if (!x)
+			return dst_output(skb);
+
+		err = nf_hook(x->inner_mode->afinfo->family,
+			      x->inner_mode->afinfo->nf_post_routing, skb,
+			      NULL, skb->dst->dev, xfrm_output2);
+		if (unlikely(err != 1))
+			break;
+	}
+
+	return err;
+}
+
+int xfrm_output(struct sk_buff *skb)
+{
+	struct sk_buff *segs;
+
+	if (!skb_is_gso(skb))
+		return xfrm_output2(skb);
+
+	segs = skb_gso_segment(skb, 0);
+	kfree_skb(skb);
+	if (unlikely(IS_ERR(segs)))
+		return PTR_ERR(segs);
+
+	do {
+		struct sk_buff *nskb = segs->next;
+		int err;
+
+		segs->next = NULL;
+		err = xfrm_output2(segs);
+
+		if (unlikely(err)) {
+			while ((segs = nskb)) {
+				nskb = segs->next;
+				segs->next = NULL;
+				kfree_skb(segs);
+			}
+			return err;
+		}
+
+		segs = nskb;
+	} while (segs);
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(xfrm_output);
