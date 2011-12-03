From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/9] cxgb3: Handle NULL dst neighbour in cxgb3_offload.c
Date: Fri, 02 Dec 2011 21:52:22 -0500 (EST)
Message-ID: <20111202.215222.1786543714107371836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552Ab1LCCw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 596cfe3..65e4b28 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1072,8 +1072,11 @@ static int is_offloading(struct net_device *dev)
 
 static void cxgb_neigh_update(struct neighbour *neigh)
 {
-	struct net_device *dev = neigh->dev;
+	struct net_device *dev;
 
+	if (!neigh)
+		return;
+	dev = neigh->dev;
 	if (dev && (is_offloading(dev))) {
 		struct t3cdev *tdev = dev2t3cdev(dev);
 
@@ -1107,6 +1110,7 @@ static void set_l2t_ix(struct t3cdev *tdev, u32 tid, struct l2t_entry *e)
 static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 {
 	struct net_device *olddev, *newdev;
+	struct neighbour *n;
 	struct tid_info *ti;
 	struct t3cdev *tdev;
 	u32 tid;
@@ -1114,8 +1118,16 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	struct l2t_entry *e;
 	struct t3c_tid_entry *te;
 
-	olddev = dst_get_neighbour_noref(old)->dev;
-	newdev = dst_get_neighbour_noref(new)->dev;
+	n = dst_get_neighbour_noref(old);
+	if (!n)
+		return;
+	olddev = n->dev;
+
+	n = dst_get_neighbour_noref(new);
+	if (!n)
+		return;
+	newdev = n->dev;
+
 	if (!is_offloading(olddev))
 		return;
 	if (!is_offloading(newdev)) {
-- 
1.7.7.3
