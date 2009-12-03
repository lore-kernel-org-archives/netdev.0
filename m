From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/5] bnx2: Dump some state during tx timeout.
Date: Thu, 3 Dec 2009 11:46:32 -0800
Message-ID: <1259869595-6450-2-git-send-email-mchan@broadcom.com>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3519 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756052AbZLCTja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 14:39:30 -0500
In-Reply-To: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To help debug the problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   23 +++++++++++++++++++++++
 drivers/net/bnx2.h |    2 ++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 03eb51f..665253a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6279,10 +6279,33 @@ bnx2_reset_task(struct work_struct *work)
 }
 
 static void
+bnx2_dump_state(struct bnx2 *bp)
+{
+	struct net_device *dev = bp->dev;
+
+	printk(KERN_ERR PFX "%s DEBUG: intr_sem[%x]\n", dev->name,
+		atomic_read(&bp->intr_sem));
+	printk(KERN_ERR PFX "%s DEBUG: EMAC_TX_STATUS[%08x] "
+			    "RPM_MGMT_PKT_CTRL[%08x]\n", dev->name,
+		REG_RD(bp, BNX2_EMAC_TX_STATUS),
+		REG_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
+	printk(KERN_ERR PFX "%s DEBUG: MCP_STATE_P0[%08x] MCP_STATE_P1[%08x]\n",
+		dev->name, bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P0),
+		bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P1));
+	printk(KERN_ERR PFX "%s DEBUG: HC_STATS_INTERRUPT_STATUS[%08x]\n",
+		dev->name, REG_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
+	if (bp->flags & BNX2_FLAG_USING_MSIX)
+		printk(KERN_ERR PFX "%s DEBUG: PBA[%08x]\n", dev->name,
+			REG_RD(bp, BNX2_PCI_GRC_WINDOW3_BASE));
+}
+
+static void
 bnx2_tx_timeout(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
+	bnx2_dump_state(bp);
+
 	/* This allows the netif to be shutdown gracefully before resetting */
 	schedule_work(&bp->reset_task);
 }
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 4908b9f..939dc44 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6345,6 +6345,8 @@ struct l2_fhdr {
 
 #define BNX2_MCP_ROM					0x00150000
 #define BNX2_MCP_SCRATCH				0x00160000
+#define BNX2_MCP_STATE_P1				 0x0016f9c8
+#define BNX2_MCP_STATE_P0				 0x0016fdc8
 
 #define BNX2_SHM_HDR_SIGNATURE				BNX2_MCP_SCRATCH
 #define BNX2_SHM_HDR_SIGNATURE_SIG_MASK			 0xffff0000
-- 
1.6.4.GIT


