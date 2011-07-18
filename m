From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 34/45] bna: Add Multiple Tx Queue Support
Date: Mon, 18 Jul 2011 01:22:54 -0700
Message-ID: <1310977385-5268-24-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48261 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753918Ab1GRIYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:49 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Added support for multipe Tx queues with a separate iSCSI Tx queue based
   on the default value of iSCSI port number. The feature is supported based
   on the underlying hardware and enabled for DCB (CEE) mode only.
 - Allocate multiple TxQ resource in netdev
 - Implement bnad_tx_select_queue() which enables the correct selection of
   TxQ Id (and tcb). This function is called either by the kernel to channel
   packets to the right TxQ
 - Implement bnad_iscsi_tcb_get() and BNAD_IS_ISCSI_PKT() for iSCSI packet
   inspection and retrieval of tcb corresponding to the iSCSI priority.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bna_types.h |    2 +
 drivers/net/bna/bnad.c      |  146 ++++++++++++++++++++++++++++++++++---------
 drivers/net/bna/bnad.h      |    9 +++
 3 files changed, 127 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bna/bna_types.h b/drivers/net/bna/bna_types.h
index a4f71c0..7f037db 100644
--- a/drivers/net/bna/bna_types.h
+++ b/drivers/net/bna/bna_types.h
@@ -329,6 +329,7 @@ struct bna_attr {
 	int			num_ucmac;
 	int			num_mcmac;
 	int			max_rit_size;
+	int			max_ets_groups;
 };
 
 /**
@@ -578,6 +579,7 @@ struct bna_tx_mod {
 	int			iscsi_over_cee;
 	int			iscsi_prio;
 	int			prio_reconfigured;
+	void			*prio_indirection[BFI_TX_MAX_PRIO];
 
 	u32			rid_mask;
 
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 2b716ed..8ca1b60 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -194,8 +194,6 @@ bnad_free_txbufs(struct bnad *bnad,
 	while (wis) {
 		skb = unmap_array[unmap_cons].skb;
 
-		unmap_array[unmap_cons].skb = NULL;
-
 		sent_packets++;
 		sent_bytes += skb->len;
 		wis -= BNA_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags);
@@ -245,7 +243,7 @@ bnad_tx_free_tasklet(unsigned long bnad_ptr)
 {
 	struct bnad *bnad = (struct bnad *)bnad_ptr;
 	struct bna_tcb *tcb;
-	u32		acked = 0;
+	u32		acked = 0, txq_id;
 	int			i, j;
 
 	for (i = 0; i < bnad->num_tx; i++) {
@@ -264,14 +262,20 @@ bnad_tx_free_tasklet(unsigned long bnad_ptr)
 				smp_mb__before_clear_bit();
 				clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
 			}
+			/*
+			 * Check again, because this bit can be set from another
+			 * context. This is not lock protected.
+			 */
 			if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED,
 						&tcb->flags)))
 				continue;
-			if (netif_queue_stopped(bnad->netdev)) {
+			txq_id = tcb->id;
+			if (__netif_subqueue_stopped(bnad->netdev, txq_id)) {
 				if (acked && netif_carrier_ok(bnad->netdev) &&
 					BNA_QE_FREE_CNT(tcb, tcb->q_depth) >=
 						BNAD_NETIF_WAKE_THRESHOLD) {
-					netif_wake_queue(bnad->netdev);
+					netif_wake_subqueue(bnad->netdev,
+									txq_id);
 					/* TODO */
 					/* Counters for individual TxQs? */
 					BNAD_UPDATE_CTR(bnad,
@@ -286,19 +290,21 @@ static u32
 bnad_tx(struct bnad *bnad, struct bna_tcb *tcb)
 {
 	struct net_device *netdev = bnad->netdev;
-	u32 sent = 0;
+	u32 sent = 0, txq_id;
 
 	if (test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags))
 		return 0;
 
 	sent = bnad_free_txbufs(bnad, tcb);
 	if (sent) {
-		if (netif_queue_stopped(netdev) &&
+		txq_id = tcb->id;
+
+		if (__netif_subqueue_stopped(netdev, txq_id) &&
 		    netif_carrier_ok(netdev) &&
 		    BNA_QE_FREE_CNT(tcb, tcb->q_depth) >=
 				    BNAD_NETIF_WAKE_THRESHOLD) {
 			if (test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags)) {
-				netif_wake_queue(netdev);
+				netif_wake_subqueue(netdev, txq_id);
 				BNAD_UPDATE_CTR(bnad, netif_queue_wakeup);
 			}
 		}
@@ -850,7 +856,9 @@ bnad_cb_tcb_setup(struct bnad *bnad, struct bna_tcb *tcb)
 			(struct bnad_tx_info *)tcb->txq->tx->priv;
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 
+	tcb->priv = tcb;
 	tx_info->tcb[tcb->id] = tcb;
+
 	unmap_q->producer_index = 0;
 	unmap_q->consumer_index = 0;
 	unmap_q->q_depth = BNAD_TX_UNMAPQ_DEPTH;
@@ -875,6 +883,7 @@ bnad_cb_tcb_destroy(struct bnad *bnad, struct bna_tcb *tcb)
 	clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
 
 	tx_info->tcb[tcb->id] = NULL;
+	tcb->priv = NULL;
 }
 
 static void
@@ -1777,6 +1786,29 @@ bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 	bnad_tx_res_free(bnad, res_info);
 }
 
+/*
+ * Sets up bnad->num_tx depending on the current value (already
+ * adjusted based on MSIX vectors available and ETS support in
+ * the chip
+ */
+static void
+bnad_num_txq_set(struct bnad *bnad)
+{
+	struct bna *bna	= &bnad->bna;
+	struct bna_attr	attr;
+	unsigned long		flags;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	attr = bna->ioceth.attr;
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+
+	if (attr.max_ets_groups < BFI_TX_MAX_PRIO)
+		bnad->num_txq_per_tx = 1;
+	else
+		bnad->num_txq_per_tx = min((u32)attr.max_ets_groups,
+					(u32)bnad->num_txq_per_tx);
+}
+
 /* Should be held with conf_lock held */
 int
 bnad_setup_tx(struct bnad *bnad, u32 tx_id)
@@ -1793,6 +1825,8 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 
 	tx_info->tx_id = tx_id;
 
+	bnad_num_txq_set(bnad);
+
 	/* Initialize the Tx object configuration */
 	tx_config->num_txq = bnad->num_txq_per_tx;
 	tx_config->txq_depth = bnad->txq_depth;
@@ -2264,38 +2298,45 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 static void
 bnad_q_num_init(struct bnad *bnad)
 {
-	int rxps;
+	int rxps = min((u32)num_online_cpus(),
+			(u32)(BNAD_MAX_RXP_PER_RX));
 
-	rxps = min((uint)num_online_cpus(),
-			(uint)(BNAD_MAX_RX * BNAD_MAX_RXP_PER_RX));
+	BNA_TO_POWER_OF_2(rxps);
 
 	if (!(bnad->cfg_flags & BNAD_CF_MSIX))
 		rxps = 1;	/* INTx */
 
-	bnad->num_rx = 1;
-	bnad->num_tx = 1;
+	bnad->num_rx = BNAD_MAX_RX;
+	bnad->num_tx = BNAD_MAX_TX;
 	bnad->num_rxp_per_rx = rxps;
 	bnad->num_txq_per_tx = BNAD_MAX_TXQ_PER_TX;
 }
 
 /*
- * Adjusts the Q numbers, given a number of msix vectors
+ * Adjusts the Q numbers, given a number of max possible queues.
  * Give preference to RSS as opposed to Tx priority Queues,
  * in such a case, just use 1 Tx Q
  * Called with bnad->bna_lock held b'cos of cfg_flags access
  */
 static void
-bnad_q_num_adjust(struct bnad *bnad, int msix_vectors, int temp)
+bnad_q_num_adjust(struct bnad *bnad, int max_txq, int max_rxq)
 {
-	bnad->num_txq_per_tx = 1;
-	if ((msix_vectors >= (bnad->num_tx * bnad->num_txq_per_tx)  +
-	     bnad_rxqs_per_cq + BNAD_MAILBOX_MSIX_VECTORS) &&
-	    (bnad->cfg_flags & BNAD_CF_MSIX)) {
-		bnad->num_rxp_per_rx = msix_vectors -
-			(bnad->num_tx * bnad->num_txq_per_tx) -
-			BNAD_MAILBOX_MSIX_VECTORS;
-	} else
-		bnad->num_rxp_per_rx = 1;
+	if (!(bnad->cfg_flags & BNAD_CF_MSIX)) {
+		bnad->num_tx = bnad->num_txq_per_tx = 1;
+		bnad->num_rx = bnad->num_rxp_per_rx = 1;
+		return;
+	}
+
+	if (max_txq < BNAD_NUM_TXQ) {
+		bnad->num_txq_per_tx = 1;
+		bnad->num_tx = 1;
+	}
+
+	bnad->num_rx = 1;
+	bnad->num_rxp_per_rx = min((u32)(min((u32)num_online_cpus(),
+					(u32)(BNAD_MAX_RXP_PER_RX))),
+					(u32)max_rxq);
+	BNA_TO_POWER_OF_2(bnad->num_rxp_per_rx);
 }
 
 /* Enable / disable ioceth */
@@ -2359,7 +2400,7 @@ bnad_res_alloc(struct bnad *bnad, struct bna_res_info *res_info,
 {
 	int i, err;
 
-	for (i = 0; i < BNA_RES_T_MAX; i++) {
+	for (i = 0; i < res_val_max; i++) {
 		if (res_info[i].res_type == BNA_RES_T_MEM)
 			err = bnad_mem_alloc(bnad, &res_info[i].res_u.mem_info);
 		else
@@ -2433,7 +2474,6 @@ bnad_enable_msix(struct bnad *bnad)
 	return;
 
 intx_mode:
-
 	kfree(bnad->msix_table);
 	bnad->msix_table = NULL;
 	bnad->msix_num = 0;
@@ -2608,7 +2648,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 			smp_mb__before_clear_bit();
 			clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
 		} else {
-			netif_stop_queue(netdev);
+			netif_stop_subqueue(netdev, txq_id);
 			BNAD_UPDATE_CTR(bnad, netif_queue_stop);
 		}
 
@@ -2624,7 +2664,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 			BNAD_UPDATE_CTR(bnad, netif_queue_stop);
 			return NETDEV_TX_BUSY;
 		} else {
-			netif_wake_queue(netdev);
+			netif_wake_subqueue(netdev, txq_id);
 			BNAD_UPDATE_CTR(bnad, netif_queue_wakeup);
 		}
 	}
@@ -2649,7 +2689,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 	if (test_bit(BNAD_RF_CEE_RUNNING, &bnad->run_flags)) {
 		vlan_tag =
-			(tcb->priority & 0x7) << 13 | (vlan_tag & 0x1fff);
+			((tcb->priority & 0x7) << VLAN_PRIO_SHIFT)
+							| (vlan_tag & 0x1fff);
 		flags |= (BNA_TXQ_WI_CF_INS_PRIO | BNA_TXQ_WI_CF_INS_VLAN);
 	}
 
@@ -2796,6 +2837,50 @@ bnad_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 	return stats;
 }
 
+static bool bnad_is_iscsi(struct sk_buff *skb)
+{
+	u16		proto = 0;
+	struct tcphdr		*th;
+
+	if (skb->protocol == htons(ETH_P_IP))
+		proto = ip_hdr(skb)->protocol;
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		/* nexthdr may not be TCP immediately. */
+		proto = ipv6_hdr(skb)->nexthdr;
+	if (proto == IPPROTO_TCP) {
+		th = tcp_hdr(skb);
+		if (BNAD_IS_ISCSI_PKT(th))
+			return true;
+	}
+
+	return false;
+}
+
+static u16
+bnad_tx_select_queue(struct net_device *netdev, struct sk_buff *skb)
+{
+	struct bnad *bnad =  netdev_priv(netdev);
+	struct bna *bna = &bnad->bna;
+	u8	prio = 0;
+
+	if (bnad->num_txq_per_tx < BFI_TX_MAX_PRIO)
+		prio = 0;
+	else if (bna_is_iscsi_over_cee(&bnad->bna) && bnad_is_iscsi(skb))
+		prio = bna_iscsi_prio(bna);
+	else if (vlan_tx_tag_present(skb)) {
+		u8 pkt_vlan_prio = 0;
+		u16 pkt_vlan_tag = 0;
+		pkt_vlan_tag = (u16)vlan_tx_tag_get(skb);
+		pkt_vlan_prio = (pkt_vlan_tag & VLAN_PRIO_MASK)
+					>> VLAN_PRIO_SHIFT;
+		prio = bna_prio_allowed(bna, pkt_vlan_prio) ?
+			pkt_vlan_prio : bna_default_prio(bna);
+	} else
+		prio = bna_default_prio(bna);
+
+	return (u16)prio;
+}
+
 static void
 bnad_set_rx_mode(struct net_device *netdev)
 {
@@ -3011,6 +3096,7 @@ bnad_netpoll(struct net_device *netdev)
 static const struct net_device_ops bnad_netdev_ops = {
 	.ndo_open		= bnad_open,
 	.ndo_stop		= bnad_stop,
+	.ndo_select_queue	= bnad_tx_select_queue,
 	.ndo_start_xmit		= bnad_start_xmit,
 	.ndo_get_stats64		= bnad_get_stats64,
 	.ndo_set_rx_mode	= bnad_set_rx_mode,
@@ -3208,7 +3294,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 * Allocates sizeof(struct net_device + struct bnad)
 	 * bnad = netdev->priv
 	 */
-	netdev = alloc_etherdev(sizeof(struct bnad));
+	netdev = alloc_etherdev_mq(sizeof(struct bnad), BNAD_MAX_TXQ);
 	if (!netdev) {
 		dev_err(&pdev->dev, "netdev allocation failed\n");
 		err = -ENOMEM;
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index c25e6e2..1b87b27 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -231,6 +231,15 @@ struct bnad_unmap_q {
 /* Defined as bit positions */
 #define BNAD_FP_IN_RX_PATH	      0
 
+/*
+ * Deep Inspection : Checks if packet is ISCSI based on
+ * standard iSCSI port
+ */
+#define BNAD_TCP_ISCSI_PORT 3260
+#define BNAD_IS_ISCSI_PKT(_tch)				\
+(((_tch)->source == ntohs(BNAD_TCP_ISCSI_PORT)) ||	\
+	((_tch)->dest == ntohs(BNAD_TCP_ISCSI_PORT)))
+
 struct bnad {
 	struct net_device	*netdev;
 
-- 
1.7.1

