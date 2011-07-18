From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 32/45] bna: TxRx Coalesce Settings Fix and Reorg PCI Probe Failure
Date: Mon, 18 Jul 2011 01:22:52 -0700
Message-ID: <1310977385-5268-22-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48256 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754558Ab1GRIYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:41 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - The TX and Rx coalesce settings are programmed in steps of 5 us. The value
   that are not divisible by 5 are rounded to the next lower number. This was
   causing the value os 1 to 4 to be rounded to 0, which is an invalid setting.
 - When creating Rx and Tx object, we are currently assigning the default
   values of Rx and Tx coalescing_timeo. If these values are changed in
   the driver to a different value, the change is lost during such
   operations as MTU change. In order to avoid that, pass the configured
   value of coalescing_timeo before Rx and Tx object creation.
 - Fix bnad_tx_coalescing_timeo_set() so it applies to all the Tx objects.
 - Fix uninitialization path in case of pci_probe failure.
 - Added/Removed flags.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |   46 ++++++++++++++++++++++++++++++----------------
 drivers/net/bna/bnad.h |    9 +++++----
 2 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 684ff91..6d1b82b 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -1797,6 +1797,7 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 	tx_config->num_txq = bnad->num_txq_per_tx;
 	tx_config->txq_depth = bnad->txq_depth;
 	tx_config->tx_type = BNA_TX_T_REGULAR;
+	tx_config->coalescing_timeo = bnad->tx_coalescing_timeo;
 
 	/* Initialize the tx event handlers */
 	tx_cbfn.tcb_setup_cbfn = bnad_cb_tcb_setup;
@@ -1857,6 +1858,7 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 {
 	rx_config->rx_type = BNA_RX_T_REGULAR;
 	rx_config->num_paths = bnad->num_rxp_per_rx;
+	rx_config->coalescing_timeo = bnad->rx_coalescing_timeo;
 
 	if (bnad->num_rxp_per_rx > 1) {
 		rx_config->rss_status = BNA_STATUS_T_ENABLED;
@@ -2017,12 +2019,15 @@ void
 bnad_tx_coalescing_timeo_set(struct bnad *bnad)
 {
 	struct bnad_tx_info *tx_info;
+	int i;
 
-	tx_info = &bnad->tx_info[0];
-	if (!tx_info->tx)
-		return;
-
-	bna_tx_coalescing_timeo_set(tx_info->tx, bnad->tx_coalescing_timeo);
+	for (i = 0; i < bnad->num_tx; i++) {
+		tx_info = &bnad->tx_info[i];
+		if (!tx_info->tx)
+			continue;
+		bna_tx_coalescing_timeo_set(tx_info->tx,
+				bnad->tx_coalescing_timeo);
+	}
 }
 
 /* Called with conf_lock & bnad->bna_lock held */
@@ -2726,7 +2731,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
-		u32		size = frag->size;
+		u16		size = frag->size;
 
 		if (++vect_id == BFI_TX_MAX_VECTORS_PER_WI) {
 			vect_id = 0;
@@ -3248,7 +3253,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	/* Allocate resources from bna */
 	err = bnad_res_alloc(bnad, &bnad->res_info[0], BNA_RES_T_MAX);
 	if (err)
-		goto free_netdev;
+		goto drv_uninit;
 
 	bna = &bnad->bna;
 
@@ -3284,8 +3289,11 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 * This is a catastrophic error.
 	 */
 	err = bnad_ioceth_enable(bnad);
-	if (err)
-		goto disable_device;
+	if (err) {
+		pr_err("BNA: Initialization failed err=%d\n",
+		       err);
+		goto probe_success;
+	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (bna_num_txq_set(bna, BNAD_NUM_TXQ + 1) ||
@@ -3301,7 +3309,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 	err = bnad_res_alloc(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
 	if (err)
-		goto disable_device;
+		goto disable_ioceth;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_mod_init(&bnad->bna, &bnad->mod_res_info[0]);
@@ -3317,13 +3325,17 @@ bnad_pci_probe(struct pci_dev *pdev,
 	err = register_netdev(netdev);
 	if (err) {
 		pr_err("BNA : Registering with netdev failed\n");
-		goto disable_device;
+		goto probe_uninit;
 	}
-	mutex_unlock(&bnad->conf_mutex);
+	set_bit(BNAD_RF_NETDEV_REGISTERED, &bnad->run_flags);
 
+probe_success:
+	mutex_unlock(&bnad->conf_mutex);
 	return 0;
 
-disable_device:
+probe_uninit:
+	bnad_res_free(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
+disable_ioceth:
 	bnad_ioceth_disable(bnad);
 	del_timer_sync(&bnad->bna.ioceth.ioc.ioc_timer);
 	del_timer_sync(&bnad->bna.ioceth.ioc.sem_timer);
@@ -3331,13 +3343,14 @@ disable_device:
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_uninit(bna);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-	bnad_res_free(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
 	bnad_res_free(bnad, &bnad->res_info[0], BNA_RES_T_MAX);
+drv_uninit:
 	bnad_disable_msix(bnad);
+	bnad_uninit(bnad);
 pci_uninit:
 	bnad_pci_uninit(pdev);
+	mutex_unlock(&bnad->conf_mutex);
 	bnad_lock_uninit(bnad);
-	bnad_uninit(bnad);
 free_netdev:
 	free_netdev(netdev);
 	return err;
@@ -3358,7 +3371,8 @@ bnad_pci_remove(struct pci_dev *pdev)
 	bnad = netdev_priv(netdev);
 	bna = &bnad->bna;
 
-	unregister_netdev(netdev);
+	if (test_and_clear_bit(BNAD_RF_NETDEV_REGISTERED, &bnad->run_flags))
+		unregister_netdev(netdev);
 
 	mutex_lock(&bnad->conf_mutex);
 	bnad_ioceth_disable(bnad);
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 41ade02..c25e6e2 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -218,13 +218,14 @@ struct bnad_unmap_q {
 /* Defines for run_flags bit-mask */
 /* Set, tested & cleared using xxx_bit() functions */
 /* Values indicated bit positions */
-#define	BNAD_RF_CEE_RUNNING		1
+#define BNAD_RF_CEE_RUNNING		0
+#define BNAD_RF_MTU_SET		1
 #define BNAD_RF_MBOX_IRQ_DISABLED	2
-#define BNAD_RF_RX_STARTED		3
+#define BNAD_RF_NETDEV_REGISTERED	3
 #define BNAD_RF_DIM_TIMER_RUNNING	4
 #define BNAD_RF_STATS_TIMER_RUNNING	5
-#define BNAD_RF_TX_SHUTDOWN_DELAYED	6
-#define BNAD_RF_RX_SHUTDOWN_DELAYED	7
+#define BNAD_RF_TX_PRIO_SET		6
+
 
 /* Define for Fast Path flags */
 /* Defined as bit positions */
-- 
1.7.1

