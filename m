From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/11] tg3: Fix 5719 A0 tx completion bug
Date: Tue, 25 Jan 2011 17:58:48 -0800
Message-ID: <1296007137-23146-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1765 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476Ab1AZB7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5719 A0 has a bug that manifests itself as if the chipset were
reordering memory writes.  The best known way to solve this problem is
to turn off LSO and jumbo frames.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   12 ++++++++----
 drivers/net/tg3.h |    1 +
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 07d4e61..8756f31 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8108,8 +8108,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* Program the jumbo buffer descriptor ring control
 	 * blocks on those devices that have them.
 	 */
-	if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0 ||
+	    ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))) {
 		/* Setup replenish threshold. */
 		tw32(RCVBDI_JUMBO_THRESH, tp->rx_jumbo_pending / 8);
 
@@ -13329,7 +13330,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	/* Determine TSO capabilities */
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5719_A0)
+		; /* Do nothing. HW bug. */
+	else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_3;
 	else if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
@@ -13380,7 +13383,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags3 |= TG3_FLG3_40BIT_DMA_LIMIT_BUG;
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
+	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+	    tp->pci_chip_rev_id != CHIPREV_ID_5719_A0)
 		tp->tg3_flags3 |= TG3_FLG3_USE_JUMBO_BDFLAG;
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 0a0987a..52ae644 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -141,6 +141,7 @@
 #define  CHIPREV_ID_57780_A1		 0x57780001
 #define  CHIPREV_ID_5717_A0		 0x05717000
 #define  CHIPREV_ID_57765_A0		 0x57785000
+#define  CHIPREV_ID_5719_A0		 0x05719000
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
-- 
1.7.2.2


