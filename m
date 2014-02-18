From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 09/14] r8152: support WOL
Date: Tue, 18 Feb 2014 21:49:06 +0800
Message-ID: <1392731351-25502-10-git-send-email-hayeswang@realtek.com>
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

Support WOL for RTL8152 and RTL8153.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 118 ++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 105 insertions(+), 13 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 828572a..5d520be 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -23,7 +23,7 @@
 #include <linux/ipv6.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.04.0 (2014/01/15)"
+#define DRIVER_VERSION "v1.05.0 (2014/02/18)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -62,6 +62,8 @@
 #define PLA_RSTTELLY		0xe800
 #define PLA_CR			0xe813
 #define PLA_CRWECR		0xe81c
+#define PLA_CONFIG12		0xe81e	/* CONFIG1, CONFIG2 */
+#define PLA_CONFIG34		0xe820	/* CONFIG3, CONFIG4 */
 #define PLA_CONFIG5		0xe822
 #define PLA_PHY_PWR		0xe84c
 #define PLA_OOB_CTRL		0xe84f
@@ -216,7 +218,14 @@
 /* PAL_BDC_CR */
 #define ALDPS_PROXY_MODE	0x0001
 
+/* PLA_CONFIG34 */
+#define LINK_ON_WAKE_EN		0x0010
+#define LINK_OFF_WAKE_EN	0x0008
+
 /* PLA_CONFIG5 */
+#define BWF_EN			0x0040
+#define MWF_EN			0x0020
+#define UWF_EN			0x0010
 #define LAN_WAKE_EN		0x0002
 
 /* PLA_LED_FEATURE */
@@ -521,6 +530,7 @@ struct r8152 {
 	} rtl_ops;
 
 	int intr_interval;
+	u32 saved_wolopts;
 	u32 msg_enable;
 	u32 tx_qlen;
 	u16 ocp_base;
@@ -1798,6 +1808,74 @@ static void r8152_power_cut_en(struct r8152 *tp, bool enable)
 
 }
 
+#define WAKE_ANY (WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_BCAST | WAKE_MCAST)
+
+static u32 __rtl_get_wol(struct r8152 *tp)
+{
+	u32 ocp_data;
+	u32 wolopts = 0;
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_CONFIG5);
+	if (!(ocp_data & LAN_WAKE_EN))
+		return 0;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG34);
+	if (ocp_data & LINK_ON_WAKE_EN)
+		wolopts |= WAKE_PHY;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG5);
+	if (ocp_data & UWF_EN)
+		wolopts |= WAKE_UCAST;
+	if (ocp_data & BWF_EN)
+		wolopts |= WAKE_BCAST;
+	if (ocp_data & MWF_EN)
+		wolopts |= WAKE_MCAST;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL);
+	if (ocp_data & MAGIC_EN)
+		wolopts |= WAKE_MAGIC;
+
+	return wolopts;
+}
+
+static void __rtl_set_wol(struct r8152 *tp, u32 wolopts)
+{
+	u32 ocp_data;
+
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG34);
+	ocp_data &= ~LINK_ON_WAKE_EN;
+	if (wolopts & WAKE_PHY)
+		ocp_data |= LINK_ON_WAKE_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CONFIG34, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG5);
+	ocp_data &= ~(UWF_EN | BWF_EN | MWF_EN | LAN_WAKE_EN);
+	if (wolopts & WAKE_UCAST)
+		ocp_data |= UWF_EN;
+	if (wolopts & WAKE_BCAST)
+		ocp_data |= BWF_EN;
+	if (wolopts & WAKE_MCAST)
+		ocp_data |= MWF_EN;
+	if (wolopts & WAKE_ANY)
+		ocp_data |= LAN_WAKE_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CONFIG5, ocp_data);
+
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL);
+	ocp_data &= ~MAGIC_EN;
+	if (wolopts & WAKE_MAGIC)
+		ocp_data |= MAGIC_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL, ocp_data);
+
+	if (wolopts & WAKE_ANY)
+		device_set_wakeup_enable(&tp->udev->dev, true);
+	else
+		device_set_wakeup_enable(&tp->udev->dev, false);
+}
+
 static void rtl_phy_reset(struct r8152 *tp)
 {
 	u16 data;
@@ -2002,10 +2080,6 @@ static void r8152b_enter_oob(struct r8152 *tp)
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL);
-	ocp_data |= MAGIC_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL, ocp_data);
-
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
 	ocp_data |= CPCR_RX_VLAN;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
@@ -2018,8 +2092,6 @@ static void r8152b_enter_oob(struct r8152 *tp)
 	ocp_data |= NOW_IS_OOB | DIS_MCU_CLROOB;
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL, ocp_data);
 
-	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CONFIG5, LAN_WAKE_EN);
-
 	rxdy_gated_en(tp, false);
 
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
@@ -2217,10 +2289,6 @@ static void r8153_enter_oob(struct r8152 *tp)
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
 
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL);
-	ocp_data |= MAGIC_EN;
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL, ocp_data);
-
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG);
 	ocp_data &= ~TEREDO_WAKE_MASK;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG, ocp_data);
@@ -2237,8 +2305,6 @@ static void r8153_enter_oob(struct r8152 *tp)
 	ocp_data |= NOW_IS_OOB | DIS_MCU_CLROOB;
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL, ocp_data);
 
-	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CONFIG5, LAN_WAKE_EN);
-
 	rxdy_gated_en(tp, false);
 
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
@@ -2652,6 +2718,24 @@ static int rtl8152_resume(struct usb_interface *intf)
 	return 0;
 }
 
+static void rtl8152_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct r8152 *tp = netdev_priv(dev);
+
+	wol->supported = WAKE_ANY;
+	wol->wolopts = __rtl_get_wol(tp);
+}
+
+static int rtl8152_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct r8152 *tp = netdev_priv(dev);
+
+	__rtl_set_wol(tp, wol->wolopts);
+	tp->saved_wolopts = wol->wolopts & WAKE_ANY;
+
+	return 0;
+}
+
 static void rtl8152_get_drvinfo(struct net_device *netdev,
 				struct ethtool_drvinfo *info)
 {
@@ -2685,6 +2769,8 @@ static struct ethtool_ops ops = {
 	.get_settings = rtl8152_get_settings,
 	.set_settings = rtl8152_set_settings,
 	.get_link = ethtool_op_get_link,
+	.get_wol = rtl8152_get_wol,
+	.set_wol = rtl8152_set_wol,
 };
 
 static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
@@ -2888,6 +2974,12 @@ static int rtl8152_probe(struct usb_interface *intf,
 		goto out1;
 	}
 
+	tp->saved_wolopts = __rtl_get_wol(tp);
+	if (tp->saved_wolopts)
+		device_set_wakeup_enable(&udev->dev, true);
+	else
+		device_set_wakeup_enable(&udev->dev, false);
+
 	netif_info(tp, probe, netdev, "%s\n", DRIVER_VERSION);
 
 	return 0;
-- 
1.8.4.2
