From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6 netevent: Remove old_neigh from netevent_redirect.
Date: Tue, 15 Jan 2013 04:28:27 +0900
Message-ID: <50F45C5B.8020507@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39989 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756654Ab3ANT23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 14:28:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only user is cxgb3 driver.

old_neigh is used to check device change, but it must not happen
on redirect.  In this sense, we can remove old_neigh argument.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   35 ++++++--------------
 include/net/netevent.h                             |    3 +-
 net/ipv6/route.c                                   |    3 +-
 3 files changed, 13 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 91d02eb..4232767 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -64,9 +64,8 @@ static const unsigned int MAX_ATIDS = 64 * 1024;
 static const unsigned int ATID_BASE = 0x10000;
 
 static void cxgb_neigh_update(struct neighbour *neigh);
-static void cxgb_redirect(struct dst_entry *old, struct neighbour *old_neigh,
-			  struct dst_entry *new, struct neighbour *new_neigh,
-			  const void *daddr);
+static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new,
+			  struct neighbour *neigh, const void *daddr);
 
 static inline int offload_activated(struct t3cdev *tdev)
 {
@@ -970,10 +969,9 @@ static int nb_callback(struct notifier_block *self, unsigned long event,
 	}
 	case (NETEVENT_REDIRECT):{
 		struct netevent_redirect *nr = ctx;
-		cxgb_redirect(nr->old, nr->old_neigh,
-			      nr->new, nr->new_neigh,
+		cxgb_redirect(nr->old, nr->new, nr->neigh,
 			      nr->daddr);
-		cxgb_neigh_update(nr->new_neigh);
+		cxgb_neigh_update(nr->neigh);
 		break;
 	}
 	default:
@@ -1109,11 +1107,11 @@ static void set_l2t_ix(struct t3cdev *tdev, u32 tid, struct l2t_entry *e)
 	tdev->send(tdev, skb);
 }
 
-static void cxgb_redirect(struct dst_entry *old, struct neighbour *old_neigh,
-			  struct dst_entry *new, struct neighbour *new_neigh,
+static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new,
+			  struct neighbour *neigh,
 			  const void *daddr)
 {
-	struct net_device *olddev, *newdev;
+	struct net_device *dev;
 	struct tid_info *ti;
 	struct t3cdev *tdev;
 	u32 tid;
@@ -1121,26 +1119,15 @@ static void cxgb_redirect(struct dst_entry *old, struct neighbour *old_neigh,
 	struct l2t_entry *e;
 	struct t3c_tid_entry *te;
 
-	olddev = old_neigh->dev;
-	newdev = new_neigh->dev;
+	dev = neigh->dev;
 
-	if (!is_offloading(olddev))
-		return;
-	if (!is_offloading(newdev)) {
-		pr_warn("%s: Redirect to non-offload device ignored\n",
-			__func__);
+	if (!is_offloading(dev))
 		return;
-	}
-	tdev = dev2t3cdev(olddev);
+	tdev = dev2t3cdev(dev);
 	BUG_ON(!tdev);
-	if (tdev != dev2t3cdev(newdev)) {
-		pr_warn("%s: Redirect to different offload device ignored\n",
-			__func__);
-		return;
-	}
 
 	/* Add new L2T entry */
-	e = t3_l2t_get(tdev, new, newdev, daddr);
+	e = t3_l2t_get(tdev, new, dev, daddr);
 	if (!e) {
 		pr_err("%s: couldn't allocate new l2t entry!\n", __func__);
 		return;
diff --git a/include/net/netevent.h b/include/net/netevent.h
index 3ce4988..fe630dd 100644
--- a/include/net/netevent.h
+++ b/include/net/netevent.h
@@ -16,9 +16,8 @@ struct neighbour;
 
 struct netevent_redirect {
 	struct dst_entry *old;
-	struct neighbour *old_neigh;
 	struct dst_entry *new;
-	struct neighbour *new_neigh;
+	struct neighbour *neigh;
 	const void *daddr;
 };
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 34f392f0..7c34c01 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1803,10 +1803,9 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 		goto out;
 
 	netevent.old = &rt->dst;
-	netevent.old_neigh = old_neigh;
 	netevent.new = &nrt->dst;
-	netevent.new_neigh = neigh;
 	netevent.daddr = &msg->dest;
+	netevent.neigh = neigh;
 	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
 
 	if (rt->rt6i_flags & RTF_CACHE) {
-- 
1.7.9.5
