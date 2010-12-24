From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] bnx2: Free IRQ before freeing status block
 memory
Date: Thu, 23 Dec 2010 18:21:59 -0800
Message-ID: <1293157320-13758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2462 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601Ab0LXDRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 22:17:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing ring size, we free all memory including status block
memory.  If we're in INTA mode and sharing IRQ, the IRQ handler can
be called and it will reference the NULL status block pointer.

Because of the lockless design of the IRQ handler, there is no simple
way to synchronize and prevent this.  So we avoid this problem by
freeing the IRQ handler before freeing the status block memory.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6fa7984..44aed3b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6096,7 +6096,7 @@ bnx2_request_irq(struct bnx2 *bp)
 }
 
 static void
-bnx2_free_irq(struct bnx2 *bp)
+__bnx2_free_irq(struct bnx2 *bp)
 {
 	struct bnx2_irq *irq;
 	int i;
@@ -6107,6 +6107,13 @@ bnx2_free_irq(struct bnx2 *bp)
 			free_irq(irq->vector, &bp->bnx2_napi[i]);
 		irq->requested = 0;
 	}
+}
+
+static void
+bnx2_free_irq(struct bnx2 *bp)
+{
+
+	__bnx2_free_irq(bp);
 	if (bp->flags & BNX2_FLAG_USING_MSI)
 		pci_disable_msi(bp->pdev);
 	else if (bp->flags & BNX2_FLAG_USING_MSIX)
@@ -7092,6 +7099,7 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 
 		bnx2_netif_stop(bp, true);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
+		__bnx2_free_irq(bp);
 		bnx2_free_skbs(bp);
 		bnx2_free_mem(bp);
 	}
@@ -7104,6 +7112,9 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 
 		rc = bnx2_alloc_mem(bp);
 		if (!rc)
+			rc = bnx2_request_irq(bp);
+
+		if (!rc)
 			rc = bnx2_init_nic(bp, 0);
 
 		if (rc) {
-- 
1.6.4.GIT


