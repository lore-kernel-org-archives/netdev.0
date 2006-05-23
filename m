From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 7/9] ixgb: use DPRINTK and msglvl, and ethtool to control it
Date: Tue, 23 May 2006 11:04:18 -0700
Message-ID: <20060523180418.17428.10734.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:46853 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932118AbWEWR7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:20 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use DPRINTK and msglvl, and ethtool to control it. Add proper names
to netdev structs and mappings.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    8 ++++++-
 drivers/net/ixgb/ixgb_ethtool.c |   15 +++++++++++++
 drivers/net/ixgb/ixgb_main.c    |   46 +++++++++++++++++++++++++++------------
 3 files changed, 54 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index c83271b..a687f12 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -84,7 +84,12 @@ struct ixgb_adapter;
 #define IXGB_DBG(args...)
 #endif
 
-#define IXGB_ERR(args...) printk(KERN_ERR "ixgb: " args)
+#define PFX "ixgb: "
+#define DPRINTK(nlevel, klevel, fmt, args...) \
+	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
+	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
+		__FUNCTION__ , ## args))
+
 
 /* TX/RX descriptor defines */
 #define DEFAULT_TXD	 256
@@ -192,6 +197,7 @@ struct ixgb_adapter {
 
 	/* structs defined in ixgb_hw.h */
 	struct ixgb_hw hw;
+	u16 msg_enable;
 	struct ixgb_hw_stats stats;
 #ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index f6baf28..560b4b6 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -250,6 +250,19 @@ ixgb_set_tso(struct net_device *netdev, 
 } 
 #endif /* NETIF_F_TSO */
 
+static uint32_t
+ixgb_get_msglevel(struct net_device *netdev)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	return adapter->msg_enable;
+}
+
+static void
+ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
+{
+	struct ixgb_adapter *adapter = netdev->priv;
+	adapter->msg_enable = data;
+}
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
 
 static int 
@@ -709,6 +722,8 @@ static struct ethtool_ops ixgb_ethtool_o
 	.set_tx_csum = ixgb_set_tx_csum,
 	.get_sg	= ethtool_op_get_sg,
 	.set_sg	= ethtool_op_set_sg,
+	.get_msglevel = ixgb_get_msglevel,
+	.set_msglevel = ixgb_set_msglevel,
 #ifdef NETIF_F_TSO
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ixgb_set_tso,
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 0de3ed0..4115bf3 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -150,6 +150,11 @@ MODULE_DESCRIPTION("Intel(R) PRO/10GbE N
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 /* some defines for controlling descriptor fetches in h/w */
 #define RXDCTL_WTHRESH_DEFAULT 16	/* chip writes back at this many or RXT0 */
 #define RXDCTL_PTHRESH_DEFAULT 0		/* chip considers prefech below
@@ -251,7 +256,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 	if (!pcix)
 	   adapter->have_msi = FALSE;
 	else if((err = pci_enable_msi(adapter->pdev))) {
-		printk (KERN_ERR
+		DPRINTK(PROBE, ERR,
 		 "Unable to allocate MSI interrupt Error: %d\n", err);
 		adapter->have_msi = FALSE;
 		/* proceed to try to request regular interrupt */
@@ -261,8 +266,11 @@ ixgb_up(struct ixgb_adapter *adapter)
 #endif
 	if((err = request_irq(adapter->pdev->irq, &ixgb_intr,
 				  SA_SHIRQ | SA_SAMPLE_RANDOM,
-				  netdev->name, netdev)))
+			          netdev->name, netdev))) {
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate interrupt Error: %d\n", err);
 		return err;
+	}
 
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
@@ -328,7 +336,7 @@ ixgb_reset(struct ixgb_adapter *adapter)
 
 	ixgb_adapter_stop(&adapter->hw);
 	if(!ixgb_init_hw(&adapter->hw))
-		IXGB_DBG("ixgb_init_hw failed.\n");
+		DPRINTK(PROBE, ERR, "ixgb_init_hw failed.\n");
 }
 
 /**
@@ -365,7 +373,8 @@ ixgb_probe(struct pci_dev *pdev,
 	} else {
 		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
 		   (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
-			IXGB_ERR("No usable DMA configuration, aborting\n");
+			printk(KERN_ERR
+			 "ixgb: No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
 		}
 		pci_using_dac = 0;
@@ -390,6 +399,7 @@ ixgb_probe(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
@@ -430,6 +440,7 @@ ixgb_probe(struct pci_dev *pdev,
 	netdev->poll_controller = ixgb_netpoll;
 #endif
 
+	strcpy(netdev->name, pci_name(pdev));
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
 	netdev->base_addr = adapter->hw.io_base;
@@ -461,7 +472,7 @@ ixgb_probe(struct pci_dev *pdev,
 	/* make sure the EEPROM is good */
 
 	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
-		printk(KERN_ERR "The EEPROM Checksum Is Not Valid\n");
+		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -470,6 +481,7 @@ ixgb_probe(struct pci_dev *pdev,
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
 	if(!is_valid_ether_addr(netdev->perm_addr)) {
+		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -483,6 +495,7 @@ ixgb_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->tx_timeout_task,
 		  (void (*)(void *))ixgb_tx_timeout_task, netdev);
 
+	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev)))
 		goto err_register;
 
@@ -491,8 +504,7 @@ ixgb_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	printk(KERN_INFO "%s: Intel(R) PRO/10GbE Network Connection\n",
-		   netdev->name);
+	DPRINTK(PROBE, INFO, "Intel(R) PRO/10GbE Network Connection\n");
 	ixgb_check_options(adapter);
 	/* reset the hardware with the new settings */
 
@@ -573,7 +585,7 @@ ixgb_sw_init(struct ixgb_adapter *adapte
 			hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
-		printk(KERN_ERR "ixgb: unsupported device id\n");
+		DPRINTK(PROBE, ERR, "unsupported device id\n");
 	}
 
 	/* enable flow control to be programmed */
@@ -671,6 +683,8 @@ ixgb_setup_tx_resources(struct ixgb_adap
 	size = sizeof(struct ixgb_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if(!txdr->buffer_info) {
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -683,6 +697,8 @@ ixgb_setup_tx_resources(struct ixgb_adap
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
 		vfree(txdr->buffer_info);
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate transmit descriptor memory\n");
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -756,6 +772,8 @@ ixgb_setup_rx_resources(struct ixgb_adap
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if(!rxdr->buffer_info) {
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -769,6 +787,8 @@ ixgb_setup_rx_resources(struct ixgb_adap
 
 	if(!rxdr->desc) {
 		vfree(rxdr->buffer_info);
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate receive descriptors\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -1118,8 +1138,8 @@ ixgb_watchdog(unsigned long data)
 
 	if(adapter->hw.link_up) {
 		if(!netif_carrier_ok(netdev)) {
-			printk(KERN_INFO "ixgb: %s NIC Link is Up %d Mbps %s\n",
-				   netdev->name, 10000, "Full Duplex");
+			DPRINTK(LINK, INFO,
+			        "NIC Link is Up 10000 Mbps Full Duplex\n");
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
 			netif_carrier_on(netdev);
@@ -1129,9 +1149,7 @@ ixgb_watchdog(unsigned long data)
 		if(netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			printk(KERN_INFO
-				   "ixgb: %s NIC Link is Down\n",
-				   netdev->name);
+			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 
@@ -1529,7 +1547,7 @@ ixgb_change_mtu(struct net_device *netde
 
 	if((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
 	   || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
-		IXGB_ERR("Invalid MTU setting\n");
+		DPRINTK(PROBE, ERR, "Invalid MTU setting %d\n", new_mtu);
 		return -EINVAL;
 	}
 



--
Auke Kok <auke-jan.h.kok@intel.com>
