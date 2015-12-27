From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 10/12] bnxt_en: Keep track of the ring group resource.
Date: Sun, 27 Dec 2015 18:19:27 -0500
Message-ID: <1451258369-21543-11-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:39628 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826AbbL0XTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:33 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer firmware will return the ring group resource when we call
hwrm_func_qcaps().  To be compatible with older firmware, use the
number of tx rings as the number of ring groups if the older firmware
returns 0.  When determining how many rx rings we can support, take
the ring group resource in account as well in _bnxt_get_max_rings().
Divide and assign the ring groups to VFs.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 11 ++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |  2 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  7 ++++++-
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 22c2644..5737e0d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3617,6 +3617,9 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		pf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
 		pf->max_tx_rings = le16_to_cpu(resp->max_tx_rings);
 		pf->max_rx_rings = le16_to_cpu(resp->max_rx_rings);
+		pf->max_hw_ring_grps = le32_to_cpu(resp->max_hw_ring_grps);
+		if (!pf->max_hw_ring_grps)
+			pf->max_hw_ring_grps = pf->max_tx_rings;
 		pf->max_l2_ctxs = le16_to_cpu(resp->max_l2_ctxs);
 		pf->max_vnics = le16_to_cpu(resp->max_vnics);
 		pf->max_stat_ctxs = le16_to_cpu(resp->max_stat_ctx);
@@ -3644,6 +3647,9 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		vf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
 		vf->max_tx_rings = le16_to_cpu(resp->max_tx_rings);
 		vf->max_rx_rings = le16_to_cpu(resp->max_rx_rings);
+		vf->max_hw_ring_grps = le32_to_cpu(resp->max_hw_ring_grps);
+		if (!vf->max_hw_ring_grps)
+			vf->max_hw_ring_grps = vf->max_tx_rings;
 		vf->max_l2_ctxs = le16_to_cpu(resp->max_l2_ctxs);
 		vf->max_vnics = le16_to_cpu(resp->max_vnics);
 		vf->max_stat_ctxs = le16_to_cpu(resp->max_stat_ctx);
@@ -5618,25 +5624,28 @@ static int bnxt_get_max_irq(struct pci_dev *pdev)
 
 void bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx)
 {
-	int max_rings = 0;
+	int max_rings = 0, max_ring_grps = 0;
 
 	if (BNXT_PF(bp)) {
 		*max_tx = bp->pf.max_tx_rings;
 		*max_rx = bp->pf.max_rx_rings;
 		max_rings = min_t(int, bp->pf.max_irqs, bp->pf.max_cp_rings);
 		max_rings = min_t(int, max_rings, bp->pf.max_stat_ctxs);
+		max_ring_grps = bp->pf.max_hw_ring_grps;
 	} else {
 #ifdef CONFIG_BNXT_SRIOV
 		*max_tx = bp->vf.max_tx_rings;
 		*max_rx = bp->vf.max_rx_rings;
 		max_rings = min_t(int, bp->vf.max_irqs, bp->vf.max_cp_rings);
 		max_rings = min_t(int, max_rings, bp->vf.max_stat_ctxs);
+		max_ring_grps = bp->vf.max_hw_ring_grps;
 #endif
 	}
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
 		*max_rx >>= 1;
 
 	*max_rx = min_t(int, *max_rx, max_rings);
+	*max_rx = min_t(int, *max_rx, max_ring_grps);
 	*max_tx = min_t(int, *max_tx, max_rings);
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 8abaece..8241437 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -695,6 +695,7 @@ struct bnxt_vf_info {
 	u16	max_cp_rings;
 	u16	max_tx_rings;
 	u16	max_rx_rings;
+	u16	max_hw_ring_grps;
 	u16	max_l2_ctxs;
 	u16	max_irqs;
 	u16	max_vnics;
@@ -723,6 +724,7 @@ struct bnxt_pf_info {
 	u16	max_cp_rings;
 	u16	max_tx_rings; /* HW assigned max tx rings for this PF */
 	u16	max_rx_rings; /* HW assigned max rx rings for this PF */
+	u16	max_hw_ring_grps;
 	u16	max_irqs;
 	u16	max_l2_ctxs;
 	u16	max_vnics;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 44673e6..79b48e4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -367,6 +367,7 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 {
 	u32 rc = 0, mtu, i;
 	u16 vf_tx_rings, vf_rx_rings, vf_cp_rings, vf_stat_ctx, vf_vnics;
+	u16 vf_ring_grps;
 	struct hwrm_func_cfg_input req = {0};
 	struct bnxt_pf_info *pf = &bp->pf;
 
@@ -388,6 +389,7 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 			      num_vfs;
 	else
 		vf_rx_rings = (pf->max_rx_rings - bp->rx_nr_rings) / num_vfs;
+	vf_ring_grps = (bp->pf.max_hw_ring_grps - bp->rx_nr_rings) / num_vfs;
 	vf_tx_rings = (pf->max_tx_rings - bp->tx_nr_rings) / num_vfs;
 
 	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_MTU |
@@ -398,7 +400,8 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 				  FUNC_CFG_REQ_ENABLES_NUM_TX_RINGS |
 				  FUNC_CFG_REQ_ENABLES_NUM_RX_RINGS |
 				  FUNC_CFG_REQ_ENABLES_NUM_L2_CTXS |
-				  FUNC_CFG_REQ_ENABLES_NUM_VNICS);
+				  FUNC_CFG_REQ_ENABLES_NUM_VNICS |
+				  FUNC_CFG_REQ_ENABLES_NUM_HW_RING_GRPS);
 
 	mtu = bp->dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	req.mru = cpu_to_le16(mtu);
@@ -408,6 +411,7 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 	req.num_cmpl_rings = cpu_to_le16(vf_cp_rings);
 	req.num_tx_rings = cpu_to_le16(vf_tx_rings);
 	req.num_rx_rings = cpu_to_le16(vf_rx_rings);
+	req.num_hw_ring_grps = cpu_to_le16(vf_ring_grps);
 	req.num_l2_ctxs = cpu_to_le16(4);
 	vf_vnics = 1;
 
@@ -429,6 +433,7 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 	if (!rc) {
 		pf->max_tx_rings -= vf_tx_rings * num_vfs;
 		pf->max_rx_rings -= vf_rx_rings * num_vfs;
+		pf->max_hw_ring_grps -= vf_ring_grps * num_vfs;
 		pf->max_cp_rings -= vf_cp_rings * num_vfs;
 		pf->max_rsscos_ctxs -= num_vfs;
 		pf->max_stat_ctxs -= vf_stat_ctx * num_vfs;
-- 
1.8.3.1
