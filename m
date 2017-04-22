From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 5/5] bnxt_en: Restrict a PF in Multi-Host mode from changing port PHY configuration
Date: Fri, 21 Apr 2017 20:11:26 -0400
Message-ID: <1492819886-19625-6-git-send-email-michael.chan@broadcom.com>
References: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38680 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426554AbdDVALq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 20:11:46 -0400
Received: by mail-wm0-f42.google.com with SMTP id r190so28282096wme.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 17:11:45 -0700 (PDT)
In-Reply-To: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Khungar <deepak.khungar@broadcom.com>

This change restricts the PF in multi-host mode from setting any port
level PHY configuration.  The settings are controlled by firmware in
Multi-Host mode.

Signed-off-by: Deepak Khungar <deepak.khungar@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 13 +++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  4 +++-
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9130628..b3ba660 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4482,10 +4482,15 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 		vf->vlan = le16_to_cpu(resp->vlan) & VLAN_VID_MASK;
 	}
 #endif
-	if (BNXT_PF(bp) && (le16_to_cpu(resp->flags) &
-			    (FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED |
-			     FUNC_QCFG_RESP_FLAGS_FW_LLDP_AGENT_ENABLED)))
-		bp->flags |= BNXT_FLAG_FW_LLDP_AGENT;
+	if (BNXT_PF(bp)) {
+		u16 flags = le16_to_cpu(resp->flags);
+
+		if (flags & (FUNC_QCFG_RESP_FLAGS_FW_DCBX_AGENT_ENABLED |
+			     FUNC_QCFG_RESP_FLAGS_FW_LLDP_AGENT_ENABLED))
+			bp->flags |= BNXT_FLAG_FW_LLDP_AGENT;
+		if (flags & FUNC_QCFG_RESP_FLAGS_MULTI_HOST)
+			bp->flags |= BNXT_FLAG_MULTI_HOST;
+	}
 
 	switch (resp->port_partition_type) {
 	case FUNC_QCFG_RESP_PORT_PARTITION_TYPE_NPAR1_0:
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 25fef61..3ef42db 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1005,6 +1005,7 @@ struct bnxt {
 	#define BNXT_FLAG_NO_AGG_RINGS	0x20000
 	#define BNXT_FLAG_RX_PAGE_MODE	0x40000
 	#define BNXT_FLAG_FW_LLDP_AGENT	0x80000
+	#define BNXT_FLAG_MULTI_HOST	0x100000
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
@@ -1014,7 +1015,8 @@ struct bnxt {
 #define BNXT_PF(bp)		(!((bp)->flags & BNXT_FLAG_VF))
 #define BNXT_VF(bp)		((bp)->flags & BNXT_FLAG_VF)
 #define BNXT_NPAR(bp)		((bp)->port_partition_type)
-#define BNXT_SINGLE_PF(bp)	(BNXT_PF(bp) && !BNXT_NPAR(bp))
+#define BNXT_MH(bp)		((bp)->flags & BNXT_FLAG_MULTI_HOST)
+#define BNXT_SINGLE_PF(bp)	(BNXT_PF(bp) && !BNXT_NPAR(bp) && !BNXT_MH(bp))
 #define BNXT_CHIP_TYPE_NITRO_A0(bp) ((bp)->flags & BNXT_FLAG_CHIP_NITRO_A0)
 #define BNXT_RX_PAGE_MODE(bp)	((bp)->flags & BNXT_FLAG_RX_PAGE_MODE)
 
-- 
1.8.3.1
