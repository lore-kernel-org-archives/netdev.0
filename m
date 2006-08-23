From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 10/44] [XFRM] STATE: Common receive function for route optimization extension headers.
Date: Thu, 24 Aug 2006 00:02:11 +0900
Message-ID: <1156345365315-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:63112 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964920AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <11563453652646-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

XFRM_STATE_WILDRECV flag is introduced; the last resort state is set it
and receives packet which is not route optimized but uses such extension
headers i.e. Mobile IPv6 signaling (binding update and acknowledgement).
A node enabled Mobile IPv6 adds the state.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h   |    1 
 include/net/xfrm.h     |    2 +
 net/ipv6/ipv6_syms.c   |    1 
 net/ipv6/xfrm6_input.c |  108 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_state.c  |    1 
 5 files changed, 113 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 66343d3..a7c9e4c 100644
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
index a936423..6d0dafb 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -955,6 +955,8 @@ extern int xfrm4_tunnel_register(struct 
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, u32 spi);
 extern int xfrm6_rcv(struct sk_buff **pskb);
+extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
+			    xfrm_address_t *saddr, u8 proto);
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler);
 extern u32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index e1a7416..7b7b90d 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -31,6 +31,7 @@ EXPORT_SYMBOL(ipv6_chk_addr);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 #ifdef CONFIG_XFRM
 EXPORT_SYMBOL(xfrm6_rcv);
+EXPORT_SYMBOL(xfrm6_input_addr);
 EXPORT_SYMBOL(xfrm6_find_1stfragopt);
 #endif
 EXPORT_SYMBOL(rt6_lookup);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index ee2f6b3..a40a057 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -138,3 +138,111 @@ int xfrm6_rcv(struct sk_buff **pskb)
 {
 	return xfrm6_rcv_spi(*pskb, 0);
 }
+
+int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
+		     xfrm_address_t *saddr, u8 proto)
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
+
+	return 1;
+drop:
+	if (xfrm_vec_one)
+		xfrm_state_put(xfrm_vec_one);
+	return -1;
+}
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 11f480b..f053715 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -352,6 +352,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 	list_for_each_entry(x, xfrm_state_bydst+h, bydst) {
 		if (x->props.family == family &&
 		    x->props.reqid == tmpl->reqid &&
+		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 		    tmpl->mode == x->props.mode &&
 		    tmpl->id.proto == x->id.proto &&
-- 
1.4.0

