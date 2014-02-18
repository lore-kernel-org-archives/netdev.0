From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 01/14] r8152: move some functions
Date: Tue, 18 Feb 2014 21:48:58 +0800
Message-ID: <1392731351-25502-2-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the following functions which is for the further coding.
 - rtl_clear_bp
 - r8153_clear_bp
 - r8153_teredo_off
 - r8152b_disable_aldps
 - r8152b_enable_aldps
 - r8152b_hw_phy_cfg

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 106 ++++++++++++++++++++++++------------------------
 1 file changed, 53 insertions(+), 53 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d89dbe3..f042a85 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1721,6 +1721,59 @@ static void rtl8152_disable(struct r8152 *tp)
 	rtl8152_nic_reset(tp);
 }
 
+static void rtl_clear_bp(struct r8152 *tp)
+{
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_0, 0);
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_2, 0);
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_4, 0);
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_6, 0);
+	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_0, 0);
+	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_2, 0);
+	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_4, 0);
+	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_6, 0);
+	mdelay(3);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_BP_BA, 0);
+	ocp_write_word(tp, MCU_TYPE_USB, USB_BP_BA, 0);
+}
+
+static void r8153_clear_bp(struct r8152 *tp)
+{
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_BP_EN, 0);
+	ocp_write_byte(tp, MCU_TYPE_USB, USB_BP_EN, 0);
+	rtl_clear_bp(tp);
+}
+
+static void r8153_teredo_off(struct r8152 *tp)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG);
+	ocp_data &= ~(TEREDO_SEL | TEREDO_RS_EVENT_MASK | OOB_TEREDO_EN);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG, ocp_data);
+
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_WDT6_CTRL, WDT6_SET_MODE);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_REALWOW_TIMER, 0);
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TEREDO_TIMER, 0);
+}
+
+static void r8152b_disable_aldps(struct r8152 *tp)
+{
+	ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPDNPS | LINKENA | DIS_SDSAVE);
+	msleep(20);
+}
+
+static inline void r8152b_enable_aldps(struct r8152 *tp)
+{
+	ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPWRSAVE | ENPDNPS |
+					    LINKENA | DIS_SDSAVE);
+}
+
+static void r8152b_hw_phy_cfg(struct r8152 *tp)
+{
+	r8152_mdio_write(tp, MII_BMCR, BMCR_ANENABLE);
+	r8152b_disable_aldps(tp);
+}
+
 static void r8152b_exit_oob(struct r8152 *tp)
 {
 	u32	ocp_data;
@@ -1865,18 +1918,6 @@ static void r8152b_enter_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 }
 
-static void r8152b_disable_aldps(struct r8152 *tp)
-{
-	ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPDNPS | LINKENA | DIS_SDSAVE);
-	msleep(20);
-}
-
-static inline void r8152b_enable_aldps(struct r8152 *tp)
-{
-	ocp_reg_write(tp, OCP_ALDPS_CONFIG, ENPWRSAVE | ENPDNPS |
-					    LINKENA | DIS_SDSAVE);
-}
-
 static void r8153_hw_phy_cfg(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -1961,19 +2002,6 @@ static void r8153_power_cut_en(struct r8152 *tp, int enable)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_MISC_0, ocp_data);
 }
 
-static void r8153_teredo_off(struct r8152 *tp)
-{
-	u32 ocp_data;
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG);
-	ocp_data &= ~(TEREDO_SEL | TEREDO_RS_EVENT_MASK | OOB_TEREDO_EN);
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG, ocp_data);
-
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_WDT6_CTRL, WDT6_SET_MODE);
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_REALWOW_TIMER, 0);
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TEREDO_TIMER, 0);
-}
-
 static void r8153_first_init(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -2308,28 +2336,6 @@ static int rtl8152_close(struct net_device *netdev)
 	return res;
 }
 
-static void rtl_clear_bp(struct r8152 *tp)
-{
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_0, 0);
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_2, 0);
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_4, 0);
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_6, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_0, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_2, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_4, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_6, 0);
-	mdelay(3);
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_BP_BA, 0);
-	ocp_write_word(tp, MCU_TYPE_USB, USB_BP_BA, 0);
-}
-
-static void r8153_clear_bp(struct r8152 *tp)
-{
-	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_BP_EN, 0);
-	ocp_write_byte(tp, MCU_TYPE_USB, USB_BP_EN, 0);
-	rtl_clear_bp(tp);
-}
-
 static void r8152b_enable_eee(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -2378,12 +2384,6 @@ static void r8152b_enable_fc(struct r8152 *tp)
 	r8152_mdio_write(tp, MII_ADVERTISE, anar);
 }
 
-static void r8152b_hw_phy_cfg(struct r8152 *tp)
-{
-	r8152_mdio_write(tp, MII_BMCR, BMCR_ANENABLE);
-	r8152b_disable_aldps(tp);
-}
-
 static void r8152b_init(struct r8152 *tp)
 {
 	u32 ocp_data;
-- 
1.8.4.2
