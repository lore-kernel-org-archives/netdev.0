From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/17] sfc: Extend the legacy interrupt workarounds
Date: Wed, 28 Apr 2010 20:28:27 +0100
Message-ID: <1272482907.2549.22.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12466 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab0D1T2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:28:30 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Siena has two problems with legacy interrupts:
  1. There is no synchronisation between the ISR read completion,
     and the interrupt deassert message.
  2. A downstream read at the "wrong" moment can return 0, and
     suppress generating the next interrupt.

Falcon should suffer from both of these, and it appears it does.
Enable EFX_WORKAROUND_15783 on Falcon as well.

Also, when we see queues == 0, ensure we always schedule or rearm
every event queue.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c         |   23 +++++++++--------------
 drivers/net/sfc/workarounds.h |    2 +-
 2 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 23738f8..b61674c 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1356,33 +1356,28 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 		}
 		result = IRQ_HANDLED;
 
-	} else if (EFX_WORKAROUND_15783(efx) &&
-		   efx->irq_zero_count++ == 0) {
+	} else if (EFX_WORKAROUND_15783(efx)) {
 		efx_qword_t *event;
 
-		/* Ensure we rearm all event queues */
+		/* We can't return IRQ_HANDLED more than once on seeing ISR=0
+		 * because this might be a shared interrupt. */
+		if (efx->irq_zero_count++ == 0)
+			result = IRQ_HANDLED;
+
+		/* Ensure we schedule or rearm all event queues */
 		efx_for_each_channel(channel, efx) {
 			event = efx_event(channel, channel->eventq_read_ptr);
 			if (efx_event_present(event))
 				efx_schedule_channel(channel);
+			else
+				efx_nic_eventq_read_ack(channel);
 		}
-
-		result = IRQ_HANDLED;
 	}
 
 	if (result == IRQ_HANDLED) {
 		efx->last_irq_cpu = raw_smp_processor_id();
 		EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_DWORD_FMT "\n",
 			  irq, raw_smp_processor_id(), EFX_DWORD_VAL(reg));
-	} else if (EFX_WORKAROUND_15783(efx)) {
-		/* We can't return IRQ_HANDLED more than once on seeing ISR0=0
-		 * because this might be a shared interrupt, but we do need to
-		 * check the channel every time and preemptively rearm it if
-		 * it's idle. */
-		efx_for_each_channel(channel, efx) {
-			if (!channel->work_pending)
-				efx_nic_eventq_read_ack(channel);
-		}
 	}
 
 	return result;
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index acd9c73..518f7fc 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -37,7 +37,7 @@
 /* Truncated IPv4 packets can confuse the TX packet parser */
 #define EFX_WORKAROUND_15592 EFX_WORKAROUND_FALCON_AB
 /* Legacy ISR read can return zero once */
-#define EFX_WORKAROUND_15783 EFX_WORKAROUND_SIENA
+#define EFX_WORKAROUND_15783 EFX_WORKAROUND_ALWAYS
 /* Legacy interrupt storm when interrupt fifo fills */
 #define EFX_WORKAROUND_17213 EFX_WORKAROUND_SIENA
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

