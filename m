From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/2] r8152: split rtl8152_resume function
Date: Tue, 13 Jun 2017 15:14:39 +0800
Message-ID: <1394712342-15778-276-Taiwan-albertk@realtek.com>
References: <1394712342-15778-272-Taiwan-albertk@realtek.com>
 <1394712342-15778-275-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-275-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split rtl8152_resume() into rtl8152_runtime_resume() and
rtl8152_system_resume().

Besides, replace GFP_KERNEL with GFP_NOIO for usb_submit_urb().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 99 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 61 insertions(+), 38 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5a02053..2d238b5 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3686,6 +3686,61 @@ static bool delay_autosuspend(struct r8152 *tp)
 		return false;
 }
 
+static int rtl8152_runtime_resume(struct r8152 *tp)
+{
+	struct net_device *netdev = tp->netdev;
+
+	if (netif_running(netdev) && netdev->flags & IFF_UP) {
+		struct napi_struct *napi = &tp->napi;
+
+		tp->rtl_ops.autosuspend_en(tp, false);
+		napi_disable(napi);
+		set_bit(WORK_ENABLE, &tp->flags);
+
+		if (netif_carrier_ok(netdev)) {
+			if (rtl8152_get_speed(tp) & LINK_STATUS) {
+				rtl_start_rx(tp);
+			} else {
+				netif_carrier_off(netdev);
+				tp->rtl_ops.disable(tp);
+				netif_info(tp, link, netdev, "linking down\n");
+			}
+		}
+
+		napi_enable(napi);
+		clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+		smp_mb__after_atomic();
+
+		if (!list_empty(&tp->rx_done))
+			napi_schedule(&tp->napi);
+
+		usb_submit_urb(tp->intr_urb, GFP_NOIO);
+	} else {
+		if (netdev->flags & IFF_UP)
+			tp->rtl_ops.autosuspend_en(tp, false);
+
+		clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+	}
+
+	return 0;
+}
+
+static int rtl8152_system_resume(struct r8152 *tp)
+{
+	struct net_device *netdev = tp->netdev;
+
+	netif_device_attach(netdev);
+
+	if (netif_running(netdev) && netdev->flags & IFF_UP) {
+		tp->rtl_ops.up(tp);
+		netif_carrier_off(netdev);
+		set_bit(WORK_ENABLE, &tp->flags);
+		usb_submit_urb(tp->intr_urb, GFP_NOIO);
+	}
+
+	return 0;
+}
+
 static int rtl8152_runtime_suspend(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
@@ -3784,50 +3839,18 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 static int rtl8152_resume(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
-	struct net_device *netdev = tp->netdev;
+	int ret;
 
 	mutex_lock(&tp->control);
 
-	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags))
-		netif_device_attach(netdev);
-
-	if (netif_running(netdev) && netdev->flags & IFF_UP) {
-		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
-			struct napi_struct *napi = &tp->napi;
-
-			tp->rtl_ops.autosuspend_en(tp, false);
-			napi_disable(napi);
-			set_bit(WORK_ENABLE, &tp->flags);
-			if (netif_carrier_ok(netdev)) {
-				if (rtl8152_get_speed(tp) & LINK_STATUS) {
-					rtl_start_rx(tp);
-				} else {
-					netif_carrier_off(netdev);
-					tp->rtl_ops.disable(tp);
-					netif_info(tp, link, netdev,
-						   "linking down\n");
-				}
-			}
-			napi_enable(napi);
-			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
-			smp_mb__after_atomic();
-			if (!list_empty(&tp->rx_done))
-				napi_schedule(&tp->napi);
-		} else {
-			tp->rtl_ops.up(tp);
-			netif_carrier_off(netdev);
-			set_bit(WORK_ENABLE, &tp->flags);
-		}
-		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
-	} else if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
-		if (netdev->flags & IFF_UP)
-			tp->rtl_ops.autosuspend_en(tp, false);
-		clear_bit(SELECTIVE_SUSPEND, &tp->flags);
-	}
+	if (test_bit(SELECTIVE_SUSPEND, &tp->flags))
+		ret = rtl8152_runtime_resume(tp);
+	else
+		ret = rtl8152_system_resume(tp);
 
 	mutex_unlock(&tp->control);
 
-	return 0;
+	return ret;
 }
 
 static int rtl8152_reset_resume(struct usb_interface *intf)
-- 
2.7.4
