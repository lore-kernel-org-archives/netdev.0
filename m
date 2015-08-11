From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 1/2] lan78xx: Fix Smatch Warnings
Date: Tue, 11 Aug 2015 15:21:41 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D53FAEF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:63521 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965062AbbHKPVn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 11:21:43 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lan78xx.c:2282 tx_complete() warn: variable dereferenced before check 'skb' (see line 2249)
lan78xx.c:2885 lan78xx_bh() info: ignoring unreachable code.
lan78xx.c:3159 lan78xx_probe() info: ignoring unreachable code.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index ec8bd34..3a6a4c1 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
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
