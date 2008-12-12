From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/33] sfc: Add support for MMDs numbered >15
Date: Fri, 12 Dec 2008 12:53:40 +0000
Message-ID: <20081212125339.GO10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:49996 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757237AbYLLMxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:53:42 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Combine DEVS0 and DEVS1 registers into a 32-bit mask instead of
reading just DEVS0.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c  |   24 +++++++++++++-----------
 drivers/net/sfc/mdio_10g.h  |    8 ++++----
 drivers/net/sfc/tenxpress.c |    6 +++---
 drivers/net/sfc/xfp_phy.c   |    8 ++++----
 4 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 19e2521..1eed484 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -121,16 +121,18 @@ int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
 int mdio_clause45_check_mmds(struct efx_nic *efx,
 			     unsigned int mmd_mask, unsigned int fatal_mask)
 {
-	int devices, mmd = 0;
-	int probe_mmd;
+	u32 devices;
+	int mmd = 0, probe_mmd;
 
 	/* Historically we have probed the PHYXS to find out what devices are
 	 * present,but that doesn't work so well if the PHYXS isn't expected
 	 * to exist, if so just find the first item in the list supplied. */
-	probe_mmd = (mmd_mask & MDIO_MMDREG_DEVS0_PHYXS) ? MDIO_MMD_PHYXS :
+	probe_mmd = (mmd_mask & MDIO_MMDREG_DEVS_PHYXS) ? MDIO_MMD_PHYXS :
 	    __ffs(mmd_mask);
-	devices = mdio_clause45_read(efx, efx->mii.phy_id,
-				     probe_mmd, MDIO_MMDREG_DEVS0);
+	devices = (mdio_clause45_read(efx, efx->mii.phy_id,
+				      probe_mmd, MDIO_MMDREG_DEVS0) |
+		   mdio_clause45_read(efx, efx->mii.phy_id,
+				      probe_mmd, MDIO_MMDREG_DEVS1) << 16);
 
 	/* Check all the expected MMDs are present */
 	if (devices < 0) {
@@ -175,14 +177,14 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	else if (efx_phy_mode_disabled(efx->phy_mode))
 		return false;
 	else if (efx->loopback_mode == LOOPBACK_PHYXS)
-		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PHYXS |
-			      MDIO_MMDREG_DEVS0_PCS |
-			      MDIO_MMDREG_DEVS0_PMAPMD);
+		mmd_mask &= ~(MDIO_MMDREG_DEVS_PHYXS |
+			      MDIO_MMDREG_DEVS_PCS |
+			      MDIO_MMDREG_DEVS_PMAPMD);
 	else if (efx->loopback_mode == LOOPBACK_PCS)
-		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PCS |
-			      MDIO_MMDREG_DEVS0_PMAPMD);
+		mmd_mask &= ~(MDIO_MMDREG_DEVS_PCS |
+			      MDIO_MMDREG_DEVS_PMAPMD);
 	else if (efx->loopback_mode == LOOPBACK_PMAPMD)
-		mmd_mask &= ~MDIO_MMDREG_DEVS0_PMAPMD;
+		mmd_mask &= ~MDIO_MMDREG_DEVS_PMAPMD;
 
 	while (mmd_mask) {
 		if (mmd_mask & 1) {
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index db9f358..4516383 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -73,14 +73,14 @@
 #define MDIO_ID_MODEL(_id32)	((_id32 >> 4) & 0x3f)
 #define MDIO_ID_OUI(_id32)	(_id32 >> 10)
 
-/* Bits in MMDREG_DEVS0. Someone thoughtfully layed things out
+/* Bits in MMDREG_DEVS0/1. Someone thoughtfully layed things out
  * so the 'bit present' bit number of an MMD is the number of
  * that MMD */
 #define DEV_PRESENT_BIT(_b) (1 << _b)
 
-#define MDIO_MMDREG_DEVS0_PHYXS	 DEV_PRESENT_BIT(MDIO_MMD_PHYXS)
-#define MDIO_MMDREG_DEVS0_PCS	 DEV_PRESENT_BIT(MDIO_MMD_PCS)
-#define MDIO_MMDREG_DEVS0_PMAPMD DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)
+#define MDIO_MMDREG_DEVS_PHYXS	DEV_PRESENT_BIT(MDIO_MMD_PHYXS)
+#define MDIO_MMDREG_DEVS_PCS	DEV_PRESENT_BIT(MDIO_MMD_PCS)
+#define MDIO_MMDREG_DEVS_PMAPMD	DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)
 
 /* Bits in MMDREG_STAT2 */
 #define MDIO_MMDREG_STAT2_PRESENT_VAL	(2)
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 3fa7ccb..197b544 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -19,9 +19,9 @@
 
 /* We expect these MMDs to be in the package */
 /* AN not here as mdio_check_mmds() requires STAT2 support */
-#define TENXPRESS_REQUIRED_DEVS (MDIO_MMDREG_DEVS0_PMAPMD | \
-				 MDIO_MMDREG_DEVS0_PCS    | \
-				 MDIO_MMDREG_DEVS0_PHYXS)
+#define TENXPRESS_REQUIRED_DEVS (MDIO_MMDREG_DEVS_PMAPMD	| \
+				 MDIO_MMDREG_DEVS_PCS		| \
+				 MDIO_MMDREG_DEVS_PHYXS)
 
 #define TENXPRESS_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
 			     (1 << LOOPBACK_PCS) |	\
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 971a24b..0413d13 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -19,9 +19,9 @@
 #include "phy.h"
 #include "mac.h"
 
-#define XFP_REQUIRED_DEVS (MDIO_MMDREG_DEVS0_PCS |	\
-			   MDIO_MMDREG_DEVS0_PMAPMD |	\
-			   MDIO_MMDREG_DEVS0_PHYXS)
+#define XFP_REQUIRED_DEVS (MDIO_MMDREG_DEVS_PCS |	\
+			   MDIO_MMDREG_DEVS_PMAPMD |	\
+			   MDIO_MMDREG_DEVS_PHYXS)
 
 #define XFP_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
 		       (1 << LOOPBACK_PMAPMD) |		\
@@ -64,7 +64,7 @@ static int xfp_reset_phy(struct efx_nic *efx)
 	/* Check that all the MMDs we expect are present and responding. We
 	 * expect faults on some if the link is down, but not on the PHY XS */
 	rc = mdio_clause45_check_mmds(efx, XFP_REQUIRED_DEVS,
-				      MDIO_MMDREG_DEVS0_PHYXS);
+				      MDIO_MMDREG_DEVS_PHYXS);
 	if (rc < 0)
 		goto fail;
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
