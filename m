From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: reduce memory copy for rx
Date: Wed, 3 Dec 2014 13:14:38 +0800
Message-ID: <1394712342-15778-105-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the data size is more than half of the AGG_BUG_SZ, allocate a new
rx buffer and use skb_clone() to avoid the memory copy.

The original method is that allocate the memory and copy data for each
packet in a rx buffer. The new one is that when the data size for a rx
buffer is more than RX_THRESHOLD_CLONED, allocate a new rx buffer and
use skb_clone for each packet in the rx buffer. According to the
experiment, the new mothod has better performance.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 110 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 77 insertions(+), 33 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4a9ece0..e44b9fb 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,7 +26,7 @@
 #include <linux/mdio.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.07.0 (2014/10/09)"
+#define DRIVER_VERSION "v1.08.0 (2014/11/27)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -447,6 +447,8 @@ enum rtl_register_content {
 #define RTL8152_RMS		(VLAN_ETH_FRAME_LEN + VLAN_HLEN)
 #define RTL8153_RMS		RTL8153_MAX_PACKET
 #define RTL8152_TX_TIMEOUT	(5 * HZ)
+#define AGG_BUF_SZ		16384 /* 16K */
+#define RX_THRESHOLD_CLONED	(AGG_BUF_SZ / 2)
 
 /* rtl8152 flags */
 enum rtl8152_flags {
@@ -534,8 +536,7 @@ struct rx_agg {
 	struct list_head list;
 	struct urb *urb;
 	struct r8152 *context;
-	void *buffer;
-	void *head;
+	struct sk_buff *skb;
 };
 
 struct tx_agg {
@@ -605,9 +606,8 @@ enum tx_csum_stat {
  * The RTL chips use a 64 element hash table based on the Ethernet CRC.
  */
 static const int multicast_filter_limit = 32;
-static unsigned int agg_buf_sz = 16384;
 
-#define RTL_LIMITED_TSO_SIZE	(agg_buf_sz - sizeof(struct tx_desc) - \
+#define RTL_LIMITED_TSO_SIZE	(AGG_BUF_SZ - sizeof(struct tx_desc) - \
 				 VLAN_ETH_HLEN - VLAN_HLEN)
 
 static
@@ -1210,9 +1210,8 @@ static void free_all_mem(struct r8152 *tp)
 		usb_free_urb(tp->rx_info[i].urb);
 		tp->rx_info[i].urb = NULL;
 
-		kfree(tp->rx_info[i].buffer);
-		tp->rx_info[i].buffer = NULL;
-		tp->rx_info[i].head = NULL;
+		dev_kfree_skb(tp->rx_info[i].skb);
+		tp->rx_info[i].skb = NULL;
 	}
 
 	for (i = 0; i < RTL8152_MAX_TX; i++) {
@@ -1231,6 +1230,31 @@ static void free_all_mem(struct r8152 *tp)
 	tp->intr_buff = NULL;
 }
 
+static struct sk_buff *rtl_alloc_rx_skb(struct r8152 *tp, gfp_t gfp_mask)
+{
+	struct net_device *netdev = tp->netdev;
+	struct sk_buff *skb;
+
+	skb = __netdev_alloc_skb(netdev, AGG_BUF_SZ, gfp_mask);
+	if (!skb)
+		goto out1;
+
+	if (skb->data != rx_agg_align(skb->data)) {
+		int rl;
+
+		dev_kfree_skb_any(skb);
+		skb = __netdev_alloc_skb(netdev, AGG_BUF_SZ + RX_ALIGN,
+					 gfp_mask);
+		if (!skb)
+			goto out1;
+
+		rl = (int)(rx_agg_align(skb->data) - (void *)skb->data);
+		skb_reserve(skb, rl);
+	}
+out1:
+	return skb;
+}
+
 static int alloc_all_mem(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
@@ -1239,7 +1263,6 @@ static int alloc_all_mem(struct r8152 *tp)
 	struct usb_host_endpoint *ep_intr = alt->endpoint + 2;
 	struct urb *urb;
 	int node, i;
-	u8 *buf;
 
 	node = netdev->dev.parent ? dev_to_node(netdev->dev.parent) : -1;
 
@@ -1249,39 +1272,33 @@ static int alloc_all_mem(struct r8152 *tp)
 	skb_queue_head_init(&tp->tx_queue);
 
 	for (i = 0; i < RTL8152_MAX_RX; i++) {
-		buf = kmalloc_node(agg_buf_sz, GFP_KERNEL, node);
-		if (!buf)
-			goto err1;
+		struct sk_buff *skb;
 
-		if (buf != rx_agg_align(buf)) {
-			kfree(buf);
-			buf = kmalloc_node(agg_buf_sz + RX_ALIGN, GFP_KERNEL,
-					   node);
-			if (!buf)
-				goto err1;
-		}
+		skb = rtl_alloc_rx_skb(tp, GFP_KERNEL);
+		if (!skb)
+			goto err1;
 
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
-			kfree(buf);
+			dev_kfree_skb(skb);
 			goto err1;
 		}
 
 		INIT_LIST_HEAD(&tp->rx_info[i].list);
 		tp->rx_info[i].context = tp;
 		tp->rx_info[i].urb = urb;
-		tp->rx_info[i].buffer = buf;
-		tp->rx_info[i].head = rx_agg_align(buf);
+		tp->rx_info[i].skb = skb;
 	}
 
 	for (i = 0; i < RTL8152_MAX_TX; i++) {
-		buf = kmalloc_node(agg_buf_sz, GFP_KERNEL, node);
+		u8 *buf = kmalloc_node(AGG_BUF_SZ, GFP_KERNEL, node);
+
 		if (!buf)
 			goto err1;
 
 		if (buf != tx_agg_align(buf)) {
 			kfree(buf);
-			buf = kmalloc_node(agg_buf_sz + TX_ALIGN, GFP_KERNEL,
+			buf = kmalloc_node(AGG_BUF_SZ + TX_ALIGN, GFP_KERNEL,
 					   node);
 			if (!buf)
 				goto err1;
@@ -1538,7 +1555,7 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 	tx_data = agg->head;
 	agg->skb_num = 0;
 	agg->skb_len = 0;
-	remain = agg_buf_sz;
+	remain = AGG_BUF_SZ;
 
 	while (remain >= ETH_ZLEN + sizeof(struct tx_desc)) {
 		struct tx_desc *tx_desc;
@@ -1587,7 +1604,7 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 
 		dev_kfree_skb_any(skb);
 
-		remain = agg_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
+		remain = AGG_BUF_SZ - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
 	if (!skb_queue_empty(&skb_head)) {
@@ -1666,6 +1683,8 @@ static void rx_bottom(struct r8152 *tp)
 
 	list_for_each_safe(cursor, next, &rx_queue) {
 		struct rx_desc *rx_desc;
+		struct sk_buff *rx_skb;
+		bool cloned = false;
 		struct rx_agg *agg;
 		int len_used = 0;
 		struct urb *urb;
@@ -1678,10 +1697,21 @@ static void rx_bottom(struct r8152 *tp)
 		if (urb->actual_length < ETH_ZLEN)
 			goto submit;
 
-		rx_desc = agg->head;
-		rx_data = agg->head;
+		rx_skb = agg->skb;
+		rx_desc = (struct rx_desc *)rx_skb->data;
+		rx_data = rx_skb->data;
 		len_used += sizeof(struct rx_desc);
 
+		if (!NET_IP_ALIGN && urb->actual_length > RX_THRESHOLD_CLONED) {
+			struct sk_buff *new_skb;
+
+			new_skb = rtl_alloc_rx_skb(tp, GFP_ATOMIC);
+			if (new_skb) {
+				agg->skb = new_skb;
+				cloned = true;
+			}
+		}
+
 		while (urb->actual_length > len_used) {
 			struct net_device *netdev = tp->netdev;
 			struct net_device_stats *stats = &netdev->stats;
@@ -1699,14 +1729,23 @@ static void rx_bottom(struct r8152 *tp)
 			pkt_len -= CRC_SIZE;
 			rx_data += sizeof(struct rx_desc);
 
-			skb = netdev_alloc_skb_ip_align(netdev, pkt_len);
+			if (cloned)
+				skb = skb_clone(rx_skb, GFP_ATOMIC);
+			else
+				skb = netdev_alloc_skb_ip_align(netdev,
+								pkt_len);
 			if (!skb) {
 				stats->rx_dropped++;
 				goto find_next_rx;
 			}
 
 			skb->ip_summed = r8152_rx_csum(tp, rx_desc);
-			memcpy(skb->data, rx_data, pkt_len);
+
+			if (cloned)
+				skb_reserve(skb, (int)(rx_data - rx_skb->data));
+			else
+				memcpy(skb->data, rx_data, pkt_len);
+
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, netdev);
 			rtl_rx_vlan_tag(rx_desc, skb);
@@ -1717,10 +1756,14 @@ static void rx_bottom(struct r8152 *tp)
 find_next_rx:
 			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
 			rx_desc = (struct rx_desc *)rx_data;
-			len_used = (int)(rx_data - (u8 *)agg->head);
+			len_used = (int)(rx_data - rx_skb->data);
 			len_used += sizeof(struct rx_desc);
 		}
 
+		/* free the cloned skb */
+		if (cloned)
+			dev_kfree_skb_any(rx_skb);
+
 submit:
 		r8152_submit_rx(tp, agg, GFP_ATOMIC);
 	}
@@ -1789,10 +1832,11 @@ static void bottom_half(unsigned long data)
 static
 int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 {
+	struct sk_buff *skb = agg->skb;
 	int ret;
 
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
-			  agg->head, agg_buf_sz,
+			  skb->data, AGG_BUF_SZ,
 			  (usb_complete_t)read_bulk_callback, agg);
 
 	ret = usb_submit_urb(agg->urb, mem_flags);
@@ -1951,7 +1995,7 @@ static void set_tx_qlen(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
 
-	tp->tx_qlen = agg_buf_sz / (netdev->mtu + VLAN_ETH_HLEN + VLAN_HLEN +
+	tp->tx_qlen = AGG_BUF_SZ / (netdev->mtu + VLAN_ETH_HLEN + VLAN_HLEN +
 				    sizeof(struct tx_desc));
 }
 
-- 
1.9.3
