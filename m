From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: support jumbo frame for RTL8153
Date: Wed, 9 Jul 2014 16:07:02 +0800
Message-ID: <1394712342-15778-8-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The maximum jumbo frame size for RTL8153 is 9K bytes.
Change the max rx packet size to 9K.
Change the use of the shared fifo from 6K (default) to 12K for tx.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 39 +++++++++++++++++++++++++++++++++++----
 1 file changed, 35 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e9685ce..c3ce4e4 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -59,6 +59,7 @@
 #define PLA_WDT6_CTRL		0xe428
 #define PLA_TCR0		0xe610
 #define PLA_TCR1		0xe612
+#define PLA_MTPS		0xe615
 #define PLA_TXFIFO_CTRL		0xe618
 #define PLA_RSTTALLY		0xe800
 #define PLA_CR			0xe813
@@ -180,6 +181,10 @@
 /* PLA_TCR1 */
 #define VERSION_MASK		0x7cf0
 
+/* PLA_MTPS */
+#define MTPS_JUMBO		(12 * 1024 / 64)
+#define MTPS_DEFAULT		(6 * 1024 / 64)
+
 /* PLA_RSTTALLY */
 #define TALLY_RESET		0x0001
 
@@ -440,7 +445,10 @@ enum rtl_register_content {
 #define BYTE_EN_START_MASK	0x0f
 #define BYTE_EN_END_MASK	0xf0
 
+#define RTL8153_MAX_PACKET	9216 /* 9K */
+#define RTL8153_MAX_MTU		(RTL8153_MAX_PACKET - VLAN_ETH_HLEN - VLAN_HLEN)
 #define RTL8152_RMS		(VLAN_ETH_FRAME_LEN + VLAN_HLEN)
+#define RTL8153_RMS		RTL8153_MAX_PACKET
 #define RTL8152_TX_TIMEOUT	(5 * HZ)
 
 /* rtl8152 flags */
@@ -2522,7 +2530,8 @@ static void r8153_first_init(struct r8152 *tp)
 	ocp_data &= ~CPCR_RX_VLAN;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
 
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8153_RMS);
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_MTPS, MTPS_JUMBO);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TCR0);
 	ocp_data |= TCR0_AUTO_FIFO;
@@ -2572,7 +2581,7 @@ static void r8153_enter_oob(struct r8152 *tp)
 		mdelay(1);
 	}
 
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8153_RMS);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG);
 	ocp_data &= ~TEREDO_WAKE_MASK;
@@ -3284,6 +3293,29 @@ out:
 	return res;
 }
 
+static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct r8152 *tp = netdev_priv(dev);
+
+	if (dev->mtu == new_mtu)
+		return 0;
+
+	switch (tp->version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		return eth_change_mtu(dev, new_mtu);
+	default:
+		break;
+	}
+
+	if (new_mtu < 68 || new_mtu > RTL8153_MAX_MTU)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
 static const struct net_device_ops rtl8152_netdev_ops = {
 	.ndo_open		= rtl8152_open,
 	.ndo_stop		= rtl8152_close,
@@ -3292,8 +3324,7 @@ static const struct net_device_ops rtl8152_netdev_ops = {
 	.ndo_tx_timeout		= rtl8152_tx_timeout,
 	.ndo_set_rx_mode	= rtl8152_set_rx_mode,
 	.ndo_set_mac_address	= rtl8152_set_mac_address,
-
-	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_change_mtu		= rtl8152_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-- 
1.9.3
