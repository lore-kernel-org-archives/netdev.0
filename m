From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next] bnxt_en: Fix compile errors when CONFIG_BNXT_SRIOV is not set.
Date: Fri, 23 Oct 2015 15:06:19 -0400
Message-ID: <1445627179-9971-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jim.hull@hpe.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:31812 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbbJWTGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 15:06:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct bnxt_pf_info needs to be always defined.  Move bnxt_update_vf_mac()
to bnxt_sriov.c and add some missing #ifdef CONFIG_BNXT_SRIOV.

Reported-by: Jim Hull <jim.hull@hpe.com>
Tested-by: Jim Hull <jim.hull@hpe.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 32 ++++++-------------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |  4 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 31 +++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h |  1 +
 4 files changed, 40 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 94b11a5..9e36f83 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3645,6 +3645,7 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		pf->max_rx_em_flows = le32_to_cpu(resp->max_rx_em_flows);
 		pf->max_rx_wm_flows = le32_to_cpu(resp->max_rx_wm_flows);
 	} else {
+#ifdef CONFIG_BNXT_SRIOV
 		struct bnxt_vf_info *vf = &bp->vf;
 
 		vf->fw_fid = le16_to_cpu(resp->fid);
@@ -3659,6 +3660,7 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		vf->max_l2_ctxs = le16_to_cpu(resp->max_l2_ctxs);
 		vf->max_vnics = le16_to_cpu(resp->max_vnics);
 		vf->max_stat_ctxs = le16_to_cpu(resp->max_stat_ctx);
+#endif
 	}
 
 	bp->tx_push_thresh = 0;
@@ -3880,30 +3882,6 @@ static int bnxt_alloc_rfs_vnics(struct bnxt *bp)
 #endif
 }
 
-static void bnxt_update_vf_mac(struct bnxt *bp)
-{
-	struct hwrm_func_qcaps_input req = {0};
-	struct hwrm_func_qcaps_output *resp = bp->hwrm_cmd_resp_addr;
-
-	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_QCAPS, -1, -1);
-	req.fid = cpu_to_le16(0xffff);
-
-	mutex_lock(&bp->hwrm_cmd_lock);
-	if (_hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT))
-		goto update_vf_mac_exit;
-
-	if (!is_valid_ether_addr(resp->perm_mac_address))
-		goto update_vf_mac_exit;
-
-	if (ether_addr_equal(resp->perm_mac_address, bp->vf.mac_addr))
-		goto update_vf_mac_exit;
-
-	memcpy(bp->vf.mac_addr, resp->perm_mac_address, ETH_ALEN);
-	memcpy(bp->dev->dev_addr, bp->vf.mac_addr, ETH_ALEN);
-update_vf_mac_exit:
-	mutex_unlock(&bp->hwrm_cmd_lock);
-}
-
 static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 {
 	int rc = 0;
@@ -5581,7 +5559,7 @@ static int bnxt_get_max_irq(struct pci_dev *pdev)
 
 void bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx)
 {
-	int max_rings;
+	int max_rings = 0;
 
 	if (BNXT_PF(bp)) {
 		*max_tx = bp->pf.max_pf_tx_rings;
@@ -5589,10 +5567,12 @@ void bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx)
 		max_rings = min_t(int, bp->pf.max_irqs, bp->pf.max_cp_rings);
 		max_rings = min_t(int, max_rings, bp->pf.max_stat_ctxs);
 	} else {
+#ifdef CONFIG_BNXT_SRIOV
 		*max_tx = bp->vf.max_tx_rings;
 		*max_rx = bp->vf.max_rx_rings;
 		max_rings = min_t(int, bp->vf.max_irqs, bp->vf.max_cp_rings);
 		max_rings = min_t(int, max_rings, bp->vf.max_stat_ctxs);
+#endif
 	}
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
 		*max_rx >>= 1;
@@ -5696,8 +5676,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		memcpy(dev->dev_addr, bp->pf.mac_addr, ETH_ALEN);
 		bp->pf.max_irqs = max_irqs;
 	} else {
+#if defined(CONFIG_BNXT_SRIOV)
 		memcpy(dev->dev_addr, bp->vf.mac_addr, ETH_ALEN);
 		bp->vf.max_irqs = max_irqs;
+#endif
 	}
 	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings);
 	bp->rx_nr_rings = min_t(int, dflt_rings, max_rx_rings);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 7c89367..5ee3cc2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -709,6 +709,7 @@ struct bnxt_vf_info {
 	void	*hwrm_cmd_req_addr;
 	dma_addr_t	hwrm_cmd_req_dma_addr;
 };
+#endif
 
 struct bnxt_pf_info {
 #define BNXT_FIRST_PF_FID	1
@@ -741,7 +742,6 @@ struct bnxt_pf_info {
 	dma_addr_t		hwrm_cmd_req_dma_addr[4];
 	struct bnxt_vf_info	*vf;
 };
-#endif
 
 struct bnxt_ntuple_filter {
 	struct hlist_node	hash;
@@ -960,9 +960,9 @@ struct bnxt {
 #define BNXT_RESET_TASK_SP_EVENT	32
 #define BNXT_RST_RING_SP_EVENT		64
 
+	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
 	int			nr_vfs;
-	struct bnxt_pf_info	pf;
 	struct bnxt_vf_info	vf;
 	wait_queue_head_t	sriov_cfg_wait;
 	bool			sriov_cfg;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 3422147..60989e7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -774,6 +774,31 @@ void bnxt_hwrm_exec_fwd_req(struct bnxt *bp)
 		i = vf_id + 1;
 	}
 }
+
+void bnxt_update_vf_mac(struct bnxt *bp)
+{
+	struct hwrm_func_qcaps_input req = {0};
+	struct hwrm_func_qcaps_output *resp = bp->hwrm_cmd_resp_addr;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_QCAPS, -1, -1);
+	req.fid = cpu_to_le16(0xffff);
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	if (_hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT))
+		goto update_vf_mac_exit;
+
+	if (!is_valid_ether_addr(resp->perm_mac_address))
+		goto update_vf_mac_exit;
+
+	if (ether_addr_equal(resp->perm_mac_address, bp->vf.mac_addr))
+		goto update_vf_mac_exit;
+
+	memcpy(bp->vf.mac_addr, resp->perm_mac_address, ETH_ALEN);
+	memcpy(bp->dev->dev_addr, bp->vf.mac_addr, ETH_ALEN);
+update_vf_mac_exit:
+	mutex_unlock(&bp->hwrm_cmd_lock);
+}
+
 #else
 
 void bnxt_sriov_disable(struct bnxt *bp)
@@ -782,6 +807,10 @@ void bnxt_sriov_disable(struct bnxt *bp)
 
 void bnxt_hwrm_exec_fwd_req(struct bnxt *bp)
 {
-	netdev_err(dev, "Invalid VF message received when SRIOV is not enable\n");
+	netdev_err(bp->dev, "Invalid VF message received when SRIOV is not enable\n");
+}
+
+void bnxt_update_vf_mac(struct bnxt *bp)
+{
 }
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
index 0b430f1..c151280 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h
@@ -19,4 +19,5 @@ int bnxt_set_vf_spoofchk(struct net_device *, int, bool);
 int bnxt_sriov_configure(struct pci_dev *pdev, int num_vfs);
 void bnxt_sriov_disable(struct bnxt *);
 void bnxt_hwrm_exec_fwd_req(struct bnxt *);
+void bnxt_update_vf_mac(struct bnxt *);
 #endif
-- 
1.8.3.1
