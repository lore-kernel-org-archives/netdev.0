From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 36/52] sfc: Cleanup reset code
Date: Mon, 1 Sep 2008 12:48:50 +0100
Message-ID: <20080901114849.GD7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:41699 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758853AbYIALsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:52 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move more code from efx_reset() into efx_reset_down() and efx_reset_up().

Stop propagating MAC/PHY setting failures from efx_reset_down() and
efx_reset_up() as these should not be fatal.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   98 ++++++++++++++++++++----------------------------
 1 files changed, 41 insertions(+), 57 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f226dcf..f34dbf2 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1527,46 +1527,58 @@ static void efx_unregister_netdev(struct efx_nic *efx)
  *
  **************************************************************************/
 
-/* The final hardware and software finalisation before reset. */
-static int efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+/* Tears down the entire software state and most of the hardware state
+ * before reset.  */
+static void efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
+	/* The net_dev->get_stats handler is quite slow, and will fail
+	 * if a fetch is pending over reset. Serialise against it. */
+	spin_lock(&efx->stats_lock);
+	spin_unlock(&efx->stats_lock);
+
+	efx_stop_all(efx);
+	mutex_lock(&efx->mac_lock);
+
 	rc = falcon_xmac_get_settings(efx, ecmd);
-	if (rc) {
+	if (rc)
 		EFX_ERR(efx, "could not back up PHY settings\n");
-		goto fail;
-	}
 
 	efx_fini_channels(efx);
-	return 0;
-
- fail:
-	return rc;
 }
 
-/* The first part of software initialisation after a hardware reset
- * This function does not handle serialisation with the kernel, it
- * assumes the caller has done this */
-static int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+/* This function will always ensure that the locks acquired in
+ * efx_reset_down() are released. A failure return code indicates
+ * that we were unable to reinitialise the hardware, and the
+ * driver should be disabled. If ok is false, then the rx and tx
+ * engines are not restarted, pending a RESET_DISABLE. */
+static int efx_reset_up(struct efx_nic *efx, struct ethtool_cmd *ecmd,
+			bool ok)
 {
 	int rc;
 
-	efx_init_channels(efx);
+	EFX_ASSERT_RESET_SERIALISED(efx);
 
-	/* Restore MAC and PHY settings. */
-	rc = falcon_xmac_set_settings(efx, ecmd);
+	rc = falcon_init_nic(efx);
 	if (rc) {
-		EFX_ERR(efx, "could not restore PHY settings\n");
-		goto fail;
+		EFX_ERR(efx, "failed to initialise NIC\n");
+		ok = false;
 	}
 
-	return 0;
+	if (ok) {
+		efx_init_channels(efx);
 
- fail:
-	efx_fini_channels(efx);
+		if (falcon_xmac_set_settings(efx, ecmd))
+			EFX_ERR(efx, "could not restore PHY settings\n");
+	}
+
+	mutex_unlock(&efx->mac_lock);
+
+	if (ok)
+		efx_start_all(efx);
 	return rc;
 }
 
@@ -1598,22 +1610,12 @@ static int efx_reset(struct efx_nic *efx)
 	efx->state = STATE_RESETTING;
 	EFX_INFO(efx, "resetting (%d)\n", method);
 
-	/* The net_dev->get_stats handler is quite slow, and will fail
-	 * if a fetch is pending over reset. Serialise against it. */
-	spin_lock(&efx->stats_lock);
-	spin_unlock(&efx->stats_lock);
-
-	efx_stop_all(efx);
-	mutex_lock(&efx->mac_lock);
-
-	rc = efx_reset_down(efx, &ecmd);
-	if (rc)
-		goto fail1;
+	efx_reset_down(efx, &ecmd);
 
 	rc = falcon_reset_hw(efx, method);
 	if (rc) {
 		EFX_ERR(efx, "failed to reset hardware\n");
-		goto fail2;
+		goto fail;
 	}
 
 	/* Allow resets to be rescheduled. */
@@ -1625,46 +1627,28 @@ static int efx_reset(struct efx_nic *efx)
 	 * can respond to requests. */
 	pci_set_master(efx->pci_dev);
 
-	/* Reinitialise device. This is appropriate in the RESET_TYPE_DISABLE
-	 * case so the driver can talk to external SRAM */
-	rc = falcon_init_nic(efx);
-	if (rc) {
-		EFX_ERR(efx, "failed to initialise NIC\n");
-		goto fail3;
-	}
-
 	/* Leave device stopped if necessary */
 	if (method == RESET_TYPE_DISABLE) {
-		/* Reinitialise the device anyway so the driver unload sequence
-		 * can talk to the external SRAM */
-		falcon_init_nic(efx);
 		rc = -EIO;
-		goto fail4;
+		goto fail;
 	}
 
-	rc = efx_reset_up(efx, &ecmd);
+	rc = efx_reset_up(efx, &ecmd, true);
 	if (rc)
-		goto fail5;
+		goto disable;
 
-	mutex_unlock(&efx->mac_lock);
 	EFX_LOG(efx, "reset complete\n");
-
 	efx->state = STATE_RUNNING;
-	efx_start_all(efx);
-
  unlock_rtnl:
 	rtnl_unlock();
 	return 0;
 
- fail5:
- fail4:
- fail3:
- fail2:
- fail1:
+ fail:
+	efx_reset_up(efx, &ecmd, false);
+ disable:
 	EFX_ERR(efx, "has been disabled\n");
 	efx->state = STATE_DISABLED;
 
-	mutex_unlock(&efx->mac_lock);
 	rtnl_unlock();
 	efx_unregister_netdev(efx);
 	efx_fini_port(efx);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

