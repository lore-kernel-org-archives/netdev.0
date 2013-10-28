From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 5/5] net/usb/r8152: code adjust
Date: Mon, 28 Oct 2013 19:58:14 +0800
Message-ID: <1382961494-2272-6-git-send-email-hayeswang@realtek.com>
References: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 -Remove rtl8152_get_stats()
 -Fix the wrong name
 -Something else

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 46 +++++++++++++++++++++-------------------------
 1 file changed, 21 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 90bc105..d252ff6 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -218,7 +218,7 @@
 #define POWER_CUT		0x0100
 
 /* USB_PM_CTRL_STATUS */
-#define RWSUME_INDICATE		0x0001
+#define RESUME_INDICATE		0x0001
 
 /* USB_USB_CTRL */
 #define RX_AGG_DISABLE		0x0010
@@ -376,7 +376,8 @@ struct r8152 {
 enum rtl_version {
 	RTL_VER_UNKNOWN = 0,
 	RTL_VER_01,
-	RTL_VER_02
+	RTL_VER_02,
+	RTL_VER_INVALLID = -1
 };
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
@@ -422,14 +423,15 @@ int set_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 			       value, index, tmp, size, 500);
 
 	kfree(tmp);
+
 	return ret;
 }
 
 static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
 				void *data, u16 type)
 {
-	u16	limit = 64;
-	int	ret = 0;
+	u16 limit = 64;
+	int ret = 0;
 
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return -ENODEV;
@@ -468,9 +470,9 @@ static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
 static int generic_ocp_write(struct r8152 *tp, u16 index, u16 byteen,
 				u16 size, void *data, u16 type)
 {
-	int	ret;
-	u16	byteen_start, byteen_end, byen;
-	u16	limit = 512;
+	int ret;
+	u16 byteen_start, byteen_end, byen;
+	u16 limit = 512;
 
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return -ENODEV;
@@ -763,11 +765,6 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 	return 0;
 }
 
-static struct net_device_stats *rtl8152_get_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
 static void read_bulk_callback(struct urb *urb)
 {
 	struct net_device *netdev;
@@ -836,6 +833,7 @@ static void read_bulk_callback(struct urb *urb)
 static void write_bulk_callback(struct urb *urb)
 {
 	struct net_device_stats *stats;
+	struct net_device *netdev;
 	unsigned long flags;
 	struct tx_agg *agg;
 	struct r8152 *tp;
@@ -849,7 +847,8 @@ static void write_bulk_callback(struct urb *urb)
 	if (!tp)
 		return;
 
-	stats = rtl8152_get_stats(tp->netdev);
+	netdev = tp->netdev;
+	stats = &netdev->stats;
 	if (status) {
 		pr_warn_ratelimited("Tx status %d\n", status);
 		stats->tx_errors += agg->skb_num;
@@ -862,7 +861,7 @@ static void write_bulk_callback(struct urb *urb)
 	list_add_tail(&agg->list, &tp->tx_free);
 	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
-	if (!netif_carrier_ok(tp->netdev))
+	if (!netif_carrier_ok(netdev))
 		return;
 
 	if (!test_bit(WORK_ENABLE, &tp->flags))
@@ -1214,7 +1213,7 @@ static void rx_bottom(struct r8152 *tp)
 
 		while (urb->actual_length > len_used) {
 			struct net_device *netdev = tp->netdev;
-			struct net_device_stats *stats;
+			struct net_device_stats *stats = &netdev->stats;
 			unsigned pkt_len;
 			struct sk_buff *skb;
 
@@ -1226,8 +1225,6 @@ static void rx_bottom(struct r8152 *tp)
 			if (urb->actual_length < len_used)
 				break;
 
-			stats = rtl8152_get_stats(netdev);
-
 			pkt_len -= 4; /* CRC */
 			rx_data += sizeof(struct rx_desc);
 
@@ -1281,7 +1278,7 @@ static void tx_bottom(struct r8152 *tp)
 			unsigned long flags;
 
 			netdev = tp->netdev;
-			stats = rtl8152_get_stats(netdev);
+			stats = &netdev->stats;
 
 			if (res == -ENODEV) {
 				netif_device_detach(netdev);
@@ -1476,7 +1473,7 @@ static int rtl8152_enable(struct r8152 *tp)
 
 static void rtl8152_disable(struct r8152 *tp)
 {
-	struct net_device_stats *stats = rtl8152_get_stats(tp->netdev);
+	struct net_device_stats *stats = &tp->netdev->stats;
 	struct sk_buff *skb;
 	u32 ocp_data;
 	int i;
@@ -1600,8 +1597,8 @@ static void r8152b_exit_oob(struct r8152 *tp)
 
 static void r8152b_enter_oob(struct r8152 *tp)
 {
-	u32	ocp_data;
-	int	i;
+	u32 ocp_data;
+	int i;
 
 	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 	ocp_data &= ~NOW_IS_OOB;
@@ -1722,7 +1719,6 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 	r8152_mdio_write(tp, MII_BMCR, bmcr);
 
 out:
-
 	return ret;
 }
 
@@ -1840,7 +1836,7 @@ static void rtl_clear_bp(struct r8152 *tp)
 
 static void r8152b_enable_eee(struct r8152 *tp)
 {
-	u32	ocp_data;
+	u32 ocp_data;
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
 	ocp_data |= EEE_RX_EN | EEE_TX_EN;
@@ -1896,7 +1892,7 @@ static void r8152b_init(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_UPS_CTRL, ocp_data);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
-	ocp_data &= ~RWSUME_INDICATE;
+	ocp_data &= ~RESUME_INDICATE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 
 	r8152b_exit_oob(tp);
@@ -2148,7 +2144,7 @@ static void rtl8152_unload(struct r8152 *tp)
 	}
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
-	ocp_data &= ~RWSUME_INDICATE;
+	ocp_data &= ~RESUME_INDICATE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 }
 
-- 
1.8.3.1
