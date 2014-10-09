From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next] r8152: add rtnl_lock
Date: Thu, 9 Oct 2014 14:24:44 +0800
Message-ID: <1394712342-15778-59-Taiwan-albertk@realtek.com>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-58-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add rtnl_lock() for suspend/resume and workqueue.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5cfd414..2b2b679 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,7 +26,7 @@
 #include <linux/mdio.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.06.1 (2014/10/01)"
+#define DRIVER_VERSION "v1.07.0 (2014/10/09)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -2851,6 +2851,11 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		goto out1;
 
+	if (!rtnl_trylock()) {
+		schedule_delayed_work(&tp->schedule, 0);
+		goto out1;
+	}
+
 	if (test_bit(RTL8152_LINK_CHG, &tp->flags))
 		set_carrier(tp);
 
@@ -2866,6 +2871,8 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(PHY_RESET, &tp->flags))
 		rtl_phy_reset(tp);
 
+	rtnl_unlock();
+
 out1:
 	usb_autopm_put_interface(tp->intf);
 }
@@ -3169,6 +3176,8 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
+	rtnl_lock();
+
 	if (PMSG_IS_AUTO(message))
 		set_bit(SELECTIVE_SUSPEND, &tp->flags);
 	else
@@ -3188,6 +3197,8 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 		tasklet_enable(&tp->tl);
 	}
 
+	rtnl_unlock();
+
 	return 0;
 }
 
@@ -3195,6 +3206,8 @@ static int rtl8152_resume(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
+	rtnl_lock();
+
 	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 		tp->rtl_ops.init(tp);
 		netif_device_attach(tp->netdev);
@@ -3220,6 +3233,8 @@ static int rtl8152_resume(struct usb_interface *intf)
 		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 	}
 
+	rtnl_unlock();
+
 	return 0;
 }
 
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
