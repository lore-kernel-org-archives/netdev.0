From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: rename rx_buf_sz
Date: Tue, 2 Sep 2014 10:27:52 +0800
Message-ID: <1394712342-15778-25-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:38457 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaIBC2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 22:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable "rx_buf_sz" is used by both tx and rx buffers. Replace
it with "agg_buf_sz".

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index cc64dc0..80b0179 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -607,9 +607,9 @@ enum tx_csum_stat {
  * The RTL chips use a 64 element hash table based on the Ethernet CRC.
  */
 static const int multicast_filter_limit = 32;
-static unsigned int rx_buf_sz = 16384;
+static unsigned int agg_buf_sz = 16384;
 
-#define RTL_LIMITED_TSO_SIZE	(rx_buf_sz - sizeof(struct tx_desc) - \
+#define RTL_LIMITED_TSO_SIZE	(agg_buf_sz - sizeof(struct tx_desc) - \
 				 VLAN_ETH_HLEN - VLAN_HLEN)
 
 static
@@ -1248,13 +1248,13 @@ static int alloc_all_mem(struct r8152 *tp)
 	skb_queue_head_init(&tp->tx_queue);
 
 	for (i = 0; i < RTL8152_MAX_RX; i++) {
-		buf = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
+		buf = kmalloc_node(agg_buf_sz, GFP_KERNEL, node);
 		if (!buf)
 			goto err1;
 
 		if (buf != rx_agg_align(buf)) {
 			kfree(buf);
-			buf = kmalloc_node(rx_buf_sz + RX_ALIGN, GFP_KERNEL,
+			buf = kmalloc_node(agg_buf_sz + RX_ALIGN, GFP_KERNEL,
 					   node);
 			if (!buf)
 				goto err1;
@@ -1274,13 +1274,13 @@ static int alloc_all_mem(struct r8152 *tp)
 	}
 
 	for (i = 0; i < RTL8152_MAX_TX; i++) {
-		buf = kmalloc_node(rx_buf_sz, GFP_KERNEL, node);
+		buf = kmalloc_node(agg_buf_sz, GFP_KERNEL, node);
 		if (!buf)
 			goto err1;
 
 		if (buf != tx_agg_align(buf)) {
 			kfree(buf);
-			buf = kmalloc_node(rx_buf_sz + TX_ALIGN, GFP_KERNEL,
+			buf = kmalloc_node(agg_buf_sz + TX_ALIGN, GFP_KERNEL,
 					   node);
 			if (!buf)
 				goto err1;
@@ -1518,7 +1518,7 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 	tx_data = agg->head;
 	agg->skb_num = 0;
 	agg->skb_len = 0;
-	remain = rx_buf_sz;
+	remain = agg_buf_sz;
 
 	while (remain >= ETH_ZLEN + sizeof(struct tx_desc)) {
 		struct tx_desc *tx_desc;
@@ -1565,7 +1565,7 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 
 		dev_kfree_skb_any(skb);
 
-		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
+		remain = agg_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
 	if (!skb_queue_empty(&skb_head)) {
@@ -1771,7 +1771,7 @@ static
 int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 {
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
-			  agg->head, rx_buf_sz,
+			  agg->head, agg_buf_sz,
 			  (usb_complete_t)read_bulk_callback, agg);
 
 	return usb_submit_urb(agg->urb, mem_flags);
@@ -1915,8 +1915,8 @@ static void set_tx_qlen(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
 
-	tp->tx_qlen = rx_buf_sz / (netdev->mtu + VLAN_ETH_HLEN + VLAN_HLEN +
-				   sizeof(struct tx_desc));
+	tp->tx_qlen = agg_buf_sz / (netdev->mtu + VLAN_ETH_HLEN + VLAN_HLEN +
+				    sizeof(struct tx_desc));
 }
 
 static inline u8 rtl8152_get_speed(struct r8152 *tp)
-- 
1.9.3
