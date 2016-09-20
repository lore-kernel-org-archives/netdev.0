From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 2/5] r8152: move enabling PHY
Date: Tue, 20 Sep 2016 16:22:06 +0800
Message-ID: <1394712342-15778-221-Taiwan-albertk@realtek.com>
References: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-219-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Move enabling PHY to init(), otherwise some other settings may fail.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 43 +++++++++++++++++++++++++------------------
 1 file changed, 25 insertions(+), 18 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ae7db46..dbf11ba 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2632,14 +2632,6 @@ static void rtl8152_disable(struct r8152 *tp)
 
 static void r8152b_hw_phy_cfg(struct r8152 *tp)
 {
-	u16 data;
-
-	data = r8152_mdio_read(tp, MII_BMCR);
-	if (data & BMCR_PDOWN) {
-		data &= ~BMCR_PDOWN;
-		r8152_mdio_write(tp, MII_BMCR, data);
-	}
-
 	set_bit(PHY_RESET, &tp->flags);
 }
 
@@ -2818,16 +2810,6 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 	u32 ocp_data;
 	u16 data;
 
-	if (tp->version == RTL_VER_03 || tp->version == RTL_VER_04 ||
-	    tp->version == RTL_VER_05)
-		ocp_reg_write(tp, OCP_ADC_CFG, CKADSEL_L | ADC_EN | EN_EMI_L);
-
-	data = r8152_mdio_read(tp, MII_BMCR);
-	if (data & BMCR_PDOWN) {
-		data &= ~BMCR_PDOWN;
-		r8152_mdio_write(tp, MII_BMCR, data);
-	}
-
 	if (tp->version == RTL_VER_03) {
 		data = ocp_reg_read(tp, OCP_EEE_CFG);
 		data &= ~CTAP_SHORT_EN;
@@ -3355,10 +3337,17 @@ static void rtl_tally_reset(struct r8152 *tp)
 static void r8152b_init(struct r8152 *tp)
 {
 	u32 ocp_data;
+	u16 data;
 
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
+	data = r8152_mdio_read(tp, MII_BMCR);
+	if (data & BMCR_PDOWN) {
+		data &= ~BMCR_PDOWN;
+		r8152_mdio_write(tp, MII_BMCR, data);
+	}
+
 	r8152_aldps_en(tp, false);
 
 	if (tp->version == RTL_VER_01) {
@@ -3394,6 +3383,7 @@ static void r8152b_init(struct r8152 *tp)
 static void r8153_init(struct r8152 *tp)
 {
 	u32 ocp_data;
+	u16 data;
 	int i;
 
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
@@ -3416,6 +3406,23 @@ static void r8153_init(struct r8152 *tp)
 		msleep(20);
 	}
 
+	if (tp->version == RTL_VER_03 || tp->version == RTL_VER_04 ||
+	    tp->version == RTL_VER_05)
+		ocp_reg_write(tp, OCP_ADC_CFG, CKADSEL_L | ADC_EN | EN_EMI_L);
+
+	data = r8152_mdio_read(tp, MII_BMCR);
+	if (data & BMCR_PDOWN) {
+		data &= ~BMCR_PDOWN;
+		r8152_mdio_write(tp, MII_BMCR, data);
+	}
+
+	for (i = 0; i < 500; i++) {
+		ocp_data = ocp_reg_read(tp, OCP_PHY_STATUS) & PHY_STAT_MASK;
+		if (ocp_data == PHY_STAT_LAN_ON)
+			break;
+		msleep(20);
+	}
+
 	usb_disable_lpm(tp->udev);
 	r8153_u2p3en(tp, false);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
