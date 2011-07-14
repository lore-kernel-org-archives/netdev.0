From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/7] sfc: Fix mapping of reset reasons and
 flags to methods
Date: Thu, 14 Jul 2011 02:16:54 +0100
Message-ID: <1310606214.2756.26.camel@bwh-desktop>
References: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11224 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab1GNBRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:17:05 -0400
In-Reply-To: <1310606090.2756.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are certain hardware bugs that may occur on Falcon during normal
operation, that require a reset to recover from.  We try to minimise
disruption by keeping the PHY running, following a reset sequence
labelled as 'invisible'.

Siena does not suffer from these hardware bugs, so we have not
implemented an 'invisible' reset sequence.  However, if a similar
error does occur (due to a hardware fault or software bug) then the
code shared with Falcon will wrongly assume that the PHY is not being
reset.

Since the mapping of reset reasons (internal) and flags (ethtool) to
methods must differ significantly between NIC types, move it into
per-NIC-type functions (replacing the insufficient reset_world_flags
field).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   20 ++++------------
 drivers/net/sfc/ethtool.c    |   27 ++++------------------
 drivers/net/sfc/falcon.c     |   49 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/sfc/net_driver.h |    7 +++--
 drivers/net/sfc/siena.c      |   33 +++++++++++++++++++++++++++-
 5 files changed, 93 insertions(+), 43 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 9b4cfdb..ff162df 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2183,26 +2183,16 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	case RESET_TYPE_WORLD:
 	case RESET_TYPE_DISABLE:
 		method = type;
+		netif_dbg(efx, drv, efx->net_dev, "scheduling %s reset\n",
+			  RESET_TYPE(method));
 		break;
-	case RESET_TYPE_RX_RECOVERY:
-	case RESET_TYPE_RX_DESC_FETCH:
-	case RESET_TYPE_TX_DESC_FETCH:
-	case RESET_TYPE_TX_SKIP:
-		method = RESET_TYPE_INVISIBLE;
-		break;
-	case RESET_TYPE_MC_FAILURE:
 	default:
-		method = RESET_TYPE_ALL;
-		break;
-	}
-
-	if (method != type)
+		method = efx->type->map_reset_reason(type);
 		netif_dbg(efx, drv, efx->net_dev,
 			  "scheduling %s reset for %s\n",
 			  RESET_TYPE(method), RESET_TYPE(type));
-	else
-		netif_dbg(efx, drv, efx->net_dev, "scheduling %s reset\n",
-			  RESET_TYPE(method));
+		break;
+	}
 
 	set_bit(method, &efx->reset_pending);
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index d229027..bc4643a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -796,30 +796,13 @@ static int efx_ethtool_set_wol(struct net_device *net_dev,
 static int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	enum reset_type method;
-	enum {
-		ETH_RESET_EFX_INVISIBLE = (ETH_RESET_DMA | ETH_RESET_FILTER |
-					   ETH_RESET_OFFLOAD | ETH_RESET_MAC)
-	};
-
-	/* Check for minimal reset flags */
-	if ((*flags & ETH_RESET_EFX_INVISIBLE) != ETH_RESET_EFX_INVISIBLE)
-		return -EINVAL;
-	*flags ^= ETH_RESET_EFX_INVISIBLE;
-	method = RESET_TYPE_INVISIBLE;
-
-	if (*flags & ETH_RESET_PHY) {
-		*flags ^= ETH_RESET_PHY;
-		method = RESET_TYPE_ALL;
-	}
+	int rc;
 
-	if ((*flags & efx->type->reset_world_flags) ==
-	    efx->type->reset_world_flags) {
-		*flags ^= efx->type->reset_world_flags;
-		method = RESET_TYPE_WORLD;
-	}
+	rc = efx->type->map_reset_flags(flags);
+	if (rc < 0)
+		return rc;
 
-	return efx_reset(efx, method);
+	return efx_reset(efx, rc);
 }
 
 static int
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index a4c7830..94bf4aa 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1051,6 +1051,49 @@ static int falcon_b0_test_registers(struct efx_nic *efx)
  **************************************************************************
  */
 
+static enum reset_type falcon_map_reset_reason(enum reset_type reason)
+{
+	switch (reason) {
+	case RESET_TYPE_RX_RECOVERY:
+	case RESET_TYPE_RX_DESC_FETCH:
+	case RESET_TYPE_TX_DESC_FETCH:
+	case RESET_TYPE_TX_SKIP:
+		/* These can occasionally occur due to hardware bugs.
+		 * We try to reset without disrupting the link.
+		 */
+		return RESET_TYPE_INVISIBLE;
+	default:
+		return RESET_TYPE_ALL;
+	}
+}
+
+static int falcon_map_reset_flags(u32 *flags)
+{
+	enum {
+		FALCON_RESET_INVISIBLE = (ETH_RESET_DMA | ETH_RESET_FILTER |
+					  ETH_RESET_OFFLOAD | ETH_RESET_MAC),
+		FALCON_RESET_ALL = FALCON_RESET_INVISIBLE | ETH_RESET_PHY,
+		FALCON_RESET_WORLD = FALCON_RESET_ALL | ETH_RESET_IRQ,
+	};
+
+	if ((*flags & FALCON_RESET_WORLD) == FALCON_RESET_WORLD) {
+		*flags &= ~FALCON_RESET_WORLD;
+		return RESET_TYPE_WORLD;
+	}
+
+	if ((*flags & FALCON_RESET_ALL) == FALCON_RESET_ALL) {
+		*flags &= ~FALCON_RESET_ALL;
+		return RESET_TYPE_ALL;
+	}
+
+	if ((*flags & FALCON_RESET_INVISIBLE) == FALCON_RESET_INVISIBLE) {
+		*flags &= ~FALCON_RESET_INVISIBLE;
+		return RESET_TYPE_INVISIBLE;
+	}
+
+	return -EINVAL;
+}
+
 /* Resets NIC to known state.  This routine must be called in process
  * context and is allowed to sleep. */
 static int __falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
@@ -1709,6 +1752,8 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.init = falcon_init_nic,
 	.fini = efx_port_dummy_op_void,
 	.monitor = falcon_monitor,
+	.map_reset_reason = falcon_map_reset_reason,
+	.map_reset_flags = falcon_map_reset_flags,
 	.reset = falcon_reset_hw,
 	.probe_port = falcon_probe_port,
 	.remove_port = falcon_remove_port,
@@ -1741,7 +1786,6 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
 	.offload_features = NETIF_F_IP_CSUM,
-	.reset_world_flags = ETH_RESET_IRQ,
 };
 
 const struct efx_nic_type falcon_b0_nic_type = {
@@ -1750,6 +1794,8 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.init = falcon_init_nic,
 	.fini = efx_port_dummy_op_void,
 	.monitor = falcon_monitor,
+	.map_reset_reason = falcon_map_reset_reason,
+	.map_reset_flags = falcon_map_reset_flags,
 	.reset = falcon_reset_hw,
 	.probe_port = falcon_probe_port,
 	.remove_port = falcon_remove_port,
@@ -1791,6 +1837,5 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
 	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH | NETIF_F_NTUPLE,
-	.reset_world_flags = ETH_RESET_IRQ,
 };
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index c422eb2..4597066 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -828,6 +828,8 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @init: Initialise the controller
  * @fini: Shut down the controller
  * @monitor: Periodic function for polling link state and hardware monitor
+ * @map_reset_reason: Map ethtool reset reason to a reset method
+ * @map_reset_flags: Map ethtool reset flags to a reset method, if possible
  * @reset: Reset the controller hardware and possibly the PHY.  This will
  *	be called while the controller is uninitialised.
  * @probe_port: Probe the MAC and PHY
@@ -865,8 +867,6 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
  * @offload_features: net_device feature flags for protocol offload
  *	features implemented in hardware
- * @reset_world_flags: Flags for additional components covered by
- *	reset method RESET_TYPE_WORLD
  */
 struct efx_nic_type {
 	int (*probe)(struct efx_nic *efx);
@@ -874,6 +874,8 @@ struct efx_nic_type {
 	int (*init)(struct efx_nic *efx);
 	void (*fini)(struct efx_nic *efx);
 	void (*monitor)(struct efx_nic *efx);
+	enum reset_type (*map_reset_reason)(enum reset_type reason);
+	int (*map_reset_flags)(u32 *flags);
 	int (*reset)(struct efx_nic *efx, enum reset_type method);
 	int (*probe_port)(struct efx_nic *efx);
 	void (*remove_port)(struct efx_nic *efx);
@@ -908,7 +910,6 @@ struct efx_nic_type {
 	unsigned int tx_dc_base;
 	unsigned int rx_dc_base;
 	u32 offload_features;
-	u32 reset_world_flags;
 };
 
 /**************************************************************************
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index a66818e..442897b 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -177,6 +177,36 @@ static int siena_test_registers(struct efx_nic *efx)
  **************************************************************************
  */
 
+static enum reset_type siena_map_reset_reason(enum reset_type reason)
+{
+	return RESET_TYPE_ALL;
+}
+
+static int siena_map_reset_flags(u32 *flags)
+{
+	enum {
+		SIENA_RESET_PORT = (ETH_RESET_DMA | ETH_RESET_FILTER |
+				    ETH_RESET_OFFLOAD | ETH_RESET_MAC |
+				    ETH_RESET_PHY),
+		SIENA_RESET_MC = (SIENA_RESET_PORT |
+				  ETH_RESET_MGMT << ETH_RESET_SHARED_SHIFT),
+	};
+
+	if ((*flags & SIENA_RESET_MC) == SIENA_RESET_MC) {
+		*flags &= ~SIENA_RESET_MC;
+		return RESET_TYPE_WORLD;
+	}
+
+	if ((*flags & SIENA_RESET_PORT) == SIENA_RESET_PORT) {
+		*flags &= ~SIENA_RESET_PORT;
+		return RESET_TYPE_ALL;
+	}
+
+	/* no invisible reset implemented */
+
+	return -EINVAL;
+}
+
 static int siena_reset_hw(struct efx_nic *efx, enum reset_type method)
 {
 	int rc;
@@ -605,6 +635,8 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.init = siena_init_nic,
 	.fini = efx_port_dummy_op_void,
 	.monitor = NULL,
+	.map_reset_reason = siena_map_reset_reason,
+	.map_reset_flags = siena_map_reset_flags,
 	.reset = siena_reset_hw,
 	.probe_port = siena_probe_port,
 	.remove_port = siena_remove_port,
@@ -641,5 +673,4 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.rx_dc_base = 0x68000,
 	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			     NETIF_F_RXHASH | NETIF_F_NTUPLE),
-	.reset_world_flags = ETH_RESET_MGMT << ETH_RESET_SHARED_SHIFT,
 };
-- 
1.7.4.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

