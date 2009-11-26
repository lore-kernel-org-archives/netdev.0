From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/16] sfc: Only switch Falcon MAC clocks as necessary
Date: Thu, 26 Nov 2009 02:11:03 +0000
Message-ID: <1259201463.2806.21.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31273 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbZKZCLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:11:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   42 +++++++++++++++++++++++++-----------------
 1 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e1b9ce3..9eec885 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2183,11 +2183,29 @@ static int falcon_mdio_read(struct net_device *net_dev,
 	return rc;
 }
 
+static void falcon_clock_mac(struct efx_nic *efx)
+{
+	unsigned strap_val;
+	efx_oword_t nic_stat;
+
+	/* Configure the NIC generated MAC clock correctly */
+	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
+	strap_val = EFX_IS10G(efx) ? 5 : 3;
+	if (falcon_rev(efx) >= FALCON_REV_B0) {
+		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP_EN, 1);
+		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP, strap_val);
+		efx_writeo(efx, &nic_stat, FR_AB_NIC_STAT);
+	} else {
+		/* Falcon A1 does not support 1G/10G speed switching
+		 * and must not be used with a PHY that does. */
+		BUG_ON(EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_PINS) !=
+		       strap_val);
+	}
+}
+
 int falcon_switch_mac(struct efx_nic *efx)
 {
 	struct efx_mac_operations *old_mac_op = efx->mac_op;
-	efx_oword_t nic_stat;
-	unsigned strap_val;
 	int rc = 0;
 
 	/* Don't try to fetch MAC stats while we're switching MACs */
@@ -2206,24 +2224,11 @@ int falcon_switch_mac(struct efx_nic *efx)
 	efx->mac_op = (EFX_IS10G(efx) ?
 		       &falcon_xmac_operations : &falcon_gmac_operations);
 
-	/* Always push the NIC_STAT_REG setting even if the mac hasn't
-	 * changed, because this function is run post online reset */
-	efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
-	strap_val = EFX_IS10G(efx) ? 5 : 3;
-	if (falcon_rev(efx) >= FALCON_REV_B0) {
-		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP_EN, 1);
-		EFX_SET_OWORD_FIELD(nic_stat, FRF_BB_EE_STRAP, strap_val);
-		efx_writeo(efx, &nic_stat, FR_AB_NIC_STAT);
-	} else {
-		/* Falcon A1 does not support 1G/10G speed switching
-		 * and must not be used with a PHY that does. */
-		BUG_ON(EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_PINS) !=
-		       strap_val);
-	}
-
 	if (old_mac_op == efx->mac_op)
 		goto out;
 
+	falcon_clock_mac(efx);
+
 	EFX_LOG(efx, "selected %cMAC\n", EFX_IS10G(efx) ? 'X' : 'G');
 	/* Not all macs support a mac-level link state */
 	efx->mac_up = true;
@@ -2982,6 +2987,9 @@ int falcon_init_nic(struct efx_nic *efx)
 		efx_writeo(efx, &temp, FR_AB_GPIO_CTL);
 	}
 
+	/* Select the correct MAC */
+	falcon_clock_mac(efx);
+
 	rc = falcon_reset_sram(efx);
 	if (rc)
 		return rc;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

