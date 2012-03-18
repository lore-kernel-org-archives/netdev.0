From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 9/9] bnx2x: validate FW trace prior to its printing
Date: Sun, 18 Mar 2012 16:33:45 -0400
Message-ID: <1332102825-7838-10-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4992 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740Ab2CRNsi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:38 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   12 +++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 0c5f121..5d71b7d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1129,6 +1129,8 @@ struct shm_dev_info {				/* size */
 
 #define FW_ACK_NUM_OF_POLL  (FW_ACK_TIME_OUT_MS/FW_ACK_POLL_TIME_MS)
 
+#define MFW_TRACE_SIGNATURE     0x54524342
+
 /****************************************************************************
  * Driver <-> FW Mailbox                                                    *
  ****************************************************************************/
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a3d5246..6879d01 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -719,7 +719,17 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 		trace_shmem_base = bp->common.shmem_base;
 	else
 		trace_shmem_base = SHMEM2_RD(bp, other_shmem_base_addr);
-	addr = trace_shmem_base - 0x0800 + 4;
+	addr = trace_shmem_base - 0x800;
+
+	/* validate TRCB signature */
+	mark = REG_RD(bp, addr);
+	if (mark != MFW_TRACE_SIGNATURE) {
+		BNX2X_ERR("Trace buffer signature is missing.");
+		return ;
+	}
+
+	/* read cyclic buffer pointer */
+	addr += 4;
 	mark = REG_RD(bp, addr);
 	mark = (CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
 			+ ((mark + 0x3) & ~0x3) - 0x08000000;
-- 
1.7.9.rc2
