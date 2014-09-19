From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: disable ALDPS
Date: Fri, 19 Sep 2014 15:17:18 +0800
Message-ID: <1394712342-15778-44-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the hw is in ALDPS mode, the hw may have no response for accessing
the most registers. Therefore, the ALDPS should be disabled before
accessing the hw in rtl_ops.init(), rtl_ops.disable(), rtl_ops.up(),
and rtl_ops.down(). Regardless of rtl_ops.enable(), because the hw
wouldn't enter ALDPS mode when linking on. The hw would enter the
ALDPS mode after several seconds when link down occurs and the ALDPS
is enabled.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 62 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 45 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 87f7104..74760e8 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2019,7 +2019,7 @@ static int rtl8153_enable(struct r8152 *tp)
 	return rtl_enable(tp);
 }
 
-static void rtl8152_disable(struct r8152 *tp)
+static void rtl_disable(struct r8152 *tp)
 {
 	u32 ocp_data;
 	int i;
@@ -2232,6 +2232,13 @@ static inline void r8152b_enable_aldps(struct r8152 *tp)
 					    LINKENA | DIS_SDSAVE);
 }
 
+static void rtl8152_disable(struct r8152 *tp)
+{
+	r8152b_disable_aldps(tp);
+	rtl_disable(tp);
+	r8152b_enable_aldps(tp);
+}
+
 static void r8152b_hw_phy_cfg(struct r8152 *tp)
 {
 	u16 data;
@@ -2242,11 +2249,8 @@ static void r8152b_hw_phy_cfg(struct r8152 *tp)
 		r8152_mdio_write(tp, MII_BMCR, data);
 	}
 
-	r8152b_disable_aldps(tp);
-
 	rtl_clear_bp(tp);
 
-	r8152b_enable_aldps(tp);
 	set_bit(PHY_RESET, &tp->flags);
 }
 
@@ -2255,9 +2259,6 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
-	if (test_bit(RTL8152_UNPLUG, &tp->flags))
-		return;
-
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data &= ~RCR_ACPT_ALL;
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
@@ -2347,7 +2348,7 @@ static void r8152b_enter_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL1, RXFIFO_THR2_OOB);
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL2, RXFIFO_THR3_OOB);
 
-	rtl8152_disable(tp);
+	rtl_disable(tp);
 
 	for (i = 0; i < 1000; i++) {
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
@@ -2485,9 +2486,6 @@ static void r8153_first_init(struct r8152 *tp)
 	u32 ocp_data;
 	int i;
 
-	if (test_bit(RTL8152_UNPLUG, &tp->flags))
-		return;
-
 	rxdy_gated_en(tp, true);
 	r8153_teredo_off(tp);
 
@@ -2560,7 +2558,7 @@ static void r8153_enter_oob(struct r8152 *tp)
 	ocp_data &= ~NOW_IS_OOB;
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL, ocp_data);
 
-	rtl8152_disable(tp);
+	rtl_disable(tp);
 
 	for (i = 0; i < 1000; i++) {
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
@@ -2624,6 +2622,13 @@ static void r8153_enable_aldps(struct r8152 *tp)
 	ocp_reg_write(tp, OCP_POWER_CFG, data);
 }
 
+static void rtl8153_disable(struct r8152 *tp)
+{
+	r8153_disable_aldps(tp);
+	rtl_disable(tp);
+	r8153_enable_aldps(tp);
+}
+
 static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 {
 	u16 bmcr, anar, gbcr;
@@ -2714,6 +2719,16 @@ out:
 	return ret;
 }
 
+static void rtl8152_up(struct r8152 *tp)
+{
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
+	r8152b_disable_aldps(tp);
+	r8152b_exit_oob(tp);
+	r8152b_enable_aldps(tp);
+}
+
 static void rtl8152_down(struct r8152 *tp)
 {
 	if (test_bit(RTL8152_UNPLUG, &tp->flags)) {
@@ -2727,6 +2742,16 @@ static void rtl8152_down(struct r8152 *tp)
 	r8152b_enable_aldps(tp);
 }
 
+static void rtl8153_up(struct r8152 *tp)
+{
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
+	r8153_disable_aldps(tp);
+	r8153_first_init(tp);
+	r8153_enable_aldps(tp);
+}
+
 static void rtl8153_down(struct r8152 *tp)
 {
 	if (test_bit(RTL8152_UNPLUG, &tp->flags)) {
@@ -2946,6 +2971,8 @@ static void r8152b_init(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
+	r8152b_disable_aldps(tp);
+
 	if (tp->version == RTL_VER_01) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE);
 		ocp_data &= ~LED_MODE_MASK;
@@ -2984,6 +3011,7 @@ static void r8153_init(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
+	r8153_disable_aldps(tp);
 	r8153_u1u2en(tp, false);
 
 	for (i = 0; i < 500; i++) {
@@ -3392,7 +3420,7 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->init		= r8152b_init;
 			ops->enable		= rtl8152_enable;
 			ops->disable		= rtl8152_disable;
-			ops->up			= r8152b_exit_oob;
+			ops->up			= rtl8152_up;
 			ops->down		= rtl8152_down;
 			ops->unload		= rtl8152_unload;
 			ret = 0;
@@ -3400,8 +3428,8 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 		case PRODUCT_ID_RTL8153:
 			ops->init		= r8153_init;
 			ops->enable		= rtl8153_enable;
-			ops->disable		= rtl8152_disable;
-			ops->up			= r8153_first_init;
+			ops->disable		= rtl8153_disable;
+			ops->up			= rtl8153_up;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
 			ret = 0;
@@ -3416,8 +3444,8 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 		case PRODUCT_ID_SAMSUNG:
 			ops->init		= r8153_init;
 			ops->enable		= rtl8153_enable;
-			ops->disable		= rtl8152_disable;
-			ops->up			= r8153_first_init;
+			ops->disable		= rtl8153_disable;
+			ops->up			= rtl8153_up;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
 			ret = 0;
-- 
1.9.3
