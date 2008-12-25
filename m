From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 8/8] sfc: If AN is enabled, always read speed/duplex from
	the AN advertising bits
Date: Thu, 25 Dec 2008 03:43:33 +0000
Message-ID: <1230176613.3401.54.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:4340 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751481AbYLYDnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:43:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When AN is enabled and the link is down the speed/duplex control bits
will not be meaningful.  Use the advertising bits instead, and mask
them with the LPA bits if and only if AN is complete (as before).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index f131ad2..f6a1642 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -368,13 +368,16 @@ void mdio_clause45_get_settings_ext(struct efx_nic *efx,
 	} else
 		ecmd->autoneg = AUTONEG_DISABLE;
 
-	/* If AN is enabled and complete, report best common mode */
-	if (ecmd->autoneg &&
-	    (mdio_clause45_read(efx, phy_id, MDIO_MMD_AN, MDIO_MMDREG_STAT1) &
-	     (1 << MDIO_AN_STATUS_AN_DONE_LBN))) {
-		u32 common, lpa;
-		lpa = mdio_clause45_get_an(efx, MDIO_AN_LPA, xnp_lpa);
-		common = ecmd->advertising & lpa;
+	if (ecmd->autoneg) {
+		/* If AN is complete, report best common mode,
+		 * otherwise report best advertised mode. */
+		u32 common = ecmd->advertising;
+		if (mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+				       MDIO_MMDREG_STAT1) &
+		    (1 << MDIO_AN_STATUS_AN_DONE_LBN)) {
+			common &= mdio_clause45_get_an(efx, MDIO_AN_LPA,
+						       xnp_lpa);
+		}
 		if (common & ADVERTISED_10000baseT_Full) {
 			ecmd->speed = SPEED_10000;
 			ecmd->duplex = DUPLEX_FULL;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
