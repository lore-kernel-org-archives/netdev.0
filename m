From: akpm@osdl.org
Subject: [patch 7/7] ixgb: fix ixgb_intr looping checks
Date: Wed, 10 Nov 2004 16:02:34 -0800
Message-ID: <200411102358.iAANwN904232@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch undoes a change that we believe will impact performance
adversely, by creating possibly too long a delay between servicing
completions.  The comment pretty much explains it.  We need to call both
cleanup routines each pass through the loop, this time we have a comment
explaining why.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/ixgb/ixgb_main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff -puN drivers/net/ixgb/ixgb_main.c~ixgb-fix-ixgb_intr-looping-checks drivers/net/ixgb/ixgb_main.c
--- 25/drivers/net/ixgb/ixgb_main.c~ixgb-fix-ixgb_intr-looping-checks	Wed Nov 10 16:00:38 2004
+++ 25-akpm/drivers/net/ixgb/ixgb_main.c	Wed Nov 10 16:00:38 2004
@@ -1613,13 +1613,14 @@ static irqreturn_t ixgb_intr(int irq, vo
 		__netif_rx_schedule(netdev);
 	}
 #else
-	for (i = 0; i < IXGB_MAX_INTR; i++)
-		if (ixgb_clean_rx_irq(adapter) == FALSE)
+	/* yes, that is actually a & and it is meant to make sure that
+	 * every pass through this for loop checks both receive and
+	 * transmit queues for completed descriptors, intended to
+	 * avoid starvation issues and assist tx/rx fairness. */
+	for(i = 0; i < IXGB_MAX_INTR; i++)
+		if(!ixgb_clean_rx_irq(adapter) &
+		   !ixgb_clean_tx_irq(adapter))
 			break;
-	for (i = 0; i < IXGB_MAX_INTR; i++)
-		if (ixgb_clean_tx_irq(adapter) == FALSE)
-			break;
-
 	/* if RAIDC:EN == 1 and ICR:RXDMT0 == 1, we need to
 	 * set IMS:RXDMT0 to 1 to restart the RBD timer (POLL)
 	 */
_
