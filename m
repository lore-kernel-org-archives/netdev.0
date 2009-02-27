From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/9] sfc: Fix test for MDIO read failure
Date: Fri, 27 Feb 2009 23:06:12 +0000
Message-ID: <1235775972.3164.17.camel@achroite>
References: <1235775847.3164.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roel Kluin <roel.kluin@gmail.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:38497 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759357AbZB0XGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 18:06:18 -0500
In-Reply-To: <1235775847.3164.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 27dd2caca4eabe7c13a052b7456495ba75535e6a changed
mdio_clause45_check_mmds() to read both DEVS0 and DEVS1 registers and
to combine their values into an unsigned 32-bit mask.  This made the
following test for a negative (failure) value useless.  Fix it to
check whether either read failed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index f9e2f95..4462fb5 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -125,24 +125,25 @@ int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
 int mdio_clause45_check_mmds(struct efx_nic *efx,
 			     unsigned int mmd_mask, unsigned int fatal_mask)
 {
+	int mmd = 0, probe_mmd, devs0, devs1;
 	u32 devices;
-	int mmd = 0, probe_mmd;
 
 	/* Historically we have probed the PHYXS to find out what devices are
 	 * present,but that doesn't work so well if the PHYXS isn't expected
 	 * to exist, if so just find the first item in the list supplied. */
 	probe_mmd = (mmd_mask & MDIO_MMDREG_DEVS_PHYXS) ? MDIO_MMD_PHYXS :
 	    __ffs(mmd_mask);
-	devices = (mdio_clause45_read(efx, efx->mii.phy_id,
-				      probe_mmd, MDIO_MMDREG_DEVS0) |
-		   mdio_clause45_read(efx, efx->mii.phy_id,
-				      probe_mmd, MDIO_MMDREG_DEVS1) << 16);
 
 	/* Check all the expected MMDs are present */
-	if (devices < 0) {
+	devs0 = mdio_clause45_read(efx, efx->mii.phy_id,
+				   probe_mmd, MDIO_MMDREG_DEVS0);
+	devs1 = mdio_clause45_read(efx, efx->mii.phy_id,
+				   probe_mmd, MDIO_MMDREG_DEVS1);
+	if (devs0 < 0 || devs1 < 0) {
 		EFX_ERR(efx, "failed to read devices present\n");
 		return -EIO;
 	}
+	devices = devs0 | (devs1 << 16);
 	if ((devices & mmd_mask) != mmd_mask) {
 		EFX_ERR(efx, "required MMDs not present: got %x, "
 			"wanted %x\n", devices, mmd_mask);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

