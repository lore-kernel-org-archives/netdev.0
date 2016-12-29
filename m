From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 11/14] bnxt_en: Implement new scheme to reserve tx rings.
Date: Thu, 29 Dec 2016 12:13:41 -0500
Message-ID: <1483031624-20076-12-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35361 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752865AbcL2ROK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:10 -0500
Received: by mail-pf0-f177.google.com with SMTP id i88so63034355pfk.2
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:09 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to properly support TX rate limiting in SRIOV VF functions or
NPAR functions, firmware needs better control over tx ring allocations.
The new scheme requires the driver to reserve the number of tx rings
and to query to see if the requested number of tx rings is reserved.
The driver will use the new scheme when the firmware interface spec is
1.6.1 or newer.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 59 ++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  2 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 15 ++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   | 10 +++-
 4 files changed, 83 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4d478e7..338dbd0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4045,6 +4045,50 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 	}
 }
 
+/* Caller must hold bp->hwrm_cmd_lock */
+int __bnxt_hwrm_get_tx_rings(struct bnxt *bp, u16 fid, int *tx_rings)
+{
+	struct hwrm_func_qcfg_output *resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_func_qcfg_input req = {0};
+	int rc;
+
+	if (bp->hwrm_spec_code < 0x10601)
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_QCFG, -1, -1);
+	req.fid = cpu_to_le16(fid);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (!rc)
+		*tx_rings = le16_to_cpu(resp->alloc_tx_rings);
+
+	return rc;
+}
+
+int bnxt_hwrm_reserve_tx_rings(struct bnxt *bp, int *tx_rings)
+{
+	struct hwrm_func_cfg_input req = {0};
+	int rc;
+
+	if (bp->hwrm_spec_code < 0x10601)
+		return 0;
+
+	if (BNXT_VF(bp))
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
+	req.fid = cpu_to_le16(0xffff);
+	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_NUM_TX_RINGS);
+	req.num_tx_rings = cpu_to_le16(*tx_rings);
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc)
+		return rc;
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = __bnxt_hwrm_get_tx_rings(bp, 0xffff, tx_rings);
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
 static void bnxt_hwrm_set_coal_params(struct bnxt *bp, u32 max_bufs,
 	u32 buf_tmrs, u16 flags,
 	struct hwrm_ring_cmpl_ring_cfg_aggint_params_input *req)
@@ -6509,10 +6553,16 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 		sh = true;
 
 	if (tc) {
-		int max_rx_rings, max_tx_rings, rc;
+		int max_rx_rings, max_tx_rings, req_tx_rings, rsv_tx_rings, rc;
 
+		req_tx_rings = bp->tx_nr_rings_per_tc * tc;
 		rc = bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, sh);
-		if (rc || bp->tx_nr_rings_per_tc * tc > max_tx_rings)
+		if (rc || req_tx_rings > max_tx_rings)
+			return -ENOMEM;
+
+		rsv_tx_rings = req_tx_rings;
+		if (bnxt_hwrm_reserve_tx_rings(bp, &rsv_tx_rings) ||
+		    rsv_tx_rings < req_tx_rings)
 			return -ENOMEM;
 	}
 
@@ -7000,6 +7050,11 @@ static int bnxt_set_dflt_rings(struct bnxt *bp)
 		return rc;
 	bp->rx_nr_rings = min_t(int, dflt_rings, max_rx_rings);
 	bp->tx_nr_rings_per_tc = min_t(int, dflt_rings, max_tx_rings);
+
+	rc = bnxt_hwrm_reserve_tx_rings(bp, &bp->tx_nr_rings_per_tc);
+	if (rc)
+		netdev_warn(bp->dev, "Unable to reserve tx rings\n");
+
 	bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
 	bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
 			       bp->tx_nr_rings + bp->rx_nr_rings;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 75803e5..d174729d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1149,6 +1149,8 @@ struct bnxt {
 int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 				     int bmap_size);
 int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id);
+int __bnxt_hwrm_get_tx_rings(struct bnxt *bp, u16 fid, int *tx_rings);
+int bnxt_hwrm_reserve_tx_rings(struct bnxt *bp, int *tx_rings);
 int bnxt_hwrm_set_coal(struct bnxt *);
 unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp);
 void bnxt_set_max_func_stat_ctxs(struct bnxt *bp, unsigned int max);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index e6b1196..dd21be4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -388,6 +388,7 @@ static int bnxt_set_channels(struct net_device *dev,
 {
 	struct bnxt *bp = netdev_priv(dev);
 	int max_rx_rings, max_tx_rings, tcs;
+	int req_tx_rings, rsv_tx_rings;
 	u32 rc = 0;
 	bool sh = false;
 
@@ -423,6 +424,20 @@ static int bnxt_set_channels(struct net_device *dev,
 		    channel->tx_count > max_tx_rings))
 		return -ENOMEM;
 
+	req_tx_rings = sh ? channel->combined_count : channel->tx_count;
+	req_tx_rings = min_t(int, req_tx_rings, max_tx_rings);
+	if (tcs > 1)
+		req_tx_rings *= tcs;
+
+	rsv_tx_rings = req_tx_rings;
+	if (bnxt_hwrm_reserve_tx_rings(bp, &rsv_tx_rings))
+		return -ENOMEM;
+
+	if (rsv_tx_rings < req_tx_rings) {
+		netdev_warn(dev, "Unable to allocate the requested tx rings\n");
+		return -ENOMEM;
+	}
+
 	if (netif_running(dev)) {
 		if (BNXT_PF(bp)) {
 			/* TODO CHIMP_FW: Send message to all VF's
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 0c9f6c1..64ef0e5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -416,6 +416,7 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 	u16 vf_ring_grps;
 	struct hwrm_func_cfg_input req = {0};
 	struct bnxt_pf_info *pf = &bp->pf;
+	int total_vf_tx_rings = 0;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
 
@@ -460,6 +461,8 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 
 	mutex_lock(&bp->hwrm_cmd_lock);
 	for (i = 0; i < num_vfs; i++) {
+		int vf_tx_rsvd = vf_tx_rings;
+
 		req.fid = cpu_to_le16(pf->first_vf_id + i);
 		rc = _hwrm_send_message(bp, &req, sizeof(req),
 					HWRM_CMD_TIMEOUT);
@@ -467,10 +470,15 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 			break;
 		pf->active_vfs = i + 1;
 		pf->vf[i].fw_fid = le16_to_cpu(req.fid);
+		rc = __bnxt_hwrm_get_tx_rings(bp, pf->vf[i].fw_fid,
+					      &vf_tx_rsvd);
+		if (rc)
+			break;
+		total_vf_tx_rings += vf_tx_rsvd;
 	}
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	if (!rc) {
-		pf->max_tx_rings -= vf_tx_rings * num_vfs;
+		pf->max_tx_rings -= total_vf_tx_rings;
 		pf->max_rx_rings -= vf_rx_rings * num_vfs;
 		pf->max_hw_ring_grps -= vf_ring_grps * num_vfs;
 		pf->max_cp_rings -= vf_cp_rings * num_vfs;
-- 
1.8.3.1
