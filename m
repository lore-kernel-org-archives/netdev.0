From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 2/4] bnxt_en: Change bp->state to bitmap.
Date: Tue, 8 Dec 2015 19:18:40 -0500
Message-ID: <1449620322-12961-3-git-send-email-mchan@broadcom.com>
References: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64648 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbbLIASo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 19:18:44 -0500
In-Reply-To: <1449620322-12961-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows multiple independent bits to be set for various states.
Subsequent patches to implement tx timeout reset will require this.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 8 ++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       | 5 ++---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 2 +-
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 51671e3..fd89e9d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4602,7 +4602,7 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 			bp->nge_port_cnt = 1;
 	}
 
-	bp->state = BNXT_STATE_OPEN;
+	set_bit(BNXT_STATE_OPEN, &bp->state);
 	bnxt_enable_int(bp);
 	/* Enable TX queues */
 	bnxt_tx_enable(bp);
@@ -4678,7 +4678,7 @@ int bnxt_close_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	/* Change device state to avoid TX queue wake up's */
 	bnxt_tx_disable(bp);
 
-	bp->state = BNXT_STATE_CLOSED;
+	clear_bit(BNXT_STATE_OPEN, &bp->state);
 	cancel_work_sync(&bp->sp_task);
 
 	/* Flush rings before disabling interrupts */
@@ -5080,7 +5080,7 @@ static void bnxt_sp_task(struct work_struct *work)
 	struct bnxt *bp = container_of(work, struct bnxt, sp_task);
 	int rc;
 
-	if (bp->state != BNXT_STATE_OPEN)
+	if (!test_bit(BNXT_STATE_OPEN, &bp->state))
 		return;
 
 	if (test_and_clear_bit(BNXT_RX_MASK_SP_EVENT, &bp->sp_event))
@@ -5185,7 +5185,7 @@ static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->timer.function = bnxt_timer;
 	bp->current_interval = BNXT_TIMER_INTERVAL;
 
-	bp->state = BNXT_STATE_CLOSED;
+	clear_bit(BNXT_STATE_OPEN, &bp->state);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 674bc51..a8b6881 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -925,9 +925,8 @@ struct bnxt {
 
 	struct timer_list	timer;
 
-	int			state;
-#define BNXT_STATE_CLOSED	0
-#define BNXT_STATE_OPEN		1
+	unsigned long		state;
+#define BNXT_STATE_OPEN		0
 
 	struct bnxt_irq	*irq_tbl;
 	u8			mac_addr[ETH_ALEN];
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 7a9af28..ea044bb 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -21,7 +21,7 @@
 #ifdef CONFIG_BNXT_SRIOV
 static int bnxt_vf_ndo_prep(struct bnxt *bp, int vf_id)
 {
-	if (bp->state != BNXT_STATE_OPEN) {
+	if (!test_bit(BNXT_STATE_OPEN, &bp->state)) {
 		netdev_err(bp->dev, "vf ndo called though PF is down\n");
 		return -EINVAL;
 	}
-- 
1.8.3.1
