From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] net/usb/r8152: support aggregation
Date: Tue, 13 Aug 2013 15:28:31 +0800
Message-ID: <1376378913-879-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable the tx/rx aggregation which could contain one or more packets
for each bulk in/out. This could reduce the loading of the host
controller by sending less bulk transfer.

The rx packets in the bulk in buffer should be 8-byte aligned, and
the tx packets in the bulk out buffer should be 4-byte aligned.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 627 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 466 insertions(+), 161 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 11c51f2..c6c5aa2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -19,9 +19,10 @@
 #include <linux/crc32.h>
 #include <linux/if_vlan.h>
 #include <linux/uaccess.h>
+#include <linux/list.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.0.0 (2013/05/03)"
+#define DRIVER_VERSION "v1.01.0 (2013/08/12)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152 Based USB 2.0 Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -267,6 +268,9 @@ enum rtl_register_content {
 	FULL_DUP	= 0x01,
 };
 
+#define RTL8152_MAX_TX		10
+#define RTL8152_MAX_RX		10
+
 #define RTL8152_REQT_READ	0xc0
 #define RTL8152_REQT_WRITE	0x40
 #define RTL8152_REQ_GET_REGS	0x05
@@ -285,7 +289,6 @@ enum rtl_register_content {
 /* rtl8152 flags */
 enum rtl8152_flags {
 	RTL8152_UNPLUG = 0,
-	RX_URB_FAIL,
 	RTL8152_SET_RX_MODE,
 	WORK_ENABLE
 };
@@ -315,13 +318,36 @@ struct tx_desc {
 	u32 opts2;
 };
 
+struct rx_agg {
+	struct list_head list;
+	struct urb *urb;
+	void *context;
+	void *buffer;
+	void *head;
+	u8 *data;
+};
+
+struct tx_agg {
+	struct list_head list;
+	struct urb *urb;
+	void *context;
+	void *buffer;
+	void *head;
+	u8 *data;
+	u32 skb_num;
+	u32 skb_len;
+};
+
 struct r8152 {
 	unsigned long flags;
 	struct usb_device *udev;
 	struct tasklet_struct tl;
 	struct net_device *netdev;
-	struct urb *rx_urb, *tx_urb;
-	struct sk_buff *tx_skb, *rx_skb;
+	struct tx_agg tx_info[RTL8152_MAX_TX];
+	struct rx_agg rx_info[RTL8152_MAX_RX];
+	struct list_head rx_done, tx_free;
+	struct sk_buff_head tx_queue;
+	spinlock_t rx_lock, tx_lock;
 	struct delayed_work schedule;
 	struct mii_if_info mii;
 	u32 msg_enable;
@@ -340,6 +366,7 @@ enum rtl_version {
  * The RTL chips use a 64 element hash table based on the Ethernet CRC.
  */
 static const int multicast_filter_limit = 32;
+static unsigned int rx_buf_sz = 16384;
 
 static
 int get_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
@@ -686,6 +713,9 @@ static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
 	ocp_write_word(tp, MCU_TYPE_PLA, ocp_index, data);
 }
 
+static
+int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags);
+
 static inline void set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
@@ -716,26 +746,6 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 	return 0;
 }
 
-static int alloc_all_urbs(struct r8152 *tp)
-{
-	tp->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!tp->rx_urb)
-		return 0;
-	tp->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!tp->tx_urb) {
-		usb_free_urb(tp->rx_urb);
-		return 0;
-	}
-
-	return 1;
-}
-
-static void free_all_urbs(struct r8152 *tp)
-{
-	usb_free_urb(tp->rx_urb);
-	usb_free_urb(tp->tx_urb);
-}
-
 static struct net_device_stats *rtl8152_get_stats(struct net_device *dev)
 {
 	return &dev->stats;
@@ -743,129 +753,417 @@ static struct net_device_stats *rtl8152_get_stats(struct net_device *dev)
 
 static void read_bulk_callback(struct urb *urb)
 {
-	struct r8152 *tp;
-	unsigned pkt_len;
-	struct sk_buff *skb;
 	struct net_device *netdev;
-	struct net_device_stats *stats;
+	unsigned long lockflags;
 	int status = urb->status;
+	struct rx_agg *agg;
+	struct r8152 *tp;
 	int result;
-	struct rx_desc *rx_desc;
 
-	tp = urb->context;
+	agg = urb->context;
+	if (!agg)
+		return;
+
+	tp = agg->context;
 	if (!tp)
 		return;
+
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return;
+
 	netdev = tp->netdev;
 	if (!netif_device_present(netdev))
 		return;
 
-	stats = rtl8152_get_stats(netdev);
 	switch (status) {
 	case 0:
-		break;
+		if (urb->actual_length < ETH_ZLEN)
+			break;
+
+		spin_lock_irqsave(&tp->rx_lock, lockflags);
+		list_add_tail(&agg->list, &tp->rx_done);
+		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+		tasklet_schedule(&tp->tl);
+		return;
 	case -ESHUTDOWN:
 		set_bit(RTL8152_UNPLUG, &tp->flags);
 		netif_device_detach(tp->netdev);
+		return;
 	case -ENOENT:
 		return;	/* the urb is in unlink state */
 	case -ETIME:
 		pr_warn_ratelimited("may be reset is needed?..\n");
-		goto goon;
+		break;
 	default:
 		pr_warn_ratelimited("Rx status %d\n", status);
-		goto goon;
+		break;
 	}
 
-	/* protect against short packets (tell me why we got some?!?) */
-	if (urb->actual_length < sizeof(*rx_desc))
-		goto goon;
-
-
-	rx_desc = (struct rx_desc *)urb->transfer_buffer;
-	pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
-	if (urb->actual_length < sizeof(struct rx_desc) + pkt_len)
-		goto goon;
-
-	skb = netdev_alloc_skb_ip_align(netdev, pkt_len);
-	if (!skb)
-		goto goon;
-
-	memcpy(skb->data, tp->rx_skb->data + sizeof(struct rx_desc), pkt_len);
-	skb_put(skb, pkt_len);
-	skb->protocol = eth_type_trans(skb, netdev);
-	netif_rx(skb);
-	stats->rx_packets++;
-	stats->rx_bytes += pkt_len;
-goon:
-	usb_fill_bulk_urb(tp->rx_urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
-		      tp->rx_skb->data, RTL8152_RMS + sizeof(struct rx_desc),
-		      (usb_complete_t)read_bulk_callback, tp);
-	result = usb_submit_urb(tp->rx_urb, GFP_ATOMIC);
+	result = r8152_submit_rx(tp, agg, GFP_ATOMIC);
 	if (result == -ENODEV) {
 		netif_device_detach(tp->netdev);
 	} else if (result) {
-		set_bit(RX_URB_FAIL, &tp->flags);
-		goto resched;
-	} else {
-		clear_bit(RX_URB_FAIL, &tp->flags);
+		spin_lock_irqsave(&tp->rx_lock, lockflags);
+		list_add_tail(&agg->list, &tp->rx_done);
+		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+		tasklet_schedule(&tp->tl);
 	}
-
-	return;
-resched:
-	tasklet_schedule(&tp->tl);
 }
 
-static void rx_fixup(unsigned long data)
+static void write_bulk_callback(struct urb *urb)
 {
+	struct net_device_stats *stats;
+	unsigned long lockflags;
+	struct tx_agg *agg;
 	struct r8152 *tp;
-	int status;
+	int status = urb->status;
 
-	tp = (struct r8152 *)data;
-	if (!test_bit(WORK_ENABLE, &tp->flags))
+	agg = urb->context;
+	if (!agg)
 		return;
 
-	status = usb_submit_urb(tp->rx_urb, GFP_ATOMIC);
-	if (status == -ENODEV) {
-		netif_device_detach(tp->netdev);
-	} else if (status) {
-		set_bit(RX_URB_FAIL, &tp->flags);
-		goto tlsched;
+	tp = agg->context;
+	if (!tp)
+		return;
+
+	stats = rtl8152_get_stats(tp->netdev);
+	if (status) {
+		pr_warn_ratelimited("Tx status %d\n", status);
+		stats->tx_errors += agg->skb_num;
 	} else {
-		clear_bit(RX_URB_FAIL, &tp->flags);
+		stats->tx_packets += agg->skb_num;
+		stats->tx_bytes += agg->skb_len;
 	}
 
-	return;
-tlsched:
-	tasklet_schedule(&tp->tl);
+	if (!netif_device_present(tp->netdev))
+		return;
+
+	agg->data = agg->head;
+	agg->skb_num = agg->skb_len = 0;
+	spin_lock_irqsave(&tp->tx_lock, lockflags);
+	list_add_tail(&agg->list, &tp->tx_free);
+	spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+
+	if (!skb_queue_empty(&tp->tx_queue))
+		tasklet_schedule(&tp->tl);
 }
 
-static void write_bulk_callback(struct urb *urb)
+static inline void *rx_agg_align(void *data)
 {
-	struct r8152 *tp;
-	int status = urb->status;
+	return (void *)ALIGN((uintptr_t)data, 8);
+}
 
-	tp = urb->context;
-	if (!tp)
+static inline void *tx_agg_align(void *data)
+{
+	return (void *)ALIGN((uintptr_t)data, 4);
+}
+
+static void free_all_mem(struct r8152 *tp)
+{
+	int i;
+
+	for (i = 0; i < RTL8152_MAX_RX; i++) {
+		if (tp->rx_info[i].urb) {
+			usb_free_urb(tp->rx_info[i].urb);
+			tp->rx_info[i].urb = NULL;
+		}
+
+		if (tp->rx_info[i].buffer) {
+			kfree(tp->rx_info[i].buffer);
+			tp->rx_info[i].buffer = NULL;
+			tp->rx_info[i].head = tp->rx_info[i].data = NULL;
+		}
+	}
+
+	for (i = 0; i < RTL8152_MAX_TX; i++) {
+		if (tp->tx_info[i].urb) {
+			usb_free_urb(tp->tx_info[i].urb);
+			tp->tx_info[i].urb = NULL;
+		}
+
+		if (tp->tx_info[i].buffer) {
+			kfree(tp->tx_info[i].buffer);
+			tp->tx_info[i].buffer = NULL;
+			tp->tx_info[i].head = tp->tx_info[i].data = NULL;
+		}
+	}
+}
+
+static int alloc_all_mem(struct r8152 *tp)
+{
+	struct net_device *netdev = tp->netdev;
+	struct urb *urb;
+	int node, i;
+	u8 *buf;
+
+	node = netdev->dev.parent ? dev_to_node(netdev->dev.parent) : -1;
+
+	spin_lock_init(&tp->rx_lock);
+	INIT_LIST_HEAD(&tp->rx_done);
+
+	for (i = 0; i < RTL8152_MAX_RX; i++) {
+		buf = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
+		if (!buf)
+			goto err1;
+
+		if (buf != rx_agg_align(buf)) {
+			kfree(buf);
+			buf = kmalloc_node(rx_buf_sz + 8, GFP_KERNEL, node);
+			if (!buf)
+				goto err1;
+		}
+
+		urb = usb_alloc_urb(0, GFP_KERNEL);
+		if (!urb) {
+			kfree(buf);
+			goto err1;
+		}
+
+		INIT_LIST_HEAD(&tp->rx_info[i].list);
+		tp->rx_info[i].context = tp;
+		tp->rx_info[i].urb = urb;
+		tp->rx_info[i].buffer = buf;
+		tp->rx_info[i].head = tp->rx_info[i].data = rx_agg_align(buf);
+	}
+
+	spin_lock_init(&tp->tx_lock);
+	INIT_LIST_HEAD(&tp->tx_free);
+	skb_queue_head_init(&tp->tx_queue);
+
+	for (i = 0; i < RTL8152_MAX_TX; i++) {
+		buf = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
+		if (!buf)
+			goto err1;
+
+		if (buf != tx_agg_align(buf)) {
+			kfree(buf);
+			buf = kmalloc_node(rx_buf_sz + 4, GFP_KERNEL, node);
+			if (!buf)
+				goto err1;
+		}
+
+		urb = usb_alloc_urb(0, GFP_KERNEL);
+		if (!urb) {
+			kfree(buf);
+			goto err1;
+		}
+
+		INIT_LIST_HEAD(&tp->tx_info[i].list);
+		tp->tx_info[i].context = tp;
+		tp->tx_info[i].urb = urb;
+		tp->tx_info[i].buffer = buf;
+		tp->tx_info[i].head = tp->tx_info[i].data = tx_agg_align(buf);
+
+		list_add_tail(&tp->tx_info[i].list, &tp->tx_free);
+	}
+
+	return 0;
+
+err1:
+	free_all_mem(tp);
+	return -ENOMEM;
+}
+
+static void rx_bottom(struct r8152 *tp)
+{
+	struct net_device_stats *stats;
+	struct net_device *netdev;
+	struct rx_agg *agg;
+	struct rx_desc *rx_desc;
+	unsigned long lockflags;
+	struct list_head *cursor, *next;
+	struct sk_buff *skb;
+	struct urb *urb;
+	unsigned pkt_len;
+	int len_used;
+	u8 *rx_data;
+	int ret;
+
+	netdev = tp->netdev;
+
+	if (!netif_running(netdev))
 		return;
-	dev_kfree_skb_irq(tp->tx_skb);
-	if (!netif_device_present(tp->netdev))
+
+	stats = rtl8152_get_stats(netdev);
+
+	spin_lock_irqsave(&tp->rx_lock, lockflags);
+	list_for_each_safe(cursor, next, &tp->rx_done) {
+		list_del_init(cursor);
+		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+
+		agg = list_entry(cursor, struct rx_agg, list);
+		urb = agg->urb;
+		if (urb->actual_length < ETH_ZLEN) {
+			ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
+			spin_lock_irqsave(&tp->rx_lock, lockflags);
+			if (ret && ret != -ENODEV) {
+				list_add_tail(&agg->list, next);
+				tasklet_schedule(&tp->tl);
+			}
+			continue;
+		}
+
+		len_used = 0;
+		rx_desc = agg->head;
+		rx_data = agg->head;
+		smp_wmb();
+		pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
+		len_used += sizeof(struct rx_desc) + pkt_len;
+
+		while (urb->actual_length >= len_used) {
+			if (pkt_len < ETH_ZLEN)
+				break;
+
+			pkt_len -= 4; /* CRC */
+			rx_data += sizeof(struct rx_desc);
+
+			skb = netdev_alloc_skb_ip_align(netdev, pkt_len);
+			if (!skb) {
+				stats->rx_dropped++;
+				break;
+			}
+			memcpy(skb->data, rx_data, pkt_len);
+			skb_put(skb, pkt_len);
+			skb->protocol = eth_type_trans(skb, netdev);
+			netif_rx(skb);
+			stats->rx_packets++;
+			stats->rx_bytes += pkt_len;
+
+			rx_data = rx_agg_align(rx_data + pkt_len + 4);
+			rx_desc = (struct rx_desc *)rx_data;
+			smp_wmb();
+			pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
+			len_used = (int)(rx_data - (u8 *)agg->head);
+			len_used += sizeof(struct rx_desc) + pkt_len;
+		}
+
+		ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
+		spin_lock_irqsave(&tp->rx_lock, lockflags);
+		if (ret && ret != -ENODEV) {
+			list_add_tail(&agg->list, next);
+			tasklet_schedule(&tp->tl);
+		}
+	}
+	spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+}
+
+static void tx_bottom(struct r8152 *tp)
+{
+	struct net_device_stats *stats;
+	struct net_device *netdev;
+	struct tx_agg *agg;
+	unsigned long lockflags;
+	u32 remain, total;
+	int res;
+
+	netdev = tp->netdev;
+
+	if (!netif_running(netdev))
 		return;
-	if (status)
-		dev_info(&urb->dev->dev, "%s: Tx status %d\n",
-			 tp->netdev->name, status);
-	tp->netdev->trans_start = jiffies;
-	netif_wake_queue(tp->netdev);
+
+next_agg:
+	agg = NULL;
+	spin_lock_irqsave(&tp->tx_lock, lockflags);
+	if (!skb_queue_empty(&tp->tx_queue) && !list_empty(&tp->tx_free)) {
+		struct list_head *cursor;
+
+		cursor = tp->tx_free.next;
+		list_del_init(cursor);
+		agg = list_entry(cursor, struct tx_agg, list);
+	}
+	spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+
+	if (!agg)
+		return;
+
+	agg->data = agg->head;
+	agg->skb_num = agg->skb_len = 0;
+	remain = rx_buf_sz - sizeof(struct tx_desc);
+	total = 0;
+
+	while (remain >= ETH_ZLEN) {
+		struct tx_desc *tx_desc;
+		struct sk_buff *skb;
+		unsigned int len;
+
+		skb = skb_dequeue(&tp->tx_queue);
+		if (!skb)
+			break;
+
+		len = skb->len;
+		if (remain < len) {
+			skb_queue_head(&tp->tx_queue, skb);
+			break;
+		}
+
+		agg->data = tx_agg_align(agg->data);
+		tx_desc = (struct tx_desc *)agg->data;
+		agg->data += sizeof(*tx_desc);
+
+		tx_desc->opts1 = cpu_to_le32((skb->len & TX_LEN_MASK) | TX_FS |
+					     TX_LS);
+		memcpy(agg->data, skb->data, len);
+		agg->skb_num++;
+		agg->skb_len += len;
+		dev_kfree_skb_any(skb);
+
+		agg->data += len;
+		remain = rx_buf_sz - sizeof(*tx_desc) -
+			 (u32)(tx_agg_align(agg->data) - agg->head);
+	}
+
+	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
+			  agg->head, (int)(agg->data - (u8 *)agg->head),
+			  (usb_complete_t)write_bulk_callback, agg);
+	res = usb_submit_urb(agg->urb, GFP_ATOMIC);
+
+	stats = rtl8152_get_stats(netdev);
+
+	if (res) {
+		/* Can we get/handle EPIPE here? */
+		if (res == -ENODEV) {
+			netif_device_detach(tp->netdev);
+		} else {
+			netif_warn(tp, tx_err, netdev,
+				   "failed tx_urb %d\n", res);
+			stats->tx_dropped += agg->skb_num;
+			agg->data = agg->head;
+			spin_lock_irqsave(&tp->tx_lock, lockflags);
+			list_add_tail(&agg->list, &tp->tx_free);
+			spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+		}
+		return;
+	}
+	goto next_agg;
+}
+
+static void bottom_half(unsigned long data)
+{
+	struct r8152 *tp;
+
+	tp = (struct r8152 *)data;
+	rx_bottom(tp);
+	tx_bottom(tp);
+}
+
+static
+int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
+{
+	usb_fill_bulk_urb(agg->urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
+		      agg->head, rx_buf_sz,
+		      (usb_complete_t)read_bulk_callback, agg);
+
+	return usb_submit_urb(agg->urb, mem_flags);
 }
 
 static void rtl8152_tx_timeout(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
-	struct net_device_stats *stats = rtl8152_get_stats(netdev);
+	int i;
+
 	netif_warn(tp, tx_err, netdev, "Tx timeout.\n");
-	usb_unlink_urb(tp->tx_urb);
-	stats->tx_errors++;
+	for (i = 0; i < RTL8152_MAX_TX; i++)
+		usb_unlink_urb(tp->tx_info[i].urb);
 }
 
 static void rtl8152_set_rx_mode(struct net_device *netdev)
@@ -923,33 +1221,43 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 {
 	struct r8152 *tp = netdev_priv(netdev);
 	struct net_device_stats *stats = rtl8152_get_stats(netdev);
+	unsigned long lockflags;
+	struct tx_agg *agg = NULL;
 	struct tx_desc *tx_desc;
 	unsigned int len;
 	int res;
 
-	netif_stop_queue(netdev);
-	len = skb->len;
-	if (skb_header_cloned(skb) || skb_headroom(skb) < sizeof(*tx_desc)) {
-		struct sk_buff *tx_skb;
+	skb_tx_timestamp(skb);
 
-		tx_skb = skb_copy_expand(skb, sizeof(*tx_desc), 0, GFP_ATOMIC);
-		dev_kfree_skb_any(skb);
-		if (!tx_skb) {
-			stats->tx_dropped++;
-			netif_wake_queue(netdev);
-			return NETDEV_TX_OK;
-		}
-		skb = tx_skb;
+	spin_lock_irqsave(&tp->tx_lock, lockflags);
+	if (!list_empty(&tp->tx_free) && skb_queue_empty(&tp->tx_queue)) {
+		struct list_head *cursor;
+
+		cursor = tp->tx_free.next;
+		list_del_init(cursor);
+		agg = list_entry(cursor, struct tx_agg, list);
 	}
-	tx_desc = (struct tx_desc *)skb_push(skb, sizeof(*tx_desc));
-	memset(tx_desc, 0, sizeof(*tx_desc));
-	tx_desc->opts1 = cpu_to_le32((len & TX_LEN_MASK) | TX_FS | TX_LS);
-	tp->tx_skb = skb;
-	skb_tx_timestamp(skb);
-	usb_fill_bulk_urb(tp->tx_urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
-			  skb->data, skb->len,
-			  (usb_complete_t)write_bulk_callback, tp);
-	res = usb_submit_urb(tp->tx_urb, GFP_ATOMIC);
+	spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+
+	if (!agg) {
+		skb_queue_tail(&tp->tx_queue, skb);
+		return NETDEV_TX_OK;
+	}
+
+	tx_desc = (struct tx_desc *)agg->head;
+	agg->data = agg->head + sizeof(*tx_desc);
+	agg->skb_num = agg->skb_len = 0;
+
+	len = skb->len;
+	tx_desc->opts1 = cpu_to_le32((skb->len & TX_LEN_MASK) | TX_FS | TX_LS);
+	memcpy(agg->data, skb->data, len);
+	dev_kfree_skb_any(skb);
+	agg->skb_num++;
+	agg->skb_len += len;
+	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
+			  agg->head, len + sizeof(*tx_desc),
+			  (usb_complete_t)write_bulk_callback, agg);
+	res = usb_submit_urb(agg->urb, GFP_ATOMIC);
 	if (res) {
 		/* Can we get/handle EPIPE here? */
 		if (res == -ENODEV) {
@@ -957,12 +1265,12 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 		} else {
 			netif_warn(tp, tx_err, netdev,
 				   "failed tx_urb %d\n", res);
-			stats->tx_errors++;
-			netif_start_queue(netdev);
+			stats->tx_dropped++;
+			agg->data = agg->head;
+			spin_lock_irqsave(&tp->tx_lock, lockflags);
+			list_add_tail(&agg->list, &tp->tx_free);
+			spin_unlock_irqrestore(&tp->tx_lock, lockflags);
 		}
-	} else {
-		stats->tx_packets++;
-		stats->tx_bytes += skb->len;
 	}
 
 	return NETDEV_TX_OK;
@@ -999,17 +1307,18 @@ static inline u8 rtl8152_get_speed(struct r8152 *tp)
 
 static int rtl8152_enable(struct r8152 *tp)
 {
-	u32	ocp_data;
+	u32 ocp_data;
+	int i, ret;
 	u8 speed;
 
 	speed = rtl8152_get_speed(tp);
-	if (speed & _100bps) {
+	if (speed & _10bps) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR);
-		ocp_data &= ~EEEP_CR_EEEP_TX;
+		ocp_data |= EEEP_CR_EEEP_TX;
 		ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR, ocp_data);
 	} else {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR);
-		ocp_data |= EEEP_CR_EEEP_TX;
+		ocp_data &= ~EEEP_CR_EEEP_TX;
 		ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR, ocp_data);
 	}
 
@@ -1023,23 +1332,26 @@ static int rtl8152_enable(struct r8152 *tp)
 	ocp_data &= ~RXDY_GATED_EN;
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
 
-	usb_fill_bulk_urb(tp->rx_urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
-		      tp->rx_skb->data, RTL8152_RMS + sizeof(struct rx_desc),
-		      (usb_complete_t)read_bulk_callback, tp);
+	for (i = 0; i < RTL8152_MAX_RX; i++) {
+		ret = r8152_submit_rx(tp, &tp->rx_info[i], GFP_KERNEL);
+		if (ret)
+			break;
+	}
 
-	return usb_submit_urb(tp->rx_urb, GFP_KERNEL);
+	return ret;
 }
 
 static void rtl8152_disable(struct r8152 *tp)
 {
-	u32	ocp_data;
-	int	i;
+	u32 ocp_data;
+	int i;
 
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data &= ~RCR_ACPT_ALL;
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 
-	usb_kill_urb(tp->tx_urb);
+	for (i = 0; i < RTL8152_MAX_TX; i++)
+		usb_kill_urb(tp->tx_info[i].urb);
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
 	ocp_data |= RXDY_GATED_EN;
@@ -1058,7 +1370,8 @@ static void rtl8152_disable(struct r8152 *tp)
 		mdelay(1);
 	}
 
-	usb_kill_urb(tp->rx_urb);
+	for (i = 0; i < RTL8152_MAX_RX; i++)
+		usb_kill_urb(tp->rx_info[i].urb);
 
 	rtl8152_nic_reset(tp);
 }
@@ -1429,8 +1742,8 @@ static void r8152b_hw_phy_cfg(struct r8152 *tp)
 
 static void r8152b_init(struct r8152 *tp)
 {
-	u32	ocp_data;
-	int	i;
+	u32 ocp_data;
+	int i;
 
 	rtl_clear_bp(tp);
 
@@ -1475,9 +1788,9 @@ static void r8152b_init(struct r8152 *tp)
 			break;
 	}
 
-	/* disable rx aggregation */
+	/* enable rx aggregation */
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
-	ocp_data |= RX_AGG_DISABLE;
+	ocp_data &= ~RX_AGG_DISABLE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_USB_CTRL, ocp_data);
 }
 
@@ -1619,6 +1932,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	struct usb_device *udev = interface_to_usbdev(intf);
 	struct r8152 *tp;
 	struct net_device *netdev;
+	int ret;
 
 	if (udev->actconfig->desc.bConfigurationValue != 1) {
 		usb_driver_set_configuration(udev, 1);
@@ -1631,10 +1945,12 @@ static int rtl8152_probe(struct usb_interface *intf,
 		return -ENOMEM;
 	}
 
+	SET_NETDEV_DEV(netdev, &intf->dev);
 	tp = netdev_priv(netdev);
+	memset(tp, 0, sizeof(*tp));
 	tp->msg_enable = 0x7FFF;
 
-	tasklet_init(&tp->tl, rx_fixup, (unsigned long)tp);
+	tasklet_init(&tp->tl, bottom_half, (unsigned long)tp);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
 
 	tp->udev = udev;
@@ -1657,37 +1973,27 @@ static int rtl8152_probe(struct usb_interface *intf,
 	r8152b_init(tp);
 	set_ethernet_addr(tp);
 
-	if (!alloc_all_urbs(tp)) {
-		netif_err(tp, probe, netdev, "out of memory");
+	ret = alloc_all_mem(tp);
+	if (ret)
 		goto out;
-	}
-
-	tp->rx_skb = netdev_alloc_skb(netdev,
-			RTL8152_RMS + sizeof(struct rx_desc));
-	if (!tp->rx_skb)
-		goto out1;
 
 	usb_set_intfdata(intf, tp);
-	SET_NETDEV_DEV(netdev, &intf->dev);
-
 
-	if (register_netdev(netdev) != 0) {
+	ret = register_netdev(netdev);
+	if (ret != 0) {
 		netif_err(tp, probe, netdev, "couldn't register the device");
-		goto out2;
+		goto out1;
 	}
 
 	netif_info(tp, probe, netdev, "%s", DRIVER_VERSION);
 
 	return 0;
 
-out2:
-	usb_set_intfdata(intf, NULL);
-	dev_kfree_skb(tp->rx_skb);
 out1:
-	free_all_urbs(tp);
+	usb_set_intfdata(intf, NULL);
 out:
 	free_netdev(netdev);
-	return -EIO;
+	return ret;
 }
 
 static void rtl8152_unload(struct r8152 *tp)
@@ -1715,9 +2021,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 		tasklet_kill(&tp->tl);
 		unregister_netdev(tp->netdev);
 		rtl8152_unload(tp);
-		free_all_urbs(tp);
-		if (tp->rx_skb)
-			dev_kfree_skb(tp->rx_skb);
+		free_all_mem(tp);
 		free_netdev(tp->netdev);
 	}
 }
@@ -1732,11 +2036,12 @@ MODULE_DEVICE_TABLE(usb, rtl8152_table);
 
 static struct usb_driver rtl8152_driver = {
 	.name =		MODULENAME,
+	.id_table =	rtl8152_table,
 	.probe =	rtl8152_probe,
 	.disconnect =	rtl8152_disconnect,
-	.id_table =	rtl8152_table,
 	.suspend =	rtl8152_suspend,
-	.resume =	rtl8152_resume
+	.resume =	rtl8152_resume,
+	.reset_resume =	rtl8152_resume,
 };
 
 module_usb_driver(rtl8152_driver);
-- 
1.8.3.1
