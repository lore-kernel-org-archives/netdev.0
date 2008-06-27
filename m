From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 14/18] igb: Add support for quad port
	WOL and feature	flags
Date: Fri, 27 Jun 2008 11:01:39 -0700
Message-ID: <20080627180136.22428.92338.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

Change igb from using a series of boolean operators to using a single flags
value that contains a number of different bit flags for all the different
features of the adapter.

This patch also adds WOL support for quad port adapters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |   13 ++++--
 drivers/net/igb/igb_ethtool.c |   12 ++++-
 drivers/net/igb/igb_main.c    |   92 ++++++++++++++++++++++++++++-------------
 3 files changed, 81 insertions(+), 36 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index fa941da..97f03da 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -270,16 +270,21 @@ struct igb_adapter {
 
 	/* to not mess up cache alignment, always add to the bottom */
 	unsigned long state;
-	unsigned int msi_enabled;
-#ifdef CONFIG_DCA
-	unsigned int dca_enabled;
-#endif
+	unsigned int flags;
 	u32 eeprom_wol;
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
 #endif /* CONFIG_NETDEVICES_MULTIQUEUE */
 };
 
+#define IGB_FLAG_HAS_MSI           (1 << 0)
+#define IGB_FLAG_MSI_ENABLE        (1 << 1)
+#define IGB_FLAG_HAS_DCA           (1 << 2)
+#define IGB_FLAG_DCA_ENABLED       (1 << 3)
+#define IGB_FLAG_IN_NETPOLL        (1 << 5)
+#define IGB_FLAG_QUAD_PORT_A       (1 << 6)
+#define IGB_FLAG_NEED_CTX_IDX      (1 << 7)
+
 enum e1000_state_t {
 	__IGB_TESTING,
 	__IGB_RESETTING,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index e27d5a5..ef209b5 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1097,7 +1097,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	if (adapter->msix_entries) {
 		/* NOTE: we don't test MSI-X interrupts here, yet */
 		return 0;
-	} else if (adapter->msi_enabled) {
+	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		shared_int = false;
 		if (request_irq(irq, &igb_test_intr, 0, netdev->name, netdev)) {
 			*data = 1;
@@ -1727,7 +1727,6 @@ static int igb_wol_exclusion(struct igb_adapter *adapter,
 
 	switch (hw->device_id) {
 	case E1000_DEV_ID_82575GB_QUAD_COPPER:
-	case E1000_DEV_ID_82576_QUAD_COPPER:
 		/* WoL not supported */
 		wol->supported = 0;
 		break;
@@ -1742,6 +1741,15 @@ static int igb_wol_exclusion(struct igb_adapter *adapter,
 		/* return success for non excluded adapter ports */
 		retval = 0;
 		break;
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		/* quad port adapters only support WoL on port A */
+		if (!(adapter->flags & IGB_FLAG_QUAD_PORT_A)) {
+			wol->supported = 0;
+			break;
+		}
+		/* return success for non excluded adapter ports */
+		retval = 0;
+		break;
 	default:
 		/* dual port cards only support WoL on port A from now on
 		 * unless it was enabled in the eeprom for port B
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f4b1e3a..43f288a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -53,7 +53,6 @@ static const char igb_driver_string[] =
 				"Intel(R) Gigabit Ethernet Network Driver";
 static const char igb_copyright[] = "Copyright (c) 2008 Intel Corporation.";
 
-
 static const struct e1000_info *igb_info_tbl[] = {
 	[board_82575] = &e1000_82575_info,
 };
@@ -170,6 +169,8 @@ static struct pci_driver igb_driver = {
 	.err_handler = &igb_err_handler
 };
 
+static int global_quad_port_a; /* global quad port a indication */
+
 MODULE_AUTHOR("Intel Corporation, <e1000-devel@lists.sourceforge.net>");
 MODULE_DESCRIPTION("Intel(R) Gigabit Ethernet Network Driver");
 MODULE_LICENSE("GPL");
@@ -201,6 +202,8 @@ static int __init igb_init_module(void)
 
 	printk(KERN_INFO "%s\n", igb_copyright);
 
+	global_quad_port_a = 0;
+
 	ret = pci_register_driver(&igb_driver);
 #ifdef CONFIG_DCA
 	dca_register_notify(&dca_notifier);
@@ -471,7 +474,7 @@ static void igb_reset_interrupt_capability(struct igb_adapter *adapter)
 		pci_disable_msix(adapter->pdev);
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
-	} else if (adapter->msi_enabled)
+	} else if (adapter->flags & IGB_FLAG_HAS_MSI)
 		pci_disable_msi(adapter->pdev);
 	return;
 }
@@ -510,7 +513,7 @@ msi_only:
 	adapter->num_rx_queues = 1;
 	adapter->num_tx_queues = 1;
 	if (!pci_enable_msi(adapter->pdev))
-		adapter->msi_enabled = 1;
+		adapter->flags |= IGB_FLAG_HAS_MSI;
 
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
@@ -538,7 +541,7 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		/* fall back to MSI */
 		igb_reset_interrupt_capability(adapter);
 		if (!pci_enable_msi(adapter->pdev))
-			adapter->msi_enabled = 1;
+			adapter->flags |= IGB_FLAG_HAS_MSI;
 		igb_free_all_tx_resources(adapter);
 		igb_free_all_rx_resources(adapter);
 		adapter->num_rx_queues = 1;
@@ -557,14 +560,14 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		}
 	}
 
-	if (adapter->msi_enabled) {
+	if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		err = request_irq(adapter->pdev->irq, &igb_intr_msi, 0,
 				  netdev->name, netdev);
 		if (!err)
 			goto request_done;
 		/* fall back to legacy interrupts */
 		igb_reset_interrupt_capability(adapter);
-		adapter->msi_enabled = 0;
+		adapter->flags &= ~IGB_FLAG_HAS_MSI;
 	}
 
 	err = request_irq(adapter->pdev->irq, &igb_intr, IRQF_SHARED,
@@ -1070,6 +1073,17 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	igb_get_bus_info_pcie(hw);
 
+	/* set flags */
+	switch (hw->mac.type) {
+	case e1000_82576:
+	case e1000_82575:
+		adapter->flags |= IGB_FLAG_HAS_DCA;
+		adapter->flags |= IGB_FLAG_NEED_CTX_IDX;
+		break;
+	default:
+		break;
+	}
+
 	hw->phy.autoneg_wait_to_complete = false;
 	hw->mac.adaptive_ifs = true;
 
@@ -1182,7 +1196,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	 * lan on a particular port */
 	switch (pdev->device) {
 	case E1000_DEV_ID_82575GB_QUAD_COPPER:
-	case E1000_DEV_ID_82576_QUAD_COPPER:
 		adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82575EB_FIBER_SERDES:
@@ -1193,6 +1206,16 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1)
 			adapter->eeprom_wol = 0;
 		break;
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		/* if quad port adapter, disable WoL on all but port A */
+		if (global_quad_port_a != 0)
+			adapter->eeprom_wol = 0;
+		else
+			adapter->flags |= IGB_FLAG_QUAD_PORT_A;
+		/* Reset for multiple quad port adapters */
+		if (++global_quad_port_a == 4)
+			global_quad_port_a = 0;
+		break;
 	}
 
 	/* initialize the wol settings based on the eeprom settings */
@@ -1219,8 +1242,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		goto err_register;
 
 #ifdef CONFIG_DCA
-	if (dca_add_requester(&pdev->dev) == 0) {
-		adapter->dca_enabled = true;
+	if ((adapter->flags & IGB_FLAG_HAS_DCA) &&
+	    (dca_add_requester(&pdev->dev) == 0)) {
+		adapter->flags |= IGB_FLAG_DCA_ENABLED;
 		dev_info(&pdev->dev, "DCA enabled\n");
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
@@ -1249,7 +1273,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	dev_info(&pdev->dev,
 		"Using %s interrupts. %d rx queue(s), %d tx queue(s)\n",
 		adapter->msix_entries ? "MSI-X" :
-		adapter->msi_enabled ? "MSI" : "legacy",
+		(adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
 		adapter->num_rx_queues, adapter->num_tx_queues);
 
 	return 0;
@@ -1303,10 +1327,10 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	flush_scheduled_work();
 
 #ifdef CONFIG_DCA
-	if (adapter->dca_enabled) {
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED) {
 		dev_info(&pdev->dev, "DCA disabled\n");
 		dca_remove_requester(&pdev->dev);
-		adapter->dca_enabled = false;
+		adapter->flags &= ~IGB_FLAG_DCA_ENABLED;
 		wr32(E1000_DCA_CTRL, 1);
 	}
 #endif
@@ -2623,9 +2647,9 @@ static inline int igb_tso_adv(struct igb_adapter *adapter,
 	mss_l4len_idx = (skb_shinfo(skb)->gso_size << E1000_ADVTXD_MSS_SHIFT);
 	mss_l4len_idx |= (l4len << E1000_ADVTXD_L4LEN_SHIFT);
 
-	/* Context index must be unique per ring.  Luckily, so is the interrupt
-	 * mask value. */
-	mss_l4len_idx |= tx_ring->eims_value >> 4;
+	/* Context index must be unique per ring. */
+	if (adapter->flags & IGB_FLAG_NEED_CTX_IDX)
+		mss_l4len_idx |= tx_ring->queue_index << 4;
 
 	context_desc->mss_l4len_idx = cpu_to_le32(mss_l4len_idx);
 	context_desc->seqnum_seed = 0;
@@ -2689,8 +2713,9 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);
 		context_desc->seqnum_seed = 0;
-		context_desc->mss_l4len_idx =
-					  cpu_to_le32(tx_ring->queue_index << 4);
+		if (adapter->flags & IGB_FLAG_NEED_CTX_IDX)
+			context_desc->mss_l4len_idx =
+				cpu_to_le32(tx_ring->queue_index << 4);
 
 		buffer_info->time_stamp = jiffies;
 		buffer_info->dma = 0;
@@ -2791,8 +2816,9 @@ static inline void igb_tx_queue_adv(struct igb_adapter *adapter,
 		olinfo_status |= E1000_TXD_POPTS_TXSM << 8;
 	}
 
-	if (tx_flags & (IGB_TX_FLAGS_CSUM | IGB_TX_FLAGS_TSO |
-			IGB_TX_FLAGS_VLAN))
+	if ((adapter->flags & IGB_FLAG_NEED_CTX_IDX) &&
+	    (tx_flags & (IGB_TX_FLAGS_CSUM | IGB_TX_FLAGS_TSO |
+			 IGB_TX_FLAGS_VLAN)))
 		olinfo_status |= tx_ring->queue_index << 4;
 
 	olinfo_status |= ((paylen - hdr_len) << E1000_ADVTXD_PAYLEN_SHIFT);
@@ -3228,7 +3254,7 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 	if (!tx_ring->itr_val)
 		wr32(E1000_EIMC, tx_ring->eims_value);
 #ifdef CONFIG_DCA
-	if (adapter->dca_enabled)
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(tx_ring);
 #endif
 	tx_ring->total_bytes = 0;
@@ -3265,7 +3291,7 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
 
 #ifdef CONFIG_DCA
-	if (adapter->dca_enabled)
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif
 		return IRQ_HANDLED;
@@ -3328,7 +3354,7 @@ static void igb_setup_dca(struct igb_adapter *adapter)
 {
 	int i;
 
-	if (!(adapter->dca_enabled))
+	if (!(adapter->flags & IGB_FLAG_DCA_ENABLED))
 		return;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
@@ -3348,12 +3374,15 @@ static int __igb_notify_dca(struct device *dev, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned long event = *(unsigned long *)data;
 
+	if (!(adapter->flags & IGB_FLAG_HAS_DCA))
+		goto out;
+
 	switch (event) {
 	case DCA_PROVIDER_ADD:
 		/* if already enabled, don't do it again */
-		if (adapter->dca_enabled)
+		if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 			break;
-		adapter->dca_enabled = true;
+		adapter->flags |= IGB_FLAG_DCA_ENABLED;
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
 		wr32(E1000_DCA_CTRL, 2);
@@ -3364,17 +3393,17 @@ static int __igb_notify_dca(struct device *dev, void *data)
 		}
 		/* Fall Through since DCA is disabled. */
 	case DCA_PROVIDER_REMOVE:
-		if (adapter->dca_enabled) {
+		if (adapter->flags & IGB_FLAG_DCA_ENABLED) {
 			/* without this a class_device is left
  			 * hanging around in the sysfs model */
 			dca_remove_requester(dev);
 			dev_info(&adapter->pdev->dev, "DCA disabled\n");
-			adapter->dca_enabled = false;
+			adapter->flags &= ~IGB_FLAG_DCA_ENABLED;
 			wr32(E1000_DCA_CTRL, 1);
 		}
 		break;
 	}
-
+out:
 	return 0;
 }
 
@@ -3480,13 +3509,13 @@ static int igb_poll(struct napi_struct *napi, int budget)
 
 	/* this poll routine only supports one tx and one rx queue */
 #ifdef CONFIG_DCA
-	if (adapter->dca_enabled)
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(&adapter->tx_ring[0]);
 #endif
 	tx_clean_complete = igb_clean_tx_irq(&adapter->tx_ring[0]);
 
 #ifdef CONFIG_DCA
-	if (adapter->dca_enabled)
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(&adapter->rx_ring[0]);
 #endif
 	igb_clean_rx_irq_adv(&adapter->rx_ring[0], &work_done, budget);
@@ -3518,7 +3547,7 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 		goto quit_polling;
 
 #ifdef CONFIG_DCA
-	if (adapter->dca_enabled)
+	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif
 	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
@@ -4320,6 +4349,8 @@ static void igb_netpoll(struct net_device *netdev)
 	int work_done = 0;
 
 	igb_irq_disable(adapter);
+	adapter->flags |= IGB_FLAG_IN_NETPOLL;
+
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		igb_clean_tx_irq(&adapter->tx_ring[i]);
 
@@ -4328,6 +4359,7 @@ static void igb_netpoll(struct net_device *netdev)
 				     &work_done,
 				     adapter->rx_ring[i].napi.weight);
 
+	adapter->flags &= ~IGB_FLAG_IN_NETPOLL;
 	igb_irq_enable(adapter);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
