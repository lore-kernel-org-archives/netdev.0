From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 18/33] sfc: Clean up MDIO flag setting
Date: Fri, 12 Dec 2008 12:54:34 +0000
Message-ID: <20081212125433.GR10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:40641 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757336AbYLLMyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:54:36 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We often want to set or clear a flag in an MDIO register, but avoid
writing if no change is required since this can have side-effects.
Encapsulate this in a function, mdio_clause45_set_flag().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c |   87 ++++++++++++++------------------------------
 drivers/net/sfc/mdio_10g.h |    4 ++
 2 files changed, 32 insertions(+), 59 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 1eed484..8d91131 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -205,61 +205,24 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 
 void mdio_clause45_transmit_disable(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
-	int ctrl1, ctrl2;
-
-	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-					   MDIO_MMDREG_TXDIS);
-	if (efx->phy_mode & PHY_MODE_TX_DISABLED)
-		ctrl2 |= (1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
-	else
-		ctrl1 &= ~(1 << MDIO_MMDREG_TXDIS_GLOBAL_LBN);
-	if (ctrl1 != ctrl2)
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-				    MDIO_MMDREG_TXDIS, ctrl2);
+	mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			       MDIO_MMDREG_TXDIS, MDIO_MMDREG_TXDIS_GLOBAL_LBN,
+			       efx->phy_mode & PHY_MODE_TX_DISABLED);
 }
 
 void mdio_clause45_phy_reconfigure(struct efx_nic *efx)
 {
 	int phy_id = efx->mii.phy_id;
-	int ctrl1, ctrl2;
-
-	/* Handle (with debouncing) PMA/PMD loopback */
-	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-					   MDIO_MMDREG_CTRL1);
-
-	if (efx->loopback_mode == LOOPBACK_PMAPMD)
-		ctrl2 |= (1 << MDIO_PMAPMD_CTRL1_LBACK_LBN);
-	else
-		ctrl2 &= ~(1 << MDIO_PMAPMD_CTRL1_LBACK_LBN);
-
-	if (ctrl1 != ctrl2)
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-				    MDIO_MMDREG_CTRL1, ctrl2);
-
-	/* Handle (with debouncing) PCS loopback */
-	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
-					   MDIO_MMDREG_CTRL1);
-	if (efx->loopback_mode == LOOPBACK_PCS)
-		ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
-	else
-		ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
 
-	if (ctrl1 != ctrl2)
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PCS,
-				    MDIO_MMDREG_CTRL1, ctrl2);
-
-	/* Handle (with debouncing) PHYXS network loopback */
-	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
-					   MDIO_MMDREG_CTRL1);
-	if (efx->loopback_mode == LOOPBACK_NETWORK)
-		ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
-	else
-		ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LBACK_LBN);
-
-	if (ctrl1 != ctrl2)
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PHYXS,
-				    MDIO_MMDREG_CTRL1, ctrl2);
+	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PMAPMD,
+			       MDIO_MMDREG_CTRL1, MDIO_PMAPMD_CTRL1_LBACK_LBN,
+			       efx->loopback_mode == LOOPBACK_PMAPMD);
+	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PCS,
+			       MDIO_MMDREG_CTRL1, MDIO_MMDREG_CTRL1_LBACK_LBN,
+			       efx->loopback_mode == LOOPBACK_PCS);
+	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PHYXS,
+			       MDIO_MMDREG_CTRL1, MDIO_MMDREG_CTRL1_LBACK_LBN,
+			       efx->loopback_mode == LOOPBACK_NETWORK);
 }
 
 static void mdio_clause45_set_mmd_lpower(struct efx_nic *efx,
@@ -267,21 +230,13 @@ static void mdio_clause45_set_mmd_lpower(struct efx_nic *efx,
 {
 	int phy = efx->mii.phy_id;
 	int stat = mdio_clause45_read(efx, phy, mmd, MDIO_MMDREG_STAT1);
-	int ctrl1, ctrl2;
 
 	EFX_TRACE(efx, "Setting low power mode for MMD %d to %d\n",
 		  mmd, lpower);
 
 	if (stat & (1 << MDIO_MMDREG_STAT1_LPABLE_LBN)) {
-		ctrl1 = ctrl2 = mdio_clause45_read(efx, phy,
-						   mmd, MDIO_MMDREG_CTRL1);
-		if (lpower)
-			ctrl2 |= (1 << MDIO_MMDREG_CTRL1_LPOWER_LBN);
-		else
-			ctrl2 &= ~(1 << MDIO_MMDREG_CTRL1_LPOWER_LBN);
-		if (ctrl1 != ctrl2)
-			mdio_clause45_write(efx, phy, mmd,
-					    MDIO_MMDREG_CTRL1, ctrl2);
+		mdio_clause45_set_flag(efx, phy, mmd, MDIO_MMDREG_CTRL1,
+				       MDIO_MMDREG_CTRL1_LPOWER_LBN, lpower);
 	}
 }
 
@@ -395,3 +350,17 @@ int mdio_clause45_set_settings(struct efx_nic *efx,
 		return 0;
 	return -EOPNOTSUPP;
 }
+
+void mdio_clause45_set_flag(struct efx_nic *efx, u8 prt, u8 dev,
+			    u16 addr, int bit, bool sense)
+{
+	int old_val = mdio_clause45_read(efx, prt, dev, addr);
+	int new_val;
+
+	if (sense)
+		new_val = old_val | (1 << bit);
+	else
+		new_val = old_val & ~(1 << bit);
+	if (old_val != new_val)
+		mdio_clause45_write(efx, prt, dev, addr, new_val);
+}
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 4516383..4830e0c 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -259,4 +259,8 @@ extern int mdio_clause45_set_settings(struct efx_nic *efx,
 extern int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
 					 unsigned int mmd_mask);
 
+/* Set or clear flag, debouncing */
+extern void mdio_clause45_set_flag(struct efx_nic *efx, u8 prt, u8 dev,
+				   u16 addr, int bit, bool sense);
+
 #endif /* EFX_MDIO_10G_H */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
