From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/7] sfc: QT2025C: Use hard reset only
Date: Wed, 26 Aug 2009 19:17:19 +0100
Message-ID: <1251310639.27345.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60573 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752545AbZHZSRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 14:17:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At probe time, falcon_reset_hw() performs a hard reset of the PHY
along with Falcon.  There is no need to perform a soft reset later,
and any access to standard MDIO registers before the PHY firmware has
booted can interrupt the boot process, making the port unusable.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/xfp_phy.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index bb2e6af..e6b3d5e 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -97,23 +97,24 @@ static int qt2025c_wait_reset(struct efx_nic *efx)
 	return 0;
 }
 
-/* Reset the PHYXS MMD. This is documented (for the Quake PHYs) as doing
- * a complete soft reset.
- */
 static int xfp_reset_phy(struct efx_nic *efx)
 {
 	int rc;
 
-	rc = efx_mdio_reset_mmd(efx, MDIO_MMD_PHYXS,
-				XFP_MAX_RESET_TIME / XFP_RESET_WAIT,
-				XFP_RESET_WAIT);
-	if (rc < 0)
-		goto fail;
-
 	if (efx->phy_type == PHY_TYPE_QT2025C) {
+		/* Wait for the reset triggered by falcon_reset_hw()
+		 * to complete */
 		rc = qt2025c_wait_reset(efx);
 		if (rc < 0)
 			goto fail;
+	} else {
+		/* Reset the PHYXS MMD. This is documented as doing
+		 * a complete soft reset. */
+		rc = efx_mdio_reset_mmd(efx, MDIO_MMD_PHYXS,
+					XFP_MAX_RESET_TIME / XFP_RESET_WAIT,
+					XFP_RESET_WAIT);
+		if (rc < 0)
+			goto fail;
 	}
 
 	/* Wait 250ms for the PHY to complete bootup */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

