From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/20] tg3: Refine TSO and MSI discovery
Date: Fri, 13 Nov 2009 15:03:37 -0800
Message-ID: <1258153432-7036-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4587 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932461AbZKMXES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch consolidates the TSO capability discovery code into its own
code block.  The code that decides whether or not to allow TSO is then
cleaned up.  Finally, the patch consolidates all MSI and MSIX
capability code into a single code block.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   64 ++++++++++++++++++++++++++++------------------------
 1 files changed, 34 insertions(+), 30 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f74d80d..29276e6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12669,6 +12669,27 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tp->dev->features |= NETIF_F_IPV6_CSUM;
 	}
 
+	/* Determine TSO capabilities */
+	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
+	else if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
+		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 | TG3_FLG2_TSO_BUG;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 &&
+		    tp->pci_chip_rev_id >= CHIPREV_ID_5750_C2)
+			tp->tg3_flags2 &= ~TG3_FLG2_TSO_BUG;
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
+		   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701 &&
+		   tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
+		tp->tg3_flags2 |= TG3_FLG2_TSO_BUG;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
+			tp->fw_needed = FIRMWARE_TG3TSO5;
+		else
+			tp->fw_needed = FIRMWARE_TG3TSO;
+	}
+
+	tp->irq_max = 1;
+
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
 		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSI;
 		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_AX ||
@@ -12680,22 +12701,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
-		} else {
-			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 | TG3_FLG2_TSO_BUG;
-			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
-				ASIC_REV_5750 &&
-	     		    tp->pci_chip_rev_id >= CHIPREV_ID_5750_C2)
-				tp->tg3_flags2 &= ~TG3_FLG2_TSO_BUG;
 		}
-	}
-
-	tp->irq_max = 1;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
-		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSIX;
-		tp->irq_max = TG3_IRQ_MAX_VECS;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+			tp->tg3_flags |= TG3_FLAG_SUPPORT_MSIX;
+			tp->irq_max = TG3_IRQ_MAX_VECS;
+		}
 	}
 
 	if (!(tp->tg3_flags3 & TG3_FLG3_5755_PLUS)) {
@@ -14108,25 +14120,17 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_bufmgr_config(tp);
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0)
-		tp->fw_needed = FIRMWARE_TG3;
-
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
+	/* Selectively allow TSO based on operating conditions */
+	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
+	    (tp->fw_needed && !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)))
 		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+	else {
+		tp->tg3_flags2 &= ~(TG3_FLG2_TSO_CAPABLE | TG3_FLG2_TSO_BUG);
+		tp->fw_needed = NULL;
 	}
-	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5705_A0 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
-	    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0) {
-		tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
-	} else {
-		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE | TG3_FLG2_TSO_BUG;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
-			tp->fw_needed = FIRMWARE_TG3TSO5;
-		else
-			tp->fw_needed = FIRMWARE_TG3TSO;
-	}
+
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0)
+		tp->fw_needed = FIRMWARE_TG3;
 
 	/* TSO is on by default on chips that support hardware TSO.
 	 * Firmware TSO on older chips gives lower performance, so it
-- 
1.6.4.4


