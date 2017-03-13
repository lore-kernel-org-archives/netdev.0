From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 02/25] IB/ipoib: separate control from HW operation on ipoib_open/stop ndo
Date: Mon, 13 Mar 2017 20:31:13 +0200
Message-ID: <1489429896-10781-3-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49626 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752387AbdCMSb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:31:56 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch is preparing the netdev part at the ipoib driver to be able
to use the ipoib_options.
It deals with the two flows from the .ndo: ipoib_open and ipoib_stop.
It arranges that area of code as follows:
All operations which deal with the HW resources, (for example change QP
state, post-receive etc.) are done in one place.
All operations that are control oriented (like restart multicast task,
start the reap_ah etc.) are done in separate place.

The functions that deals with the HW resources now located at
__ipoib_ib_dev_open for the ipoib_open flow and __ipoib_ib_dev_stop for
ipoib_stop.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h      |   2 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c   | 228 +++++++++++++++++-------------
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   2 +-
 3 files changed, 129 insertions(+), 103 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 7cd9befd7d54..b3900b253ad5 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -501,7 +501,7 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 int ipoib_ib_dev_open(struct net_device *dev);
 void ipoib_ib_dev_up(struct net_device *dev);
 void ipoib_ib_dev_down(struct net_device *dev);
-void ipoib_ib_dev_stop(struct net_device *dev);
+int ipoib_ib_dev_stop_default(struct net_device *dev);
 void ipoib_pkey_dev_check_presence(struct net_device *dev);
 
 int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 3c0a35d883e2..5d732c5f01ee 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -693,24 +693,113 @@ static void ipoib_stop_ah(struct net_device *dev)
 	ipoib_flush_ah(dev);
 }
 
-void ipoib_ib_tx_timer_func(unsigned long ctx)
+static int recvs_pending(struct net_device *dev)
 {
-	drain_tx_cq((struct net_device *)ctx);
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	int pending = 0;
+	int i;
+
+	for (i = 0; i < ipoib_recvq_size; ++i)
+		if (priv->rx_ring[i].skb)
+			++pending;
+
+	return pending;
 }
 
-int ipoib_ib_dev_open(struct net_device *dev)
+int ipoib_ib_dev_stop_default(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
-	int ret;
+	struct ib_qp_attr qp_attr;
+	unsigned long begin;
+	struct ipoib_tx_buf *tx_req;
+	int i;
 
-	ipoib_pkey_dev_check_presence(dev);
+	if (test_and_clear_bit(IPOIB_FLAG_INITIALIZED, &priv->flags))
+		napi_disable(&priv->napi);
 
-	if (!test_bit(IPOIB_PKEY_ASSIGNED, &priv->flags)) {
-		ipoib_warn(priv, "P_Key 0x%04x is %s\n", priv->pkey,
-			   (!(priv->pkey & 0x7fff) ? "Invalid" : "not found"));
-		return -1;
+	ipoib_cm_dev_stop(dev);
+
+	/*
+	 * Move our QP to the error state and then reinitialize in
+	 * when all work requests have completed or have been flushed.
+	 */
+	qp_attr.qp_state = IB_QPS_ERR;
+	if (ib_modify_qp(priv->qp, &qp_attr, IB_QP_STATE))
+		ipoib_warn(priv, "Failed to modify QP to ERROR state\n");
+
+	/* Wait for all sends and receives to complete */
+	begin = jiffies;
+
+	while (priv->tx_head != priv->tx_tail || recvs_pending(dev)) {
+		if (time_after(jiffies, begin + 5 * HZ)) {
+			ipoib_warn(priv, "timing out; %d sends %d receives not completed\n",
+				   priv->tx_head - priv->tx_tail, recvs_pending(dev));
+
+			/*
+			 * assume the HW is wedged and just free up
+			 * all our pending work requests.
+			 */
+			while ((int) priv->tx_tail - (int) priv->tx_head < 0) {
+				tx_req = &priv->tx_ring[priv->tx_tail &
+							(ipoib_sendq_size - 1)];
+				ipoib_dma_unmap_tx(priv, tx_req);
+				dev_kfree_skb_any(tx_req->skb);
+				++priv->tx_tail;
+				--priv->tx_outstanding;
+			}
+
+			for (i = 0; i < ipoib_recvq_size; ++i) {
+				struct ipoib_rx_buf *rx_req;
+
+				rx_req = &priv->rx_ring[i];
+				if (!rx_req->skb)
+					continue;
+				ipoib_ud_dma_unmap_rx(priv,
+						      priv->rx_ring[i].mapping);
+				dev_kfree_skb_any(rx_req->skb);
+				rx_req->skb = NULL;
+			}
+
+			goto timeout;
+		}
+
+		ipoib_drain_cq(dev);
+
+		msleep(1);
 	}
 
+	ipoib_dbg(priv, "All sends and receives done.\n");
+
+timeout:
+	del_timer_sync(&priv->poll_timer);
+	qp_attr.qp_state = IB_QPS_RESET;
+	if (ib_modify_qp(priv->qp, &qp_attr, IB_QP_STATE))
+		ipoib_warn(priv, "Failed to modify QP to RESET state\n");
+
+	ib_req_notify_cq(priv->recv_cq, IB_CQ_NEXT_COMP);
+
+	return 0;
+}
+
+int ipoib_ib_dev_stop(struct net_device *dev)
+{
+	ipoib_ib_dev_stop_default(dev);
+
+	ipoib_flush_ah(dev);
+
+	return 0;
+}
+
+void ipoib_ib_tx_timer_func(unsigned long ctx)
+{
+	drain_tx_cq((struct net_device *)ctx);
+}
+
+int ipoib_ib_dev_open_default(struct net_device *dev)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	int ret;
+
 	ret = ipoib_init_qp(dev);
 	if (ret) {
 		ipoib_warn(priv, "ipoib_init_qp returned %d\n", ret);
@@ -729,10 +818,6 @@ int ipoib_ib_dev_open(struct net_device *dev)
 		goto dev_stop;
 	}
 
-	clear_bit(IPOIB_STOP_REAPER, &priv->flags);
-	queue_delayed_work(priv->wq, &priv->ah_reap_task,
-			   round_jiffies_relative(HZ));
-
 	if (!test_and_set_bit(IPOIB_FLAG_INITIALIZED, &priv->flags))
 		napi_enable(&priv->napi);
 
@@ -744,6 +829,35 @@ int ipoib_ib_dev_open(struct net_device *dev)
 	return -1;
 }
 
+int ipoib_ib_dev_open(struct net_device *dev)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+
+	ipoib_pkey_dev_check_presence(dev);
+
+	if (!test_bit(IPOIB_PKEY_ASSIGNED, &priv->flags)) {
+		ipoib_warn(priv, "P_Key 0x%04x is %s\n", priv->pkey,
+			   (!(priv->pkey & 0x7fff) ? "Invalid" : "not found"));
+		return -1;
+	}
+
+	clear_bit(IPOIB_STOP_REAPER, &priv->flags);
+	queue_delayed_work(priv->wq, &priv->ah_reap_task,
+			   round_jiffies_relative(HZ));
+
+	if (ipoib_ib_dev_open_default(dev)) {
+		pr_warn("%s: Failed to open dev\n", dev->name);
+		goto stop_ah_reap;
+	}
+
+	return 0;
+
+stop_ah_reap:
+	set_bit(IPOIB_STOP_REAPER, &priv->flags);
+	cancel_delayed_work(&priv->ah_reap_task);
+	return -1;
+}
+
 void ipoib_pkey_dev_check_presence(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -787,19 +901,6 @@ void ipoib_ib_dev_down(struct net_device *dev)
 	ipoib_flush_paths(dev);
 }
 
-static int recvs_pending(struct net_device *dev)
-{
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
-	int pending = 0;
-	int i;
-
-	for (i = 0; i < ipoib_recvq_size; ++i)
-		if (priv->rx_ring[i].skb)
-			++pending;
-
-	return pending;
-}
-
 void ipoib_drain_cq(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -839,81 +940,6 @@ void ipoib_drain_cq(struct net_device *dev)
 	local_bh_enable();
 }
 
-void ipoib_ib_dev_stop(struct net_device *dev)
-{
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
-	struct ib_qp_attr qp_attr;
-	unsigned long begin;
-	struct ipoib_tx_buf *tx_req;
-	int i;
-
-	if (test_and_clear_bit(IPOIB_FLAG_INITIALIZED, &priv->flags))
-		napi_disable(&priv->napi);
-
-	ipoib_cm_dev_stop(dev);
-
-	/*
-	 * Move our QP to the error state and then reinitialize in
-	 * when all work requests have completed or have been flushed.
-	 */
-	qp_attr.qp_state = IB_QPS_ERR;
-	if (ib_modify_qp(priv->qp, &qp_attr, IB_QP_STATE))
-		ipoib_warn(priv, "Failed to modify QP to ERROR state\n");
-
-	/* Wait for all sends and receives to complete */
-	begin = jiffies;
-
-	while (priv->tx_head != priv->tx_tail || recvs_pending(dev)) {
-		if (time_after(jiffies, begin + 5 * HZ)) {
-			ipoib_warn(priv, "timing out; %d sends %d receives not completed\n",
-				   priv->tx_head - priv->tx_tail, recvs_pending(dev));
-
-			/*
-			 * assume the HW is wedged and just free up
-			 * all our pending work requests.
-			 */
-			while ((int) priv->tx_tail - (int) priv->tx_head < 0) {
-				tx_req = &priv->tx_ring[priv->tx_tail &
-							(ipoib_sendq_size - 1)];
-				ipoib_dma_unmap_tx(priv, tx_req);
-				dev_kfree_skb_any(tx_req->skb);
-				++priv->tx_tail;
-				--priv->tx_outstanding;
-			}
-
-			for (i = 0; i < ipoib_recvq_size; ++i) {
-				struct ipoib_rx_buf *rx_req;
-
-				rx_req = &priv->rx_ring[i];
-				if (!rx_req->skb)
-					continue;
-				ipoib_ud_dma_unmap_rx(priv,
-						      priv->rx_ring[i].mapping);
-				dev_kfree_skb_any(rx_req->skb);
-				rx_req->skb = NULL;
-			}
-
-			goto timeout;
-		}
-
-		ipoib_drain_cq(dev);
-
-		msleep(1);
-	}
-
-	ipoib_dbg(priv, "All sends and receives done.\n");
-
-timeout:
-	del_timer_sync(&priv->poll_timer);
-	qp_attr.qp_state = IB_QPS_RESET;
-	if (ib_modify_qp(priv->qp, &qp_attr, IB_QP_STATE))
-		ipoib_warn(priv, "Failed to modify QP to RESET state\n");
-
-	ipoib_flush_ah(dev);
-
-	ib_req_notify_cq(priv->recv_cq, IB_CQ_NEXT_COMP);
-}
-
 /*
  * Takes whatever value which is in pkey index 0 and updates priv->pkey
  * returns 0 if the pkey value was changed.
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 8c644bbc2828..be8dcea252f9 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -166,7 +166,7 @@ static int ipoib_stop(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	ipoib_ib_dev_down(dev);
-	ipoib_ib_dev_stop(dev);
+	ipoib_ib_dev_stop_default(dev);
 
 	if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags)) {
 		struct ipoib_dev_priv *cpriv;
-- 
1.8.3.1
