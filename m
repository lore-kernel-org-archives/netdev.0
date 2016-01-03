From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 5/7] bnxt_en: Modify bnxt_get_max_rings() to support shared or non shared rings.
Date: Sat, 2 Jan 2016 23:45:02 -0500
Message-ID: <1451796304-23220-6-git-send-email-mchan@broadcom.com>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:50073 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbcACEpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:08 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add logic to calculate how many shared or non shared rings can be
supported.  Default is to use shared rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 96 +++++++++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  4 +-
 3 files changed, 79 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8a54dab..4f7b231 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4038,6 +4038,30 @@ static int bnxt_set_real_num_queues(struct bnxt *bp)
 	return rc;
 }
 
+static int bnxt_trim_rings(struct bnxt *bp, int *rx, int *tx, int max,
+			   bool shared)
+{
+	int _rx = *rx, _tx = *tx;
+
+	if (shared) {
+		*rx = min_t(int, _rx, max);
+		*tx = min_t(int, _tx, max);
+	} else {
+		if (max < 2)
+			return -ENOMEM;
+
+		while (_rx + _tx > max) {
+			if (_rx > _tx && _rx > 1)
+				_rx--;
+			else if (_tx > 1)
+				_tx--;
+		}
+		*rx = _rx;
+		*tx = _tx;
+	}
+	return 0;
+}
+
 static int bnxt_setup_msix(struct bnxt *bp)
 {
 	struct msix_entry *msix_ent;
@@ -4068,8 +4092,11 @@ static int bnxt_setup_msix(struct bnxt *bp)
 		int tcs;
 
 		/* Trim rings based upon num of vectors allocated */
-		bp->rx_nr_rings = min_t(int, total_vecs, bp->rx_nr_rings);
-		bp->tx_nr_rings = min_t(int, total_vecs, bp->tx_nr_rings);
+		rc = bnxt_trim_rings(bp, &bp->rx_nr_rings, &bp->tx_nr_rings,
+				     total_vecs, true);
+		if (rc)
+			goto msix_setup_exit;
+
 		bp->tx_nr_rings_per_tc = bp->tx_nr_rings;
 		tcs = netdev_get_num_tc(dev);
 		if (tcs > 1) {
@@ -5337,10 +5364,10 @@ static int bnxt_setup_tc(struct net_device *dev, u8 tc)
 		return 0;
 
 	if (tc) {
-		int max_rx_rings, max_tx_rings;
+		int max_rx_rings, max_tx_rings, rc;
 
-		bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings);
-		if (bp->tx_nr_rings_per_tc * tc > max_tx_rings)
+		rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
+		if (rc || bp->tx_nr_rings_per_tc * tc > max_tx_rings)
 			return -ENOMEM;
 	}
 
@@ -5654,31 +5681,62 @@ static int bnxt_get_max_irq(struct pci_dev *pdev)
 	return (ctrl & PCI_MSIX_FLAGS_QSIZE) + 1;
 }
 
-void bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx)
+static void _bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx,
+				int *max_cp)
 {
-	int max_rings = 0, max_ring_grps = 0;
+	int max_ring_grps = 0;
 
 	if (BNXT_PF(bp)) {
 		*max_tx = bp->pf.max_tx_rings;
 		*max_rx = bp->pf.max_rx_rings;
-		max_rings = min_t(int, bp->pf.max_irqs, bp->pf.max_cp_rings);
-		max_rings = min_t(int, max_rings, bp->pf.max_stat_ctxs);
+		*max_cp = min_t(int, bp->pf.max_irqs, bp->pf.max_cp_rings);
+		*max_cp = min_t(int, *max_cp, bp->pf.max_stat_ctxs);
 		max_ring_grps = bp->pf.max_hw_ring_grps;
 	} else {
 #ifdef CONFIG_BNXT_SRIOV
 		*max_tx = bp->vf.max_tx_rings;
 		*max_rx = bp->vf.max_rx_rings;
-		max_rings = min_t(int, bp->vf.max_irqs, bp->vf.max_cp_rings);
-		max_rings = min_t(int, max_rings, bp->vf.max_stat_ctxs);
+		*max_cp = min_t(int, bp->vf.max_irqs, bp->vf.max_cp_rings);
+		*max_cp = min_t(int, *max_cp, bp->vf.max_stat_ctxs);
 		max_ring_grps = bp->vf.max_hw_ring_grps;
 #endif
 	}
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
 		*max_rx >>= 1;
-
-	*max_rx = min_t(int, *max_rx, max_rings);
 	*max_rx = min_t(int, *max_rx, max_ring_grps);
-	*max_tx = min_t(int, *max_tx, max_rings);
+}
+
+int bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx, bool shared)
+{
+	int rx, tx, cp;
+
+	_bnxt_get_max_rings(bp, &rx, &tx, &cp);
+	if (!rx || !tx || !cp)
+		return -ENOMEM;
+
+	*max_rx = rx;
+	*max_tx = tx;
+	return bnxt_trim_rings(bp, max_rx, max_tx, cp, shared);
+}
+
+static int bnxt_set_dflt_rings(struct bnxt *bp)
+{
+	int dflt_rings, max_rx_rings, max_tx_rings, rc;
+	bool sh = true;
+
+	if (sh)
+		bp->flags |= BNXT_FLAG_SHARED_RINGS;
+	dflt_rings = netif_get_num_default_rss_queues();
+	rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
+	if (rc)
+		return rc;
+	bp->rx_nr_rings = min_t(int, dflt_rings, max_rx_rings);
+	bp->tx_nr_rings_per_tc = min_t(int, dflt_rings, max_tx_rings);
+	bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
+	bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
+			       bp->tx_nr_rings + bp->rx_nr_rings;
+	bp->num_stat_ctxs = bp->cp_nr_rings;
+	return rc;
 }
 
 static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
@@ -5686,7 +5744,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	static int version_printed;
 	struct net_device *dev;
 	struct bnxt *bp;
-	int rc, max_rx_rings, max_tx_rings, max_irqs, dflt_rings;
+	int rc, max_irqs;
 
 	if (version_printed++ == 0)
 		pr_info("%s", version);
@@ -5765,19 +5823,13 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
-	dflt_rings = netif_get_num_default_rss_queues();
 	if (BNXT_PF(bp))
 		bp->pf.max_irqs = max_irqs;
 #if defined(CONFIG_BNXT_SRIOV)
 	else
 		bp->vf.max_irqs = max_irqs;
 #endif
-	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings);
-	bp->rx_nr_rings = min_t(int, dflt_rings, max_rx_rings);
-	bp->tx_nr_rings_per_tc = min_t(int, dflt_rings, max_tx_rings);
-	bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
-	bp->cp_nr_rings = max_t(int, bp->rx_nr_rings, bp->tx_nr_rings);
-	bp->num_stat_ctxs = bp->cp_nr_rings;
+	bnxt_set_dflt_rings(bp);
 
 	if (BNXT_PF(bp)) {
 		dev->hw_features |= NETIF_F_NTUPLE;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index ec3edcc..8af3ca8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -877,6 +877,8 @@ struct bnxt {
 	#define BNXT_FLAG_USING_MSIX	0x40
 	#define BNXT_FLAG_MSIX_CAP	0x80
 	#define BNXT_FLAG_RFS		0x100
+	#define BNXT_FLAG_SHARED_RINGS	0x200
+
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
 					    BNXT_FLAG_RFS |		\
 					    BNXT_FLAG_STRIP_VLAN)
@@ -1096,5 +1098,5 @@ int bnxt_hwrm_set_pause(struct bnxt *);
 int bnxt_hwrm_set_link_setting(struct bnxt *, bool);
 int bnxt_open_nic(struct bnxt *, bool, bool);
 int bnxt_close_nic(struct bnxt *, bool, bool);
-void bnxt_get_max_rings(struct bnxt *, int *, int *);
+int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index a39511f..8ad1b6c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -211,7 +211,7 @@ static void bnxt_get_channels(struct net_device *dev,
 	struct bnxt *bp = netdev_priv(dev);
 	int max_rx_rings, max_tx_rings, tcs;
 
-	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings);
+	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
 	tcs = netdev_get_num_tc(dev);
 	if (tcs > 1)
 		max_tx_rings /= tcs;
@@ -235,7 +235,7 @@ static int bnxt_set_channels(struct net_device *dev,
 	    !channel->rx_count || !channel->tx_count)
 		return -EINVAL;
 
-	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings);
+	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
 	tcs = netdev_get_num_tc(dev);
 	if (tcs > 1)
 		max_tx_rings /= tcs;
-- 
1.8.3.1
