From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sfc: mdio_clause45_read errors go unnoticed
Date: Fri, 27 Feb 2009 17:31:33 +0100
Message-ID: <49A81565.3030004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: linux-net-drivers@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.217.174]:40688 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbZB0Qbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 11:31:36 -0500
Received: by gxk22 with SMTP id 22so2785294gxk.13
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 08:31:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch was not tested in any way, but:

since commit 27dd2caca4eabe7c13a052b7456495ba75535e6a
------------------------------>8-------------8<---------------------------------
mdio_clause45_read may return -ERR, but since 'devices' is unsigned, this is not
noticed.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index f9e2f95..bcb5ddc 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -126,23 +126,29 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 			     unsigned int mmd_mask, unsigned int fatal_mask)
 {
 	u32 devices;
-	int mmd = 0, probe_mmd;
+	int ret, mmd = 0, probe_mmd;
 
 	/* Historically we have probed the PHYXS to find out what devices are
 	 * present,but that doesn't work so well if the PHYXS isn't expected
 	 * to exist, if so just find the first item in the list supplied. */
 	probe_mmd = (mmd_mask & MDIO_MMDREG_DEVS_PHYXS) ? MDIO_MMD_PHYXS :
 	    __ffs(mmd_mask);
-	devices = (mdio_clause45_read(efx, efx->mii.phy_id,
-				      probe_mmd, MDIO_MMDREG_DEVS0) |
-		   mdio_clause45_read(efx, efx->mii.phy_id,
-				      probe_mmd, MDIO_MMDREG_DEVS1) << 16);
 
-	/* Check all the expected MMDs are present */
-	if (devices < 0) {
+	ret = mdio_clause45_read(efx, efx->mii.phy_id, probe_mmd,
+			MDIO_MMDREG_DEVS0);
+	if (ret >= 0) {
+		devices = ret;
+		ret = mdio_clause45_read(efx, efx->mii.phy_id, probe_mmd,
+				MDIO_MMDREG_DEVS1);
+	}
+
+	/* Check all the expected MMDs were present */
+	if (ret < 0) {
 		EFX_ERR(efx, "failed to read devices present\n");
 		return -EIO;
 	}
+	devices |= ret << 16;
+
 	if ((devices & mmd_mask) != mmd_mask) {
 		EFX_ERR(efx, "required MMDs not present: got %x, "
 			"wanted %x\n", devices, mmd_mask);
