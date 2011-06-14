From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 8/24] bnx2x: dump FW memory when appropriate
 msglvl is raised
Date: Tue, 14 Jun 2011 14:33:25 +0300
Message-ID: <201106141433.25717.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2506 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756261Ab1FNLeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:34:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.h     |    2 ++
 drivers/net/bnx2x/bnx2x_ethtool.c |    6 +++++-
 drivers/net/bnx2x/bnx2x_main.c    |   23 ++++++++++++++++++-----
 drivers/net/bnx2x/bnx2x_reg.h     |    1 +
 4 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index fab161e..b01f737 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -363,6 +363,8 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
  */
 void bnx2x_update_max_mf_config(struct bnx2x *bp, u32 value);
 
+void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl);
+
 /* dev_close main block */
 int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
 
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 727fe89..10b17f6 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -682,8 +682,12 @@ static void bnx2x_set_msglevel(struct net_device *dev, u32 level)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	if (capable(CAP_NET_ADMIN))
+	if (capable(CAP_NET_ADMIN)) {
+		/* dump MCP trace */
+		if (level & BNX2X_MSG_MCP)
+			bnx2x_fw_dump_lvl(bp, KERN_INFO);
 		bp->msg_enable = level;
+	}
 }
 
 static int bnx2x_nway_reset(struct net_device *dev)
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 0e8d302..c6c59ad 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -833,9 +833,9 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 	return rc;
 }
 
-static void bnx2x_fw_dump(struct bnx2x *bp)
+void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 {
-	u32 addr;
+	u32 addr, val;
 	u32 mark, offset;
 	__be32 data[9];
 	int word;
@@ -844,6 +844,14 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 		BNX2X_ERR("NO MCP - can not dump\n");
 		return;
 	}
+	netdev_printk(lvl, bp->dev, "bc %d.%d.%d\n",
+		(bp->common.bc_ver & 0xff0000) >> 16,
+		(bp->common.bc_ver & 0xff00) >> 8,
+		(bp->common.bc_ver & 0xff));
+
+	val = REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER);
+	if (val == REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER))
+		printk("%s" "MCP PC at 0x%x\n", lvl, val);
 
 	if (BP_PATH(bp) == 0)
 		trace_shmem_base = bp->common.shmem_base;
@@ -853,9 +861,9 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 	mark = REG_RD(bp, addr);
 	mark = (CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
 			+ ((mark + 0x3) & ~0x3) - 0x08000000;
-	pr_err("begin fw dump (mark 0x%x)\n", mark);
+	printk("%s" "begin fw dump (mark 0x%x)\n", lvl, mark);
 
-	pr_err("");
+	printk("%s", lvl);
 	for (offset = mark; offset <= trace_shmem_base; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
 			data[word] = htonl(REG_RD(bp, offset + 4*word));
@@ -868,7 +876,12 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 		data[8] = 0x0;
 		pr_cont("%s", (char *)data);
 	}
-	pr_err("end of fw dump\n");
+	printk("%s" "end of fw dump\n", lvl);
+}
+
+static inline void bnx2x_fw_dump(struct bnx2x *bp)
+{
+	bnx2x_fw_dump_lvl(bp, KERN_ERR);
 }
 
 void bnx2x_panic_dump(struct bnx2x *bp)
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 86bba25..40bddca 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -933,6 +933,7 @@
  * clear; 1 = set. Data valid only in addresses 0-4. all the rest are zero. */
 #define IGU_REG_WRITE_DONE_PENDING				 0x130480
 #define MCP_A_REG_MCPR_SCRATCH					 0x3a0000
+#define MCP_REG_MCPR_CPU_PROGRAM_COUNTER			 0x8501c
 #define MCP_REG_MCPR_NVM_ACCESS_ENABLE				 0x86424
 #define MCP_REG_MCPR_NVM_ADDR					 0x8640c
 #define MCP_REG_MCPR_NVM_CFG4					 0x8642c
-- 
1.7.2.2


