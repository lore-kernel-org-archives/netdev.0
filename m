From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/11] sfc: Reinitialise the PHY completely in case of a PHY or NIC reset
Date: Fri, 30 Jan 2009 03:50:51 +0000
Message-ID: <20090130035051.GH15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:57543 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754610AbZA3Duy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:50:54 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

In particular, set pause advertising bits properly.

A PHY reset is not necessary to recover from the register self-test,
so use a "invisible" reset there instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c       |   26 +++++++++++++++++++-------
 drivers/net/sfc/efx.h       |    7 ++++---
 drivers/net/sfc/selftest.c  |    7 ++++---
 drivers/net/sfc/tenxpress.c |    1 +
 4 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7673fd9..b0e5308 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -676,9 +676,8 @@ static int efx_init_port(struct efx_nic *efx)
 	rc = efx->phy_op->init(efx);
 	if (rc)
 		return rc;
-	efx->phy_op->reconfigure(efx);
-
 	mutex_lock(&efx->mac_lock);
+	efx->phy_op->reconfigure(efx);
 	rc = falcon_switch_mac(efx);
 	mutex_unlock(&efx->mac_lock);
 	if (rc)
@@ -1622,7 +1621,8 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 
 /* Tears down the entire software state and most of the hardware state
  * before reset.  */
-void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+void efx_reset_down(struct efx_nic *efx, enum reset_type method,
+		    struct ethtool_cmd *ecmd)
 {
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
@@ -1639,6 +1639,8 @@ void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	efx->phy_op->get_settings(efx, ecmd);
 
 	efx_fini_channels(efx);
+	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE)
+		efx->phy_op->fini(efx);
 }
 
 /* This function will always ensure that the locks acquired in
@@ -1646,7 +1648,8 @@ void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
  * that we were unable to reinitialise the hardware, and the
  * driver should be disabled. If ok is false, then the rx and tx
  * engines are not restarted, pending a RESET_DISABLE. */
-int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool ok)
+int efx_reset_up(struct efx_nic *efx, enum reset_type method,
+		 struct ethtool_cmd *ecmd, bool ok)
 {
 	int rc;
 
@@ -1658,6 +1661,15 @@ int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd, bool ok)
 		ok = false;
 	}
 
+	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE) {
+		if (ok) {
+			rc = efx->phy_op->init(efx);
+			if (rc)
+				ok = false;
+		} else
+			efx->port_initialized = false;
+	}
+
 	if (ok) {
 		efx_init_channels(efx);
 
@@ -1702,7 +1714,7 @@ static int efx_reset(struct efx_nic *efx)
 
 	EFX_INFO(efx, "resetting (%d)\n", method);
 
-	efx_reset_down(efx, &ecmd);
+	efx_reset_down(efx, method, &ecmd);
 
 	rc = falcon_reset_hw(efx, method);
 	if (rc) {
@@ -1721,10 +1733,10 @@ static int efx_reset(struct efx_nic *efx)
 
 	/* Leave device stopped if necessary */
 	if (method == RESET_TYPE_DISABLE) {
-		efx_reset_up(efx, &ecmd, false);
+		efx_reset_up(efx, method, &ecmd, false);
 		rc = -EIO;
 	} else {
-		rc = efx_reset_up(efx, &ecmd, true);
+		rc = efx_reset_up(efx, method, &ecmd, true);
 	}
 
 out_disable:
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 0dd7a53..ac20158 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -40,9 +40,10 @@ extern void efx_reconfigure_port(struct efx_nic *efx);
 extern void __efx_reconfigure_port(struct efx_nic *efx);
 
 /* Reset handling */
-extern void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd);
-extern int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd,
-			bool ok);
+extern void efx_reset_down(struct efx_nic *efx, enum reset_type method,
+			   struct ethtool_cmd *ecmd);
+extern int efx_reset_up(struct efx_nic *efx, enum reset_type method,
+			struct ethtool_cmd *ecmd, bool ok);
 
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index dba0d64..0a59808 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -665,6 +665,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 {
 	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
 	int phy_mode = efx->phy_mode;
+	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
 	struct ethtool_cmd ecmd;
 	struct efx_channel *channel;
 	int rc_test = 0, rc_reset = 0, rc;
@@ -718,21 +719,21 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	mutex_unlock(&efx->mac_lock);
 
 	/* free up all consumers of SRAM (including all the queues) */
-	efx_reset_down(efx, &ecmd);
+	efx_reset_down(efx, reset_method, &ecmd);
 
 	rc = efx_test_chip(efx, tests);
 	if (rc && !rc_test)
 		rc_test = rc;
 
 	/* reset the chip to recover from the register test */
-	rc_reset = falcon_reset_hw(efx, RESET_TYPE_ALL);
+	rc_reset = falcon_reset_hw(efx, reset_method);
 
 	/* Ensure that the phy is powered and out of loopback
 	 * for the bist and loopback tests */
 	efx->phy_mode &= ~PHY_MODE_LOW_POWER;
 	efx->loopback_mode = LOOPBACK_NONE;
 
-	rc = efx_reset_up(efx, &ecmd, rc_reset == 0);
+	rc = efx_reset_up(efx, reset_method, &ecmd, rc_reset == 0);
 	if (rc && !rc_reset)
 		rc_reset = rc;
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index bc2833f..c958461 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -337,6 +337,7 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	rc = tenxpress_init(efx);
 	if (rc < 0)
 		goto fail;
+	mdio_clause45_set_pause(efx);
 
 	if (efx->phy_type == PHY_TYPE_SFT9001B) {
 		rc = device_create_file(&efx->pci_dev->dev,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
