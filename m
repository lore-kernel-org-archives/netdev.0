From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH v2] b44: add 64 bit stats
Date: Tue, 17 Jul 2012 23:46:01 -0400
Message-ID: <1342583161-1184-1-git-send-email-kgroeneveld@gmail.com>
References: <20120716.230806.242760837075045729.davem@davemloft.net>
Cc: Kevin Groeneveld <kgroeneveld@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54786 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab2GRDqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 23:46:09 -0400
Received: by yenl2 with SMTP id l2so1159675yen.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 20:46:09 -0700 (PDT)
In-Reply-To: <20120716.230806.242760837075045729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Groeneveld <kgroeneveld@gmail.com>

Add support for 64 bit stats to Broadcom b44 ethernet driver.

Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
---
v2: use u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh instead of
    u64_stats_fetch_begin/u64_stats_fetch_retry as stats update happens in a
    timer interrupt

 drivers/net/ethernet/broadcom/b44.c |   96 ++++++++++++++++++++---------------
 drivers/net/ethernet/broadcom/b44.h |    3 +-
 2 files changed, 58 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index d09c6b5..9786c0e 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -483,9 +483,11 @@ out:
 static void b44_stats_update(struct b44 *bp)
 {
 	unsigned long reg;
-	u32 *val;
+	u64 *val;
 
 	val = &bp->hw_stats.tx_good_octets;
+	u64_stats_update_begin(&bp->hw_stats.syncp);
+
 	for (reg = B44_TX_GOOD_O; reg <= B44_TX_PAUSE; reg += 4UL) {
 		*val++ += br32(bp, reg);
 	}
@@ -496,6 +498,8 @@ static void b44_stats_update(struct b44 *bp)
 	for (reg = B44_RX_GOOD_O; reg <= B44_RX_NPAUSE; reg += 4UL) {
 		*val++ += br32(bp, reg);
 	}
+
+	u64_stats_update_end(&bp->hw_stats.syncp);
 }
 
 static void b44_link_report(struct b44 *bp)
@@ -1635,44 +1639,49 @@ static int b44_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *b44_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *b44_get_stats64(struct net_device *dev,
+					struct rtnl_link_stats64 *nstat)
 {
 	struct b44 *bp = netdev_priv(dev);
-	struct net_device_stats *nstat = &dev->stats;
 	struct b44_hw_stats *hwstat = &bp->hw_stats;
-
-	/* Convert HW stats into netdevice stats. */
-	nstat->rx_packets = hwstat->rx_pkts;
-	nstat->tx_packets = hwstat->tx_pkts;
-	nstat->rx_bytes   = hwstat->rx_octets;
-	nstat->tx_bytes   = hwstat->tx_octets;
-	nstat->tx_errors  = (hwstat->tx_jabber_pkts +
-			     hwstat->tx_oversize_pkts +
-			     hwstat->tx_underruns +
-			     hwstat->tx_excessive_cols +
-			     hwstat->tx_late_cols);
-	nstat->multicast  = hwstat->tx_multicast_pkts;
-	nstat->collisions = hwstat->tx_total_cols;
-
-	nstat->rx_length_errors = (hwstat->rx_oversize_pkts +
-				   hwstat->rx_undersize);
-	nstat->rx_over_errors   = hwstat->rx_missed_pkts;
-	nstat->rx_frame_errors  = hwstat->rx_align_errs;
-	nstat->rx_crc_errors    = hwstat->rx_crc_errs;
-	nstat->rx_errors        = (hwstat->rx_jabber_pkts +
-				   hwstat->rx_oversize_pkts +
-				   hwstat->rx_missed_pkts +
-				   hwstat->rx_crc_align_errs +
-				   hwstat->rx_undersize +
-				   hwstat->rx_crc_errs +
-				   hwstat->rx_align_errs +
-				   hwstat->rx_symbol_errs);
-
-	nstat->tx_aborted_errors = hwstat->tx_underruns;
+	unsigned int start;
+
+	do {
+		start = u64_stats_fetch_begin_bh(&hwstat->syncp);
+
+		/* Convert HW stats into rtnl_link_stats64 stats. */
+		nstat->rx_packets = hwstat->rx_pkts;
+		nstat->tx_packets = hwstat->tx_pkts;
+		nstat->rx_bytes   = hwstat->rx_octets;
+		nstat->tx_bytes   = hwstat->tx_octets;
+		nstat->tx_errors  = (hwstat->tx_jabber_pkts +
+				     hwstat->tx_oversize_pkts +
+				     hwstat->tx_underruns +
+				     hwstat->tx_excessive_cols +
+				     hwstat->tx_late_cols);
+		nstat->multicast  = hwstat->tx_multicast_pkts;
+		nstat->collisions = hwstat->tx_total_cols;
+
+		nstat->rx_length_errors = (hwstat->rx_oversize_pkts +
+					   hwstat->rx_undersize);
+		nstat->rx_over_errors   = hwstat->rx_missed_pkts;
+		nstat->rx_frame_errors  = hwstat->rx_align_errs;
+		nstat->rx_crc_errors    = hwstat->rx_crc_errs;
+		nstat->rx_errors        = (hwstat->rx_jabber_pkts +
+					   hwstat->rx_oversize_pkts +
+					   hwstat->rx_missed_pkts +
+					   hwstat->rx_crc_align_errs +
+					   hwstat->rx_undersize +
+					   hwstat->rx_crc_errs +
+					   hwstat->rx_align_errs +
+					   hwstat->rx_symbol_errs);
+
+		nstat->tx_aborted_errors = hwstat->tx_underruns;
 #if 0
-	/* Carrier lost counter seems to be broken for some devices */
-	nstat->tx_carrier_errors = hwstat->tx_carrier_lost;
+		/* Carrier lost counter seems to be broken for some devices */
+		nstat->tx_carrier_errors = hwstat->tx_carrier_lost;
 #endif
+	} while (u64_stats_fetch_retry_bh(&hwstat->syncp, start));
 
 	return nstat;
 }
@@ -1993,17 +2002,24 @@ static void b44_get_ethtool_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct b44 *bp = netdev_priv(dev);
-	u32 *val = &bp->hw_stats.tx_good_octets;
+	struct b44_hw_stats *hwstat = &bp->hw_stats;
+	u64 *data_src, *data_dst;
+	unsigned int start;
 	u32 i;
 
 	spin_lock_irq(&bp->lock);
-
 	b44_stats_update(bp);
+	spin_unlock_irq(&bp->lock);
 
-	for (i = 0; i < ARRAY_SIZE(b44_gstrings); i++)
-		*data++ = *val++;
+	do {
+		data_src = &hwstat->tx_good_octets;
+		data_dst = data;
+		start = u64_stats_fetch_begin_bh(&hwstat->syncp);
 
-	spin_unlock_irq(&bp->lock);
+		for (i = 0; i < ARRAY_SIZE(b44_gstrings); i++)
+			*data_dst++ = *data_src++;
+
+	} while (u64_stats_fetch_retry_bh(&hwstat->syncp, start));
 }
 
 static void b44_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
@@ -2113,7 +2129,7 @@ static const struct net_device_ops b44_netdev_ops = {
 	.ndo_open		= b44_open,
 	.ndo_stop		= b44_close,
 	.ndo_start_xmit		= b44_start_xmit,
-	.ndo_get_stats		= b44_get_stats,
+	.ndo_get_stats64	= b44_get_stats64,
 	.ndo_set_rx_mode	= b44_set_rx_mode,
 	.ndo_set_mac_address	= b44_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
index e1905a4..8993d72 100644
--- a/drivers/net/ethernet/broadcom/b44.h
+++ b/drivers/net/ethernet/broadcom/b44.h
@@ -338,9 +338,10 @@ struct ring_info {
  * the layout
  */
 struct b44_hw_stats {
-#define _B44(x)	u32 x;
+#define _B44(x)	u64 x;
 B44_STAT_REG_DECLARE
 #undef _B44
+	struct u64_stats_sync	syncp;
 };
 
 struct ssb_device;
-- 
1.7.9.5
