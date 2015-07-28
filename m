From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 2/2] r8152: reset device when tx timeout
Date: Tue, 28 Jul 2015 15:36:17 +0800
Message-ID: <1394712342-15778-158-Taiwan-albertk@realtek.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-156-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device reset is necessary if the hw becomes abnormal and stops
transmitting packets.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a6caa60..9bf6e0c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -27,7 +27,7 @@
 #include <linux/usb/cdc.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.08.0 (2015/01/13)"
+#define DRIVER_VERSION "v1.08.1 (2015/07/28)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -591,6 +591,7 @@ struct r8152 {
 	struct sk_buff_head tx_queue, rx_queue;
 	spinlock_t rx_lock, tx_lock;
 	struct delayed_work schedule;
+	struct delayed_work work_reset;
 	struct mii_if_info mii;
 	struct mutex control;	/* use for hw setting */
 
@@ -1902,11 +1903,11 @@ static void rtl_drop_queued_tx(struct r8152 *tp)
 static void rtl8152_tx_timeout(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
-	int i;
 
 	netif_warn(tp, tx_err, netdev, "Tx timeout\n");
-	for (i = 0; i < RTL8152_MAX_TX; i++)
-		usb_unlink_urb(tp->tx_info[i].urb);
+
+	schedule_delayed_work(&tp->work_reset, 0);
+	cancel_delayed_work(&tp->schedule);
 }
 
 static void rtl8152_set_rx_mode(struct net_device *netdev)
@@ -3408,6 +3409,18 @@ static int rtl8152_post_reset(struct usb_interface *intf)
 	return ret;
 }
 
+static void rtl_hw_reset(struct work_struct *work)
+{
+	struct r8152 *tp = container_of(work, struct r8152, work_reset.work);
+
+	netif_info(tp, drv, tp->netdev, "usb reset device\n");
+
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
+	usb_reset_device(tp->udev);
+}
+
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
@@ -4102,6 +4115,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	mutex_init(&tp->control);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
+	INIT_DELAYED_WORK(&tp->work_reset, rtl_hw_reset);
 
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
-- 
2.4.2
