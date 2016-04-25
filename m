From: <Woojung.Huh@microchip.com>
Subject: [PATCH 1/2 net] lan78xx: fix statistics counter error
Date: Mon, 25 Apr 2016 22:22:32 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D408987F2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:52460 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751095AbcDYWWe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 18:22:34 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Fix rx_bytes, tx_bytes and tx_frames error in netdev.stats.
- rx_bytes counted bytes excluding size of struct ethhdr.
- tx_packets didn't count multiple packets in a single urb
- tx_bytes included 8 bytes of extra commands.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index f20890e..0460b81 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -269,6 +269,7 @@ struct skb_data {		/* skb->cb is one of these */
 	struct lan78xx_net *dev;
 	enum skb_state state;
 	size_t length;
+	int num_of_packet;
 };
 
 struct usb_context {
@@ -2464,7 +2465,7 @@ static void tx_complete(struct urb *urb)
 	struct lan78xx_net *dev = entry->dev;
 
 	if (urb->status == 0) {
-		dev->net->stats.tx_packets++;
+		dev->net->stats.tx_packets += entry->num_of_packet;
 		dev->net->stats.tx_bytes += entry->length;
 	} else {
 		dev->net->stats.tx_errors++;
@@ -2681,10 +2682,11 @@ void lan78xx_skb_return(struct lan78xx_net *dev, struct sk_buff *skb)
 		return;
 	}
 
-	skb->protocol = eth_type_trans(skb, dev->net);
 	dev->net->stats.rx_packets++;
 	dev->net->stats.rx_bytes += skb->len;
 
+	skb->protocol = eth_type_trans(skb, dev->net);
+
 	netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
 		  skb->len + sizeof(struct ethhdr), skb->protocol);
 	memset(skb->cb, 0, sizeof(struct skb_data));
@@ -2934,13 +2936,16 @@ static void lan78xx_tx_bh(struct lan78xx_net *dev)
 
 	skb_totallen = 0;
 	pkt_cnt = 0;
+	count = 0;
+	length = 0;
 	for (skb = tqp->next; pkt_cnt < tqp->qlen; skb = skb->next) {
 		if (skb_is_gso(skb)) {
 			if (pkt_cnt) {
 				/* handle previous packets first */
 				break;
 			}
-			length = skb->len;
+			count = 1;
+			length = skb->len - TX_OVERHEAD;
 			skb2 = skb_dequeue(tqp);
 			goto gso_skb;
 		}
@@ -2961,14 +2966,13 @@ static void lan78xx_tx_bh(struct lan78xx_net *dev)
 	for (count = pos = 0; count < pkt_cnt; count++) {
 		skb2 = skb_dequeue(tqp);
 		if (skb2) {
+			length += (skb2->len - TX_OVERHEAD);
 			memcpy(skb->data + pos, skb2->data, skb2->len);
 			pos += roundup(skb2->len, sizeof(u32));
 			dev_kfree_skb(skb2);
 		}
 	}
 
-	length = skb_totallen;
-
 gso_skb:
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
@@ -2980,6 +2984,7 @@ gso_skb:
 	entry->urb = urb;
 	entry->dev = dev;
 	entry->length = length;
+	entry->num_of_packet = count;
 
 	spin_lock_irqsave(&dev->txq.lock, flags);
 	ret = usb_autopm_get_interface_async(dev->intf);
-- 
2.8.1
