From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/8] sfc: Merge top-level functions for self-tests
Date: Thu, 25 Dec 2008 03:40:13 +0000
Message-ID: <1230176413.3401.45.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3917 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751551AbYLYDkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:40:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass in ethtool test flags to determine which tests to run.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c  |   19 +++--------
 drivers/net/sfc/selftest.c |   76 +++++++++++++++++++++++---------------------
 drivers/net/sfc/selftest.h |    8 ++---
 3 files changed, 48 insertions(+), 55 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 3aaece6..7fa2844 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -487,7 +487,7 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_self_tests efx_tests;
-	int offline, already_up;
+	int already_up;
 	int rc;
 
 	ASSERT_RTNL();
@@ -507,24 +507,15 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 	}
 
 	memset(&efx_tests, 0, sizeof(efx_tests));
-	offline = (test->flags & ETH_TEST_FL_OFFLINE);
 
-	/* Perform online self tests first */
-	rc = efx_online_test(efx, &efx_tests);
-	if (rc)
-		goto out;
-
-	/* Perform offline tests only if online tests passed */
-	if (offline)
-		rc = efx_offline_test(efx, &efx_tests,
-				      efx->loopback_modes);
+	rc = efx_selftest(efx, &efx_tests, test->flags);
 
- out:
 	if (!already_up)
 		dev_close(efx->net_dev);
 
-	EFX_LOG(efx, "%s all %sline self-tests\n",
-		rc == 0 ? "passed" : "failed", offline ? "off" : "on");
+	EFX_LOG(efx, "%s %sline self-tests\n",
+		rc == 0 ? "passed" : "failed",
+		(test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
 
  fail2:
  fail1:
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 7813ab3..d10f6fb 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -653,47 +653,48 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 
 /**************************************************************************
  *
- * Entry points
+ * Entry point
  *
  *************************************************************************/
 
-/* Online (i.e. non-disruptive) testing
- * This checks interrupt generation, event delivery and PHY presence. */
-int efx_online_test(struct efx_nic *efx, struct efx_self_tests *tests)
+int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
+		 unsigned flags)
 {
+	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
+	int phy_mode = efx->phy_mode;
+	struct ethtool_cmd ecmd;
 	struct efx_channel *channel;
-	int rc, rc2 = 0;
+	int rc_test = 0, rc_reset = 0, rc;
+
+	/* Online (i.e. non-disruptive) testing
+	 * This checks interrupt generation, event delivery and PHY presence. */
 
 	rc = efx_test_mii(efx, tests);
-	if (rc && !rc2)
-		rc2 = rc;
+	if (rc && !rc_test)
+		rc_test = rc;
 
 	rc = efx_test_nvram(efx, tests);
-	if (rc && !rc2)
-		rc2 = rc;
+	if (rc && !rc_test)
+		rc_test = rc;
 
 	rc = efx_test_interrupts(efx, tests);
-	if (rc && !rc2)
-		rc2 = rc;
+	if (rc && !rc_test)
+		rc_test = rc;
 
 	efx_for_each_channel(channel, efx) {
 		rc = efx_test_eventq_irq(channel, tests);
-		if (rc && !rc2)
-			rc2 = rc;
+		if (rc && !rc_test)
+			rc_test = rc;
 	}
 
-	return rc2;
-}
+	if (rc_test)
+		return rc_test;
 
-/* Offline (i.e. disruptive) testing
- * This checks MAC and PHY loopback on the specified port. */
-int efx_offline_test(struct efx_nic *efx,
-		     struct efx_self_tests *tests, unsigned int loopback_modes)
-{
-	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
-	int phy_mode = efx->phy_mode;
-	struct ethtool_cmd ecmd;
-	int rc, rc2 = 0;
+	if (!(flags & ETH_TEST_FL_OFFLINE))
+		return 0;
+
+	/* Offline (i.e. disruptive) testing
+	 * This checks MAC and PHY loopback on the specified port. */
 
 	/* force the carrier state off so the kernel doesn't transmit during
 	 * the loopback test, and the watchdog timeout doesn't fire. Also put
@@ -717,31 +718,34 @@ int efx_offline_test(struct efx_nic *efx,
 	efx_reset_down(efx, &ecmd);
 
 	rc = efx_test_chip(efx, tests);
-	if (rc && !rc2)
-		rc2 = rc;
+	if (rc && !rc_test)
+		rc_test = rc;
 
 	/* reset the chip to recover from the register test */
-	rc = falcon_reset_hw(efx, RESET_TYPE_ALL);
+	rc_reset = falcon_reset_hw(efx, RESET_TYPE_ALL);
 
 	/* Ensure that the phy is powered and out of loopback
 	 * for the bist and loopback tests */
 	efx->phy_mode &= ~PHY_MODE_LOW_POWER;
 	efx->loopback_mode = LOOPBACK_NONE;
 
-	rc = efx_reset_up(efx, &ecmd, rc == 0);
-	if (rc) {
+	rc = efx_reset_up(efx, &ecmd, rc_reset == 0);
+	if (rc && !rc_reset)
+		rc_reset = rc;
+
+	if (rc_reset) {
 		EFX_ERR(efx, "Unable to recover from chip test\n");
 		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
-		return rc;
+		return rc_reset;
 	}
 
 	rc = efx_test_phy(efx, tests);
-	if (rc && !rc2)
-		rc2 = rc;
+	if (rc && !rc_test)
+		rc_test = rc;
 
-	rc = efx_test_loopbacks(efx, tests, loopback_modes);
-	if (rc && !rc2)
-		rc2 = rc;
+	rc = efx_test_loopbacks(efx, tests, efx->loopback_modes);
+	if (rc && !rc_test)
+		rc_test = rc;
 
 	/* restore the PHY to the previous state */
 	efx->loopback_mode = loopback_mode;
@@ -749,6 +753,6 @@ int efx_offline_test(struct efx_nic *efx,
 	efx->port_inhibited = false;
 	efx_ethtool_set_settings(efx->net_dev, &ecmd);
 
-	return rc2;
+	return rc_test;
 }
 
diff --git a/drivers/net/sfc/selftest.h b/drivers/net/sfc/selftest.h
index 252f7d7..97d6acc 100644
--- a/drivers/net/sfc/selftest.h
+++ b/drivers/net/sfc/selftest.h
@@ -44,10 +44,8 @@ struct efx_self_tests {
 
 extern void efx_loopback_rx_packet(struct efx_nic *efx,
 				   const char *buf_ptr, int pkt_len);
-extern int efx_online_test(struct efx_nic *efx,
-			   struct efx_self_tests *tests);
-extern int efx_offline_test(struct efx_nic *efx,
-			    struct efx_self_tests *tests,
-			    unsigned int loopback_modes);
+extern int efx_selftest(struct efx_nic *efx,
+			struct efx_self_tests *tests,
+			unsigned flags);
 
 #endif /* EFX_SELFTEST_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
