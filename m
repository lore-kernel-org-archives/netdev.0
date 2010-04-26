From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: failure to enable mwi should not be fatal
Date: Mon, 26 Apr 2010 23:42:06 +0200
Message-ID: <20100426214206.GA7624@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Conrad Kostecki <conikost@gmx.de>,
	David Dillow <dave@thedillows.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 97.17.115-78.rev.gaoland.net ([78.115.17.97]:54234 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754805Ab0DZVw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 17:52:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few (6) network drivers enable mwi explicitly. Fewer worry about a
failure.

It is not a fix but it should avoid some annoyance like
http://bugzilla.kernel.org/show_bug.cgi?id=15454

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Conrad Kostecki <conikost@gmx.de>
---
 drivers/net/r8169.c |   27 +++++++++++++--------------
 1 files changed, 13 insertions(+), 14 deletions(-)


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dbb1f5a..2b54389 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2759,6 +2759,7 @@ static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 {
 	iounmap(ioaddr);
 	pci_release_regions(pdev);
+	pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
 	free_netdev(dev);
 }
@@ -3014,9 +3015,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_dev_1;
 	}
 
-	rc = pci_set_mwi(pdev);
-	if (rc < 0)
-		goto err_out_disable_2;
+	if (pci_set_mwi(pdev) < 0)
+		netif_info(tp, probe, dev, "Mem-Wr-Inval unavailable\n");
 
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
@@ -3024,7 +3024,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			  "region #%d not an MMIO resource, aborting\n",
 			  region);
 		rc = -ENODEV;
-		goto err_out_mwi_3;
+		goto err_out_mwi_2;
 	}
 
 	/* check for weird/broken PCI region reporting */
@@ -3032,13 +3032,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netif_err(tp, probe, dev,
 			  "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
-		goto err_out_mwi_3;
+		goto err_out_mwi_2;
 	}
 
 	rc = pci_request_regions(pdev, MODULENAME);
 	if (rc < 0) {
 		netif_err(tp, probe, dev, "could not request regions\n");
-		goto err_out_mwi_3;
+		goto err_out_mwi_2;
 	}
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
@@ -3051,7 +3051,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
 			netif_err(tp, probe, dev, "DMA configuration failed\n");
-			goto err_out_free_res_4;
+			goto err_out_free_res_3;
 		}
 	}
 
@@ -3060,7 +3060,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!ioaddr) {
 		netif_err(tp, probe, dev, "cannot remap MMIO, aborting\n");
 		rc = -EIO;
-		goto err_out_free_res_4;
+		goto err_out_free_res_3;
 	}
 
 	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
@@ -3102,7 +3102,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (i == ARRAY_SIZE(rtl_chip_info)) {
 		dev_err(&pdev->dev,
 			"driver bug, MAC version not found in rtl_chip_info\n");
-		goto err_out_msi_5;
+		goto err_out_msi_4;
 	}
 	tp->chipset = i;
 
@@ -3167,7 +3167,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_msi_5;
+		goto err_out_msi_4;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -3190,14 +3190,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
-err_out_msi_5:
+err_out_msi_4:
 	rtl_disable_msi(pdev, tp);
 	iounmap(ioaddr);
-err_out_free_res_4:
+err_out_free_res_3:
 	pci_release_regions(pdev);
-err_out_mwi_3:
+err_out_mwi_2:
 	pci_clear_mwi(pdev);
-err_out_disable_2:
 	pci_disable_device(pdev);
 err_out_free_dev_1:
 	free_netdev(dev);
-- 
1.6.6.1

