From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 1/2] bna: fix interrupt handling
Date: Tue, 5 Oct 2010 18:46:04 -0700
Message-ID: <1286329565-20234-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shemminger@vyatta.com>, Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37186 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750954Ab0JFBqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 21:46:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fix handles the case when IRQ handler is called (for shared IRQs)
even before the driver is ready to handle interrupts.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |   48 +++++++++++++++++++++++++++---------------------
 1 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index e380c0e..7210c34 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -564,9 +564,11 @@ bnad_disable_rx_irq(struct bnad *bnad, struct bna_ccb *ccb)
 static void
 bnad_enable_rx_irq(struct bnad *bnad, struct bna_ccb *ccb)
 {
-	spin_lock_irq(&bnad->bna_lock); /* Because of polling context */
+	unsigned long flags;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags); /* Because of polling context */
 	bnad_enable_rx_irq_unsafe(ccb);
-	spin_unlock_irq(&bnad->bna_lock);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
 static void
@@ -599,7 +601,7 @@ static irqreturn_t
 bnad_msix_mbox_handler(int irq, void *data)
 {
 	u32 intr_status;
-	unsigned long  flags;
+	unsigned long flags;
 	struct net_device *netdev = data;
 	struct bnad *bnad;
 
@@ -630,13 +632,15 @@ bnad_isr(int irq, void *data)
 	struct bnad_rx_info *rx_info;
 	struct bnad_rx_ctrl *rx_ctrl;
 
-	spin_lock_irqsave(&bnad->bna_lock, flags);
+	if (unlikely(test_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags)))
+		return IRQ_NONE;
 
 	bna_intr_status_get(&bnad->bna, intr_status);
-	if (!intr_status) {
-		spin_unlock_irqrestore(&bnad->bna_lock, flags);
+
+	if (unlikely(!intr_status))
 		return IRQ_NONE;
-	}
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
 
 	if (BNA_IS_MBOX_ERR_INTR(intr_status)) {
 		bna_mbox_handler(&bnad->bna, intr_status);
@@ -672,11 +676,10 @@ bnad_enable_mbox_irq(struct bnad *bnad)
 {
 	int irq = BNAD_GET_MBOX_IRQ(bnad);
 
-	if (!(bnad->cfg_flags & BNAD_CF_MSIX))
-		return;
-
 	if (test_and_clear_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags))
-		enable_irq(irq);
+		if (bnad->cfg_flags & BNAD_CF_MSIX)
+			enable_irq(irq);
+
 	BNAD_UPDATE_CTR(bnad, mbox_intr_enabled);
 }
 
@@ -689,11 +692,11 @@ bnad_disable_mbox_irq(struct bnad *bnad)
 {
 	int irq = BNAD_GET_MBOX_IRQ(bnad);
 
-	if (!(bnad->cfg_flags & BNAD_CF_MSIX))
-		return;
 
 	if (!test_and_set_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags))
-		disable_irq_nosync(irq);
+		if (bnad->cfg_flags & BNAD_CF_MSIX)
+			disable_irq_nosync(irq);
+
 	BNAD_UPDATE_CTR(bnad, mbox_intr_disabled);
 }
 
@@ -1045,14 +1048,12 @@ bnad_mbox_irq_free(struct bnad *bnad,
 		return;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-
 	bnad_disable_mbox_irq(bnad);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	irq = BNAD_GET_MBOX_IRQ(bnad);
 	free_irq(irq, bnad->netdev);
 
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-
 	kfree(intr_info->idl);
 }
 
@@ -1094,8 +1095,15 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
 
 	sprintf(bnad->mbox_irq_name, "%s", BNAD_NAME);
 
+	/*
+	 * Set the Mbox IRQ disable flag, so that the IRQ handler
+	 * called from request_irq() for SHARED IRQs do not execute
+	 */
+	set_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags);
+
 	err = request_irq(irq, irq_handler, flags,
 			  bnad->mbox_irq_name, bnad->netdev);
+
 	if (err) {
 		kfree(intr_info->idl);
 		intr_info->idl = NULL;
@@ -1103,7 +1111,8 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
 	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bnad_disable_mbox_irq(bnad);
+	if (bnad->cfg_flags & BNAD_CF_MSIX)
+		disable_irq_nosync(irq);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 	return 0;
 }
@@ -1485,7 +1494,6 @@ bnad_stats_timer_start(struct bnad *bnad)
 			  jiffies + msecs_to_jiffies(BNAD_STATS_TIMER_FREQ));
 	}
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-
 }
 
 /*
@@ -2170,7 +2178,6 @@ bnad_device_disable(struct bnad *bnad)
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	wait_for_completion(&bnad->bnad_completions.ioc_comp);
-
 }
 
 static int
@@ -3108,7 +3115,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_init(bna, bnad, &pcidev_info, &bnad->res_info[0]);
-
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	bnad->stats.bna_stats = &bna->stats;
-- 
1.7.1

