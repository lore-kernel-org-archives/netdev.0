From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/8] tg3: Add ability to turn off 1shot MSI
Date: Wed, 31 Aug 2011 14:44:50 -0700
Message-ID: <1314827094-29714-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2585 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932162Ab1HaRzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In older devices, 1-shot MSI mode had to be enabled by the code.  In
newer devices however, 1-shot MSI mode is enabled by default; code would
be needed to disable it.

Disabling 1-shot MSI mode is useful when debugging.  This patch changes
the code so that the TG3_FLAG_1SHOT_MSI accurately reflects (and
controls) the state of 1-shot MSI mode.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e2acf9a..dab2aa7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5712,7 +5712,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 * NIC to stop sending us irqs, engaging "in-intr-handler"
 	 * event coalescing.
 	 */
-	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	tw32_mailbox(tnapi->int_mbox, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
 		napi_schedule(&tnapi->napi);
 
@@ -8809,6 +8809,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (tg3_flag(tp, USING_MSIX) && tp->irq_cnt > 1) {
 		val = tr32(MSGINT_MODE);
 		val |= MSGINT_MODE_MULTIVEC_EN | MSGINT_MODE_ENABLE;
+		if (!tg3_flag(tp, 1SHOT_MSI))
+			val |= MSGINT_MODE_ONE_SHOT_DISABLE;
 		tw32(MSGINT_MODE, val);
 	}
 
@@ -9424,7 +9426,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	if (intr_ok) {
 		/* Reenable MSI one shot mode. */
-		if (tg3_flag(tp, 57765_PLUS)) {
+		if (tg3_flag(tp, 57765_PLUS) && tg3_flag(tp, 1SHOT_MSI)) {
 			val = tr32(MSGINT_MODE) & ~MSGINT_MODE_ONE_SHOT_DISABLE;
 			tw32(MSGINT_MODE, val);
 		}
@@ -9602,6 +9604,8 @@ static void tg3_ints_init(struct tg3 *tp)
 		u32 msi_mode = tr32(MSGINT_MODE);
 		if (tg3_flag(tp, USING_MSIX) && tp->irq_cnt > 1)
 			msi_mode |= MSGINT_MODE_MULTIVEC_EN;
+		if (!tg3_flag(tp, 1SHOT_MSI))
+			msi_mode |= MSGINT_MODE_ONE_SHOT_DISABLE;
 		tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
 	}
 defcfg:
-- 
1.7.3.4
