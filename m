From: David Miller <davem@davemloft.net>
Subject: [PATCH]: usbatm: Use skb_queue_walk_safe() instead of by-hand
 implementation.
Date: Tue, 23 Sep 2008 00:28:26 -0700 (PDT)
Message-ID: <20080923.002826.111592180.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47893
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753040AbYIWH2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 03:28:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 57DC0C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 00:28:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


usbatm: Use skb_queue_walk_safe() instead of by-hand implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/usb/atm/usbatm.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index 0722872..0da2c25 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -640,14 +640,13 @@ static void usbatm_cancel_send(struct usbatm_data *instance,
 
 	atm_dbg(instance, "%s entered\n", __func__);
 	spin_lock_irq(&instance->sndqueue.lock);
-	for (skb = instance->sndqueue.next, n = skb->next;
-	     skb != (struct sk_buff *)&instance->sndqueue;
-	     skb = n, n = skb->next)
+	skb_queue_walk_safe(&instance->sndqueue, skb, n) {
 		if (UDSL_SKB(skb)->atm.vcc == vcc) {
 			atm_dbg(instance, "%s: popping skb 0x%p\n", __func__, skb);
 			__skb_unlink(skb, &instance->sndqueue);
 			usbatm_pop(vcc, skb);
 		}
+	}
 	spin_unlock_irq(&instance->sndqueue.lock);
 
 	tasklet_disable(&instance->tx_channel.tasklet);
-- 
1.5.6.5

