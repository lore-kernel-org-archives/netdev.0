From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/12] sfc: Implement ethtool reset operation
Date: Sun, 29 Nov 2009 13:43:15 +0000
Message-ID: <1259502195.3709.47.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29159 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbZK2NnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 08:43:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor efx_reset_down() and efx_reset_up() accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   98 ++++++++++++++++++++---------------------
 drivers/net/sfc/efx.h        |    1 +
 drivers/net/sfc/ethtool.c    |   30 +++++++++++++
 drivers/net/sfc/falcon.c     |    2 +
 drivers/net/sfc/net_driver.h |    3 +
 5 files changed, 84 insertions(+), 50 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b016719..4b7168f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1754,58 +1754,49 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	rc = efx->type->init(efx);
 	if (rc) {
 		EFX_ERR(efx, "failed to initialise NIC\n");
-		ok = false;
+		goto fail;
 	}
 
+	if (!ok)
+		goto fail;
+
 	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE) {
-		if (ok) {
-			rc = efx->phy_op->init(efx);
-			if (rc)
-				ok = false;
-			if (efx->phy_op->reconfigure(efx))
-				EFX_ERR(efx, "could not restore PHY settings\n");
-		}
-		if (!ok)
-			efx->port_initialized = false;
+		rc = efx->phy_op->init(efx);
+		if (rc)
+			goto fail;
+		if (efx->phy_op->reconfigure(efx))
+			EFX_ERR(efx, "could not restore PHY settings\n");
 	}
 
-	if (ok) {
-		efx->mac_op->reconfigure(efx);
+	efx->mac_op->reconfigure(efx);
 
-		efx_init_channels(efx);
-	}
+	efx_init_channels(efx);
+
+	mutex_unlock(&efx->spi_lock);
+	mutex_unlock(&efx->mac_lock);
+
+	efx_start_all(efx);
+
+	return 0;
+
+fail:
+	efx->port_initialized = false;
 
 	mutex_unlock(&efx->spi_lock);
 	mutex_unlock(&efx->mac_lock);
 
-	if (ok)
-		efx_start_all(efx);
 	return rc;
 }
 
-/* Reset the NIC as transparently as possible. Do not reset the PHY
- * Note that the reset may fail, in which case the card will be left
- * in a most-probably-unusable state.
- *
- * This function will sleep.  You cannot reset from within an atomic
- * state; use efx_schedule_reset() instead.
+/* Reset the NIC using the specified method.  Note that the reset may
+ * fail, in which case the card will be left in an unusable state.
  *
- * Grabs the rtnl_lock.
+ * Caller must hold the rtnl_lock.
  */
-static int efx_reset(struct efx_nic *efx)
+int efx_reset(struct efx_nic *efx, enum reset_type method)
 {
-	enum reset_type method = efx->reset_pending;
-	int rc = 0;
-
-	/* Serialise with kernel interfaces */
-	rtnl_lock();
-
-	/* If we're not RUNNING then don't reset. Leave the reset_pending
-	 * flag set so that efx_pci_probe_main will be retried */
-	if (efx->state != STATE_RUNNING) {
-		EFX_INFO(efx, "scheduled reset quenched. NIC not RUNNING\n");
-		goto out_unlock;
-	}
+	int rc, rc2;
+	bool disabled;
 
 	EFX_INFO(efx, "resetting (%s)\n", RESET_TYPE(method));
 
@@ -1814,7 +1805,7 @@ static int efx_reset(struct efx_nic *efx)
 	rc = efx->type->reset(efx, method);
 	if (rc) {
 		EFX_ERR(efx, "failed to reset hardware\n");
-		goto out_disable;
+		goto out;
 	}
 
 	/* Allow resets to be rescheduled. */
@@ -1826,25 +1817,22 @@ static int efx_reset(struct efx_nic *efx)
 	 * can respond to requests. */
 	pci_set_master(efx->pci_dev);
 
+out:
 	/* Leave device stopped if necessary */
-	if (method == RESET_TYPE_DISABLE) {
-		efx_reset_up(efx, method, false);
-		rc = -EIO;
-	} else {
-		rc = efx_reset_up(efx, method, true);
+	disabled = rc || method == RESET_TYPE_DISABLE;
+	rc2 = efx_reset_up(efx, method, !disabled);
+	if (rc2) {
+		disabled = true;
+		if (!rc)
+			rc = rc2;
 	}
 
-out_disable:
-	if (rc) {
+	if (disabled) {
 		EFX_ERR(efx, "has been disabled\n");
 		efx->state = STATE_DISABLED;
-		dev_close(efx->net_dev);
 	} else {
 		EFX_LOG(efx, "reset complete\n");
 	}
-
-out_unlock:
-	rtnl_unlock();
 	return rc;
 }
 
@@ -1853,9 +1841,19 @@ out_unlock:
  */
 static void efx_reset_work(struct work_struct *data)
 {
-	struct efx_nic *nic = container_of(data, struct efx_nic, reset_work);
+	struct efx_nic *efx = container_of(data, struct efx_nic, reset_work);
 
-	efx_reset(nic);
+	/* If we're not RUNNING then don't reset. Leave the reset_pending
+	 * flag set so that efx_pci_probe_main will be retried */
+	if (efx->state != STATE_RUNNING) {
+		EFX_INFO(efx, "scheduled reset quenched. NIC not RUNNING\n");
+		return;
+	}
+
+	rtnl_lock();
+	if (efx_reset(efx, efx->reset_pending))
+		dev_close(efx->net_dev);
+	rtnl_unlock();
 }
 
 void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index c785003..fa40c7b 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -71,6 +71,7 @@ extern int efx_ethtool_set_settings(struct net_device *net_dev,
 extern const struct ethtool_ops efx_ethtool_ops;
 
 /* Reset handling */
+extern int efx_reset(struct efx_nic *efx, enum reset_type method);
 extern void efx_reset_down(struct efx_nic *efx, enum reset_type method);
 extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index b4c6ea1..29aa83c 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -754,6 +754,35 @@ static int efx_ethtool_set_wol(struct net_device *net_dev,
 	return efx->type->set_wol(efx, wol->wolopts);
 }
 
+extern int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	enum reset_type method;
+	enum {
+		ETH_RESET_EFX_INVISIBLE = (ETH_RESET_DMA | ETH_RESET_FILTER |
+					   ETH_RESET_OFFLOAD | ETH_RESET_MAC)
+	};
+
+	/* Check for minimal reset flags */
+	if ((*flags & ETH_RESET_EFX_INVISIBLE) != ETH_RESET_EFX_INVISIBLE)
+		return -EINVAL;
+	*flags ^= ETH_RESET_EFX_INVISIBLE;
+	method = RESET_TYPE_INVISIBLE;
+
+	if (*flags & ETH_RESET_PHY) {
+		*flags ^= ETH_RESET_PHY;
+		method = RESET_TYPE_ALL;
+	}
+
+	if ((*flags & efx->type->reset_world_flags) ==
+	    efx->type->reset_world_flags) {
+		*flags ^= efx->type->reset_world_flags;
+		method = RESET_TYPE_WORLD;
+	}
+
+	return efx_reset(efx, method);
+}
+
 const struct ethtool_ops efx_ethtool_ops = {
 	.get_settings		= efx_ethtool_get_settings,
 	.set_settings		= efx_ethtool_set_settings,
@@ -784,4 +813,5 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_ethtool_stats	= efx_ethtool_get_stats,
 	.get_wol                = efx_ethtool_get_wol,
 	.set_wol                = efx_ethtool_set_wol,
+	.reset			= efx_ethtool_reset,
 };
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 8f2c583..6a96c69 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3305,6 +3305,7 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.phys_addr_channels = 4,
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
+	.reset_world_flags = ETH_RESET_IRQ,
 };
 
 struct efx_nic_type falcon_b0_nic_type = {
@@ -3348,5 +3349,6 @@ struct efx_nic_type falcon_b0_nic_type = {
 				   * channels */
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
+	.reset_world_flags = ETH_RESET_IRQ,
 };
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index a9fde82..58bf761 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -880,6 +880,8 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  *	descriptors
  * @tx_dc_base: Base address in SRAM of TX queue descriptor caches
  * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
+ * @reset_world_flags: Flags for additional components covered by
+ *	reset method RESET_TYPE_WORLD
  */
 struct efx_nic_type {
 	int (*probe)(struct efx_nic *efx);
@@ -915,6 +917,7 @@ struct efx_nic_type {
 	unsigned int phys_addr_channels;
 	unsigned int tx_dc_base;
 	unsigned int rx_dc_base;
+	u32 reset_world_flags;
 };
 
 /**************************************************************************
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

