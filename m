From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/4] bnxt_en: Check if firmware LLDP agent is running.
Date: Wed,  8 Mar 2017 18:44:34 -0500
Message-ID: <1489016675-16097-4-git-send-email-michael.chan@broadcom.com>
References: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:36311 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753913AbdCHXqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 18:46:03 -0500
Received: by mail-wr0-f175.google.com with SMTP id u108so34040464wrb.3
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 15:44:53 -0800 (PST)
In-Reply-To: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set DCB_CAP_DCBX_HOST capability flag only if the firmware LLDP agent
is not running.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 4 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     | 1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c | 2 +-
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index bbe9371..869d4c9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4465,6 +4465,10 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 		vf->vlan = le16_to_cpu(resp->vlan) & VLAN_VID_MASK;
 	}
 #endif
+	if (BNXT_PF(bp) && (le16_to_cpu(resp->flags) &
+			    FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED))
+		bp->flags |= BNXT_FLAG_FW_LLDP_AGENT;
+
 	switch (resp->port_partition_type) {
 	case FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_0:
 	case FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_5:
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index faf26a2..c7a5b84 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -993,6 +993,7 @@ struct bnxt {
 					 BNXT_FLAG_ROCEV2_CAP)
 	#define BNXT_FLAG_NO_AGG_RINGS	0x20000
 	#define BNXT_FLAG_RX_PAGE_MODE	0x40000
+	#define BNXT_FLAG_FW_LLDP_AGENT	0x80000
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
index fdf2d8c..03532061 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
@@ -474,7 +474,7 @@ void bnxt_dcb_init(struct bnxt *bp)
 		return;
 
 	bp->dcbx_cap = DCB_CAP_DCBX_VER_IEEE;
-	if (BNXT_PF(bp))
+	if (BNXT_PF(bp) && !(bp->flags & BNXT_FLAG_FW_LLDP_AGENT))
 		bp->dcbx_cap |= DCB_CAP_DCBX_HOST;
 	else
 		bp->dcbx_cap |= DCB_CAP_DCBX_LLD_MANAGED;
-- 
1.8.3.1
