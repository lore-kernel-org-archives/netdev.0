From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169: Add EEPROM support and disable MWI on pci express.
Date: Sun,  7 Feb 2016 19:38:57 +0200
Message-ID: <1454866737-2406-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-192.residential.rdsnet.ro ([5.14.227.192]:51395 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408AbcBGRjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 12:39:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On chip with external eeprom ASPM settings is loaded from eeprom and
   on pci express interface not support MWI.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1d119a6..bebd550 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -733,6 +733,7 @@ enum features {
 	RTL_FEATURE_WOL		= (1 << 0),
 	RTL_FEATURE_MSI		= (1 << 1),
 	RTL_FEATURE_GMII	= (1 << 2),
+	RTL_FEATURE_EEPROM	= (1 << 3),
 };
 
 struct rtl8169_counters {
@@ -4372,7 +4373,8 @@ static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 {
 	iounmap(ioaddr);
 	pci_release_regions(pdev);
-	pci_clear_mwi(pdev);
+	if (!pci_is_pcie(pdev))
+	 pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
 	free_netdev(dev);
 }
@@ -8042,7 +8044,7 @@ static const struct rtl_cfg_info {
 		.align		= 8,
 		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver |
 				  PCSTimeout | SWInt | TxDescUnavail,
-		.features	= RTL_FEATURE_MSI,
+		.features	= RTL_FEATURE_MSI | RTL_FEATURE_EEPROM,
 		.default_ver	= RTL_GIGA_MAC_VER_13,
 	}
 };
@@ -8151,6 +8153,7 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
 	const unsigned int region = cfg->region;
+	unsigned features = cfg->features;
 	struct rtl8169_private *tp;
 	struct mii_if_info *mii;
 	struct net_device *dev;
@@ -8186,8 +8189,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* disable ASPM completely as that cause random device stop working
 	 * problems as well as full system hangs for some PCIe devices users */
-	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
-				     PCIE_LINK_STATE_CLKPM);
+	if (!(features & RTL_FEATURE_EEPROM)) 
+		pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S |
+					PCIE_LINK_STATE_L1 |
+				     	PCIE_LINK_STATE_CLKPM);
 
 	mdelay(RTL8169_EE_TIMEOUT);
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
@@ -8196,10 +8201,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netif_err(tp, probe, dev, "enable failure\n");
 		goto err_out_free_dev_1;
 	}
-
-	if (pci_set_mwi(pdev) < 0)
+	if (!pci_is_pcie(pdev)) {
+	 if (pci_set_mwi(pdev) < 0)
 		netif_info(tp, probe, dev, "Mem-Wr-Inval unavailable\n");
-
+        }
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
 		netif_err(tp, probe, dev,
@@ -8462,7 +8467,8 @@ err_out_msi_4:
 err_out_free_res_3:
 	pci_release_regions(pdev);
 err_out_mwi_2:
-	pci_clear_mwi(pdev);
+        if (!pci_is_pcie(pdev))
+	 pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
 err_out_free_dev_1:
 	free_netdev(dev);
-- 
2.5.0
