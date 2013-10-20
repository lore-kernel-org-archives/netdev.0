From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 2/9] bnx2x: Prevent an illegal pointer
 dereference during panic
Date: Sun, 20 Oct 2013 16:51:27 +0200
Message-ID: <1382280694-8428-3-git-send-email-yuvalmin@broadcom.com>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2637 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797Ab3JTOvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:51:49 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a panic, the driver tries to print the Management FW buffer of recent
commands. To do so, the driver reads the address of that buffer from a known
address. If the buffer is unavailable (e.g., PCI reads don't work, MCP is
failing, etc.), the driver will try to access the address it has read, possibly
causing a kernel panic.

This check 'sanitizes' the access, validating the read value is indeed a valid
address inside the management FW's buffers.
The patch also removes a read outside the scope of the buffer, which resulted
in some unrelated chraracters appearing in the log.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  4 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 32 ++++++++++++++++++------
 2 files changed, 29 insertions(+), 7 deletions(-)

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
index 60f9e68..c2609c4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -751,6 +751,10 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 	return rc;
 }
 
+#define MCPR_TRACE_BUFFER_SIZE	(0x800)
+#define SCRATCH_BUFFER_SIZE(bp)	\
+	(CHIP_IS_E1(bp) ? 0x10000 : (CHIP_IS_E1H(bp) ? 0x20000 : 0x28000))
+
 void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 {
 	u32 addr, val;
@@ -775,7 +779,17 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 		trace_shmem_base = bp->common.shmem_base;
 	else
 		trace_shmem_base = SHMEM2_RD(bp, other_shmem_base_addr);
-	addr = trace_shmem_base - 0x800;
+
+	/* sanity */
+	if (trace_shmem_base < MCPR_SCRATCH_BASE(bp) + MCPR_TRACE_BUFFER_SIZE ||
+	    trace_shmem_base >= MCPR_SCRATCH_BASE(bp) +
+				SCRATCH_BUFFER_SIZE(bp)) {
+		BNX2X_ERR("Unable to dump trace buffer (mark %x)\n",
+			  trace_shmem_base);
+		return;
+	}
+
+	addr = trace_shmem_base - MCPR_TRACE_BUFFER_SIZE;
 
 	/* validate TRCB signature */
 	mark = REG_RD(bp, addr);
@@ -787,14 +801,17 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 	/* read cyclic buffer pointer */
 	addr += 4;
 	mark = REG_RD(bp, addr);
-	mark = (CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
-			+ ((mark + 0x3) & ~0x3) - 0x08000000;
+	mark = MCPR_SCRATCH_BASE(bp) + ((mark + 0x3) & ~0x3) - 0x08000000;
+	if (mark >= trace_shmem_base || mark < addr + 4) {
+		BNX2X_ERR("Mark doesn't fall inside Trace Buffer\n");
+		return;
+	}
 	printk("%s" "begin fw dump (mark 0x%x)\n", lvl, mark);
 
 	printk("%s", lvl);
 
 	/* dump buffer after the mark */
-	for (offset = mark; offset <= trace_shmem_base; offset += 0x8*4) {
+	for (offset = mark; offset < trace_shmem_base; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, offset + 4*word));
 		data[8] = 0x0;
@@ -11685,9 +11702,6 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 static int bnx2x_open(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	bool global = false;
-	int other_engine = BP_PATH(bp) ? 0 : 1;
-	bool other_load_status, load_status;
 	int rc;
 
 	bp->stats_init = true;
@@ -11703,6 +11717,10 @@ static int bnx2x_open(struct net_device *dev)
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
