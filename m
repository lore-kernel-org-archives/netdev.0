From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/14] bnxt_en: Improve the IRQ disable sequence during shutdown.
Date: Thu, 29 Dec 2016 12:13:33 -0500
Message-ID: <1483031624-20076-4-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36842 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753224AbcL2ROD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:03 -0500
Received: by mail-pf0-f170.google.com with SMTP id 189so63329664pfz.3
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:02 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IRQ is disabled by writing to the completion ring doorbell.  This
should be done before the hardware completion ring is freed for correctness.
The current code disables IRQs after all the completion rings are freed.

Fix it by calling bnxt_disable_int_sync() before freeing the completion
rings.  Rearrange the code to avoid forward declaration.

Signed-off-by: Michael Chan <michael.chan@broadocm.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 89 ++++++++++++++++---------------
 1 file changed, 46 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 3fbc842..277573b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2953,6 +2953,45 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 	return rc;
 }
 
+static void bnxt_disable_int(struct bnxt *bp)
+{
+	int i;
+
+	if (!bp->bnapi)
+		return;
+
+	for (i = 0; i < bp->cp_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+
+		BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
+	}
+}
+
+static void bnxt_disable_int_sync(struct bnxt *bp)
+{
+	int i;
+
+	atomic_inc(&bp->intr_sem);
+
+	bnxt_disable_int(bp);
+	for (i = 0; i < bp->cp_nr_rings; i++)
+		synchronize_irq(bp->irq_tbl[i].vector);
+}
+
+static void bnxt_enable_int(struct bnxt *bp)
+{
+	int i;
+
+	atomic_set(&bp->intr_sem, 0);
+	for (i = 0; i < bp->cp_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+
+		BNXT_CP_DB_REARM(cpr->cp_doorbell, cpr->cp_raw_cons);
+	}
+}
+
 void bnxt_hwrm_cmd_hdr_init(struct bnxt *bp, void *request, u16 req_type,
 			    u16 cmpl_ring, u16 target_id)
 {
@@ -3937,6 +3976,12 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 		}
 	}
 
+	/* The completion rings are about to be freed.  After that the
+	 * IRQ doorbell will not work anymore.  So we need to disable
+	 * IRQ here.
+	 */
+	bnxt_disable_int_sync(bp);
+
 	for (i = 0; i < bp->cp_nr_rings; i++) {
 		struct bnxt_napi *bnapi = bp->bnapi[i];
 		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
@@ -4658,34 +4703,6 @@ static int bnxt_init_nic(struct bnxt *bp, bool irq_re_init)
 	return bnxt_init_chip(bp, irq_re_init);
 }
 
-static void bnxt_disable_int(struct bnxt *bp)
-{
-	int i;
-
-	if (!bp->bnapi)
-		return;
-
-	for (i = 0; i < bp->cp_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-
-		BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
-	}
-}
-
-static void bnxt_enable_int(struct bnxt *bp)
-{
-	int i;
-
-	atomic_set(&bp->intr_sem, 0);
-	for (i = 0; i < bp->cp_nr_rings; i++) {
-		struct bnxt_napi *bnapi = bp->bnapi[i];
-		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-
-		BNXT_CP_DB_REARM(cpr->cp_doorbell, cpr->cp_raw_cons);
-	}
-}
-
 static int bnxt_set_real_num_queues(struct bnxt *bp)
 {
 	int rc;
@@ -5640,19 +5657,6 @@ static int bnxt_open(struct net_device *dev)
 	return __bnxt_open_nic(bp, true, true);
 }
 
-static void bnxt_disable_int_sync(struct bnxt *bp)
-{
-	int i;
-
-	atomic_inc(&bp->intr_sem);
-	if (!netif_running(bp->dev))
-		return;
-
-	bnxt_disable_int(bp);
-	for (i = 0; i < bp->cp_nr_rings; i++)
-		synchronize_irq(bp->irq_tbl[i].vector);
-}
-
 int bnxt_close_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 {
 	int rc = 0;
@@ -5674,13 +5678,12 @@ int bnxt_close_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	while (test_bit(BNXT_STATE_IN_SP_TASK, &bp->state))
 		msleep(20);
 
-	/* Flush rings before disabling interrupts */
+	/* Flush rings and and disable interrupts */
 	bnxt_shutdown_nic(bp, irq_re_init);
 
 	/* TODO CHIMP_FW: Link/PHY related cleanup if (link_re_init) */
 
 	bnxt_disable_napi(bp);
-	bnxt_disable_int_sync(bp);
 	del_timer_sync(&bp->timer);
 	bnxt_free_skbs(bp);
 
-- 
1.8.3.1
