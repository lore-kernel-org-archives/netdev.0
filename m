From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/10] bnxt_en: Report firmware DCBX agent.
Date: Mon, 24 Jul 2017 12:34:25 -0400
Message-ID: <1500914069-15724-7-git-send-email-michael.chan@broadcom.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:35411 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753990AbdGXQev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:51 -0400
Received: by mail-qt0-f176.google.com with SMTP id p3so12521027qtg.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:50 -0700 (PDT)
In-Reply-To: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report DCB_CAP_DCBX_LLD_MANAGED only if the firmware DCBX agent is enabled
and running for PF or VF.  Otherwise, if both LLDP and DCBX agents are
disabled in firmware, we report DCB_CAP_DCBX_LLD_HOST and allow host
IEEE DCB settings.  This patch refines the current logic in the driver.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 19 ++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c | 11 ++++++++---
 3 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5df9670..95fea26 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4578,6 +4578,7 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 {
 	struct hwrm_func_qcfg_input req = {0};
 	struct hwrm_func_qcfg_output *resp = bp->hwrm_cmd_resp_addr;
+	u16 flags;
 	int rc;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_QCFG, -1, -1);
@@ -4594,15 +4595,15 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 		vf->vlan = le16_to_cpu(resp->vlan) & VLAN_VID_MASK;
 	}
 #endif
-	if (BNXT_PF(bp)) {
-		u16 flags = le16_to_cpu(resp->flags);
-
-		if (flags & (FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED |
-			     FUNC_QCFG_RESP_FLAGS_FW_LLDP_AGENT_ENABLED))
-			bp->flags |= BNXT_FLAG_FW_LLDP_AGENT;
-		if (flags & FUNC_QCFG_RESP_FLAGS_MULTI_HOST)
-			bp->flags |= BNXT_FLAG_MULTI_HOST;
-	}
+	flags = le16_to_cpu(resp->flags);
+	if (flags & (FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED |
+		     FUNC_QCFG_RESP_FLAGS_FW_LLDP_AGENT_ENABLED)) {
+		bp->flags |= BNXT_FLAG_FW_LLDP_AGENT;
+		if (flags & FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED)
+			bp->flags |= BNXT_FLAG_FW_DCBX_AGENT;
+	}
+	if (BNXT_PF(bp) && (flags & FUNC_QCFG_RESP_FLAGS_MULTI_HOST))
+		bp->flags |= BNXT_FLAG_MULTI_HOST;
 
 	switch (resp->port_partition_type) {
 	case FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_0:
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 15d5a10..6b781be 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1027,6 +1027,7 @@ struct bnxt {
 	#define BNXT_FLAG_MULTI_HOST	0x100000
 	#define BNXT_FLAG_SHORT_CMD	0x200000
 	#define BNXT_FLAG_DOUBLE_DB	0x400000
+	#define BNXT_FLAG_FW_DCBX_AGENT	0x800000
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
index 5c6dd0c..c014589 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
@@ -549,13 +549,18 @@ static u8 bnxt_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
-	/* only support IEEE */
-	if ((mode & DCB_CAP_DCBX_VER_CEE) || !(mode & DCB_CAP_DCBX_VER_IEEE))
+	/* All firmware DCBX settings are set in NVRAM */
+	if (bp->dcbx_cap & DCB_CAP_DCBX_LLD_MANAGED)
 		return 1;
 
 	if (mode & DCB_CAP_DCBX_HOST) {
 		if (BNXT_VF(bp) || (bp->flags & BNXT_FLAG_FW_LLDP_AGENT))
 			return 1;
+
+		/* only support IEEE */
+		if ((mode & DCB_CAP_DCBX_VER_CEE) ||
+		    !(mode & DCB_CAP_DCBX_VER_IEEE))
+			return 1;
 	}
 
 	if (mode == bp->dcbx_cap)
@@ -584,7 +589,7 @@ void bnxt_dcb_init(struct bnxt *bp)
 	bp->dcbx_cap = DCB_CAP_DCBX_VER_IEEE;
 	if (BNXT_PF(bp) && !(bp->flags & BNXT_FLAG_FW_LLDP_AGENT))
 		bp->dcbx_cap |= DCB_CAP_DCBX_HOST;
-	else
+	else if (bp->flags & BNXT_FLAG_FW_DCBX_AGENT)
 		bp->dcbx_cap |= DCB_CAP_DCBX_LLD_MANAGED;
 	bp->dev->dcbnl_ops = &dcbnl_ops;
 }
-- 
1.8.3.1
