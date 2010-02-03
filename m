From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/10] sfc: Enable autonegotiated flow-control by default
 if supported
Date: Wed, 03 Feb 2010 19:30:38 +0000
Message-ID: <1265225438.2116.3.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27995 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757136Ab0BCTal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:30:41 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c   |    2 ++
 drivers/net/sfc/mcdi_phy.c |   14 +++++++++++++-
 drivers/net/sfc/siena.c    |    7 +------
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9d009c4..1e78585 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -909,6 +909,8 @@ static int falcon_probe_port(struct efx_nic *efx)
 		efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
 	else
 		efx->wanted_fc = EFX_FC_RX;
+	if (efx->mdio.mmds & MDIO_DEVS_AN)
+		efx->wanted_fc |= EFX_FC_AUTO;
 
 	/* Allocate buffer for stats */
 	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index eb694af..d87e74d 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -381,6 +381,18 @@ static int efx_mcdi_phy_probe(struct efx_nic *efx)
 	 * but by convention we don't */
 	efx->loopback_modes &= ~(1 << LOOPBACK_NONE);
 
+	/* Set the initial link mode */
+	efx_mcdi_phy_decode_link(
+		efx, &efx->link_state,
+		MCDI_DWORD(outbuf, GET_LINK_OUT_LINK_SPEED),
+		MCDI_DWORD(outbuf, GET_LINK_OUT_FLAGS),
+		MCDI_DWORD(outbuf, GET_LINK_OUT_FCNTL));
+
+	/* Default to Autonegotiated flow control if the PHY supports it */
+	efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
+	if (phy_data->supported_cap & (1 << MC_CMD_PHY_CAP_AN_LBN))
+		efx->wanted_fc |= EFX_FC_AUTO;
+
 	return 0;
 
 fail:
@@ -436,7 +448,7 @@ void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa)
 
 	/* The link partner capabilities are only relevent if the
 	 * link supports flow control autonegotiation */
-	if (~phy_cfg->supported_cap & (1 << MC_CMD_PHY_CAP_ASYM_LBN))
+	if (~phy_cfg->supported_cap & (1 << MC_CMD_PHY_CAP_AN_LBN))
 		return;
 
 	/* If flow control autoneg is supported and enabled, then fine */
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 0e4c13a..f6a5389 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -106,16 +106,11 @@ static int siena_probe_port(struct efx_nic *efx)
 	efx->mdio.mdio_read = siena_mdio_read;
 	efx->mdio.mdio_write = siena_mdio_write;
 
-	/* Fill out MDIO structure and loopback modes */
+	/* Fill out MDIO structure, loopback modes, and initial link state */
 	rc = efx->phy_op->probe(efx);
 	if (rc != 0)
 		return rc;
 
-	/* Initial assumption */
-	efx->link_state.speed = 10000;
-	efx->link_state.fd = true;
-	efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
-
 	/* Allocate buffer for stats */
 	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
 				  MC_CMD_MAC_NSTATS * sizeof(u64));
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

