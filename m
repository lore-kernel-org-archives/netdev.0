From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 44/52] sfc: Serialise tenxpress_special_reset() with statistics fetches
Date: Mon, 1 Sep 2008 12:49:25 +0100
Message-ID: <20080901114924.GK7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:33039 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759096AbYIALt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:28 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some boards 10Xpress feeds a 156 MHz clock to the Falcon XMAC.  MAC
statistics DMA can fail while this clock is stopped during a PHY reset.

From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 77e7f3a..2ad3d8d 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -214,7 +214,10 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 {
 	int rc, reg;
 
-	EFX_TRACE(efx, "%s\n", __func__);
+	/* The XGMAC clock is driven from the SFC7101/SFT9001 312MHz clock, so
+	 * a special software reset can glitch the XGMAC sufficiently for stats
+	 * requests to fail. Since we don't ofen special_reset, just lock. */
+	spin_lock(&efx->stats_lock);
 
 	/* Initiate reset */
 	reg = mdio_clause45_read(efx, efx->mii.phy_id,
@@ -223,20 +226,22 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
 			    PMA_PMD_EXT_CTRL_REG, reg);
 
-	msleep(200);
+	mdelay(200);
 
 	/* Wait for the blocks to come out of reset */
 	rc = mdio_clause45_wait_reset_mmds(efx,
 					   TENXPRESS_REQUIRED_DEVS);
 	if (rc < 0)
-		return rc;
+		goto unlock;
 
 	/* Try and reconfigure the device */
 	rc = tenxpress_init(efx);
 	if (rc < 0)
-		return rc;
+		goto unlock;
 
-	return 0;
+unlock:
+	spin_unlock(&efx->stats_lock);
+	return rc;
 }
 
 static void tenxpress_set_bad_lp(struct efx_nic *efx, bool bad_lp)
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

