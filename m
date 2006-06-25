From: akpm@osdl.org
Subject: [patch 2/6] netpoll: don't spin forever sending to stopped queues
Date: Sun, 25 Jun 2006 01:47:29 -0700
Message-ID: <200606250847.k5P8lThc020900@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jeremy@goop.org,
	mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16275 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751179AbWFYIrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 04:47:39 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Jeremy Fitzhardinge <jeremy@goop.org>

When transmitting a skb in netpoll_send_skb(), only retry a limited number
of times if the device queue is stopped.

Signed-off-by: Jeremy Fitzhardinge <jeremy@goop.org>
Acked-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/core/netpoll.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff -puN net/core/netpoll.c~netpoll-dont-spin-forever-sending-to-blocked-queues net/core/netpoll.c
--- a/net/core/netpoll.c~netpoll-dont-spin-forever-sending-to-blocked-queues
+++ a/net/core/netpoll.c
@@ -279,14 +279,10 @@ static void netpoll_send_skb(struct netp
 		 * network drivers do not expect to be called if the queue is
 		 * stopped.
 		 */
-		if (netif_queue_stopped(np->dev)) {
-			netif_tx_unlock(np->dev);
-			netpoll_poll(np);
-			udelay(50);
-			continue;
-		}
+		status = NETDEV_TX_BUSY;
+		if (!netif_queue_stopped(np->dev))
+			status = np->dev->hard_start_xmit(skb, np->dev);
 
-		status = np->dev->hard_start_xmit(skb, np->dev);
 		netif_tx_unlock(np->dev);
 
 		/* success */
_
