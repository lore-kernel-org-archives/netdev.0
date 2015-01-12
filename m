From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: replace tasklet with NAPI
Date: Mon, 12 Jan 2015 12:06:23 +0800
Message-ID: <1394712342-15778-117-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace tasklet with NAPI.

Add rx_queue to queue the remaining rx packets if the number of the
rx packets is more than the request from poll().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 120 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 85 insertions(+), 35 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b23426e..50387fe 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -27,7 +27,7 @@
 #include <linux/usb/cdc.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.07.0 (2014/10/09)"
+#define DRIVER_VERSION "v1.08.0 (2015/01/13)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -448,6 +448,7 @@ enum rtl_register_content {
 #define RTL8152_RMS		(VLAN_ETH_FRAME_LEN + VLAN_HLEN)
 #define RTL8153_RMS		RTL8153_MAX_PACKET
 #define RTL8152_TX_TIMEOUT	(5 * HZ)
+#define RTL8152_NAPI_WEIGHT	64
 
 /* rtl8152 flags */
 enum rtl8152_flags {
@@ -457,7 +458,7 @@ enum rtl8152_flags {
 	RTL8152_LINK_CHG,
 	SELECTIVE_SUSPEND,
 	PHY_RESET,
-	SCHEDULE_TASKLET,
+	SCHEDULE_NAPI,
 };
 
 /* Define these values to match your device */
@@ -549,14 +550,14 @@ struct tx_agg {
 struct r8152 {
 	unsigned long flags;
 	struct usb_device *udev;
-	struct tasklet_struct tl;
+	struct napi_struct napi;
 	struct usb_interface *intf;
 	struct net_device *netdev;
 	struct urb *intr_urb;
 	struct tx_agg tx_info[RTL8152_MAX_TX];
 	struct rx_agg rx_info[RTL8152_MAX_RX];
 	struct list_head rx_done, tx_free;
-	struct sk_buff_head tx_queue;
+	struct sk_buff_head tx_queue, rx_queue;
 	spinlock_t rx_lock, tx_lock;
 	struct delayed_work schedule;
 	struct mii_if_info mii;
@@ -1062,7 +1063,7 @@ static void read_bulk_callback(struct urb *urb)
 		spin_lock(&tp->rx_lock);
 		list_add_tail(&agg->list, &tp->rx_done);
 		spin_unlock(&tp->rx_lock);
-		tasklet_schedule(&tp->tl);
+		napi_schedule(&tp->napi);
 		return;
 	case -ESHUTDOWN:
 		set_bit(RTL8152_UNPLUG, &tp->flags);
@@ -1126,7 +1127,7 @@ static void write_bulk_callback(struct urb *urb)
 		return;
 
 	if (!skb_queue_empty(&tp->tx_queue))
-		tasklet_schedule(&tp->tl);
+		napi_schedule(&tp->napi);
 }
 
 static void intr_callback(struct urb *urb)
@@ -1245,6 +1246,7 @@ static int alloc_all_mem(struct r8152 *tp)
 	spin_lock_init(&tp->tx_lock);
 	INIT_LIST_HEAD(&tp->tx_free);
 	skb_queue_head_init(&tp->tx_queue);
+	skb_queue_head_init(&tp->rx_queue);
 
 	for (i = 0; i < RTL8152_MAX_RX; i++) {
 		buf = kmalloc_node(agg_buf_sz, GFP_KERNEL, node);
@@ -1649,13 +1651,32 @@ return_result:
 	return checksum;
 }
 
-static void rx_bottom(struct r8152 *tp)
+static int rx_bottom(struct r8152 *tp, int budget)
 {
 	unsigned long flags;
 	struct list_head *cursor, *next, rx_queue;
+	int work_done = 0;
+
+	if (!skb_queue_empty(&tp->rx_queue)) {
+		while (work_done < budget) {
+			struct sk_buff *skb = __skb_dequeue(&tp->rx_queue);
+			struct net_device *netdev = tp->netdev;
+			struct net_device_stats *stats = &netdev->stats;
+			unsigned int pkt_len;
+
+			if (!skb)
+				break;
+
+			pkt_len = skb->len;
+			napi_gro_receive(&tp->napi, skb);
+			work_done++;
+			stats->rx_packets++;
+			stats->rx_bytes += pkt_len;
+		}
+	}
 
 	if (list_empty(&tp->rx_done))
-		return;
+		goto out1;
 
 	INIT_LIST_HEAD(&rx_queue);
 	spin_lock_irqsave(&tp->rx_lock, flags);
@@ -1708,9 +1729,14 @@ static void rx_bottom(struct r8152 *tp)
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, netdev);
 			rtl_rx_vlan_tag(rx_desc, skb);
-			netif_receive_skb(skb);
-			stats->rx_packets++;
-			stats->rx_bytes += pkt_len;
+			if (work_done < budget) {
+				napi_gro_receive(&tp->napi, skb);
+				work_done++;
+				stats->rx_packets++;
+				stats->rx_bytes += pkt_len;
+			} else {
+				__skb_queue_tail(&tp->rx_queue, skb);
+			}
 
 find_next_rx:
 			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
@@ -1722,6 +1748,9 @@ find_next_rx:
 submit:
 		r8152_submit_rx(tp, agg, GFP_ATOMIC);
 	}
+
+out1:
+	return work_done;
 }
 
 static void tx_bottom(struct r8152 *tp)
@@ -1761,12 +1790,8 @@ static void tx_bottom(struct r8152 *tp)
 	} while (res == 0);
 }
 
-static void bottom_half(unsigned long data)
+static void bottom_half(struct r8152 *tp)
 {
-	struct r8152 *tp;
-
-	tp = (struct r8152 *)data;
-
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
 
@@ -1778,12 +1803,28 @@ static void bottom_half(unsigned long data)
 	if (!netif_carrier_ok(tp->netdev))
 		return;
 
-	clear_bit(SCHEDULE_TASKLET, &tp->flags);
+	clear_bit(SCHEDULE_NAPI, &tp->flags);
 
-	rx_bottom(tp);
 	tx_bottom(tp);
 }
 
+static int r8152_poll(struct napi_struct *napi, int budget)
+{
+	struct r8152 *tp = container_of(napi, struct r8152, napi);
+	int work_done;
+
+	work_done = rx_bottom(tp, budget);
+	bottom_half(tp);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		if (!list_empty(&tp->rx_done))
+			napi_schedule(napi);
+	}
+
+	return work_done;
+}
+
 static
 int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 {
@@ -1810,7 +1851,11 @@ int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 		spin_lock_irqsave(&tp->rx_lock, flags);
 		list_add_tail(&agg->list, &tp->rx_done);
 		spin_unlock_irqrestore(&tp->rx_lock, flags);
-		tasklet_schedule(&tp->tl);
+
+		netif_err(tp, rx_err, tp->netdev,
+			  "Couldn't submit rx[%p], ret = %d\n", agg, ret);
+
+		napi_schedule(&tp->napi);
 	}
 
 	return ret;
@@ -1929,11 +1974,11 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 
 	if (!list_empty(&tp->tx_free)) {
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
-			set_bit(SCHEDULE_TASKLET, &tp->flags);
+			set_bit(SCHEDULE_NAPI, &tp->flags);
 			schedule_delayed_work(&tp->schedule, 0);
 		} else {
 			usb_mark_last_busy(tp->udev);
-			tasklet_schedule(&tp->tl);
+			napi_schedule(&tp->napi);
 		}
 	} else if (skb_queue_len(&tp->tx_queue) > tp->tx_qlen) {
 		netif_stop_queue(netdev);
@@ -2012,6 +2057,7 @@ static int rtl_start_rx(struct r8152 *tp)
 {
 	int i, ret = 0;
 
+	napi_disable(&tp->napi);
 	INIT_LIST_HEAD(&tp->rx_done);
 	for (i = 0; i < RTL8152_MAX_RX; i++) {
 		INIT_LIST_HEAD(&tp->rx_info[i].list);
@@ -2019,6 +2065,7 @@ static int rtl_start_rx(struct r8152 *tp)
 		if (ret)
 			break;
 	}
+	napi_enable(&tp->napi);
 
 	if (ret && ++i < RTL8152_MAX_RX) {
 		struct list_head rx_queue;
@@ -2049,6 +2096,9 @@ static int rtl_stop_rx(struct r8152 *tp)
 	for (i = 0; i < RTL8152_MAX_RX; i++)
 		usb_kill_urb(tp->rx_info[i].urb);
 
+	while (!skb_queue_empty(&tp->rx_queue))
+		dev_kfree_skb(__skb_dequeue(&tp->rx_queue));
+
 	return 0;
 }
 
@@ -2884,9 +2934,9 @@ static void set_carrier(struct r8152 *tp)
 	} else {
 		if (tp->speed & LINK_STATUS) {
 			netif_carrier_off(netdev);
-			tasklet_disable(&tp->tl);
+			napi_disable(&tp->napi);
 			tp->rtl_ops.disable(tp);
-			tasklet_enable(&tp->tl);
+			napi_enable(&tp->napi);
 		}
 	}
 	tp->speed = speed;
@@ -2919,10 +2969,11 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
 		_rtl8152_set_rx_mode(tp->netdev);
 
-	if (test_bit(SCHEDULE_TASKLET, &tp->flags) &&
+	/* don't schedule napi before linking */
+	if (test_bit(SCHEDULE_NAPI, &tp->flags) &&
 	    (tp->speed & LINK_STATUS)) {
-		clear_bit(SCHEDULE_TASKLET, &tp->flags);
-		tasklet_schedule(&tp->tl);
+		clear_bit(SCHEDULE_NAPI, &tp->flags);
+		napi_schedule(&tp->napi);
 	}
 
 	if (test_bit(PHY_RESET, &tp->flags))
@@ -2983,7 +3034,7 @@ static int rtl8152_open(struct net_device *netdev)
 			   res);
 		free_all_mem(tp);
 	} else {
-		tasklet_enable(&tp->tl);
+		napi_enable(&tp->napi);
 	}
 
 	mutex_unlock(&tp->control);
@@ -2999,7 +3050,7 @@ static int rtl8152_close(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int res = 0;
 
-	tasklet_disable(&tp->tl);
+	napi_disable(&tp->napi);
 	clear_bit(WORK_ENABLE, &tp->flags);
 	usb_kill_urb(tp->intr_urb);
 	cancel_delayed_work_sync(&tp->schedule);
@@ -3008,6 +3059,7 @@ static int rtl8152_close(struct net_device *netdev)
 	res = usb_autopm_get_interface(tp->intf);
 	if (res < 0) {
 		rtl_drop_queued_tx(tp);
+		rtl_stop_rx(tp);
 	} else {
 		mutex_lock(&tp->control);
 
@@ -3263,7 +3315,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
-		tasklet_disable(&tp->tl);
+		napi_disable(&tp->napi);
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 			rtl_stop_rx(tp);
 			rtl_runtime_suspend_enable(tp, true);
@@ -3271,7 +3323,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 			cancel_delayed_work_sync(&tp->schedule);
 			tp->rtl_ops.down(tp);
 		}
-		tasklet_enable(&tp->tl);
+		napi_enable(&tp->napi);
 	}
 out1:
 	mutex_unlock(&tp->control);
@@ -3855,7 +3907,6 @@ static int rtl8152_probe(struct usb_interface *intf,
 	if (ret)
 		goto out;
 
-	tasklet_init(&tp->tl, bottom_half, (unsigned long)tp);
 	mutex_init(&tp->control);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
 
@@ -3891,6 +3942,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	set_ethernet_addr(tp);
 
 	usb_set_intfdata(intf, tp);
+	netif_napi_add(netdev, &tp->napi, r8152_poll, RTL8152_NAPI_WEIGHT);
 
 	ret = register_netdev(netdev);
 	if (ret != 0) {
@@ -3904,15 +3956,13 @@ static int rtl8152_probe(struct usb_interface *intf,
 	else
 		device_set_wakeup_enable(&udev->dev, false);
 
-	tasklet_disable(&tp->tl);
-
 	netif_info(tp, probe, netdev, "%s\n", DRIVER_VERSION);
 
 	return 0;
 
 out1:
+	netif_napi_del(&tp->napi);
 	usb_set_intfdata(intf, NULL);
-	tasklet_kill(&tp->tl);
 out:
 	free_netdev(netdev);
 	return ret;
@@ -3929,7 +3979,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 		if (udev->state == USB_STATE_NOTATTACHED)
 			set_bit(RTL8152_UNPLUG, &tp->flags);
 
-		tasklet_kill(&tp->tl);
+		netif_napi_del(&tp->napi);
 		unregister_netdev(tp->netdev);
 		tp->rtl_ops.unload(tp);
 		free_netdev(tp->netdev);
-- 
2.1.0
