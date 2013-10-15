From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/9] bnx2x: Prevent an illegal pointer dereference
 during panic
Date: Tue, 15 Oct 2013 16:28:48 +0200
Message-ID: <1381847335-32662-3-git-send-email-yuvalmin@broadcom.com>
References: <1381847335-32662-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4414 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759113Ab3JOO3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 10:29:06 -0400
In-Reply-To: <1381847335-32662-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

During a panic, the driver tries to print the Management FW buffer of recent
commands. To do so, the driver reads the address of that buffer from a known
address. If the buffer is unavailable (e.g., PCI reads don't work, MCP is
failing, etc.), the driver will try to access the address it has read, possibly
causing a kernel panic.

This check 'sanitizes' the access, validating the read value is indeed a valid
address inside the management FW's buffers.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 19 ++++++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 97b3d32..d21742c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2498,4 +2498,8 @@ enum bnx2x_pci_bus_speed {
 };
 
 void bnx2x_set_local_cmng(struct bnx2x *bp);
+
+#define MCPR_SCRATCH_BASE(bp) \
+	(CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
+
 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 60f9e68..3fd76b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -775,6 +775,15 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 		trace_shmem_base = bp->common.shmem_base;
 	else
 		trace_shmem_base = SHMEM2_RD(bp, other_shmem_base_addr);
+
+	/* sanity */
+	if (trace_shmem_base < MCPR_SCRATCH_BASE(bp) ||
+	    trace_shmem_base > MCPR_SCRATCH_BASE(bp) + 0x28000) {
+		BNX2X_ERR("Unable to dump trace buffer (mark %x)\n",
+			  trace_shmem_base);
+		return;
+	}
+
 	addr = trace_shmem_base - 0x800;
 
 	/* validate TRCB signature */
@@ -787,8 +796,7 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 	/* read cyclic buffer pointer */
 	addr += 4;
 	mark = REG_RD(bp, addr);
-	mark = (CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
-			+ ((mark + 0x3) & ~0x3) - 0x08000000;
+	mark = MCPR_SCRATCH_BASE(bp) + ((mark + 0x3) & ~0x3) - 0x08000000;
 	printk("%s" "begin fw dump (mark 0x%x)\n", lvl, mark);
 
 	printk("%s", lvl);
@@ -11685,9 +11693,6 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 static int bnx2x_open(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	bool global = false;
-	int other_engine = BP_PATH(bp) ? 0 : 1;
-	bool other_load_status, load_status;
 	int rc;
 
 	bp->stats_init = true;
@@ -11703,6 +11708,10 @@ static int bnx2x_open(struct net_device *dev)
 	 * Parity recovery is only relevant for PF driver.
 	 */
 	if (IS_PF(bp)) {
+		int other_engine = BP_PATH(bp) ? 0 : 1;
+		bool other_load_status, load_status;
+		bool global = false;
+
 		other_load_status = bnx2x_get_load_status(bp, other_engine);
 		load_status = bnx2x_get_load_status(bp, BP_PATH(bp));
 		if (!bnx2x_reset_is_done(bp, BP_PATH(bp)) ||
-- 
1.8.1.227.g44fe835
