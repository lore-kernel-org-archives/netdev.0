From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/5] tg3: Add reliable serdes detection for 5717 A0
Date: Tue, 12 Jan 2010 12:11:38 -0800
Message-ID: <1263327100-13554-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1094 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754176Ab0ALUMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 15:12:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The serdes status bit does not work as intended for the 5717 A0.
This patch implements an alternative detection scheme that will only be
valid for A0 revisions.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    9 +++++++--
 drivers/net/tg3.h |    2 ++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4e8b87d..0a632f9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1037,7 +1037,11 @@ static void tg3_mdio_start(struct tg3 *tp)
 		else
 			tp->phy_addr = 1;
 
-		is_serdes = tr32(SG_DIG_STATUS) & SG_DIG_IS_SERDES;
+		if (tp->pci_chip_rev_id != CHIPREV_ID_5717_A0)
+			is_serdes = tr32(SG_DIG_STATUS) & SG_DIG_IS_SERDES;
+		else
+			is_serdes = tr32(TG3_CPMU_PHY_STRAP) &
+				    TG3_CPMU_PHY_STRAP_IS_SERDES;
 		if (is_serdes)
 			tp->phy_addr += 7;
 	} else
@@ -12123,7 +12127,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 
 		tp->phy_id = eeprom_phy_id;
 		if (eeprom_phy_serdes) {
-			if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
+			if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 				tp->tg3_flags2 |= TG3_FLG2_MII_SERDES;
 			else
 				tp->tg3_flags2 |= TG3_FLG2_PHY_SERDES;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index cd30889..43ed41b 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1054,6 +1054,8 @@
 #define  CPMU_MUTEX_REQ_DRIVER		 0x00001000
 #define TG3_CPMU_MUTEX_GNT		0x00003660
 #define  CPMU_MUTEX_GNT_DRIVER		 0x00001000
+#define TG3_CPMU_PHY_STRAP		0x00003664
+#define TG3_CPMU_PHY_STRAP_IS_SERDES	 0x00000020
 /* 0x3664 --> 0x3800 unused */
 
 /* Mbuf cluster free registers */
-- 
1.6.4.4


