From: Tyler Hicks <tyhicks@ou.edu>
Subject: [PATCH] [IPSEC]: Add populate from packet (PFP) support
Date: Tue, 11 Dec 2007 19:23:52 -0800
Message-ID: <20071212032352.GA12890@hestia>
Reply-To: tyhicks@ou.edu
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Joy Latten <latten@us.ibm.com>
To: linux netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2007asmtp.zero.ou.edu ([129.15.0.236]:29756 "EHLO
	IT-CYCLONE.sooner.net.ou.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751702AbXLLDXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 22:23:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4301 requires us to associate each SPD entry with a set of flags to
determine how to assign the selector values when creating a new SAD entry.

Each selector in the new xfrm_state can either be assigned using the
corresponding selector in the xfrm_policy or with the corresponding value
in the flowi.  Prior to this patch, the fields in the flowi were always
used.

Signed-off-by: Tyler Hicks <tyhicks@ou.edu>

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b58adc5..ce6b1b5 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -362,6 +362,11 @@ struct xfrm_userpolicy_info {
 #define XFRM_POLICY_BLOCK	1
 	__u8				flags;
 #define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */
+#define XFRM_POLICY_PFP_SADDR	2
+#define XFRM_POLICY_PFP_DADDR	4
+#define XFRM_POLICY_PFP_PROTO	8
+#define XFRM_POLICY_PFP_SPORT	16
+#define XFRM_POLICY_PFP_DPORT	32
 	__u8				share;
 };
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 58dfa82..5a039a2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -261,9 +261,12 @@ struct xfrm_state_afinfo {
 	struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
 	int			(*init_flags)(struct xfrm_state *x);
-	void			(*init_tempsel)(struct xfrm_state *x, struct flowi *fl,
+	void			(*init_tempsel)(struct xfrm_state *x,
+						struct flowi *fl,
 						struct xfrm_tmpl *tmpl,
-						xfrm_address_t *daddr, xfrm_address_t *saddr);
+						struct xfrm_policy *pol,
+						xfrm_address_t *daddr,
+						xfrm_address_t *saddr);
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
 	int			(*output)(struct sk_buff *skb);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 13d54a1..0fb1092 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -23,18 +23,39 @@ static int xfrm4_init_flags(struct xfrm_state *x)
 
 static void
 __xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
-		     struct xfrm_tmpl *tmpl,
+		     struct xfrm_tmpl *tmpl, struct xfrm_policy *pol,
 		     xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
-	x->sel.daddr.a4 = fl->fl4_dst;
-	x->sel.saddr.a4 = fl->fl4_src;
-	x->sel.dport = xfrm_flowi_dport(fl);
-	x->sel.dport_mask = htons(0xffff);
-	x->sel.sport = xfrm_flowi_sport(fl);
-	x->sel.sport_mask = htons(0xffff);
-	x->sel.prefixlen_d = 32;
-	x->sel.prefixlen_s = 32;
-	x->sel.proto = fl->proto;
+	if (pol->flags & XFRM_POLICY_PFP_DADDR) {
+		x->sel.daddr.a4 = fl->fl4_dst;
+		x->sel.prefixlen_d = 32;
+	} else {
+		x->sel.daddr.a4 = pol->selector.daddr.a4;
+		x->sel.prefixlen_d = pol->selector.prefixlen_d;
+	}
+	if (pol->flags & XFRM_POLICY_PFP_SADDR) {
+		x->sel.saddr.a4 = fl->fl4_src;
+		x->sel.prefixlen_s = 32;
+	} else {
+		x->sel.saddr.a4 = pol->selector.saddr.a4;
+		x->sel.prefixlen_s = pol->selector.prefixlen_s;
+	}
+	if (pol->flags & XFRM_POLICY_PFP_DPORT) {
+		x->sel.dport = xfrm_flowi_dport(fl);
+		x->sel.dport_mask = htons(0xffff);
+	} else {
+		x->sel.dport = pol->selector.dport;
+		x->sel.dport_mask = pol->selector.dport_mask;
+	}
+	if (pol->flags & XFRM_POLICY_PFP_SPORT) {
+		x->sel.sport = xfrm_flowi_sport(fl);
+		x->sel.sport_mask = htons(0xffff);
+	} else {
+		x->sel.sport = pol->selector.sport;
+		x->sel.sport = pol->selector.sport_mask;
+	}
+	x->sel.proto = pol->flags & XFRM_POLICY_PFP_PROTO ?
+				fl->proto : pol->selector.proto;
 	x->sel.ifindex = fl->oif;
 	x->id = tmpl->id;
 	if (x->id.daddr.a4 == 0)
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index b392bee..213d92d 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -21,20 +21,43 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo;
 
 static void
 __xfrm6_init_tempsel(struct xfrm_state *x, struct flowi *fl,
-		     struct xfrm_tmpl *tmpl,
+		     struct xfrm_tmpl *tmpl, struct xfrm_policy *pol,
 		     xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
 	/* Initialize temporary selector matching only
 	 * to current session. */
-	ipv6_addr_copy((struct in6_addr *)&x->sel.daddr, &fl->fl6_dst);
-	ipv6_addr_copy((struct in6_addr *)&x->sel.saddr, &fl->fl6_src);
-	x->sel.dport = xfrm_flowi_dport(fl);
-	x->sel.dport_mask = htons(0xffff);
-	x->sel.sport = xfrm_flowi_sport(fl);
-	x->sel.sport_mask = htons(0xffff);
-	x->sel.prefixlen_d = 128;
-	x->sel.prefixlen_s = 128;
-	x->sel.proto = fl->proto;
+	if (pol->flags & XFRM_POLICY_PFP_DADDR) {
+		ipv6_addr_copy((struct in6_addr *)&x->sel.daddr, &fl->fl6_dst);
+		x->sel.prefixlen_d = 128;
+	} else {
+		ipv6_addr_copy((struct in6_addr *)&x->sel.daddr,
+			       (struct in6_addr *)&pol->selector.daddr);
+		x->sel.prefixlen_d = pol->selector.prefixlen_d;
+	}
+	if (pol->flags & XFRM_POLICY_PFP_SADDR) {
+		ipv6_addr_copy((struct in6_addr *)&x->sel.saddr, &fl->fl6_src);
+		x->sel.prefixlen_s = 128;
+	} else {
+		ipv6_addr_copy((struct in6_addr *)&x->sel.saddr,
+			       (struct in6_addr *)&pol->selector.saddr);
+		x->sel.prefixlen_s = pol->selector.prefixlen_s;
+	}
+	if (pol->flags & XFRM_POLICY_PFP_DPORT) {
+		x->sel.dport = xfrm_flowi_dport(fl);
+		x->sel.dport_mask = htons(0xffff);
+	} else {
+		x->sel.dport = pol->selector.dport;
+		x->sel.dport_mask = pol->selector.dport_mask;
+	}
+	if (pol->flags & XFRM_POLICY_PFP_SPORT) {
+		x->sel.sport = xfrm_flowi_sport(fl);
+		x->sel.sport_mask = htons(0xffff);
+	} else {
+		x->sel.sport = pol->selector.sport;
+		x->sel.sport_mask = pol->selector.sport_mask;
+	}
+	x->sel.proto = pol->flags & XFRM_POLICY_PFP_PROTO ?
+			fl->proto : pol->selector.proto;
 	x->sel.ifindex = fl->oif;
 	x->id = tmpl->id;
 	if (ipv6_addr_any((struct in6_addr*)&x->id.daddr))
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 224b44e..2dab50e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -654,14 +654,14 @@ EXPORT_SYMBOL(xfrm_sad_getinfo);
 
 static int
 xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
-		  struct xfrm_tmpl *tmpl,
+		  struct xfrm_tmpl *tmpl, struct xfrm_policy *pol,
 		  xfrm_address_t *daddr, xfrm_address_t *saddr,
 		  unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
 	if (!afinfo)
 		return -1;
-	afinfo->init_tempsel(x, fl, tmpl, daddr, saddr);
+	afinfo->init_tempsel(x, fl, tmpl, pol, daddr, saddr);
 	xfrm_state_put_afinfo(afinfo);
 	return 0;
 }
@@ -824,7 +824,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 		}
 		/* Initialize temporary selector matching only
 		 * to current session. */
-		xfrm_init_tempsel(x, fl, tmpl, daddr, saddr, family);
+		xfrm_init_tempsel(x, fl, tmpl, pol, daddr, saddr, family);
 
 		error = security_xfrm_state_alloc_acquire(x, pol->security, fl->secid);
 		if (error) {
-- 
1.5.3.4

