From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/20] tg3: Add AC131 power down support
Date: Mon, 2 Nov 2009 16:26:38 -0800
Message-ID: <1257211997.22004@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1278 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757596AbZKCBd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AC131 does not respect the power down bit (bit 11) of the MII
Control Register (reg 0x0).  Instead, software is required to put the
phy into standby power down mode through the shadow register set.  This
patch implements support for the AC131 standby power down mode.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   20 ++++++++++++++++++++
 drivers/net/tg3.h |    3 +++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a43ef2b..003ab53 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2149,6 +2149,26 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 		tw32_f(GRC_MISC_CFG, val | GRC_MISC_CFG_EPHY_IDDQ);
 		udelay(40);
 		return;
+	} else if (tp->tg3_flags3 & TG3_FLG3_PHY_IS_FET) {
+		u32 phytest;
+		if (!tg3_readphy(tp, MII_TG3_FET_TEST, &phytest)) {
+			u32 phy;
+
+			tg3_writephy(tp, MII_ADVERTISE, 0);
+			tg3_writephy(tp, MII_BMCR,
+				     BMCR_ANENABLE | BMCR_ANRESTART);
+
+			tg3_writephy(tp, MII_TG3_FET_TEST,
+				     phytest | MII_TG3_FET_SHADOW_EN);
+			if (!tg3_readphy(tp, MII_TG3_FET_SHDW_AUXMODE4, &phy)) {
+				phy |= MII_TG3_FET_SHDW_AUXMODE4_SBPD;
+				tg3_writephy(tp,
+					     MII_TG3_FET_SHDW_AUXMODE4,
+					     phy);
+			}
+			tg3_writephy(tp, MII_TG3_FET_TEST, phytest);
+		}
+		return;
 	} else if (do_low_power) {
 		tg3_writephy(tp, MII_TG3_EXT_CTRL,
 			     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 68431da..9999345 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2080,6 +2080,9 @@
 #define MII_TG3_FET_SHDW_MISCCTRL	0x10
 #define  MII_TG3_FET_SHDW_MISCCTRL_MDIX	0x4000
 
+#define MII_TG3_FET_SHDW_AUXMODE4	0x1a
+#define MII_TG3_FET_SHDW_AUXMODE4_SBPD	0x0008
+
 #define MII_TG3_FET_SHDW_AUXSTAT2	0x1b
 #define  MII_TG3_FET_SHDW_AUXSTAT2_APD	0x0020
 
-- 
1.6.4.4


