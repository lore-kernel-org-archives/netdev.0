From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 3/5] xfrm: Convert xfrm_addr_cmp() to boolean xfrm_addr_equal().
Date: Wed, 30 Jan 2013 07:48:50 +0900
Message-ID: <510851D2.8080000@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54631 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752773Ab3A2Wsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 17:48:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users of xfrm_addr_cmp() use its result as boolean.
Introduce xfrm_addr_equal() (which is equal to !xfrm_addr_cmp())
and convert all users.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h     |   25 ++++++++++++-------------
 net/key/af_key.c       |    8 ++++----
 net/xfrm/xfrm_policy.c |   24 ++++++++++++------------
 net/xfrm/xfrm_state.c  |   34 +++++++++++++++++-----------------
 net/xfrm/xfrm_user.c   |    2 +-
 5 files changed, 46 insertions(+), 47 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0d8a797..de34883 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1574,27 +1574,26 @@ extern struct xfrm_algo_desc *xfrm_calg_get_byname(const char *name, int probe);
 extern struct xfrm_algo_desc *xfrm_aead_get_byname(const char *name, int icv_len,
 						   int probe);
 
-static inline int xfrm_addr_cmp(const xfrm_address_t *a,
-				const xfrm_address_t *b,
-				int family)
+static inline bool xfrm6_addr_equal(const xfrm_address_t *a,
+				    const xfrm_address_t *b)
+{
+	return ipv6_addr_equal((const struct in6_addr *)a,
+			       (const struct in6_addr *)b);
+}
+
+static inline bool xfrm_addr_equal(const xfrm_address_t *a,
+				   const xfrm_address_t *b,
+				   sa_family_t family)
 {
 	switch (family) {
 	default:
 	case AF_INET:
-		return (__force u32)a->a4 - (__force u32)b->a4;
+		return ((__force u32)a->a4 ^ (__force u32)b->a4) == 0;
 	case AF_INET6:
-		return ipv6_addr_cmp((const struct in6_addr *)a,
-				     (const struct in6_addr *)b);
+		return xfrm6_addr_equal(a, b);
 	}
 }
 
-static inline bool xfrm6_addr_equal(const xfrm_address_t *a,
-				    const xfrm_address_t *b)
-{
-	return ipv6_addr_equal((const struct in6_addr *)a,
-			       (const struct in6_addr *)b);
-}
-
 static inline int xfrm_policy_id2dir(u32 index)
 {
 	return index & 7;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5b426a6..cc2630a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -762,7 +762,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	}
 
 	/* identity & sensitivity */
-	if (xfrm_addr_cmp(&x->sel.saddr, &x->props.saddr, x->props.family))
+	if (!xfrm_addr_equal(&x->sel.saddr, &x->props.saddr, x->props.family))
 		size += sizeof(struct sadb_address) + sockaddr_size;
 
 	if (add_keys) {
@@ -909,8 +909,8 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 	if (!addr->sadb_address_prefixlen)
 		BUG();
 
-	if (xfrm_addr_cmp(&x->sel.saddr, &x->props.saddr,
-			  x->props.family)) {
+	if (!xfrm_addr_equal(&x->sel.saddr, &x->props.saddr,
+			     x->props.family)) {
 		addr = (struct sadb_address*) skb_put(skb,
 			sizeof(struct sadb_address)+sockaddr_size);
 		addr->sadb_address_len =
@@ -1321,7 +1321,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, const struct sadb_
 
 	if (hdr->sadb_msg_seq) {
 		x = xfrm_find_acq_byseq(net, DUMMY_MARK, hdr->sadb_msg_seq);
-		if (x && xfrm_addr_cmp(&x->id.daddr, xdaddr, family)) {
+		if (x && !xfrm_addr_equal(&x->id.daddr, xdaddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
 		}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 07c5857..6c9aa64 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2786,10 +2786,10 @@ static bool xfrm_migrate_selector_match(const struct xfrm_selector *sel_cmp,
 {
 	if (sel_cmp->proto == IPSEC_ULPROTO_ANY) {
 		if (sel_tgt->family == sel_cmp->family &&
-		    xfrm_addr_cmp(&sel_tgt->daddr, &sel_cmp->daddr,
-				  sel_cmp->family) == 0 &&
-		    xfrm_addr_cmp(&sel_tgt->saddr, &sel_cmp->saddr,
-				  sel_cmp->family) == 0 &&
+		    xfrm_addr_equal(&sel_tgt->daddr, &sel_cmp->daddr,
+				    sel_cmp->family) &&
+		    xfrm_addr_equal(&sel_tgt->saddr, &sel_cmp->saddr,
+				    sel_cmp->family) &&
 		    sel_tgt->prefixlen_d == sel_cmp->prefixlen_d &&
 		    sel_tgt->prefixlen_s == sel_cmp->prefixlen_s) {
 			return true;
@@ -2847,10 +2847,10 @@ static int migrate_tmpl_match(const struct xfrm_migrate *m, const struct xfrm_tm
 		switch (t->mode) {
 		case XFRM_MODE_TUNNEL:
 		case XFRM_MODE_BEET:
-			if (xfrm_addr_cmp(&t->id.daddr, &m->old_daddr,
-					  m->old_family) == 0 &&
-			    xfrm_addr_cmp(&t->saddr, &m->old_saddr,
-					  m->old_family) == 0) {
+			if (xfrm_addr_equal(&t->id.daddr, &m->old_daddr,
+					    m->old_family) &&
+			    xfrm_addr_equal(&t->saddr, &m->old_saddr,
+					    m->old_family)) {
 				match = 1;
 			}
 			break;
@@ -2916,10 +2916,10 @@ static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
 		return -EINVAL;
 
 	for (i = 0; i < num_migrate; i++) {
-		if ((xfrm_addr_cmp(&m[i].old_daddr, &m[i].new_daddr,
-				   m[i].old_family) == 0) &&
-		    (xfrm_addr_cmp(&m[i].old_saddr, &m[i].new_saddr,
-				   m[i].old_family) == 0))
+		if (xfrm_addr_equal(&m[i].old_daddr, &m[i].new_daddr,
+				    m[i].old_family) &&
+		    xfrm_addr_equal(&m[i].old_saddr, &m[i].new_saddr,
+				    m[i].old_family))
 			return -EINVAL;
 		if (xfrm_addr_any(&m[i].new_daddr, m[i].new_family) ||
 		    xfrm_addr_any(&m[i].new_saddr, m[i].new_family))
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0adae91..ae01bdb 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -691,7 +691,7 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark,
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
 		    x->id.proto     != proto ||
-		    xfrm_addr_cmp(&x->id.daddr, daddr, family))
+		    !xfrm_addr_equal(&x->id.daddr, daddr, family))
 			continue;
 
 		if ((mark & x->mark.m) != x->mark.v)
@@ -715,8 +715,8 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 	hlist_for_each_entry(x, entry, net->xfrm.state_bysrc+h, bysrc) {
 		if (x->props.family != family ||
 		    x->id.proto     != proto ||
-		    xfrm_addr_cmp(&x->id.daddr, daddr, family) ||
-		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
+		    !xfrm_addr_equal(&x->id.daddr, daddr, family) ||
+		    !xfrm_addr_equal(&x->props.saddr, saddr, family))
 			continue;
 
 		if ((mark & x->mark.m) != x->mark.v)
@@ -981,8 +981,8 @@ static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
 		if (x->props.family	== family &&
 		    x->props.reqid	== reqid &&
 		    (mark & x->mark.m) == x->mark.v &&
-		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family) &&
-		    !xfrm_addr_cmp(&x->props.saddr, &xnew->props.saddr, family))
+		    xfrm_addr_equal(&x->id.daddr, &xnew->id.daddr, family) &&
+		    xfrm_addr_equal(&x->props.saddr, &xnew->props.saddr, family))
 			x->genid++;
 	}
 }
@@ -1016,8 +1016,8 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_mark *m,
 		    x->id.spi       != 0 ||
 		    x->id.proto	    != proto ||
 		    (mark & x->mark.m) != x->mark.v ||
-		    xfrm_addr_cmp(&x->id.daddr, daddr, family) ||
-		    xfrm_addr_cmp(&x->props.saddr, saddr, family))
+		    !xfrm_addr_equal(&x->id.daddr, daddr, family) ||
+		    !xfrm_addr_equal(&x->props.saddr, saddr, family))
 			continue;
 
 		xfrm_state_hold(x);
@@ -1100,7 +1100,7 @@ int xfrm_state_add(struct xfrm_state *x)
 	if (use_spi && x->km.seq) {
 		x1 = __xfrm_find_acq_byseq(net, mark, x->km.seq);
 		if (x1 && ((x1->id.proto != x->id.proto) ||
-		    xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family))) {
+		    !xfrm_addr_equal(&x1->id.daddr, &x->id.daddr, family))) {
 			to_put = x1;
 			x1 = NULL;
 		}
@@ -1226,10 +1226,10 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 				continue;
 			if (m->reqid && x->props.reqid != m->reqid)
 				continue;
-			if (xfrm_addr_cmp(&x->id.daddr, &m->old_daddr,
-					  m->old_family) ||
-			    xfrm_addr_cmp(&x->props.saddr, &m->old_saddr,
-					  m->old_family))
+			if (!xfrm_addr_equal(&x->id.daddr, &m->old_daddr,
+					     m->old_family) ||
+			    !xfrm_addr_equal(&x->props.saddr, &m->old_saddr,
+					     m->old_family))
 				continue;
 			xfrm_state_hold(x);
 			return x;
@@ -1241,10 +1241,10 @@ struct xfrm_state * xfrm_migrate_state_find(struct xfrm_migrate *m)
 			if (x->props.mode != m->mode ||
 			    x->id.proto != m->proto)
 				continue;
-			if (xfrm_addr_cmp(&x->id.daddr, &m->old_daddr,
-					  m->old_family) ||
-			    xfrm_addr_cmp(&x->props.saddr, &m->old_saddr,
-					  m->old_family))
+			if (!xfrm_addr_equal(&x->id.daddr, &m->old_daddr,
+					     m->old_family) ||
+			    !xfrm_addr_equal(&x->props.saddr, &m->old_saddr,
+					     m->old_family))
 				continue;
 			xfrm_state_hold(x);
 			return x;
@@ -1269,7 +1269,7 @@ struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
 	memcpy(&xc->props.saddr, &m->new_saddr, sizeof(xc->props.saddr));
 
 	/* add state */
-	if (!xfrm_addr_cmp(&x->id.daddr, &m->new_daddr, m->new_family)) {
+	if (xfrm_addr_equal(&x->id.daddr, &m->new_daddr, m->new_family)) {
 		/* a care is needed when the destination address of the
 		   state is to be updated as it is a part of triplet */
 		xfrm_state_insert(xc);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index eb872b2..fbd9e6c 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1112,7 +1112,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	mark = xfrm_mark_get(attrs, &m);
 	if (p->info.seq) {
 		x = xfrm_find_acq_byseq(net, mark, p->info.seq);
-		if (x && xfrm_addr_cmp(&x->id.daddr, daddr, family)) {
+		if (x && !xfrm_addr_equal(&x->id.daddr, daddr, family)) {
 			xfrm_state_put(x);
 			x = NULL;
 		}
-- 
1.7.9.5
