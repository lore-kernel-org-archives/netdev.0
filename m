From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 4/6] r8152: add rtl_ops
Date: Thu, 2 Jan 2014 11:22:42 +0800
Message-ID: <1388632963-1341-5-git-send-email-hayeswang@realtek.com>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
 <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The different chips may have different settings. This makes it easy
to let different chips have the same flow with differnt settings.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 57 +++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 50 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 85862a8..8a7c876 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -367,6 +367,15 @@ struct r8152 {
 	spinlock_t rx_lock, tx_lock;
 	struct delayed_work schedule;
 	struct mii_if_info mii;
+
+	struct rtl_ops {
+		void (*init)(struct r8152 *);
+		int (*enable)(struct r8152 *);
+		void (*disable)(struct r8152 *);
+		void (*down)(struct r8152 *);
+		void (*unload)(struct r8152 *);
+	} rtl_ops;
+
 	int intr_interval;
 	u32 msg_enable;
 	u32 tx_qlen;
@@ -1751,7 +1760,7 @@ static void set_carrier(struct r8152 *tp)
 
 	if (speed & LINK_STATUS) {
 		if (!(tp->speed & LINK_STATUS)) {
-			rtl8152_enable(tp);
+			tp->rtl_ops.enable(tp);
 			set_bit(RTL8152_SET_RX_MODE, &tp->flags);
 			netif_carrier_on(netdev);
 		}
@@ -1759,7 +1768,7 @@ static void set_carrier(struct r8152 *tp)
 		if (tp->speed & LINK_STATUS) {
 			netif_carrier_off(netdev);
 			tasklet_disable(&tp->tl);
-			rtl8152_disable(tp);
+			tp->rtl_ops.disable(tp);
 			tasklet_enable(&tp->tl);
 		}
 	}
@@ -1819,7 +1828,7 @@ static int rtl8152_close(struct net_device *netdev)
 	cancel_delayed_work_sync(&tp->schedule);
 	netif_stop_queue(netdev);
 	tasklet_disable(&tp->tl);
-	rtl8152_disable(tp);
+	tp->rtl_ops.disable(tp);
 	tasklet_enable(&tp->tl);
 
 	return res;
@@ -1945,7 +1954,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 		tasklet_disable(&tp->tl);
 	}
 
-	rtl8152_down(tp);
+	tp->rtl_ops.down(tp);
 
 	return 0;
 }
@@ -1954,7 +1963,7 @@ static int rtl8152_resume(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
-	r8152b_init(tp);
+	tp->rtl_ops.init(tp);
 	netif_device_attach(tp->netdev);
 	if (netif_running(tp->netdev)) {
 		rtl8152_set_speed(tp, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL);
@@ -2083,6 +2092,35 @@ static void rtl8152_unload(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 }
 
+static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
+{
+	struct rtl_ops *ops = &tp->rtl_ops;
+	bool ret = true;
+
+	switch (id->idVendor) {
+	case VENDOR_ID_REALTEK:
+		switch (id->idProduct) {
+		case PRODUCT_ID_RTL8152:
+			ops->init		= r8152b_init;
+			ops->enable		= rtl8152_enable;
+			ops->disable		= rtl8152_disable;
+			ops->down		= rtl8152_down;
+			ops->unload		= rtl8152_unload;
+			break;
+		default:
+			ret = false;
+			break;
+		}
+		break;
+
+	default:
+		ret = false;
+		break;
+	}
+
+	return ret;
+}
+
 static int rtl8152_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
@@ -2106,6 +2144,11 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp = netdev_priv(netdev);
 	tp->msg_enable = 0x7FFF;
 
+	if (!rtl_ops_init(tp, id)) {
+		netif_err(tp, probe, netdev, "Unknown Device");
+		return -ENODEV;
+	}
+
 	tasklet_init(&tp->tl, bottom_half, (unsigned long)tp);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
 
@@ -2128,7 +2171,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->mii.supports_gmii = 0;
 
 	r8152b_get_version(tp);
-	r8152b_init(tp);
+	tp->rtl_ops.init(tp);
 	set_ethernet_addr(tp);
 
 	ret = alloc_all_mem(tp);
@@ -2163,7 +2206,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 		set_bit(RTL8152_UNPLUG, &tp->flags);
 		tasklet_kill(&tp->tl);
 		unregister_netdev(tp->netdev);
-		rtl8152_unload(tp);
+		tp->rtl_ops.unload(tp);
 		free_all_mem(tp);
 		free_netdev(tp->netdev);
 	}
-- 
1.8.3.1
