From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: prevent the driver from transmitting packets with carrier off
Date: Thu, 23 Mar 2017 19:14:19 +0800
Message-ID: <1394712342-15778-259-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The linking status may be changed when autosuspend. And, after
autoresume, the driver may try to transmit packets when the device
is carrier off, because the interrupt transfer doesn't update the
linking status, yet. And, if the device is in ALDPS mode, the device
would stop working.

The another similar case is
 1. unplug the cable.
 2. interrupt transfer queue a work_queue for linking change.
 3. device enters the ALDPS mode.
 4. a tx occurs before the work_queue is called.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0b1b918..c34df33 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1294,6 +1294,7 @@ static void intr_callback(struct urb *urb)
 		}
 	} else {
 		if (netif_carrier_ok(tp->netdev)) {
+			netif_stop_queue(tp->netdev);
 			set_bit(RTL8152_LINK_CHG, &tp->flags);
 			schedule_delayed_work(&tp->schedule, 0);
 		}
@@ -3169,6 +3170,9 @@ static void set_carrier(struct r8152 *tp)
 			napi_enable(&tp->napi);
 			netif_wake_queue(netdev);
 			netif_info(tp, link, netdev, "carrier on\n");
+		} else if (netif_queue_stopped(netdev) &&
+			   skb_queue_len(&tp->tx_queue) < tp->tx_qlen) {
+			netif_wake_queue(netdev);
 		}
 	} else {
 		if (netif_carrier_ok(netdev)) {
@@ -3702,8 +3706,18 @@ static int rtl8152_resume(struct usb_interface *intf)
 			tp->rtl_ops.autosuspend_en(tp, false);
 			napi_disable(&tp->napi);
 			set_bit(WORK_ENABLE, &tp->flags);
-			if (netif_carrier_ok(tp->netdev))
-				rtl_start_rx(tp);
+
+			if (netif_carrier_ok(tp->netdev)) {
+				if (rtl8152_get_speed(tp) & LINK_STATUS) {
+					rtl_start_rx(tp);
+				} else {
+					netif_carrier_off(tp->netdev);
+					tp->rtl_ops.disable(tp);
+					netif_info(tp, link, tp->netdev,
+						   "linking down\n");
+				}
+			}
+
 			napi_enable(&tp->napi);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 			smp_mb__after_atomic();
-- 
2.7.4
