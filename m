From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/14] pktgen: xmit logic reorganization
Date: Thu, 27 Aug 2009 16:55:11 -0700
Message-ID: <20090827235705.493721319@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58754 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbZH0X7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:25 -0400
Content-Disposition: inline; filename=pktgen-reorg1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do some reorganization of transmit logic path:
   * move transmit queue full idle to separate routine
   * add a cpu_relax()
   * eliminate some of the uneeded goto's
   * if queue is still stopped, go back to main thread loop.
   * don't give up transmitting if quantum is exhausted (be greedy)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   55 +++++++++++++++++++++++-------------------------------
 1 file changed, 24 insertions(+), 31 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:35:23.959966151 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:57:10.525500312 -0700
@@ -3339,6 +3339,18 @@ static void pktgen_rem_thread(struct pkt
 	mutex_unlock(&pktgen_thread_lock);
 }
 
+static void idle(struct pktgen_dev *pkt_dev)
+{
+	u64 idle_start = getCurUs();
+
+	if (need_resched())
+		schedule();
+	else
+		cpu_relax();
+
+	pkt_dev->idle_acc += getCurUs() - idle_start;
+}
+
 static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = pkt_dev->odev;
@@ -3361,7 +3373,7 @@ static void pktgen_xmit(struct pktgen_de
 		if (pkt_dev->delay_us == 0x7FFFFFFF) {
 			pkt_dev->next_tx_us = getCurUs() + pkt_dev->delay_us;
 			pkt_dev->next_tx_ns = pkt_dev->delay_ns;
-			goto out;
+			return;
 		}
 	}
 
@@ -3373,26 +3385,14 @@ static void pktgen_xmit(struct pktgen_de
 	}
 
 	txq = netdev_get_tx_queue(odev, queue_map);
-	if (netif_tx_queue_stopped(txq) ||
-	    netif_tx_queue_frozen(txq) ||
-	    need_resched()) {
-		u64 idle_start = getCurUs();
-
-		if (!netif_running(odev)) {
+	/* Did we saturate the queue already? */
+	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
+		/* If device is down, then all queues are permnantly frozen */
+		if (netif_running(odev))
+			idle(pkt_dev);
+		else
 			pktgen_stop_device(pkt_dev);
-			goto out;
-		}
-		if (need_resched())
-			schedule();
-
-		pkt_dev->idle_acc += getCurUs() - idle_start;
-
-		if (netif_tx_queue_stopped(txq) ||
-		    netif_tx_queue_frozen(txq)) {
-			pkt_dev->next_tx_us = getCurUs();	/* TODO */
-			pkt_dev->next_tx_ns = 0;
-			goto out;	/* Try the next interface */
-		}
+		return;
 	}
 
 	if (pkt_dev->last_ok || !pkt_dev->skb) {
@@ -3407,7 +3407,7 @@ static void pktgen_xmit(struct pktgen_de
 				       "allocate skb in fill_packet.\n");
 				schedule();
 				pkt_dev->clone_count--;	/* back out increment, OOM */
-				goto out;
+				return;
 			}
 			pkt_dev->allocated_skbs++;
 			pkt_dev->clone_count = 0;	/* reset counter */
@@ -3419,9 +3419,9 @@ static void pktgen_xmit(struct pktgen_de
 	txq = netdev_get_tx_queue(odev, queue_map);
 
 	__netif_tx_lock_bh(txq);
-	if (!netif_tx_queue_stopped(txq) &&
-	    !netif_tx_queue_frozen(txq)) {
-
+	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)))
+		pkt_dev->last_ok = 0;
+	else {
 		atomic_inc(&(pkt_dev->skb->users));
 	      retry_now:
 		ret = (*xmit)(pkt_dev->skb, odev);
@@ -3458,13 +3458,6 @@ static void pktgen_xmit(struct pktgen_de
 			pkt_dev->next_tx_ns -= 1000;
 		}
 	}
-
-	else {			/* Retry it next time */
-		pkt_dev->last_ok = 0;
-		pkt_dev->next_tx_us = getCurUs();	/* TODO */
-		pkt_dev->next_tx_ns = 0;
-	}
-
 	__netif_tx_unlock_bh(txq);
 
 	/* If pkt_dev->count is zero, then run forever */

-- 

