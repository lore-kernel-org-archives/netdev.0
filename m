From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v3 2/4] r8152: avoid start_xmit to schedule napi when napi is disabled
Date: Thu, 26 Jan 2017 09:38:32 +0800
Message-ID: <1394712342-15778-249-Taiwan-albertk@realtek.com>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
 <1394712342-15778-247-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-247-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stop the tx when the napi is disabled to prevent napi_schedule() is
called.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 23bef8e..ec882be 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3155,10 +3155,13 @@ static void set_carrier(struct r8152 *tp)
 		if (!netif_carrier_ok(netdev)) {
 			tp->rtl_ops.enable(tp);
 			set_bit(RTL8152_SET_RX_MODE, &tp->flags);
+			netif_stop_queue(netdev);
 			napi_disable(&tp->napi);
 			netif_carrier_on(netdev);
 			rtl_start_rx(tp);
 			napi_enable(&tp->napi);
+			netif_wake_queue(netdev);
+			netif_info(tp, link, netdev, "carrier on\n");
 		}
 	} else {
 		if (netif_carrier_ok(netdev)) {
@@ -3166,6 +3169,7 @@ static void set_carrier(struct r8152 *tp)
 			napi_disable(&tp->napi);
 			tp->rtl_ops.disable(tp);
 			napi_enable(&tp->napi);
+			netif_info(tp, link, netdev, "carrier off\n");
 		}
 	}
 }
@@ -3515,12 +3519,12 @@ static int rtl8152_pre_reset(struct usb_interface *intf)
 	if (!netif_running(netdev))
 		return 0;
 
+	netif_stop_queue(netdev);
 	napi_disable(&tp->napi);
 	clear_bit(WORK_ENABLE, &tp->flags);
 	usb_kill_urb(tp->intr_urb);
 	cancel_delayed_work_sync(&tp->schedule);
 	if (netif_carrier_ok(netdev)) {
-		netif_stop_queue(netdev);
 		mutex_lock(&tp->control);
 		tp->rtl_ops.disable(tp);
 		mutex_unlock(&tp->control);
@@ -3548,10 +3552,10 @@ static int rtl8152_post_reset(struct usb_interface *intf)
 		rtl_start_rx(tp);
 		rtl8152_set_rx_mode(netdev);
 		mutex_unlock(&tp->control);
-		netif_wake_queue(netdev);
 	}
 
 	napi_enable(&tp->napi);
+	netif_wake_queue(netdev);
 	usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 
 	return 0;
-- 
2.7.4
