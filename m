From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/6] bnxt_en: Workaround Nitro A0 hardware RX bug (part 2).
Date: Mon, 18 Jul 2016 07:15:22 -0400
Message-ID: <1468840525-340-4-git-send-email-michael.chan@broadcom.com>
References: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34351 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbcGRLPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:15:38 -0400
Received: by mail-oi0-f51.google.com with SMTP id l65so161127448oib.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:15:37 -0700 (PDT)
In-Reply-To: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant.sreedharan@broadcom.com>

The hardware is unable to drop rx packets not matching the RX filters.  To
workaround it, we create a special VNIC and configure the hardware to
direct all packets not matching the filters to it.  We then setup the
driver to drop packets received on this VNIC.

This patch creates the infrastructure for this VNIC, reserves a
completion ring, and rx rings.  Only shared completion ring mode is
supported.  The next 2 patches add a NAPI to handle packets from this
VNIC and the setup of the VNIC.

Signed-off-by: Prashant Sreedharan <prashant.sreedharan@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 17 +++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 12 ++++++++++--
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index de74012..75a8b30 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3433,6 +3433,8 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 		ring = 0;
 	else if (vnic->flags & BNXT_VNIC_RFS_FLAG)
 		ring = vnic_id - 1;
+	else if ((vnic_id == 1) && BNXT_CHIP_TYPE_NITRO_A0(bp))
+		ring = bp->rx_nr_rings - 1;
 
 	grp_idx = bp->rx_ring[ring].bnapi->index;
 	req.vnic_id = cpu_to_le16(vnic->fw_vnic_id);
@@ -4365,6 +4367,7 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 {
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[0];
 	int rc = 0;
+	unsigned int rx_nr_rings = bp->rx_nr_rings;
 
 	if (irq_re_init) {
 		rc = bnxt_hwrm_stat_ctx_alloc(bp);
@@ -4387,8 +4390,11 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 		goto err_out;
 	}
 
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp))
+		rx_nr_rings--;
+
 	/* default vnic 0 */
-	rc = bnxt_hwrm_vnic_alloc(bp, 0, 0, bp->rx_nr_rings);
+	rc = bnxt_hwrm_vnic_alloc(bp, 0, 0, rx_nr_rings);
 	if (rc) {
 		netdev_err(bp->dev, "hwrm vnic alloc failure rc: %x\n", rc);
 		goto err_out;
@@ -6519,7 +6525,10 @@ static void _bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx,
 		*max_cp = min_t(int, *max_cp, bp->pf.max_stat_ctxs);
 		max_ring_grps = bp->pf.max_hw_ring_grps;
 	}
-
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp) && BNXT_PF(bp)) {
+		*max_cp -= 1;
+		*max_rx -= 2;
+	}
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
 		*max_rx >>= 1;
 	*max_rx = min_t(int, *max_rx, max_ring_grps);
@@ -6555,6 +6564,10 @@ static int bnxt_set_dflt_rings(struct bnxt *bp)
 	bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
 			       bp->tx_nr_rings + bp->rx_nr_rings;
 	bp->num_stat_ctxs = bp->cp_nr_rings;
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+		bp->rx_nr_rings++;
+		bp->cp_nr_rings++;
+	}
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 0f7dd86..492c06b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -362,9 +362,13 @@ static void bnxt_get_channels(struct net_device *dev,
 	channel->max_other = 0;
 	if (bp->flags & BNXT_FLAG_SHARED_RINGS) {
 		channel->combined_count = bp->rx_nr_rings;
+		if (BNXT_CHIP_TYPE_NITRO_A0(bp))
+			channel->combined_count--;
 	} else {
-		channel->rx_count = bp->rx_nr_rings;
-		channel->tx_count = bp->tx_nr_rings_per_tc;
+		if (!BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+			channel->rx_count = bp->rx_nr_rings;
+			channel->tx_count = bp->tx_nr_rings_per_tc;
+		}
 	}
 }
 
@@ -387,6 +391,10 @@ static int bnxt_set_channels(struct net_device *dev,
 	    (channel->rx_count || channel->tx_count))
 		return -EINVAL;
 
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp) && (channel->rx_count ||
+					    channel->tx_count))
+		return -EINVAL;
+
 	if (channel->combined_count)
 		sh = true;
 
-- 
1.8.3.1
