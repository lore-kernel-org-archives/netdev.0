From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 07/12] bnxt_en: Check hardware resources before enabling NTUPLE.
Date: Sun, 27 Dec 2015 18:19:24 -0500
Message-ID: <1451258369-21543-8-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:44954 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808AbbL0XTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:32 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware resources required to enable NTUPLE varies depending on
how many rx channels are configured.  We need to make sure we have the
resources before we enable NTUPLE.  Add bnxt_rfs_capable() to do the
checking.

In addition, we need to do the same checking in ndo_fix_features().  As
the rx channels are changed using ethtool -L, we call
netdev_update_features() to make the necessary adjustment for NTUPLE.

Calling netdev_update_features() in netif_running() state but before
calling bnxt_open_nic() would be a problem.  To make this work,
bnxt_set_features() has to be modified to test for BNXT_STATE_OPEN for
the true hardware state instead of checking netif_running().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 41 ++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  2 ++
 2 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 082c1e9..8827b7b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4916,9 +4916,32 @@ skip_uc:
 	return rc;
 }
 
+static bool bnxt_rfs_capable(struct bnxt *bp)
+{
+#ifdef CONFIG_RFS_ACCEL
+	struct bnxt_pf_info *pf = &bp->pf;
+	int vnics;
+
+	if (BNXT_VF(bp) || !(bp->flags & BNXT_FLAG_MSIX_CAP))
+		return false;
+
+	vnics = 1 + bp->rx_nr_rings;
+	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics)
+		return false;
+
+	return true;
+#else
+	return false;
+#endif
+}
+
 static netdev_features_t bnxt_fix_features(struct net_device *dev,
 					   netdev_features_t features)
 {
+	struct bnxt *bp = netdev_priv(dev);
+
+	if (!bnxt_rfs_capable(bp))
+		features &= ~NETIF_F_NTUPLE;
 	return features;
 }
 
@@ -4959,7 +4982,7 @@ static int bnxt_set_features(struct net_device *dev, netdev_features_t features)
 
 		bp->flags = flags;
 
-		if (!netif_running(dev)) {
+		if (!test_bit(BNXT_STATE_OPEN, &bp->state)) {
 			if (update_tpa)
 				bnxt_set_ring_params(bp);
 			return rc;
@@ -5639,11 +5662,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (bnxt_vf_pciid(ent->driver_data))
 		bp->flags |= BNXT_FLAG_VF;
 
-	if (pdev->msix_cap) {
+	if (pdev->msix_cap)
 		bp->flags |= BNXT_FLAG_MSIX_CAP;
-		if (BNXT_PF(bp))
-			bp->flags |= BNXT_FLAG_RFS;
-	}
 
 	rc = bnxt_init_board(pdev, dev);
 	if (rc < 0)
@@ -5662,9 +5682,6 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_RXHASH |
 			   NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO;
 
-	if (bp->flags & BNXT_FLAG_RFS)
-		dev->hw_features |= NETIF_F_NTUPLE;
-
 	dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO6 |
@@ -5723,6 +5740,14 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bp->cp_nr_rings = max_t(int, bp->rx_nr_rings, bp->tx_nr_rings);
 	bp->num_stat_ctxs = bp->cp_nr_rings;
 
+	if (BNXT_PF(bp)) {
+		dev->hw_features |= NETIF_F_NTUPLE;
+		if (bnxt_rfs_capable(bp)) {
+			bp->flags |= BNXT_FLAG_RFS;
+			dev->features |= NETIF_F_NTUPLE;
+		}
+	}
+
 	if (dev->hw_features & NETIF_F_HW_VLAN_CTAG_RX)
 		bp->flags |= BNXT_FLAG_STRIP_VLAN;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index ea94450..a39511f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -266,6 +266,8 @@ static int bnxt_set_channels(struct net_device *dev,
 	bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
 	bp->num_stat_ctxs = bp->cp_nr_rings;
 
+	/* After changing number of rx channels, update NTUPLE feature. */
+	netdev_update_features(dev);
 	if (netif_running(dev)) {
 		rc = bnxt_open_nic(bp, true, false);
 		if ((!rc) && BNXT_PF(bp)) {
-- 
1.8.3.1
