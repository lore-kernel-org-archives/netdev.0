From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/12] sfc: Extend loopback mode enumeration
Date: Mon, 30 Nov 2009 01:08:41 +0000
Message-ID: <1259543321.3709.85.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46594 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbZK3BIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:08:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New NICs and PHYs support a wider variety of loopback modes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c         |   19 +++++++-
 drivers/net/sfc/enum.h        |  106 +++++++++++++++++++++++++++++++++--------
 drivers/net/sfc/falcon_xmac.c |    2 +-
 drivers/net/sfc/mdio_10g.c    |    4 +-
 drivers/net/sfc/net_driver.h  |    2 +-
 drivers/net/sfc/qt202x_phy.c  |    2 +-
 drivers/net/sfc/tenxpress.c   |    4 +-
 7 files changed, 111 insertions(+), 28 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index e5c33c6..75dcaae 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -36,15 +36,32 @@
 const unsigned int efx_loopback_mode_max = LOOPBACK_MAX;
 const char *efx_loopback_mode_names[] = {
 	[LOOPBACK_NONE]		= "NONE",
+	[LOOPBACK_DATA]		= "DATAPATH",
 	[LOOPBACK_GMAC]		= "GMAC",
 	[LOOPBACK_XGMII]	= "XGMII",
 	[LOOPBACK_XGXS]		= "XGXS",
 	[LOOPBACK_XAUI]  	= "XAUI",
+	[LOOPBACK_GMII] 	= "GMII",
+	[LOOPBACK_SGMII] 	= "SGMII",
+	[LOOPBACK_XGBR]		= "XGBR",
+	[LOOPBACK_XFI]		= "XFI",
+	[LOOPBACK_XAUI_FAR]	= "XAUI_FAR",
+	[LOOPBACK_GMII_FAR]	= "GMII_FAR",
+	[LOOPBACK_SGMII_FAR]	= "SGMII_FAR",
+	[LOOPBACK_XFI_FAR]	= "XFI_FAR",
 	[LOOPBACK_GPHY]		= "GPHY",
 	[LOOPBACK_PHYXS]	= "PHYXS",
 	[LOOPBACK_PCS]	 	= "PCS",
 	[LOOPBACK_PMAPMD] 	= "PMA/PMD",
-	[LOOPBACK_NETWORK]	= "NETWORK",
+	[LOOPBACK_XPORT]	= "XPORT",
+	[LOOPBACK_XGMII_WS]	= "XGMII_WS",
+	[LOOPBACK_XAUI_WS]  	= "XAUI_WS",
+	[LOOPBACK_XAUI_WS_FAR]  = "XAUI_WS_FAR",
+	[LOOPBACK_XAUI_WS_NEAR] = "XAUI_WS_NEAR",
+	[LOOPBACK_GMII_WS] 	= "GMII_WS",
+	[LOOPBACK_XFI_WS]	= "XFI_WS",
+	[LOOPBACK_XFI_WS_FAR]	= "XFI_WS_FAR",
+	[LOOPBACK_PHYXS_WS]  	= "PHYXS_WS",
 };
 
 /* Interrupt mode names (see INT_MODE())) */
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index fcd14b7..7a9e79a 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -13,38 +13,101 @@
 /**
  * enum efx_loopback_mode - loopback modes
  * @LOOPBACK_NONE: no loopback
- * @LOOPBACK_GMAC: loopback within GMAC at unspecified level
- * @LOOPBACK_XGMII: loopback within XMAC at XGMII level
- * @LOOPBACK_XGXS: loopback within XMAC at XGXS level
- * @LOOPBACK_XAUI: loopback within XMAC at XAUI level
+ * @LOOPBACK_DATA: data path loopback
+ * @LOOPBACK_GMAC: loopback within GMAC
+ * @LOOPBACK_XGMII: loopback after XMAC
+ * @LOOPBACK_XGXS: loopback within BPX after XGXS
+ * @LOOPBACK_XAUI: loopback within BPX before XAUI serdes
+ * @LOOPBACK_GMII: loopback within BPX after GMAC
+ * @LOOPBACK_SGMII: loopback within BPX within SGMII
+ * @LOOPBACK_XGBR: loopback within BPX within XGBR
+ * @LOOPBACK_XFI: loopback within BPX before XFI serdes
+ * @LOOPBACK_XAUI_FAR: loopback within BPX after XAUI serdes
+ * @LOOPBACK_GMII_FAR: loopback within BPX before SGMII
+ * @LOOPBACK_SGMII_FAR: loopback within BPX after SGMII
+ * @LOOPBACK_XFI_FAR: loopback after XFI serdes
  * @LOOPBACK_GPHY: loopback within 1G PHY at unspecified level
  * @LOOPBACK_PHYXS: loopback within 10G PHY at PHYXS level
  * @LOOPBACK_PCS: loopback within 10G PHY at PCS level
  * @LOOPBACK_PMAPMD: loopback within 10G PHY at PMAPMD level
- * @LOOPBACK_NETWORK: reflecting loopback (even further than furthest!)
+ * @LOOPBACK_XPORT: cross port loopback
+ * @LOOPBACK_XGMII_WS: wireside loopback excluding XMAC
+ * @LOOPBACK_XAUI_WS: wireside loopback within BPX within XAUI serdes
+ * @LOOPBACK_XAUI_WS_FAR: wireside loopback within BPX including XAUI serdes
+ * @LOOPBACK_XAUI_WS_NEAR: wireside loopback within BPX excluding XAUI serdes
+ * @LOOPBACK_GMII_WS: wireside loopback excluding GMAC
+ * @LOOPBACK_XFI_WS: wireside loopback excluding XFI serdes
+ * @LOOPBACK_XFI_WS_FAR: wireside loopback including XFI serdes
+ * @LOOPBACK_PHYXS_WS: wireside loopback within 10G PHY at PHYXS level
  */
-/* Please keep in order and up-to-date w.r.t the following two #defines */
+/* Please keep up-to-date w.r.t the following two #defines */
 enum efx_loopback_mode {
 	LOOPBACK_NONE = 0,
-	LOOPBACK_GMAC = 1,
-	LOOPBACK_XGMII = 2,
-	LOOPBACK_XGXS = 3,
-	LOOPBACK_XAUI = 4,
-	LOOPBACK_GPHY = 5,
-	LOOPBACK_PHYXS = 6,
-	LOOPBACK_PCS = 7,
-	LOOPBACK_PMAPMD = 8,
-	LOOPBACK_NETWORK = 9,
+	LOOPBACK_DATA = 1,
+	LOOPBACK_GMAC = 2,
+	LOOPBACK_XGMII = 3,
+	LOOPBACK_XGXS = 4,
+	LOOPBACK_XAUI = 5,
+	LOOPBACK_GMII = 6,
+	LOOPBACK_SGMII = 7,
+	LOOPBACK_XGBR = 8,
+	LOOPBACK_XFI = 9,
+	LOOPBACK_XAUI_FAR = 10,
+	LOOPBACK_GMII_FAR = 11,
+	LOOPBACK_SGMII_FAR = 12,
+	LOOPBACK_XFI_FAR = 13,
+	LOOPBACK_GPHY = 14,
+	LOOPBACK_PHYXS = 15,
+	LOOPBACK_PCS = 16,
+	LOOPBACK_PMAPMD = 17,
+	LOOPBACK_XPORT = 18,
+	LOOPBACK_XGMII_WS = 19,
+	LOOPBACK_XAUI_WS = 20,
+	LOOPBACK_XAUI_WS_FAR = 21,
+	LOOPBACK_XAUI_WS_NEAR = 22,
+	LOOPBACK_GMII_WS = 23,
+	LOOPBACK_XFI_WS = 24,
+	LOOPBACK_XFI_WS_FAR = 25,
+	LOOPBACK_PHYXS_WS = 26,
 	LOOPBACK_MAX
 };
-
 #define LOOPBACK_TEST_MAX LOOPBACK_PMAPMD
 
 /* These loopbacks occur within the controller */
-#define LOOPBACKS_INTERNAL ((1 << LOOPBACK_GMAC) |     \
-			    (1 << LOOPBACK_XGMII)|     \
-			    (1 << LOOPBACK_XGXS) |     \
-			    (1 << LOOPBACK_XAUI))
+#define LOOPBACKS_INTERNAL ((1 << LOOPBACK_DATA) |		\
+			    (1 << LOOPBACK_GMAC) |		\
+			    (1 << LOOPBACK_XGMII)|		\
+			    (1 << LOOPBACK_XGXS) |		\
+			    (1 << LOOPBACK_XAUI) |		\
+			    (1 << LOOPBACK_GMII) |		\
+			    (1 << LOOPBACK_SGMII) |		\
+			    (1 << LOOPBACK_SGMII) |		\
+			    (1 << LOOPBACK_XGBR) |		\
+			    (1 << LOOPBACK_XFI) |		\
+			    (1 << LOOPBACK_XAUI_FAR) |		\
+			    (1 << LOOPBACK_GMII_FAR) |		\
+			    (1 << LOOPBACK_SGMII_FAR) |		\
+			    (1 << LOOPBACK_XFI_FAR) |		\
+			    (1 << LOOPBACK_XGMII_WS) |		\
+			    (1 << LOOPBACK_XAUI_WS) |		\
+			    (1 << LOOPBACK_XAUI_WS_FAR) |	\
+			    (1 << LOOPBACK_XAUI_WS_NEAR) |	\
+			    (1 << LOOPBACK_GMII_WS) |		\
+			    (1 << LOOPBACK_XFI_WS) |		\
+			    (1 << LOOPBACK_XFI_WS_FAR))
+
+#define LOOPBACKS_WS ((1 << LOOPBACK_XGMII_WS) |		\
+		      (1 << LOOPBACK_XAUI_WS) |			\
+		      (1 << LOOPBACK_XAUI_WS_FAR) |		\
+		      (1 << LOOPBACK_XAUI_WS_NEAR) |		\
+		      (1 << LOOPBACK_GMII_WS) |			\
+		      (1 << LOOPBACK_XFI_WS) |			\
+		      (1 << LOOPBACK_XFI_WS_FAR) |		\
+		      (1 << LOOPBACK_PHYXS_WS))
+
+#define LOOPBACKS_EXTERNAL(_efx)					\
+	((_efx)->loopback_modes & ~LOOPBACKS_INTERNAL &			\
+	 ~(1 << LOOPBACK_NONE))
 
 #define LOOPBACK_MASK(_efx)			\
 	(1 << (_efx)->loopback_mode)
@@ -52,6 +115,9 @@ enum efx_loopback_mode {
 #define LOOPBACK_INTERNAL(_efx)				\
 	(!!(LOOPBACKS_INTERNAL & LOOPBACK_MASK(_efx)))
 
+#define LOOPBACK_EXTERNAL(_efx)				\
+	(!!(LOOPBACK_MASK(_efx) & LOOPBACKS_EXTERNAL(_efx)))
+
 #define LOOPBACK_CHANGED(_from, _to, _mask)				\
 	(!!((LOOPBACK_MASK(_from) ^ LOOPBACK_MASK(_to)) & (_mask)))
 
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 898afc1..83da792 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -249,7 +249,7 @@ static bool falcon_check_xaui_link_up(struct efx_nic *efx, int tries)
 {
 	bool mac_up = falcon_xaui_link_ok(efx);
 
-	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
+	if (LOOPBACK_MASK(efx) & LOOPBACKS_EXTERNAL(efx) & LOOPBACKS_WS ||
 	    efx_phy_mode_disabled(efx->phy_mode))
 		/* XAUI link is expected to be down */
 		return mac_up;
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 1f62a5c..e6ca988 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -173,7 +173,7 @@ bool efx_mdio_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	 * of mmd's */
 	if (LOOPBACK_INTERNAL(efx))
 		return true;
-	else if (efx->loopback_mode == LOOPBACK_NETWORK)
+	else if (LOOPBACK_MASK(efx) & LOOPBACKS_WS)
 		return false;
 	else if (efx_phy_mode_disabled(efx->phy_mode))
 		return false;
@@ -210,7 +210,7 @@ void efx_mdio_phy_reconfigure(struct efx_nic *efx)
 			  efx->loopback_mode == LOOPBACK_PCS);
 	efx_mdio_set_flag(efx, MDIO_MMD_PHYXS,
 			  MDIO_CTRL1, MDIO_PHYXS_CTRL1_LOOPBACK,
-			  efx->loopback_mode == LOOPBACK_NETWORK);
+			  efx->loopback_mode == LOOPBACK_PHYXS_WS);
 }
 
 static void efx_mdio_set_mmd_lpower(struct efx_nic *efx,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 62b2089..cd2debb 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -824,7 +824,7 @@ struct efx_nic {
 
 	atomic_t rx_reset;
 	enum efx_loopback_mode loopback_mode;
-	unsigned int loopback_modes;
+	u64 loopback_modes;
 
 	void *loopback_selftest;
 };
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 4c38516..49a5ab5 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -23,7 +23,7 @@
 
 #define QT202X_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
 			  (1 << LOOPBACK_PMAPMD) |	\
-			  (1 << LOOPBACK_NETWORK))
+			  (1 << LOOPBACK_PHYXS_WS))
 
 /****************************************************************************/
 /* Quake-specific MDIO registers */
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index c301853..0dfb227 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -30,13 +30,13 @@
 #define SFX7101_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
 			   (1 << LOOPBACK_PCS) |	\
 			   (1 << LOOPBACK_PMAPMD) |	\
-			   (1 << LOOPBACK_NETWORK))
+			   (1 << LOOPBACK_PHYXS_WS))
 
 #define SFT9001_LOOPBACKS ((1 << LOOPBACK_GPHY) |	\
 			   (1 << LOOPBACK_PHYXS) |	\
 			   (1 << LOOPBACK_PCS) |	\
 			   (1 << LOOPBACK_PMAPMD) |	\
-			   (1 << LOOPBACK_NETWORK))
+			   (1 << LOOPBACK_PHYXS_WS))
 
 /* We complain if we fail to see the link partner as 10G capable this many
  * times in a row (must be > 1 as sampling the autoneg. registers is racy)
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

