From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 5/8] sfc: Add support for multiple PHY self-tests
Date: Thu, 25 Dec 2008 03:40:40 +0000
Message-ID: <1230176440.3401.47.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3921 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751598AbYLYDko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:40:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c    |    8 +++++---
 drivers/net/sfc/net_driver.h |    8 +++++++-
 drivers/net/sfc/selftest.c   |   15 +++++++++------
 drivers/net/sfc/selftest.h   |    4 +++-
 drivers/net/sfc/tenxpress.c  |   24 ++++++++++++++++++++----
 5 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7fa2844..53d259e 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -345,7 +345,7 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 				       u64 *data)
 {
 	struct efx_channel *channel;
-	unsigned int n = 0;
+	unsigned int n = 0, i;
 	enum efx_loopback_mode mode;
 
 	efx_fill_test(n++, strings, data, &tests->mii,
@@ -373,8 +373,10 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 
 	efx_fill_test(n++, strings, data, &tests->registers,
 		      "core", 0, "registers", NULL);
-	efx_fill_test(n++, strings, data, &tests->phy,
-		      "phy", 0, "bist", NULL);
+
+	for (i = 0; i < efx->phy_op->num_tests; i++)
+		efx_fill_test(n++, strings, data, &tests->phy[i],
+			      "phy", 0, efx->phy_op->test_names[i], NULL);
 
 	/* Loopback tests */
 	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index b0c7975..5f255f7 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -568,6 +568,10 @@ struct efx_mac_operations {
  * @set_settings: Set ethtool settings. Serialised by the mac_lock.
  * @set_xnp_advertise: Set abilities advertised in Extended Next Page
  *	(only needed where AN bit is set in mmds)
+ * @num_tests: Number of PHY-specific tests/results
+ * @test_names: Names of the tests/results
+ * @run_tests: Run tests and record results as appropriate.
+ *	Flags are the ethtool tests flags.
  * @mmds: MMD presence mask
  * @loopbacks: Supported loopback modes mask
  */
@@ -578,12 +582,14 @@ struct efx_phy_operations {
 	void (*reconfigure) (struct efx_nic *efx);
 	void (*clear_interrupt) (struct efx_nic *efx);
 	void (*poll) (struct efx_nic *efx);
-	int (*test) (struct efx_nic *efx);
 	void (*get_settings) (struct efx_nic *efx,
 			      struct ethtool_cmd *ecmd);
 	int (*set_settings) (struct efx_nic *efx,
 			     struct ethtool_cmd *ecmd);
 	bool (*set_xnp_advertise) (struct efx_nic *efx, u32);
+	u32 num_tests;
+	const char *const *test_names;
+	int (*run_tests) (struct efx_nic *efx, int *results, unsigned flags);
 	int mmds;
 	unsigned loopbacks;
 };
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index d10f6fb..dba0d64 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -247,17 +247,20 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 	return 0;
 }
 
-static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests)
+static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests,
+			unsigned flags)
 {
 	int rc;
 
-	if (!efx->phy_op->test)
+	if (!efx->phy_op->run_tests)
 		return 0;
 
+	EFX_BUG_ON_PARANOID(efx->phy_op->num_tests == 0 ||
+			    efx->phy_op->num_tests > EFX_MAX_PHY_TESTS);
+
 	mutex_lock(&efx->mac_lock);
-	rc = efx->phy_op->test(efx);
+	rc = efx->phy_op->run_tests(efx, tests->phy, flags);
 	mutex_unlock(&efx->mac_lock);
-	tests->phy = rc ? -1 : 1;
 	return rc;
 }
 
@@ -691,7 +694,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 		return rc_test;
 
 	if (!(flags & ETH_TEST_FL_OFFLINE))
-		return 0;
+		return efx_test_phy(efx, tests, flags);
 
 	/* Offline (i.e. disruptive) testing
 	 * This checks MAC and PHY loopback on the specified port. */
@@ -739,7 +742,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 		return rc_reset;
 	}
 
-	rc = efx_test_phy(efx, tests);
+	rc = efx_test_phy(efx, tests, flags);
 	if (rc && !rc_test)
 		rc_test = rc;
 
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index 97d6acc..39451cf 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -24,6 +24,8 @@ struct efx_loopback_self_tests {
 	int rx_bad;
 };
 
+#define EFX_MAX_PHY_TESTS 20
+
 /* Efx self test results
  * For fields which are not counters, 1 indicates success and -1
  * indicates failure.
@@ -38,7 +40,7 @@ struct efx_self_tests {
 	int eventq_poll[EFX_MAX_CHANNELS];
 	/* offline tests */
 	int registers;
-	int phy;
+	int phy[EFX_MAX_PHY_TESTS];
 	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX + 1];
 };
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 1567ab5..bd20482 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -654,10 +654,22 @@ void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 			    PMA_PMD_LED_OVERR_REG, reg);
 }
 
-static int tenxpress_phy_test(struct efx_nic *efx)
+static const char *const tenxpress_test_names[] = {
+	"bist"
+};
+
+static int
+tenxpress_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 {
+	int rc;
+
+	if (!(flags & ETH_TEST_FL_OFFLINE))
+		return 0;
+
 	/* BIST is automatically run after a special software reset */
-	return tenxpress_special_reset(efx);
+	rc = tenxpress_special_reset(efx);
+	results[0] = rc ? -1 : 1;
+	return rc;
 }
 
 static u32 tenxpress_get_xnp_lpa(struct efx_nic *efx)
@@ -770,9 +782,11 @@ struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.poll             = tenxpress_phy_poll,
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = efx_port_dummy_op_void,
-	.test             = tenxpress_phy_test,
 	.get_settings	  = sfx7101_get_settings,
 	.set_settings	  = mdio_clause45_set_settings,
+	.num_tests	  = ARRAY_SIZE(tenxpress_test_names),
+	.test_names	  = tenxpress_test_names,
+	.run_tests	  = tenxpress_run_tests,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = SFX7101_LOOPBACKS,
 };
@@ -784,10 +798,12 @@ struct efx_phy_operations falcon_sft9001_phy_ops = {
 	.poll             = tenxpress_phy_poll,
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = efx_port_dummy_op_void,
-	.test             = tenxpress_phy_test,
 	.get_settings	  = sft9001_get_settings,
 	.set_settings	  = sft9001_set_settings,
 	.set_xnp_advertise = sft9001_set_xnp_advertise,
+	.num_tests	  = ARRAY_SIZE(tenxpress_test_names),
+	.test_names	  = tenxpress_test_names,
+	.run_tests	  = tenxpress_run_tests,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = SFT9001_LOOPBACKS,
 };

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
