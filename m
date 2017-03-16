From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 net-next] r8152: simply the arguments
Date: Thu, 16 Mar 2017 14:32:22 +0800
Message-ID: <1394712342-15778-254-Taiwan-albertk@realtek.com>
References: <1394712342-15778-253-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-253-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace &tp->napi with napi and tp->netdev with netdev.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 43 ++++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 227e1fd..4b85e95 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1761,6 +1761,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
 	unsigned long flags;
 	struct list_head *cursor, *next, rx_queue;
 	int ret = 0, work_done = 0;
+	struct napi_struct *napi = &tp->napi;
 
 	if (!skb_queue_empty(&tp->rx_queue)) {
 		while (work_done < budget) {
@@ -1773,7 +1774,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
 				break;
 
 			pkt_len = skb->len;
-			napi_gro_receive(&tp->napi, skb);
+			napi_gro_receive(napi, skb);
 			work_done++;
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_len;
@@ -1823,7 +1824,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
 			pkt_len -= CRC_SIZE;
 			rx_data += sizeof(struct rx_desc);
 
-			skb = napi_alloc_skb(&tp->napi, pkt_len);
+			skb = napi_alloc_skb(napi, pkt_len);
 			if (!skb) {
 				stats->rx_dropped++;
 				goto find_next_rx;
@@ -1835,7 +1836,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
 			skb->protocol = eth_type_trans(skb, netdev);
 			rtl_rx_vlan_tag(rx_desc, skb);
 			if (work_done < budget) {
-				napi_gro_receive(&tp->napi, skb);
+				napi_gro_receive(napi, skb);
 				work_done++;
 				stats->rx_packets++;
 				stats->rx_bytes += pkt_len;
@@ -3150,6 +3151,7 @@ static bool rtl8153_in_nway(struct r8152 *tp)
 static void set_carrier(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
+	struct napi_struct *napi = &tp->napi;
 	u8 speed;
 
 	speed = rtl8152_get_speed(tp);
@@ -3159,7 +3161,7 @@ static void set_carrier(struct r8152 *tp)
 			tp->rtl_ops.enable(tp);
 			set_bit(RTL8152_SET_RX_MODE, &tp->flags);
 			netif_stop_queue(netdev);
-			napi_disable(&tp->napi);
+			napi_disable(napi);
 			netif_carrier_on(netdev);
 			rtl_start_rx(tp);
 			napi_enable(&tp->napi);
@@ -3169,9 +3171,9 @@ static void set_carrier(struct r8152 *tp)
 	} else {
 		if (netif_carrier_ok(netdev)) {
 			netif_carrier_off(netdev);
-			napi_disable(&tp->napi);
+			napi_disable(napi);
 			tp->rtl_ops.disable(tp);
-			napi_enable(&tp->napi);
+			napi_enable(napi);
 			netif_info(tp, link, netdev, "carrier off\n");
 		}
 	}
@@ -3633,11 +3635,13 @@ static int rtl8152_runtime_suspend(struct r8152 *tp)
 		tp->rtl_ops.autosuspend_en(tp, true);
 
 		if (netif_carrier_ok(netdev)) {
-			napi_disable(&tp->napi);
+			struct napi_struct *napi = &tp->napi;
+
+			napi_disable(napi);
 			rtl_stop_rx(tp);
 			rxdy_gated_en(tp, false);
 			ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, rcr);
-			napi_enable(&tp->napi);
+			napi_enable(napi);
 		}
 	}
 
@@ -3653,12 +3657,14 @@ static int rtl8152_system_suspend(struct r8152 *tp)
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
+		struct napi_struct *napi = &tp->napi;
+
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
-		napi_disable(&tp->napi);
+		napi_disable(napi);
 		cancel_delayed_work_sync(&tp->schedule);
 		tp->rtl_ops.down(tp);
-		napi_enable(&tp->napi);
+		napi_enable(napi);
 	}
 
 	return ret;
@@ -3684,35 +3690,38 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 static int rtl8152_resume(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
+	struct net_device *netdev = tp->netdev;
 
 	mutex_lock(&tp->control);
 
 	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 		tp->rtl_ops.init(tp);
 		queue_delayed_work(system_long_wq, &tp->hw_phy_work, 0);
-		netif_device_attach(tp->netdev);
+		netif_device_attach(netdev);
 	}
 
-	if (netif_running(tp->netdev) && tp->netdev->flags & IFF_UP) {
+	if (netif_running(netdev) && netdev->flags & IFF_UP) {
 		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+			struct napi_struct *napi = &tp->napi;
+
 			tp->rtl_ops.autosuspend_en(tp, false);
-			napi_disable(&tp->napi);
+			napi_disable(napi);
 			set_bit(WORK_ENABLE, &tp->flags);
-			if (netif_carrier_ok(tp->netdev))
+			if (netif_carrier_ok(netdev))
 				rtl_start_rx(tp);
-			napi_enable(&tp->napi);
+			napi_enable(napi);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 			smp_mb__after_atomic();
 			if (!list_empty(&tp->rx_done))
 				napi_schedule(&tp->napi);
 		} else {
 			tp->rtl_ops.up(tp);
-			netif_carrier_off(tp->netdev);
+			netif_carrier_off(netdev);
 			set_bit(WORK_ENABLE, &tp->flags);
 		}
 		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 	} else if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
-		if (tp->netdev->flags & IFF_UP)
+		if (netdev->flags & IFF_UP)
 			tp->rtl_ops.autosuspend_en(tp, false);
 		clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 	}
-- 
2.7.4
