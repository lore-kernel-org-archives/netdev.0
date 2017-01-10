From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 1/2] r8152: split rtl8152_suspend function
Date: Tue, 10 Jan 2017 17:04:06 +0800
Message-ID: <1394712342-15778-230-Taiwan-albertk@realtek.com>
References: <1394712342-15778-229-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-229-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Split rtl8152_suspend() into rtl8152_system_suspend() and
rtl8152_rumtime_suspend().

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 57 ++++++++++++++++++++++++++++++++++---------------
 1 file changed, 40 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 7dc6122..c5e6d88 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3576,39 +3576,62 @@ static bool delay_autosuspend(struct r8152 *tp)
 		return false;
 }
 
-static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
+static int rtl8152_rumtime_suspend(struct r8152 *tp)
 {
-	struct r8152 *tp = usb_get_intfdata(intf);
 	struct net_device *netdev = tp->netdev;
 	int ret = 0;
 
-	mutex_lock(&tp->control);
-
-	if (PMSG_IS_AUTO(message)) {
-		if (netif_running(netdev) && delay_autosuspend(tp)) {
+	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
+		if (delay_autosuspend(tp)) {
 			ret = -EBUSY;
 			goto out1;
 		}
 
-		set_bit(SELECTIVE_SUSPEND, &tp->flags);
-	} else {
-		netif_device_detach(netdev);
+		clear_bit(WORK_ENABLE, &tp->flags);
+		usb_kill_urb(tp->intr_urb);
+		napi_disable(&tp->napi);
+		rtl_stop_rx(tp);
+		tp->rtl_ops.autosuspend_en(tp, true);
+		napi_enable(&tp->napi);
 	}
 
+	set_bit(SELECTIVE_SUSPEND, &tp->flags);
+
+out1:
+	return ret;
+}
+
+static int rtl8152_system_suspend(struct r8152 *tp)
+{
+	struct net_device *netdev = tp->netdev;
+	int ret = 0;
+
+	netif_device_detach(netdev);
+
 	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
 		napi_disable(&tp->napi);
-		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
-			rtl_stop_rx(tp);
-			tp->rtl_ops.autosuspend_en(tp, true);
-		} else {
-			cancel_delayed_work_sync(&tp->schedule);
-			tp->rtl_ops.down(tp);
-		}
+		cancel_delayed_work_sync(&tp->schedule);
+		tp->rtl_ops.down(tp);
 		napi_enable(&tp->napi);
 	}
-out1:
+
+	return ret;
+}
+
+static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct r8152 *tp = usb_get_intfdata(intf);
+	int ret;
+
+	mutex_lock(&tp->control);
+
+	if (PMSG_IS_AUTO(message))
+		ret = rtl8152_rumtime_suspend(tp);
+	else
+		ret = rtl8152_system_suspend(tp);
+
 	mutex_unlock(&tp->control);
 
 	return ret;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
