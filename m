From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: set RTL8152_UNPLUG when finding -ENODEV
Date: Thu, 30 Oct 2014 11:46:40 +0800
Message-ID: <1394712342-15778-73-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set RTL8152_UNPLUG when finding -ENODEV. This could accelerate
unloading the driver when the device is unplugged.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e1810bc..f116335 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -690,6 +690,9 @@ static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
 		}
 	}
 
+	if (ret == -ENODEV)
+		set_bit(RTL8152_UNPLUG, &tp->flags);
+
 	return ret;
 }
 
@@ -757,6 +760,9 @@ static int generic_ocp_write(struct r8152 *tp, u16 index, u16 byteen,
 	}
 
 error1:
+	if (ret == -ENODEV)
+		set_bit(RTL8152_UNPLUG, &tp->flags);
+
 	return ret;
 }
 
@@ -1083,6 +1089,7 @@ static void read_bulk_callback(struct urb *urb)
 
 	result = r8152_submit_rx(tp, agg, GFP_ATOMIC);
 	if (result == -ENODEV) {
+		set_bit(RTL8152_UNPLUG, &tp->flags);
 		netif_device_detach(tp->netdev);
 	} else if (result) {
 		spin_lock(&tp->rx_lock);
@@ -1187,11 +1194,13 @@ static void intr_callback(struct urb *urb)
 
 resubmit:
 	res = usb_submit_urb(urb, GFP_ATOMIC);
-	if (res == -ENODEV)
+	if (res == -ENODEV) {
+		set_bit(RTL8152_UNPLUG, &tp->flags);
 		netif_device_detach(tp->netdev);
-	else if (res)
+	} else if (res) {
 		netif_err(tp, intr, tp->netdev,
 			  "can't resubmit intr, status %d\n", res);
+	}
 }
 
 static inline void *rx_agg_align(void *data)
@@ -1755,6 +1764,7 @@ static void tx_bottom(struct r8152 *tp)
 			struct net_device *netdev = tp->netdev;
 
 			if (res == -ENODEV) {
+				set_bit(RTL8152_UNPLUG, &tp->flags);
 				netif_device_detach(netdev);
 			} else {
 				struct net_device_stats *stats = &netdev->stats;
-- 
1.9.3
