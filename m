From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 3/4] bnxt_en: Don't cancel sp_task from bnxt_close_nic().
Date: Tue, 8 Dec 2015 19:18:41 -0500
Message-ID: <1449620322-12961-4-git-send-email-mchan@broadcom.com>
References: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:5468 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbbLIASo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 19:18:44 -0500
In-Reply-To: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When implementing driver reset from tx_timeout in the next patch,
bnxt_close_nic() will be called from the sp_task workqueue.  Calling
cancel_work() on sp_task will hang the workqueue.

Instead, set a new bit BNXT_STATE_IN_SP_TASK when bnxt_sp_task() is running.
bnxt_close_nic() will wait for BNXT_STATE_IN_SP_TASK to clear before
proceeding.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 13 +++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index fd89e9d..f5f4489 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4679,7 +4679,9 @@ int bnxt_close_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	bnxt_tx_disable(bp);
 
 	clear_bit(BNXT_STATE_OPEN, &bp->state);
-	cancel_work_sync(&bp->sp_task);
+	smp_mb__after_atomic();
+	while (test_bit(BNXT_STATE_IN_SP_TASK, &bp->state))
+		msleep(20);
 
 	/* Flush rings before disabling interrupts */
 	bnxt_shutdown_nic(bp, irq_re_init);
@@ -5080,8 +5082,12 @@ static void bnxt_sp_task(struct work_struct *work)
 	struct bnxt *bp = container_of(work, struct bnxt, sp_task);
 	int rc;
 
-	if (!test_bit(BNXT_STATE_OPEN, &bp->state))
+	set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
+	smp_mb__after_atomic();
+	if (!test_bit(BNXT_STATE_OPEN, &bp->state)) {
+		clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 		return;
+	}
 
 	if (test_and_clear_bit(BNXT_RX_MASK_SP_EVENT, &bp->sp_event))
 		bnxt_cfg_rx_mode(bp);
@@ -5107,6 +5113,9 @@ static void bnxt_sp_task(struct work_struct *work)
 	}
 	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
 		bnxt_reset_task(bp);
+
+	smp_mb__before_atomic();
+	clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 }
 
 static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index a8b6881..f199f4c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -927,6 +927,7 @@ struct bnxt {
 
 	unsigned long		state;
 #define BNXT_STATE_OPEN		0
+#define BNXT_STATE_IN_SP_TASK	1
 
 	struct bnxt_irq	*irq_tbl;
 	u8			mac_addr[ETH_ALEN];
-- 
1.8.3.1
