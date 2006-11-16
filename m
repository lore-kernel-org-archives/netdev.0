From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.19][TG3]: Disable TSO on 5906 if CLKREQ is enabled.
Date: Wed, 15 Nov 2006 21:57:47 -0800
Message-ID: <1163656668.8530.2.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:54288 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1161829AbWKPFF0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 00:05:26 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Disable TSO on 5906 if CLKREQ is enabled.

Due to hardware errata, TSO must be disabled if the PCI Express clock
request is enabled on 5906.  The chip may hang when transmitting TSO
frames if CLKREQ is enabled.

Update version to 3.69.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6e86866..1dbdd6b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@ #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.68"
-#define DRV_MODULE_RELDATE	"November 02, 2006"
+#define DRV_MODULE_VERSION	"3.69"
+#define DRV_MODULE_RELDATE	"November 15, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -10366,7 +10366,7 @@ static int __devinit tg3_get_invariants(
 	u32 pci_state_reg, grc_misc_cfg;
 	u32 val;
 	u16 pci_cmd;
-	int err;
+	int err, pcie_cap;
 
 	/* Force memory write invalidate off.  If we leave it on,
 	 * then on 5700_BX chips we have to enable a workaround.
@@ -10541,8 +10541,19 @@ static int __devinit tg3_get_invariants(
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
 		tp->tg3_flags2 |= TG3_FLG2_JUMBO_CAPABLE;
 
-	if (pci_find_capability(tp->pdev, PCI_CAP_ID_EXP) != 0)
+	pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
+	if (pcie_cap != 0) {
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+			u16 lnkctl;
+
+			pci_read_config_word(tp->pdev,
+					     pcie_cap + PCI_EXP_LNKCTL,
+					     &lnkctl);
+			if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN)
+				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
+		}
+	}
 
 	/* If we have an AMD 762 or VIA K8T800 chipset, write
 	 * reordering to the mailbox registers done by the host
@@ -11809,6 +11820,7 @@ #if TG3_TSO_SUPPORT != 0
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5705_A0 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
 	    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0) {
 		tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
 	} else {
diff --git a/include/linux/pci_regs.h b/include/linux/pci_regs.h
index c312a12..c321316 100644
--- a/include/linux/pci_regs.h
+++ b/include/linux/pci_regs.h
@@ -371,6 +371,7 @@ #define  PCI_EXP_DEVSTA_AUXPD	0x10	/* AU
 #define  PCI_EXP_DEVSTA_TRPND	0x20	/* Transactions Pending */
 #define PCI_EXP_LNKCAP		12	/* Link Capabilities */
 #define PCI_EXP_LNKCTL		16	/* Link Control */
+#define  PCI_EXP_LNKCTL_CLKREQ_EN 0x100	/* Enable clkreq */
 #define PCI_EXP_LNKSTA		18	/* Link Status */
 #define PCI_EXP_SLTCAP		20	/* Slot Capabilities */
 #define PCI_EXP_SLTCTL		24	/* Slot Control */


