From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 1/2] infiniband: ipoib replace IPOIB_GID_FMT with %p6
Date: Tue, 28 Oct 2008 15:25:02 -0700
Message-ID: <1225232702.11483.63.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:9288 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbYJ1WZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:25:09 -0400
Received: by rn-out-0910.google.com with SMTP id k40so1383134rnd.17
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 15:25:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all uses of IPOIB_GID_FMT, IPOIB_GID_RAW_ARG() and IPOIB_GID_ARG()

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_cm.c        |    8 ++--
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   25 ++++-----
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   70 ++++++++++--------------
 3 files changed, 45 insertions(+), 58 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 7b14c2c..d98d87b 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1128,8 +1128,8 @@ static int ipoib_cm_tx_init(struct ipoib_cm_tx *p, u32 qpn,
 		goto err_send_cm;
 	}
 
-	ipoib_dbg(priv, "Request connection 0x%x for gid " IPOIB_GID_FMT " qpn 0x%x\n",
-		  p->qp->qp_num, IPOIB_GID_ARG(pathrec->dgid), qpn);
+	ipoib_dbg(priv, "Request connection 0x%x for gid %p6 qpn 0x%x\n",
+		  p->qp->qp_num, pathrec->dgid.raw, qpn);
 
 	return 0;
 
@@ -1276,8 +1276,8 @@ void ipoib_cm_destroy_tx(struct ipoib_cm_tx *tx)
 	if (test_and_clear_bit(IPOIB_FLAG_INITIALIZED, &tx->flags)) {
 		list_move(&tx->list, &priv->cm.reap_list);
 		queue_work(ipoib_workqueue, &priv->cm.reap_task);
-		ipoib_dbg(priv, "Reap connection for gid " IPOIB_GID_FMT "\n",
-			  IPOIB_GID_ARG(tx->neigh->dgid));
+		ipoib_dbg(priv, "Reap connection for gid %p6\n",
+			  tx->neigh->dgid.raw);
 		tx->neigh = NULL;
 	}
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index fddded7..e7f4f94 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -359,9 +359,9 @@ void ipoib_mark_paths_invalid(struct net_device *dev)
 	spin_lock_irq(&priv->lock);
 
 	list_for_each_entry_safe(path, tp, &priv->path_list, list) {
-		ipoib_dbg(priv, "mark path LID 0x%04x GID " IPOIB_GID_FMT " invalid\n",
+		ipoib_dbg(priv, "mark path LID 0x%04x GID %p6 invalid\n",
 			be16_to_cpu(path->pathrec.dlid),
-			IPOIB_GID_ARG(path->pathrec.dgid));
+			path->pathrec.dgid.raw);
 		path->valid =  0;
 	}
 
@@ -413,11 +413,11 @@ static void path_rec_completion(int status,
 	unsigned long flags;
 
 	if (!status)
-		ipoib_dbg(priv, "PathRec LID 0x%04x for GID " IPOIB_GID_FMT "\n",
-			  be16_to_cpu(pathrec->dlid), IPOIB_GID_ARG(pathrec->dgid));
+		ipoib_dbg(priv, "PathRec LID 0x%04x for GID %p6\n",
+			  be16_to_cpu(pathrec->dlid), pathrec->dgid.raw);
 	else
-		ipoib_dbg(priv, "PathRec status %d for GID " IPOIB_GID_FMT "\n",
-			  status, IPOIB_GID_ARG(path->pathrec.dgid));
+		ipoib_dbg(priv, "PathRec status %d for GID %p6\n",
+			  status, path->pathrec.dgid.raw);
 
 	skb_queue_head_init(&skqueue);
 
@@ -527,8 +527,8 @@ static int path_rec_start(struct net_device *dev,
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	ipoib_dbg(priv, "Start path record lookup for " IPOIB_GID_FMT "\n",
-		  IPOIB_GID_ARG(path->pathrec.dgid));
+	ipoib_dbg(priv, "Start path record lookup for %p6\n",
+		  path->pathrec.dgid.raw);
 
 	init_completion(&path->done);
 
@@ -764,12 +764,11 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			if ((be16_to_cpup((__be16 *) skb->data) != ETH_P_ARP) &&
 			    (be16_to_cpup((__be16 *) skb->data) != ETH_P_RARP)) {
-				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x "
-					   IPOIB_GID_FMT "\n",
+				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x %p6\n",
 					   skb->dst ? "neigh" : "dst",
 					   be16_to_cpup((__be16 *) skb->data),
 					   IPOIB_QPN(phdr->hwaddr),
-					   IPOIB_GID_RAW_ARG(phdr->hwaddr + 4));
+					   phdr->hwaddr + 4);
 				dev_kfree_skb_any(skb);
 				++dev->stats.tx_dropped;
 				return NETDEV_TX_OK;
@@ -845,9 +844,9 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 	else
 		return;
 	ipoib_dbg(priv,
-		  "neigh_cleanup for %06x " IPOIB_GID_FMT "\n",
+		  "neigh_cleanup for %06x %p6\n",
 		  IPOIB_QPN(n->ha),
-		  IPOIB_GID_RAW_ARG(n->ha + 4));
+		  n->ha + 4);
 
 	spin_lock_irqsave(&priv->lock, flags);
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index d9d1223..0de79cf 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -71,9 +71,8 @@ static void ipoib_mcast_free(struct ipoib_mcast *mcast)
 	struct ipoib_neigh *neigh, *tmp;
 	int tx_dropped = 0;
 
-	ipoib_dbg_mcast(netdev_priv(dev),
-			"deleting multicast group " IPOIB_GID_FMT "\n",
-			IPOIB_GID_ARG(mcast->mcmember.mgid));
+	ipoib_dbg_mcast(netdev_priv(dev), "deleting multicast group %p6\n",
+			mcast->mcmember.mgid.raw);
 
 	spin_lock_irq(&priv->lock);
 
@@ -205,9 +204,8 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 
 	if (!test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags)) {
 		if (test_and_set_bit(IPOIB_MCAST_FLAG_ATTACHED, &mcast->flags)) {
-			ipoib_warn(priv, "multicast group " IPOIB_GID_FMT
-				   " already attached\n",
-				   IPOIB_GID_ARG(mcast->mcmember.mgid));
+			ipoib_warn(priv, "multicast group %p6 already attached\n",
+				   mcast->mcmember.mgid.raw);
 
 			return 0;
 		}
@@ -215,9 +213,8 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 		ret = ipoib_mcast_attach(dev, be16_to_cpu(mcast->mcmember.mlid),
 					 &mcast->mcmember.mgid, set_qkey);
 		if (ret < 0) {
-			ipoib_warn(priv, "couldn't attach QP to multicast group "
-				   IPOIB_GID_FMT "\n",
-				   IPOIB_GID_ARG(mcast->mcmember.mgid));
+			ipoib_warn(priv, "couldn't attach QP to multicast group %p6\n",
+				   mcast->mcmember.mgid.raw);
 
 			clear_bit(IPOIB_MCAST_FLAG_ATTACHED, &mcast->flags);
 			return ret;
@@ -248,9 +245,8 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 			mcast->ah = ah;
 			spin_unlock_irq(&priv->lock);
 
-			ipoib_dbg_mcast(priv, "MGID " IPOIB_GID_FMT
-					" AV %p, LID 0x%04x, SL %d\n",
-					IPOIB_GID_ARG(mcast->mcmember.mgid),
+			ipoib_dbg_mcast(priv, "MGID %p6 AV %p, LID 0x%04x, SL %d\n",
+					mcast->mcmember.mgid.raw,
 					mcast->ah->ah,
 					be16_to_cpu(mcast->mcmember.mlid),
 					mcast->mcmember.sl);
@@ -295,9 +291,8 @@ ipoib_mcast_sendonly_join_complete(int status,
 
 	if (status) {
 		if (mcast->logcount++ < 20)
-			ipoib_dbg_mcast(netdev_priv(dev), "multicast join failed for "
-					IPOIB_GID_FMT ", status %d\n",
-					IPOIB_GID_ARG(mcast->mcmember.mgid), status);
+			ipoib_dbg_mcast(netdev_priv(dev), "multicast join failed for %p6, status %d\n",
+					mcast->mcmember.mgid.raw, status);
 
 		/* Flush out any queued packets */
 		netif_tx_lock_bh(dev);
@@ -356,9 +351,8 @@ static int ipoib_mcast_sendonly_join(struct ipoib_mcast *mcast)
 		ipoib_warn(priv, "ib_sa_join_multicast failed (ret = %d)\n",
 			   ret);
 	} else {
-		ipoib_dbg_mcast(priv, "no multicast record for " IPOIB_GID_FMT
-				", starting join\n",
-				IPOIB_GID_ARG(mcast->mcmember.mgid));
+		ipoib_dbg_mcast(priv, "no multicast record for %p6, starting join\n",
+				mcast->mcmember.mgid.raw);
 	}
 
 	return ret;
@@ -386,9 +380,8 @@ static int ipoib_mcast_join_complete(int status,
 	struct net_device *dev = mcast->dev;
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	ipoib_dbg_mcast(priv, "join completion for " IPOIB_GID_FMT
-			" (status %d)\n",
-			IPOIB_GID_ARG(mcast->mcmember.mgid), status);
+	ipoib_dbg_mcast(priv, "join completion for %p6 (status %d)\n",
+			mcast->mcmember.mgid.raw, status);
 
 	/* We trap for port events ourselves. */
 	if (status == -ENETRESET)
@@ -417,15 +410,11 @@ static int ipoib_mcast_join_complete(int status,
 
 	if (mcast->logcount++ < 20) {
 		if (status == -ETIMEDOUT) {
-			ipoib_dbg_mcast(priv, "multicast join failed for " IPOIB_GID_FMT
-					", status %d\n",
-					IPOIB_GID_ARG(mcast->mcmember.mgid),
-					status);
+			ipoib_dbg_mcast(priv, "multicast join failed for %p6, status %d\n",
+					mcast->mcmember.mgid.raw, status);
 		} else {
-			ipoib_warn(priv, "multicast join failed for "
-				   IPOIB_GID_FMT ", status %d\n",
-				   IPOIB_GID_ARG(mcast->mcmember.mgid),
-				   status);
+			ipoib_warn(priv, "multicast join failed for %p6, status %d\n",
+				   mcast->mcmember.mgid.raw, status);
 		}
 	}
 
@@ -457,8 +446,7 @@ static void ipoib_mcast_join(struct net_device *dev, struct ipoib_mcast *mcast,
 	ib_sa_comp_mask comp_mask;
 	int ret = 0;
 
-	ipoib_dbg_mcast(priv, "joining MGID " IPOIB_GID_FMT "\n",
-			IPOIB_GID_ARG(mcast->mcmember.mgid));
+	ipoib_dbg_mcast(priv, "joining MGID %p6\n", mcast->mcmember.mgid.raw);
 
 	rec.mgid     = mcast->mcmember.mgid;
 	rec.port_gid = priv->local_gid;
@@ -643,8 +631,8 @@ static int ipoib_mcast_leave(struct net_device *dev, struct ipoib_mcast *mcast)
 		ib_sa_free_multicast(mcast->mc);
 
 	if (test_and_clear_bit(IPOIB_MCAST_FLAG_ATTACHED, &mcast->flags)) {
-		ipoib_dbg_mcast(priv, "leaving MGID " IPOIB_GID_FMT "\n",
-				IPOIB_GID_ARG(mcast->mcmember.mgid));
+		ipoib_dbg_mcast(priv, "leaving MGID %p6\n",
+				mcast->mcmember.mgid.raw);
 
 		/* Remove ourselves from the multicast group */
 		ret = ib_detach_mcast(priv->qp, &mcast->mcmember.mgid,
@@ -675,8 +663,8 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 	mcast = __ipoib_mcast_find(dev, mgid);
 	if (!mcast) {
 		/* Let's create a new send only group now */
-		ipoib_dbg_mcast(priv, "setting up send only multicast group for "
-				IPOIB_GID_FMT "\n", IPOIB_GID_RAW_ARG(mgid));
+		ipoib_dbg_mcast(priv, "setting up send only multicast group for %p6\n",
+				mgid);
 
 		mcast = ipoib_mcast_alloc(dev, 0);
 		if (!mcast) {
@@ -809,14 +797,14 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 			/* ignore group which is directly joined by userspace */
 			if (test_bit(IPOIB_FLAG_UMCAST, &priv->flags) &&
 			    !ib_sa_get_mcmember_rec(priv->ca, priv->port, &mgid, &rec)) {
-				ipoib_dbg_mcast(priv, "ignoring multicast entry for mgid "
-						IPOIB_GID_FMT "\n", IPOIB_GID_ARG(mgid));
+				ipoib_dbg_mcast(priv, "ignoring multicast entry for mgid %p6\n",
+						mgid.raw);
 				continue;
 			}
 
 			/* Not found or send-only group, let's add a new entry */
-			ipoib_dbg_mcast(priv, "adding multicast entry for mgid "
-					IPOIB_GID_FMT "\n", IPOIB_GID_ARG(mgid));
+			ipoib_dbg_mcast(priv, "adding multicast entry for mgid %p6\n",
+					mgid.raw);
 
 			nmcast = ipoib_mcast_alloc(dev, 0);
 			if (!nmcast) {
@@ -849,8 +837,8 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 	list_for_each_entry_safe(mcast, tmcast, &priv->multicast_list, list) {
 		if (!test_bit(IPOIB_MCAST_FLAG_FOUND, &mcast->flags) &&
 		    !test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags)) {
-			ipoib_dbg_mcast(priv, "deleting multicast group " IPOIB_GID_FMT "\n",
-					IPOIB_GID_ARG(mcast->mcmember.mgid));
+			ipoib_dbg_mcast(priv, "deleting multicast group %p6\n",
+					mcast->mcmember.mgid.raw);
 
 			rb_erase(&mcast->rb_node, &priv->multicast_tree);
 
-- 
1.6.0.3.729.g6ea410


