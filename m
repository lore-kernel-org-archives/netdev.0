From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 31/45] bna: Configuration changes
Date: Mon, 18 Jul 2011 01:22:51 -0700
Message-ID: <1310977385-5268-21-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48254 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754524Ab1GRIYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:38 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
bnad.c:
 - Set number of Tx and Rx queues bassed on underlying hardware.
 - Take VLAN header into account for MTU calculation
 - Default to INTx mode when pci_enable_msix() fails.
 - Set a bit in Rx poll routine, check and wait for that bit to be cleared
   in the cleanup routine before proceeding.
bnad.h:
 - Define separate macros for maximum and supported numbers of Tx and Rx
   queues based on underlying hardware
bna.h:
 - Define a macro to access the supported attributes for underlying hardware

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bna.h  |    4 ++
 drivers/net/bna/bnad.c |  136 ++++++++++++++++++++++++++++++-----------------
 drivers/net/bna/bnad.h |   23 ++++++---
 3 files changed, 107 insertions(+), 56 deletions(-)

diff --git a/drivers/net/bna/bna.h b/drivers/net/bna/bna.h
index 518f3dd..66725d3 100644
--- a/drivers/net/bna/bna.h
+++ b/drivers/net/bna/bna.h
@@ -362,6 +362,8 @@ do {									\
 
 #define bna_is_prio_reconfig(_bna) ((_bna)->tx_mod.prio_reconfigured)
 
+#define bna_attr(_bna) (&(_bna)->ioceth.attr)
+
 /**
  *
  *  Inline functions
@@ -403,6 +405,8 @@ void bna_init(struct bna *bna, struct bnad *bnad,
 			struct bna_res_info *res_info);
 void bna_mod_init(struct bna *bna, struct bna_res_info *res_info);
 void bna_uninit(struct bna *bna);
+int bna_num_txq_set(struct bna *bna, int num_txq);
+int bna_num_rxp_set(struct bna *bna, int num_rxp);
 void bna_stats_get(struct bna *bna);
 void bna_get_perm_mac(struct bna *bna, u8 *mac);
 void bna_hw_stats_get(struct bna *bna);
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 076f398..684ff91 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -441,9 +441,17 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	struct sk_buff *skb;
 	u32 flags, unmap_cons;
 	struct bna_pkt_rate *pkt_rt = &ccb->pkt_rate;
+	struct bnad_rx_ctrl *rx_ctrl = (struct bnad_rx_ctrl *)(ccb->ctrl);
+
+	preempt_disable();
+
+	set_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
 
-	if (!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags))
+	if (!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)) {
+		clear_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
+		preempt_enable();
 		return 0;
+	}
 
 	prefetch(bnad->netdev);
 	BNA_CQ_QPGE_PTR_GET(ccb->producer_index, ccb->sw_qpt, cmpl,
@@ -551,6 +559,10 @@ next:
 			bna_ib_ack(ccb->i_dbell, 0);
 	}
 
+	clear_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
+
+	preempt_enable();
+
 	return packets;
 }
 
@@ -1259,7 +1271,7 @@ bnad_txrx_irq_free(struct bnad *bnad, struct bna_intr_info *intr_info)
 /* Allocates Interrupt Descriptor List for MSIX/INT-X vectors */
 static int
 bnad_txrx_irq_alloc(struct bnad *bnad, enum bnad_intr_source src,
-		    uint txrx_id, struct bna_intr_info *intr_info)
+		    u32 txrx_id, struct bna_intr_info *intr_info)
 {
 	int i, vector_start = 0;
 	u32 cfg_flags;
@@ -1342,7 +1354,7 @@ bnad_tx_msix_unregister(struct bnad *bnad, struct bnad_tx_info *tx_info,
  */
 static int
 bnad_tx_msix_register(struct bnad *bnad, struct bnad_tx_info *tx_info,
-			uint tx_id, int num_txqs)
+			u32 tx_id, int num_txqs)
 {
 	int i;
 	int err;
@@ -1395,7 +1407,7 @@ bnad_rx_msix_unregister(struct bnad *bnad, struct bnad_rx_info *rx_info,
  */
 static int
 bnad_rx_msix_register(struct bnad *bnad, struct bnad_rx_info *rx_info,
-			uint rx_id, int num_rxps)
+			u32 rx_id, int num_rxps)
 {
 	int i;
 	int err;
@@ -1439,7 +1451,7 @@ bnad_tx_res_free(struct bnad *bnad, struct bna_res_info *res_info)
 /* Allocates memory and interrupt resources for Tx object */
 static int
 bnad_tx_res_alloc(struct bnad *bnad, struct bna_res_info *res_info,
-		  uint tx_id)
+		  u32 tx_id)
 {
 	int i, err = 0;
 
@@ -1733,7 +1745,7 @@ bnad_napi_disable(struct bnad *bnad, u32 rx_id)
 
 /* Should be held with conf_lock held */
 void
-bnad_cleanup_tx(struct bnad *bnad, uint tx_id)
+bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 {
 	struct bnad_tx_info *tx_info = &bnad->tx_info[tx_id];
 	struct bna_res_info *res_info = &bnad->tx_res_info[tx_id].res_info[0];
@@ -1757,6 +1769,7 @@ bnad_cleanup_tx(struct bnad *bnad, uint tx_id)
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	tx_info->tx = NULL;
+	tx_info->tx_id = 0;
 
 	if (0 == tx_id)
 		tasklet_kill(&bnad->tx_free_tasklet);
@@ -1766,7 +1779,7 @@ bnad_cleanup_tx(struct bnad *bnad, uint tx_id)
 
 /* Should be held with conf_lock held */
 int
-bnad_setup_tx(struct bnad *bnad, uint tx_id)
+bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 {
 	int err;
 	struct bnad_tx_info *tx_info = &bnad->tx_info[tx_id];
@@ -1778,6 +1791,8 @@ bnad_setup_tx(struct bnad *bnad, uint tx_id)
 	struct bna_tx *tx;
 	unsigned long flags;
 
+	tx_info->tx_id = tx_id;
+
 	/* Initialize the Tx object configuration */
 	tx_config->num_txq = bnad->num_txq_per_tx;
 	tx_config->txq_depth = bnad->txq_depth;
@@ -1869,7 +1884,7 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 
 /* Called with mutex_lock(&bnad->conf_mutex) held */
 void
-bnad_cleanup_rx(struct bnad *bnad, uint rx_id)
+bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 {
 	struct bnad_rx_info *rx_info = &bnad->rx_info[rx_id];
 	struct bna_rx_config *rx_config = &bnad->rx_config[rx_id];
@@ -1912,7 +1927,7 @@ bnad_cleanup_rx(struct bnad *bnad, uint rx_id)
 
 /* Called with mutex_lock(&bnad->conf_mutex) held */
 int
-bnad_setup_rx(struct bnad *bnad, uint rx_id)
+bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 {
 	int err;
 	struct bnad_rx_info *rx_info = &bnad->rx_info[rx_id];
@@ -1924,6 +1939,8 @@ bnad_setup_rx(struct bnad *bnad, uint rx_id)
 	struct bna_rx *rx;
 	unsigned long flags;
 
+	rx_info->rx_id = rx_id;
+
 	/* Initialize the Rx object configuration */
 	bnad_init_rx_config(bnad, rx_config);
 
@@ -2138,7 +2155,7 @@ void
 bnad_netdev_hwstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats)
 {
 	struct bfi_enet_stats_mac *mac_stats;
-	u64 bmap;
+	u32 bmap;
 	int i;
 
 	mac_stats = &bnad->stats.bna_stats->hw_stats.mac_stats;
@@ -2253,7 +2270,7 @@ bnad_q_num_init(struct bnad *bnad)
 	bnad->num_rx = 1;
 	bnad->num_tx = 1;
 	bnad->num_rxp_per_rx = rxps;
-	bnad->num_txq_per_tx = BNAD_TXQ_NUM;
+	bnad->num_txq_per_tx = BNAD_MAX_TXQ_PER_TX;
 }
 
 /*
@@ -2263,7 +2280,7 @@ bnad_q_num_init(struct bnad *bnad)
  * Called with bnad->bna_lock held b'cos of cfg_flags access
  */
 static void
-bnad_q_num_adjust(struct bnad *bnad, int msix_vectors)
+bnad_q_num_adjust(struct bnad *bnad, int msix_vectors, int temp)
 {
 	bnad->num_txq_per_tx = 1;
 	if ((msix_vectors >= (bnad->num_tx * bnad->num_txq_per_tx)  +
@@ -2317,12 +2334,12 @@ bnad_ioceth_enable(struct bnad *bnad)
 
 /* Free BNA resources */
 static void
-bnad_res_free(struct bnad *bnad)
+bnad_res_free(struct bnad *bnad, struct bna_res_info *res_info,
+		u32 res_val_max)
 {
 	int i;
-	struct bna_res_info *res_info = &bnad->res_info[0];
 
-	for (i = 0; i < BNA_RES_T_MAX; i++) {
+	for (i = 0; i < res_val_max; i++) {
 		if (res_info[i].res_type == BNA_RES_T_MEM)
 			bnad_mem_free(bnad, &res_info[i].res_u.mem_info);
 		else
@@ -2332,10 +2349,10 @@ bnad_res_free(struct bnad *bnad)
 
 /* Allocates memory and interrupt resources for BNA */
 static int
-bnad_res_alloc(struct bnad *bnad)
+bnad_res_alloc(struct bnad *bnad, struct bna_res_info *res_info,
+		u32 res_val_max)
 {
 	int i, err;
-	struct bna_res_info *res_info = &bnad->res_info[0];
 
 	for (i = 0; i < BNA_RES_T_MAX; i++) {
 		if (res_info[i].res_type == BNA_RES_T_MEM)
@@ -2349,7 +2366,7 @@ bnad_res_alloc(struct bnad *bnad)
 	return 0;
 
 err_return:
-	bnad_res_free(bnad);
+	bnad_res_free(bnad, res_info, res_val_max);
 	return err;
 }
 
@@ -2385,7 +2402,7 @@ bnad_enable_msix(struct bnad *bnad)
 
 		spin_lock_irqsave(&bnad->bna_lock, flags);
 		/* ret = #of vectors that we got */
-		bnad_q_num_adjust(bnad, ret);
+		bnad_q_num_adjust(bnad, ret, 0);
 		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 		bnad->msix_num = (bnad->num_tx * bnad->num_txq_per_tx)
@@ -2393,6 +2410,9 @@ bnad_enable_msix(struct bnad *bnad)
 			* bnad->num_rxp_per_rx) +
 			 BNAD_MAILBOX_MSIX_VECTORS;
 
+		if (bnad->msix_num > ret)
+			goto intx_mode;
+
 		/* Try once more with adjusted numbers */
 		/* If this fails, fall back to INTx */
 		ret = pci_enable_msix(bnad->pcidev, bnad->msix_table,
@@ -2402,6 +2422,9 @@ bnad_enable_msix(struct bnad *bnad)
 
 	} else if (ret < 0)
 		goto intx_mode;
+
+	pci_intx(bnad->pcidev, 0);
+
 	return;
 
 intx_mode:
@@ -2460,7 +2483,7 @@ bnad_open(struct net_device *netdev)
 	pause_config.tx_pause = 0;
 	pause_config.rx_pause = 0;
 
-	mtu = ETH_HLEN + bnad->netdev->mtu + ETH_FCS_LEN;
+	mtu = ETH_HLEN + VLAN_HLEN + bnad->netdev->mtu + ETH_FCS_LEN;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_enet_mtu_set(&bnad->bna.enet, mtu, NULL);
@@ -2534,16 +2557,15 @@ static netdev_tx_t
 bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
+	u32 txq_id = 0;
+	struct bna_tcb *tcb = bnad->tx_info[0].tcb[txq_id];
 
 	u16		txq_prod, vlan_tag = 0;
 	u32		unmap_prod, wis, wis_used, wi_range;
 	u32		vectors, vect_id, i, acked;
-	u32		tx_id;
 	int			err;
 
-	struct bnad_tx_info *tx_info;
-	struct bna_tcb *tcb;
-	struct bnad_unmap_q *unmap_q;
+	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	dma_addr_t		dma_addr;
 	struct bna_txq_entry *txqent;
 	u16	flags;
@@ -2554,15 +2576,9 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-	tx_id = 0;
-
-	tx_info = &bnad->tx_info[tx_id];
-	tcb = tx_info->tcb[tx_id];
-	unmap_q = tcb->unmap_q;
-
 	/*
 	 * Takes care of the Tx that is scheduled between clearing the flag
-	 * and the netif_stop_queue() call.
+	 * and the netif_stop_all_queue() call.
 	 */
 	if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))) {
 		dev_kfree_skb(skb);
@@ -2576,9 +2592,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 	wis = BNA_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
 	acked = 0;
-	if (unlikely
-	    (wis > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
-	     vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
+	if (unlikely(wis > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
+			vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
 		if ((u16) (*tcb->hw_consumer_index) !=
 		    tcb->consumer_index &&
 		    !test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags)) {
@@ -3190,12 +3205,15 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 */
 	netdev = alloc_etherdev(sizeof(struct bnad));
 	if (!netdev) {
-		dev_err(&pdev->dev, "alloc_etherdev failed\n");
+		dev_err(&pdev->dev, "netdev allocation failed\n");
 		err = -ENOMEM;
 		return err;
 	}
 	bnad = netdev_priv(netdev);
 
+	bnad_lock_init(bnad);
+
+	mutex_lock(&bnad->conf_mutex);
 	/*
 	 * PCI initialization
 	 *	Output : using_dac = 1 for 64 bit DMA
@@ -3205,7 +3223,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto free_netdev;
 
-	bnad_lock_init(bnad);
 	/*
 	 * Initialize bnad structure
 	 * Setup relation between pci_dev & netdev
@@ -3214,6 +3231,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	err = bnad_init(bnad, pdev, netdev);
 	if (err)
 		goto pci_uninit;
+
 	/* Initialize netdev structure, set up ethtool ops */
 	bnad_netdev_init(bnad, using_dac);
 
@@ -3223,10 +3241,12 @@ bnad_pci_probe(struct pci_dev *pdev,
 	bnad_enable_msix(bnad);
 
 	/* Get resource requirement form bna */
+	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_res_req(&bnad->res_info[0]);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	/* Allocate resources from bna */
-	err = bnad_res_alloc(bnad);
+	err = bnad_res_alloc(bnad, &bnad->res_info[0], BNA_RES_T_MAX);
 	if (err)
 		goto free_netdev;
 
@@ -3238,8 +3258,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 	pcidev_info.device_id = bnad->pcidev->device;
 	pcidev_info.pci_bar_kva = bnad->bar0;
 
-	mutex_lock(&bnad->conf_mutex);
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_init(bna, bnad, &pcidev_info, &bnad->res_info[0]);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -3262,10 +3280,32 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 	/*
 	 * Start the chip
-	 * Don't care even if err != 0, bna state machine will
-	 * deal with it
+	 * If the call back comes with error, we bail out.
+	 * This is a catastrophic error.
 	 */
 	err = bnad_ioceth_enable(bnad);
+	if (err)
+		goto disable_device;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	if (bna_num_txq_set(bna, BNAD_NUM_TXQ + 1) ||
+		bna_num_rxp_set(bna, BNAD_NUM_RXP + 1)) {
+		bnad_q_num_adjust(bnad, bna_attr(bna)->num_txq - 1,
+			bna_attr(bna)->num_rxp - 1);
+		if (bna_num_txq_set(bna, BNAD_NUM_TXQ + 1) ||
+			bna_num_rxp_set(bna, BNAD_NUM_RXP + 1))
+			err = -EIO;
+	}
+	bna_mod_res_req(&bnad->bna, &bnad->mod_res_info[0]);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+
+	err = bnad_res_alloc(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
+	if (err)
+		goto disable_device;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bna_mod_init(&bnad->bna, &bnad->mod_res_info[0]);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	/* Get the burnt-in mac */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -3273,19 +3313,17 @@ bnad_pci_probe(struct pci_dev *pdev,
 	bnad_set_netdev_perm_addr(bnad);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-	mutex_unlock(&bnad->conf_mutex);
-
 	/* Finally, reguister with net_device layer */
 	err = register_netdev(netdev);
 	if (err) {
 		pr_err("BNA : Registering with netdev failed\n");
 		goto disable_device;
 	}
+	mutex_unlock(&bnad->conf_mutex);
 
 	return 0;
 
 disable_device:
-	mutex_lock(&bnad->conf_mutex);
 	bnad_ioceth_disable(bnad);
 	del_timer_sync(&bnad->bna.ioceth.ioc.ioc_timer);
 	del_timer_sync(&bnad->bna.ioceth.ioc.sem_timer);
@@ -3293,9 +3331,8 @@ disable_device:
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_uninit(bna);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-	mutex_unlock(&bnad->conf_mutex);
-
-	bnad_res_free(bnad);
+	bnad_res_free(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
+	bnad_res_free(bnad, &bnad->res_info[0], BNA_RES_T_MAX);
 	bnad_disable_msix(bnad);
 pci_uninit:
 	bnad_pci_uninit(pdev);
@@ -3331,11 +3368,12 @@ bnad_pci_remove(struct pci_dev *pdev)
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_uninit(bna);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-	mutex_unlock(&bnad->conf_mutex);
 
-	bnad_res_free(bnad);
+	bnad_res_free(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
+	bnad_res_free(bnad, &bnad->res_info[0], BNA_RES_T_MAX);
 	bnad_disable_msix(bnad);
 	bnad_pci_uninit(pdev);
+	mutex_unlock(&bnad->conf_mutex);
 	bnad_lock_uninit(bnad);
 	bnad_uninit(bnad);
 	free_netdev(netdev);
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 6a161b0..41ade02 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -38,12 +38,11 @@
 #define BNAD_RXQ_DEPTH		2048
 
 #define BNAD_MAX_TX		1
-#define BNAD_MAX_TXQ_PER_TX	8	/* 8 priority queues */
-#define BNAD_TXQ_NUM		1
+#define BNAD_MAX_TXQ_PER_TX	8
 
 #define BNAD_MAX_RX		1
 #define BNAD_MAX_RXP_PER_RX	16
-#define BNAD_MAX_RXQ_PER_RXP    2
+#define BNAD_MAX_RXQ_PER_RXP	2
 
 /*
  * Control structure pointed to ccb->ctrl, which
@@ -95,6 +94,13 @@ struct bnad_rx_ctrl {
 #define BNAD_RXQ_REFILL			0
 #define BNAD_RXQ_STARTED		1
 
+/* Resource limits */
+#define BNAD_MAX_TXQ			(BNAD_MAX_TX * BNAD_MAX_TXQ_PER_TX)
+#define BNAD_MAX_RXP			(BNAD_MAX_RX * BNAD_MAX_RXP_PER_RX)
+
+#define BNAD_NUM_TXQ			(bnad->num_tx * bnad->num_txq_per_tx)
+#define BNAD_NUM_RXP			(bnad->num_rx * bnad->num_rxp_per_rx)
+
 /*
  * DATA STRUCTURES
  */
@@ -179,12 +185,14 @@ struct bnad_rx_res_info {
 struct bnad_tx_info {
 	struct bna_tx *tx; /* 1:1 between tx_info & tx */
 	struct bna_tcb *tcb[BNAD_MAX_TXQ_PER_TX];
+	u32 tx_id;
 } ____cacheline_aligned;
 
 struct bnad_rx_info {
 	struct bna_rx *rx; /* 1:1 between rx_info & rx */
 
 	struct bnad_rx_ctrl rx_ctrl[BNAD_MAX_RXP_PER_RX];
+	u32 rx_id;
 } ____cacheline_aligned;
 
 /* Unmap queues for Tx / Rx cleanup */
@@ -274,6 +282,7 @@ struct bnad {
 
 	/* Control path resources, memory & irq */
 	struct bna_res_info res_info[BNA_RES_T_MAX];
+	struct bna_res_info mod_res_info[BNA_MOD_RES_T_MAX];
 	struct bnad_tx_res_info tx_res_info[BNAD_MAX_TX];
 	struct bnad_rx_res_info rx_res_info[BNAD_MAX_RX];
 
@@ -311,10 +320,10 @@ extern void bnad_set_ethtool_ops(struct net_device *netdev);
 extern void bnad_tx_coalescing_timeo_set(struct bnad *bnad);
 extern void bnad_rx_coalescing_timeo_set(struct bnad *bnad);
 
-extern int bnad_setup_rx(struct bnad *bnad, uint rx_id);
-extern int bnad_setup_tx(struct bnad *bnad, uint tx_id);
-extern void bnad_cleanup_tx(struct bnad *bnad, uint tx_id);
-extern void bnad_cleanup_rx(struct bnad *bnad, uint rx_id);
+extern int bnad_setup_rx(struct bnad *bnad, u32 rx_id);
+extern int bnad_setup_tx(struct bnad *bnad, u32 tx_id);
+extern void bnad_cleanup_tx(struct bnad *bnad, u32 tx_id);
+extern void bnad_cleanup_rx(struct bnad *bnad, u32 rx_id);
 
 /* Timer start/stop protos */
 extern void bnad_dim_timer_start(struct bnad *bnad);
-- 
1.7.1

