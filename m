From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/11] sfc: SFT9001: Fix speed reporting in 1G PHY loopback
Date: Fri, 30 Jan 2009 03:49:09 +0000
Message-ID: <20090130034908.GE15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:56051 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753490AbZA3DtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:49:16 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Instead of disabling AN in loopback, just prevent restarting AN and
override the speed in sft9001_get_settings().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c    |    4 ++++
 drivers/net/sfc/tenxpress.c   |   27 +++++++++------------------
 drivers/net/sfc/workarounds.h |    5 +++++
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index f6a1642..7f09ab5 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -15,6 +15,7 @@
 #include "net_driver.h"
 #include "mdio_10g.h"
 #include "boards.h"
+#include "workarounds.h"
 
 int mdio_clause45_reset_mmd(struct efx_nic *port, int mmd,
 			    int spins, int spintime)
@@ -517,6 +518,9 @@ int mdio_clause45_set_settings(struct efx_nic *efx,
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
index 80c8d6e..bc2833f 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -511,7 +511,7 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
 	struct ethtool_cmd ecmd;
-	bool phy_mode_change, loop_reset, loop_toggle, loopback;
+	bool phy_mode_change, loop_reset;
 
 	if (efx->phy_mode & (PHY_MODE_OFF | PHY_MODE_SPECIAL)) {
 		phy_data->phy_mode = efx->phy_mode;
@@ -522,12 +522,10 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 
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
@@ -542,20 +540,6 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
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
@@ -813,6 +797,13 @@ static void sft9001_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
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
