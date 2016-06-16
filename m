From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 2/3] r8152: reset the bmu
Date: Thu, 16 Jun 2016 10:55:18 +0800
Message-ID: <1394712342-15778-181-Taiwan-albertk@realtek.com>
References: <1394712342-15778-179-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-179-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Reset the BMU to clear the rx/tx fifo. This avoids that the unexpected
data remains in the hw.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 89dc752..f5bc351 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -116,6 +116,7 @@
 #define USB_TX_DMA		0xd434
 #define USB_TOLERANCE		0xd490
 #define USB_LPM_CTRL		0xd41a
+#define USB_BMU_RESET		0xd4b0
 #define USB_UPS_CTRL		0xd800
 #define USB_MISC_0		0xd81a
 #define USB_POWER_CUT		0xd80a
@@ -338,6 +339,10 @@
 #define TEST_MODE_DISABLE	0x00000001
 #define TX_SIZE_ADJUST1		0x00000100
 
+/* USB_BMU_RESET */
+#define BMU_RESET_EP_IN		0x01
+#define BMU_RESET_EP_OUT	0x02
+
 /* USB_UPS_CTRL */
 #define POWER_CUT		0x0100
 
@@ -2456,6 +2461,17 @@ static void r8153_teredo_off(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TEREDO_TIMER, 0);
 }
 
+static void rtl_reset_bmu(struct r8152 *tp)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_BMU_RESET);
+	ocp_data &= ~(BMU_RESET_EP_IN | BMU_RESET_EP_OUT);
+	ocp_write_byte(tp, MCU_TYPE_USB, USB_BMU_RESET, ocp_data);
+	ocp_data |= BMU_RESET_EP_IN | BMU_RESET_EP_OUT;
+	ocp_write_byte(tp, MCU_TYPE_USB, USB_BMU_RESET, ocp_data);
+}
+
 static void r8152_aldps_en(struct r8152 *tp, bool enable)
 {
 	if (enable) {
@@ -2681,6 +2697,7 @@ static void r8153_first_init(struct r8152 *tp)
 	r8153_hw_phy_cfg(tp);
 
 	rtl8152_nic_reset(tp);
+	rtl_reset_bmu(tp);
 
 	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 	ocp_data &= ~NOW_IS_OOB;
@@ -2742,6 +2759,7 @@ static void r8153_enter_oob(struct r8152 *tp)
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL, ocp_data);
 
 	rtl_disable(tp);
+	rtl_reset_bmu(tp);
 
 	for (i = 0; i < 1000; i++) {
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
@@ -2803,6 +2821,7 @@ static void rtl8153_disable(struct r8152 *tp)
 {
 	r8153_aldps_en(tp, false);
 	rtl_disable(tp);
+	rtl_reset_bmu(tp);
 	r8153_aldps_en(tp, true);
 	usb_enable_lpm(tp->udev);
 }
-- 
2.4.11

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
