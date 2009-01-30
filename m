From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/11] sfc: Test for PHYXS faults whenever we cannot test link state bits
Date: Fri, 30 Jan 2009 03:51:15 +0000
Message-ID: <20090130035115.GI15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:34945 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441AbZA3DvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:51:17 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Depending on the loopback mode, there may be no pertinent link state
bits.  In this case we test the PHYXS RX fault bit instead.  Make
sure to do this in all cases where there are no link state bits.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 7f09ab5..16bc585 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -180,17 +180,12 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 		return false;
 	else if (efx_phy_mode_disabled(efx->phy_mode))
 		return false;
-	else if (efx->loopback_mode == LOOPBACK_PHYXS) {
+	else if (efx->loopback_mode == LOOPBACK_PHYXS)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS_PHYXS |
 			      MDIO_MMDREG_DEVS_PCS |
 			      MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
-		if (!mmd_mask) {
-			reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
-						 MDIO_PHYXS_STATUS2);
-			return !(reg & (1 << MDIO_PHYXS_STATUS2_RX_FAULT_LBN));
-		}
-	} else if (efx->loopback_mode == LOOPBACK_PCS)
+	else if (efx->loopback_mode == LOOPBACK_PCS)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS_PCS |
 			      MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
@@ -198,6 +193,13 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
 
+	if (!mmd_mask) {
+		/* Use presence of XGMII faults in leui of link state */
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
+					 MDIO_PHYXS_STATUS2);
+		return !(reg & (1 << MDIO_PHYXS_STATUS2_RX_FAULT_LBN));
+	}
+
 	while (mmd_mask) {
 		if (mmd_mask & 1) {
 			/* Double reads because link state is latched, and a

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
