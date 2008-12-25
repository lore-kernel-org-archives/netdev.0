From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/8] sfc: Fix unreliable link detection in some loopback
	modes
Date: Thu, 25 Dec 2008 03:38:57 +0000
Message-ID: <1230176337.3401.41.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3908 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751515AbYLYDjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:39:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Loopback self-tests are flaky on the SFT9001 without this.

Ben.

 drivers/net/sfc/mdio_10g.c  |   22 +++++++++++++---------
 drivers/net/sfc/mdio_10g.h  |    4 ++++
 drivers/net/sfc/tenxpress.c |   11 +++++++----
 3 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 037601e..f131ad2 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -167,7 +167,7 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 {
 	int phy_id = efx->mii.phy_id;
-	int status;
+	u32 reg;
 	bool ok = true;
 	int mmd = 0;
 
@@ -179,12 +179,17 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 		return false;
 	else if (efx_phy_mode_disabled(efx->phy_mode))
 		return false;
-	else if (efx->loopback_mode == LOOPBACK_PHYXS)
+	else if (efx->loopback_mode == LOOPBACK_PHYXS) {
 		mmd_mask &= ~(MDIO_MMDREG_DEVS_PHYXS |
 			      MDIO_MMDREG_DEVS_PCS |
 			      MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
-	else if (efx->loopback_mode == LOOPBACK_PCS)
+		if (!mmd_mask) {
+			reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
+						 MDIO_PHYXS_STATUS2);
+			return !(reg & (1 << MDIO_PHYXS_STATUS2_RX_FAULT_LBN));
+		}
+	} else if (efx->loopback_mode == LOOPBACK_PCS)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS_PCS |
 			      MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
@@ -196,12 +201,11 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 		if (mmd_mask & 1) {
 			/* Double reads because link state is latched, and a
 			 * read moves the current state into the register */
-			status = mdio_clause45_read(efx, phy_id,
-						    mmd, MDIO_MMDREG_STAT1);
-			status = mdio_clause45_read(efx, phy_id,
-						    mmd, MDIO_MMDREG_STAT1);
-
-			ok = ok && (status & (1 << MDIO_MMDREG_STAT1_LINK_LBN));
+			reg = mdio_clause45_read(efx, phy_id,
+						 mmd, MDIO_MMDREG_STAT1);
+			reg = mdio_clause45_read(efx, phy_id,
+						 mmd, MDIO_MMDREG_STAT1);
+			ok = ok && (reg & (1 << MDIO_MMDREG_STAT1_LINK_LBN));
 		}
 		mmd_mask = (mmd_mask >> 1);
 		mmd++;
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 4091182..09bf801 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -133,6 +133,10 @@
 #define MDIO_PMAPMD_10GBT_TXPWR_SHORT_LBN (0)
 #define MDIO_PMAPMD_10GBT_TXPWR_SHORT_WIDTH (1)
 
+/* PHY XGXS Status 2 */
+#define MDIO_PHYXS_STATUS2              (8)
+#define MDIO_PHYXS_STATUS2_RX_FAULT_LBN 10
+
 /* PHY XGXS lane state */
 #define MDIO_PHYXS_LANE_STATE		(0x18)
 #define MDIO_PHYXS_LANE_ALIGNED_LBN	(12)
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index b3ca2dc..1567ab5 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -445,14 +445,13 @@ static bool sft9001_link_ok(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	int phy_id = efx->mii.phy_id;
 	u32 reg;
 
-	if (efx->loopback_mode == LOOPBACK_GPHY)
-		return true;
-	else if (efx_phy_mode_disabled(efx->phy_mode))
+	if (efx_phy_mode_disabled(efx->phy_mode))
 		return false;
+	else if (efx->loopback_mode == LOOPBACK_GPHY)
+		return true;
 	else if (efx->loopback_mode)
 		return mdio_clause45_links_ok(efx,
 					      MDIO_MMDREG_DEVS_PMAPMD |
-					      MDIO_MMDREG_DEVS_PCS |
 					      MDIO_MMDREG_DEVS_PHYXS);
 
 	/* We must use the same definition of link state as LASI,
@@ -588,6 +587,10 @@ static void tenxpress_phy_poll(struct efx_nic *efx)
 				change = true;
 		}
 		sfx7101_check_bad_lp(efx, link_ok);
+	} else if (efx->loopback_mode) {
+		bool link_ok = sft9001_link_ok(efx, NULL);
+		if (link_ok != efx->link_up)
+			change = true;
 	} else {
 		u32 status = mdio_clause45_read(efx, efx->mii.phy_id,
 						MDIO_MMD_PMAPMD,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
