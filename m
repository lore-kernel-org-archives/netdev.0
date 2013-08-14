From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 3/3] net/usb/r8152: enable interrupt transfer
Date: Wed, 14 Aug 2013 20:54:40 +0800
Message-ID: <1376484880-741-3-git-send-email-hayeswang@realtek.com>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com>
 <1376484880-741-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376484880-741-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the interrupt transfer to replace polling link status.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 140 ++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 113 insertions(+), 27 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4d938a7..ef2498c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -272,6 +272,9 @@ enum rtl_register_content {
 
 #define RTL8152_MAX_TX		10
 #define RTL8152_MAX_RX		10
+#define INTBUFSIZE		2
+
+#define INTR_LINK		0x0004
 
 #define RTL8152_REQT_READ	0xc0
 #define RTL8152_REQT_WRITE	0x40
@@ -292,7 +295,8 @@ enum rtl_register_content {
 enum rtl8152_flags {
 	RTL8152_UNPLUG = 0,
 	RTL8152_SET_RX_MODE,
-	WORK_ENABLE
+	WORK_ENABLE,
+	RTL8152_LINK_CHG,
 };
 
 /* Define these values to match your device */
@@ -347,7 +351,9 @@ struct r8152 {
 	unsigned long flags;
 	struct usb_device *udev;
 	struct tasklet_struct tl;
+	struct usb_interface *intf;
 	struct net_device *netdev;
+	struct urb *intr_urb;
 	struct tx_agg tx_info[RTL8152_MAX_TX];
 	struct rx_agg rx_info[RTL8152_MAX_RX];
 	struct list_head rx_done, tx_free;
@@ -355,8 +361,10 @@ struct r8152 {
 	spinlock_t rx_lock, tx_lock;
 	struct delayed_work schedule;
 	struct mii_if_info mii;
+	int intr_interval;
 	u32 msg_enable;
 	u16 ocp_base;
+	u8 *intr_buff;
 	u8 version;
 	u8 speed;
 };
@@ -860,6 +868,62 @@ static void write_bulk_callback(struct urb *urb)
 		tasklet_schedule(&tp->tl);
 }
 
+static void intr_callback(struct urb *urb)
+{
+	struct r8152 *tp;
+	__u16 *d;
+	int status = urb->status;
+	int res;
+
+	tp = urb->context;
+	if (!tp)
+		return;
+
+	if (!test_bit(WORK_ENABLE, &tp->flags))
+		return;
+
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
+	switch (status) {
+	case 0:			/* success */
+		break;
+	case -ECONNRESET:	/* unlink */
+	case -ESHUTDOWN:
+		netif_device_detach(tp->netdev);
+	case -ENOENT:
+		return;
+	case -EOVERFLOW:
+		netif_info(tp, intr, tp->netdev, "intr status -EOVERFLOW\n");
+		goto resubmit;
+	/* -EPIPE:  should clear the halt */
+	default:
+		netif_info(tp, intr, tp->netdev, "intr status %d\n", status);
+		goto resubmit;
+	}
+
+	d = urb->transfer_buffer;
+	if (INTR_LINK & __le16_to_cpu(d[0])) {
+		if (!(tp->speed & LINK_STATUS)) {
+			set_bit(RTL8152_LINK_CHG, &tp->flags);
+			schedule_delayed_work(&tp->schedule, 0);
+		}
+	} else {
+		if (tp->speed & LINK_STATUS) {
+			set_bit(RTL8152_LINK_CHG, &tp->flags);
+			schedule_delayed_work(&tp->schedule, 0);
+		}
+	}
+
+resubmit:
+	res = usb_submit_urb(urb, GFP_ATOMIC);
+	if (res == -ENODEV)
+		netif_device_detach(tp->netdev);
+	else if (res)
+		netif_err(tp, intr, tp->netdev,
+			"can't resubmit intr, status %d\n", res);
+}
+
 static inline void *rx_agg_align(void *data)
 {
 	return (void *)ALIGN((uintptr_t)data, 8);
@@ -899,11 +963,24 @@ static void free_all_mem(struct r8152 *tp)
 			tp->tx_info[i].head = NULL;
 		}
 	}
+
+	if (tp->intr_urb) {
+		usb_free_urb(tp->intr_urb);
+		tp->intr_urb = NULL;
+	}
+
+	if (tp->intr_buff) {
+		kfree(tp->intr_buff);
+		tp->intr_buff = NULL;
+	}
 }
 
 static int alloc_all_mem(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
+	struct usb_interface *intf = tp->intf;
+	struct usb_host_interface *alt = intf->cur_altsetting;
+	struct usb_host_endpoint *ep_intr = alt->endpoint + 2;
 	struct urb *urb;
 	int node, i;
 	u8 *buf;
@@ -968,6 +1045,19 @@ static int alloc_all_mem(struct r8152 *tp)
 		list_add_tail(&tp->tx_info[i].list, &tp->tx_free);
 	}
 
+	tp->intr_urb = usb_alloc_urb(0, GFP_KERNEL);
+	if (!tp->intr_urb)
+		goto err1;
+
+	tp->intr_buff = kmalloc(INTBUFSIZE, GFP_KERNEL);
+	if (!tp->intr_buff)
+		goto err1;
+
+	tp->intr_interval = (int)ep_intr->desc.bInterval;
+	usb_fill_int_urb(tp->intr_urb, tp->udev, usb_rcvintpipe(tp->udev, 3),
+		     tp->intr_buff, INTBUFSIZE, intr_callback,
+		     tp, tp->intr_interval);
+
 	return 0;
 
 err1:
@@ -1228,8 +1318,10 @@ static void rtl8152_set_rx_mode(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 
-	if (tp->speed & LINK_STATUS)
+	if (tp->speed & LINK_STATUS) {
 		set_bit(RTL8152_SET_RX_MODE, &tp->flags);
+		schedule_delayed_work(&tp->schedule, 0);
+	}
 }
 
 static void _rtl8152_set_rx_mode(struct net_device *netdev)
@@ -1648,7 +1740,6 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 	r8152_mdio_write(tp, MII_BMCR, bmcr);
 
 out:
-	schedule_delayed_work(&tp->schedule, 5 * HZ);
 
 	return ret;
 }
@@ -1671,6 +1762,7 @@ static void set_carrier(struct r8152 *tp)
 	struct net_device *netdev = tp->netdev;
 	u8 speed;
 
+	clear_bit(RTL8152_LINK_CHG, &tp->flags);
 	speed = rtl8152_get_speed(tp);
 
 	if (speed & LINK_STATUS) {
@@ -1700,13 +1792,12 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		goto out1;
 
-	set_carrier(tp);
+	if (test_bit(RTL8152_LINK_CHG, &tp->flags))
+		set_carrier(tp);
 
 	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
 		_rtl8152_set_rx_mode(tp->netdev);
 
-	schedule_delayed_work(&tp->schedule, HZ);
-
 out1:
 	return;
 }
@@ -1716,28 +1807,20 @@ static int rtl8152_open(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int res = 0;
 
-	tp->speed = rtl8152_get_speed(tp);
-	if (tp->speed & LINK_STATUS) {
-		res = rtl8152_enable(tp);
-		if (res) {
-			if (res == -ENODEV)
-				netif_device_detach(tp->netdev);
-
-			netif_err(tp, ifup, netdev,
-				  "rtl8152_open failed: %d\n", res);
-			return res;
-		}
-
-		netif_carrier_on(netdev);
-	} else {
-		netif_stop_queue(netdev);
-		netif_carrier_off(netdev);
+	res = usb_submit_urb(tp->intr_urb, GFP_KERNEL);
+	if (res) {
+		if (res == -ENODEV)
+			netif_device_detach(tp->netdev);
+		netif_warn(tp, ifup, netdev,
+			"intr_urb submit failed: %d\n", res);
+		return res;
 	}
 
 	rtl8152_set_speed(tp, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL);
+	tp->speed = 0;
+	netif_carrier_off(netdev);
 	netif_start_queue(netdev);
 	set_bit(WORK_ENABLE, &tp->flags);
-	schedule_delayed_work(&tp->schedule, 0);
 
 	return res;
 }
@@ -1747,6 +1830,7 @@ static int rtl8152_close(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int res = 0;
 
+	usb_kill_urb(tp->intr_urb);
 	clear_bit(WORK_ENABLE, &tp->flags);
 	cancel_delayed_work_sync(&tp->schedule);
 	netif_stop_queue(netdev);
@@ -1872,6 +1956,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 
 	if (netif_running(tp->netdev)) {
 		clear_bit(WORK_ENABLE, &tp->flags);
+		usb_kill_urb(tp->intr_urb);
 		cancel_delayed_work_sync(&tp->schedule);
 		tasklet_disable(&tp->tl);
 	}
@@ -1888,10 +1973,11 @@ static int rtl8152_resume(struct usb_interface *intf)
 	r8152b_init(tp);
 	netif_device_attach(tp->netdev);
 	if (netif_running(tp->netdev)) {
-		rtl8152_enable(tp);
+		rtl8152_set_speed(tp, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL);
+		tp->speed = 0;
+		netif_carrier_off(tp->netdev);
 		set_bit(WORK_ENABLE, &tp->flags);
-		set_bit(RTL8152_SET_RX_MODE, &tp->flags);
-		schedule_delayed_work(&tp->schedule, 0);
+		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 		tasklet_enable(&tp->tl);
 	}
 
@@ -2027,13 +2113,13 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	tp->udev = udev;
 	tp->netdev = netdev;
+	tp->intf = intf;
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
 
 	netdev->features |= NETIF_F_IP_CSUM;
 	netdev->hw_features = NETIF_F_IP_CSUM;
 	SET_ETHTOOL_OPS(netdev, &ops);
-	tp->speed = 0;
 
 	tp->mii.dev = netdev;
 	tp->mii.mdio_read = read_mii_word;
-- 
1.8.3.1
