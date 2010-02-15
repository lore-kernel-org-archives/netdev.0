From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/7] drivers/net/ixgb: Use
	netif_printk macros
Date: Mon, 15 Feb 2010 10:34:20 -0800
Message-ID: <ea7ea7a2239206a7e794e49e2a45ba94b6dc0ac7.1266258417.git.joe@perches.com>
References: <cover.1266258417.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1266258417.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert private DPRINTK macro uses to netif_<level> equivalents
Remove #define DPRINTK

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgb/ixgb.h      |   11 +----
 drivers/net/ixgb/ixgb_main.c |   89 ++++++++++++++++++++++-------------------
 2 files changed, 51 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 5257ae0..92d2e71 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -75,19 +75,14 @@ struct ixgb_adapter;
 #include "ixgb_ee.h"
 #include "ixgb_ids.h"
 
+#define PFX "ixgb: "
+
 #ifdef _DEBUG_DRIVER_
-#define IXGB_DBG(args...) printk(KERN_DEBUG "ixgb: " args)
+#define IXGB_DBG(args...) printk(KERN_DEBUG PFX args)
 #else
 #define IXGB_DBG(args...)
 #endif
 
-#define PFX "ixgb: "
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__func__ , ## args))
-
-
 /* TX/RX descriptor defines */
 #define DEFAULT_TXD      256
 #define MAX_TXD         4096
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6a7b2cc..93d0185 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -238,8 +238,8 @@ ixgb_up(struct ixgb_adapter *adapter)
 	if (err) {
 		if (adapter->have_msi)
 			pci_disable_msi(adapter->pdev);
-		DPRINTK(PROBE, ERR,
-		 "Unable to allocate interrupt Error: %d\n", err);
+		netif_err(adapter, probe, adapter->netdev,
+			  "Unable to allocate interrupt Error: %d\n", err);
 		return err;
 	}
 
@@ -310,7 +310,7 @@ ixgb_reset(struct ixgb_adapter *adapter)
 
 	ixgb_adapter_stop(hw);
 	if (!ixgb_init_hw(hw))
-		DPRINTK(PROBE, ERR, "ixgb_init_hw failed.\n");
+		netif_err(adapter, probe, adapter->netdev, "ixgb_init_hw failed\n");
 
 	/* restore frame size information */
 	IXGB_WRITE_REG(hw, MFS, hw->max_frame_size << IXGB_MFS_SHIFT);
@@ -447,7 +447,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* make sure the EEPROM is good */
 
 	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
-		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "The EEPROM Checksum Is Not Valid\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -456,7 +457,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
+		netif_err(adapter, probe, adapter->netdev, "Invalid MAC Address\n");
 		err = -EIO;
 		goto err_eeprom;
 	}
@@ -477,7 +478,8 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
-	DPRINTK(PROBE, INFO, "Intel(R) PRO/10GbE Network Connection\n");
+	netif_info(adapter, probe, adapter->netdev,
+		   "Intel(R) PRO/10GbE Network Connection\n");
 	ixgb_check_options(adapter);
 	/* reset the hardware with the new settings */
 
@@ -552,14 +554,14 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 	adapter->rx_buffer_len = hw->max_frame_size + 8; /* + 8 for errata */
 
-	if ((hw->device_id == IXGB_DEVICE_ID_82597EX)
-	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4)
-	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_LR)
-	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
+	if ((hw->device_id == IXGB_DEVICE_ID_82597EX) ||
+	    (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4) ||
+	    (hw->device_id == IXGB_DEVICE_ID_82597EX_LR) ||
+	    (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
 		hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
-		DPRINTK(PROBE, ERR, "unsupported device id\n");
+		netif_err(adapter, probe, adapter->netdev, "unsupported device id\n");
 	}
 
 	/* enable flow control to be programmed */
@@ -661,8 +663,8 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	size = sizeof(struct ixgb_buffer) * txdr->count;
 	txdr->buffer_info = vmalloc(size);
 	if (!txdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
-		 "Unable to allocate transmit descriptor ring memory\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "Unable to allocate transmit descriptor ring memory\n");
 		return -ENOMEM;
 	}
 	memset(txdr->buffer_info, 0, size);
@@ -675,8 +677,8 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
 	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
-		DPRINTK(PROBE, ERR,
-		 "Unable to allocate transmit descriptor memory\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "Unable to allocate transmit descriptor memory\n");
 		return -ENOMEM;
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -750,8 +752,8 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 	size = sizeof(struct ixgb_buffer) * rxdr->count;
 	rxdr->buffer_info = vmalloc(size);
 	if (!rxdr->buffer_info) {
-		DPRINTK(PROBE, ERR,
-		 "Unable to allocate receive descriptor ring\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "Unable to allocate receive descriptor ring\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->buffer_info, 0, size);
@@ -765,8 +767,8 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 
 	if (!rxdr->desc) {
 		vfree(rxdr->buffer_info);
-		DPRINTK(PROBE, ERR,
-		 "Unable to allocate receive descriptors\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "Unable to allocate receive descriptors\n");
 		return -ENOMEM;
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -1580,7 +1582,8 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 	/* MTU < 68 is an error for IPv4 traffic, just don't allow it */
 	if ((new_mtu < 68) ||
 	    (max_frame > IXGB_MAX_JUMBO_FRAME_SIZE + ENET_FCS_LENGTH)) {
-		DPRINTK(PROBE, ERR, "Invalid MTU setting %d\n", new_mtu);
+		netif_err(adapter, probe, adapter->netdev,
+			  "Invalid MTU setting %d\n", new_mtu);
 		return -EINVAL;
 	}
 
@@ -1854,24 +1857,25 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
 		        IXGB_STATUS_TXOFF)) {
 			/* detected Tx unit hang */
-			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
-					"  TDH                  <%x>\n"
-					"  TDT                  <%x>\n"
-					"  next_to_use          <%x>\n"
-					"  next_to_clean        <%x>\n"
-					"buffer_info[next_to_clean]\n"
-					"  time_stamp           <%lx>\n"
-					"  next_to_watch        <%x>\n"
-					"  jiffies              <%lx>\n"
-					"  next_to_watch.status <%x>\n",
-				IXGB_READ_REG(&adapter->hw, TDH),
-				IXGB_READ_REG(&adapter->hw, TDT),
-				tx_ring->next_to_use,
-				tx_ring->next_to_clean,
-				tx_ring->buffer_info[eop].time_stamp,
-				eop,
-				jiffies,
-				eop_desc->status);
+			netif_err(adapter, drv, adapter->netdev,
+				  "Detected Tx Unit Hang\n"
+				  "  TDH                  <%x>\n"
+				  "  TDT                  <%x>\n"
+				  "  next_to_use          <%x>\n"
+				  "  next_to_clean        <%x>\n"
+				  "buffer_info[next_to_clean]\n"
+				  "  time_stamp           <%lx>\n"
+				  "  next_to_watch        <%x>\n"
+				  "  jiffies              <%lx>\n"
+				  "  next_to_watch.status <%x>\n",
+				  IXGB_READ_REG(&adapter->hw, TDH),
+				  IXGB_READ_REG(&adapter->hw, TDT),
+				  tx_ring->next_to_use,
+				  tx_ring->next_to_clean,
+				  tx_ring->buffer_info[eop].time_stamp,
+				  eop,
+				  jiffies,
+				  eop_desc->status);
 			netif_stop_queue(netdev);
 		}
 	}
@@ -2269,7 +2273,8 @@ static pci_ers_result_t ixgb_io_slot_reset(struct pci_dev *pdev)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
-		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "Cannot re-enable PCI device after reset\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
@@ -2285,14 +2290,16 @@ static pci_ers_result_t ixgb_io_slot_reset(struct pci_dev *pdev)
 
 	/* Make sure the EEPROM is good */
 	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
-		DPRINTK(PROBE, ERR, "After reset, the EEPROM checksum is not valid.\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "After reset, the EEPROM checksum is not valid\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
-		DPRINTK(PROBE, ERR, "After reset, invalid MAC address.\n");
+		netif_err(adapter, probe, adapter->netdev,
+			  "After reset, invalid MAC address\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
-- 
1.7.0.14.g7e948


------------------------------------------------------------------------------
SOLARIS 10 is the OS for Data Centers - provides features such as DTrace,
Predictive Self Healing and Award Winning ZFS. Get Solaris 10 NOW
http://p.sf.net/sfu/solaris-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
