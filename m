From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 03/13] r8152: remove rtl8152_get_stats
Date: Wed, 5 Mar 2014 14:49:18 +0800
Message-ID: <1394002168-3193-4-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394002168-3193-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rtl8152_get_stats() returns the point address of the struct
net_device_stats. This could be got from struct net_device directly.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 151398b..b8eee36 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -960,11 +960,6 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
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
@@ -1052,7 +1047,7 @@ static void write_bulk_callback(struct urb *urb)
 		return;
 
 	netdev = tp->netdev;
-	stats = rtl8152_get_stats(netdev);
+	stats = &netdev->stats;
 	if (status) {
 		if (net_ratelimit())
 			netdev_warn(netdev, "Tx status %d\n", status);
@@ -1442,7 +1437,7 @@ static void rx_bottom(struct r8152 *tp)
 
 		while (urb->actual_length > len_used) {
 			struct net_device *netdev = tp->netdev;
-			struct net_device_stats *stats;
+			struct net_device_stats *stats = &netdev->stats;
 			unsigned int pkt_len;
 			struct sk_buff *skb;
 
@@ -1454,8 +1449,6 @@ static void rx_bottom(struct r8152 *tp)
 			if (urb->actual_length < len_used)
 				break;
 
-			stats = rtl8152_get_stats(netdev);
-
 			pkt_len -= CRC_SIZE;
 			rx_data += sizeof(struct rx_desc);
 
@@ -1504,16 +1497,14 @@ static void tx_bottom(struct r8152 *tp)
 
 		res = r8152_tx_agg_fill(tp, agg);
 		if (res) {
-			struct net_device_stats *stats;
-			struct net_device *netdev;
-			unsigned long flags;
-
-			netdev = tp->netdev;
-			stats = rtl8152_get_stats(netdev);
+			struct net_device *netdev = tp->netdev;
 
 			if (res == -ENODEV) {
 				netif_device_detach(netdev);
 			} else {
+				struct net_device_stats *stats = &netdev->stats;
+				unsigned long flags;
+
 				netif_warn(tp, tx_err, netdev,
 					   "failed tx_urb %d\n", res);
 				stats->tx_dropped += agg->skb_num;
-- 
1.8.4.2
