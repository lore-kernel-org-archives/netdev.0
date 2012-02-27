From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next] tg3: Recode PCI MRRS adjustment as a PCI quirk
Date: Mon, 27 Feb 2012 11:44:48 -0800
Message-ID: <1330371888-29237-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4172 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753965Ab2B0Tpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 14:45:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch recodes the MRRS cap for 5719 A0 devices as a PCI quirk.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 ------
 drivers/pci/quirks.c                |   18 ++++++++++++++++++
 include/linux/pci_ids.h             |    1 +
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 97dcccd..bdd6ff1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14218,12 +14218,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		tg3_flag_set(tp, PCI_EXPRESS);
 
-		if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0) {
-			int readrq = pcie_get_readrq(tp->pdev);
-			if (readrq > 2048)
-				pcie_set_readrq(tp->pdev, 2048);
-		}
-
 		pci_read_config_word(tp->pdev,
 				     pci_pcie_cap(tp->pdev) + PCI_EXP_LNKCTL,
 				     &lnkctl);
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 6476547..f722c5f 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -2161,6 +2161,24 @@ DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_BROADCOM,
 			PCI_DEVICE_ID_NX2_5709S,
 			quirk_brcm_570x_limit_vpd);
 
+static void __devinit quirk_brcm_5719_limit_mrrs(struct pci_dev *dev)
+{
+	u32 rev;
+
+	pci_read_config_dword(dev, 0xf4, &rev);
+
+	/* Only CAP the MRRS if the device is a 5719 A0 */
+	if (rev == 0x05719000) {
+		int readrq = pcie_get_readrq(dev);
+		if (readrq > 2048)
+			pcie_set_readrq(dev, 2048);
+	}
+}
+
+DECLARE_PCI_FIXUP_ENABLE(PCI_VENDOR_ID_BROADCOM,
+			 PCI_DEVICE_ID_TIGON3_5719,
+			 quirk_brcm_5719_limit_mrrs);
+
 /* Originally in EDAC sources for i82875P:
  * Intel tells BIOS developers to hide device 6 which
  * configures the overflow device access containing
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 31d77af..3329965 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2105,6 +2105,7 @@
 #define PCI_DEVICE_ID_NX2_57711E	0x1650
 #define PCI_DEVICE_ID_TIGON3_5705	0x1653
 #define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
+#define PCI_DEVICE_ID_TIGON3_5719	0x1657
 #define PCI_DEVICE_ID_TIGON3_5721	0x1659
 #define PCI_DEVICE_ID_TIGON3_5722	0x165a
 #define PCI_DEVICE_ID_TIGON3_5723	0x165b
-- 
1.7.3.4
