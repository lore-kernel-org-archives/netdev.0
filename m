From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 11/23] [PATCH] [XFRM] STATE: Common receive function for route optimization extension headers.
Date: Sat, 29 Jul 2006 18:30:31 +0900
Message-ID: <1154165431686-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:22147 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S932608AbWG2Jac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:32 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

XFRM_STATE_WILDRECV flag is introduced; the last resort state is set it
and receives packet which is not route optimized but uses such extension
headers i.e. Mobile IPv6 signaling (binding update and acknowledgement).
A node enabled Mobile IPv6 adds the state.
Based on MIPL2 kernel patch.
---
 include/linux/xfrm.h   |    1 
 include/net/xfrm.h     |   10 ++++
 net/ipv6/ipv6_syms.c   |    3 +
 net/ipv6/xfrm6_input.c |  112 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_state.c  |    3 +
 5 files changed, 129 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 55d1ce4..47e39f6 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -256,6 +256,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_NOECN	1
 #define XFRM_STATE_DECAP_DSCP	2
 #define XFRM_STATE_NOPMTUDISC	4
+#define XFRM_STATE_WILDRECV	8
 };
 
 struct xfrm_usersa_id {
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8dcf6cd..f551bc6 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -964,6 +964,16 @@ extern int xfrm4_tunnel_register(struct 
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, u32 spi);
 extern int xfrm6_rcv(struct sk_buff **pskb);
+#ifdef CONFIG_XFRM_ADVANCED
+extern int __xfrm6_rcv_one(struct sk_buff *skb, xfrm_address_t *daddr,
+			   xfrm_address_t *saddr, u8 proto);
+#else
+static inline int __xfrm6_rcv_one(struct sk_buff *skb, xfrm_address_t *daddr,
+				  xfrm_address_t *saddr, u8 proto)
+{
+	return -ENOSYS;
+}
+#endif
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler);
 extern u32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index 1648278..e8b8a5e 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -32,6 +32,9 @@ EXPORT_SYMBOL(ipv6_chk_addr);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 #ifdef CONFIG_XFRM
 EXPORT_SYMBOL(xfrm6_rcv);
+#ifdef CONFIG_XFRM_ADVANCED
+EXPORT_SYMBOL(__xfrm6_rcv_one);
+#endif
 #endif
 EXPORT_SYMBOL(rt6_lookup);
 EXPORT_SYMBOL(ipv6_push_nfrag_opts);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 915e867..9dc8373 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -161,3 +161,115 @@ int xfrm6_rcv(struct sk_buff **pskb)
 {
 	return xfrm6_rcv_spi(*pskb, 0);
 }
+
+#ifdef CONFIG_XFRM_ADVANCED
+int __xfrm6_rcv_one(struct sk_buff *skb, xfrm_address_t *daddr,
+ 		    xfrm_address_t *saddr, u8 proto)
+{
+ 	struct xfrm_state *x = NULL;
+ 	int wildcard = 0;
+	struct in6_addr any;
+	xfrm_address_t *xany;
+	struct xfrm_state *xfrm_vec_one = NULL;
+ 	int nh = 0;
+	int i = 0;
+
+	ipv6_addr_set(&any, 0, 0, 0, 0);
+	xany = (xfrm_address_t *)&any;
+
+	for (i = 0; i < 3; i++) {
+		xfrm_address_t *dst, *src;
+		switch (i) {
+		case 0:
+			dst = daddr;
+			src = saddr;
+			break;
+		case 1:
+			/* lookup state with wild-card source address */
+			wildcard = 1;
+			dst = daddr;
+			src = xany;
+			break;
+		case 2:
+		default:
+ 			/* lookup state with wild-card addresses */
+			wildcard = 1; /* XXX */
+			dst = xany;
+			src = xany;
+			break;
+ 		}
+
+		x = xfrm_state_lookup_byaddr(dst, src, proto, AF_INET6);
+		if (!x)
+			continue;
+
+		spin_lock(&x->lock);
+
+		if (wildcard) {
+			if ((x->props.flags & XFRM_STATE_WILDRECV) == 0) {
+				spin_unlock(&x->lock);
+				xfrm_state_put(x);
+				x = NULL;
+				continue;
+			}
+		}
+
+		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+			spin_unlock(&x->lock);
+			xfrm_state_put(x);
+ 			x = NULL;
+ 			continue;
+		}
+		if (xfrm_state_check_expire(x)) {
+			spin_unlock(&x->lock);
+			xfrm_state_put(x);
+			x = NULL;
+			continue;
+		}
+
+		nh = x->type->input(x, skb);
+		if (nh <= 0) {
+			spin_unlock(&x->lock);
+			xfrm_state_put(x);
+			x = NULL;
+			continue;
+		}
+
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+ 
+		spin_unlock(&x->lock);
+ 
+		xfrm_vec_one = x;
+		break;
+	}
+
+	if (!xfrm_vec_one)
+		goto drop;
+ 
+	/* Allocate new secpath or COW existing one. */
+	if (!skb->sp || atomic_read(&skb->sp->refcnt) != 1) {
+		struct sec_path *sp;
+		sp = secpath_dup(skb->sp);
+		if (!sp)
+			goto drop;
+		if (skb->sp)
+			secpath_put(skb->sp);
+		skb->sp = sp;
+	}
+
+	if (1 + skb->sp->len > XFRM_MAX_DEPTH)
+		goto drop;
+
+	skb->sp->xvec[skb->sp->len] = xfrm_vec_one;
+	skb->sp->len ++;
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+drop:
+	if (xfrm_vec_one)
+		xfrm_state_put(xfrm_vec_one);
+	return -1;
+}
+#endif
+
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1eedb85..60def7a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -357,6 +357,9 @@ xfrm_state_find(xfrm_address_t *daddr, x
 	list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
+#ifdef CONFIG_XFRM_ADVANCED
+		    (x->props.flags & XFRM_STATE_WILDRECV) == 0 &&
+#endif
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
-- 
1.4.1

