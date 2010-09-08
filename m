From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000: fix Tx hangs by disabling 64-bit DMA
Date: Wed, 08 Sep 2010 00:01:12 -0700
Message-ID: <20100908065835.315.15437.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:41638 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399Ab0IHHBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:01:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Several users report issues with 32-bit adapters when plugged
into PCI slots in machines with >= 4GB ram.  In particular AMD
systems with HyperTransport to PCI bridges seem to trigger the
issue, but it isn't limited to only them.

This issue is not easily reproducible here, yet still continues
to occur in the field.  For e1000 on PCI devices, just disable DMA
addresses over the 4GB boundary when in PCI (not PCI-X) mode, to
prevent the issue from continuing to pop up.  The performance
impact for this is negligible.

The code was refactored to move the init of the hw struct to its
own function. This allows the init to be called very early in
probe, which then allows using hw-> members for this fix.

A slight refactor to the DMA mask code was done for minor
correctness based on the instructions in DMA-API-HOWTO.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |  162 +++++++++++++++++++++++-----------------
 1 files changed, 92 insertions(+), 70 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 17f5867..8d9269d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -790,6 +790,70 @@ static const struct net_device_ops e1000_netdev_ops = {
 };
 
 /**
+ * e1000_init_hw_struct - initialize members of hw struct
+ * @adapter: board private struct
+ * @hw: structure used by e1000_hw.c
+ *
+ * Factors out initialization of the e1000_hw struct to its own function
+ * that can be called very early at init (just after struct allocation).
+ * Fields are initialized based on PCI device information and
+ * OS network device settings (MTU size).
+ * Returns negative error codes if MAC type setup fails.
+ */
+static int e1000_init_hw_struct(struct e1000_adapter *adapter,
+				struct e1000_hw *hw)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	/* PCI config space info */
+	hw->vendor_id = pdev->vendor;
+	hw->device_id = pdev->device;
+	hw->subsystem_vendor_id = pdev->subsystem_vendor;
+	hw->subsystem_id = pdev->subsystem_device;
+	hw->revision_id = pdev->revision;
+
+	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
+
+	hw->max_frame_size = adapter->netdev->mtu +
+			     ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
+	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
+
+	/* identify the MAC */
+	if (e1000_set_mac_type(hw)) {
+		e_err(probe, "Unknown MAC Type\n");
+		return -EIO;
+	}
+
+	switch (hw->mac_type) {
+	default:
+		break;
+	case e1000_82541:
+	case e1000_82547:
+	case e1000_82541_rev_2:
+	case e1000_82547_rev_2:
+		hw->phy_init_script = 1;
+		break;
+	}
+
+	e1000_set_media_type(hw);
+	e1000_get_bus_info(hw);
+
+	hw->wait_autoneg_complete = false;
+	hw->tbi_compatibility_en = true;
+	hw->adaptive_ifs = true;
+
+	/* Copper options */
+
+	if (hw->media_type == e1000_media_type_copper) {
+		hw->mdix = AUTO_ALL_MODES;
+		hw->disable_polarity_correction = false;
+		hw->master_slave = E1000_MASTER_SLAVE;
+	}
+
+	return 0;
+}
+
+/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -826,22 +890,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		return err;
 
-	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
-	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
-	} else {
-		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
-		if (err) {
-			err = dma_set_coherent_mask(&pdev->dev,
-						    DMA_BIT_MASK(32));
-			if (err) {
-				pr_err("No usable DMA config, aborting\n");
-				goto err_dma;
-			}
-		}
-		pci_using_dac = 0;
-	}
-
 	err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
 	if (err)
 		goto err_pci_reg;
@@ -885,6 +933,32 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		}
 	}
 
+	/* make ready for any if (hw->...) below */
+	err = e1000_init_hw_struct(adapter, hw);
+	if (err)
+		goto err_sw_init;
+
+	/*
+	 * there is a workaround being applied below that limits
+	 * 64-bit DMA addresses to 64-bit hardware.  There are some
+	 * 32-bit adapters that Tx hang when given 64-bit DMA addresses
+	 */
+	pci_using_dac = 0;
+	if ((hw->bus_type == e1000_bus_type_pcix) &&
+	    !dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
+		/*
+		 * according to DMA-API-HOWTO, coherent calls will always
+		 * succeed if the set call did
+		 */
+		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
+		pci_using_dac = 1;
+	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
+		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
+	} else {
+		pr_err("No usable DMA config, aborting\n");
+		goto err_dma;
+	}
+
 	netdev->netdev_ops = &e1000_netdev_ops;
 	e1000_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
@@ -959,8 +1033,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (!is_valid_ether_addr(netdev->perm_addr))
 		e_err(probe, "Invalid MAC Address\n");
 
-	e1000_get_bus_info(hw);
-
 	init_timer(&adapter->tx_fifo_stall_timer);
 	adapter->tx_fifo_stall_timer.function = e1000_82547_tx_fifo_stall;
 	adapter->tx_fifo_stall_timer.data = (unsigned long)adapter;
@@ -1072,6 +1144,7 @@ err_eeprom:
 		iounmap(hw->flash_address);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
+err_dma:
 err_sw_init:
 	iounmap(hw->hw_addr);
 err_ioremap:
@@ -1079,7 +1152,6 @@ err_ioremap:
 err_alloc_etherdev:
 	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
-err_dma:
 	pci_disable_device(pdev);
 	return err;
 }
@@ -1131,62 +1203,12 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
  * @adapter: board private structure to initialize
  *
  * e1000_sw_init initializes the Adapter private data structure.
- * Fields are initialized based on PCI device information and
- * OS network device settings (MTU size).
+ * e1000_init_hw_struct MUST be called before this function
  **/
 
 static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 {
-	struct e1000_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-
-	/* PCI config space info */
-
-	hw->vendor_id = pdev->vendor;
-	hw->device_id = pdev->device;
-	hw->subsystem_vendor_id = pdev->subsystem_vendor;
-	hw->subsystem_id = pdev->subsystem_device;
-	hw->revision_id = pdev->revision;
-
-	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
-
 	adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
-	hw->max_frame_size = netdev->mtu +
-			     ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
-
-	/* identify the MAC */
-
-	if (e1000_set_mac_type(hw)) {
-		e_err(probe, "Unknown MAC Type\n");
-		return -EIO;
-	}
-
-	switch (hw->mac_type) {
-	default:
-		break;
-	case e1000_82541:
-	case e1000_82547:
-	case e1000_82541_rev_2:
-	case e1000_82547_rev_2:
-		hw->phy_init_script = 1;
-		break;
-	}
-
-	e1000_set_media_type(hw);
-
-	hw->wait_autoneg_complete = false;
-	hw->tbi_compatibility_en = true;
-	hw->adaptive_ifs = true;
-
-	/* Copper options */
-
-	if (hw->media_type == e1000_media_type_copper) {
-		hw->mdix = AUTO_ALL_MODES;
-		hw->disable_polarity_correction = false;
-		hw->master_slave = E1000_MASTER_SLAVE;
-	}
 
 	adapter->num_tx_queues = 1;
 	adapter->num_rx_queues = 1;

