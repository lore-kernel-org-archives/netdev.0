From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 4/4] bnx2x: allow device properly initialize
 after hotplug
Date: Sun, 22 May 2011 23:11:26 +0300
Message-ID: <1306095086.9376.7.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3618 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468Ab1EVUQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 16:16:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   67 ++++++++++++++-------------------------
 1 files changed, 24 insertions(+), 43 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 58e30a2..8bfd857 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -7450,51 +7450,35 @@ static inline void bnx2x_mcp_wait_one(struct bnx2x *bp)
 		msleep(MCP_ONE_TIMEOUT);
 }
 
-static int bnx2x_reset_mcp_comp(struct bnx2x *bp, u32 magic_val)
+/*
+ * initializes bp->common.shmem_base and waits for validity signature to appear
+ */
+static int bnx2x_init_shmem(struct bnx2x *bp)
 {
-	u32 shmem, cnt, validity_offset, val;
-	int rc = 0;
-
-	msleep(100);
+	int cnt = 0;
+	u32 val = 0;
 
-	/* Get shmem offset */
-	shmem = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
-	if (shmem == 0) {
-		BNX2X_ERR("Shmem 0 return failure\n");
-		rc = -ENOTTY;
-		goto exit_lbl;
-	}
+	do {
+		bp->common.shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
+		if (bp->common.shmem_base) {
+			val = SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
+			if (val & SHR_MEM_VALIDITY_MB)
+				return 0;
+		}
 
-	validity_offset = offsetof(struct shmem_region, validity_map[0]);
+		bnx2x_mcp_wait_one(bp);
 
-	/* Wait for MCP to come up */
-	for (cnt = 0; cnt < (MCP_TIMEOUT / MCP_ONE_TIMEOUT); cnt++) {
-		/* TBD: its best to check validity map of last port.
-		 * currently checks on port 0.
-		 */
-		val = REG_RD(bp, shmem + validity_offset);
-		DP(NETIF_MSG_HW, "shmem 0x%x validity map(0x%x)=0x%x\n", shmem,
-		   shmem + validity_offset, val);
+	} while (cnt++ < (MCP_TIMEOUT / MCP_ONE_TIMEOUT));
 
-		/* check that shared memory is valid. */
-		if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		    == (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-			break;
+	BNX2X_ERR("BAD MCP validity signature\n");
 
-		bnx2x_mcp_wait_one(bp);
-	}
-
-	DP(NETIF_MSG_HW, "Cnt=%d Shmem validity map 0x%x\n", cnt, val);
+	return -ENODEV;
+}
 
-	/* Check that shared memory is valid. This indicates that MCP is up. */
-	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB)) !=
-	    (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB)) {
-		BNX2X_ERR("Shmem signature not present. MCP is not up !!\n");
-		rc = -ENOTTY;
-		goto exit_lbl;
-	}
+static int bnx2x_reset_mcp_comp(struct bnx2x *bp, u32 magic_val)
+{
+	int rc = bnx2x_init_shmem(bp);
 
-exit_lbl:
 	/* Restore the `magic' bit value */
 	if (!CHIP_IS_E1(bp))
 		bnx2x_clp_reset_done(bp, magic_val);
@@ -8007,10 +7991,12 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	BNX2X_DEV_INFO("flash_size 0x%x (%d)\n",
 		       bp->common.flash_size, bp->common.flash_size);
 
-	bp->common.shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
+	bnx2x_init_shmem(bp);
+
 	bp->common.shmem2_base = REG_RD(bp, (BP_PATH(bp) ?
 					MISC_REG_GENERIC_CR_1 :
 					MISC_REG_GENERIC_CR_0));
+
 	bp->link_params.shmem_base = bp->common.shmem_base;
 	bp->link_params.shmem2_base = bp->common.shmem2_base;
 	BNX2X_DEV_INFO("shmem offset 0x%x  shmem2 offset 0x%x\n",
@@ -8022,11 +8008,6 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		return;
 	}
 
-	val = SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
-	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		BNX2X_ERR("BAD MCP validity signature\n");
-
 	bp->common.hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
 	BNX2X_DEV_INFO("hw_config 0x%08x\n", bp->common.hw_config);
 
-- 
1.7.2.2




