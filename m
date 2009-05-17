From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH] be2net: remove napi from tx path
Date: Sun, 17 May 2009 15:37:41 +0530
Message-ID: <20090517100739.GA19730@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:22592 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750804AbZEQKHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 06:07:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
- this patch removes napi in the tx path.
- provides a switch to enable or disable lro.
Please apply the patch to net-2.6

Thanks
Ajit

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
----
diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index b4bb06f..6d149a4 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -159,8 +159,6 @@ struct be_eq_obj {
 	u16 min_eqd;		/* in usecs */
 	u16 max_eqd;		/* in usecs */
 	u16 cur_eqd;		/* in usecs */
-
-	struct napi_struct napi;
 };
 
 struct be_tx_obj {
@@ -179,6 +177,7 @@ struct be_rx_page_info {
 };
 
 struct be_rx_obj {
+	struct napi_struct napi;
 	struct be_queue_info q;
 	struct be_queue_info cq;
 	struct be_rx_page_info page_info_tbl[RX_Q_LEN];
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index cf75905..591a0fa 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -26,7 +26,12 @@ MODULE_LICENSE("GPL");
 
 static unsigned int rx_frag_size = 2048;
 module_param(rx_frag_size, uint, S_IRUGO);
-MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
+MODULE_PARM_DESC(rx_frag_size,
+	"Size of receive fragment buffer - 2048 (default), 4096 or 8192");
+
+static unsigned int lro = 1;
+module_param(lro, uint, S_IRUGO);
+MODULE_PARM_DESC(lro, "Configure LRO. 1=enable (default) or 0=disable");
 
 static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
@@ -977,7 +982,7 @@ static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 
 	atomic_sub(num_wrbs, &txq->used);
 
-	kfree_skb(sent_skb);
+	dev_kfree_skb_any(sent_skb);
 }
 
 static void be_rx_q_clean(struct be_adapter *adapter)
@@ -1121,7 +1126,10 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 	struct be_queue_info *eq, *q, *cq;
 	int rc;
 
-	adapter->max_rx_coal = BE_MAX_FRAGS_PER_FRAME;
+	if (lro)
+		adapter->max_rx_coal = BE_MAX_FRAGS_PER_FRAME;
+	else
+		adapter->max_rx_coal = 0;
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
 	adapter->rx_eq.max_eqd = BE_MAX_EQD;
 	adapter->rx_eq.min_eqd = 0;
@@ -1202,20 +1210,66 @@ static int event_handle(struct be_ctrl_info *ctrl,
 
 	/* We can see an interrupt and no event */
 	be_eq_notify(ctrl, eq_obj->q.id, true, true, num);
-	if (num)
-		napi_schedule(&eq_obj->napi);
 
 	return num;
 }
 
+static int rx_event_handle(struct be_adapter *adapter)
+{
+	int evts;
+
+	evts = event_handle(&adapter->ctrl, &adapter->rx_eq);
+	if (evts)
+		napi_schedule(&adapter->rx_obj.napi);
+
+	return evts;
+}
+
+static int tx_event_handle(struct be_adapter *adapter)
+{
+	struct be_tx_obj *tx_obj = &adapter->tx_obj;
+	struct be_queue_info *tx_cq = &tx_obj->cq;
+	struct be_queue_info *txq = &tx_obj->q;
+	struct be_eth_tx_compl *txcp;
+	u32 num_cmpl = 0;
+	u16 end_idx;
+	int evts;
+
+	evts = event_handle(&adapter->ctrl, &adapter->tx_eq);
+	if (!evts)
+		goto done;
+
+	while ((txcp = be_tx_compl_get(adapter))) {
+		end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
+					wrb_index, txcp);
+		be_tx_compl_process(adapter, end_idx);
+		num_cmpl++;
+	}
+
+	/* As Tx wrbs have been freed up, wake up netdev queue if
+	 * it was stopped due to lack of tx wrbs.
+	 */
+	if (netif_queue_stopped(adapter->netdev) &&
+			atomic_read(&txq->used) < txq->len / 2) {
+		netif_wake_queue(adapter->netdev);
+	}
+
+	be_cq_notify(&adapter->ctrl, tx_cq->id, true, num_cmpl);
+
+	drvr_stats(adapter)->be_tx_events++;
+	drvr_stats(adapter)->be_tx_compl += num_cmpl;
+
+done:
+	return evts;
+}
+
 static irqreturn_t be_intx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
-	struct be_ctrl_info *ctrl = &adapter->ctrl;
 	int rx, tx;
 
-	tx = event_handle(ctrl, &adapter->tx_eq);
-	rx = event_handle(ctrl, &adapter->rx_eq);
+	rx = rx_event_handle(adapter);
+	tx = tx_event_handle(adapter);
 
 	if (rx || tx)
 		return IRQ_HANDLED;
@@ -1227,7 +1281,7 @@ static irqreturn_t be_msix_rx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
 
-	event_handle(&adapter->ctrl, &adapter->rx_eq);
+	rx_event_handle(adapter);
 
 	return IRQ_HANDLED;
 }
@@ -1236,7 +1290,7 @@ static irqreturn_t be_msix_tx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
 
-	event_handle(&adapter->ctrl, &adapter->tx_eq);
+	tx_event_handle(adapter);
 
 	return IRQ_HANDLED;
 }
@@ -1256,9 +1310,9 @@ static inline bool do_lro(struct be_adapter *adapter,
 
 int be_poll_rx(struct napi_struct *napi, int budget)
 {
-	struct be_eq_obj *rx_eq = container_of(napi, struct be_eq_obj, napi);
+	struct be_rx_obj *rx_obj = container_of(napi, struct be_rx_obj, napi);
 	struct be_adapter *adapter =
-		container_of(rx_eq, struct be_adapter, rx_eq);
+		container_of(rx_obj, struct be_adapter, rx_obj);
 	struct be_queue_info *rx_cq = &adapter->rx_obj.cq;
 	struct be_eth_rx_compl *rxcp;
 	u32 work_done;
@@ -1274,7 +1328,8 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 			be_rx_compl_process(adapter, rxcp);
 	}
 
-	lro_flush_all(&adapter->rx_obj.lro_mgr);
+	if (lro)
+		lro_flush_all(&adapter->rx_obj.lro_mgr);
 
 	/* Refill the queue */
 	if (atomic_read(&adapter->rx_obj.q.used) < RX_FRAGS_REFILL_WM)
@@ -1291,44 +1346,6 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-/* For TX we don't honour budget; consume everything */
-int be_poll_tx(struct napi_struct *napi, int budget)
-{
-	struct be_eq_obj *tx_eq = container_of(napi, struct be_eq_obj, napi);
-	struct be_adapter *adapter =
-		container_of(tx_eq, struct be_adapter, tx_eq);
-	struct be_tx_obj *tx_obj = &adapter->tx_obj;
-	struct be_queue_info *tx_cq = &tx_obj->cq;
-	struct be_queue_info *txq = &tx_obj->q;
-	struct be_eth_tx_compl *txcp;
-	u32 num_cmpl = 0;
-	u16 end_idx;
-
-	while ((txcp = be_tx_compl_get(adapter))) {
-		end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
-					wrb_index, txcp);
-		be_tx_compl_process(adapter, end_idx);
-		num_cmpl++;
-	}
-
-	/* As Tx wrbs have been freed up, wake up netdev queue if
-	 * it was stopped due to lack of tx wrbs.
-	 */
-	if (netif_queue_stopped(adapter->netdev) &&
-			atomic_read(&txq->used) < txq->len / 2) {
-		netif_wake_queue(adapter->netdev);
-	}
-
-	napi_complete(napi);
-
-	be_cq_notify(&adapter->ctrl, tx_cq->id, true, num_cmpl);
-
-	drvr_stats(adapter)->be_tx_events++;
-	drvr_stats(adapter)->be_tx_compl += num_cmpl;
-
-	return 1;
-}
-
 static void be_worker(struct work_struct *work)
 {
 	struct be_adapter *adapter =
@@ -1491,8 +1508,7 @@ static int be_open(struct net_device *netdev)
 	/* First time posting */
 	be_post_rx_frags(adapter);
 
-	napi_enable(&rx_eq->napi);
-	napi_enable(&tx_eq->napi);
+	napi_enable(&adapter->rx_obj.napi);
 
 	be_irq_register(adapter);
 
@@ -1545,8 +1561,7 @@ static int be_close(struct net_device *netdev)
 	}
 	be_irq_unregister(adapter);
 
-	napi_disable(&rx_eq->napi);
-	napi_disable(&tx_eq->napi);
+	napi_disable(&adapter->rx_obj.napi);
 
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
@@ -1634,11 +1649,10 @@ static void be_netdev_init(struct net_device *netdev)
 
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
 
-	be_lro_init(adapter, netdev);
+	if (lro)
+		be_lro_init(adapter, netdev);
 
-	netif_napi_add(netdev, &adapter->rx_eq.napi, be_poll_rx,
-		BE_NAPI_WEIGHT);
-	netif_napi_add(netdev, &adapter->tx_eq.napi, be_poll_tx,
+	netif_napi_add(netdev, &adapter->rx_obj.napi, be_poll_rx,
 		BE_NAPI_WEIGHT);
 
 	netif_carrier_off(netdev);
