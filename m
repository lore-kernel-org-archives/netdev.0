From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 09/13] tg3: Move TSO_CAPABLE assignment
Date: Thu, 19 May 2011 15:12:52 -0700
Message-ID: <1305843176-32358-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1127 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934964Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the code that asserts the TSO_CAPABLE flag closer to
where the TSO capabilities flags are set.  There isn't a good enough
reason for the code to be separated.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 574fe97..09fe067 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13639,6 +13639,21 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tp->fw_needed = FIRMWARE_TG3TSO;
 	}
 
+	/* Selectively allow TSO based on operating conditions */
+	if ((tg3_flag(tp, HW_TSO_1) ||
+	     tg3_flag(tp, HW_TSO_2) ||
+	     tg3_flag(tp, HW_TSO_3)) ||
+	    (tp->fw_needed && !tg3_flag(tp, ENABLE_ASF)))
+		tg3_flag_set(tp, TSO_CAPABLE);
+	else {
+		tg3_flag_clear(tp, TSO_CAPABLE);
+		tg3_flag_clear(tp, TSO_BUG);
+		tp->fw_needed = NULL;
+	}
+
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0)
+		tp->fw_needed = FIRMWARE_TG3;
+
 	tp->irq_max = 1;
 
 	if (tg3_flag(tp, 5750_PLUS)) {
@@ -13705,6 +13720,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN) {
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 				tg3_flag_clear(tp, HW_TSO_2);
+				tg3_flag_clear(tp, TSO_CAPABLE);
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A0 ||
@@ -15044,21 +15060,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_bufmgr_config(tp);
 
-	/* Selectively allow TSO based on operating conditions */
-	if ((tg3_flag(tp, HW_TSO_1) ||
-	     tg3_flag(tp, HW_TSO_2) ||
-	     tg3_flag(tp, HW_TSO_3)) ||
-	    (tp->fw_needed && !tg3_flag(tp, ENABLE_ASF)))
-		tg3_flag_set(tp, TSO_CAPABLE);
-	else {
-		tg3_flag_clear(tp, TSO_CAPABLE);
-		tg3_flag_clear(tp, TSO_BUG);
-		tp->fw_needed = NULL;
-	}
-
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0)
-		tp->fw_needed = FIRMWARE_TG3;
-
 	/* TSO is on by default on chips that support hardware TSO.
 	 * Firmware TSO on older chips gives lower performance, so it
 	 * is off by default, but can be enabled using ethtool.
-- 
1.7.3.4


