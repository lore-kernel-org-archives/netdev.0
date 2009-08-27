From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/14] pktgen: reorganize transmit loop
Date: Thu, 27 Aug 2009 16:55:14 -0700
Message-ID: <20090827235705.740919364@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58755 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981AbZH0X7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:25 -0400
Content-Disposition: inline; filename=pktgen-reorg2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle standard (and non-standard) return values in a switch.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:45:40.162808571 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:56:46.356874524 -0700
@@ -3424,27 +3424,29 @@ static void pktgen_xmit(struct pktgen_de
 		pkt_dev->last_ok = 0;
 	else {
 		atomic_inc(&(pkt_dev->skb->users));
-	      retry_now:
+
+	retry_now:
 		ret = (*xmit)(pkt_dev->skb, odev);
-		if (likely(ret == NETDEV_TX_OK)) {
+		switch (ret) {
+		case NETDEV_TX_OK:
 			txq_trans_update(txq);
 			pkt_dev->last_ok = 1;
 			pkt_dev->sofar++;
 			pkt_dev->seq_num++;
 			pkt_dev->tx_bytes += pkt_dev->cur_pkt_size;
-
-		} else if (ret == NETDEV_TX_LOCKED
-			   && (odev->features & NETIF_F_LLTX)) {
+			break;
+		case NETDEV_TX_LOCKED:
 			cpu_relax();
 			goto retry_now;
-		} else {	/* Retry it next time */
-
-			atomic_dec(&(pkt_dev->skb->users));
-
-			if (debug && net_ratelimit())
-				printk(KERN_INFO "pktgen: Hard xmit error\n");
-
+		default: /* Drivers are not supposed to return other values! */
+			if (net_ratelimit())
+				pr_info("pktgen: %s xmit error: %d\n",
+					odev->name, ret);
 			pkt_dev->errors++;
+			/* fallthru */
+		case NETDEV_TX_BUSY:
+			/* Retry it next time */
+			atomic_dec(&(pkt_dev->skb->users));
 			pkt_dev->last_ok = 0;
 		}
 

-- 

