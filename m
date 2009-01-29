From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/20] sfc: SFT9001: Fix speed reporting in 1G PHY loopback
Date: Thu, 29 Jan 2009 19:17:51 +0000
Message-ID: <1233256671.3656.23.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:53484 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753117AbZA2TRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:17:53 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of disabling AN in loopback, just prevent restarting AN and
override the speed in sft9001_get_settings().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c    |    4 ++++
 drivers/net/sfc/tenxpress.c   |   27 +++++++++------------------
 drivers/net/sfc/workarounds.h |    5 +++++
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 4d54010..3303628 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -15,6 +15,7 @@
 #include "net_driver.h"
 #include "mdio_10g.h"
 #include "boards.h"
+#include "workarounds.h"
 
 int mdio_clause45_reset_mmd(struct efx_nic *port, int mmd,
 			    int spins, int spintime)
@@ -518,6 +519,9 @@ int mdio_clause45_set_settings(struct efx_nic *efx,
 			reg |= BMCR_ANENABLE | BMCR_ANRESTART;
 		else
 			reg &= ~BMCR_ANENABLE;
+		if (EFX_WORKAROUND_15195(efx)
+		    && LOOPBACK_MASK(efx) & efx->phy_op->loopbacks)
+			reg &= ~BMCR_ANRESTART;
 		if (xnp)
 			reg |= 1 << MDIO_AN_CTRL_XNP_LBN;
 		else
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 9e0b755..ec3e38b 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -531,7 +531,7 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
 	struct ethtool_cmd ecmd;
-	bool phy_mode_change, loop_reset, loop_toggle, loopback;
+	bool phy_mode_change, loop_reset;
 
 	if (efx->phy_mode & (PHY_MODE_OFF | PHY_MODE_SPECIAL)) {
 		phy_data->phy_mode = efx->phy_mode;
@@ -542,12 +542,10 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 
 	phy_mode_change = (efx->phy_mode == PHY_MODE_NORMAL &&
 			   phy_data->phy_mode != PHY_MODE_NORMAL);
-	loopback = LOOPBACK_MASK(efx) & efx->phy_op->loopbacks;
-	loop_toggle = LOOPBACK_CHANGED(phy_data, efx, efx->phy_op->loopbacks);
 	loop_reset = (LOOPBACK_OUT_OF(phy_data, efx, efx->phy_op->loopbacks) ||
 		      LOOPBACK_CHANGED(phy_data, efx, 1 << LOOPBACK_GPHY));
 
-	if (loop_reset || loop_toggle || loopback || phy_mode_change) {
+	if (loop_reset || phy_mode_change) {
 		int rc;
 
 		efx->phy_op->get_settings(efx, &ecmd);
@@ -562,20 +560,6 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 				falcon_reset_xaui(efx);
 		}
 
-		if (efx->phy_type != PHY_TYPE_SFX7101) {
-			/* Only change autoneg once, on coming out or
-			 * going into loopback */
-			if (loop_toggle)
-				ecmd.autoneg = !loopback;
-			if (loopback) {
-				ecmd.duplex = DUPLEX_FULL;
-				if (efx->loopback_mode == LOOPBACK_GPHY)
-					ecmd.speed = SPEED_1000;
-				else
-					ecmd.speed = SPEED_10000;
-			}
-		}
-
 		rc = efx->phy_op->set_settings(efx, &ecmd);
 		WARN_ON(rc);
 	}
@@ -836,6 +820,13 @@ static void sft9001_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 		ecmd->duplex = (reg & (1 << GPHY_DUPLEX_LBN) ?
 				DUPLEX_FULL : DUPLEX_HALF);
 	}
+
+	/* In loopback, the PHY automatically brings up the correct interface,
+	 * but doesn't advertise the correct speed. So override it */
+	if (efx->loopback_mode == LOOPBACK_GPHY)
+		ecmd->speed = SPEED_1000;
+	else if (LOOPBACK_MASK(efx) & SFT9001_LOOPBACKS)
+		ecmd->speed = SPEED_10000;
 }
 
 static int sft9001_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 797a0cf..420fe15 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -19,6 +19,8 @@
 #define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
 #define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
 #define EFX_WORKAROUND_SFT9001A(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A)
+#define EFX_WORKAROUND_SFT9001(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A || \
+				     (efx)->phy_type == PHY_TYPE_SFT9001B)
 
 /* XAUI resets if link not detected */
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
@@ -56,4 +58,7 @@
 /* Need to keep AN enabled */
 #define EFX_WORKAROUND_13963 EFX_WORKAROUND_SFT9001A
 
+/* Don't restart AN in near-side loopback */
+#define EFX_WORKAROUND_15195 EFX_WORKAROUND_SFT9001
+
 #endif /* EFX_WORKAROUNDS_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

