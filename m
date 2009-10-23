From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 25/27] sfc: Merge efx_fc_resolve() into efx_mdio_get_pause()
Date: Fri, 23 Oct 2009 19:33:17 +0100
Message-ID: <1256322797.2785.53.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8982 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbZJWSdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:33:15 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_fc_resolve() is specific to MDIO and is not used by any other
function.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c   |   12 ++++++++----
 drivers/net/sfc/net_driver.h |   11 -----------
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index b355872..25fb20a 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -341,10 +341,14 @@ int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 
 enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx)
 {
-	int lpa;
+	BUILD_BUG_ON(EFX_FC_AUTO & (EFX_FC_RX | EFX_FC_TX));
 
-	if (!(efx->phy_op->mmds & MDIO_DEVS_AN))
+	if (!(efx->wanted_fc & EFX_FC_AUTO))
 		return efx->wanted_fc;
-	lpa = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_LPA);
-	return efx_fc_resolve(efx->wanted_fc, lpa);
+
+	WARN_ON(!(efx->mdio.mmds & MDIO_DEVS_AN));
+
+	return mii_resolve_flowctrl_fdx(
+		mii_advertise_flowctrl(efx->wanted_fc),
+		efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_LPA));
 }
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 13bc1b4..bb3d258 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -497,17 +497,6 @@ enum efx_mac_type {
 	EFX_XMAC = 2,
 };
 
-static inline enum efx_fc_type efx_fc_resolve(enum efx_fc_type wanted_fc,
-					      unsigned int lpa)
-{
-	BUILD_BUG_ON(EFX_FC_AUTO & (EFX_FC_RX | EFX_FC_TX));
-
-	if (!(wanted_fc & EFX_FC_AUTO))
-		return wanted_fc;
-
-	return mii_resolve_flowctrl_fdx(mii_advertise_flowctrl(wanted_fc), lpa);
-}
-
 /**
  * struct efx_mac_operations - Efx MAC operations table
  * @reconfigure: Reconfigure MAC. Serialised by the mac_lock

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

