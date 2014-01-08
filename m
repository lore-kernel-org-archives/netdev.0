From: Ma JieYue <majieyue@gmail.com>
Subject: [PATCH net] xen-netback: fix vif tx queue race in xenvif_rx_interrupt
Date: Thu,  9 Jan 2014 03:24:21 +0800
Message-ID: <1389209061-29494-1-git-send-email-jieyue.majy@alibaba-inc.com>
Cc: Ma JieYue <jieyue.majy@alibaba-inc.com>,
	Wang Yingbin <yingbin.wangyb@alibaba-inc.com>,
	Fu Tienan <tienan.ftn@alibaba-inc.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:41721 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbaAHTZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 14:25:02 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so1973598pbb.23
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 11:25:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ma JieYue <jieyue.majy@alibaba-inc.com>

There is a race when waking up or stopping xenvif tx queue, and it leads to 
unnecessary packet drop. The problem is that the rx ring still full when entering 
into xenvif_start_xmit. In fact, in xenvif_rx_interrupt, the netif_wake_queue 
may be called not just after the ring is not full any more, so the operation 
is not atomic. Here is part of the debug log when the race scenario happened:

wake_queue: req_cons_peek 2679757 req_cons 2679586 req_prod 2679841
stop_queue: req_cons_peek 2679837 req_cons 2679757 req_prod 2679841
[tx_queue_stopped true]
wake_queue: req_cons_peek 2679837 req_cons 2679757 req_prod 2679841
[tx_queue_stopped false]
drop packet: req_cons_peek 2679837 req_cons 2679757 req_prod 2679841

The debug log was written, every time right after netif_wake_queue been called 
in xenvif_rx_interrupt, every time after netif_stop_queue been called in 
xenvif_start_xmit and every time packet drop happened in xenvif_start_xmit. 
As we can see, the second wake_queue appeared in the place it should not be, and 
we believed the ring had been checked before the stop_queue, but the actual 
wake_queue action didn't follow, and took place after the stop_queue, so that when 
entering into xenvif_start_xmit the ring was full but the queue was not stopped.

The patch fixes the race by checking if tx queue stopped, before trying to 
wake it up in xenvif_rx_interrupt. It only wakes the queue when it is stopped, 
as well as it is not full and schedulable.

Signed-off-by: Ma JieYue <jieyue.majy@alibaba-inc.com>
Signed-off-by: Wang Yingbin <yingbin.wangyb@alibaba-inc.com>
Signed-off-by: Fu Tienan <tienan.ftn@alibaba-inc.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index fff8cdd..e099f62 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -105,7 +105,7 @@ static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
-	if (xenvif_rx_schedulable(vif))
+	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))
 		netif_wake_queue(vif->dev);
 
 	return IRQ_HANDLED;
-- 
1.8.4
