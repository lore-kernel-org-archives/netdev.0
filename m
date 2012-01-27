From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/32] sfc: Remove
 efx_nic_type::push_multicast_hash operation
Date: Fri, 27 Jan 2012 20:46:30 +0000
Message-ID: <1327697190.2503.22.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63640 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752675Ab2A0Uqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:46:33 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both implementations of efx_nic_type::reconfigure_mac operation
push the multicast hash filter to the hardware.  It is therefore
redundant to call efx_nic_type::push_multicast_hash as well.

efx_mcdi_mac_reconfigure() also uses this operation, but the
implementation for Siena just uses MCDI anyway.  Merge that into
efx_mcdi_mac_reconfigure().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    5 +----
 drivers/net/ethernet/sfc/falcon.c     |    2 --
 drivers/net/ethernet/sfc/mcdi_mac.c   |   10 ++++++----
 drivers/net/ethernet/sfc/net_driver.h |    5 ++---
 drivers/net/ethernet/sfc/siena.c      |   10 ----------
 5 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 1d20e01..de16247 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -898,10 +898,8 @@ static void efx_mac_work(struct work_struct *data)
 	struct efx_nic *efx = container_of(data, struct efx_nic, mac_work);
 
 	mutex_lock(&efx->mac_lock);
-	if (efx->port_enabled) {
-		efx->type->push_multicast_hash(efx);
+	if (efx->port_enabled)
 		efx->type->reconfigure_mac(efx);
-	}
 	mutex_unlock(&efx->mac_lock);
 }
 
@@ -968,7 +966,6 @@ static void efx_start_port(struct efx_nic *efx)
 
 	/* efx_mac_work() might have been scheduled after efx_stop_port(),
 	 * and then cancelled by efx_flush_all() */
-	efx->type->push_multicast_hash(efx);
 	efx->type->reconfigure_mac(efx);
 
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 1a8a316..fe21c7e 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1766,7 +1766,6 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.stop_stats = falcon_stop_nic_stats,
 	.set_id_led = falcon_set_id_led,
 	.push_irq_moderation = falcon_push_irq_moderation,
-	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
 	.reconfigure_mac = falcon_reconfigure_xmac,
 	.check_mac_fault = falcon_xmac_check_fault,
@@ -1809,7 +1808,6 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.stop_stats = falcon_stop_nic_stats,
 	.set_id_led = falcon_set_id_led,
 	.push_irq_moderation = falcon_push_irq_moderation,
-	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
 	.reconfigure_mac = falcon_reconfigure_xmac,
 	.check_mac_fault = falcon_xmac_check_fault,
diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
index 559d798..f67cf92 100644
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ b/drivers/net/ethernet/sfc/mcdi_mac.c
@@ -115,12 +115,14 @@ int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
 {
 	int rc;
 
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+
 	rc = efx_mcdi_set_mac(efx);
 	if (rc != 0)
 		return rc;
 
-	/* Restore the multicast hash registers. */
-	efx->type->push_multicast_hash(efx);
-
-	return 0;
+	return efx_mcdi_rpc(efx, MC_CMD_SET_MCAST_HASH,
+			    efx->multicast_hash.byte,
+			    sizeof(efx->multicast_hash),
+			    NULL, 0, NULL);
 }
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index aa5a321..a88e95f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -826,9 +826,9 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @stop_stats: Stop the regular fetching of statistics
  * @set_id_led: Set state of identifying LED or revert to automatic function
  * @push_irq_moderation: Apply interrupt moderation value
- * @push_multicast_hash: Apply multicast hash table
  * @reconfigure_port: Push loopback/power/txdis changes to the MAC and PHY
- * @reconfigure_mac: Reconfigure MAC only. Serialised by the mac_lock
+ * @reconfigure_mac: Push MAC address, MTU, flow control and filter settings
+ *	to the hardware.  Serialised by the mac_lock.
  * @check_mac_fault: Check MAC fault state. True if fault present.
  * @get_wol: Get WoL configuration from driver state
  * @set_wol: Push WoL configuration to the NIC
@@ -872,7 +872,6 @@ struct efx_nic_type {
 	void (*stop_stats)(struct efx_nic *efx);
 	void (*set_id_led)(struct efx_nic *efx, enum efx_led_mode mode);
 	void (*push_irq_moderation)(struct efx_channel *channel);
-	void (*push_multicast_hash)(struct efx_nic *efx);
 	int (*reconfigure_port)(struct efx_nic *efx);
 	int (*reconfigure_mac)(struct efx_nic *efx);
 	bool (*check_mac_fault)(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 775b678..d681f25 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -52,15 +52,6 @@ static void siena_push_irq_moderation(struct efx_channel *channel)
 			       channel->channel);
 }
 
-static void siena_push_multicast_hash(struct efx_nic *efx)
-{
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
-
-	efx_mcdi_rpc(efx, MC_CMD_SET_MCAST_HASH,
-		     efx->multicast_hash.byte, sizeof(efx->multicast_hash),
-		     NULL, 0, NULL);
-}
-
 static int siena_mdio_write(struct net_device *net_dev,
 			    int prtad, int devad, u16 addr, u16 value)
 {
@@ -629,7 +620,6 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.stop_stats = siena_stop_nic_stats,
 	.set_id_led = efx_mcdi_set_id_led,
 	.push_irq_moderation = siena_push_irq_moderation,
-	.push_multicast_hash = siena_push_multicast_hash,
 	.reconfigure_mac = efx_mcdi_mac_reconfigure,
 	.check_mac_fault = efx_mcdi_mac_check_fault,
 	.reconfigure_port = efx_mcdi_phy_reconfigure,
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
