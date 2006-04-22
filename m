From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 02/11] ixgb: Fix the use of dprintk rather than printk
Date: Fri, 21 Apr 2006 18:00:34 -0700
Message-ID: <20060422010034.24255.21136.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:47745 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750810AbWDVA52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:28 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- use DPRINTK and msglvl instead of printk
- allow ethtool control of msglvl

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    8 +++++-
 drivers/net/ixgb/ixgb_ethtool.c |   16 ++++++++++++
 drivers/net/ixgb/ixgb_main.c    |   52 +++++++++++++++++++++++++--------------
 3 files changed, 56 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index c83271b..a696c33 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -84,7 +84,12 @@ struct ixgb_adapter;
 #define IXGB_DBG(args...)
 #endif
 
-#define IXGB_ERR(args...) printk(KERN_ERR "ixgb: " args)
+#define PFX "ixgb: "
+#define DPRINTK(nlevel, klevel, fmt, args...) \
+   (void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
+   printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
+       __FUNCTION__ , ## args))
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
index d38ade5..e8d83de 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -251,6 +251,20 @@ ixgb_set_tso(struct net_device *netdev, 
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
+
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
 
 static int 
@@ -714,6 +728,8 @@ static struct ethtool_ops ixgb_ethtool_o
 	.set_tx_csum = ixgb_set_tx_csum,
 	.get_sg	= ethtool_op_get_sg,
 	.set_sg	= ethtool_op_set_sg,
+	.get_msglevel = ixgb_get_msglevel,
+	.set_msglevel = ixgb_set_msglevel,
 #ifdef NETIF_F_TSO
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ixgb_set_tso,
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 0b9481a..6f8fd6f 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -148,6 +148,11 @@ MODULE_DESCRIPTION("Intel(R) PRO/10GbE N
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
@@ -248,19 +253,20 @@ ixgb_up(struct ixgb_adapter *adapter)
 
 	if (!pcix)
 	   adapter->have_msi = FALSE;
-	else if((err = pci_enable_msi(adapter->pdev))) {
-		printk (KERN_ERR
+	else if ((err = pci_enable_msi(adapter->pdev))) {
+		DPRINTK(PROBE, ERR,
 		 "Unable to allocate MSI interrupt Error: %d\n", err);
 		adapter->have_msi = FALSE;
 		/* proceed to try to request regular interrupt */
 	}
-	}
 
 #endif
-	if((err = request_irq(adapter->pdev->irq, &ixgb_intr,
-				  SA_SHIRQ | SA_SAMPLE_RANDOM,
-				  netdev->name, netdev)))
+	if ((err = request_irq(adapter->pdev->irq, &ixgb_intr,
+		 SA_SHIRQ | SA_SAMPLE_RANDOM, netdev->name, netdev))) {
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate interrupt Error: %d\n", err);		 
 		return err;
+	}
 
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
@@ -326,7 +332,7 @@ ixgb_reset(struct ixgb_adapter *adapter)
 
 	ixgb_adapter_stop(&adapter->hw);
 	if(!ixgb_init_hw(&adapter->hw))
-		IXGB_DBG("ixgb_init_hw failed.\n");
+		DPRINTK(PROBE, ERR, "ixgb_init_hw failed.\n");
 }
 
 /**
@@ -363,7 +369,7 @@ ixgb_probe(struct pci_dev *pdev,
 	} else {
 		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
 		   (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
-			IXGB_ERR("No usable DMA configuration, aborting\n");
+			DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
 		}
 		pci_using_dac = 0;
@@ -388,6 +394,7 @@ ixgb_probe(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
@@ -456,7 +463,7 @@ ixgb_probe(struct pci_dev *pdev,
 	/* make sure the EEPROM is good */
 
 	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
-		printk(KERN_ERR "The EEPROM Checksum Is Not Valid\n");
+		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -464,7 +471,8 @@ ixgb_probe(struct pci_dev *pdev,
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
-	if(!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
+		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -478,6 +486,7 @@ ixgb_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->tx_timeout_task,
 		  (void (*)(void *))ixgb_tx_timeout_task, netdev);
 
+	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev)))
 		goto err_register;
 
@@ -486,8 +495,7 @@ ixgb_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	printk(KERN_INFO "%s: Intel(R) PRO/10GbE Network Connection\n",
-		   netdev->name);
+	DPRINTK(PROBE, INFO, "Intel(R) PRO/10GbE Network Connection\n");
 	ixgb_check_options(adapter);
 	/* reset the hardware with the new settings */
 
@@ -567,7 +575,7 @@ ixgb_sw_init(struct ixgb_adapter *adapte
 			hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
-		printk(KERN_ERR "ixgb: unsupported device id\n");
+		DPRINTK(PROBE, ERR, "unsupported device id\n");
 	}
 
 	/* enable flow control to be programmed */
@@ -665,6 +673,8 @@ ixgb_setup_tx_resources(struct ixgb_adap
 	size = sizeof(struct ixgb_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if(!txdr->buffer_info) {
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -677,6 +687,8 @@ ixgb_setup_tx_resources(struct ixgb_adap
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if(!txdr->desc) {
 		vfree(txdr->buffer_info);
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate transmit descriptor memory\n");
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -750,6 +762,8 @@ ixgb_setup_rx_resources(struct ixgb_adap
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if(!rxdr->buffer_info) {
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -763,6 +777,8 @@ ixgb_setup_rx_resources(struct ixgb_adap
 
 	if(!rxdr->desc) {
 		vfree(rxdr->buffer_info);
+		DPRINTK(PROBE, ERR,
+		 "Unable to allocate receive descriptors\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -1112,8 +1128,8 @@ ixgb_watchdog(unsigned long data)
 
 	if(adapter->hw.link_up) {
 		if(!netif_carrier_ok(netdev)) {
-			printk(KERN_INFO "ixgb: %s NIC Link is Up %d Mbps %s\n",
-				   netdev->name, 10000, "Full Duplex");
+			DPRINTK(LINK, INFO,
+			 "NIC Link is Up 10000 Mbps Full Duplex\n");
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
 			netif_carrier_on(netdev);
@@ -1123,9 +1139,7 @@ ixgb_watchdog(unsigned long data)
 		if(netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			printk(KERN_INFO
-				   "ixgb: %s NIC Link is Down\n",
-				   netdev->name);
+			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 
@@ -1486,7 +1500,7 @@ ixgb_change_mtu(struct net_device *netde
 
 	if((max_frame < IXGB_MIN_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH)
 	   || (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
-		IXGB_ERR("Invalid MTU setting\n");
+		DPRINTK(PROBE, ERR, "Invalid MTU setting %d\n", new_mtu);
 		return -EINVAL;
 	}
 

