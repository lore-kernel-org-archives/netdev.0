From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 7/7] bnxt_en: Modify ethtool -l|-L to support combined or rx/tx rings.
Date: Sat, 2 Jan 2016 23:45:04 -0500
Message-ID: <1451796304-23220-8-git-send-email-mchan@broadcom.com>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:4198 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbcACEpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:07 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver can support either all combined or all rx/tx rings.  The
default is combined, but the user can now select rx/tx rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 57 ++++++++++++++++++-----
 1 file changed, 45 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 8ad1b6c..4f62c9f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -212,6 +212,9 @@ static void bnxt_get_channels(struct net_device *dev,
 	int max_rx_rings, max_tx_rings, tcs;
 
 	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
+	channel->max_combined = max_rx_rings;
+
+	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, false);
 	tcs = netdev_get_num_tc(dev);
 	if (tcs > 1)
 		max_tx_rings /= tcs;
@@ -219,9 +222,12 @@ static void bnxt_get_channels(struct net_device *dev,
 	channel->max_rx = max_rx_rings;
 	channel->max_tx = max_tx_rings;
 	channel->max_other = 0;
-	channel->max_combined = 0;
-	channel->rx_count = bp->rx_nr_rings;
-	channel->tx_count = bp->tx_nr_rings_per_tc;
+	if (bp->flags & BNXT_FLAG_SHARED_RINGS) {
+		channel->combined_count = bp->rx_nr_rings;
+	} else {
+		channel->rx_count = bp->rx_nr_rings;
+		channel->tx_count = bp->tx_nr_rings_per_tc;
+	}
 }
 
 static int bnxt_set_channels(struct net_device *dev,
@@ -230,19 +236,35 @@ static int bnxt_set_channels(struct net_device *dev,
 	struct bnxt *bp = netdev_priv(dev);
 	int max_rx_rings, max_tx_rings, tcs;
 	u32 rc = 0;
+	bool sh = false;
 
-	if (channel->other_count || channel->combined_count ||
-	    !channel->rx_count || !channel->tx_count)
+	if (channel->other_count)
 		return -EINVAL;
 
-	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
+	if (!channel->combined_count &&
+	    (!channel->rx_count || !channel->tx_count))
+		return -EINVAL;
+
+	if (channel->combined_count &&
+	    (channel->rx_count || channel->tx_count))
+		return -EINVAL;
+
+	if (channel->combined_count)
+		sh = true;
+
+	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
+
 	tcs = netdev_get_num_tc(dev);
 	if (tcs > 1)
 		max_tx_rings /= tcs;
 
-	if (channel->rx_count > max_rx_rings ||
-	    channel->tx_count > max_tx_rings)
-		return -EINVAL;
+	if (sh && (channel->combined_count > max_rx_rings ||
+		   channel->combined_count > max_tx_rings))
+		return -ENOMEM;
+
+	if (!sh && (channel->rx_count > max_rx_rings ||
+		    channel->tx_count > max_tx_rings))
+		return -ENOMEM;
 
 	if (netif_running(dev)) {
 		if (BNXT_PF(bp)) {
@@ -258,12 +280,23 @@ static int bnxt_set_channels(struct net_device *dev,
 		}
 	}
 
-	bp->rx_nr_rings = channel->rx_count;
-	bp->tx_nr_rings_per_tc = channel->tx_count;
+	if (sh) {
+		bp->flags |= BNXT_FLAG_SHARED_RINGS;
+		bp->rx_nr_rings = channel->combined_count;
+		bp->tx_nr_rings_per_tc = channel->combined_count;
+	} else {
+		bp->flags &= ~BNXT_FLAG_SHARED_RINGS;
+		bp->rx_nr_rings = channel->rx_count;
+		bp->tx_nr_rings_per_tc = channel->tx_count;
+	}
+
 	bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
 	if (tcs > 1)
 		bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tcs;
-	bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
+
+	bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
+			       bp->tx_nr_rings + bp->rx_nr_rings;
+
 	bp->num_stat_ctxs = bp->cp_nr_rings;
 
 	/* After changing number of rx channels, update NTUPLE feature. */
-- 
1.8.3.1
