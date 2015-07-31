From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/1] sfc: allow ethtool selftest and MC reboot to
 complete on an unprivileged function
Date: Fri, 31 Jul 2015 11:14:54 +0100
Message-ID: <55BB4A9E.1090406@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:50528 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751037AbbGaKPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 06:15:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The policy in the net driver is to attempt MCDI commands and
then handle any EPERM error codes appropriately when returned
by unprivileged functions.
The ethtool selftest contains some tests which are useful on
an unprivileged function, such as the event queue interrupt
tests, but other tests cannot be performed as the function
does not have the required permissions.

If a test returns -EPERM, act as though the test was not run
and continue.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c     |  8 ++++++++
 drivers/net/ethernet/sfc/selftest.c | 14 +++++++++++++-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 8505d82..7e2e206 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1041,6 +1041,12 @@ static int efx_ef10_reset(struct efx_nic *efx, enum reset_type reset_type)
 {
 	int rc = efx_mcdi_reset(efx, reset_type);
 
+	/* Unprivileged functions return -EPERM, but need to return success
+	 * here so that the datapath is brought back up.
+	 */
+	if (reset_type == RESET_TYPE_WORLD && rc == -EPERM)
+		rc = 0;
+
 	/* If it was a port reset, trigger reallocation of MC resources.
 	 * Note that on an MC reset nothing needs to be done now because we'll
 	 * detect the MC reset later and handle it then.
@@ -4324,6 +4330,8 @@ efx_ef10_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 	rc = efx_mcdi_reset(efx, RESET_TYPE_WORLD);
 
 out:
+	if (rc == -EPERM)
+		rc = 0;
 	rc2 = efx_reset_up(efx, RESET_TYPE_WORLD, rc == 0);
 	return rc ? rc : rc2;
 }
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index b605dfd5..9d78830 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -114,7 +114,10 @@ static int efx_test_nvram(struct efx_nic *efx, struct efx_self_tests *tests)
 
 	if (efx->type->test_nvram) {
 		rc = efx->type->test_nvram(efx);
-		tests->nvram = rc ? -1 : 1;
+		if (rc == -EPERM)
+			rc = 0;
+		else
+			tests->nvram = rc ? -1 : 1;
 	}
 
 	return rc;
@@ -253,6 +256,12 @@ static int efx_test_phy(struct efx_nic *efx, struct efx_self_tests *tests,
 	mutex_lock(&efx->mac_lock);
 	rc = efx->phy_op->run_tests(efx, tests->phy_ext, flags);
 	mutex_unlock(&efx->mac_lock);
+	if (rc == -EPERM)
+		rc = 0;
+	else
+		netif_info(efx, drv, efx->net_dev,
+			   "%s phy selftest\n", rc ? "Failed" : "Passed");
+
 	return rc;
 }
 
@@ -661,6 +670,9 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 	wmb();
 	kfree(state);
 
+	if (rc == -EPERM)
+		rc = 0;
+
 	return rc;
 }
 
