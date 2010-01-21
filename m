From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/10] tg3: Abort phy init for 5717 serdes
 devices
Date: Wed, 20 Jan 2010 18:58:05 -0800
Message-ID: <1264042691-28284-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1730 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663Ab0AUC61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717 serdes devices have a different phy register layout than all
other previous serdes devices.  This patch aborts the phy init sequence
in tg3_phy_reset() if the device is a 5717 serdes.  It also aborts the
tg3_phy_toggle_apd() operation.  Most other operations in the MII_SERDES
path are O.K.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4a65347..7a36bf4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1560,7 +1560,9 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 {
 	u32 reg;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
+		(GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+	     (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)))
 		return;
 
 	if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
@@ -1935,6 +1937,10 @@ static int tg3_phy_reset(struct tg3 *tp)
 		}
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+	    (tp->tg3_flags2 & TG3_FLG2_MII_SERDES))
+		return 0;
+
 	tg3_phy_apply_otp(tp);
 
 	if (tp->tg3_flags3 & TG3_FLG3_PHY_ENABLE_APD)
-- 
1.6.4.4


