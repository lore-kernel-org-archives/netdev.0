From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.29] cxgb3 - Add multiple Tx queue support.
Date: Fri, 12 Dec 2008 17:47:44 -0800
Message-ID: <20081213014744.25650.62772.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:16500 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbYLMBr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 20:47:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Implement NIC Tx multiqueue.
Bump up driver version.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |    4 +++-
 drivers/net/cxgb3/cxgb3_main.c |   11 +++++++----
 drivers/net/cxgb3/sge.c        |   30 ++++++++++++++++++++----------
 drivers/net/cxgb3/version.h    |    2 +-
 4 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index bc8e241..c190a69 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -196,6 +196,7 @@ struct sge_qset {		/* an SGE queue set */
 	int lro_frag_len;
 	void *lro_va;
 	struct net_device *netdev;
+	struct netdev_queue *tx_q;	/* associated netdev TX queue */
 	unsigned long txq_stopped;	/* which Tx queues are stopped */
 	struct timer_list tx_reclaim_timer;	/* reclaims TX buffers */
 	unsigned long port_stats[SGE_PSTAT_MAX];
@@ -294,7 +295,8 @@ int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p);
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
-		      int ntxq, struct net_device *dev);
+		      int ntxq, struct net_device *dev,
+		      struct netdev_queue *netdevq);
 int t3_get_desc(const struct sge_qset *qs, unsigned int qnum, unsigned int idx,
 		unsigned char *data);
 irqreturn_t t3_sge_intr_msix(int irq, void *cookie);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 46c114e..9e8727c 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -550,7 +550,8 @@ static int setup_sge_qsets(struct adapter *adap)
 			err = t3_sge_alloc_qset(adap, qset_idx, 1,
 				(adap->flags & USING_MSIX) ? qset_idx + 1 :
 							     irq_idx,
-				&adap->params.sge.qset[qset_idx], ntxq, dev);
+				&adap->params.sge.qset[qset_idx], ntxq, dev,
+				netdev_get_tx_queue(dev, j));
 			if (err) {
 				t3_stop_sge_timers(adap);
 				t3_free_sge_resources(adap);
@@ -1165,9 +1166,10 @@ static int cxgb_open(struct net_device *dev)
 			       "Could not initialize offload capabilities\n");
 	}
 
+	dev->real_num_tx_queues = pi->nqsets;
 	link_start(dev);
 	t3_port_intr_enable(adapter, pi->port_id);
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 	if (!other_ports)
 		schedule_chk_task(adapter);
 
@@ -1180,7 +1182,7 @@ static int cxgb_close(struct net_device *dev)
 	struct adapter *adapter = pi->adapter;
 
 	t3_port_intr_disable(adapter, pi->port_id);
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 	pi->phy.ops->power_down(&pi->phy, 1);
 	netif_carrier_off(dev);
 	t3_mac_disable(&pi->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
@@ -2932,7 +2934,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	for (i = 0; i < ai->nports; ++i) {
 		struct net_device *netdev;
 
-		netdev = alloc_etherdev(sizeof(struct port_info));
+		netdev = alloc_etherdev_mq(sizeof(struct port_info), SGE_QSETS);
 		if (!netdev) {
 			err = -ENOMEM;
 			goto out_free_dev;
@@ -2946,6 +2948,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		pi->rx_csum_offload = 1;
 		pi->port_id = i;
 		netif_carrier_off(netdev);
+		netif_tx_stop_all_queues(netdev);
 		netdev->irq = pdev->irq;
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index d3a6e24..63eb974 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1120,10 +1120,10 @@ static void write_tx_pkt_wr(struct adapter *adap, struct sk_buff *skb,
 			 htonl(V_WR_TID(q->token)));
 }
 
-static inline void t3_stop_queue(struct net_device *dev, struct sge_qset *qs,
-				 struct sge_txq *q)
+static inline void t3_stop_tx_queue(struct netdev_queue *txq,
+				    struct sge_qset *qs, struct sge_txq *q)
 {
-	netif_stop_queue(dev);
+	netif_tx_stop_queue(txq);
 	set_bit(TXQ_ETH, &qs->txq_stopped);
 	q->stops++;
 }
@@ -1137,11 +1137,13 @@ static inline void t3_stop_queue(struct net_device *dev, struct sge_qset *qs,
  */
 int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	int qidx;
 	unsigned int ndesc, pidx, credits, gen, compl;
 	const struct port_info *pi = netdev_priv(dev);
 	struct adapter *adap = pi->adapter;
-	struct sge_qset *qs = pi->qs;
-	struct sge_txq *q = &qs->txq[TXQ_ETH];
+	struct netdev_queue *txq;
+	struct sge_qset *qs;
+	struct sge_txq *q;
 
 	/*
 	 * The chip min packet length is 9 octets but play safe and reject
@@ -1152,6 +1154,11 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
+	qidx = skb_get_queue_mapping(skb);
+	qs = &pi->qs[qidx];
+	q = &qs->txq[TXQ_ETH];
+	txq = netdev_get_tx_queue(dev, qidx);
+
 	spin_lock(&q->lock);
 	reclaim_completed_tx(adap, q);
 
@@ -1159,7 +1166,7 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	ndesc = calc_tx_descs(skb);
 
 	if (unlikely(credits < ndesc)) {
-		t3_stop_queue(dev, qs, q);
+		t3_stop_tx_queue(txq, qs, q);
 		dev_err(&adap->pdev->dev,
 			"%s: Tx ring %u full while queue awake!\n",
 			dev->name, q->cntxt_id & 7);
@@ -1169,12 +1176,12 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	q->in_use += ndesc;
 	if (unlikely(credits - ndesc < q->stop_thres)) {
-		t3_stop_queue(dev, qs, q);
+		t3_stop_tx_queue(txq, qs, q);
 
 		if (should_restart_tx(q) &&
 		    test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
 			q->restarts++;
-			netif_wake_queue(dev);
+			netif_tx_wake_queue(txq);
 		}
 	}
 
@@ -1838,7 +1845,7 @@ static void restart_tx(struct sge_qset *qs)
 	    test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
 		qs->txq[TXQ_ETH].restarts++;
 		if (netif_running(qs->netdev))
-			netif_wake_queue(qs->netdev);
+			netif_tx_wake_queue(qs->tx_q);
 	}
 
 	if (test_bit(TXQ_OFLD, &qs->txq_stopped) &&
@@ -2824,6 +2831,7 @@ void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
  *	@p: configuration parameters for this queue set
  *	@ntxq: number of Tx queues for the queue set
  *	@netdev: net device associated with this queue set
+ *	@netdevq: net device TX queue associated with this queue set
  *
  *	Allocate resources and initialize an SGE queue set.  A queue set
  *	comprises a response queue, two Rx free-buffer queues, and up to 3
@@ -2832,7 +2840,8 @@ void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
  */
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
-		      int ntxq, struct net_device *dev)
+		      int ntxq, struct net_device *dev,
+		      struct netdev_queue *netdevq)
 {
 	int i, avail, ret = -ENOMEM;
 	struct sge_qset *q = &adapter->sge.qs[id];
@@ -2968,6 +2977,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 
 	q->adap = adapter;
 	q->netdev = dev;
+	q->tx_q = netdevq;
 	t3_update_qset_coalesce(q, p);
 
 	init_lro_mgr(q, lro_mgr);
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index bb8698a..b1b25c3 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -35,7 +35,7 @@
 #define DRV_DESC "Chelsio T3 Network Driver"
 #define DRV_NAME "cxgb3"
 /* Driver version */
-#define DRV_VERSION "1.1.0-ko"
+#define DRV_VERSION "1.1.1-ko"
 
 /* Firmware version */
 #define FW_VERSION_MAJOR 7

