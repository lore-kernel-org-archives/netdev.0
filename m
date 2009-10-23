From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 21/27] sfc: Merge falcon_probe_phy() into
	falcon_probe_port()
Date: Fri, 23 Oct 2009 19:32:42 +0100
Message-ID: <1256322762.2785.45.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8905 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbZJWScl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:32:41 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAC and PHY probing are bound up together, as evidenced by the
initialisation of efx_nic::loopback_modes.  Remove the current
arbitrary separation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   60 +++++++++++++++++++--------------------------
 1 files changed, 25 insertions(+), 35 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ade2792..d9ce21e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2173,37 +2173,6 @@ static int falcon_mdio_read(struct net_device *net_dev,
 	return rc;
 }
 
-static int falcon_probe_phy(struct efx_nic *efx)
-{
-	switch (efx->phy_type) {
-	case PHY_TYPE_SFX7101:
-		efx->phy_op = &falcon_sfx7101_phy_ops;
-		break;
-	case PHY_TYPE_SFT9001A:
-	case PHY_TYPE_SFT9001B:
-		efx->phy_op = &falcon_sft9001_phy_ops;
-		break;
-	case PHY_TYPE_QT2022C2:
-	case PHY_TYPE_QT2025C:
-		efx->phy_op = &falcon_xfp_phy_ops;
-		break;
-	default:
-		EFX_ERR(efx, "Unknown PHY type %d\n",
-			efx->phy_type);
-		return -1;
-	}
-
-	if (efx->phy_op->macs & EFX_XMAC)
-		efx->loopback_modes |= ((1 << LOOPBACK_XGMII) |
-					(1 << LOOPBACK_XGXS) |
-					(1 << LOOPBACK_XAUI));
-	if (efx->phy_op->macs & EFX_GMAC)
-		efx->loopback_modes |= (1 << LOOPBACK_GMAC);
-	efx->loopback_modes |= efx->phy_op->loopbacks;
-
-	return 0;
-}
-
 int falcon_switch_mac(struct efx_nic *efx)
 {
 	struct efx_mac_operations *old_mac_op = efx->mac_op;
@@ -2260,10 +2229,31 @@ int falcon_probe_port(struct efx_nic *efx)
 {
 	int rc;
 
-	/* Hook in PHY operations table */
-	rc = falcon_probe_phy(efx);
-	if (rc)
-		return rc;
+	switch (efx->phy_type) {
+	case PHY_TYPE_SFX7101:
+		efx->phy_op = &falcon_sfx7101_phy_ops;
+		break;
+	case PHY_TYPE_SFT9001A:
+	case PHY_TYPE_SFT9001B:
+		efx->phy_op = &falcon_sft9001_phy_ops;
+		break;
+	case PHY_TYPE_QT2022C2:
+	case PHY_TYPE_QT2025C:
+		efx->phy_op = &falcon_xfp_phy_ops;
+		break;
+	default:
+		EFX_ERR(efx, "Unknown PHY type %d\n",
+			efx->phy_type);
+		return -ENODEV;
+	}
+
+	if (efx->phy_op->macs & EFX_XMAC)
+		efx->loopback_modes |= ((1 << LOOPBACK_XGMII) |
+					(1 << LOOPBACK_XGXS) |
+					(1 << LOOPBACK_XAUI));
+	if (efx->phy_op->macs & EFX_GMAC)
+		efx->loopback_modes |= (1 << LOOPBACK_GMAC);
+	efx->loopback_modes |= efx->phy_op->loopbacks;
 
 	/* Set up MDIO structure for PHY */
 	efx->mdio.mmds = efx->phy_op->mmds;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

