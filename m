From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/14] pktgen: cleanup clone count test
Date: Thu, 27 Aug 2009 16:55:12 -0700
Message-ID: <20090827235705.572057709@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58749 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbZH0X7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:18 -0400
Content-Disposition: inline; filename=pktgen-clone-count.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The if statement to test for "should a new packet be used"
can be simplified.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:35:26.831941925 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:57:09.804814960 -0700
@@ -3395,23 +3395,22 @@ static void pktgen_xmit(struct pktgen_de
 		return;
 	}
 
-	if (pkt_dev->last_ok || !pkt_dev->skb) {
-		if ((++pkt_dev->clone_count >= pkt_dev->clone_skb)
-		    || (!pkt_dev->skb)) {
-			/* build a new pkt */
-			kfree_skb(pkt_dev->skb);
-
-			pkt_dev->skb = fill_packet(odev, pkt_dev);
-			if (pkt_dev->skb == NULL) {
-				printk(KERN_ERR "pktgen: ERROR: couldn't "
-				       "allocate skb in fill_packet.\n");
-				schedule();
-				pkt_dev->clone_count--;	/* back out increment, OOM */
-				return;
-			}
-			pkt_dev->allocated_skbs++;
-			pkt_dev->clone_count = 0;	/* reset counter */
+	if (!pkt_dev->skb || (pkt_dev->last_ok &&
+			      ++pkt_dev->clone_count >= pkt_dev->clone_skb)) {
+		/* build a new pkt */
+		kfree_skb(pkt_dev->skb);
+
+		pkt_dev->skb = fill_packet(odev, pkt_dev);
+		if (pkt_dev->skb == NULL) {
+			printk(KERN_ERR "pktgen: ERROR: couldn't "
+			       "allocate skb in fill_packet.\n");
+			schedule();
+			pkt_dev->clone_count--;	/* back out increment, OOM */
+			return;
 		}
+
+		pkt_dev->allocated_skbs++;
+		pkt_dev->clone_count = 0;	/* reset counter */
 	}
 
 	/* fill_packet() might have changed the queue */
@@ -3476,7 +3475,6 @@ static void pktgen_xmit(struct pktgen_de
 		/* Done with this */
 		pktgen_stop_device(pkt_dev);
 	}
-out:;
 }
 
 /*

-- 

