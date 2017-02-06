From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 07/12] bnxt_en: Centralize logic to reserve rings.
Date: Mon,  6 Feb 2017 16:55:38 -0500
Message-ID: <1486418143-8958-8-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36205 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752067AbdBFV4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:07 -0500
Received: by mail-pg0-f48.google.com with SMTP id v184so31801983pgv.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:06 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bnxt_setup_tc() and bnxt_set_channels() have similar and
duplicated code to check and reserve rx and tx rings.  Add a new
function bnxt_reserve_rings() to centralize the logic.  This will
make it easier to add XDP_TX support which requires allocating a
new set of TX rings.

Also, the tx ring checking logic in bnxt_setup_msix() can be removed.
The rings have been reserved before hand.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 68 ++++++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 39 +++----------
 3 files changed, 52 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 32c808f..1b051f9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4212,7 +4212,7 @@ int __bnxt_hwrm_get_tx_rings(struct bnxt *bp, u16 fid, int *tx_rings)
 	return rc;
 }
 
-int bnxt_hwrm_reserve_tx_rings(struct bnxt *bp, int *tx_rings)
+static int bnxt_hwrm_reserve_tx_rings(struct bnxt *bp, int *tx_rings)
 {
 	struct hwrm_func_cfg_input req = {0};
 	int rc;
@@ -5005,19 +5005,12 @@ static void bnxt_setup_msix(struct bnxt *bp)
 
 	tcs = netdev_get_num_tc(dev);
 	if (tcs > 1) {
-		bp->tx_nr_rings_per_tc = bp->tx_nr_rings / tcs;
-		if (bp->tx_nr_rings_per_tc == 0) {
-			netdev_reset_tc(dev);
-			bp->tx_nr_rings_per_tc = bp->tx_nr_rings;
-		} else {
-			int i, off, count;
+		int i, off, count;
 
-			bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tcs;
-			for (i = 0; i < tcs; i++) {
-				count = bp->tx_nr_rings_per_tc;
-				off = i * count;
-				netdev_set_tc_queue(dev, i, count, off);
-			}
+		for (i = 0; i < tcs; i++) {
+			count = bp->tx_nr_rings_per_tc;
+			off = i * count;
+			netdev_set_tc_queue(dev, i, count, off);
 		}
 	}
 
@@ -6579,6 +6572,37 @@ static void bnxt_sp_task(struct work_struct *work)
 	clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 }
 
+/* Under rtnl_lock */
+int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs)
+{
+	int max_rx, max_tx, tx_sets = 1;
+	int tx_rings_needed;
+	bool sh = true;
+	int rc;
+
+	if (!(bp->flags & BNXT_FLAG_SHARED_RINGS))
+		sh = false;
+
+	if (tcs)
+		tx_sets = tcs;
+
+	rc = bnxt_get_max_rings(bp, &max_rx, &max_tx, sh);
+	if (rc)
+		return rc;
+
+	if (max_rx < rx)
+		return -ENOMEM;
+
+	tx_rings_needed = tx * tx_sets;
+	if (max_tx < tx_rings_needed)
+		return -ENOMEM;
+
+	if (bnxt_hwrm_reserve_tx_rings(bp, &tx_rings_needed) ||
+	    tx_rings_needed < (tx * tx_sets))
+		return -ENOMEM;
+	return 0;
+}
+
 static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
 	int rc;
@@ -6741,6 +6765,7 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 {
 	struct bnxt *bp = netdev_priv(dev);
 	bool sh = false;
+	int rc;
 
 	if (tc > bp->max_tc) {
 		netdev_err(dev, "too many traffic classes requested: %d Max supported is %d\n",
@@ -6754,19 +6779,10 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 	if (bp->flags & BNXT_FLAG_SHARED_RINGS)
 		sh = true;
 
-	if (tc) {
-		int max_rx_rings, max_tx_rings, req_tx_rings, rsv_tx_rings, rc;
-
-		req_tx_rings = bp->tx_nr_rings_per_tc * tc;
-		rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
-		if (rc || req_tx_rings > max_tx_rings)
-			return -ENOMEM;
-
-		rsv_tx_rings = req_tx_rings;
-		if (bnxt_hwrm_reserve_tx_rings(bp, &rsv_tx_rings) ||
-		    rsv_tx_rings < req_tx_rings)
-			return -ENOMEM;
-	}
+	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc,
+				bp->rx_nr_rings, tc);
+	if (rc)
+		return rc;
 
 	/* Needs to close the device and do hw resource re-allocations */
 	if (netif_running(bp->dev))
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 7f59ce9..3a079b8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1188,7 +1188,6 @@ int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 				     int bmap_size);
 int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id);
 int __bnxt_hwrm_get_tx_rings(struct bnxt *bp, u16 fid, int *tx_rings);
-int bnxt_hwrm_reserve_tx_rings(struct bnxt *bp, int *tx_rings);
 int bnxt_hwrm_set_coal(struct bnxt *);
 unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp);
 void bnxt_set_max_func_stat_ctxs(struct bnxt *bp, unsigned int max);
@@ -1202,6 +1201,7 @@ int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 int bnxt_hwrm_fw_set_time(struct bnxt *);
 int bnxt_open_nic(struct bnxt *, bool, bool);
 int bnxt_close_nic(struct bnxt *, bool, bool);
+int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, int tcs);
 int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
 void bnxt_restore_pf_fw_resources(struct bnxt *bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 24818e1..6f2568d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -387,10 +387,9 @@ static int bnxt_set_channels(struct net_device *dev,
 			     struct ethtool_channels *channel)
 {
 	struct bnxt *bp = netdev_priv(dev);
-	int max_rx_rings, max_tx_rings, tcs;
-	int req_tx_rings, rsv_tx_rings;
-	u32 rc = 0;
+	int req_tx_rings, req_rx_rings, tcs;
 	bool sh = false;
+	int rc = 0;
 
 	if (channel->other_count)
 		return -EINVAL;
@@ -410,32 +409,14 @@ static int bnxt_set_channels(struct net_device *dev,
 	if (channel->combined_count)
 		sh = true;
 
-	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
-
 	tcs = netdev_get_num_tc(dev);
-	if (tcs > 1)
-		max_tx_rings /= tcs;
-
-	if (sh &&
-	    channel->combined_count > max_t(int, max_rx_rings, max_tx_rings))
-		return -ENOMEM;
-
-	if (!sh && (channel->rx_count > max_rx_rings ||
-		    channel->tx_count > max_tx_rings))
-		return -ENOMEM;
 
 	req_tx_rings = sh ? channel->combined_count : channel->tx_count;
-	req_tx_rings = min_t(int, req_tx_rings, max_tx_rings);
-	if (tcs > 1)
-		req_tx_rings *= tcs;
-
-	rsv_tx_rings = req_tx_rings;
-	if (bnxt_hwrm_reserve_tx_rings(bp, &rsv_tx_rings))
-		return -ENOMEM;
-
-	if (rsv_tx_rings < req_tx_rings) {
-		netdev_warn(dev, "Unable to allocate the requested tx rings\n");
-		return -ENOMEM;
+	req_rx_rings = sh ? channel->combined_count : channel->rx_count;
+	rc = bnxt_reserve_rings(bp, req_tx_rings, req_rx_rings, tcs);
+	if (rc) {
+		netdev_warn(dev, "Unable to allocate the requested rings\n");
+		return rc;
 	}
 
 	if (netif_running(dev)) {
@@ -454,10 +435,8 @@ static int bnxt_set_channels(struct net_device *dev,
 
 	if (sh) {
 		bp->flags |= BNXT_FLAG_SHARED_RINGS;
-		bp->rx_nr_rings = min_t(int, channel->combined_count,
-					max_rx_rings);
-		bp->tx_nr_rings_per_tc = min_t(int, channel->combined_count,
-					       max_tx_rings);
+		bp->rx_nr_rings = channel->combined_count;
+		bp->tx_nr_rings_per_tc = channel->combined_count;
 	} else {
 		bp->flags &= ~BNXT_FLAG_SHARED_RINGS;
 		bp->rx_nr_rings = channel->rx_count;
-- 
1.8.3.1
