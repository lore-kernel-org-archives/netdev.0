From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 02/10] tg3: Qualify use of tp->pcix_cap
Date: Fri, 21 Nov 2008 11:00:04 -0800
Message-ID: <1227295575.5614@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1317 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754534AbYKUT0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes sure the device is a PCIX device before attempting to
use the pcix_cap device structure member.  This is prep work for the
following patch.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   50 ++++++++++++++++++++++++--------------------------
 1 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0a82ea8..821e381 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5876,7 +5876,7 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	}
 
 	/* Make sure PCI-X relaxed ordering bit is clear. */
-	if (tp->pcix_cap) {
+	if (tp->tg3_flags & TG3_FLAG_PCIX_MODE) {
 		u16 pcix_cmd;
 
 		pci_read_config_word(tp->pdev, tp->pcix_cap + PCI_X_CMD,
@@ -12190,6 +12190,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	     (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_JUMBO_CAPABLE;
 
+	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
+			      &pci_state_reg);
+
 	pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
 	if (pcie_cap != 0) {
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
@@ -12205,8 +12208,20 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN)
 				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
 		}
-	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
 		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
+	} else if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
+		   (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+		tp->pcix_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_PCIX);
+		if (!tp->pcix_cap) {
+			printk(KERN_ERR PFX "Cannot find PCI-X "
+					    "capability, aborting.\n");
+			return -EIO;
+		}
+
+		if (!(pci_state_reg & PCISTATE_CONV_PCI_MODE))
+			tp->tg3_flags |= TG3_FLAG_PCIX_MODE;
+	}
 
 	/* If we have an AMD 762 or VIA K8T800 chipset, write
 	 * reordering to the mailbox registers done by the host
@@ -12231,29 +12246,18 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				       cacheline_sz_reg);
 	}
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
-		tp->pcix_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_PCIX);
-		if (!tp->pcix_cap) {
-			printk(KERN_ERR PFX "Cannot find PCI-X "
-					    "capability, aborting.\n");
-			return -EIO;
-		}
-	}
-
-	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
-			      &pci_state_reg);
-
-	if (tp->pcix_cap && (pci_state_reg & PCISTATE_CONV_PCI_MODE) == 0) {
-		tp->tg3_flags |= TG3_FLAG_PCIX_MODE;
+	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5700_BX) {
+		/* 5700 BX chips need to have their TX producer index
+		 * mailboxes written twice to workaround a bug.
+		 */
+		tp->tg3_flags |= TG3_FLAG_TXD_MBOX_HWBUG;
 
-		/* If this is a 5700 BX chipset, and we are in PCI-X
-		 * mode, enable register write workaround.
+		/* If we are in PCI-X mode, enable register write workaround.
 		 *
 		 * The workaround is to use indirect register accesses
 		 * for all chip writes not to mailbox registers.
 		 */
-		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5700_BX) {
+		if (tp->tg3_flags & TG3_FLAG_PCIX_MODE) {
 			u32 pm_reg;
 
 			tp->tg3_flags |= TG3_FLAG_PCIX_TARGET_HWBUG;
@@ -12278,12 +12282,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
-	/* 5700 BX chips need to have their TX producer index mailboxes
-	 * written twice to workaround a bug.
-	 */
-	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5700_BX)
-		tp->tg3_flags |= TG3_FLAG_TXD_MBOX_HWBUG;
-
 	if ((pci_state_reg & PCISTATE_BUS_SPEED_HIGH) != 0)
 		tp->tg3_flags |= TG3_FLAG_PCI_HIGH_SPEED;
 	if ((pci_state_reg & PCISTATE_BUS_32BIT) != 0)
-- 
1.5.6.4



