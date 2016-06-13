From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/11] bnxt_en: Enable NPAR (NIC Partitioning) Support.
Date: Mon, 13 Jun 2016 02:25:31 -0400
Message-ID: <1465799138-27529-5-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34612 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964814AbcFMGZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:55 -0400
Received: by mail-pa0-f50.google.com with SMTP id bz2so42651107pad.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:55 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Baddipadige <sbaddipa@broadcom.com>

NPAR type is read from bnxt_hwrm_func_qcfg.  Do not allow changing link
parameters if in NPAR mode sinc ethe port is shared among multiple
partitions.  The link parameters are set up by firmware.

Signed-off-by: Satish Baddipadige <sbaddipa@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 13 +++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  3 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  6 +++---
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 51f9e38..9d785e6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3850,6 +3850,7 @@ static int bnxt_hwrm_stat_ctx_alloc(struct bnxt *bp)
 static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 {
 	struct hwrm_func_qcfg_input req = {0};
+	struct hwrm_func_qcfg_output *resp = bp->hwrm_cmd_resp_addr;
 	int rc;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_QCFG, -1, -1);
@@ -3861,12 +3862,18 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 
 #ifdef CONFIG_BNXT_SRIOV
 	if (BNXT_VF(bp)) {
-		struct hwrm_func_qcfg_output *resp = bp->hwrm_cmd_resp_addr;
 		struct bnxt_vf_info *vf = &bp->vf;
 
 		vf->vlan = le16_to_cpu(resp->vlan) & VLAN_VID_MASK;
 	}
 #endif
+	switch (resp->port_partition_type) {
+	case FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_0:
+	case FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_5:
+	case FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR2_0:
+		bp->port_partition_type = resp->port_partition_type;
+		break;
+	}
 
 func_qcfg_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
@@ -4965,7 +4972,7 @@ static int bnxt_hwrm_shutdown_link(struct bnxt *bp)
 {
 	struct hwrm_port_phy_cfg_input req = {0};
 
-	if (BNXT_VF(bp))
+	if (!BNXT_SINGLE_PF(bp))
 		return 0;
 
 	if (pci_num_vf(bp->pdev))
@@ -6427,6 +6434,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto init_err;
 	}
 
+	bnxt_hwrm_func_qcfg(bp);
+
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
 	if (BNXT_PF(bp))
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 538eb1c..ec18a07 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -907,6 +907,8 @@ struct bnxt {
 
 #define BNXT_PF(bp)		(!((bp)->flags & BNXT_FLAG_VF))
 #define BNXT_VF(bp)		((bp)->flags & BNXT_FLAG_VF)
+#define BNXT_NPAR(bp)		((bp)->port_partition_type)
+#define BNXT_SINGLE_PF(bp)	(BNXT_PF(bp) && !BNXT_NPAR(bp))
 
 	struct bnxt_napi	**bnapi;
 
@@ -993,6 +995,7 @@ struct bnxt {
 	__le16			vxlan_fw_dst_port_id;
 	u8			nge_port_cnt;
 	__le16			nge_fw_dst_port_id;
+	u8			port_partition_type;
 
 	u16			rx_coal_ticks;
 	u16			rx_coal_ticks_irq;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index a38cb04..89050ed 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -823,7 +823,7 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	u32 speed, fw_advertising = 0;
 	bool set_pause = false;
 
-	if (BNXT_VF(bp))
+	if (!BNXT_SINGLE_PF(bp))
 		return rc;
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
@@ -911,7 +911,7 @@ static int bnxt_set_pauseparam(struct net_device *dev,
 	struct bnxt *bp = netdev_priv(dev);
 	struct bnxt_link_info *link_info = &bp->link_info;
 
-	if (BNXT_VF(bp))
+	if (!BNXT_SINGLE_PF(bp))
 		return rc;
 
 	if (epause->autoneg) {
@@ -1433,7 +1433,7 @@ static int bnxt_set_eee(struct net_device *dev, struct ethtool_eee *edata)
 		 _bnxt_fw_to_ethtool_adv_spds(link_info->advertising, 0);
 	int rc = 0;
 
-	if (BNXT_VF(bp))
+	if (!BNXT_SINGLE_PF(bp))
 		return 0;
 
 	if (!(bp->flags & BNXT_FLAG_EEE_CAP))
-- 
1.8.3.1
