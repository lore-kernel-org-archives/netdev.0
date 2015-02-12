From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: restore hw settings
Date: Thu, 12 Feb 2015 16:20:46 +0800
Message-ID: <1394712342-15778-145-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a capability which let the hw could change the settings
automatically when the power change to ON. However, the USB reset
would reset the settings to the hw default, so the driver has to
restore the relative settings. Otherwise, it would influence the
functions of the hw, and the compatibility for the USB hub and
USB host controller.

The relative settings are as following.
 - set the power down scale to 96.
 - enable the power saving function of USB 2.0.
 - disable the ALDPS of ECM mode.
 - set burst mode depending on the burst size.
 - enable the flow control of endpoint full.
 - set fifo empty boundary to 32448 bytes.
 - enable the function of exiting LPM when Rx OK occurs.
 - set the connect timer to 1.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5980ac6..438fc6b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -40,6 +40,7 @@
 #define PLA_RXFIFO_CTRL0	0xc0a0
 #define PLA_RXFIFO_CTRL1	0xc0a4
 #define PLA_RXFIFO_CTRL2	0xc0a8
+#define PLA_DMY_REG0		0xc0b0
 #define PLA_FMC			0xc0b4
 #define PLA_CFG_WOL		0xc0b6
 #define PLA_TEREDO_CFG		0xc0bc
@@ -90,8 +91,14 @@
 #define PLA_BP_7		0xfc36
 #define PLA_BP_EN		0xfc38
 
+#define USB_USB2PHY		0xb41e
+#define USB_SSPHYLINK2		0xb428
 #define USB_U2P3_CTRL		0xb460
+#define USB_CSR_DUMMY1		0xb464
+#define USB_CSR_DUMMY2		0xb466
 #define USB_DEV_STAT		0xb808
+#define USB_CONNECT_TIMER	0xcbf8
+#define USB_BURST_SIZE		0xcfc0
 #define USB_USB_CTRL		0xd406
 #define USB_PHY_CTRL		0xd408
 #define USB_TX_AGG		0xd40a
@@ -170,6 +177,9 @@
 #define TXFIFO_THR_NORMAL	0x00400008
 #define TXFIFO_THR_NORMAL2	0x01000008
 
+/* PLA_DMY_REG0 */
+#define ECM_ALDPS		0x0002
+
 /* PLA_FMC */
 #define FMC_FCR_MCU_EN		0x0001
 
@@ -289,6 +299,20 @@
 /* PLA_BOOT_CTRL */
 #define AUTOLOAD_DONE		0x0002
 
+/* USB_USB2PHY */
+#define USB2PHY_SUSPEND		0x0001
+#define USB2PHY_L1		0x0002
+
+/* USB_SSPHYLINK2 */
+#define pwd_dn_scale_mask	0x3ffe
+#define pwd_dn_scale(x)		((x) << 1)
+
+/* USB_CSR_DUMMY1 */
+#define DYNAMIC_BURST		0x0001
+
+/* USB_CSR_DUMMY2 */
+#define EP4_FULL_FC		0x0001
+
 /* USB_DEV_STAT */
 #define STAT_SPEED_MASK		0x0006
 #define STAT_SPEED_HIGH		0x0000
@@ -334,9 +358,13 @@
 #define TIMER11_EN		0x0001
 
 /* USB_LPM_CTRL */
+/* bit 4 ~ 5: fifo empty boundary */
+#define FIFO_EMPTY_1FB		0x30	/* 0x1fb * 64 = 32448 bytes */
+/* bit 2 ~ 3: LMP timer */
 #define LPM_TIMER_MASK		0x0c
 #define LPM_TIMER_500MS		0x04	/* 500 ms */
 #define LPM_TIMER_500US		0x0c	/* 500 us */
+#define ROK_EXIT_LPM		0x02
 
 /* USB_AFE_CTRL2 */
 #define SEN_VAL_MASK		0xf800
@@ -3230,6 +3258,32 @@ static void r8153_init(struct r8152 *tp)
 
 	r8153_u2p3en(tp, false);
 
+	if (tp->version == RTL_VER_04) {
+		ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_SSPHYLINK2);
+		ocp_data &= ~pwd_dn_scale_mask;
+		ocp_data |= pwd_dn_scale(96);
+		ocp_write_word(tp, MCU_TYPE_USB, USB_SSPHYLINK2, ocp_data);
+
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_USB2PHY);
+		ocp_data |= USB2PHY_L1 | USB2PHY_SUSPEND;
+		ocp_write_byte(tp, MCU_TYPE_USB, USB_USB2PHY, ocp_data);
+	} else if (tp->version == RTL_VER_05) {
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_DMY_REG0);
+		ocp_data &= ~ECM_ALDPS;
+		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_DMY_REG0, ocp_data);
+
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY1);
+		if (ocp_read_word(tp, MCU_TYPE_USB, USB_BURST_SIZE) == 0)
+			ocp_data &= ~DYNAMIC_BURST;
+		else
+			ocp_data |= DYNAMIC_BURST;
+		ocp_write_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY1, ocp_data);
+	}
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY2);
+	ocp_data |= EP4_FULL_FC;
+	ocp_write_byte(tp, MCU_TYPE_USB, USB_CSR_DUMMY2, ocp_data);
+
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_WDT11_CTRL);
 	ocp_data &= ~TIMER11_EN;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_WDT11_CTRL, ocp_data);
@@ -3238,8 +3292,7 @@ static void r8153_init(struct r8152 *tp)
 	ocp_data &= ~LED_MODE_MASK;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE, ocp_data);
 
-	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_LPM_CTRL);
-	ocp_data &= ~LPM_TIMER_MASK;
+	ocp_data = FIFO_EMPTY_1FB | ROK_EXIT_LPM;
 	if (tp->version == RTL_VER_04 && tp->udev->speed != USB_SPEED_SUPER)
 		ocp_data |= LPM_TIMER_500MS;
 	else
@@ -3251,6 +3304,8 @@ static void r8153_init(struct r8152 *tp)
 	ocp_data |= SEN_VAL_NORMAL | SEL_RXIDLE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_AFE_CTRL2, ocp_data);
 
+	ocp_write_word(tp, MCU_TYPE_USB, USB_CONNECT_TIMER, 0x0001);
+
 	r8153_power_cut_en(tp, false);
 	r8153_u1u2en(tp, true);
 
-- 
2.1.0
