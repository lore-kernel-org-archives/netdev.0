From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/20] sfc: SFT9001: Include non-breaking cable diagnostics
	in online self-tests
Date: Thu, 29 Jan 2009 19:15:21 +0000
Message-ID: <1233256521.3656.12.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:53141 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbZA2TPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:15:24 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |   45 ++++++++++++++++++++++--------------------
 1 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 9ecb77d..9f5c8b8 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -708,12 +708,10 @@ static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 {
 	struct ethtool_cmd ecmd;
 	int phy_id = efx->mii.phy_id;
-	int rc = 0, rc2, i, res_reg;
+	int rc = 0, rc2, i, ctrl_reg, res_reg;
 
-	if (!(flags & ETH_TEST_FL_OFFLINE))
-		return 0;
-
-	efx->phy_op->get_settings(efx, &ecmd);
+	if (flags & ETH_TEST_FL_OFFLINE)
+		efx->phy_op->get_settings(efx, &ecmd);
 
 	/* Initialise cable diagnostic results to unknown failure */
 	for (i = 1; i < 9; ++i)
@@ -721,18 +719,22 @@ static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 
 	/* Run cable diagnostics; wait up to 5 seconds for them to complete.
 	 * A cable fault is not a self-test failure, but a timeout is. */
+	ctrl_reg = ((1 << CDIAG_CTRL_IMMED_LBN) |
+		    (CDIAG_CTRL_LEN_METRES << CDIAG_CTRL_LEN_UNIT_LBN));
+	if (flags & ETH_TEST_FL_OFFLINE) {
+		/* Break the link in order to run full diagnostics.  We
+		 * must reset the PHY to resume normal service. */
+		ctrl_reg |= (1 << CDIAG_CTRL_BRK_LINK_LBN);
+	}
 	mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_CDIAG_CTRL_REG,
-			    (1 << CDIAG_CTRL_IMMED_LBN) |
-			    (1 << CDIAG_CTRL_BRK_LINK_LBN) |
-			    (CDIAG_CTRL_LEN_METRES << CDIAG_CTRL_LEN_UNIT_LBN));
+			    PMA_PMD_CDIAG_CTRL_REG, ctrl_reg);
 	i = 0;
 	while (mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
 				  PMA_PMD_CDIAG_CTRL_REG) &
 	       (1 << CDIAG_CTRL_IN_PROG_LBN)) {
 		if (++i == 50) {
 			rc = -ETIMEDOUT;
-			goto reset;
+			goto out;
 		}
 		msleep(100);
 	}
@@ -757,17 +759,18 @@ static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 			results[5 + i] = len_reg;
 	}
 
-	/* We must reset to exit cable diagnostic mode.  The BIST will
-	 * also run when we do this. */
-reset:
-	rc2 = tenxpress_special_reset(efx);
-	results[0] = rc2 ? -1 : 1;
-	if (!rc)
-		rc = rc2;
-
-	rc2 = efx->phy_op->set_settings(efx, &ecmd);
-	if (!rc)
-		rc = rc2;
+out:
+	if (flags & ETH_TEST_FL_OFFLINE) {
+		/* Reset, running the BIST and then resuming normal service. */
+		rc2 = tenxpress_special_reset(efx);
+		results[0] = rc2 ? -1 : 1;
+		if (!rc)
+			rc = rc2;
+
+		rc2 = efx->phy_op->set_settings(efx, &ecmd);
+		if (!rc)
+			rc = rc2;
+	}
 
 	return rc;
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

