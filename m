From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/2] r8152: adjust ALDPS function
Date: Thu, 7 Jan 2016 17:51:12 +0800
Message-ID: <1394712342-15778-173-Taiwan-albertk@realtek.com>
References: <1394712342-15778-171-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-171-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace disable_aldps() and enable_aldps() with aldps_en().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 72 +++++++++++++++++++++++--------------------------
 1 file changed, 34 insertions(+), 38 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4f0bb67..230c73c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2452,23 +2452,23 @@ static void r8153_teredo_off(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TEREDO_TIMER, 0);
 }
 
-static void r8152b_disable_aldps(struct r8152 *tp)
+static void r8152_aldps_en(struct r8152 *tp, bool enable)
 {
-	ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPDNPS | LINKENA | DIS_SDSAVE);
-	msleep(20);
-}
-
-static inline void r8152b_enable_aldps(struct r8152 *tp)
-{
-	ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPWRSAVE | ENPDNPS |
-					    LINKENA | DIS_SDSAVE);
+	if (enable) {
+		ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPWRSAVE | ENPDNPS |
+						    LINKENA | DIS_SDSAVE);
+	} else {
+		ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPDNPS | LINKENA |
+						    DIS_SDSAVE);
+		msleep(20);
+	}
 }
 
 static void rtl8152_disable(struct r8152 *tp)
 {
-	r8152b_disable_aldps(tp);
+	r8152_aldps_en(tp, false);
 	rtl_disable(tp);
-	r8152b_enable_aldps(tp);
+	r8152_aldps_en(tp, true);
 }
 
 static void r8152b_hw_phy_cfg(struct r8152 *tp)
@@ -2780,30 +2780,26 @@ static void r8153_enter_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 }
 
-static void r8153_disable_aldps(struct r8152 *tp)
+static void r8153_aldps_en(struct r8152 *tp, bool enable)
 {
 	u16 data;
 
 	data = ocp_reg_read(tp, OCP_POWER_CFG);
-	data &= ~EN_ALDPS;
-	ocp_reg_write(tp, OCP_POWER_CFG, data);
-	msleep(20);
-}
-
-static void r8153_enable_aldps(struct r8152 *tp)
-{
-	u16 data;
-
-	data = ocp_reg_read(tp, OCP_POWER_CFG);
-	data |= EN_ALDPS;
-	ocp_reg_write(tp, OCP_POWER_CFG, data);
+	if (enable) {
+		data |= EN_ALDPS;
+		ocp_reg_write(tp, OCP_POWER_CFG, data);
+	} else {
+		data &= ~EN_ALDPS;
+		ocp_reg_write(tp, OCP_POWER_CFG, data);
+		msleep(20);
+	}
 }
 
 static void rtl8153_disable(struct r8152 *tp)
 {
-	r8153_disable_aldps(tp);
+	r8153_aldps_en(tp, false);
 	rtl_disable(tp);
-	r8153_enable_aldps(tp);
+	r8153_aldps_en(tp, true);
 	usb_enable_lpm(tp->udev);
 }
 
@@ -2900,9 +2896,9 @@ static void rtl8152_up(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
-	r8152b_disable_aldps(tp);
+	r8152_aldps_en(tp, false);
 	r8152b_exit_oob(tp);
-	r8152b_enable_aldps(tp);
+	r8152_aldps_en(tp, true);
 }
 
 static void rtl8152_down(struct r8152 *tp)
@@ -2913,9 +2909,9 @@ static void rtl8152_down(struct r8152 *tp)
 	}
 
 	r8152_power_cut_en(tp, false);
-	r8152b_disable_aldps(tp);
+	r8152_aldps_en(tp, false);
 	r8152b_enter_oob(tp);
-	r8152b_enable_aldps(tp);
+	r8152_aldps_en(tp, true);
 }
 
 static void rtl8153_up(struct r8152 *tp)
@@ -2924,9 +2920,9 @@ static void rtl8153_up(struct r8152 *tp)
 		return;
 
 	r8153_u1u2en(tp, false);
-	r8153_disable_aldps(tp);
+	r8153_aldps_en(tp, false);
 	r8153_first_init(tp);
-	r8153_enable_aldps(tp);
+	r8153_aldps_en(tp, true);
 	r8153_u2p3en(tp, true);
 	r8153_u1u2en(tp, true);
 	usb_enable_lpm(tp->udev);
@@ -2942,9 +2938,9 @@ static void rtl8153_down(struct r8152 *tp)
 	r8153_u1u2en(tp, false);
 	r8153_u2p3en(tp, false);
 	r8153_power_cut_en(tp, false);
-	r8153_disable_aldps(tp);
+	r8153_aldps_en(tp, false);
 	r8153_enter_oob(tp);
-	r8153_enable_aldps(tp);
+	r8153_aldps_en(tp, true);
 }
 
 static bool rtl8152_in_nway(struct r8152 *tp)
@@ -3230,7 +3226,7 @@ static void r8152b_init(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
-	r8152b_disable_aldps(tp);
+	r8152_aldps_en(tp, false);
 
 	if (tp->version == RTL_VER_01) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE);
@@ -3252,7 +3248,7 @@ static void r8152b_init(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_GPHY_INTR_IMR, ocp_data);
 
 	r8152b_enable_eee(tp);
-	r8152b_enable_aldps(tp);
+	r8152_aldps_en(tp, true);
 	r8152b_enable_fc(tp);
 	rtl_tally_reset(tp);
 
@@ -3270,7 +3266,7 @@ static void r8153_init(struct r8152 *tp)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
-	r8153_disable_aldps(tp);
+	r8153_aldps_en(tp, false);
 	r8153_u1u2en(tp, false);
 
 	for (i = 0; i < 500; i++) {
@@ -3359,7 +3355,7 @@ static void r8153_init(struct r8152 *tp)
 		       EEE_SPDWN_EN);
 
 	r8153_enable_eee(tp);
-	r8153_enable_aldps(tp);
+	r8153_aldps_en(tp, true);
 	r8152b_enable_fc(tp);
 	rtl_tally_reset(tp);
 	r8153_u2p3en(tp, true);
-- 
2.4.3
