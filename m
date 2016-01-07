From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: fix the wake event
Date: Thu, 7 Jan 2016 17:12:17 +0800
Message-ID: <1394712342-15778-170-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the autosuspend is enabled and occurs before system suspend, we should
wake the device before running system syspend. Then, we could change the wake
event for system suspend. Otherwise, the device would resume the system when
receiving any packet.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 40 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2fb637a..ef9aab6 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -25,12 +25,13 @@
 #include <uapi/linux/mdio.h>
 #include <linux/mdio.h>
 #include <linux/usb/cdc.h>
+#include <linux/suspend.h>
 
 /* Information for net-next */
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"2"
+#define NET_VERSION		"3"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
@@ -604,6 +605,9 @@ struct r8152 {
 	struct delayed_work schedule;
 	struct mii_if_info mii;
 	struct mutex control;	/* use for hw setting */
+#ifdef CONFIG_PM_SLEEP
+	struct notifier_block pm_notifier;
+#endif
 
 	struct rtl_ops {
 		void (*init)(struct r8152 *);
@@ -3048,6 +3052,33 @@ out1:
 	usb_autopm_put_interface(tp->intf);
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int rtl_notifier(struct notifier_block *nb, unsigned long action,
+			void *data)
+{
+	struct r8152 *tp = container_of(nb, struct r8152, pm_notifier);
+
+	switch (action) {
+	case PM_HIBERNATION_PREPARE:
+	case PM_SUSPEND_PREPARE:
+		usb_autopm_get_interface(tp->intf);
+		break;
+
+	case PM_POST_HIBERNATION:
+	case PM_POST_SUSPEND:
+		usb_autopm_put_interface(tp->intf);
+		break;
+
+	case PM_POST_RESTORE:
+	case PM_RESTORE_PREPARE:
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+#endif
+
 static int rtl8152_open(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
@@ -3090,6 +3121,10 @@ static int rtl8152_open(struct net_device *netdev)
 	mutex_unlock(&tp->control);
 
 	usb_autopm_put_interface(tp->intf);
+#ifdef CONFIG_PM_SLEEP
+	tp->pm_notifier.notifier_call = rtl_notifier;
+	register_pm_notifier(&tp->pm_notifier);
+#endif
 
 out:
 	return res;
@@ -3100,6 +3135,9 @@ static int rtl8152_close(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int res = 0;
 
+#ifdef CONFIG_PM_SLEEP
+	unregister_pm_notifier(&tp->pm_notifier);
+#endif
 	napi_disable(&tp->napi);
 	clear_bit(WORK_ENABLE, &tp->flags);
 	usb_kill_urb(tp->intr_urb);
-- 
2.4.3
