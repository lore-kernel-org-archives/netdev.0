From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 03/26] e1000: e1000_probe resources cleanup
Date: Tue, 29 Aug 2006 09:44:20 -0700
Message-ID: <20060829164420.6872.43348.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:27658 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965075AbWH2QgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:07 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix resources cleanup in e1000_probe()

Signed-off-by: Vasily Averin <vvs@sw.ru>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   44 +++++++++++++++++++++++++---------------
 1 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 354d778..c273b45 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -695,21 +695,20 @@ e1000_probe(struct pci_dev *pdev,
 		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) &&
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
 			E1000_ERR("No usable DMA configuration, aborting\n");
-			return err;
+			goto err_dma;
 		}
 		pci_using_dac = 0;
 	}
 
 	if ((err = pci_request_regions(pdev, e1000_driver_name)))
-		return err;
+		goto err_pci_reg;
 
 	pci_set_master(pdev);
 
+	err = -ENOMEM;
 	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
-	if (!netdev) {
-		err = -ENOMEM;
+	if (!netdev)
 		goto err_alloc_etherdev;
-	}
 
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -724,11 +723,10 @@ e1000_probe(struct pci_dev *pdev,
 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
+	err = -EIO;
 	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
-	if (!adapter->hw.hw_addr) {
-		err = -EIO;
+	if (!adapter->hw.hw_addr)
 		goto err_ioremap;
-	}
 
 	for (i = BAR_1; i <= BAR_5; i++) {
 		if (pci_resource_len(pdev, i) == 0)
@@ -773,6 +771,7 @@ e1000_probe(struct pci_dev *pdev,
 	if ((err = e1000_sw_init(adapter)))
 		goto err_sw_init;
 
+	err = -EIO;
 	/* Flash BAR mapping must happen after e1000_sw_init
 	 * because it depends on mac_type */
 	if ((adapter->hw.mac_type == e1000_ich8lan) &&
@@ -780,13 +779,11 @@ e1000_probe(struct pci_dev *pdev,
 		flash_start = pci_resource_start(pdev, 1);
 		flash_len = pci_resource_len(pdev, 1);
 		adapter->hw.flash_address = ioremap(flash_start, flash_len);
-		if (!adapter->hw.flash_address) {
-			err = -EIO;
+		if (!adapter->hw.flash_address)
 			goto err_flashmap;
-		}
 	}
 
-	if ((err = e1000_check_phy_reset_block(&adapter->hw)))
+	if (e1000_check_phy_reset_block(&adapter->hw))
 		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
 	/* if ksp3, indicate if it's port a being setup */
@@ -829,7 +826,7 @@ e1000_probe(struct pci_dev *pdev,
 
 	if (e1000_init_eeprom_params(&adapter->hw)) {
 		E1000_ERR("EEPROM initialization failed\n");
-		return -EIO;
+		goto err_eeprom;
 	}
 
 	/* before reading the EEPROM, reset the controller to
@@ -841,7 +838,6 @@ e1000_probe(struct pci_dev *pdev,
 
 	if (e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
 		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
-		err = -EIO;
 		goto err_eeprom;
 	}
 
@@ -854,7 +850,6 @@ e1000_probe(struct pci_dev *pdev,
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
-		err = -EIO;
 		goto err_eeprom;
 	}
 
@@ -963,16 +958,33 @@ e1000_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+	e1000_release_hw_control(adapter);
+err_eeprom:
+	if (!e1000_check_phy_reset_block(&adapter->hw))
+		e1000_phy_hw_reset(&adapter->hw);
+
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
 err_flashmap:
+#ifdef CONFIG_E1000_NAPI
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		dev_put(&adapter->polling_netdev[i]);
+#endif
+
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+#ifdef CONFIG_E1000_NAPI
+	kfree(adapter->polling_netdev);
+#endif
 err_sw_init:
-err_eeprom:
 	iounmap(adapter->hw.hw_addr);
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
 	pci_release_regions(pdev);
+err_pci_reg:
+err_dma:
+	pci_disable_device(pdev);
 	return err;
 }
 



---
Auke Kok <auke-jan.h.kok@intel.com>
