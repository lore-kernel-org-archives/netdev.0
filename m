From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 20/32] Partly revert "sfc: Handle serious errors in
 exactly one interrupt handler"
Date: Fri, 27 Jan 2012 20:48:58 +0000
Message-ID: <1327697338.2503.27.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63709 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752836Ab2A0UtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:49:01 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 6369545945b90daa1a73fca174da9194c398417c in
drivers/net/ethernet/sfc/falcon.c.

Unlike the INT_ISR0 register on later controller revisions, the
NET_IVEC_INT_Q bits written to memory are only ever set for
interrupting event queues, not for any other interrupt sources.

By definition there can only be one legacy interrupt handler per
function, so there is no need to worry about detecting a fatal
interrupt more than once.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 0b7880b..b4e91ed 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -174,19 +174,16 @@ irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 		   "IRQ %d on CPU %d status " EFX_OWORD_FMT "\n",
 		   irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
 
+	/* Check to see if we have a serious error condition */
+	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
+	if (unlikely(syserr))
+		return efx_nic_fatal_interrupt(efx);
+
 	/* Determine interrupting queues, clear interrupt status
 	 * register and acknowledge the device interrupt.
 	 */
 	BUILD_BUG_ON(FSF_AZ_NET_IVEC_INT_Q_WIDTH > EFX_MAX_CHANNELS);
 	queues = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_INT_Q);
-
-	/* Check to see if we have a serious error condition */
-	if (queues & (1U << efx->fatal_irq_level)) {
-		syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
-		if (unlikely(syserr))
-			return efx_nic_fatal_interrupt(efx);
-	}
-
 	EFX_ZERO_OWORD(*int_ker);
 	wmb(); /* Ensure the vector is cleared before interrupt ack */
 	falcon_irq_ack_a1(efx);
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
