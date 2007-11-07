From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 21/24] [IPSEC]: Merge most of the input path
Date: Wed, 07 Nov 2007 22:08:38 +0800
Message-ID: <E1IplaA-0001If-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3801 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758347AbXKGO1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:27:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Merge most of the input path

As part of the work on asynchrnous cryptographic operations, we need to
be able to resume from the spot where they occur.  As such, it helps if
we isolate them to one spot.

This patch moves most of the remaining family-specific processing into
the common input code.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h     |   22 ++++++++
 net/ipv4/xfrm4_input.c |  126 +++++--------------------------------------------
 net/ipv4/xfrm4_state.c |    1 
 net/ipv6/xfrm6_input.c |  118 +++++----------------------------------------
 net/ipv6/xfrm6_state.c |    1 
 net/xfrm/xfrm_input.c  |  113 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 164 insertions(+), 217 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b6c26da..5c457b0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -274,6 +274,8 @@ struct xfrm_state_afinfo {
 						 struct sk_buff *skb);
 	int			(*extract_output)(struct xfrm_state *x,
 						  struct sk_buff *skb);
+	int			(*transport_finish)(struct sk_buff *skb,
+						    int async);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -522,6 +524,22 @@ struct xfrm_mode_skb_cb {
 
 #define XFRM_MODE_SKB_CB(__skb) ((struct xfrm_mode_skb_cb *)&((__skb)->cb[0]))
 
+/*
+ * This structure is used by the input processing to locate the SPI and
+ * related information.
+ */
+struct xfrm_spi_skb_cb {
+	union {
+		struct inet_skb_parm h4;
+		struct inet6_skb_parm h6;
+	} header;
+
+	unsigned int nhoff;
+	unsigned int daddroff;
+};
+
+#define XFRM_SPI_SKB_CB(__skb) ((struct xfrm_spi_skb_cb *)&((__skb)->cb[0]))
+
 /* Audit Information */
 struct xfrm_audit
 {
@@ -1119,12 +1137,15 @@ extern void xfrm_replay_notify(struct xfrm_state *x, int event);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
+extern int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi,
+		      int encap_type);
 extern int xfrm_output_resume(struct sk_buff *skb, int err);
 extern int xfrm_output(struct sk_buff *skb);
 extern int xfrm4_extract_header(struct sk_buff *skb);
 extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 			   int encap_type);
+extern int xfrm4_transport_finish(struct sk_buff *skb, int async);
 extern int xfrm4_rcv(struct sk_buff *skb);
 
 static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
@@ -1140,6 +1161,7 @@ extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short f
 extern int xfrm6_extract_header(struct sk_buff *skb);
 extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
+extern int xfrm6_transport_finish(struct sk_buff *skb, int async);
 extern int xfrm6_rcv(struct sk_buff *skb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			    xfrm_address_t *saddr, u8 proto);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index c0323d0..e374903 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -41,124 +41,26 @@ drop:
 int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type)
 {
-	int err;
-	__be32 seq;
-	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
-	struct xfrm_state *x;
-	int xfrm_nr = 0;
-	int decaps = 0;
-	unsigned int nhoff = offsetof(struct iphdr, protocol);
-
-	seq = 0;
-	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
-		goto drop;
-
-	do {
-		const struct iphdr *iph = ip_hdr(skb);
-
-		if (xfrm_nr == XFRM_MAX_DEPTH)
-			goto drop;
-
-		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
-				      nexthdr, AF_INET);
-		if (x == NULL)
-			goto drop;
-
-		spin_lock(&x->lock);
-		if (unlikely(x->km.state != XFRM_STATE_VALID))
-			goto drop_unlock;
-
-		if ((x->encap ? x->encap->encap_type : 0) != encap_type)
-			goto drop_unlock;
-
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
-			goto drop_unlock;
-
-		if (xfrm_state_check_expire(x))
-			goto drop_unlock;
-
-		nexthdr = x->type->input(x, skb);
-		if (nexthdr <= 0)
-			goto drop_unlock;
-
-		skb_network_header(skb)[nhoff] = nexthdr;
-
-		/* only the first xfrm gets the encap type */
-		encap_type = 0;
-
-		if (x->props.replay_window)
-			xfrm_replay_advance(x, seq);
-
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-
-		spin_unlock(&x->lock);
-
-		xfrm_vec[xfrm_nr++] = x;
-
-		if (x->inner_mode->input(x, skb))
-			goto drop;
-
-		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
-			decaps = 1;
-			break;
-		}
-
-		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
-		if (err < 0)
-			goto drop;
-	} while (!err);
-
-	/* Allocate new secpath or COW existing one. */
-
-	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
-		struct sec_path *sp;
-		sp = secpath_dup(skb->sp);
-		if (!sp)
-			goto drop;
-		if (skb->sp)
-			secpath_put(skb->sp);
-		skb->sp = sp;
-	}
-	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH)
-		goto drop;
-
-	memcpy(skb->sp->xvec + skb->sp->len, xfrm_vec,
-	       xfrm_nr * sizeof(xfrm_vec[0]));
-	skb->sp->len += xfrm_nr;
-
-	nf_reset(skb);
+	XFRM_SPI_SKB_CB(skb)->nhoff = offsetof(struct iphdr, protocol);
+	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
+	return xfrm_input(skb, nexthdr, spi, encap_type);
+}
+EXPORT_SYMBOL(xfrm4_rcv_encap);
 
-	if (decaps) {
-		dst_release(skb->dst);
-		skb->dst = NULL;
-		netif_rx(skb);
-		return 0;
-	} else {
+int xfrm4_transport_finish(struct sk_buff *skb, int async)
+{
 #ifdef CONFIG_NETFILTER
-		__skb_push(skb, skb->data - skb_network_header(skb));
-		ip_hdr(skb)->tot_len = htons(skb->len);
-		ip_send_check(ip_hdr(skb));
+	__skb_push(skb, skb->data - skb_network_header(skb));
+	ip_hdr(skb)->tot_len = htons(skb->len);
+	ip_send_check(ip_hdr(skb));
 
-		NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
-			xfrm4_rcv_encap_finish);
-		return 0;
+	NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
+		xfrm4_rcv_encap_finish);
+	return 0;
 #else
-		return -ip_hdr(skb)->protocol;
+	return -ip_hdr(skb)->protocol;
 #endif
-	}
-
-drop_unlock:
-	spin_unlock(&x->lock);
-	xfrm_state_put(x);
-drop:
-	while (--xfrm_nr >= 0)
-		xfrm_state_put(xfrm_vec[xfrm_nr]);
-
-	kfree_skb(skb);
-	return 0;
 }
-EXPORT_SYMBOL(xfrm4_rcv_encap);
 
 /* If it's a keepalive packet, then just eat it.
  * If it's an encapsulated packet, then pass it to the
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 80292fb..3b067e8 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -74,6 +74,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.output			= xfrm4_output,
 	.extract_input		= xfrm4_extract_input,
 	.extract_output		= xfrm4_extract_output,
+	.transport_finish	= xfrm4_transport_finish,
 };
 
 void __init xfrm4_state_init(void)
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index c458d0a..3b9eedf 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -23,118 +23,26 @@ int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
-	int err;
-	__be32 seq;
-	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
-	struct xfrm_state *x;
-	int xfrm_nr = 0;
-	int decaps = 0;
-	unsigned int nhoff;
-
-	nhoff = IP6CB(skb)->nhoff;
-
-	seq = 0;
-	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
-		goto drop;
-
-	do {
-		struct ipv6hdr *iph = ipv6_hdr(skb);
-
-		if (xfrm_nr == XFRM_MAX_DEPTH)
-			goto drop;
-
-		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
-				      nexthdr, AF_INET6);
-		if (x == NULL)
-			goto drop;
-		spin_lock(&x->lock);
-		if (unlikely(x->km.state != XFRM_STATE_VALID))
-			goto drop_unlock;
-
-		if (x->props.replay_window && xfrm_replay_check(x, seq))
-			goto drop_unlock;
-
-		if (xfrm_state_check_expire(x))
-			goto drop_unlock;
-
-		nexthdr = x->type->input(x, skb);
-		if (nexthdr <= 0)
-			goto drop_unlock;
-
-		skb_network_header(skb)[nhoff] = nexthdr;
-
-		if (x->props.replay_window)
-			xfrm_replay_advance(x, seq);
-
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-
-		spin_unlock(&x->lock);
-
-		xfrm_vec[xfrm_nr++] = x;
-
-		if (x->inner_mode->input(x, skb))
-			goto drop;
-
-		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
-			decaps = 1;
-			break;
-		}
-
-		if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) < 0)
-			goto drop;
-	} while (!err);
-
-	/* Allocate new secpath or COW existing one. */
-	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
-		struct sec_path *sp;
-		sp = secpath_dup(skb->sp);
-		if (!sp)
-			goto drop;
-		if (skb->sp)
-			secpath_put(skb->sp);
-		skb->sp = sp;
-	}
-
-	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH)
-		goto drop;
-
-	memcpy(skb->sp->xvec + skb->sp->len, xfrm_vec,
-	       xfrm_nr * sizeof(xfrm_vec[0]));
-	skb->sp->len += xfrm_nr;
-
-	nf_reset(skb);
+	XFRM_SPI_SKB_CB(skb)->nhoff = IP6CB(skb)->nhoff;
+	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
+	return xfrm_input(skb, nexthdr, spi, 0);
+}
+EXPORT_SYMBOL(xfrm6_rcv_spi);
 
-	if (decaps) {
-		dst_release(skb->dst);
-		skb->dst = NULL;
-		netif_rx(skb);
-		return -1;
-	} else {
+int xfrm6_transport_finish(struct sk_buff *skb, int async)
+{
 #ifdef CONFIG_NETFILTER
-		ipv6_hdr(skb)->payload_len = htons(skb->len);
-		__skb_push(skb, skb->data - skb_network_header(skb));
+	ipv6_hdr(skb)->payload_len = htons(skb->len);
+	__skb_push(skb, skb->data - skb_network_header(skb));
 
-		NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
-			ip6_rcv_finish);
-		return -1;
+	NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
+		ip6_rcv_finish);
+	return -1;
 #else
-		return 1;
+	return 1;
 #endif
-	}
-
-drop_unlock:
-	spin_unlock(&x->lock);
-	xfrm_state_put(x);
-drop:
-	while (--xfrm_nr >= 0)
-		xfrm_state_put(xfrm_vec[xfrm_nr]);
-	kfree_skb(skb);
-	return -1;
 }
 
-EXPORT_SYMBOL(xfrm6_rcv_spi);
-
 int xfrm6_rcv(struct sk_buff *skb)
 {
 	return xfrm6_rcv_spi(skb, skb_network_header(skb)[IP6CB(skb)->nhoff],
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index bb09e85..00360b5 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -198,6 +198,7 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.output			= xfrm6_output,
 	.extract_input		= xfrm6_extract_input,
 	.extract_output		= xfrm6_extract_output,
+	.transport_finish	= xfrm6_transport_finish,
 };
 
 void __init xfrm6_state_init(void)
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 4c803f7..b980095 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -9,6 +9,8 @@
 
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/netdevice.h>
+#include <net/dst.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
 
@@ -94,6 +96,117 @@ int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm_prepare_input);
 
+int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
+{
+	int err;
+	__be32 seq;
+	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
+	struct xfrm_state *x;
+	int xfrm_nr = 0;
+	int decaps = 0;
+	unsigned int nhoff = XFRM_SPI_SKB_CB(skb)->nhoff;
+	unsigned int daddroff = XFRM_SPI_SKB_CB(skb)->daddroff;
+
+	seq = 0;
+	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
+		goto drop;
+
+	do {
+		if (xfrm_nr == XFRM_MAX_DEPTH)
+			goto drop;
+
+		x = xfrm_state_lookup((xfrm_address_t *)
+				      (skb_network_header(skb) + daddroff),
+				      spi, nexthdr, AF_INET);
+		if (x == NULL)
+			goto drop;
+
+		spin_lock(&x->lock);
+		if (unlikely(x->km.state != XFRM_STATE_VALID))
+			goto drop_unlock;
+
+		if ((x->encap ? x->encap->encap_type : 0) != encap_type)
+			goto drop_unlock;
+
+		if (x->props.replay_window && xfrm_replay_check(x, seq))
+			goto drop_unlock;
+
+		if (xfrm_state_check_expire(x))
+			goto drop_unlock;
+
+		nexthdr = x->type->input(x, skb);
+		if (nexthdr <= 0)
+			goto drop_unlock;
+
+		skb_network_header(skb)[nhoff] = nexthdr;
+
+		/* only the first xfrm gets the encap type */
+		encap_type = 0;
+
+		if (x->props.replay_window)
+			xfrm_replay_advance(x, seq);
+
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+
+		spin_unlock(&x->lock);
+
+		xfrm_vec[xfrm_nr++] = x;
+
+		if (x->inner_mode->input(x, skb))
+			goto drop;
+
+		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
+			decaps = 1;
+			break;
+		}
+
+		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
+		if (err < 0)
+			goto drop;
+	} while (!err);
+
+	/* Allocate new secpath or COW existing one. */
+
+	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
+		struct sec_path *sp;
+		sp = secpath_dup(skb->sp);
+		if (!sp)
+			goto drop;
+		if (skb->sp)
+			secpath_put(skb->sp);
+		skb->sp = sp;
+	}
+	if (xfrm_nr + skb->sp->len > XFRM_MAX_DEPTH)
+		goto drop;
+
+	memcpy(skb->sp->xvec + skb->sp->len, xfrm_vec,
+	       xfrm_nr * sizeof(xfrm_vec[0]));
+	skb->sp->len += xfrm_nr;
+
+	nf_reset(skb);
+
+	if (decaps) {
+		dst_release(skb->dst);
+		skb->dst = NULL;
+		netif_rx(skb);
+		return 0;
+	} else {
+		return x->inner_mode->afinfo->transport_finish(skb, 0);
+	}
+
+drop_unlock:
+	spin_unlock(&x->lock);
+	xfrm_state_put(x);
+drop:
+	while (--xfrm_nr >= 0)
+		xfrm_state_put(xfrm_vec[xfrm_nr]);
+
+	kfree_skb(skb);
+	return 0;
+}
+EXPORT_SYMBOL(xfrm_input);
+
 void __init xfrm_input_init(void)
 {
 	secpath_cachep = kmem_cache_create("secpath_cache",
