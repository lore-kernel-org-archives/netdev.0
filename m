From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/32] sfc: Remove redundant writes to INT_ADR_KER
Date: Sat, 28 Nov 2009 03:48:44 +0000
Message-ID: <1259380124.2811.32.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42583 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbZK1Dsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:48:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Hodgson <shodgson@solarflare.com>

This register only needs to be written after reset, not each time we
enable interrupts.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b2509fc..5bbe842 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1290,19 +1290,11 @@ static inline void falcon_interrupts(struct efx_nic *efx, int enabled,
 
 void falcon_enable_interrupts(struct efx_nic *efx)
 {
-	efx_oword_t int_adr_reg_ker;
 	struct efx_channel *channel;
 
 	EFX_ZERO_OWORD(*((efx_oword_t *) efx->irq_status.addr));
 	wmb(); /* Ensure interrupt vector is clear before interrupts enabled */
 
-	/* Program address */
-	EFX_POPULATE_OWORD_2(int_adr_reg_ker,
-			     FRF_AZ_NORM_INT_VEC_DIS_KER,
-			     EFX_INT_MODE_USE_MSI(efx),
-			     FRF_AZ_INT_ADR_KER, efx->irq_status.dma_addr);
-	efx_writeo(efx, &int_adr_reg_ker, FR_AZ_INT_ADR_KER);
-
 	/* Enable interrupts */
 	falcon_interrupts(efx, 1, 0);
 
@@ -3061,6 +3053,13 @@ int falcon_init_nic(struct efx_nic *efx)
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_RX_DC_PF_LWM, RX_DC_ENTRIES - 8);
 	efx_writeo(efx, &temp, FR_AZ_RX_DC_PF_WM);
 
+	/* Program INT_KER address */
+	EFX_POPULATE_OWORD_2(temp,
+			     FRF_AZ_NORM_INT_VEC_DIS_KER,
+			     EFX_INT_MODE_USE_MSI(efx),
+			     FRF_AZ_INT_ADR_KER, efx->irq_status.dma_addr);
+	efx_writeo(efx, &temp, FR_AZ_INT_ADR_KER);
+
 	/* Clear the parity enables on the TX data fifos as
 	 * they produce false parity errors because of timing issues
 	 */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

