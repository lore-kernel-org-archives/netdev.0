From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6] ixgb: fix ixgb_intr looping checks
Date: Tue, 2 Nov 2004 12:45:07 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0411021152220.24843-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@intel.com, <akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hey Jeff, we have a little problem with a patch that got accepted into -mm 
and is now in netdev, but never got copied to netdev mailing list.

This thread:
http://marc.theaimsgroup.com/?t=109149508900004&r=1&w=2

the last comment is entirely correct, we need to update the comment.  
this patch reverts the patch to ixgb that akpm added to do two for loops,
as we actually did intend to do the boolean '&' check, and both the
functions *should* be called every time through the loop.

Here is a patch that we would like applied, it undoes the change we don't 
like, it was checked to apply cleanly against the netdev-2.6 tree this 
morning, and reviewed by the team.

It also keeps the 10Gig (ixgb) driver consistent with our 1gig (e1000) 
code. 

This patch undoes a change that we believe will impact performance
adversely, by creating possibly too long a delay between servicing
completions. The comment pretty much explains it.  We need to call both
cleanup routines each pass through the loop, this time we have a comment
explaining why.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-15 10:39:56.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb/ixgb_main.c.new	2004-10-15 11:09:42.000000000 -0700
@@ -1613,13 +1613,14 @@ static irqreturn_t ixgb_intr(int irq, vo
 		__netif_rx_schedule(netdev);
 	}
 #else
-	for (i = 0; i < IXGB_MAX_INTR; i++)
-		if (ixgb_clean_rx_irq(adapter) == FALSE)
-			break;
-	for (i = 0; i < IXGB_MAX_INTR; i++)
-		if (ixgb_clean_tx_irq(adapter) == FALSE)
+	/* yes, that is actually a & and it is meant to make sure that
+	 * every pass through this for loop checks both receive and
+	 * transmit queues for completed descriptors, intended to
+	 * avoid starvation issues and assist tx/rx fairness. */
+	for(i = 0; i < IXGB_MAX_INTR; i++)
+		if(!ixgb_clean_rx_irq(adapter) &
+		   !ixgb_clean_tx_irq(adapter))
 			break;
-
 	/* if RAIDC:EN == 1 and ICR:RXDMT0 == 1, we need to
 	 * set IMS:RXDMT0 to 1 to restart the RBD timer (POLL)
 	 */
