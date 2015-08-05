From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 1/1] lan78xx: Fix Smatch warnings
Date: Wed, 5 Aug 2015 21:26:14 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D53BF06@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:43111 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751464AbbHEV0U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 17:26:20 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix Smatch warnings.
- lan78xx.c:2282 tx_complete() warn: variable dereferenced before check 'skb' (see line 2249)
- lan78xx.c:2885 lan78xx_bh() info: ignoring unreachable code.
- lan78xx.c:3159 lan78xx_probe() info: ignoring unreachable code.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 52 ++++++++++++++++++++++-------------------------
 1 file changed, 24 insertions(+), 28 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index ec8bd34..3ac405f 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -291,7 +291,7 @@ static int lan78xx_read_reg(struct lan78xx_net *dev, u32 index, u32 *data)
 	u32 *buf = kmalloc(sizeof(u32), GFP_KERNEL);
 	int ret;
 
-	BUG_ON(!dev);
+	WARN_ON_ONCE(!dev);
 
 	if (!buf)
 		return -ENOMEM;
@@ -319,7 +319,7 @@ static int lan78xx_write_reg(struct lan78xx_net *dev, u32 index, u32 data)
 	u32 *buf = kmalloc(sizeof(u32), GFP_KERNEL);
 	int ret;
 
-	BUG_ON(!dev);
+	WARN_ON_ONCE(!dev);
 
 	if (!buf)
 		return -ENOMEM;
@@ -351,9 +351,9 @@ static int lan78xx_read_stats(struct lan78xx_net *dev,
 	u32 *src;
 	u32 *dst;
 
-	BUG_ON(!dev);
-	BUG_ON(!data);
-	BUG_ON(sizeof(struct lan78xx_statstage) != 0xBC);
+	WARN_ON_ONCE(!dev);
+	WARN_ON_ONCE(!data);
+	WARN_ON_ONCE(sizeof(struct lan78xx_statstage) != 0xBC);
 
 	stats = kmalloc(sizeof(*stats), GFP_KERNEL);
 	if (!stats)
@@ -687,8 +687,8 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	u32 val;
 	int i, ret;
 
-	BUG_ON(!dev);
-	BUG_ON(!data);
+	WARN_ON_ONCE(!dev);
+	WARN_ON_ONCE(!data);
 
 	ret = lan78xx_eeprom_confirm_not_busy(dev);
 	if (ret)
@@ -737,8 +737,8 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	u32 val;
 	int i, ret;
 
-	BUG_ON(!dev);
-	BUG_ON(!data);
+	WARN_ON_ONCE(!dev);
+	WARN_ON_ONCE(!data);
 
 	ret = lan78xx_eeprom_confirm_not_busy(dev);
 	if (ret)
@@ -2221,19 +2221,19 @@ static enum skb_state defer_bh(struct lan78xx_net *dev, struct sk_buff *skb,
 	old_state = entry->state;
 	entry->state = state;
 	if (!list->prev)
-		BUG_ON(!list->prev);
+		WARN_ON_ONCE(!list->prev);
 	if (!list->next)
-		BUG_ON(!list->next);
+		WARN_ON_ONCE(!list->next);
 	if (!skb->prev || !skb->next)
-		BUG_ON(true);
+		WARN_ON_ONCE(true);
 
 	__skb_unlink(skb, list);
 	spin_unlock(&list->lock);
 	spin_lock(&dev->done.lock);
 	if (!dev->done.prev)
-		BUG_ON(!dev->done.prev);
+		WARN_ON_ONCE(!dev->done.prev);
 	if (!dev->done.next)
-		BUG_ON(!dev->done.next);
+		WARN_ON_ONCE(!dev->done.next);
 
 	__skb_queue_tail(&dev->done, skb);
 	if (skb_queue_len(&dev->done) == 1)
@@ -2279,8 +2279,7 @@ static void tx_complete(struct urb *urb)
 
 	usb_autopm_put_interface_async(dev->intf);
 
-	if (skb)
-		defer_bh(dev, skb, &dev->txq, tx_done);
+	defer_bh(dev, skb, &dev->txq, tx_done);
 }
 
 static void lan78xx_queue_skb(struct sk_buff_head *list,
@@ -2295,13 +2294,15 @@ static void lan78xx_queue_skb(struct sk_buff_head *list,
 netdev_tx_t lan78xx_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct lan78xx_net *dev = netdev_priv(net);
+	struct sk_buff *skb2 = NULL;
 
-	if (skb)
+	if (skb) {
 		skb_tx_timestamp(skb);
+		skb2 = lan78xx_tx_prep(dev, skb, GFP_ATOMIC);
+	}
 
-	skb = lan78xx_tx_prep(dev, skb, GFP_ATOMIC);
-	if (skb) {
-		skb_queue_tail(&dev->txq_pend, skb);
+	if (skb2) {
+		skb_queue_tail(&dev->txq_pend, skb2);
 
 		if (skb_queue_len(&dev->txq_pend) > 10)
 			netif_stop_queue(net);
@@ -2749,7 +2750,7 @@ static void lan78xx_tx_bh(struct lan78xx_net *dev)
 			pos += roundup(skb2->len, sizeof(u32));
 			dev_kfree_skb(skb2);
 		} else {
-			BUG_ON(true);
+			WARN_ON_ONCE(true);
 		}
 	}
 
@@ -2859,9 +2860,9 @@ static void lan78xx_bh(unsigned long param)
 	struct skb_data *entry;
 
 	if (!dev->done.prev)
-		BUG_ON(!dev->done.prev);
+		WARN_ON_ONCE(!dev->done.prev);
 	if (!dev->done.next)
-		BUG_ON(!dev->done.next);
+		WARN_ON_ONCE(!dev->done.next);
 
 	while ((skb = skb_dequeue(&dev->done))) {
 		entry = (struct skb_data *)(skb->cb);
@@ -2882,10 +2883,6 @@ static void lan78xx_bh(unsigned long param)
 			netdev_dbg(dev->net, "skb state %d\n", entry->state);
 			return;
 		}
-		if (!dev->done.prev)
-			BUG_ON(!dev->done.prev);
-		if (!dev->done.next)
-			BUG_ON(!dev->done.next);
 	}
 
 	if (netif_device_present(dev->net) && netif_running(dev->net)) {
@@ -3156,7 +3153,6 @@ static int lan78xx_probe(struct usb_interface *intf,
 
 	return 0;
 
-	usb_set_intfdata(intf, NULL);
 out3:
 	lan78xx_unbind(dev, intf);
 out2:
-- 
2.1.4
