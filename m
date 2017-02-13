From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: only fall back to a lower interrupt mode if
 it is supported
Date: Mon, 13 Feb 2017 14:59:04 +0000
Message-ID: <f85fa956-eb21-4c09-ea20-8ac908df3c57@solarflare.com>
References: <2af4ea1f-cdf7-48b2-1712-e25590919f15@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:54107 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751850AbdBMO7L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:59:11 -0500
In-Reply-To: <2af4ea1f-cdf7-48b2-1712-e25590919f15@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

If we fail to probe interrupts with our minimum mode, return that error.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 88a9f97..8c4c273 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1420,9 +1420,12 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 					   xentries, 1, n_channels);
 		if (rc < 0) {
 			/* Fall back to single channel MSI */
-			efx->interrupt_mode = EFX_INT_MODE_MSI;
 			netif_err(efx, drv, efx->net_dev,
 				  "could not enable MSI-X\n");
+			if (efx->type->min_interrupt_mode >= EFX_INT_MODE_MSI)
+				efx->interrupt_mode = EFX_INT_MODE_MSI;
+			else
+				return rc;
 		} else if (rc < n_channels) {
 			netif_err(efx, drv, efx->net_dev,
 				  "WARNING: Insufficient MSI-X vectors"
@@ -1465,7 +1468,10 @@ static int efx_probe_interrupts(struct efx_nic *efx)
 		} else {
 			netif_err(efx, drv, efx->net_dev,
 				  "could not enable MSI\n");
-			efx->interrupt_mode = EFX_INT_MODE_LEGACY;
+			if (efx->type->min_interrupt_mode >= EFX_INT_MODE_LEGACY)
+				efx->interrupt_mode = EFX_INT_MODE_LEGACY;
+			else
+				return rc;
 		}
 	}
 
