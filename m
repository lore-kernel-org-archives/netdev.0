From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 01/11] bnxt_en: Add function for VF driver to query default VLAN.
Date: Mon, 13 Jun 2016 02:25:28 -0400
Message-ID: <1465799138-27529-2-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35616 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964807AbcFMGZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:53 -0400
Received: by mail-pa0-f41.google.com with SMTP id hl6so42688329pac.2
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:53 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PF can setup a default VLAN for a VF.  The default VLAN tag is
automatically inserted and stripped without the knowledge of the
stack running on the VF.  The VF driver needs to know that default
VLAN is enabled as VLAN acceleration on the RX side is no longer
supported.  Call netdev_update_features() to fix up the VLAN features
as necessary.  Also, VLAN strip mode must be enabled to strip out
the default VLAN tag.

Only allow VF default VLAN to be set if the firmware spec is >= 1.2.1.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 47 +++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c |  3 ++
 2 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c777cde..67608d5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3277,6 +3277,7 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 	unsigned int ring = 0, grp_idx;
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[vnic_id];
 	struct hwrm_vnic_cfg_input req = {0};
+	u16 def_vlan = 0;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_CFG, -1, -1);
 	/* Only RSS support for now TBD: COS & LB */
@@ -3297,7 +3298,11 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 	req.mru = cpu_to_le16(bp->dev->mtu + ETH_HLEN + ETH_FCS_LEN +
 			      VLAN_HLEN);
 
-	if (bp->flags & BNXT_FLAG_STRIP_VLAN)
+#ifdef CONFIG_BNXT_SRIOV
+	if (BNXT_VF(bp))
+		def_vlan = bp->vf.vlan;
+#endif
+	if ((bp->flags & BNXT_FLAG_STRIP_VLAN) || def_vlan)
 		req.flags |= cpu_to_le32(VNIC_CFG_REQ_FLAGS_VLAN_STRIP_MODE);
 
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
@@ -3836,6 +3841,32 @@ static int bnxt_hwrm_stat_ctx_alloc(struct bnxt *bp)
 	return 0;
 }
 
+static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
+{
+	struct hwrm_func_qcfg_input req = {0};
+	int rc;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_QCFG, -1, -1);
+	req.fid = cpu_to_le16(0xffff);
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc)
+		goto func_qcfg_exit;
+
+#ifdef CONFIG_BNXT_SRIOV
+	if (BNXT_VF(bp)) {
+		struct hwrm_func_qcfg_output *resp = bp->hwrm_cmd_resp_addr;
+		struct bnxt_vf_info *vf = &bp->vf;
+
+		vf->vlan = le16_to_cpu(resp->vlan) & VLAN_VID_MASK;
+	}
+#endif
+
+func_qcfg_exit:
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
 int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 {
 	int rc = 0;
@@ -4230,6 +4261,11 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 		netdev_warn(bp->dev, "HWRM set coalescing failure rc: %x\n",
 			    rc);
 
+	if (BNXT_VF(bp)) {
+		bnxt_hwrm_func_qcfg(bp);
+		netdev_update_features(bp->dev);
+	}
+
 	return 0;
 
 err_out:
@@ -5469,7 +5505,14 @@ static netdev_features_t bnxt_fix_features(struct net_device *dev,
 			features |= NETIF_F_HW_VLAN_CTAG_RX |
 				    NETIF_F_HW_VLAN_STAG_RX;
 	}
-
+#ifdef CONFIG_BNXT_SRIOV
+	if (BNXT_VF(bp)) {
+		if (bp->vf.vlan) {
+			features &= ~(NETIF_F_HW_VLAN_CTAG_RX |
+				      NETIF_F_HW_VLAN_STAG_RX);
+		}
+	}
+#endif
 	return features;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 363884d..50d2007 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -143,6 +143,9 @@ int bnxt_set_vf_vlan(struct net_device *dev, int vf_id, u16 vlan_id, u8 qos)
 	u16 vlan_tag;
 	int rc;
 
+	if (bp->hwrm_spec_code < 0x10201)
+		return -ENOTSUPP;
+
 	rc = bnxt_vf_ndo_prep(bp, vf_id);
 	if (rc)
 		return rc;
-- 
1.8.3.1
