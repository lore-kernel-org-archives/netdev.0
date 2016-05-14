From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2] r8169: default to 64-bit DMA on recent PCIe chips
Date: Sat, 14 May 2016 22:40:15 +0200
Message-ID: <1463258415-31072-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: ricardo.salveti@linaro.org, leif.lindholm@linaro.org,
	graeme.gregory@linaro.org, amit.kucheria@linaro.org,
	davem@davemloft.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35156 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbcENUkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 16:40:21 -0400
Received: by mail-wm0-f50.google.com with SMTP id e201so59104565wme.0
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 13:40:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current logic around the 'use_dac' module parameter prevents the
r81969 driver from being loadable on 64-bit systems without any RAM
below 4 GB when the parameter is left at its default value.

So introduce a new default value -1 which indicates that 64-bit DMA
should be enabled on sufficiently recent PCIe chips, i.e., versions
RTL_GIGA_MAC_VER_18 or later. Explicit param values of 0 or 1 retain
the existing behavior of unconditionally enabling/disabling 64-bit DMA
on 64-bit architectures (i.e., regardless of the type and version of the
chip)

Since PCIe chips do not need to CPlusCmd Dual Address Cycle to be set,
make that conditional on the device type as well.

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
This is a followup to 'r8169: default to 64-bit DMA on systems without memory
below 4 GB' [1]. At the request of Francois, this version bases the decision
whether to use 64-bit DMA by default on whether the device is PCIe and
sufficiently recent, rather than whether the platform requires 64-bit DMA
because it does not have any memory below 4 GB to begin with. This is safer,
since it will prevent the use of such problematic cards on these platforms.

v2: drop unnecessary reordering of rtl8169_get_mac_version() call with pcie
    check

[1] http://article.gmane.org/gmane.linux.network/412246

 drivers/net/ethernet/realtek/r8169.c | 44 +++++++++++---------
 1 file changed, 25 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 94f08f1e841c..0e62d74b09b3 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -345,7 +345,7 @@ static const struct pci_device_id rtl8169_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_buf_sz = 16383;
-static int use_dac;
+static int use_dac = -1;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -8224,20 +8224,6 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_mwi_2;
 	}
 
-	tp->cp_cmd = 0;
-
-	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
-		tp->cp_cmd |= PCIDAC;
-		dev->features |= NETIF_F_HIGHDMA;
-	} else {
-		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
-		if (rc < 0) {
-			netif_err(tp, probe, dev, "DMA configuration failed\n");
-			goto err_out_free_res_3;
-		}
-	}
-
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
 	if (!ioaddr) {
@@ -8253,6 +8239,25 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
+	tp->cp_cmd = 0;
+
+	if ((sizeof(dma_addr_t) > 4) &&
+	    (use_dac == 1 || (use_dac == -1 && pci_is_pcie(pdev) &&
+			      tp->mac_version >= RTL_GIGA_MAC_VER_18)) &&
+	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
+
+		/* CPlusCmd Dual Access Cycle is only needed for non-PCIe */
+		if (!pci_is_pcie(pdev))
+			tp->cp_cmd |= PCIDAC;
+		dev->features |= NETIF_F_HIGHDMA;
+	} else {
+		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (rc < 0) {
+			netif_err(tp, probe, dev, "DMA configuration failed\n");
+			goto err_out_unmap_4;
+		}
+	}
+
 	rtl_init_rxcfg(tp);
 
 	rtl_irq_disable(tp);
@@ -8412,12 +8417,12 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 					   &tp->counters_phys_addr, GFP_KERNEL);
 	if (!tp->counters) {
 		rc = -ENOMEM;
-		goto err_out_msi_4;
+		goto err_out_msi_5;
 	}
 
 	rc = register_netdev(dev);
 	if (rc < 0)
-		goto err_out_cnt_5;
+		goto err_out_cnt_6;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -8451,12 +8456,13 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 out:
 	return rc;
 
-err_out_cnt_5:
+err_out_cnt_6:
 	dma_free_coherent(&pdev->dev, sizeof(*tp->counters), tp->counters,
 			  tp->counters_phys_addr);
-err_out_msi_4:
+err_out_msi_5:
 	netif_napi_del(&tp->napi);
 	rtl_disable_msi(pdev, tp);
+err_out_unmap_4:
 	iounmap(ioaddr);
 err_out_free_res_3:
 	pci_release_regions(pdev);
-- 
2.7.4
