From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/1] Use the pause counter to avoid a needless device reset
Date: Thu, 09 Aug 2007 09:02:14 +0200
Message-ID: <46BABBF6.30001@myri.com>
References: <46BABBCA.2060001@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1976 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751126AbXHIHBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 03:01:04 -0400
In-Reply-To: <46BABBCA.2060001@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the pause counter to avoid a needless device reset, and
print a message telling the admin that our link partner is
flow controlling us down to 0 pkts/sec.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

Index: linux-2.6.22/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.22.orig/drivers/net/myri10ge/myri10ge.c	2007-08-09 08:53:40.000000000 +0200
+++ linux-2.6.22/drivers/net/myri10ge/myri10ge.c	2007-08-09 08:53:53.000000000 +0200
@@ -191,6 +191,7 @@
 	struct timer_list watchdog_timer;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
+	int watchdog_pause;
 	int watchdog_resets;
 	int tx_linearized;
 	int pause;
@@ -2800,6 +2801,7 @@
 static void myri10ge_watchdog_timer(unsigned long arg)
 {
 	struct myri10ge_priv *mgp;
+	u32 rx_pause_cnt;
 
 	mgp = (struct myri10ge_priv *)arg;
 
@@ -2816,19 +2818,28 @@
 		    myri10ge_fill_thresh)
 			mgp->rx_big.watchdog_needed = 0;
 	}
+	rx_pause_cnt = ntohl(mgp->fw_stats->dropped_pause);
 
 	if (mgp->tx.req != mgp->tx.done &&
 	    mgp->tx.done == mgp->watchdog_tx_done &&
-	    mgp->watchdog_tx_req != mgp->watchdog_tx_done)
+	    mgp->watchdog_tx_req != mgp->watchdog_tx_done) {
 		/* nic seems like it might be stuck.. */
-		schedule_work(&mgp->watchdog_work);
-	else
-		/* rearm timer */
-		mod_timer(&mgp->watchdog_timer,
-			  jiffies + myri10ge_watchdog_timeout * HZ);
-
+		if (rx_pause_cnt != mgp->watchdog_pause) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "myri10ge %s:"
+				       "TX paused, check link partner\n",
+				       mgp->dev->name);
+		} else {
+			schedule_work(&mgp->watchdog_work);
+			return;
+		}
+	}
+	/* rearm timer */
+	mod_timer(&mgp->watchdog_timer,
+		  jiffies + myri10ge_watchdog_timeout * HZ);
 	mgp->watchdog_tx_done = mgp->tx.done;
 	mgp->watchdog_tx_req = mgp->tx.req;
+	mgp->watchdog_pause = rx_pause_cnt;
 }
 
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)


