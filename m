From: Brandon Philips <bphilips@suse.de>
Subject: [PATCH] e1000e: Update e1000e driver to use devres
Date: Fri, 17 Aug 2007 13:25:02 -0700
Message-ID: <20070817202502.GD4525@ifup.org>
References: <20070815190014.GE7294@ifup.org> <46C43891.4080304@suse.de> <46C48B2E.9040105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <teheo@suse.de>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43776 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbXHQUZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 16:25:11 -0400
Content-Disposition: inline
In-Reply-To: <46C48B2E.9040105@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Conversion of e1000e probe() and remove() to devres.

Depends on "[patch 1/4] Update net core to use devres."

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 drivers/net/e1000e/netdev.c |   70 ++++++++++----------------------------------
 1 file changed, 17 insertions(+), 53 deletions(-)

Index: linux-netdev/drivers/net/e1000e/netdev.c
===================================================================
--- linux-netdev.orig/drivers/net/e1000e/netdev.c
+++ linux-netdev/drivers/net/e1000e/netdev.c
@@ -2516,6 +2516,7 @@ void e1000e_reinit_locked(struct e1000_a
 static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
 
 	adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN;
@@ -2523,11 +2524,13 @@ static int __devinit e1000_sw_init(struc
 	hw->mac.max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	hw->mac.min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
-	adapter->tx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	adapter->tx_ring = devm_kzalloc(&pdev->dev,
+					sizeof(struct e1000_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
 		goto err;
 
-	adapter->rx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	adapter->rx_ring = devm_kzalloc(&pdev->dev,
+					sizeof(struct e1000_ring), GFP_KERNEL);
 	if (!adapter->rx_ring)
 		goto err;
 
@@ -2544,8 +2547,6 @@ static int __devinit e1000_sw_init(struc
 
 err:
 	ndev_err(netdev, "Unable to allocate memory for queues\n");
-	kfree(adapter->rx_ring);
-	kfree(adapter->tx_ring);
 	return -ENOMEM;
 }
 
@@ -4016,15 +4017,13 @@ static int __devinit e1000_probe(struct 
 	struct e1000_adapter *adapter;
 	struct e1000_hw *hw;
 	const struct e1000_info *ei = e1000_info_tbl[ent->driver_data];
-	unsigned long mmio_start, mmio_len;
-	unsigned long flash_start, flash_len;
 
 	static int cards_found;
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 
-	err = pci_enable_device(pdev);
+	err = pcim_enable_device(pdev);
 	if (err)
 		return err;
 
@@ -4042,21 +4041,20 @@ static int __devinit e1000_probe(struct 
 			if (err) {
 				dev_err(&pdev->dev, "No usable DMA "
 					"configuration, aborting\n");
-				goto err_dma;
+				return err;
 			}
 		}
 	}
 
 	err = pci_request_regions(pdev, e1000e_driver_name);
 	if (err)
-		goto err_pci_reg;
+		return err;
 
 	pci_set_master(pdev);
 
-	err = -ENOMEM;
-	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
+	netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct e1000_adapter));
 	if (!netdev)
-		goto err_alloc_etherdev;
+		return -ENOMEM;
 
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -4073,21 +4071,16 @@ static int __devinit e1000_probe(struct 
 	adapter->hw.mac.type = ei->mac;
 	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
 
-	mmio_start = pci_resource_start(pdev, 0);
-	mmio_len = pci_resource_len(pdev, 0);
 
-	err = -EIO;
-	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
+	adapter->hw.hw_addr = pcim_iomap(pdev, 0, 0);
 	if (!adapter->hw.hw_addr)
-		goto err_ioremap;
+		return -EIO;
 
 	if ((adapter->flags & FLAG_HAS_FLASH) &&
 	    (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		flash_start = pci_resource_start(pdev, 1);
-		flash_len = pci_resource_len(pdev, 1);
-		adapter->hw.flash_address = ioremap(flash_start, flash_len);
+		adapter->hw.flash_address = pcim_iomap(pdev, 1, 0);
 		if (!adapter->hw.flash_address)
-			goto err_flashmap;
+			return -EIO;
 	}
 
 	/* construct the net_device struct */
@@ -4112,17 +4105,15 @@ static int __devinit e1000_probe(struct 
 #endif
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
-	netdev->mem_start = mmio_start;
-	netdev->mem_end = mmio_start + mmio_len;
+	netdev->mem_start = pci_resource_start(pdev, 0);
+	netdev->mem_end = netdev->mem_start + pci_resource_len(pdev, 0);
 
 	adapter->bd_number = cards_found++;
 
 	/* setup adapter struct */
 	err = e1000_sw_init(adapter);
 	if (err)
-		goto err_sw_init;
-
-	err = -EIO;
+		return err;
 
 	memcpy(&hw->mac.ops, ei->mac_ops, sizeof(hw->mac.ops));
 	memcpy(&hw->nvm.ops, ei->nvm_ops, sizeof(hw->nvm.ops));
@@ -4290,21 +4281,6 @@ err_eeprom:
 	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
 
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
-
-err_flashmap:
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
-err_sw_init:
-	iounmap(adapter->hw.hw_addr);
-err_ioremap:
-	free_netdev(netdev);
-err_alloc_etherdev:
-	pci_release_regions(pdev);
-err_pci_reg:
-err_dma:
-	pci_disable_device(pdev);
 	return err;
 }
 
@@ -4340,18 +4316,6 @@ static void __devexit e1000_remove(struc
 
 	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
-
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
-
-	iounmap(adapter->hw.hw_addr);
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
-
-	free_netdev(netdev);
-
-	pci_disable_device(pdev);
 }
 
 /* PCI Error Recovery (ERS) */
