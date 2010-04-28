From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/17] sfc: Handle serious errors in exactly one interrupt
 handler
Date: Wed, 28 Apr 2010 20:27:36 +0100
Message-ID: <1272482856.2549.19.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12371 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab0D1T1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:27:38 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

'Fatal' errors set an interrupt flag associated with a specific event
queue; only read the syndrome vector if we see that queue's flag set
(legacy interrupts) or in the interrupt handler for that queue (MSI).

Do not ignore an interrupt if the fatal error flag is set but specific
error flags are all zero.  Even if we don't schedule a reset, we must
respect the queue mask and rearm the appropriate event queues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |   13 ++++++++-----
 drivers/net/sfc/net_driver.h |    2 ++
 drivers/net/sfc/nic.c        |   35 +++++++++++++++++++----------------
 3 files changed, 29 insertions(+), 21 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d294d66..d09ad1b 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -175,16 +175,19 @@ irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 	EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_OWORD_FMT "\n",
 		  irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
 
-	/* Check to see if we have a serious error condition */
-	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
-	if (unlikely(syserr))
-		return efx_nic_fatal_interrupt(efx);
-
 	/* Determine interrupting queues, clear interrupt status
 	 * register and acknowledge the device interrupt.
 	 */
 	BUILD_BUG_ON(FSF_AZ_NET_IVEC_INT_Q_WIDTH > EFX_MAX_CHANNELS);
 	queues = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_INT_Q);
+
+	/* Check to see if we have a serious error condition */
+	if (queues & (1U << efx->fatal_irq_level)) {
+		syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
+		if (unlikely(syserr))
+			return efx_nic_fatal_interrupt(efx);
+	}
+
 	EFX_ZERO_OWORD(*int_ker);
 	wmb(); /* Ensure the vector is cleared before interrupt ack */
 	falcon_irq_ack_a1(efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index cb018e2..70aea3a 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -672,6 +672,7 @@ union efx_multicast_hash {
  *	This register is written with the SMP processor ID whenever an
  *	interrupt is handled.  It is used by efx_nic_test_interrupt()
  *	to verify that an interrupt has occurred.
+ * @fatal_irq_level: IRQ level (bit number) used for serious errors
  * @spi_flash: SPI flash device
  *	This field will be %NULL if no flash device is present (or for Siena).
  * @spi_eeprom: SPI EEPROM device
@@ -756,6 +757,7 @@ struct efx_nic {
 	struct efx_buffer irq_status;
 	volatile signed int last_irq_cpu;
 	unsigned long irq_zero_count;
+	unsigned fatal_irq_level;
 
 	struct efx_spi_device *spi_flash;
 	struct efx_spi_device *spi_eeprom;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 664fd6c..23738f8 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1229,15 +1229,9 @@ static inline void efx_nic_interrupts(struct efx_nic *efx,
 				      bool enabled, bool force)
 {
 	efx_oword_t int_en_reg_ker;
-	unsigned int level = 0;
-
-	if (EFX_WORKAROUND_17213(efx) && !EFX_INT_MODE_USE_MSI(efx))
-		/* Set the level always even if we're generating a test
-		 * interrupt, because our legacy interrupt handler is safe */
-		level = 0x1f;
 
 	EFX_POPULATE_OWORD_3(int_en_reg_ker,
-			     FRF_AZ_KER_INT_LEVE_SEL, level,
+			     FRF_AZ_KER_INT_LEVE_SEL, efx->fatal_irq_level,
 			     FRF_AZ_KER_INT_KER, force,
 			     FRF_AZ_DRV_INT_EN_KER, enabled);
 	efx_writeo(efx, &int_en_reg_ker, FR_AZ_INT_EN_KER);
@@ -1291,8 +1285,6 @@ irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx)
 		EFX_OWORD_FMT ": %s\n", EFX_OWORD_VAL(*int_ker),
 		EFX_OWORD_VAL(fatal_intr),
 		error ? "disabling bus mastering" : "no recognised error");
-	if (error == 0)
-		goto out;
 
 	/* If this is a memory parity error dump which blocks are offending */
 	mem_perr = EFX_OWORD_FIELD(fatal_intr, FRF_AZ_MEM_PERR_INT_KER);
@@ -1324,7 +1316,7 @@ irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx)
 			"NIC will be disabled\n");
 		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
 	}
-out:
+
 	return IRQ_HANDLED;
 }
 
@@ -1346,9 +1338,11 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 	queues = EFX_EXTRACT_DWORD(reg, 0, 31);
 
 	/* Check to see if we have a serious error condition */
-	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
-	if (unlikely(syserr))
-		return efx_nic_fatal_interrupt(efx);
+	if (queues & (1U << efx->fatal_irq_level)) {
+		syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
+		if (unlikely(syserr))
+			return efx_nic_fatal_interrupt(efx);
+	}
 
 	if (queues != 0) {
 		if (EFX_WORKAROUND_15783(efx))
@@ -1413,9 +1407,11 @@ static irqreturn_t efx_msi_interrupt(int irq, void *dev_id)
 		  irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
 
 	/* Check to see if we have a serious error condition */
-	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
-	if (unlikely(syserr))
-		return efx_nic_fatal_interrupt(efx);
+	if (channel->channel == efx->fatal_irq_level) {
+		syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
+		if (unlikely(syserr))
+			return efx_nic_fatal_interrupt(efx);
+	}
 
 	/* Schedule processing of the channel */
 	efx_schedule_channel(channel);
@@ -1553,6 +1549,13 @@ void efx_nic_init_common(struct efx_nic *efx)
 			     FRF_AZ_INT_ADR_KER, efx->irq_status.dma_addr);
 	efx_writeo(efx, &temp, FR_AZ_INT_ADR_KER);
 
+	if (EFX_WORKAROUND_17213(efx) && !EFX_INT_MODE_USE_MSI(efx))
+		/* Use an interrupt level unused by event queues */
+		efx->fatal_irq_level = 0x1f;
+	else
+		/* Use a valid MSI-X vector */
+		efx->fatal_irq_level = 0;
+
 	/* Enable all the genuinely fatal interrupts.  (They are still
 	 * masked by the overall interrupt mask, controlled by
 	 * falcon_interrupts()).
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

