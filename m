From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 07/12] qlge: Get rid of irqsave/restore in intr disable.
Date: Mon,  9 Mar 2009 13:59:23 -0700
Message-ID: <1236632368-22079-8-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbZCIVDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:09 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The completion interrupt disable routine is only called from the ISR, so
there is no need for irqsave/restore.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 8b6128e..45ad4cc 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -587,7 +587,6 @@ u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 {
 	u32 var = 0;
-	unsigned long hw_flags;
 	struct intr_context *ctx;
 
 	/* HW disables for us if we're MSIX multi interrupts and
@@ -597,14 +596,14 @@ static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 		return 0;
 
 	ctx = qdev->intr_context + intr;
-	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+	spin_lock(&qdev->hw_lock);
 	if (!atomic_read(&ctx->irq_cnt)) {
 		ql_write32(qdev, INTR_EN,
 		ctx->intr_dis_mask);
 		var = ql_read32(qdev, STS);
 	}
 	atomic_inc(&ctx->irq_cnt);
-	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+	spin_unlock(&qdev->hw_lock);
 	return var;
 }
 
-- 
1.6.0.2

