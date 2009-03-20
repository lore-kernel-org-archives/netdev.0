From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/5] sfc: Work around unreliable legacy interrupt status
Date: Fri, 20 Mar 2009 23:26:41 +0000
Message-ID: <1237591601.3217.8.camel@achroite>
References: <1237591540.3217.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:36111 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763192AbZCTX0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 19:26:46 -0400
In-Reply-To: <1237591540.3217.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rare cases, reading the legacy interrupt status register can
acknowledge an event queue whose attention flag has not yet been set
in the register.  Until we service this event queue it will not
generate any more interrupts.  Therefore, as a secondary check, poll
the next slot in each active event queue whose flag is not set.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 2ae51fd..92ea614 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1435,6 +1435,7 @@ static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 {
 	struct efx_nic *efx = dev_id;
 	efx_oword_t *int_ker = efx->irq_status.addr;
+	irqreturn_t result = IRQ_NONE;
 	struct efx_channel *channel;
 	efx_dword_t reg;
 	u32 queues;
@@ -1449,23 +1450,24 @@ static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 	if (unlikely(syserr))
 		return falcon_fatal_interrupt(efx);
 
-	if (queues == 0)
-		return IRQ_NONE;
-
-	efx->last_irq_cpu = raw_smp_processor_id();
-	EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_DWORD_FMT "\n",
-		  irq, raw_smp_processor_id(), EFX_DWORD_VAL(reg));
-
 	/* Schedule processing of any interrupting queues */
-	channel = &efx->channel[0];
-	while (queues) {
-		if (queues & 0x01)
+	efx_for_each_channel(channel, efx) {
+		if ((queues & 1) ||
+		    falcon_event_present(
+			    falcon_event(channel, channel->eventq_read_ptr))) {
 			efx_schedule_channel(channel);
-		channel++;
+			result = IRQ_HANDLED;
+		}
 		queues >>= 1;
 	}
 
-	return IRQ_HANDLED;
+	if (result == IRQ_HANDLED) {
+		efx->last_irq_cpu = raw_smp_processor_id();
+		EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_DWORD_FMT "\n",
+			  irq, raw_smp_processor_id(), EFX_DWORD_VAL(reg));
+	}
+
+	return result;
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

