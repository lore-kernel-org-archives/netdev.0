From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3 net-next] bnx2: Add support for ethtool
 --show-channels|--set-channels
Date: Sun, 5 Feb 2012 17:24:38 -0800
Message-ID: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4550 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641Ab2BFBSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Feb 2012 20:18:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the user to override the default number of RSS/TSS rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   99 ++++++++++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/bnx2.h |    3 +
 2 files changed, 93 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 0a4c540..2ab31da 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6246,7 +6246,16 @@ static int
 bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
 	int cpus = num_online_cpus();
-	int msix_vecs = min(cpus + 1, RX_MAX_RINGS);
+	int msix_vecs;
+
+	if (!bp->num_req_rx_rings)
+		msix_vecs = max(cpus + 1, bp->num_req_tx_rings);
+	else if (!bp->num_req_tx_rings)
+		msix_vecs = max(cpus, bp->num_req_rx_rings);
+	else
+		msix_vecs = max(bp->num_req_rx_rings, bp->num_req_tx_rings);
+
+	msix_vecs = min(msix_vecs, RX_MAX_RINGS);
 
 	bp->irq_tbl[0].handler = bnx2_interrupt;
 	strcpy(bp->irq_tbl[0].name, bp->dev->name);
@@ -6270,10 +6279,18 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 		}
 	}
 
-	bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
+	if (!bp->num_req_tx_rings)
+		bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
+	else
+		bp->num_tx_rings = min(bp->irq_nvecs, bp->num_req_tx_rings);
+
+	if (!bp->num_req_rx_rings)
+		bp->num_rx_rings = bp->irq_nvecs;
+	else
+		bp->num_rx_rings = min(bp->irq_nvecs, bp->num_req_rx_rings);
+
 	netif_set_real_num_tx_queues(bp->dev, bp->num_tx_rings);
 
-	bp->num_rx_rings = bp->irq_nvecs;
 	return netif_set_real_num_rx_queues(bp->dev, bp->num_rx_rings);
 }
 
@@ -7162,7 +7179,7 @@ bnx2_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 }
 
 static int
-bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
+bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx, bool reset_irq)
 {
 	if (netif_running(bp->dev)) {
 		/* Reset will erase chipset stats; save them */
@@ -7170,7 +7187,12 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 
 		bnx2_netif_stop(bp, true);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
-		__bnx2_free_irq(bp);
+		if (reset_irq) {
+			bnx2_free_irq(bp);
+			bnx2_del_napi(bp);
+		} else {
+			__bnx2_free_irq(bp);
+		}
 		bnx2_free_skbs(bp);
 		bnx2_free_mem(bp);
 	}
@@ -7179,9 +7201,16 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 	bp->tx_ring_size = tx;
 
 	if (netif_running(bp->dev)) {
-		int rc;
+		int rc = 0;
+
+		if (reset_irq) {
+			rc = bnx2_setup_int_mode(bp, disable_msi);
+			bnx2_init_napi(bp);
+		}
+
+		if (!rc)
+			rc = bnx2_alloc_mem(bp);
 
-		rc = bnx2_alloc_mem(bp);
 		if (!rc)
 			rc = bnx2_request_irq(bp);
 
@@ -7217,7 +7246,8 @@ bnx2_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 
 		return -EINVAL;
 	}
-	rc = bnx2_change_ring_size(bp, ering->rx_pending, ering->tx_pending);
+	rc = bnx2_change_ring_size(bp, ering->rx_pending, ering->tx_pending,
+				   false);
 	return rc;
 }
 
@@ -7605,6 +7635,54 @@ bnx2_set_features(struct net_device *dev, netdev_features_t features)
 	return 0;
 }
 
+static void bnx2_get_channels(struct net_device *dev,
+			      struct ethtool_channels *channels)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	u32 max_rx_rings = 1;
+	u32 max_tx_rings = 1;
+
+	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !disable_msi) {
+		max_rx_rings = RX_MAX_RINGS;
+		max_tx_rings = TX_MAX_RINGS;
+	}
+
+	channels->max_rx = max_rx_rings;
+	channels->max_tx = max_tx_rings;
+	channels->max_other = 0;
+	channels->max_combined = 0;
+	channels->rx_count = bp->num_rx_rings;
+	channels->tx_count = bp->num_tx_rings;
+	channels->other_count = 0;
+	channels->combined_count = 0;
+}
+
+static int bnx2_set_channels(struct net_device *dev,
+			      struct ethtool_channels *channels)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	u32 max_rx_rings = 1;
+	u32 max_tx_rings = 1;
+	int rc = 0;
+
+	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !disable_msi) {
+		max_rx_rings = RX_MAX_RINGS;
+		max_tx_rings = TX_MAX_RINGS;
+	}
+	if (channels->rx_count > max_rx_rings ||
+	    channels->tx_count > max_tx_rings)
+		return -EINVAL;
+
+	bp->num_req_rx_rings = channels->rx_count;
+	bp->num_req_tx_rings = channels->tx_count;
+
+	if (netif_running(dev))
+		rc = bnx2_change_ring_size(bp, bp->rx_ring_size,
+					   bp->tx_ring_size, true);
+
+	return rc;
+}
+
 static const struct ethtool_ops bnx2_ethtool_ops = {
 	.get_settings		= bnx2_get_settings,
 	.set_settings		= bnx2_set_settings,
@@ -7629,6 +7707,8 @@ static const struct ethtool_ops bnx2_ethtool_ops = {
 	.set_phys_id		= bnx2_set_phys_id,
 	.get_ethtool_stats	= bnx2_get_ethtool_stats,
 	.get_sset_count		= bnx2_get_sset_count,
+	.get_channels		= bnx2_get_channels,
+	.set_channels		= bnx2_set_channels,
 };
 
 /* Called with rtnl_lock */
@@ -7710,7 +7790,8 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
-	return bnx2_change_ring_size(bp, bp->rx_ring_size, bp->tx_ring_size);
+	return bnx2_change_ring_size(bp, bp->rx_ring_size, bp->tx_ring_size,
+				     false);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 1db2d51..dc06bda 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6933,6 +6933,9 @@ struct bnx2 {
 	u8			num_tx_rings;
 	u8			num_rx_rings;
 
+	int			num_req_tx_rings;
+	int			num_req_rx_rings;
+
 	u32 			leds_save;
 	u32			idle_chk_status_idx;
 
-- 
1.6.4.GIT
