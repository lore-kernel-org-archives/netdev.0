From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 2.6] ixgb: fix ixgb_intr looping checks
Date: Mon, 8 Nov 2004 14:50:38 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0411081446550.18540-100000@isotope.jf.intel.com>
References: <418B2C3F.60107@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <418B2C3F.60107@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Try again:
This patch undoes a change that we believe will impact performance adversely,
by creating possibly too long a delay between servicing completions.
The comment pretty much explains it.  We need to call both cleanup routines each
pass through the loop, this time we have a comment explaining why.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

===== drivers/net/ixgb/ixgb_main.c 1.21 vs edited =====
--- 1.21/drivers/net/ixgb/ixgb_main.c	2004-11-04 21:00:33 -08:00
+++ edited/drivers/net/ixgb/ixgb_main.c	2004-11-08 13:58:01 -08:00
@@ -1613,13 +1613,14 @@
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
