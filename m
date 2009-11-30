From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/12] sfc: Remove static PHY data and enumerations
Date: Mon, 30 Nov 2009 01:08:55 +0000
Message-ID: <1259543335.3709.86.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46602 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbZK3BIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:08:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New NICs have firmware managing the PHY, and we will discover the PHY
capabilities at run-time.  Replace the static data with probe() and
test_name() operations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c     |   18 ++++++++++++--
 drivers/net/sfc/falcon.c      |   15 +++---------
 drivers/net/sfc/falcon.h      |   20 ++++++++++++++++
 drivers/net/sfc/falcon_xmac.c |    2 +-
 drivers/net/sfc/mdio_10g.c    |    4 +-
 drivers/net/sfc/net_driver.h  |   35 +++++------------------------
 drivers/net/sfc/qt202x_phy.c  |   12 +++++++--
 drivers/net/sfc/selftest.c    |    5 +---
 drivers/net/sfc/tenxpress.c   |   49 +++++++++++++++++++++++++++++++----------
 9 files changed, 95 insertions(+), 65 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index e86cbca..4fe8740 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -365,9 +365,21 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 	efx_fill_test(n++, strings, data, &tests->registers,
 		      "core", 0, "registers", NULL);
 
-	for (i = 0; i < efx->phy_op->num_tests; i++)
-		efx_fill_test(n++, strings, data, &tests->phy[i],
-			      "phy", 0, efx->phy_op->test_names[i], NULL);
+	if (efx->phy_op->run_tests != NULL) {
+		EFX_BUG_ON_PARANOID(efx->phy_op->test_name == NULL);
+
+		for (i = 0; true; ++i) {
+			const char *name;
+
+			EFX_BUG_ON_PARANOID(i >= EFX_MAX_PHY_TESTS);
+			name = efx->phy_op->test_name(efx, i);
+			if (name == NULL)
+				break;
+
+			efx_fill_test(n++, strings, data, &tests->phy[i],
+				      "phy", 0, name, NULL);
+		}
+	}
 
 	/* Loopback tests */
 	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 63e6734..29d4537 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2291,19 +2291,12 @@ static int falcon_probe_port(struct efx_nic *efx)
 		return -ENODEV;
 	}
 
-	if (efx->phy_op->macs & EFX_XMAC)
-		efx->loopback_modes |= ((1 << LOOPBACK_XGMII) |
-					(1 << LOOPBACK_XGXS) |
-					(1 << LOOPBACK_XAUI));
-	if (efx->phy_op->macs & EFX_GMAC)
-		efx->loopback_modes |= (1 << LOOPBACK_GMAC);
-	efx->loopback_modes |= efx->phy_op->loopbacks;
-
-	/* Set up MDIO structure for PHY */
-	efx->mdio.mmds = efx->phy_op->mmds;
-	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	/* Fill out MDIO structure and loopback modes */
 	efx->mdio.mdio_read = falcon_mdio_read;
 	efx->mdio.mdio_write = falcon_mdio_write;
+	rc = efx->phy_op->probe(efx);
+	if (rc != 0)
+		return rc;
 
 	/* Initial assumption */
 	efx->link_state.speed = 10000;
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 875b58e..3085ecf 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -38,6 +38,26 @@ static inline bool efx_nic_is_dual_func(struct efx_nic *efx)
 	return efx_nic_rev(efx) < EFX_REV_FALCON_B0;
 }
 
+enum {
+	PHY_TYPE_NONE = 0,
+	PHY_TYPE_TXC43128 = 1,
+	PHY_TYPE_88E1111 = 2,
+	PHY_TYPE_SFX7101 = 3,
+	PHY_TYPE_QT2022C2 = 4,
+	PHY_TYPE_PM8358 = 6,
+	PHY_TYPE_SFT9001A = 8,
+	PHY_TYPE_QT2025C = 9,
+	PHY_TYPE_SFT9001B = 10,
+};
+
+#define FALCON_XMAC_LOOPBACKS			\
+	((1 << LOOPBACK_XGMII) |		\
+	 (1 << LOOPBACK_XGXS) |			\
+	 (1 << LOOPBACK_XAUI))
+
+#define FALCON_GMAC_LOOPBACKS			\
+	(1 << LOOPBACK_GMAC)
+
 /**
  * struct falcon_board_type - board operations and type information
  * @id: Board type id, as found in NVRAM
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 83da792..643622d 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -137,7 +137,7 @@ static bool falcon_xaui_link_ok(struct efx_nic *efx)
 
 	/* If the link is up, then check the phy side of the xaui link */
 	if (efx->link_state.up && link_ok)
-		if (efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS))
+		if (efx->mdio.mmds & (1 << MDIO_MMD_PHYXS))
 			link_ok = efx_mdio_phyxgxs_lane_sync(efx);
 
 	return link_ok;
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index e6ca988..20e6274 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -15,6 +15,7 @@
 #include "net_driver.h"
 #include "mdio_10g.h"
 #include "workarounds.h"
+#include "falcon.h"
 
 unsigned efx_mdio_id_oui(u32 id)
 {
@@ -312,8 +313,7 @@ void efx_mdio_an_reconfigure(struct efx_nic *efx)
 	/* Enable and restart AN */
 	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
 	reg |= MDIO_AN_CTRL1_ENABLE;
-	if (!(EFX_WORKAROUND_15195(efx) &&
-	      LOOPBACK_MASK(efx) & efx->phy_op->loopbacks))
+	if (!(EFX_WORKAROUND_15195(efx) && LOOPBACK_EXTERNAL(efx)))
 		reg |= MDIO_AN_CTRL1_RESTART;
 	if (xnp)
 		reg |= MDIO_AN_CTRL1_XNP;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index cd2debb..452f835 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -428,19 +428,6 @@ enum efx_int_mode {
 };
 #define EFX_INT_MODE_USE_MSI(x) (((x)->interrupt_mode) <= EFX_INT_MODE_MSI)
 
-enum phy_type {
-	PHY_TYPE_NONE = 0,
-	PHY_TYPE_TXC43128 = 1,
-	PHY_TYPE_88E1111 = 2,
-	PHY_TYPE_SFX7101 = 3,
-	PHY_TYPE_QT2022C2 = 4,
-	PHY_TYPE_PM8358 = 6,
-	PHY_TYPE_SFT9001A = 8,
-	PHY_TYPE_QT2025C = 9,
-	PHY_TYPE_SFT9001B = 10,
-	PHY_TYPE_MAX	/* Insert any new items before this */
-};
-
 #define EFX_IS10G(efx) ((efx)->link_state.speed == 10000)
 
 enum nic_state {
@@ -483,12 +470,6 @@ enum efx_fc_type {
 	EFX_FC_AUTO = 4,
 };
 
-/* Supported MAC bit-mask */
-enum efx_mac_type {
-	EFX_GMAC = 1,
-	EFX_XMAC = 2,
-};
-
 /**
  * struct efx_link_state - Current state of the link
  * @up: Link is up
@@ -524,6 +505,8 @@ struct efx_mac_operations {
 
 /**
  * struct efx_phy_operations - Efx PHY operations table
+ * @probe: Probe PHY and initialise efx->mdio.mode_support, efx->mdio.mmds,
+ *	efx->loopback_modes.
  * @init: Initialise PHY
  * @fini: Shut down PHY
  * @reconfigure: Reconfigure PHY (e.g. for new link parameters)
@@ -533,15 +516,12 @@ struct efx_mac_operations {
  * @set_settings: Set ethtool settings. Serialised by the mac_lock.
  * @set_npage_adv: Set abilities advertised in (Extended) Next Page
  *	(only needed where AN bit is set in mmds)
- * @num_tests: Number of PHY-specific tests/results
- * @test_names: Names of the tests/results
+ * @test_name: Get the name of a PHY-specific test/result
  * @run_tests: Run tests and record results as appropriate.
  *	Flags are the ethtool tests flags.
- * @mmds: MMD presence mask
- * @loopbacks: Supported loopback modes mask
  */
 struct efx_phy_operations {
-	enum efx_mac_type macs;
+	int (*probe) (struct efx_nic *efx);
 	int (*init) (struct efx_nic *efx);
 	void (*fini) (struct efx_nic *efx);
 	int (*reconfigure) (struct efx_nic *efx);
@@ -551,11 +531,8 @@ struct efx_phy_operations {
 	int (*set_settings) (struct efx_nic *efx,
 			     struct ethtool_cmd *ecmd);
 	void (*set_npage_adv) (struct efx_nic *efx, u32);
-	u32 num_tests;
-	const char *const *test_names;
+	const char *(*test_name) (struct efx_nic *efx, unsigned int index);
 	int (*run_tests) (struct efx_nic *efx, int *results, unsigned flags);
-	int mmds;
-	unsigned loopbacks;
 };
 
 /**
@@ -806,7 +783,7 @@ struct efx_nic {
 	struct efx_mac_operations *mac_op;
 	unsigned char mac_address[ETH_ALEN];
 
-	enum phy_type phy_type;
+	unsigned int phy_type;
 	struct mutex mdio_lock;
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 49a5ab5..22b0e89 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -135,6 +135,14 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 	return rc;
 }
 
+static int qt202x_phy_probe(struct efx_nic *efx)
+{
+	efx->mdio.mmds = QT202X_REQUIRED_DEVS;
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->loopback_modes = QT202X_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
+	return 0;
+}
+
 static int qt202x_phy_init(struct efx_nic *efx)
 {
 	struct qt202x_phy_data *phy_data;
@@ -224,13 +232,11 @@ static void qt202x_phy_fini(struct efx_nic *efx)
 }
 
 struct efx_phy_operations falcon_qt202x_phy_ops = {
-	.macs		 = EFX_XMAC,
+	.probe		 = qt202x_phy_probe,
 	.init		 = qt202x_phy_init,
 	.reconfigure	 = qt202x_phy_reconfigure,
 	.poll	     	 = qt202x_phy_poll,
 	.fini	  	 = qt202x_phy_fini,
 	.get_settings	 = qt202x_phy_get_settings,
 	.set_settings	 = efx_mdio_set_settings,
-	.mmds            = QT202X_REQUIRED_DEVS,
-	.loopbacks       = QT202X_LOOPBACKS,
 };
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 9a24053..16258d8 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -100,7 +100,7 @@ static int efx_test_mdio(struct efx_nic *efx, struct efx_self_tests *tests)
 	}
 
 	if (EFX_IS10G(efx)) {
-		rc = efx_mdio_check_mmds(efx, efx->phy_op->mmds, 0);
+		rc = efx_mdio_check_mmds(efx, efx->mdio.mmds, 0);
 		if (rc)
 			goto out;
 	}
@@ -253,9 +253,6 @@ static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests,
 	if (!efx->phy_op->run_tests)
 		return 0;
 
-	EFX_BUG_ON_PARANOID(efx->phy_op->num_tests == 0 ||
-			    efx->phy_op->num_tests > EFX_MAX_PHY_TESTS);
-
 	mutex_lock(&efx->mac_lock);
 	rc = efx->phy_op->run_tests(efx, tests->phy, flags);
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 0dfb227..8de97a9 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -298,6 +298,23 @@ static int tenxpress_init(struct efx_nic *efx)
 	return 0;
 }
 
+static int sfx7101_phy_probe(struct efx_nic *efx)
+{
+	efx->mdio.mmds = TENXPRESS_REQUIRED_DEVS;
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->loopback_modes = SFX7101_LOOPBACKS | FALCON_XMAC_LOOPBACKS;
+	return 0;
+}
+
+static int sft9001_phy_probe(struct efx_nic *efx)
+{
+	efx->mdio.mmds = TENXPRESS_REQUIRED_DEVS;
+	efx->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	efx->loopback_modes = (SFT9001_LOOPBACKS | FALCON_XMAC_LOOPBACKS |
+			       FALCON_GMAC_LOOPBACKS);
+	return 0;
+}
+
 static int tenxpress_phy_init(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data;
@@ -512,7 +529,7 @@ static int tenxpress_phy_reconfigure(struct efx_nic *efx)
 
 	phy_mode_change = (efx->phy_mode == PHY_MODE_NORMAL &&
 			   phy_data->phy_mode != PHY_MODE_NORMAL);
-	loop_reset = (LOOPBACK_OUT_OF(phy_data, efx, efx->phy_op->loopbacks) ||
+	loop_reset = (LOOPBACK_OUT_OF(phy_data, efx, LOOPBACKS_EXTERNAL(efx)) ||
 		      LOOPBACK_CHANGED(phy_data, efx, 1 << LOOPBACK_GPHY));
 
 	if (loop_reset || phy_mode_change) {
@@ -627,6 +644,13 @@ static const char *const sfx7101_test_names[] = {
 	"bist"
 };
 
+static const char *sfx7101_test_name(struct efx_nic *efx, unsigned int index)
+{
+	if (index < ARRAY_SIZE(sfx7101_test_names))
+		return sfx7101_test_names[index];
+	return NULL;
+}
+
 static int
 sfx7101_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 {
@@ -656,6 +680,13 @@ static const char *const sft9001_test_names[] = {
 	"cable.pairD.length",
 };
 
+static const char *sft9001_test_name(struct efx_nic *efx, unsigned int index)
+{
+	if (index < ARRAY_SIZE(sft9001_test_names))
+		return sft9001_test_names[index];
+	return NULL;
+}
+
 static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 {
 	int rc = 0, rc2, i, ctrl_reg, res_reg;
@@ -758,7 +789,7 @@ tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	 * but doesn't advertise the correct speed. So override it */
 	if (efx->loopback_mode == LOOPBACK_GPHY)
 		ecmd->speed = SPEED_1000;
-	else if (LOOPBACK_MASK(efx) & efx->phy_op->loopbacks)
+	else if (LOOPBACK_EXTERNAL(efx))
 		ecmd->speed = SPEED_10000;
 }
 
@@ -788,7 +819,7 @@ static void sft9001_set_npage_adv(struct efx_nic *efx, u32 advertising)
 }
 
 struct efx_phy_operations falcon_sfx7101_phy_ops = {
-	.macs		  = EFX_XMAC,
+	.probe		  = sfx7101_phy_probe,
 	.init             = tenxpress_phy_init,
 	.reconfigure      = tenxpress_phy_reconfigure,
 	.poll             = tenxpress_phy_poll,
@@ -796,15 +827,12 @@ struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.get_settings	  = tenxpress_get_settings,
 	.set_settings	  = tenxpress_set_settings,
 	.set_npage_adv    = sfx7101_set_npage_adv,
-	.num_tests	  = ARRAY_SIZE(sfx7101_test_names),
-	.test_names	  = sfx7101_test_names,
+	.test_name	  = sfx7101_test_name,
 	.run_tests	  = sfx7101_run_tests,
-	.mmds             = TENXPRESS_REQUIRED_DEVS,
-	.loopbacks        = SFX7101_LOOPBACKS,
 };
 
 struct efx_phy_operations falcon_sft9001_phy_ops = {
-	.macs		  = EFX_GMAC | EFX_XMAC,
+	.probe		  = sft9001_phy_probe,
 	.init             = tenxpress_phy_init,
 	.reconfigure      = tenxpress_phy_reconfigure,
 	.poll             = tenxpress_phy_poll,
@@ -812,9 +840,6 @@ struct efx_phy_operations falcon_sft9001_phy_ops = {
 	.get_settings	  = tenxpress_get_settings,
 	.set_settings	  = tenxpress_set_settings,
 	.set_npage_adv    = sft9001_set_npage_adv,
-	.num_tests	  = ARRAY_SIZE(sft9001_test_names),
-	.test_names	  = sft9001_test_names,
+	.test_name	  = sft9001_test_name,
 	.run_tests	  = sft9001_run_tests,
-	.mmds             = TENXPRESS_REQUIRED_DEVS,
-	.loopbacks        = SFT9001_LOOPBACKS,
 };
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

