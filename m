From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] r8152: separate USB_RX_EARLY_AGG
Date: Wed, 11 Feb 2015 14:46:57 +0800
Message-ID: <1394712342-15778-138-Taiwan-albertk@realtek.com>
References: <1394712342-15778-137-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-137-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Separate USB_RX_EARLY_AGG into USB_RX_EARLY_TIMEOUT and USB_RX_EARLY_SIZE.

Replace r8153_set_rx_agg() with r8153_set_rx_early_timeout() and
r8153_set_rx_early_size().

Set the default timeout value according to the USB speed.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 55 ++++++++++++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5980ac6..b043c7f 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -97,7 +97,8 @@
 #define USB_TX_AGG		0xd40a
 #define USB_RX_BUF_TH		0xd40c
 #define USB_USB_TIMER		0xd428
-#define USB_RX_EARLY_AGG	0xd42c
+#define USB_RX_EARLY_TIMEOUT	0xd42c
+#define USB_RX_EARLY_SIZE	0xd42e
 #define USB_PM_CTRL_STATUS	0xd432
 #define USB_TX_DMA		0xd434
 #define USB_TOLERANCE		0xd490
@@ -325,10 +326,10 @@
 /* USB_MISC_0 */
 #define PCUT_STATUS		0x0001
 
-/* USB_RX_EARLY_AGG */
-#define EARLY_AGG_SUPPER	0x0e832981
-#define EARLY_AGG_HIGH		0x0e837a12
-#define EARLY_AGG_SLOW		0x0e83ffff
+/* USB_RX_EARLY_TIMEOUT */
+#define COALESCE_SUPER		 85000U
+#define COALESCE_HIGH		250000U
+#define COALESCE_SLOW		524280U
 
 /* USB_WDT11_CTRL */
 #define TIMER11_EN		0x0001
@@ -578,6 +579,7 @@ struct r8152 {
 	u32 saved_wolopts;
 	u32 msg_enable;
 	u32 tx_qlen;
+	u32 coalesce;
 	u16 ocp_base;
 	u8 *intr_buff;
 	u8 version;
@@ -2114,28 +2116,21 @@ static int rtl8152_enable(struct r8152 *tp)
 	return rtl_enable(tp);
 }
 
-static void r8153_set_rx_agg(struct r8152 *tp)
+static void r8153_set_rx_early_timeout(struct r8152 *tp)
 {
-	u8 speed;
+	u32 ocp_data;
 
-	speed = rtl8152_get_speed(tp);
-	if (speed & _1000bps) {
-		if (tp->udev->speed == USB_SPEED_SUPER) {
-			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH,
-					RX_THR_SUPPER);
-			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_EARLY_AGG,
-					EARLY_AGG_SUPPER);
-		} else {
-			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH,
-					RX_THR_HIGH);
-			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_EARLY_AGG,
-					EARLY_AGG_HIGH);
-		}
-	} else {
-		ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH, RX_THR_SLOW);
-		ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_EARLY_AGG,
-				EARLY_AGG_SLOW);
-	}
+	ocp_data = tp->coalesce / 8;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_TIMEOUT, ocp_data);
+}
+
+static void r8153_set_rx_early_size(struct r8152 *tp)
+{
+	struct net_device *dev = tp->netdev;
+	u32 ocp_data;
+
+	ocp_data = (agg_buf_sz - dev->mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
 }
 
 static int rtl8153_enable(struct r8152 *tp)
@@ -2145,7 +2140,8 @@ static int rtl8153_enable(struct r8152 *tp)
 
 	set_tx_qlen(tp);
 	rtl_set_eee_plus(tp);
-	r8153_set_rx_agg(tp);
+	r8153_set_rx_early_timeout(tp);
+	r8153_set_rx_early_size(tp);
 
 	return rtl_enable(tp);
 }
@@ -3911,6 +3907,13 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->mii.reg_num_mask = 0x1f;
 	tp->mii.phy_id = R8152_PHY_ID;
 
+	if (udev->speed == USB_SPEED_SUPER)
+		tp->coalesce = COALESCE_SUPER;
+	else if (udev->speed == USB_SPEED_HIGH)
+		tp->coalesce = COALESCE_HIGH;
+	else
+		tp->coalesce = COALESCE_SLOW;
+
 	intf->needs_remote_wakeup = 1;
 
 	tp->rtl_ops.init(tp);
-- 
2.1.0
