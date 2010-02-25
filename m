From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC PATCH] bnx2x: fix tx queue locking and memory barriers
Date: Thu, 25 Feb 2010 14:08:34 +0100
Message-ID: <20100225140834.0169e9f2@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	David Howells <dhowells@redhat.com>
To: netdev@vger.kernel.org, Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775Ab0BYKIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 05:08:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have done some optimizations in bnx2x_start_xmit() and bnx2x_tx_int(), which 
in my opinion can lead into some theoretical race conditions. 

I can be pretty wrong here, but if so, we have to optimize some other drivers,
which use memory barriers/locking schema from that patch (like tg3, bnx2).

Memory barriers here IMHO, prevent to make queue permanently stopped when on one
cpu bnx2x_tx_int() make queue empty, whereas on other cpu bnx2x_start_xmit() see
it full and make stop it, such cause queue will be stopped forever. 

I'm not quite sure what for is __netif_tx_lock, but other drivers use it.

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5adf2a0..ca91aa8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -893,7 +893,10 @@ static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 	u16 prod;
 	u16 cons;
 
-	barrier(); /* Tell compiler that prod and cons can change */
+	/* prod and cons can change on other cpu, want to see
+	   consistend available space and queue (stop/running) state */
+	smp_mb();
+
 	prod = fp->tx_bd_prod;
 	cons = fp->tx_bd_cons;
 
@@ -957,21 +960,23 @@ static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	fp->tx_pkt_cons = sw_cons;
 	fp->tx_bd_cons = bd_cons;
 
+	/* Need to make the tx_bd_cons update visible to start_xmit()
+	 * before checking for netif_tx_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that start_xmit()
+	 * will miss it and cause the queue to be stopped forever. This
+	 * can happen when we make queue empty here, when on other cpu
+	 * start_xmit() still see it becoming full and stop.
+	 */
+	smp_mb();
+
 	/* TBD need a thresh? */
 	if (unlikely(netif_tx_queue_stopped(txq))) {
-
-		/* Need to make the tx_bd_cons update visible to start_xmit()
-		 * before checking for netif_tx_queue_stopped().  Without the
-		 * memory barrier, there is a small possibility that
-		 * start_xmit() will miss it and cause the queue to be stopped
-		 * forever.
-		 */
-		smp_mb();
-
+		__netif_tx_lock(txq, smp_processor_id());
 		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
 			netif_tx_wake_queue(txq);
+		__netif_tx_unlock(txq);
 	}
 	return 0;
 }



