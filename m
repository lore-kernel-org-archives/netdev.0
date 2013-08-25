From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/16] sfc: Limit scope of a Falcon A1 IRQ
 workaround
Date: Mon, 26 Aug 2013 00:03:43 +0100
Message-ID: <1377471823.2586.76.camel@deadeye.wl.decadent.org.uk>
References: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56369 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756651Ab3HYXDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 19:03:47 -0400
In-Reply-To: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We unconditionally acknowledge legacy interrupts just before disabling
them.  This workaround is needed on Falcon A1 but probably not on
later chips where the legacy interrupt mechanism is different.  It was
also originally done after the IRQ handler was removed, not before.
Restore the original behaviour for Falcon A1 only by doing this
acknowledgement in the efx_nic_type::fini operation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c |    4 ++--
 drivers/net/ethernet/sfc/nic.c    |    7 -------
 drivers/net/ethernet/sfc/nic.h    |    1 -
 3 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index f8de382..4492129 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -336,7 +336,7 @@ static void falcon_prepare_flush(struct efx_nic *efx)
  *
  * NB most hardware supports MSI interrupts
  */
-inline void falcon_irq_ack_a1(struct efx_nic *efx)
+static inline void falcon_irq_ack_a1(struct efx_nic *efx)
 {
 	efx_dword_t reg;
 
@@ -2343,7 +2343,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.remove = falcon_remove_nic,
 	.init = falcon_init_nic,
 	.dimension_resources = falcon_dimension_resources,
-	.fini = efx_port_dummy_op_void,
+	.fini = falcon_irq_ack_a1,
 	.monitor = falcon_monitor,
 	.map_reset_reason = falcon_map_reset_reason,
 	.map_reset_flags = falcon_map_reset_flags,
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index c17d659..2d0a584 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1781,7 +1781,6 @@ int efx_nic_init_interrupt(struct efx_nic *efx)
 void efx_nic_fini_interrupt(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
-	efx_oword_t reg;
 
 #ifdef CONFIG_RFS_ACCEL
 	free_irq_cpu_rmap(efx->net_dev->rx_cpu_rmap);
@@ -1792,12 +1791,6 @@ void efx_nic_fini_interrupt(struct efx_nic *efx)
 	efx_for_each_channel(channel, efx)
 		free_irq(channel->irq, &efx->msi_context[channel->channel]);
 
-	/* ACK legacy interrupt */
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
-		efx_reado(efx, &reg, FR_BZ_INT_ISR0);
-	else
-		falcon_irq_ack_a1(efx);
-
 	/* Disable legacy interrupt */
 	if (efx->legacy_irq)
 		free_irq(efx->legacy_irq, efx);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 9120e8b..33aa120 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -308,7 +308,6 @@ extern void efx_nic_disable_interrupts(struct efx_nic *efx);
 extern void efx_nic_fini_interrupt(struct efx_nic *efx);
 extern irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx);
 extern irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id);
-extern void falcon_irq_ack_a1(struct efx_nic *efx);
 
 static inline int efx_nic_event_test_irq_cpu(struct efx_channel *channel)
 {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
