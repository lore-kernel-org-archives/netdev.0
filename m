From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 12/16][BNX2]: Add indirect spinlock.
Date: Thu, 03 May 2007 00:30:48 -0700
Message-ID: <1178177448.4909.75.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3714 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030972AbXECGnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:43:45 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add indirect spinlock.

The indirect register access method will be used by more than one
caller in BH context (NAPI poll and timer), so a spinlock is required.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ab58909..cb74f12 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -234,21 +234,29 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp)
 static u32
 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset)
 {
+	u32 val;
+
+	spin_lock_bh(&bp->indirect_lock);
 	REG_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
-	return (REG_RD(bp, BNX2_PCICFG_REG_WINDOW));
+	val = REG_RD(bp, BNX2_PCICFG_REG_WINDOW);
+	spin_unlock_bh(&bp->indirect_lock);
+	return val;
 }
 
 static void
 bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val)
 {
+	spin_lock_bh(&bp->indirect_lock);
 	REG_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
 	REG_WR(bp, BNX2_PCICFG_REG_WINDOW, val);
+	spin_unlock_bh(&bp->indirect_lock);
 }
 
 static void
 bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 {
 	offset += cid_addr;
+	spin_lock_bh(&bp->indirect_lock);
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		int i;
 
@@ -266,6 +274,7 @@ bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 		REG_WR(bp, BNX2_CTX_DATA_ADR, offset);
 		REG_WR(bp, BNX2_CTX_DATA, val);
 	}
+	spin_unlock_bh(&bp->indirect_lock);
 }
 
 static int
@@ -6039,6 +6048,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->pdev = pdev;
 
 	spin_lock_init(&bp->phy_lock);
+	spin_lock_init(&bp->indirect_lock);
 	INIT_WORK(&bp->reset_task, bnx2_reset_task);
 
 	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 124bd03..ba175a8 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6522,6 +6522,7 @@ struct bnx2 {
 
 	/* Used to synchronize phy accesses. */
 	spinlock_t		phy_lock;
+	spinlock_t		indirect_lock;
 
 	u32			phy_flags;
 #define PHY_SERDES_FLAG			1


