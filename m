From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/7] r8152: check linking status with netif_carrier_ok
Date: Mon, 19 Jan 2015 15:13:33 +0800
Message-ID: <1394712342-15778-121-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace (tp->speed & LINK_STATUS) with netif_carrier_ok().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3ee9d06..21f853f 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -581,7 +581,6 @@ struct r8152 {
 	u16 ocp_base;
 	u8 *intr_buff;
 	u8 version;
-	u8 speed;
 };
 
 enum rtl_version {
@@ -1169,12 +1168,12 @@ static void intr_callback(struct urb *urb)
 
 	d = urb->transfer_buffer;
 	if (INTR_LINK & __le16_to_cpu(d[0])) {
-		if (!(tp->speed & LINK_STATUS)) {
+		if (!netif_carrier_ok(tp->netdev)) {
 			set_bit(RTL8152_LINK_CHG, &tp->flags);
 			schedule_delayed_work(&tp->schedule, 0);
 		}
 	} else {
-		if (tp->speed & LINK_STATUS) {
+		if (netif_carrier_ok(tp->netdev)) {
 			set_bit(RTL8152_LINK_CHG, &tp->flags);
 			schedule_delayed_work(&tp->schedule, 0);
 		}
@@ -1906,7 +1905,7 @@ static void rtl8152_set_rx_mode(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 
-	if (tp->speed & LINK_STATUS) {
+	if (netif_carrier_ok(netdev)) {
 		set_bit(RTL8152_SET_RX_MODE, &tp->flags);
 		schedule_delayed_work(&tp->schedule, 0);
 	}
@@ -2936,21 +2935,20 @@ static void set_carrier(struct r8152 *tp)
 	speed = rtl8152_get_speed(tp);
 
 	if (speed & LINK_STATUS) {
-		if (!(tp->speed & LINK_STATUS)) {
+		if (!netif_carrier_ok(netdev)) {
 			tp->rtl_ops.enable(tp);
 			set_bit(RTL8152_SET_RX_MODE, &tp->flags);
 			netif_carrier_on(netdev);
 			rtl_start_rx(tp);
 		}
 	} else {
-		if (tp->speed & LINK_STATUS) {
+		if (netif_carrier_ok(netdev)) {
 			netif_carrier_off(netdev);
 			napi_disable(&tp->napi);
 			tp->rtl_ops.disable(tp);
 			napi_enable(&tp->napi);
 		}
 	}
-	tp->speed = speed;
 }
 
 static void rtl_work_func_t(struct work_struct *work)
@@ -2982,7 +2980,7 @@ static void rtl_work_func_t(struct work_struct *work)
 
 	/* don't schedule napi before linking */
 	if (test_bit(SCHEDULE_NAPI, &tp->flags) &&
-	    (tp->speed & LINK_STATUS)) {
+	    netif_carrier_ok(tp->netdev)) {
 		clear_bit(SCHEDULE_NAPI, &tp->flags);
 		napi_schedule(&tp->napi);
 	}
@@ -3005,8 +3003,7 @@ static int rtl8152_open(struct net_device *netdev)
 	if (res)
 		goto out;
 
-	/* set speed to 0 to avoid autoresume try to submit rx */
-	tp->speed = 0;
+	netif_carrier_off(netdev);
 
 	res = usb_autopm_get_interface(tp->intf);
 	if (res < 0) {
@@ -3023,7 +3020,7 @@ static int rtl8152_open(struct net_device *netdev)
 		cancel_delayed_work_sync(&tp->schedule);
 
 		/* disable the tx/rx, if the workqueue has enabled them. */
-		if (tp->speed & LINK_STATUS)
+		if (netif_carrier_ok(netdev))
 			tp->rtl_ops.disable(tp);
 	}
 
@@ -3032,7 +3029,6 @@ static int rtl8152_open(struct net_device *netdev)
 	rtl8152_set_speed(tp, AUTONEG_ENABLE,
 			  tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
 			  DUPLEX_FULL);
-	tp->speed = 0;
 	netif_carrier_off(netdev);
 	netif_start_queue(netdev);
 	set_bit(WORK_ENABLE, &tp->flags);
@@ -3358,7 +3354,7 @@ static int rtl8152_resume(struct usb_interface *intf)
 			rtl_runtime_suspend_enable(tp, false);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 			set_bit(WORK_ENABLE, &tp->flags);
-			if (tp->speed & LINK_STATUS)
+			if (netif_carrier_ok(tp->netdev))
 				rtl_start_rx(tp);
 		} else {
 			tp->rtl_ops.up(tp);
@@ -3366,7 +3362,6 @@ static int rtl8152_resume(struct usb_interface *intf)
 					  tp->mii.supports_gmii ?
 					  SPEED_1000 : SPEED_100,
 					  DUPLEX_FULL);
-			tp->speed = 0;
 			netif_carrier_off(tp->netdev);
 			set_bit(WORK_ENABLE, &tp->flags);
 		}
-- 
2.1.0
