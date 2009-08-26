From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 3/4] pktgen: clock optimizations
Date: Tue, 25 Aug 2009 23:15:16 -0700
Message-ID: <20090826061728.771777518@vyatta.com>
References: <20090826061513.755294685@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36504 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbZHZGZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 02:25:26 -0400
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline; filename=pktgen-avoid-clock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This optimizes pktgen to avoid calling ktime_get_ts unless
it is needed. 
  * if delay is 0, then no need to update next_tx
  * if queue is stopped, then keep old value will already force
    tx on next cycle.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/core/pktgen.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- a/net/core/pktgen.c	2009-08-25 22:49:55.966424251 -0700
+++ b/net/core/pktgen.c	2009-08-25 22:51:21.162461840 -0700
@@ -3425,11 +3425,12 @@ static __inline__ void pktgen_xmit(struc
 	txq = netdev_get_tx_queue(odev, queue_map);
 
 	__netif_tx_lock_bh(txq);
-	if (!netif_tx_queue_stopped(txq) &&
-	    !netif_tx_queue_frozen(txq)) {
+	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq))
+		pkt_dev->last_ok = 0; 			/* Retry it next time */
+	else {
 
 		atomic_inc(&(pkt_dev->skb->users));
-	      retry_now:
+retry_now:
 		ret = (*xmit)(pkt_dev->skb, odev);
 		if (likely(ret == NETDEV_TX_OK)) {
 			txq_trans_update(txq);
@@ -3453,10 +3454,9 @@ static __inline__ void pktgen_xmit(struc
 			pkt_dev->last_ok = 0;
 		}
 
-		pkt_dev->next_tx = ktime_add_ns(ktime_now(), pkt_dev->delay);
-	} else {			/* Retry it next time */
-		pkt_dev->last_ok = 0;
-		pkt_dev->next_tx = ktime_now();
+		if (pkt_dev->delay)
+			pkt_dev->next_tx = ktime_add_ns(ktime_now(),
+							pkt_dev->delay);
 	}
 
 	__netif_tx_unlock_bh(txq);

-- 

