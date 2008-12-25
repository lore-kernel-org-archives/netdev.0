From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 6/8] sfc: SFT9001: Add cable diagnostics
Date: Thu, 25 Dec 2008 03:41:39 +0000
Message-ID: <1230176499.3401.49.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:4332 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751641AbYLYDln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:41:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SFT9001 firmware implements cable diagnostics; run those and
include their results in a self-test.  In case of a cable fault, do
not fail the self-test as a whole; only faults in the NIC should cause
that.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |  115 ++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 107 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index bd20482..b976876 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -106,6 +106,25 @@
 #define PMA_PMD_SPEED_LBN        4
 #define PMA_PMD_SPEED_WIDTH      4
 
+/* Cable diagnostics - SFT9001 only */
+#define PMA_PMD_CDIAG_CTRL_REG  49213
+#define CDIAG_CTRL_IMMED_LBN    15
+#define CDIAG_CTRL_BRK_LINK_LBN 12
+#define CDIAG_CTRL_IN_PROG_LBN  11
+#define CDIAG_CTRL_LEN_UNIT_LBN 10
+#define CDIAG_CTRL_LEN_METRES   1
+#define PMA_PMD_CDIAG_RES_REG   49174
+#define CDIAG_RES_A_LBN         12
+#define CDIAG_RES_B_LBN         8
+#define CDIAG_RES_C_LBN         4
+#define CDIAG_RES_D_LBN         0
+#define CDIAG_RES_WIDTH         4
+#define CDIAG_RES_OPEN          2
+#define CDIAG_RES_OK            1
+#define CDIAG_RES_INVALID       0
+/* Set of 4 registers for pairs A-D */
+#define PMA_PMD_CDIAG_LEN_REG   49175
+
 /* Serdes control registers - SFT9001 only */
 #define PMA_PMD_CSERDES_CTRL_REG 64258
 /* Set the 156.25 MHz output to 312.5 MHz to drive Falcon's XMAC */
@@ -654,12 +673,12 @@ void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 			    PMA_PMD_LED_OVERR_REG, reg);
 }
 
-static const char *const tenxpress_test_names[] = {
+static const char *const sfx7101_test_names[] = {
 	"bist"
 };
 
 static int
-tenxpress_run_tests(struct efx_nic *efx, int *results, unsigned flags)
+sfx7101_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 {
 	int rc;
 
@@ -672,6 +691,86 @@ tenxpress_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 	return rc;
 }
 
+static const char *const sft9001_test_names[] = {
+	"bist",
+	"cable.pairA.status",
+	"cable.pairB.status",
+	"cable.pairC.status",
+	"cable.pairD.status",
+	"cable.pairA.length",
+	"cable.pairB.length",
+	"cable.pairC.length",
+	"cable.pairD.length",
+};
+
+static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
+{
+	struct ethtool_cmd ecmd;
+	int phy_id = efx->mii.phy_id;
+	int rc = 0, rc2, i, res_reg;
+
+	if (!(flags & ETH_TEST_FL_OFFLINE))
+		return 0;
+
+	efx->phy_op->get_settings(efx, &ecmd);
+
+	/* Initialise cable diagnostic results to unknown failure */
+	for (i = 1; i < 9; ++i)
+		results[i] = -1;
+
+	/* Run cable diagnostics; wait up to 5 seconds for them to complete.
+	 * A cable fault is not a self-test failure, but a timeout is. */
+	mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+			    PMA_PMD_CDIAG_CTRL_REG,
+			    (1 << CDIAG_CTRL_IMMED_LBN) |
+			    (1 << CDIAG_CTRL_BRK_LINK_LBN) |
+			    (CDIAG_CTRL_LEN_METRES << CDIAG_CTRL_LEN_UNIT_LBN));
+	i = 0;
+	while (mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+				  PMA_PMD_CDIAG_CTRL_REG) &
+	       (1 << CDIAG_CTRL_IN_PROG_LBN)) {
+		if (++i == 50) {
+			rc = -ETIMEDOUT;
+			goto reset;
+		}
+		msleep(100);
+	}
+	res_reg = mdio_clause45_read(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+				     PMA_PMD_CDIAG_RES_REG);
+	for (i = 0; i < 4; i++) {
+		int pair_res =
+			(res_reg >> (CDIAG_RES_A_LBN - i * CDIAG_RES_WIDTH))
+			& ((1 << CDIAG_RES_WIDTH) - 1);
+		int len_reg = mdio_clause45_read(efx, efx->mii.phy_id,
+						 MDIO_MMD_PMAPMD,
+						 PMA_PMD_CDIAG_LEN_REG + i);
+		if (pair_res == CDIAG_RES_OK)
+			results[1 + i] = 1;
+		else if (pair_res == CDIAG_RES_INVALID)
+			results[1 + i] = -1;
+		else
+			results[1 + i] = -pair_res;
+		if (pair_res != CDIAG_RES_INVALID &&
+		    pair_res != CDIAG_RES_OPEN &&
+		    len_reg != 0xffff)
+			results[5 + i] = len_reg;
+	}
+
+	/* We must reset to exit cable diagnostic mode.  The BIST will
+	 * also run when we do this. */
+reset:
+	rc2 = tenxpress_special_reset(efx);
+	results[0] = rc2 ? -1 : 1;
+	if (!rc)
+		rc = rc2;
+
+	rc2 = efx->phy_op->set_settings(efx, &ecmd);
+	if (!rc)
+		rc = rc2;
+
+	return rc;
+}
+
 static u32 tenxpress_get_xnp_lpa(struct efx_nic *efx)
 {
 	int phy = efx->mii.phy_id;
@@ -784,9 +883,9 @@ struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.clear_interrupt  = efx_port_dummy_op_void,
 	.get_settings	  = sfx7101_get_settings,
 	.set_settings	  = mdio_clause45_set_settings,
-	.num_tests	  = ARRAY_SIZE(tenxpress_test_names),
-	.test_names	  = tenxpress_test_names,
-	.run_tests	  = tenxpress_run_tests,
+	.num_tests	  = ARRAY_SIZE(sfx7101_test_names),
+	.test_names	  = sfx7101_test_names,
+	.run_tests	  = sfx7101_run_tests,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = SFX7101_LOOPBACKS,
 };
@@ -801,9 +900,9 @@ struct efx_phy_operations falcon_sft9001_phy_ops = {
 	.get_settings	  = sft9001_get_settings,
 	.set_settings	  = sft9001_set_settings,
 	.set_xnp_advertise = sft9001_set_xnp_advertise,
-	.num_tests	  = ARRAY_SIZE(tenxpress_test_names),
-	.test_names	  = tenxpress_test_names,
-	.run_tests	  = tenxpress_run_tests,
+	.num_tests	  = ARRAY_SIZE(sft9001_test_names),
+	.test_names	  = sft9001_test_names,
+	.run_tests	  = sft9001_run_tests,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = SFT9001_LOOPBACKS,
 };

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
