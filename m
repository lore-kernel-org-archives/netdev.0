From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/9] infiniband: cxgb4: Consolidate 3 copies of the same
 operation into 1 helper function.
Date: Fri, 02 Dec 2011 21:52:31 -0500 (EST)
Message-ID: <20111202.215231.1935985613035773270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab1LCCwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Three pieces of code do the same thing, create a l2t entry and then
import this information into the c4iw_ep object.

Create a helper function and call it from these 3 locations instead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/hw/cxgb4/cm.c |  220 ++++++++++++++------------------------
 1 files changed, 80 insertions(+), 140 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index e61c802..0668bb3 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1556,6 +1556,67 @@ static void get_4tuple(struct cpl_pass_accept_req *req,
 	return;
 }
 
+static int import_ep(struct c4iw_ep *ep, __be32 peer_ip, struct dst_entry *dst,
+		     struct c4iw_dev *cdev, bool clear_mpa_v1)
+{
+	struct neighbour *n;
+	int err, step;
+
+	rcu_read_lock();
+	n = dst_get_neighbour_noref(dst);
+	err = -ENODEV;
+	if (!n)
+		goto out;
+	err = -ENOMEM;
+	if (n->dev->flags & IFF_LOOPBACK) {
+		struct net_device *pdev;
+
+		pdev = ip_dev_find(&init_net, peer_ip);
+		ep->l2t = cxgb4_l2t_get(cdev->rdev.lldi.l2t,
+					n, pdev, 0);
+		if (!ep->l2t)
+			goto out;
+		ep->mtu = pdev->mtu;
+		ep->tx_chan = cxgb4_port_chan(pdev);
+		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
+		step = cdev->rdev.lldi.ntxq /
+			cdev->rdev.lldi.nchan;
+		ep->txq_idx = cxgb4_port_idx(pdev) * step;
+		step = cdev->rdev.lldi.nrxq /
+			cdev->rdev.lldi.nchan;
+		ep->ctrlq_idx = cxgb4_port_idx(pdev);
+		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
+			cxgb4_port_idx(pdev) * step];
+		dev_put(pdev);
+	} else {
+		ep->l2t = cxgb4_l2t_get(cdev->rdev.lldi.l2t,
+					n, n->dev, 0);
+		if (!ep->l2t)
+			goto out;
+		ep->mtu = dst_mtu(ep->dst);
+		ep->tx_chan = cxgb4_port_chan(n->dev);
+		ep->smac_idx = (cxgb4_port_viid(n->dev) & 0x7F) << 1;
+		step = cdev->rdev.lldi.ntxq /
+			cdev->rdev.lldi.nchan;
+		ep->txq_idx = cxgb4_port_idx(n->dev) * step;
+		ep->ctrlq_idx = cxgb4_port_idx(n->dev);
+		step = cdev->rdev.lldi.nrxq /
+			cdev->rdev.lldi.nchan;
+		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
+			cxgb4_port_idx(n->dev) * step];
+
+		if (clear_mpa_v1) {
+			ep->retry_with_mpa_v1 = 0;
+			ep->tried_with_mpa_v1 = 0;
+		}
+	}
+	err = 0;
+out:
+	rcu_read_unlock();
+
+	return err;
+}
+
 static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct c4iw_ep *child_ep, *parent_ep;
@@ -1563,18 +1624,11 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	unsigned int stid = GET_POPEN_TID(ntohl(req->tos_stid));
 	struct tid_info *t = dev->rdev.lldi.tids;
 	unsigned int hwtid = GET_TID(req);
-	struct neighbour *neigh;
 	struct dst_entry *dst;
-	struct l2t_entry *l2t;
 	struct rtable *rt;
 	__be32 local_ip, peer_ip;
 	__be16 local_port, peer_port;
-	struct net_device *pdev;
-	u32 tx_chan, smac_idx;
-	u16 rss_qid;
-	u32 mtu;
-	int step;
-	int txq_idx, ctrlq_idx;
+	int err;
 
 	parent_ep = lookup_stid(t, stid);
 	PDBG("%s parent ep %p tid %u\n", __func__, parent_ep, hwtid);
@@ -1596,49 +1650,24 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 	dst = &rt->dst;
-	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(dst);
-	if (neigh->dev->flags & IFF_LOOPBACK) {
-		pdev = ip_dev_find(&init_net, peer_ip);
-		BUG_ON(!pdev);
-		l2t = cxgb4_l2t_get(dev->rdev.lldi.l2t, neigh, pdev, 0);
-		mtu = pdev->mtu;
-		tx_chan = cxgb4_port_chan(pdev);
-		smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
-		step = dev->rdev.lldi.ntxq / dev->rdev.lldi.nchan;
-		txq_idx = cxgb4_port_idx(pdev) * step;
-		ctrlq_idx = cxgb4_port_idx(pdev);
-		step = dev->rdev.lldi.nrxq / dev->rdev.lldi.nchan;
-		rss_qid = dev->rdev.lldi.rxq_ids[cxgb4_port_idx(pdev) * step];
-		dev_put(pdev);
-	} else {
-		l2t = cxgb4_l2t_get(dev->rdev.lldi.l2t, neigh, neigh->dev, 0);
-		mtu = dst_mtu(dst);
-		tx_chan = cxgb4_port_chan(neigh->dev);
-		smac_idx = (cxgb4_port_viid(neigh->dev) & 0x7F) << 1;
-		step = dev->rdev.lldi.ntxq / dev->rdev.lldi.nchan;
-		txq_idx = cxgb4_port_idx(neigh->dev) * step;
-		ctrlq_idx = cxgb4_port_idx(neigh->dev);
-		step = dev->rdev.lldi.nrxq / dev->rdev.lldi.nchan;
-		rss_qid = dev->rdev.lldi.rxq_ids[
-			  cxgb4_port_idx(neigh->dev) * step];
-	}
-	rcu_read_unlock();
-	if (!l2t) {
-		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
+
+	child_ep = alloc_ep(sizeof(*child_ep), GFP_KERNEL);
+	if (!child_ep) {
+		printk(KERN_ERR MOD "%s - failed to allocate ep entry!\n",
 		       __func__);
 		dst_release(dst);
 		goto reject;
 	}
 
-	child_ep = alloc_ep(sizeof(*child_ep), GFP_KERNEL);
-	if (!child_ep) {
-		printk(KERN_ERR MOD "%s - failed to allocate ep entry!\n",
+	err = import_ep(child_ep, peer_ip, dst, dev, false);
+	if (err) {
+		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
-		cxgb4_l2t_release(l2t);
 		dst_release(dst);
+		kfree(child_ep);
 		goto reject;
 	}
+
 	state_set(&child_ep->com, CONNECTING);
 	child_ep->com.dev = dev;
 	child_ep->com.cm_id = NULL;
@@ -1651,18 +1680,11 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	c4iw_get_ep(&parent_ep->com);
 	child_ep->parent_ep = parent_ep;
 	child_ep->tos = GET_POPEN_TOS(ntohl(req->tos_stid));
-	child_ep->l2t = l2t;
 	child_ep->dst = dst;
 	child_ep->hwtid = hwtid;
-	child_ep->tx_chan = tx_chan;
-	child_ep->smac_idx = smac_idx;
-	child_ep->rss_qid = rss_qid;
-	child_ep->mtu = mtu;
-	child_ep->txq_idx = txq_idx;
-	child_ep->ctrlq_idx = ctrlq_idx;
 
 	PDBG("%s tx_chan %u smac_idx %u rss_qid %u\n", __func__,
-	     tx_chan, smac_idx, rss_qid);
+	     child_ep->tx_chan, child_ep->smac_idx, child_ep->rss_qid);
 
 	init_timer(&child_ep->timer);
 	cxgb4_insert_tid(t, child_ep, hwtid);
@@ -1792,11 +1814,8 @@ static int is_neg_adv_abort(unsigned int status)
 
 static int c4iw_reconnect(struct c4iw_ep *ep)
 {
-	int err = 0;
 	struct rtable *rt;
-	struct net_device *pdev;
-	struct neighbour *neigh;
-	int step;
+	int err = 0;
 
 	PDBG("%s qp %p cm_id %p\n", __func__, ep->com.qp, ep->com.cm_id);
 	init_timer(&ep->timer);
@@ -1824,47 +1843,10 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	}
 	ep->dst = &rt->dst;
 
-	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(ep->dst);
-
-	/* get a l2t entry */
-	if (neigh->dev->flags & IFF_LOOPBACK) {
-		PDBG("%s LOOPBACK\n", __func__);
-		pdev = ip_dev_find(&init_net,
-				   ep->com.cm_id->remote_addr.sin_addr.s_addr);
-		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-					neigh, pdev, 0);
-		ep->mtu = pdev->mtu;
-		ep->tx_chan = cxgb4_port_chan(pdev);
-		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
-		step = ep->com.dev->rdev.lldi.ntxq /
-			ep->com.dev->rdev.lldi.nchan;
-		ep->txq_idx = cxgb4_port_idx(pdev) * step;
-		step = ep->com.dev->rdev.lldi.nrxq /
-			ep->com.dev->rdev.lldi.nchan;
-		ep->ctrlq_idx = cxgb4_port_idx(pdev);
-		ep->rss_qid = ep->com.dev->rdev.lldi.rxq_ids[
-			cxgb4_port_idx(pdev) * step];
-		dev_put(pdev);
-	} else {
-		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-					neigh, neigh->dev, 0);
-		ep->mtu = dst_mtu(ep->dst);
-		ep->tx_chan = cxgb4_port_chan(neigh->dev);
-		ep->smac_idx = (cxgb4_port_viid(neigh->dev) & 0x7F) << 1;
-		step = ep->com.dev->rdev.lldi.ntxq /
-			ep->com.dev->rdev.lldi.nchan;
-		ep->txq_idx = cxgb4_port_idx(neigh->dev) * step;
-		ep->ctrlq_idx = cxgb4_port_idx(neigh->dev);
-		step = ep->com.dev->rdev.lldi.nrxq /
-			ep->com.dev->rdev.lldi.nchan;
-		ep->rss_qid = ep->com.dev->rdev.lldi.rxq_ids[
-			cxgb4_port_idx(neigh->dev) * step];
-	}
-	rcu_read_unlock();
-	if (!ep->l2t) {
+	err = import_ep(ep, ep->com.cm_id->remote_addr.sin_addr.s_addr,
+			ep->dst, ep->com.dev, false);
+	if (err) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
-		err = -ENOMEM;
 		goto fail4;
 	}
 
@@ -2240,13 +2222,10 @@ err:
 
 int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 {
-	int err = 0;
 	struct c4iw_dev *dev = to_c4iw_dev(cm_id->device);
 	struct c4iw_ep *ep;
 	struct rtable *rt;
-	struct net_device *pdev;
-	struct neighbour *neigh;
-	int step;
+	int err = 0;
 
 	if ((conn_param->ord > c4iw_max_read_depth) ||
 	    (conn_param->ird > c4iw_max_read_depth)) {
@@ -2307,49 +2286,10 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	ep->dst = &rt->dst;
 
-	rcu_read_lock();
-	neigh = dst_get_neighbour_noref(ep->dst);
-
-	/* get a l2t entry */
-	if (neigh->dev->flags & IFF_LOOPBACK) {
-		PDBG("%s LOOPBACK\n", __func__);
-		pdev = ip_dev_find(&init_net,
-				   cm_id->remote_addr.sin_addr.s_addr);
-		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-					neigh, pdev, 0);
-		ep->mtu = pdev->mtu;
-		ep->tx_chan = cxgb4_port_chan(pdev);
-		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
-		step = ep->com.dev->rdev.lldi.ntxq /
-		       ep->com.dev->rdev.lldi.nchan;
-		ep->txq_idx = cxgb4_port_idx(pdev) * step;
-		step = ep->com.dev->rdev.lldi.nrxq /
-		       ep->com.dev->rdev.lldi.nchan;
-		ep->ctrlq_idx = cxgb4_port_idx(pdev);
-		ep->rss_qid = ep->com.dev->rdev.lldi.rxq_ids[
-			      cxgb4_port_idx(pdev) * step];
-		dev_put(pdev);
-	} else {
-		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-					neigh, neigh->dev, 0);
-		ep->mtu = dst_mtu(ep->dst);
-		ep->tx_chan = cxgb4_port_chan(neigh->dev);
-		ep->smac_idx = (cxgb4_port_viid(neigh->dev) & 0x7F) << 1;
-		step = ep->com.dev->rdev.lldi.ntxq /
-		       ep->com.dev->rdev.lldi.nchan;
-		ep->txq_idx = cxgb4_port_idx(neigh->dev) * step;
-		ep->ctrlq_idx = cxgb4_port_idx(neigh->dev);
-		step = ep->com.dev->rdev.lldi.nrxq /
-		       ep->com.dev->rdev.lldi.nchan;
-		ep->rss_qid = ep->com.dev->rdev.lldi.rxq_ids[
-			      cxgb4_port_idx(neigh->dev) * step];
-		ep->retry_with_mpa_v1 = 0;
-		ep->tried_with_mpa_v1 = 0;
-	}
-	rcu_read_unlock();
-	if (!ep->l2t) {
+	err = import_ep(ep, cm_id->remote_addr.sin_addr.s_addr,
+			ep->dst, ep->com.dev, true);
+	if (err) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
-		err = -ENOMEM;
 		goto fail4;
 	}
 
-- 
1.7.7.3
