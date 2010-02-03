From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/10] sfc: Survive ISR0=0 bug in the shared IRQ case
Date: Wed, 03 Feb 2010 19:31:24 +0000
Message-ID: <1265225484.2116.6.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28057 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806Ab0BCTb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:31:27 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guido Barzini <gbarzini@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index db44224..8d9696a 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1384,6 +1384,15 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 		efx->last_irq_cpu = raw_smp_processor_id();
 		EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_DWORD_FMT "\n",
 			  irq, raw_smp_processor_id(), EFX_DWORD_VAL(reg));
+	} else if (EFX_WORKAROUND_15783(efx)) {
+		/* We can't return IRQ_HANDLED more than once on seeing ISR0=0
+		 * because this might be a shared interrupt, but we do need to
+		 * check the channel every time and preemptively rearm it if
+		 * it's idle. */
+		efx_for_each_channel(channel, efx) {
+			if (!channel->work_pending)
+				efx_nic_eventq_read_ack(channel);
+		}
 	}
 
 	return result;
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

