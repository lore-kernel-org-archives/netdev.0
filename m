From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 7/9] sfc: Stop masking out XGMII faults over
 reconfigures
Date: Fri, 23 Apr 2010 23:27:42 +0100
Message-ID: <1272061662.5520.20.camel@achroite.uk.solarflarecom.com>
References: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46366 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494Ab0DWW1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:27:45 -0400
In-Reply-To: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

The aim of this code was to avoid a spurious XGMII fault over a MAC
reconfigure. It's less relevant now that the PHY reconfigure isn't
called from the MAC reconfigure.

After applying this patch, our link stress test passed 48 hours of
testing without ever resetting the PHY.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_xmac.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 8ccab2c..3d65abf 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -85,14 +85,14 @@ int falcon_reset_xaui(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }
 
-static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
+static void falcon_ack_status_intr(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 
 	if ((efx_nic_rev(efx) != EFX_REV_FALCON_B0) || LOOPBACK_INTERNAL(efx))
 		return;
 
-	/* We expect xgmii faults if the wireside link is up */
+	/* We expect xgmii faults if the wireside link is down */
 	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up)
 		return;
 
@@ -101,14 +101,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 	if (efx->xmac_poll_required)
 		return;
 
-	/* Flush the ISR */
-	if (enable)
-		efx_reado(efx, &reg, FR_AB_XM_MGT_INT_MSK);
-
-	EFX_POPULATE_OWORD_2(reg,
-			     FRF_AB_XM_MSK_RMTFLT, !enable,
-			     FRF_AB_XM_MSK_LCLFLT, !enable);
-	efx_writeo(efx, &reg, FR_AB_XM_MGT_INT_MASK);
+	efx_reado(efx, &reg, FR_AB_XM_MGT_INT_MSK);
 }
 
 static bool falcon_xgxs_link_ok(struct efx_nic *efx)
@@ -283,15 +276,13 @@ static bool falcon_xmac_check_fault(struct efx_nic *efx)
 
 static int falcon_reconfigure_xmac(struct efx_nic *efx)
 {
-	falcon_mask_status_intr(efx, false);
-
 	falcon_reconfigure_xgxs_core(efx);
 	falcon_reconfigure_xmac_core(efx);
 
 	falcon_reconfigure_mac_wrapper(efx);
 
 	efx->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 5);
-	falcon_mask_status_intr(efx, true);
+	falcon_ack_status_intr(efx);
 
 	return 0;
 }
@@ -362,9 +353,8 @@ void falcon_poll_xmac(struct efx_nic *efx)
 	    !efx->xmac_poll_required)
 		return;
 
-	falcon_mask_status_intr(efx, false);
 	efx->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 1);
-	falcon_mask_status_intr(efx, true);
+	falcon_ack_status_intr(efx);
 }
 
 struct efx_mac_operations falcon_xmac_operations = {
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

