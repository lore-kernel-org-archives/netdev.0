From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/8] sfc: Clean up PHY mode management in loopback self-test
Date: Thu, 25 Dec 2008 03:39:29 +0000
Message-ID: <1230176369.3401.43.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3912 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbYLYDjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:39:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 6bb09f2..7813ab3 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -564,8 +564,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 	return 0;
 }
 
-static int efx_test_loopbacks(struct efx_nic *efx, struct ethtool_cmd ecmd,
-			      struct efx_self_tests *tests,
+static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 			      unsigned int loopback_modes)
 {
 	enum efx_loopback_mode mode;
@@ -693,7 +692,7 @@ int efx_offline_test(struct efx_nic *efx,
 {
 	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
 	int phy_mode = efx->phy_mode;
-	struct ethtool_cmd ecmd, ecmd_test;
+	struct ethtool_cmd ecmd;
 	int rc, rc2 = 0;
 
 	/* force the carrier state off so the kernel doesn't transmit during
@@ -724,16 +723,12 @@ int efx_offline_test(struct efx_nic *efx,
 	/* reset the chip to recover from the register test */
 	rc = falcon_reset_hw(efx, RESET_TYPE_ALL);
 
-	/* Modify the saved ecmd so that when efx_reset_up() restores the phy
-	 * state, AN is disabled, and the phy is powered, and out of loopback */
-	memcpy(&ecmd_test, &ecmd, sizeof(ecmd_test));
-	if (ecmd_test.autoneg == AUTONEG_ENABLE) {
-		ecmd_test.autoneg = AUTONEG_DISABLE;
-		ecmd_test.duplex = DUPLEX_FULL;
-	}
+	/* Ensure that the phy is powered and out of loopback
+	 * for the bist and loopback tests */
+	efx->phy_mode &= ~PHY_MODE_LOW_POWER;
 	efx->loopback_mode = LOOPBACK_NONE;
 
-	rc = efx_reset_up(efx, &ecmd_test, rc == 0);
+	rc = efx_reset_up(efx, &ecmd, rc == 0);
 	if (rc) {
 		EFX_ERR(efx, "Unable to recover from chip test\n");
 		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
@@ -744,7 +739,7 @@ int efx_offline_test(struct efx_nic *efx,
 	if (rc && !rc2)
 		rc2 = rc;
 
-	rc = efx_test_loopbacks(efx, ecmd_test, tests, loopback_modes);
+	rc = efx_test_loopbacks(efx, tests, loopback_modes);
 	if (rc && !rc2)
 		rc2 = rc;
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
