From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 09/12] bna: MBOX IRQ Flag Check after Locking
Date: Tue, 30 Aug 2011 18:27:45 -0700
Message-ID: <1314754068-31978-10-git-send-email-rmody@brocade.com>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53385 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754657Ab1HaB2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 21:28:20 -0400
In-Reply-To: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Check the BNAD_RF_MBOX_IRQ_DISABLED flag after acquiring the bna_lock,
   since checking the flag and executing bna_mbox_handler needs to be atomic.
   If not, it opens up window where flag is reset when it was checked, but got
   set while spinning on the lock by the other thread which is actually
   holding the lock

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 0202b98..c6313e8 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -586,10 +586,11 @@ bnad_msix_mbox_handler(int irq, void *data)
 	unsigned long flags;
 	struct bnad *bnad = (struct bnad *)data;
 
-	if (unlikely(test_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags)))
-		return IRQ_HANDLED;
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
+	if (unlikely(test_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags))) {
+		spin_unlock_irqrestore(&bnad->bna_lock, flags);
+		return IRQ_HANDLED;
+	}
 
 	bna_intr_status_get(&bnad->bna, intr_status);
 
@@ -612,15 +613,18 @@ bnad_isr(int irq, void *data)
 	struct bnad_rx_ctrl *rx_ctrl;
 	struct bna_tcb *tcb = NULL;
 
-	if (unlikely(test_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags)))
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	if (unlikely(test_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags))) {
+		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 		return IRQ_NONE;
+	}
 
 	bna_intr_status_get(&bnad->bna, intr_status);
 
-	if (unlikely(!intr_status))
+	if (unlikely(!intr_status)) {
+		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 		return IRQ_NONE;
-
-	spin_lock_irqsave(&bnad->bna_lock, flags);
+	}
 
 	if (BNA_IS_MBOX_ERR_INTR(&bnad->bna, intr_status))
 		bna_mbox_handler(&bnad->bna, intr_status);
-- 
1.7.1
