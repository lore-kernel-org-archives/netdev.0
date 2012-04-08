From: David Woodhouse <dwmw2@infradead.org>
Subject: ppp: Fix race condition with queue start/stop
Date: Sun, 08 Apr 2012 21:01:44 +0100
Message-ID: <1333915304.31812.63.camel@shinybook.infradead.org>
References: <1332672230.32446.160.camel@shinybook.infradead.org>
	 <20120325.173635.1909319488008466320.davem@davemloft.net>
	 <1332756222.2379.66.camel@shinybook.infradead.org>
	 <20120403.172958.144419545310336164.davem@davemloft.net>
	 <1333915104.31812.61.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52960 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab2DHUBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2012 16:01:48 -0400
In-Reply-To: <1333915104.31812.61.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e675f0cc9a872fd152edc0c77acfed19bf28b81e ("ppp: Don't stop and
restart queue on every TX packet") introduced a race condition which
could leave the net queue stopped even when the channel is no longer
busy. By calling netif_stop_queue() from ppp_start_xmit(), based on the
return value from ppp_xmit_process() but *after* all the locks have been
dropped, we could potentially do so *after* the channel has actually
finished transmitting and attempted to re-wake the queue.

Fix this by moving the netif_stop_queue() into ppp_xmit_process() under
the xmit lock. I hadn't done this previously, because it gets called
from other places than ppp_start_xmit(). But I now think it's the better
option. The net queue *should* be stopped if the channel becomes
congested due to writes from pppd, anyway.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/net/ppp/ppp_generic.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 33f8c51..21d7151 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -235,7 +235,7 @@ struct ppp_net {
 /* Prototypes. */
 static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 			struct file *file, unsigned int cmd, unsigned long arg);
-static int ppp_xmit_process(struct ppp *ppp);
+static void ppp_xmit_process(struct ppp *ppp);
 static void ppp_send_frame(struct ppp *ppp, struct sk_buff *skb);
 static void ppp_push(struct ppp *ppp);
 static void ppp_channel_push(struct channel *pch);
@@ -969,8 +969,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	put_unaligned_be16(proto, pp);
 
 	skb_queue_tail(&ppp->file.xq, skb);
-	if (!ppp_xmit_process(ppp))
-		netif_stop_queue(dev);
+	ppp_xmit_process(ppp);
 	return NETDEV_TX_OK;
 
  outf:
@@ -1048,11 +1047,10 @@ static void ppp_setup(struct net_device *dev)
  * Called to do any work queued up on the transmit side
  * that can now be done.
  */
-static int
+static void
 ppp_xmit_process(struct ppp *ppp)
 {
 	struct sk_buff *skb;
-	int ret = 0;
 
 	ppp_xmit_lock(ppp);
 	if (!ppp->closing) {
@@ -1062,13 +1060,12 @@ ppp_xmit_process(struct ppp *ppp)
 			ppp_send_frame(ppp, skb);
 		/* If there's no work left to do, tell the core net
 		   code that we can accept some more. */
-		if (!ppp->xmit_pending && !skb_peek(&ppp->file.xq)) {
+		if (!ppp->xmit_pending && !skb_peek(&ppp->file.xq))
 			netif_wake_queue(ppp->dev);
-			ret = 1;
-		}
+		else
+			netif_stop_queue(ppp->dev);
 	}
 	ppp_xmit_unlock(ppp);
-	return ret;
 }
 
 static inline struct sk_buff *
-- 
1.7.7.6



-- 
dwmw2
