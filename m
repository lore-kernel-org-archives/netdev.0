From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 09/12] bnxt_en: Add a set of TX rings to support XDP.
Date: Mon,  6 Feb 2017 16:55:40 -0500
Message-ID: <1486418143-8958-10-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36456 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752067AbdBFV4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:09 -0500
Received: by mail-pf0-f173.google.com with SMTP id 189so26931945pfu.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:09 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add logic for an extra set of TX rings for XDP.  If enabled, this
set of TX rings equals the number of RX rings and shares the same
IRQ as the RX ring set.  A new field bp->tx_nr_rings_xdp is added
to keep track of these TX XDP rings.  Adjust all other relevant functions
to handle bp->tx_nr_rings_xdp.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 21 +++++++++++++--------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 16 ++++++++++++----
 3 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 811bc82..412a8de 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2218,6 +2218,8 @@ static int bnxt_alloc_tx_rings(struct bnxt *bp)
 			memset(txr->tx_push, 0, sizeof(struct tx_push_bd));
 		}
 		ring->queue_id = bp->q_info[j].queue_id;
+		if (i < bp->tx_nr_rings_xdp)
+			continue;
 		if (i % bp->tx_nr_rings_per_tc == (bp->tx_nr_rings_per_tc - 1))
 			j++;
 	}
@@ -3042,8 +3044,10 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 		for (i = 0; i < bp->tx_nr_rings; i++, j++) {
 			bp->tx_ring[i].bnapi = bp->bnapi[j];
 			bp->bnapi[j]->tx_ring = &bp->tx_ring[i];
-			bp->tx_ring_map[i] = i;
-			bp->tx_ring[i].txq_index = i;
+			bp->tx_ring_map[i] = bp->tx_nr_rings_xdp + i;
+			if (i >= bp->tx_nr_rings_xdp)
+				bp->tx_ring[i].txq_index = i -
+					bp->tx_nr_rings_xdp;
 		}
 
 		rc = bnxt_alloc_stats(bp);
@@ -4966,7 +4970,8 @@ static int bnxt_set_real_num_queues(struct bnxt *bp)
 	int rc;
 	struct net_device *dev = bp->dev;
 
-	rc = netif_set_real_num_tx_queues(dev, bp->tx_nr_rings);
+	rc = netif_set_real_num_tx_queues(dev, bp->tx_nr_rings -
+					  bp->tx_nr_rings_xdp);
 	if (rc)
 		return rc;
 
@@ -6582,7 +6587,7 @@ static void bnxt_sp_task(struct work_struct *work)
 }
 
 /* Under rtnl_lock */
-int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs)
+int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs, int tx_xdp)
 {
 	int max_rx, max_tx, tx_sets = 1;
 	int tx_rings_needed;
@@ -6602,12 +6607,12 @@ int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs)
 	if (max_rx < rx)
 		return -ENOMEM;
 
-	tx_rings_needed = tx * tx_sets;
+	tx_rings_needed = tx * tx_sets + tx_xdp;
 	if (max_tx < tx_rings_needed)
 		return -ENOMEM;
 
 	if (bnxt_hwrm_reserve_tx_rings(bp, &tx_rings_needed) ||
-	    tx_rings_needed < (tx * tx_sets))
+	    tx_rings_needed < (tx * tx_sets + tx_xdp))
 		return -ENOMEM;
 	return 0;
 }
@@ -6788,8 +6793,8 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 	if (bp->flags & BNXT_FLAG_SHARED_RINGS)
 		sh = true;
 
-	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc,
-				bp->rx_nr_rings, tc);
+	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
+				tc, bp->tx_nr_rings_xdp);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 97ccce1..4c3289a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1026,6 +1026,7 @@ struct bnxt {
 	int			tx_nr_pages;
 	int			tx_nr_rings;
 	int			tx_nr_rings_per_tc;
+	int			tx_nr_rings_xdp;
 
 	int			tx_wake_thresh;
 	int			tx_push_thresh;
@@ -1203,7 +1204,7 @@ int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 int bnxt_hwrm_fw_set_time(struct bnxt *);
 int bnxt_open_nic(struct bnxt *, bool, bool);
 int bnxt_close_nic(struct bnxt *, bool, bool);
-int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs);
+int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs, int tx_xdp);
 int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
 void bnxt_restore_pf_fw_resources(struct bnxt *bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 6f2568d..7aa248d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -389,6 +389,7 @@ static int bnxt_set_channels(struct net_device *dev,
 	struct bnxt *bp = netdev_priv(dev);
 	int req_tx_rings, req_rx_rings, tcs;
 	bool sh = false;
+	int tx_xdp = 0;
 	int rc = 0;
 
 	if (channel->other_count)
@@ -413,7 +414,14 @@ static int bnxt_set_channels(struct net_device *dev,
 
 	req_tx_rings = sh ? channel->combined_count : channel->tx_count;
 	req_rx_rings = sh ? channel->combined_count : channel->rx_count;
-	rc = bnxt_reserve_rings(bp, req_tx_rings, req_rx_rings, tcs);
+	if (bp->tx_nr_rings_xdp) {
+		if (!sh) {
+			netdev_err(dev, "Only combined mode supported when XDP is enabled.\n");
+			return -EINVAL;
+		}
+		tx_xdp = req_rx_rings;
+	}
+	rc = bnxt_reserve_rings(bp, req_tx_rings, req_rx_rings, tcs, tx_xdp);
 	if (rc) {
 		netdev_warn(dev, "Unable to allocate the requested rings\n");
 		return rc;
@@ -442,10 +450,10 @@ static int bnxt_set_channels(struct net_device *dev,
 		bp->rx_nr_rings = channel->rx_count;
 		bp->tx_nr_rings_per_tc = channel->tx_count;
 	}
-
-	bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
+	bp->tx_nr_rings_xdp = tx_xdp;
+	bp->tx_nr_rings = bp->tx_nr_rings_per_tc + tx_xdp;
 	if (tcs > 1)
-		bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tcs;
+		bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tcs + tx_xdp;
 
 	bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
 			       bp->tx_nr_rings + bp->rx_nr_rings;
-- 
1.8.3.1
