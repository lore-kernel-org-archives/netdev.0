From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH] slip: cleanup statistics generation
Date: Wed, 3 Aug 2011 11:23:35 +0400
Message-ID: <CAKh5naZEyehLdP=sHM8H3_+n7ieto0YC_6hn3x=A+y823Gqs-Q@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41629 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117Ab1HCHXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 03:23:55 -0400
Received: by vxh35 with SMTP id 35so414421vxh.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 00:23:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused tx_compressed, tx_compressed and tx_misses fields from
the slip structure. Also, make some device stats generation cleanups.

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |   29 ++++++++++++++---------------
 drivers/net/slip.h |    9 ---------
 2 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index f11b3f3..85420cf 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -562,34 +562,33 @@ static struct rtnl_link_stats64 *
 sl_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct net_device_stats *devstats = &dev->stats;
-	unsigned long c_rx_dropped = 0;
 #ifdef SL_INCLUDE_CSLIP
-	unsigned long c_rx_fifo_errors = 0;
-	unsigned long c_tx_fifo_errors = 0;
-	unsigned long c_collisions = 0;
 	struct slip *sl = netdev_priv(dev);
 	struct slcompress *comp = sl->slcomp;
-
-	if (comp) {
-		c_rx_fifo_errors = comp->sls_i_compressed;
-		c_rx_dropped     = comp->sls_i_tossed;
-		c_tx_fifo_errors = comp->sls_o_compressed;
-		c_collisions     = comp->sls_o_misses;
-	}
-	stats->rx_fifo_errors = sl->rx_compressed + c_rx_fifo_errors;
-	stats->tx_fifo_errors = sl->tx_compressed + c_tx_fifo_errors;
-	stats->collisions     = sl->tx_misses + c_collisions;
 #endif
 	stats->rx_packets     = devstats->rx_packets;
 	stats->tx_packets     = devstats->tx_packets;
 	stats->rx_bytes       = devstats->rx_bytes;
 	stats->tx_bytes       = devstats->tx_bytes;
-	stats->rx_dropped     = devstats->rx_dropped + c_rx_dropped;
+	stats->rx_dropped     = devstats->rx_dropped;
 	stats->tx_dropped     = devstats->tx_dropped;
 	stats->tx_errors      = devstats->tx_errors;
 	stats->rx_errors      = devstats->rx_errors;
 	stats->rx_over_errors = devstats->rx_over_errors;

+#ifdef SL_INCLUDE_CSLIP
+	if (comp) {
+		/* Generic compressed statistics */
+		stats->rx_compressed   = comp->sls_i_compressed.
+		stats->tx_compressed   = comp->sls_o_compressed;
+
+		/* Are we really still needs this? */
+		stats->rx_fifo_errors += comp->sls_i_compressed;
+		stats->rx_dropped     += comp->sls_i_tossed;
+		stats->tx_fifo_errors += comp->sls_o_compressed;
+		stats->collisions     += comp->sls_o_misses;
+	}
+#endif
 	return stats;
 }

diff --git a/drivers/net/slip.h b/drivers/net/slip.h
index aa0764c..67673cf 100644
--- a/drivers/net/slip.h
+++ b/drivers/net/slip.h
@@ -65,15 +65,6 @@ struct slip {
   unsigned char		*xbuff;		/* transmitter buffer		*/
   unsigned char         *xhead;         /* pointer to next byte to XMIT */
   int                   xleft;          /* bytes left in XMIT queue     */
-
-  /* SLIP interface statistics. */
-#ifdef SL_INCLUDE_CSLIP
-  unsigned long		tx_compressed;
-  unsigned long		rx_compressed;
-  unsigned long		tx_misses;
-#endif
-  /* Detailed SLIP statistics. */
-
   int			mtu;		/* Our mtu (to spot changes!)   */
   int                   buffsize;       /* Max buffers sizes            */

-- 
1.7.6
