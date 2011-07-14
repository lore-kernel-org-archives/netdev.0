From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/6] bnx2: Add MCP dump
Date: Wed, 13 Jul 2011 20:24:21 -0700
Message-ID: <1310613862-27497-5-git-send-email-mchan@broadcom.com>
References: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
 <1310613862-27497-2-git-send-email-mchan@broadcom.com>
 <1310613862-27497-3-git-send-email-mchan@broadcom.com>
 <1310613862-27497-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2715 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab1GNEQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 00:16:48 -0400
In-Reply-To: <1310613862-27497-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

to help debug issues related to management firmware.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |   61 ++++++++++++++++++++++++++++++++++++++++-----------
 drivers/net/bnx2.h |    8 ++++++
 2 files changed, 56 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7915d14..d105f1f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2443,6 +2443,48 @@ bnx2_set_phy_loopback(struct bnx2 *bp)
 	return 0;
 }
 
+static void
+bnx2_dump_mcp_state(struct bnx2 *bp)
+{
+	struct net_device *dev = bp->dev;
+	u32 mcp_p0, mcp_p1;
+
+	netdev_err(dev, "<--- start MCP states dump --->\n");
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		mcp_p0 = BNX2_MCP_STATE_P0;
+		mcp_p1 = BNX2_MCP_STATE_P1;
+	} else {
+		mcp_p0 = BNX2_MCP_STATE_P0_5708;
+		mcp_p1 = BNX2_MCP_STATE_P1_5708;
+	}
+	netdev_err(dev, "DEBUG: MCP_STATE_P0[%08x] MCP_STATE_P1[%08x]\n",
+		   bnx2_reg_rd_ind(bp, mcp_p0), bnx2_reg_rd_ind(bp, mcp_p1));
+	netdev_err(dev, "DEBUG: MCP mode[%08x] state[%08x] evt_mask[%08x]\n",
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_CPU_MODE),
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_CPU_STATE),
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_CPU_EVENT_MASK));
+	netdev_err(dev, "DEBUG: pc[%08x] pc[%08x] instr[%08x]\n",
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_CPU_PROGRAM_COUNTER),
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_CPU_PROGRAM_COUNTER),
+		   bnx2_reg_rd_ind(bp, BNX2_MCP_CPU_INSTRUCTION));
+	netdev_err(dev, "DEBUG: shmem states:\n");
+	netdev_err(dev, "DEBUG: drv_mb[%08x] fw_mb[%08x] link_status[%08x]",
+		   bnx2_shmem_rd(bp, BNX2_DRV_MB),
+		   bnx2_shmem_rd(bp, BNX2_FW_MB),
+		   bnx2_shmem_rd(bp, BNX2_LINK_STATUS));
+	pr_cont(" drv_pulse_mb[%08x]\n", bnx2_shmem_rd(bp, BNX2_DRV_PULSE_MB));
+	netdev_err(dev, "DEBUG: dev_info_signature[%08x] reset_type[%08x]",
+		   bnx2_shmem_rd(bp, BNX2_DEV_INFO_SIGNATURE),
+		   bnx2_shmem_rd(bp, BNX2_BC_STATE_RESET_TYPE));
+	pr_cont(" condition[%08x]\n",
+		bnx2_shmem_rd(bp, BNX2_BC_STATE_CONDITION));
+	DP_SHMEM_LINE(bp, 0x3cc);
+	DP_SHMEM_LINE(bp, 0x3dc);
+	DP_SHMEM_LINE(bp, 0x3ec);
+	netdev_err(dev, "DEBUG: 0x3fc[%08x]\n", bnx2_shmem_rd(bp, 0x3fc));
+	netdev_err(dev, "<--- end MCP states dump --->\n");
+}
+
 static int
 bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int ack, int silent)
 {
@@ -2471,13 +2513,14 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int ack, int silent)
 
 	/* If we timed out, inform the firmware that this is the case. */
 	if ((val & BNX2_FW_MSG_ACK) != (msg_data & BNX2_DRV_MSG_SEQ)) {
-		if (!silent)
-			pr_err("fw sync timeout, reset code = %x\n", msg_data);
-
 		msg_data &= ~BNX2_DRV_MSG_CODE;
 		msg_data |= BNX2_DRV_MSG_CODE_FW_TIMEOUT;
 
 		bnx2_shmem_wr(bp, BNX2_DRV_MB, msg_data);
+		if (!silent) {
+			pr_err("fw sync timeout, reset code = %x\n", msg_data);
+			bnx2_dump_mcp_state(bp);
+		}
 
 		return -EBUSY;
 	}
@@ -6316,7 +6359,7 @@ static void
 bnx2_dump_state(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
-	u32 mcp_p0, mcp_p1, val1, val2;
+	u32 val1, val2;
 
 	pci_read_config_dword(bp->pdev, PCI_COMMAND, &val1);
 	netdev_err(dev, "DEBUG: intr_sem[%x] PCI_CMD[%08x]\n",
@@ -6329,15 +6372,6 @@ bnx2_dump_state(struct bnx2 *bp)
 		   REG_RD(bp, BNX2_EMAC_RX_STATUS));
 	netdev_err(dev, "DEBUG: RPM_MGMT_PKT_CTRL[%08x]\n",
 		   REG_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		mcp_p0 = BNX2_MCP_STATE_P0;
-		mcp_p1 = BNX2_MCP_STATE_P1;
-	} else {
-		mcp_p0 = BNX2_MCP_STATE_P0_5708;
-		mcp_p1 = BNX2_MCP_STATE_P1_5708;
-	}
-	netdev_err(dev, "DEBUG: MCP_STATE_P0[%08x] MCP_STATE_P1[%08x]\n",
-		   bnx2_reg_rd_ind(bp, mcp_p0), bnx2_reg_rd_ind(bp, mcp_p1));
 	netdev_err(dev, "DEBUG: HC_STATS_INTERRUPT_STATUS[%08x]\n",
 		   REG_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
 	if (bp->flags & BNX2_FLAG_USING_MSIX)
@@ -6351,6 +6385,7 @@ bnx2_tx_timeout(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 
 	bnx2_dump_state(bp);
+	bnx2_dump_mcp_state(bp);
 
 	/* This allows the netif to be shutdown gracefully before resetting */
 	schedule_work(&bp->reset_task);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index bf371f6..0f0ad2b 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -7370,4 +7370,12 @@ struct bnx2_rv2p_fw_file {
 
 #define HOST_VIEW_SHMEM_BASE			0x167c00
 
+#define DP_SHMEM_LINE(bp, offset)					\
+	netdev_err(bp->dev, "DEBUG: %08x: %08x %08x %08x %08x\n",	\
+		   offset,						\
+		   bnx2_shmem_rd(bp, offset),				\
+		   bnx2_shmem_rd(bp, offset + 4),			\
+		   bnx2_shmem_rd(bp, offset + 8),			\
+		   bnx2_shmem_rd(bp, offset + 12))
+
 #endif
-- 
1.6.4.GIT


