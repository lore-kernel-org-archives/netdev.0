From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bnx2: fix locking when netconsole is used
Date: Mon, 17 Oct 2016 18:20:31 +0200
Message-ID: <1476721231-31624-1-git-send-email-ivecera@redhat.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47112 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934930AbcJQQUk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 12:20:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions bnx2_reg_rd_ind(), bnx2_reg_wr_ind() and bnx2_ctx_wr()
can be called with IRQs disabled when netconsole is enabled. So they
should use spin_{,un}lock_irq{save,restore} instead of _bh variants.

Example call flow:
bnx2_poll()
  ->bnx2_poll_link()
    ->bnx2_phy_int()
      ->bnx2_set_remote_link()
        ->bnx2_shmem_rd()
          ->bnx2_reg_rd_ind()
            -> spin_lock_bh(&bp->indirect_lock);
               spin_unlock_bh(&bp->indirect_lock);
               ...
               -> __local_bh_enable_ip

static inline void __local_bh_enable_ip(unsigned long ip)
      WARN_ON_ONCE(in_irq() || irqs_disabled());   <<<<<< WARN

Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Dept-HSGLinuxNICDev@qlogic.com
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 27f11a5..9c408413 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -272,21 +272,24 @@ static u32
 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset)
 {
 	u32 val;
+	unsigned long flags;
 
-	spin_lock_bh(&bp->indirect_lock);
+	spin_lock_irqsave(&bp->indirect_lock, flags);
 	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
 	val = BNX2_RD(bp, BNX2_PCICFG_REG_WINDOW);
-	spin_unlock_bh(&bp->indirect_lock);
+	spin_unlock_irqrestore(&bp->indirect_lock, flags);
 	return val;
 }
 
 static void
 bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val)
 {
-	spin_lock_bh(&bp->indirect_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&bp->indirect_lock, flags);
 	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
 	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW, val);
-	spin_unlock_bh(&bp->indirect_lock);
+	spin_unlock_irqrestore(&bp->indirect_lock, flags);
 }
 
 static void
@@ -304,8 +307,10 @@ bnx2_shmem_rd(struct bnx2 *bp, u32 offset)
 static void
 bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 {
+	unsigned long flags;
+
 	offset += cid_addr;
-	spin_lock_bh(&bp->indirect_lock);
+	spin_lock_irqsave(&bp->indirect_lock, flags);
 	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		int i;
 
@@ -322,7 +327,7 @@ bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 		BNX2_WR(bp, BNX2_CTX_DATA_ADR, offset);
 		BNX2_WR(bp, BNX2_CTX_DATA, val);
 	}
-	spin_unlock_bh(&bp->indirect_lock);
+	spin_unlock_irqrestore(&bp->indirect_lock, flags);
 }
 
 #ifdef BCM_CNIC
-- 
2.7.3
