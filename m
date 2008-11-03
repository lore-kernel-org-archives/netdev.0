From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/15] tg3: Allow WOL for phylib controlled Broadcom
 phys
Date: Mon, 3 Nov 2008 02:13:31 -0800
Message-ID: <1225751626.6190@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4570 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756451AbYKCWd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows WOL to be enabled for Broadcom phys under phylib
control.  The only exception is the AC131, which has a completely
different register set.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   31 ++++++++++++++++++++++++-------
 drivers/net/tg3.h |   10 +++++++++-
 2 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e64721b..d0f314c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1963,7 +1963,7 @@ static int tg3_halt_cpu(struct tg3 *, u32);
 static int tg3_nvram_lock(struct tg3 *);
 static void tg3_nvram_unlock(struct tg3 *);
 
-static void tg3_power_down_phy(struct tg3 *tp)
+static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 {
 	u32 val;
 
@@ -1986,10 +1986,15 @@ static void tg3_power_down_phy(struct tg3 *tp)
 		tw32_f(GRC_MISC_CFG, val | GRC_MISC_CFG_EPHY_IDDQ);
 		udelay(40);
 		return;
-	} else if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
+	} else if (do_low_power) {
 		tg3_writephy(tp, MII_TG3_EXT_CTRL,
 			     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x01b2);
+
+		tg3_writephy(tp, MII_TG3_AUX_CTRL,
+			     MII_TG3_AUXCTL_SHDWSEL_PWRCTL |
+			     MII_TG3_AUXCTL_PCTL_100TX_LPWR |
+			     MII_TG3_AUXCTL_PCTL_SPR_ISOLATE |
+			     MII_TG3_AUXCTL_PCTL_VREG_11V);
 	}
 
 	/* The PHY should not be powered down on some chips because
@@ -2052,7 +2057,7 @@ static void __tg3_set_mac_addr(struct tg3 *tp, int skip_mac_1)
 static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 {
 	u32 misc_host_ctrl;
-	bool device_should_wake;
+	bool device_should_wake, do_low_power;
 
 	/* Make sure register accesses (indirect or otherwise)
 	 * will function correctly.
@@ -2091,10 +2096,11 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
 
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+		do_low_power = false;
 		if ((tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) &&
 		    !tp->link_config.phy_is_low_power) {
 			struct phy_device *phydev;
-			u32 advertising;
+			u32 phyid, advertising;
 
 			phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
@@ -2124,8 +2130,19 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			phydev->advertising = advertising;
 
 			phy_start_aneg(phydev);
+
+			phyid = phydev->drv->phy_id & phydev->drv->phy_id_mask;
+			if (phyid != TG3_PHY_ID_BCMAC131) {
+				phyid &= TG3_PHY_OUI_MASK;
+				if (phyid == TG3_PHY_OUI_1 &&
+				    phyid == TG3_PHY_OUI_2 &&
+				    phyid == TG3_PHY_OUI_3)
+					do_low_power = true;
+			}
 		}
 	} else {
+		do_low_power = false;
+
 		if (tp->link_config.phy_is_low_power == 0) {
 			tp->link_config.phy_is_low_power = 1;
 			tp->link_config.orig_speed = tp->link_config.speed;
@@ -2169,7 +2186,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		u32 mac_mode;
 
 		if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
-			if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
+			if (do_low_power) {
 				tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x5a);
 				udelay(40);
 			}
@@ -2277,7 +2294,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 	if (!(device_should_wake) &&
 	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
 	    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
-		tg3_power_down_phy(tp);
+		tg3_power_down_phy(tp, do_low_power);
 
 	tg3_frob_aux_power(tp);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 417de07..d7ce3a0 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1795,6 +1795,11 @@
 
 #define MII_TG3_AUX_CTRL		0x18 /* auxilliary control register */
 
+#define MII_TG3_AUXCTL_PCTL_100TX_LPWR	0x0010
+#define MII_TG3_AUXCTL_PCTL_SPR_ISOLATE	0x0020
+#define MII_TG3_AUXCTL_PCTL_VREG_11V	0x0180
+#define MII_TG3_AUXCTL_SHDWSEL_PWRCTL	0x0002
+
 #define MII_TG3_AUXCTL_MISC_WREN	0x8000
 #define MII_TG3_AUXCTL_MISC_FORCE_AMDIX	0x0200
 #define MII_TG3_AUXCTL_MISC_RDSEL_MISC	0x7000
@@ -2590,7 +2595,10 @@ struct tg3 {
 #define PHY_REV_BCM5411_X0		0x1 /* Found on Netgear GA302T */
 #define TG3_PHY_ID_BCM50610		0x143bd60
 #define TG3_PHY_ID_BCMAC131		0x143bc70
-
+#define TG3_PHY_OUI_MASK		0xfffffc00
+#define TG3_PHY_OUI_1			0x00206000
+#define TG3_PHY_OUI_2			0x0143bc00
+#define TG3_PHY_OUI_3			0x03625c00
 
 	u32				led_ctrl;
 	u32				phy_otp;
-- 
1.5.6.4



