From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/10] sfc: Replace PHY MDIO test with an 'alive' test
Date: Wed, 03 Feb 2010 19:30:50 +0000
Message-ID: <1265225450.2116.4.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28020 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757562Ab0BCTax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:30:53 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFC9000-family boards do not all use MDIO PHYs, so we need a different
test for PHY aliveness.

Introduce a PHY operation test_alive().  For PHYs attached to Falcon,
use a common implementation based on the existing PHY MDIO test.
For PHYs managed through MCDI, use the appropriate MCDI request.

Change test name in ethtool from 'core mdio' to 'phy alive'.

Rename test_results::mdio to phy_alive and test_results::phy to phy_ext.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c    |    6 +++---
 drivers/net/sfc/mcdi_phy.c   |   22 ++++++++++++++++++++++
 drivers/net/sfc/mdio_10g.c   |   24 ++++++++++++++++++++++++
 drivers/net/sfc/mdio_10g.h   |    3 +++
 drivers/net/sfc/net_driver.h |    4 +++-
 drivers/net/sfc/qt202x_phy.c |    1 +
 drivers/net/sfc/selftest.c   |   40 ++++++----------------------------------
 drivers/net/sfc/selftest.h   |    4 ++--
 drivers/net/sfc/tenxpress.c  |    2 ++
 9 files changed, 66 insertions(+), 40 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 6c0bbed..635c420 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -342,8 +342,8 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 	unsigned int n = 0, i;
 	enum efx_loopback_mode mode;
 
-	efx_fill_test(n++, strings, data, &tests->mdio,
-		      "core", 0, "mdio", NULL);
+	efx_fill_test(n++, strings, data, &tests->phy_alive,
+		      "phy", 0, "alive", NULL);
 	efx_fill_test(n++, strings, data, &tests->nvram,
 		      "core", 0, "nvram", NULL);
 	efx_fill_test(n++, strings, data, &tests->interrupt,
@@ -379,7 +379,7 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 			if (name == NULL)
 				break;
 
-			efx_fill_test(n++, strings, data, &tests->phy[i],
+			efx_fill_test(n++, strings, data, &tests->phy_ext[i],
 				      "phy", 0, name, NULL);
 		}
 	}
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index d87e74d..34c22fa 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -572,6 +572,27 @@ static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ec
 	return 0;
 }
 
+static int efx_mcdi_phy_test_alive(struct efx_nic *efx)
+{
+	u8 outbuf[MC_CMD_GET_PHY_STATE_OUT_LEN];
+	size_t outlen;
+	int rc;
+
+	BUILD_BUG_ON(MC_CMD_GET_PHY_STATE_IN_LEN != 0);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_PHY_STATE, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		return rc;
+
+	if (outlen < MC_CMD_GET_PHY_STATE_OUT_LEN)
+		return -EMSGSIZE;
+	if (MCDI_DWORD(outbuf, GET_PHY_STATE_STATE) != MC_CMD_PHY_STATE_OK)
+		return -EINVAL;
+
+	return 0;
+}
+
 struct efx_phy_operations efx_mcdi_phy_ops = {
 	.probe		= efx_mcdi_phy_probe,
 	.init 	 	= efx_port_dummy_op_int,
@@ -581,6 +602,7 @@ struct efx_phy_operations efx_mcdi_phy_ops = {
 	.remove		= efx_mcdi_phy_remove,
 	.get_settings	= efx_mcdi_phy_get_settings,
 	.set_settings	= efx_mcdi_phy_set_settings,
+	.test_alive	= efx_mcdi_phy_test_alive,
 	.run_tests	= NULL,
 	.test_name	= NULL,
 };
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 1574e52..0548fcb 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -335,3 +335,27 @@ enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx)
 		mii_advertise_flowctrl(efx->wanted_fc),
 		efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_LPA));
 }
+
+int efx_mdio_test_alive(struct efx_nic *efx)
+{
+	int rc;
+	int devad = __ffs(efx->mdio.mmds);
+	u16 physid1, physid2;
+
+	mutex_lock(&efx->mac_lock);
+
+	physid1 = efx_mdio_read(efx, devad, MDIO_DEVID1);
+	physid2 = efx_mdio_read(efx, devad, MDIO_DEVID2);
+
+	if ((physid1 == 0x0000) || (physid1 == 0xffff) ||
+	    (physid2 == 0x0000) || (physid2 == 0xffff)) {
+		EFX_ERR(efx, "no MDIO PHY present with ID %d\n",
+			efx->mdio.prtad);
+		rc = -EINVAL;
+	} else {
+		rc = efx_mdio_check_mmds(efx, efx->mdio.mmds, 0);
+	}
+
+	mutex_unlock(&efx->mac_lock);
+	return rc;
+}
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index f6ac950..f89e719 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -106,4 +106,7 @@ efx_mdio_set_flag(struct efx_nic *efx, int devad, int addr,
 	mdio_set_flag(&efx->mdio, efx->mdio.prtad, devad, addr, mask, state);
 }
 
+/* Liveness self-test for MDIO PHYs */
+extern int efx_mdio_test_alive(struct efx_nic *efx);
+
 #endif /* EFX_MDIO_10G_H */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index d5aab5b..8f951e4 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -516,8 +516,9 @@ struct efx_mac_operations {
  * @set_settings: Set ethtool settings. Serialised by the mac_lock.
  * @set_npage_adv: Set abilities advertised in (Extended) Next Page
  *	(only needed where AN bit is set in mmds)
+ * @test_alive: Test that PHY is 'alive' (online)
  * @test_name: Get the name of a PHY-specific test/result
- * @run_tests: Run tests and record results as appropriate.
+ * @run_tests: Run tests and record results as appropriate (offline).
  *	Flags are the ethtool tests flags.
  */
 struct efx_phy_operations {
@@ -532,6 +533,7 @@ struct efx_phy_operations {
 	int (*set_settings) (struct efx_nic *efx,
 			     struct ethtool_cmd *ecmd);
 	void (*set_npage_adv) (struct efx_nic *efx, u32);
+	int (*test_alive) (struct efx_nic *efx);
 	const char *(*test_name) (struct efx_nic *efx, unsigned int index);
 	int (*run_tests) (struct efx_nic *efx, int *results, unsigned flags);
 };
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index e0d13a4..14793d8 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -445,4 +445,5 @@ struct efx_phy_operations falcon_qt202x_phy_ops = {
 	.remove	  	 = qt202x_phy_remove,
 	.get_settings	 = qt202x_phy_get_settings,
 	.set_settings	 = efx_mdio_set_settings,
+	.test_alive	 = efx_mdio_test_alive,
 };
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 250c882..8a5a7b6 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -26,7 +26,6 @@
 #include "workarounds.h"
 #include "spi.h"
 #include "io.h"
-#include "mdio_10g.h"
 
 /*
  * Loopback test packet structure
@@ -76,42 +75,15 @@ struct efx_loopback_state {
  *
  **************************************************************************/
 
-static int efx_test_mdio(struct efx_nic *efx, struct efx_self_tests *tests)
+static int efx_test_phy_alive(struct efx_nic *efx, struct efx_self_tests *tests)
 {
 	int rc = 0;
-	int devad;
-	u16 physid1, physid2;
-
-	if (efx->mdio.mode_support & MDIO_SUPPORTS_C45)
-		devad = __ffs(efx->mdio.mmds);
-	else if (efx->mdio.mode_support & MDIO_SUPPORTS_C22)
-		devad = MDIO_DEVAD_NONE;
-	else
-		return 0;
-
-	mutex_lock(&efx->mac_lock);
-	tests->mdio = -1;
-
-	physid1 = efx_mdio_read(efx, devad, MDIO_DEVID1);
-	physid2 = efx_mdio_read(efx, devad, MDIO_DEVID2);
 
-	if ((physid1 == 0x0000) || (physid1 == 0xffff) ||
-	    (physid2 == 0x0000) || (physid2 == 0xffff)) {
-		EFX_ERR(efx, "no MDIO PHY present with ID %d\n",
-			efx->mdio.prtad);
-		rc = -EINVAL;
-		goto out;
+	if (efx->phy_op->test_alive) {
+		rc = efx->phy_op->test_alive(efx);
+		tests->phy_alive = rc ? -1 : 1;
 	}
 
-	if (EFX_IS10G(efx)) {
-		rc = efx_mdio_check_mmds(efx, efx->mdio.mmds, 0);
-		if (rc)
-			goto out;
-	}
-
-out:
-	mutex_unlock(&efx->mac_lock);
-	tests->mdio = rc ? -1 : 1;
 	return rc;
 }
 
@@ -258,7 +230,7 @@ static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests,
 		return 0;
 
 	mutex_lock(&efx->mac_lock);
-	rc = efx->phy_op->run_tests(efx, tests->phy, flags);
+	rc = efx->phy_op->run_tests(efx, tests->phy_ext, flags);
 	mutex_unlock(&efx->mac_lock);
 	return rc;
 }
@@ -684,7 +656,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* Online (i.e. non-disruptive) testing
 	 * This checks interrupt generation, event delivery and PHY presence. */
 
-	rc = efx_test_mdio(efx, tests);
+	rc = efx_test_phy_alive(efx, tests);
 	if (rc && !rc_test)
 		rc_test = rc;
 
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index f6feee0..643bef7 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -32,7 +32,7 @@ struct efx_loopback_self_tests {
  */
 struct efx_self_tests {
 	/* online tests */
-	int mdio;
+	int phy_alive;
 	int nvram;
 	int interrupt;
 	int eventq_dma[EFX_MAX_CHANNELS];
@@ -40,7 +40,7 @@ struct efx_self_tests {
 	int eventq_poll[EFX_MAX_CHANNELS];
 	/* offline tests */
 	int registers;
-	int phy[EFX_MAX_PHY_TESTS];
+	int phy_ext[EFX_MAX_PHY_TESTS];
 	struct efx_loopback_self_tests loopback[LOOPBACK_TEST_MAX + 1];
 };
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 3009c29..10db071 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -842,6 +842,7 @@ struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.get_settings	  = tenxpress_get_settings,
 	.set_settings	  = tenxpress_set_settings,
 	.set_npage_adv    = sfx7101_set_npage_adv,
+	.test_alive	  = efx_mdio_test_alive,
 	.test_name	  = sfx7101_test_name,
 	.run_tests	  = sfx7101_run_tests,
 };
@@ -856,6 +857,7 @@ struct efx_phy_operations falcon_sft9001_phy_ops = {
 	.get_settings	  = tenxpress_get_settings,
 	.set_settings	  = tenxpress_set_settings,
 	.set_npage_adv    = sft9001_set_npage_adv,
+	.test_alive	  = efx_mdio_test_alive,
 	.test_name	  = sft9001_test_name,
 	.run_tests	  = sft9001_run_tests,
 };
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

