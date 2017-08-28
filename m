From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/11] bnxt_en: Improve tx ring reservation logic.
Date: Mon, 28 Aug 2017 13:40:26 -0400
Message-ID: <1503942035-24924-3-git-send-email-michael.chan@broadcom.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35561 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdH1Rkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:51 -0400
Received: by mail-qk0-f182.google.com with SMTP id p67so5392197qkd.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:40:51 -0700 (PDT)
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the number of TX rings is changed (e.g. ethtool -L, enabling XDP TX
rings, etc), the current code tries to reserve the new number of TX rings
before closing and re-opening the NIC.  If we are unable to reserve the
new TX rings, we abort the operation and keep the current TX rings.

The problem is that the firmware will disable the current TX rings even
when it cannot reserve the new set of TX rings.  We fix it as follows:

1. Instead of reserving the new set of TX rings, just ask the firmware
to check if the new set of TX rings is available.  There is a flag in
the firmware message to do that.  If not available, abort and the
current TX rings will not be disabled.

2. Do the actual TX ring reservation in the path that opens the NIC.
We keep the number of TX rings currently successfully reserved.  If the
number of TX rings is different than the reserved TX rings, we call
firmware and reserve again.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 46 +++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  5 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  3 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     |  4 +-
 4 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6e14fc4..4b0a807 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4461,9 +4461,33 @@ static int bnxt_hwrm_reserve_tx_rings(struct bnxt *bp, int *tx_rings)
 	mutex_lock(&bp->hwrm_cmd_lock);
 	rc = __bnxt_hwrm_get_tx_rings(bp, 0xffff, tx_rings);
 	mutex_unlock(&bp->hwrm_cmd_lock);
+	if (!rc)
+		bp->tx_reserved_rings = *tx_rings;
 	return rc;
 }
 
+static int bnxt_hwrm_check_tx_rings(struct bnxt *bp, int tx_rings)
+{
+	struct hwrm_func_cfg_input req = {0};
+	int rc;
+
+	if (bp->hwrm_spec_code < 0x10801)
+		return 0;
+
+	if (BNXT_VF(bp))
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
+	req.fid = cpu_to_le16(0xffff);
+	req.flags = cpu_to_le32(FUNC_CFG_REQ_FLAGS_TX_ASSETS_TEST);
+	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_NUM_TX_RINGS);
+	req.num_tx_rings = cpu_to_le16(tx_rings);
+	rc = hwrm_send_message_silent(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc)
+		return -ENOMEM;
+	return 0;
+}
+
 static void bnxt_hwrm_set_coal_params(struct bnxt *bp, u32 max_bufs,
 	u32 buf_tmrs, u16 flags,
 	struct hwrm_ring_cmpl_ring_cfg_aggint_params_input *req)
@@ -5115,6 +5139,15 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 				   rc);
 			goto err_out;
 		}
+		if (bp->tx_reserved_rings != bp->tx_nr_rings) {
+			int tx = bp->tx_nr_rings;
+
+			if (bnxt_hwrm_reserve_tx_rings(bp, &tx) ||
+			    tx < bp->tx_nr_rings) {
+				rc = -ENOMEM;
+				goto err_out;
+			}
+		}
 	}
 
 	rc = bnxt_hwrm_ring_alloc(bp);
@@ -6998,8 +7031,8 @@ static void bnxt_sp_task(struct work_struct *work)
 }
 
 /* Under rtnl_lock */
-int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
-		       int tx_xdp)
+int bnxt_check_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
+		     int tx_xdp)
 {
 	int max_rx, max_tx, tx_sets = 1;
 	int tx_rings_needed;
@@ -7019,10 +7052,7 @@ int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
 	if (max_tx < tx_rings_needed)
 		return -ENOMEM;
 
-	if (bnxt_hwrm_reserve_tx_rings(bp, &tx_rings_needed) ||
-	    tx_rings_needed < (tx * tx_sets + tx_xdp))
-		return -ENOMEM;
-	return 0;
+	return bnxt_hwrm_check_tx_rings(bp, tx_rings_needed);
 }
 
 static void bnxt_unmap_bars(struct bnxt *bp, struct pci_dev *pdev)
@@ -7211,8 +7241,8 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 	if (bp->flags & BNXT_FLAG_SHARED_RINGS)
 		sh = true;
 
-	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
-				sh, tc, bp->tx_nr_rings_xdp);
+	rc = bnxt_check_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
+			      sh, tc, bp->tx_nr_rings_xdp);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 2d84d57..568516f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1118,6 +1118,7 @@ struct bnxt {
 	int			tx_nr_rings;
 	int			tx_nr_rings_per_tc;
 	int			tx_nr_rings_xdp;
+	int			tx_reserved_rings;
 
 	int			tx_wake_thresh;
 	int			tx_push_thresh;
@@ -1346,8 +1347,8 @@ int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
 int bnxt_half_open_nic(struct bnxt *bp);
 void bnxt_half_close_nic(struct bnxt *bp);
 int bnxt_close_nic(struct bnxt *, bool, bool);
-int bnxt_reserve_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
-		       int tx_xdp);
+int bnxt_check_rings(struct bnxt *bp, int tx, int rx, bool sh, int tcs,
+		     int tx_xdp);
 int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
 void bnxt_restore_pf_fw_resources(struct bnxt *bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 08b870d..8eff05a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -435,8 +435,7 @@ static int bnxt_set_channels(struct net_device *dev,
 		}
 		tx_xdp = req_rx_rings;
 	}
-	rc = bnxt_reserve_rings(bp, req_tx_rings, req_rx_rings, sh, tcs,
-				tx_xdp);
+	rc = bnxt_check_rings(bp, req_tx_rings, req_rx_rings, sh, tcs, tx_xdp);
 	if (rc) {
 		netdev_warn(dev, "Unable to allocate the requested rings\n");
 		return rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 3961a68..d8f0c83 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -169,8 +169,8 @@ static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
 	tc = netdev_get_num_tc(dev);
 	if (!tc)
 		tc = 1;
-	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
-				true, tc, tx_xdp);
+	rc = bnxt_check_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
+			      true, tc, tx_xdp);
 	if (rc) {
 		netdev_warn(dev, "Unable to reserve enough TX rings to support XDP.\n");
 		return rc;
-- 
1.8.3.1
