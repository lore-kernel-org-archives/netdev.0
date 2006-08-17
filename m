From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/15]: [XFRM]: Add generation count to xfrm_state and
 xfrm_dst.
Date: Thu, 17 Aug 2006 01:28:09 -0700 (PDT)
Message-ID: <20060817.012809.85414862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33210
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932323AbWHQI2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:28:07 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Add generation count to xfrm_state and xfrm_dst.

Each xfrm_state inserted gets a new generation counter
value.  When a bundle is created, the xfrm_dst objects
get the current generation counter of the xfrm_state
they will attach to at dst->xfrm.

xfrm_bundle_ok() will return false if it sees an
xfrm_dst with a generation count different from the
generation count of the xfrm_state that dst points to.

This provides a facility by which to passively and
cheaply invalidate cached IPSEC routes during SA
database changes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h      |    3 +++
 net/ipv4/xfrm4_policy.c |    1 +
 net/ipv6/xfrm6_policy.c |    1 +
 net/xfrm/xfrm_policy.c  |    2 ++
 net/xfrm/xfrm_state.c   |    3 +++
 5 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e2bb0a9..7d18fff 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -103,6 +103,8 @@ struct xfrm_state
 	struct xfrm_id		id;
 	struct xfrm_selector	sel;
 
+	u32			genid;
+
 	/* Key manger bits */
 	struct {
 		u8		state;
@@ -540,6 +542,7 @@ struct xfrm_dst
 		struct rt6_info		rt6;
 	} u;
 	struct dst_entry *route;
+	u32 genid;
 	u32 route_mtu_cached;
 	u32 child_mtu_cached;
 	u32 route_cookie;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 8f50eae..72b75b8 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -93,6 +93,7 @@ __xfrm4_bundle_create(struct xfrm_policy
 
 		xdst = (struct xfrm_dst *)dst1;
 		xdst->route = &rt->u.dst;
+		xdst->genid = xfrm[i]->genid;
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 73cd250..e46a639 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -109,6 +109,7 @@ __xfrm6_bundle_create(struct xfrm_policy
 
 		xdst = (struct xfrm_dst *)dst1;
 		xdst->route = &rt->u.dst;
+		xdst->genid = xfrm[i]->genid;
 		if (rt->rt6i_node)
 			xdst->route_cookie = rt->rt6i_node->fn_sernum;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3da67ca..c504b9a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1300,6 +1300,8 @@ int xfrm_bundle_ok(struct xfrm_dst *firs
 			return 0;
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
+		if (xdst->genid != dst->xfrm->genid)
+			return 0;
 
 		mtu = dst_mtu(dst->child);
 		if (xdst->child_mtu_cached != mtu) {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index af3f23e..eb17f1b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -52,6 +52,7 @@ static struct hlist_head *xfrm_state_bys
 static unsigned int xfrm_state_hmask __read_mostly;
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 static unsigned int xfrm_state_num;
+static unsigned int xfrm_state_genid;
 
 static inline unsigned int __xfrm4_dst_hash(xfrm_address_t *addr, unsigned int hmask)
 {
@@ -640,6 +641,8 @@ static void __xfrm_state_insert(struct x
 {
 	unsigned h = xfrm_dst_hash(&x->id.daddr, x->props.family);
 
+	x->genid = ++xfrm_state_genid;
+
 	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 	xfrm_state_hold(x);
 
-- 
1.4.2.rc2.g3e042

