From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 1/9] bnx2x: Activate LFA
Date: Tue, 27 Nov 2012 15:46:28 +0200
Message-ID: <1354023996-3512-2-git-send-email-yanivr@broadcom.com>
References: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1906 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676Ab2K0LrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 06:47:17 -0500
In-Reply-To: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case Link Flap Avoidance feature is supported by the MCP, bnx2x will enable
it, and will pass the appropriate parameter when load request is sent to
the MCP.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |    8 ++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   12 ++++++++++++
 3 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 54d522d..2d30979 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2248,7 +2248,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			 DRV_PULSE_SEQ_MASK);
 		BNX2X_DEV_INFO("drv_pulse 0x%x\n", bp->fw_drv_pulse_wr_seq);
 
-		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, 0);
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ,
+					     DRV_MSG_CODE_LOAD_REQ_WITH_LFA);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EBUSY;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 7eaa74b..f478bed 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2159,6 +2159,14 @@ struct shmem2_region {
 	#define SHMEM_EEE_TIME_OUTPUT_BIT	   0x80000000
 
 	u32 sizeof_port_stats;
+
+	/* Link Flap Avoidance */
+	u32 lfa_host_addr[PORT_MAX];
+	u32 reserved1;
+
+	u32 reserved2;				/* Offset 0x148 */
+	u32 reserved3;				/* Offset 0x14C */
+	u32 reserved4;				/* Offset 0x150 */
 };
 
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 3519fed..6d125c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6267,6 +6267,10 @@ void bnx2x_pf_disable(struct bnx2x *bp)
 static void bnx2x__common_init_phy(struct bnx2x *bp)
 {
 	u32 shmem_base[2], shmem2_base[2];
+	/* Avoid common init in case MFW supports LFA */
+	if (SHMEM2_RD(bp, size) >
+	    (u32)offsetof(struct shmem2_region, lfa_host_addr[BP_PORT(bp)]))
+		return;
 	shmem_base[0] =  bp->common.shmem_base;
 	shmem2_base[0] = bp->common.shmem2_base;
 	if (!CHIP_IS_E1x(bp)) {
@@ -9859,6 +9863,14 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 
 	bp->link_params.shmem_base = bp->common.shmem_base;
 	bp->link_params.shmem2_base = bp->common.shmem2_base;
+	if (SHMEM2_RD(bp, size) >
+	    (u32)offsetof(struct shmem2_region, lfa_host_addr[BP_PORT(bp)]))
+		bp->link_params.lfa_base =
+		REG_RD(bp, bp->common.shmem2_base +
+		       (u32)offsetof(struct shmem2_region,
+				     lfa_host_addr[BP_PORT(bp)]));
+	else
+		bp->link_params.lfa_base = 0;
 	BNX2X_DEV_INFO("shmem offset 0x%x  shmem2 offset 0x%x\n",
 		       bp->common.shmem_base, bp->common.shmem2_base);
 
-- 
1.7.1
