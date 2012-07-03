From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/19] net: Pass neighbours into the NETEVENT_REDIRECT
 event.
Date: Tue, 03 Jul 2012 02:46:52 -0700 (PDT)
Message-ID: <20120703.024652.1026785408745771924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab2GCJqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:53 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 1329558411C
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   23 ++++++++------------
 include/net/netevent.h                             |    3 +++
 net/ipv6/route.c                                   |    6 ++++-
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 55cf72a..633c602 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -62,7 +62,8 @@ static const unsigned int MAX_ATIDS = 64 * 1024;
 static const unsigned int ATID_BASE = 0x10000;
 
 static void cxgb_neigh_update(struct neighbour *neigh);
-static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new);
+static void cxgb_redirect(struct dst_entry *old, struct neighbour *old_neigh,
+			  struct dst_entry *new, struct neighbour *new_neigh);
 
 static inline int offload_activated(struct t3cdev *tdev)
 {
@@ -968,8 +969,9 @@ static int nb_callback(struct notifier_block *self, unsigned long event,
 	}
 	case (NETEVENT_REDIRECT):{
 		struct netevent_redirect *nr = ctx;
-		cxgb_redirect(nr->old, nr->new);
-		cxgb_neigh_update(dst_get_neighbour_noref(nr->new));
+		cxgb_redirect(nr->old, nr->old_neigh,
+			      nr->new, nr->new_neigh);
+		cxgb_neigh_update(nr->new_neigh);
 		break;
 	}
 	default:
@@ -1107,10 +1109,10 @@ static void set_l2t_ix(struct t3cdev *tdev, u32 tid, struct l2t_entry *e)
 	tdev->send(tdev, skb);
 }
 
-static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
+static void cxgb_redirect(struct dst_entry *old, struct neighbour *old_neigh,
+			  struct dst_entry *new, struct neighbour *new_neigh)
 {
 	struct net_device *olddev, *newdev;
-	struct neighbour *n;
 	struct tid_info *ti;
 	struct t3cdev *tdev;
 	u32 tid;
@@ -1118,15 +1120,8 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	struct l2t_entry *e;
 	struct t3c_tid_entry *te;
 
-	n = dst_get_neighbour_noref(old);
-	if (!n)
-		return;
-	olddev = n->dev;
-
-	n = dst_get_neighbour_noref(new);
-	if (!n)
-		return;
-	newdev = n->dev;
+	olddev = old_neigh->dev;
+	newdev = new_neigh->dev;
 
 	if (!is_offloading(olddev))
 		return;
diff --git a/include/net/netevent.h b/include/net/netevent.h
index 086f8a5..56e9862 100644
--- a/include/net/netevent.h
+++ b/include/net/netevent.h
@@ -12,10 +12,13 @@
  */
 
 struct dst_entry;
+struct neighbour;
 
 struct netevent_redirect {
 	struct dst_entry *old;
+	struct neighbour *old_neigh;
 	struct dst_entry *new;
+	struct neighbour *new_neigh;
 };
 
 enum netevent_notif_type {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4b581c6..24034d7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1687,6 +1687,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	struct rt6_info *rt, *nrt = NULL;
 	struct netevent_redirect netevent;
 	struct net *net = dev_net(neigh->dev);
+	struct neighbour *old_neigh;
 
 	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
 
@@ -1714,7 +1715,8 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	dst_confirm(&rt->dst);
 
 	/* Duplicate redirect: silently ignore. */
-	if (neigh == dst_get_neighbour_noref_raw(&rt->dst))
+	old_neigh = dst_get_neighbour_noref_raw(&rt->dst);
+	if (neigh == old_neigh)
 		goto out;
 
 	nrt = ip6_rt_copy(rt, dest);
@@ -1732,7 +1734,9 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 		goto out;
 
 	netevent.old = &rt->dst;
+	netevent.old_neigh = old_neigh;
 	netevent.new = &nrt->dst;
+	netevent.new_neigh = neigh;
 	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
 
 	if (rt->rt6i_flags & RTF_CACHE) {
-- 
1.7.10
