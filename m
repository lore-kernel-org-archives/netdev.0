From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/8] tg3: Allow screaming interrupt detection
Date: Mon, 20 Apr 2009 09:55:01 -0700
Message-ID: <1240247955.7012@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3398 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921AbZDTRTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:19:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3 driver's ISR is coded to accept interrupts as its own if the
status block tag does not equal the last tag the driver has seen.  The
last_tag field is updated from tg3_poll.  In a screaming interrupt
situation from another device sharing tg3's IRQ, tg3_poll does not get
a chance to be called, so the last_tag will always be out of sync with
the status block tag.  Consequently, the driver will continually
declare the screaming interrupts as its own, thus thwarting the
screaming interrupt detection logic.

This patch solves the problem by creating a new last_irq_tag member and
recording the status block tag in the ISR.  The ISR then checks the
last_irq_tag for interrupt ownership.

Many thanks to John Marvin for the detailed bug report and analysis and
Michael Chan for the bugfix.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Tested-by: John Marvin <jsm@fc.hp.com>
---
 drivers/net/tg3.c |   29 +++++++++++++++++------------
 drivers/net/tg3.h |    1 +
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 201be42..e4fa02c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4656,6 +4656,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 			 * so we must read it before checking for more work.
 			 */
 			tp->last_tag = sblk->status_tag;
+			tp->last_irq_tag = tp->last_tag;
 			rmb();
 		} else
 			sblk->status &= ~SD_STATUS_UPDATED;
@@ -4811,7 +4812,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * Reading the PCI State register will confirm whether the
 	 * interrupt is ours and will flush the status block.
 	 */
-	if (unlikely(sblk->status_tag == tp->last_tag)) {
+	if (unlikely(sblk->status_tag == tp->last_irq_tag)) {
 		if ((tp->tg3_flags & TG3_FLAG_CHIP_RESETTING) ||
 		    (tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
 			handled = 0;
@@ -4831,18 +4832,22 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * excessive spurious interrupts can be worse in some cases.
 	 */
 	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+
+	/*
+	 * In a shared interrupt configuration, sometimes other devices'
+	 * interrupts will scream.  We record the current status tag here
+	 * so that the above check can report that the screaming interrupts
+	 * are unhandled.  Eventually they will be silenced.
+	 */
+	tp->last_irq_tag = sblk->status_tag;
+
 	if (tg3_irq_sync(tp))
 		goto out;
-	if (napi_schedule_prep(&tp->napi)) {
-		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		/* Update last_tag to mark that this status has been
-		 * seen. Because interrupt may be shared, we may be
-		 * racing with tg3_poll(), so only update last_tag
-		 * if tg3_poll() is not scheduled.
-		 */
-		tp->last_tag = sblk->status_tag;
-		__napi_schedule(&tp->napi);
-	}
+
+	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
+
+	napi_schedule(&tp->napi);
+
 out:
 	return IRQ_RETVAL(handled);
 }
@@ -6156,6 +6161,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tp->hw_status->status_tag = 0;
 	}
 	tp->last_tag = 0;
+	tp->last_irq_tag = 0;
 	smp_mb();
 	synchronize_irq(tp->pdev->irq);
 
@@ -7138,7 +7144,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	udelay(100);
 
 	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0);
-	tp->last_tag = 0;
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		tw32_f(DMAC_MODE, DMAC_MODE_ENABLE);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index cb4c62a..ca71a49 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2501,6 +2501,7 @@ struct tg3 {
 	struct tg3_hw_status		*hw_status;
 	dma_addr_t			status_mapping;
 	u32				last_tag;
+	u32				last_irq_tag;
 
 	u32				msg_enable;
 
-- 
1.6.0.6


