From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 04/14] bna: Add Multiple Tx Queue Support
Date: Tue, 16 Aug 2011 14:19:41 -0700
Message-ID: <1313529591-3718-5-git-send-email-rmody@brocade.com>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:47899 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752789Ab1HPVUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 17:20:23 -0400
In-Reply-To: <1313529591-3718-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Add macros bna_prio_allow, bna_default_nw_prio, bna_iscsi_prio,
   bna_is_iscsi_over_cee
 - Added support for multipe Tx queues with a separate iSCSI Tx queue based
   on the default value of iSCSI port number. The feature is supported based
   on the underlying hardware and enabled for DCB (CEE) mode only.
 - Allocate multiple TxQ resource in netdev
 - Implement bnad_tx_select_queue() which enables the correct selection of
   TxQ Id (and tcb). This function is called either by the kernel to channel
   packets to the right TxQ
 - bnad_tx_select_queue() returns priority, while only a few packets during
   transition could have wrong priority, all will be associated with a valid
   non-NULL tcb.
 - Implement bnad_iscsi_tcb_get() and BNAD_IS_ISCSI_PKT() for iSCSI packet
   inspection and retrieval of tcb corresponding to the iSCSI priority.
 - Construction of priority indirection table to be used by bnad to direct
   packets into TxQs

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bna.h  |    8 ++
 drivers/net/ethernet/brocade/bna/bnad.c |  131 ++++++++++++++++++++++++-------
 drivers/net/ethernet/brocade/bna/bnad.h |   13 +++-
 3 files changed, 121 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 2a587c5..e4f914c 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -351,6 +351,14 @@ do {									\
 	}								\
 } while (0)
 
+#define bna_prio_allowed(_bna, _prio) ((_bna)->tx_mod.prio_map & (1 << _prio))
+
+#define bna_iscsi_prio(_bna) ((_bna)->tx_mod.iscsi_prio)
+
+#define bna_default_prio(_bna) ((_bna)->tx_mod.default_prio)
+
+#define bna_is_iscsi_over_cee(_bna) ((_bna)->tx_mod.iscsi_over_cee)
+
 /**
  *
  *  Inline functions
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 327b274..895f18b 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -246,7 +246,7 @@ bnad_tx_free_tasklet(unsigned long bnad_ptr)
 {
 	struct bnad *bnad = (struct bnad *)bnad_ptr;
 	struct bna_tcb *tcb;
-	u32		acked = 0;
+	u32		acked = 0, txq_id;
 	int			i, j;
 
 	for (i = 0; i < bnad->num_tx; i++) {
@@ -265,14 +265,20 @@ bnad_tx_free_tasklet(unsigned long bnad_ptr)
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
@@ -287,19 +293,21 @@ static u32
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
@@ -2247,38 +2255,45 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
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
-	bnad->num_txq_per_tx = BNAD_TXQ_NUM;
+	bnad->num_txq_per_tx = BNAD_MAX_TXQ_PER_TX;
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
@@ -2537,15 +2552,15 @@ static netdev_tx_t
 bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
-	u32 txq_id = 0;
-	struct bna_tcb *tcb = bnad->tx_info[0].tcb[txq_id];
+	struct bna_tcb *tcb = NULL;
+	u32 txq_id;
+	struct bnad_unmap_q *unmap_q;
 
 	u16		txq_prod, vlan_tag = 0;
 	u32		unmap_prod, wis, wis_used, wi_range;
 	u32		vectors, vect_id, i, acked;
 	int			err;
 
-	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	dma_addr_t		dma_addr;
 	struct bna_txq_entry *txqent;
 	u16	flags;
@@ -2556,6 +2571,16 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
+	txq_id = skb_get_queue_mapping(skb);
+
+	tcb = bnad->tx_info[0].tcb[txq_id];
+
+	if (unlikely(!tcb)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	unmap_q = tcb->unmap_q;
 	/*
 	 * Takes care of the Tx that is scheduled between clearing the flag
 	 * and the netif_stop_all_queue() call.
@@ -2583,7 +2608,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 			smp_mb__before_clear_bit();
 			clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
 		} else {
-			netif_stop_queue(netdev);
+			netif_stop_subqueue(netdev, txq_id);
 			BNAD_UPDATE_CTR(bnad, netif_queue_stop);
 		}
 
@@ -2599,7 +2624,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 			BNAD_UPDATE_CTR(bnad, netif_queue_stop);
 			return NETDEV_TX_BUSY;
 		} else {
-			netif_wake_queue(netdev);
+			netif_wake_subqueue(netdev, txq_id);
 			BNAD_UPDATE_CTR(bnad, netif_queue_wakeup);
 		}
 	}
@@ -2624,7 +2649,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 	if (test_bit(BNAD_RF_CEE_RUNNING, &bnad->run_flags)) {
 		vlan_tag =
-			(tcb->priority & 0x7) << 13 | (vlan_tag & 0x1fff);
+			((tcb->priority & 0x7) << VLAN_PRIO_SHIFT)
+							| (vlan_tag & 0x1fff);
 		flags |= (BNA_TXQ_WI_CF_INS_PRIO | BNA_TXQ_WI_CF_INS_VLAN);
 	}
 
@@ -2771,6 +2797,50 @@ bnad_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
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
@@ -2977,6 +3047,7 @@ bnad_netpoll(struct net_device *netdev)
 static const struct net_device_ops bnad_netdev_ops = {
 	.ndo_open		= bnad_open,
 	.ndo_stop		= bnad_stop,
+	.ndo_select_queue	= bnad_tx_select_queue,
 	.ndo_start_xmit		= bnad_start_xmit,
 	.ndo_get_stats64		= bnad_get_stats64,
 	.ndo_set_rx_mode	= bnad_set_rx_mode,
@@ -3173,7 +3244,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 * Allocates sizeof(struct net_device + struct bnad)
 	 * bnad = netdev->priv
 	 */
-	netdev = alloc_etherdev(sizeof(struct bnad));
+	netdev = alloc_etherdev_mq(sizeof(struct bnad), BNAD_MAX_TXQ);
 	if (!netdev) {
 		dev_err(&pdev->dev, "netdev allocation failed\n");
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 60c2e9d..c8664d5 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -40,7 +40,6 @@
 
 #define BNAD_MAX_TX		1
 #define BNAD_MAX_TXQ_PER_TX	8	/* 8 priority queues */
-#define BNAD_TXQ_NUM		1
 
 #define BNAD_MAX_RX		1
 #define BNAD_MAX_RXP_PER_RX	16
@@ -98,6 +97,9 @@ struct bnad_rx_ctrl {
 #define BNAD_RXQ_STARTED		1
 
 /* Resource limits */
+#define BNAD_MAX_TXQ			(BNAD_MAX_TX * BNAD_MAX_TXQ_PER_TX)
+#define BNAD_MAX_RXP			(BNAD_MAX_RX * BNAD_MAX_RXP_PER_RX)
+
 #define BNAD_NUM_TXQ			(bnad->num_tx * bnad->num_txq_per_tx)
 #define BNAD_NUM_RXP			(bnad->num_rx * bnad->num_rxp_per_rx)
 
@@ -231,6 +233,15 @@ struct bnad_unmap_q {
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

