From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 17/32] sfc: Refactor link configuration
Date: Sat, 28 Nov 2009 03:49:33 +0000
Message-ID: <1259380173.2811.40.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42644 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbZK1Dt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:49:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor PHY, MAC and NIC configuration operations so that the
existing link configuration can be re-pushed with:

	efx->phy_op->reconfigure(efx);
	efx->mac_op->reconfigure(efx);

and a new configuration with:

	efx->nic_op->reconfigure_port(efx);

(plus locking and error-checking).

We have not held the link settings in software (aside from flow
control), and have relied on asking the hardware what they are.  This
is a problem because in some cases the hardware may no longer be in a
state to tell us.  In particular, if an entire multi-port board is
reset through one port, the driver bindings to other ports have no
chance to save settings before recovering.

We only actually need to keep track of the autonegotiation settings,
so add an ethtool advertising mask to struct efx_nic, initialise it
in PHY init and update it as necessary.

Remove now-unneeded uses of efx_phy_op::{get,set}_settings() and
struct ethtool_cmd.

Much of this was done by Steve Hodgson <shodgson@solarflare.com>.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |  132 +++++++++++++++++++++++---------------
 drivers/net/sfc/efx.h           |   12 ++--
 drivers/net/sfc/ethtool.c       |   61 ++++++++++++------
 drivers/net/sfc/falcon.c        |   98 ++++++++++++++++++----------
 drivers/net/sfc/falcon.h        |    3 -
 drivers/net/sfc/falcon_boards.c |    3 +-
 drivers/net/sfc/falcon_gmac.c   |    4 +-
 drivers/net/sfc/falcon_xmac.c   |    8 ++-
 drivers/net/sfc/mac.h           |    1 +
 drivers/net/sfc/mdio_10g.c      |   41 ++++++++----
 drivers/net/sfc/mdio_10g.h      |    3 +
 drivers/net/sfc/net_driver.h    |    8 ++-
 drivers/net/sfc/qt202x_phy.c    |    4 +-
 drivers/net/sfc/selftest.c      |   11 ++--
 drivers/net/sfc/tenxpress.c     |   66 ++++++++------------
 15 files changed, 273 insertions(+), 182 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ce8e447..c77338f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -620,16 +620,49 @@ void efx_link_status_changed(struct efx_nic *efx)
 
 }
 
+void efx_link_set_advertising(struct efx_nic *efx, u32 advertising)
+{
+	efx->link_advertising = advertising;
+	if (advertising) {
+		if (advertising & ADVERTISED_Pause)
+			efx->wanted_fc |= (EFX_FC_TX | EFX_FC_RX);
+		else
+			efx->wanted_fc &= ~(EFX_FC_TX | EFX_FC_RX);
+		if (advertising & ADVERTISED_Asym_Pause)
+			efx->wanted_fc ^= EFX_FC_TX;
+	}
+}
+
+void efx_link_set_wanted_fc(struct efx_nic *efx, enum efx_fc_type wanted_fc)
+{
+	efx->wanted_fc = wanted_fc;
+	if (efx->link_advertising) {
+		if (wanted_fc & EFX_FC_RX)
+			efx->link_advertising |= (ADVERTISED_Pause |
+						  ADVERTISED_Asym_Pause);
+		else
+			efx->link_advertising &= ~(ADVERTISED_Pause |
+						   ADVERTISED_Asym_Pause);
+		if (wanted_fc & EFX_FC_TX)
+			efx->link_advertising ^= ADVERTISED_Asym_Pause;
+	}
+}
+
 static void efx_fini_port(struct efx_nic *efx);
 
-/* This call reinitialises the MAC to pick up new PHY settings. The
- * caller must hold the mac_lock */
-void __efx_reconfigure_port(struct efx_nic *efx)
+/* Push loopback/power/transmit disable settings to the PHY, and reconfigure
+ * the MAC appropriately. All other PHY configuration changes are pushed
+ * through phy_op->set_settings(), and pushed asynchronously to the MAC
+ * through efx_monitor().
+ *
+ * Callers must hold the mac_lock
+ */
+int __efx_reconfigure_port(struct efx_nic *efx)
 {
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+	enum efx_phy_mode phy_mode;
+	int rc;
 
-	EFX_LOG(efx, "reconfiguring MAC from PHY settings on CPU %d\n",
-		raw_smp_processor_id());
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 
 	/* Serialise the promiscuous flag with efx_set_multicast_list. */
 	if (efx_dev_registered(efx)) {
@@ -637,42 +670,34 @@ void __efx_reconfigure_port(struct efx_nic *efx)
 		netif_addr_unlock_bh(efx->net_dev);
 	}
 
-	efx->type->stop_stats(efx);
-	falcon_deconfigure_mac_wrapper(efx);
-
-	/* Reconfigure the PHY, disabling transmit in mac level loopback. */
+	/* Disable PHY transmit in mac level loopbacks */
+	phy_mode = efx->phy_mode;
 	if (LOOPBACK_INTERNAL(efx))
 		efx->phy_mode |= PHY_MODE_TX_DISABLED;
 	else
 		efx->phy_mode &= ~PHY_MODE_TX_DISABLED;
-	efx->phy_op->reconfigure(efx);
-
-	if (falcon_switch_mac(efx))
-		goto fail;
 
-	efx->mac_op->reconfigure(efx);
+	rc = efx->type->reconfigure_port(efx);
 
-	efx->type->start_stats(efx);
-
-	/* Inform kernel of loss/gain of carrier */
-	efx_link_status_changed(efx);
-	return;
+	if (rc)
+		efx->phy_mode = phy_mode;
 
-fail:
-	EFX_ERR(efx, "failed to reconfigure MAC\n");
-	efx->port_enabled = false;
-	efx_fini_port(efx);
+	return rc;
 }
 
 /* Reinitialise the MAC to pick up new PHY settings, even if the port is
  * disabled. */
-void efx_reconfigure_port(struct efx_nic *efx)
+int efx_reconfigure_port(struct efx_nic *efx)
 {
+	int rc;
+
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	mutex_lock(&efx->mac_lock);
-	__efx_reconfigure_port(efx);
+	rc = __efx_reconfigure_port(efx);
 	mutex_unlock(&efx->mac_lock);
+
+	return rc;
 }
 
 /* Asynchronous work item for changing MAC promiscuity and multicast
@@ -737,14 +762,18 @@ static int efx_init_port(struct efx_nic *efx)
 	rc = efx->phy_op->init(efx);
 	if (rc)
 		goto fail1;
-	efx->phy_op->reconfigure(efx);
-	rc = falcon_switch_mac(efx);
-	if (rc)
-		goto fail2;
-	efx->mac_op->reconfigure(efx);
 
 	efx->port_initialized = true;
 
+	/* Reconfigure the MAC before creating dma queues (required for
+	 * Falcon/A1 where RX_INGR_EN/TX_DRAIN_EN isn't supported) */
+	efx->mac_op->reconfigure(efx);
+
+	/* Ensure the PHY advertises the correct flow control settings */
+	rc = efx->phy_op->reconfigure(efx);
+	if (rc)
+		goto fail2;
+
 	mutex_unlock(&efx->mac_lock);
 	return 0;
 
@@ -1209,12 +1238,6 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
 	efx_flush_all(efx);
 
-	/* Isolate the MAC from the TX and RX engines, so that queue
-	 * flushes will complete in a timely fashion. */
-	falcon_deconfigure_mac_wrapper(efx);
-	msleep(10); /* Let the Rx FIFO drain */
-	falcon_drain_tx_fifo(efx);
-
 	/* Stop the kernel transmit interface late, so the watchdog
 	 * timer isn't ticking over the flush */
 	if (efx_dev_registered(efx)) {
@@ -1491,7 +1514,14 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	EFX_LOG(efx, "changing MTU to %d\n", new_mtu);
 
 	efx_fini_channels(efx);
+
+	mutex_lock(&efx->mac_lock);
+	/* Reconfigure the MAC before enabling the dma queues so that
+	 * the RX buffers don't overflow */
 	net_dev->mtu = new_mtu;
+	efx->mac_op->reconfigure(efx);
+	mutex_unlock(&efx->mac_lock);
+
 	efx_init_channels(efx);
 
 	efx_start_all(efx);
@@ -1515,7 +1545,9 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	memcpy(net_dev->dev_addr, new_addr, net_dev->addr_len);
 
 	/* Reconfigure the MAC */
-	efx_reconfigure_port(efx);
+	mutex_lock(&efx->mac_lock);
+	efx->mac_op->reconfigure(efx);
+	mutex_unlock(&efx->mac_lock);
 
 	return 0;
 }
@@ -1682,8 +1714,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 
 /* Tears down the entire software state and most of the hardware state
  * before reset.  */
-void efx_reset_down(struct efx_nic *efx, enum reset_type method,
-		    struct ethtool_cmd *ecmd)
+void efx_reset_down(struct efx_nic *efx, enum reset_type method)
 {
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
@@ -1691,8 +1722,6 @@ void efx_reset_down(struct efx_nic *efx, enum reset_type method,
 	mutex_lock(&efx->mac_lock);
 	mutex_lock(&efx->spi_lock);
 
-	efx->phy_op->get_settings(efx, ecmd);
-
 	efx_fini_channels(efx);
 	if (efx->port_initialized && method != RESET_TYPE_INVISIBLE)
 		efx->phy_op->fini(efx);
@@ -1704,8 +1733,7 @@ void efx_reset_down(struct efx_nic *efx, enum reset_type method,
  * that we were unable to reinitialise the hardware, and the
  * driver should be disabled. If ok is false, then the rx and tx
  * engines are not restarted, pending a RESET_DISABLE. */
-int efx_reset_up(struct efx_nic *efx, enum reset_type method,
-		 struct ethtool_cmd *ecmd, bool ok)
+int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 {
 	int rc;
 
@@ -1722,16 +1750,17 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method,
 			rc = efx->phy_op->init(efx);
 			if (rc)
 				ok = false;
+			if (efx->phy_op->reconfigure(efx))
+				EFX_ERR(efx, "could not restore PHY settings\n");
 		}
 		if (!ok)
 			efx->port_initialized = false;
 	}
 
 	if (ok) {
-		efx_init_channels(efx);
+		efx->mac_op->reconfigure(efx);
 
-		if (efx->phy_op->set_settings(efx, ecmd))
-			EFX_ERR(efx, "could not restore PHY settings\n");
+		efx_init_channels(efx);
 	}
 
 	mutex_unlock(&efx->spi_lock);
@@ -1753,7 +1782,6 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method,
  */
 static int efx_reset(struct efx_nic *efx)
 {
-	struct ethtool_cmd ecmd;
 	enum reset_type method = efx->reset_pending;
 	int rc = 0;
 
@@ -1769,7 +1797,7 @@ static int efx_reset(struct efx_nic *efx)
 
 	EFX_INFO(efx, "resetting (%s)\n", RESET_TYPE(method));
 
-	efx_reset_down(efx, method, &ecmd);
+	efx_reset_down(efx, method);
 
 	rc = efx->type->reset(efx, method);
 	if (rc) {
@@ -1788,10 +1816,10 @@ static int efx_reset(struct efx_nic *efx)
 
 	/* Leave device stopped if necessary */
 	if (method == RESET_TYPE_DISABLE) {
-		efx_reset_up(efx, method, &ecmd, false);
+		efx_reset_up(efx, method, false);
 		rc = -EIO;
 	} else {
-		rc = efx_reset_up(efx, method, &ecmd, true);
+		rc = efx_reset_up(efx, method, true);
 	}
 
 out_disable:
@@ -1895,7 +1923,7 @@ bool efx_port_dummy_op_poll(struct efx_nic *efx)
 
 static struct efx_phy_operations efx_dummy_phy_operations = {
 	.init		 = efx_port_dummy_op_int,
-	.reconfigure	 = efx_port_dummy_op_void,
+	.reconfigure	 = efx_port_dummy_op_int,
 	.poll		 = efx_port_dummy_op_poll,
 	.fini		 = efx_port_dummy_op_void,
 };
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 15edda2..c785003 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -60,8 +60,8 @@ extern void efx_process_channel_now(struct efx_channel *channel);
 #define EFX_EVQ_MASK (EFX_EVQ_SIZE - 1)
 
 /* Ports */
-extern void efx_reconfigure_port(struct efx_nic *efx);
-extern void __efx_reconfigure_port(struct efx_nic *efx);
+extern int efx_reconfigure_port(struct efx_nic *efx);
+extern int __efx_reconfigure_port(struct efx_nic *efx);
 
 /* Ethtool support */
 extern int efx_ethtool_get_settings(struct net_device *net_dev,
@@ -71,10 +71,8 @@ extern int efx_ethtool_set_settings(struct net_device *net_dev,
 extern const struct ethtool_ops efx_ethtool_ops;
 
 /* Reset handling */
-extern void efx_reset_down(struct efx_nic *efx, enum reset_type method,
-			   struct ethtool_cmd *ecmd);
-extern int efx_reset_up(struct efx_nic *efx, enum reset_type method,
-			struct ethtool_cmd *ecmd, bool ok);
+extern void efx_reset_down(struct efx_nic *efx, enum reset_type method);
+extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
 
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
@@ -115,5 +113,7 @@ static inline void efx_schedule_channel(struct efx_channel *channel)
 }
 
 extern void efx_link_status_changed(struct efx_nic *efx);
+extern void efx_link_set_advertising(struct efx_nic *efx, u32);
+extern void efx_link_set_wanted_fc(struct efx_nic *efx, enum efx_fc_type);
 
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0ac34b0..92c5d8d 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -10,7 +10,6 @@
 
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
-#include <linux/mdio.h>
 #include <linux/rtnetlink.h>
 #include "net_driver.h"
 #include "workarounds.h"
@@ -191,6 +190,7 @@ int efx_ethtool_get_settings(struct net_device *net_dev,
 			     struct ethtool_cmd *ecmd)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	struct efx_link_state *link_state = &efx->link_state;
 
 	mutex_lock(&efx->mac_lock);
 	efx->phy_op->get_settings(efx, ecmd);
@@ -198,6 +198,13 @@ int efx_ethtool_get_settings(struct net_device *net_dev,
 
 	/* Falcon GMAC does not support 1000Mbps HD */
 	ecmd->supported &= ~SUPPORTED_1000baseT_Half;
+	/* Both MACs support pause frames (bidirectional and respond-only) */
+	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+
+	if (LOOPBACK_INTERNAL(efx)) {
+		ecmd->speed = link_state->speed;
+		ecmd->duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
+	}
 
 	return 0;
 }
@@ -219,9 +226,6 @@ int efx_ethtool_set_settings(struct net_device *net_dev,
 	mutex_lock(&efx->mac_lock);
 	rc = efx->phy_op->set_settings(efx, ecmd);
 	mutex_unlock(&efx->mac_lock);
-	if (!rc)
-		efx_reconfigure_port(efx);
-
 	return rc;
 }
 
@@ -671,8 +675,12 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 				      struct ethtool_pauseparam *pause)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	enum efx_fc_type wanted_fc;
+	enum efx_fc_type wanted_fc, old_fc;
+	u32 old_adv;
 	bool reset;
+	int rc = 0;
+
+	mutex_lock(&efx->mac_lock);
 
 	wanted_fc = ((pause->rx_pause ? EFX_FC_RX : 0) |
 		     (pause->tx_pause ? EFX_FC_TX : 0) |
@@ -680,14 +688,14 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 
 	if ((wanted_fc & EFX_FC_TX) && !(wanted_fc & EFX_FC_RX)) {
 		EFX_LOG(efx, "Flow control unsupported: tx ON rx OFF\n");
-		return -EINVAL;
+		rc = -EINVAL;
+		goto out;
 	}
 
-	if (!(efx->phy_op->mmds & MDIO_DEVS_AN) &&
-	    (wanted_fc & EFX_FC_AUTO)) {
-		EFX_LOG(efx, "PHY does not support flow control "
-			"autonegotiation\n");
-		return -EINVAL;
+	if ((wanted_fc & EFX_FC_AUTO) && !efx->link_advertising) {
+		EFX_LOG(efx, "Autonegotiation is disabled\n");
+		rc = -EINVAL;
+		goto out;
 	}
 
 	/* TX flow control may automatically turn itself off if the
@@ -699,25 +707,38 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	if (EFX_WORKAROUND_11482(efx) && reset) {
 		if (efx_nic_rev(efx) == EFX_REV_FALCON_B0) {
 			/* Recover by resetting the EM block */
-			if (efx->link_state.up)
-				falcon_drain_tx_fifo(efx);
+			falcon_stop_nic_stats(efx);
+			falcon_drain_tx_fifo(efx);
+			efx->mac_op->reconfigure(efx);
+			falcon_start_nic_stats(efx);
 		} else {
 			/* Schedule a reset to recover */
 			efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
 		}
 	}
 
-	/* Try to push the pause parameters */
-	mutex_lock(&efx->mac_lock);
+	old_adv = efx->link_advertising;
+	old_fc = efx->wanted_fc;
+	efx_link_set_wanted_fc(efx, wanted_fc);
+	if (efx->link_advertising != old_adv ||
+	    (efx->wanted_fc ^ old_fc) & EFX_FC_AUTO) {
+		rc = efx->phy_op->reconfigure(efx);
+		if (rc) {
+			EFX_ERR(efx, "Unable to advertise requested flow "
+				"control setting\n");
+			goto out;
+		}
+	}
 
-	efx->wanted_fc = wanted_fc;
-	if (efx->phy_op->mmds & MDIO_DEVS_AN)
-		mdio45_ethtool_spauseparam_an(&efx->mdio, pause);
-	__efx_reconfigure_port(efx);
+	/* Reconfigure the MAC. The PHY *may* generate a link state change event
+	 * if the user just changed the advertised capabilities, but there's no
+	 * harm doing this twice */
+	efx->mac_op->reconfigure(efx);
 
+out:
 	mutex_unlock(&efx->mac_lock);
 
-	return 0;
+	return rc;
 }
 
 static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 23e2ec2..85233c8 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1193,6 +1193,8 @@ static void falcon_poll_flush_events(struct efx_nic *efx)
 	channel->eventq_read_ptr = read_ptr;
 }
 
+static void falcon_deconfigure_mac_wrapper(struct efx_nic *efx);
+
 static void falcon_prepare_flush(struct efx_nic *efx)
 {
 	falcon_deconfigure_mac_wrapper(efx);
@@ -1836,9 +1838,10 @@ static void falcon_push_multicast_hash(struct efx_nic *efx)
 	efx_writeo(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
 }
 
-static int falcon_reset_macs(struct efx_nic *efx)
+static void falcon_reset_macs(struct efx_nic *efx)
 {
-	efx_oword_t reg;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	efx_oword_t reg, mac_ctrl;
 	int count;
 
 	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0) {
@@ -1853,7 +1856,7 @@ static int falcon_reset_macs(struct efx_nic *efx)
 			EFX_POPULATE_OWORD_1(reg, FRF_AB_GM_SW_RST, 0);
 			efx_writeo(efx, &reg, FR_AB_GM_CFG1);
 			udelay(1000);
-			return 0;
+			return;
 		} else {
 			EFX_POPULATE_OWORD_1(reg, FRF_AB_XM_CORE_RST, 1);
 			efx_writeo(efx, &reg, FR_AB_XM_GLB_CFG);
@@ -1862,22 +1865,20 @@ static int falcon_reset_macs(struct efx_nic *efx)
 				efx_reado(efx, &reg, FR_AB_XM_GLB_CFG);
 				if (EFX_OWORD_FIELD(reg, FRF_AB_XM_CORE_RST) ==
 				    0)
-					return 0;
+					return;
 				udelay(10);
 			}
 
 			EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
-			return -ETIMEDOUT;
 		}
 	}
 
-	/* MAC stats will fail whilst the TX fifo is draining. Serialise
-	 * the drain sequence with the statistics fetch */
-	falcon_stop_nic_stats(efx);
+	/* Mac stats will fail whist the TX fifo is draining */
+	WARN_ON(nic_data->stats_disable_count == 0);
 
-	efx_reado(efx, &reg, FR_AB_MAC_CTRL);
-	EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN, 1);
-	efx_writeo(efx, &reg, FR_AB_MAC_CTRL);
+	efx_reado(efx, &mac_ctrl, FR_AB_MAC_CTRL);
+	EFX_SET_OWORD_FIELD(mac_ctrl, FRF_BB_TXFIFO_DRAIN_EN, 1);
+	efx_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
 
 	efx_reado(efx, &reg, FR_AB_GLB_CTL);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_RST_XGTX, 1);
@@ -1903,14 +1904,9 @@ static int falcon_reset_macs(struct efx_nic *efx)
 		udelay(10);
 	}
 
-	/* If we've reset the EM block and the link is up, then
-	 * we'll have to kick the XAUI link so the PHY can recover */
-	if (efx->link_state.up && EFX_IS10G(efx) && EFX_WORKAROUND_5147(efx))
-		falcon_reset_xaui(efx);
-
-	falcon_start_nic_stats(efx);
-
-	return 0;
+	/* Ensure the correct MAC is selected before statistics
+	 * are re-enabled by the caller */
+	efx_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
 }
 
 void falcon_drain_tx_fifo(struct efx_nic *efx)
@@ -1929,7 +1925,7 @@ void falcon_drain_tx_fifo(struct efx_nic *efx)
 	falcon_reset_macs(efx);
 }
 
-void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
+static void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 
@@ -1941,8 +1937,8 @@ void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 0);
 	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 
-	if (!efx->link_state.up)
-		falcon_drain_tx_fifo(efx);
+	/* Isolate TX -> MAC */
+	falcon_drain_tx_fifo(efx);
 }
 
 void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
@@ -2044,6 +2040,8 @@ static void falcon_stats_timer_func(unsigned long context)
 	spin_unlock(&efx->stats_lock);
 }
 
+static void falcon_switch_mac(struct efx_nic *efx);
+
 static bool falcon_loopback_link_poll(struct efx_nic *efx)
 {
 	struct efx_link_state old_state = efx->link_state;
@@ -2063,6 +2061,38 @@ static bool falcon_loopback_link_poll(struct efx_nic *efx)
 	return !efx_link_state_equal(&efx->link_state, &old_state);
 }
 
+static int falcon_reconfigure_port(struct efx_nic *efx)
+{
+	int rc;
+
+	WARN_ON(efx_nic_rev(efx) > EFX_REV_FALCON_B0);
+
+	/* Poll the PHY link state *before* reconfiguring it. This means we
+	 * will pick up the correct speed (in loopback) to select the correct
+	 * MAC.
+	 */
+	if (LOOPBACK_INTERNAL(efx))
+		falcon_loopback_link_poll(efx);
+	else
+		efx->phy_op->poll(efx);
+
+	falcon_stop_nic_stats(efx);
+	falcon_deconfigure_mac_wrapper(efx);
+
+	falcon_switch_mac(efx);
+
+	efx->phy_op->reconfigure(efx);
+	rc = efx->mac_op->reconfigure(efx);
+	BUG_ON(rc);
+
+	falcon_start_nic_stats(efx);
+
+	/* Synchronise efx->link_state with the kernel */
+	efx_link_status_changed(efx);
+
+	return 0;
+}
+
 /**************************************************************************
  *
  * PHY access via GMII
@@ -2215,17 +2245,15 @@ static void falcon_clock_mac(struct efx_nic *efx)
 	}
 }
 
-int falcon_switch_mac(struct efx_nic *efx)
+static void falcon_switch_mac(struct efx_nic *efx)
 {
 	struct efx_mac_operations *old_mac_op = efx->mac_op;
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	unsigned int stats_done_offset;
-	int rc = 0;
-
-	/* Don't try to fetch MAC stats while we're switching MACs */
-	falcon_stop_nic_stats(efx);
 
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+	WARN_ON(nic_data->stats_disable_count == 0);
+
 	efx->mac_op = (EFX_IS10G(efx) ?
 		       &falcon_xmac_operations : &falcon_gmac_operations);
 
@@ -2236,18 +2264,14 @@ int falcon_switch_mac(struct efx_nic *efx)
 	nic_data->stats_dma_done = efx->stats_buffer.addr + stats_done_offset;
 
 	if (old_mac_op == efx->mac_op)
-		goto out;
+		return;
 
 	falcon_clock_mac(efx);
 
 	EFX_LOG(efx, "selected %cMAC\n", EFX_IS10G(efx) ? 'X' : 'G');
 	/* Not all macs support a mac-level link state */
 	efx->xmac_poll_required = false;
-
-	rc = falcon_reset_macs(efx);
-out:
-	falcon_start_nic_stats(efx);
-	return rc;
+	falcon_reset_macs(efx);
 }
 
 /* This call is responsible for hooking in the MAC and PHY operations */
@@ -2597,7 +2621,8 @@ static void falcon_monitor(struct efx_nic *efx)
 		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
 			(rc == -ERANGE) ? "reported fault" : "failed");
 		efx->phy_mode |= PHY_MODE_LOW_POWER;
-		__efx_reconfigure_port(efx);
+		rc = __efx_reconfigure_port(efx);
+		WARN_ON(rc);
 	}
 
 	if (LOOPBACK_INTERNAL(efx))
@@ -2610,7 +2635,8 @@ static void falcon_monitor(struct efx_nic *efx)
 		falcon_deconfigure_mac_wrapper(efx);
 
 		falcon_switch_mac(efx);
-		efx->mac_op->reconfigure(efx);
+		rc = efx->mac_op->reconfigure(efx);
+		BUG_ON(rc);
 
 		falcon_start_nic_stats(efx);
 
@@ -3239,6 +3265,7 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.stop_stats = falcon_stop_nic_stats,
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
+	.reconfigure_port = falcon_reconfigure_port,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_A1,
@@ -3272,6 +3299,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.stop_stats = falcon_stop_nic_stats,
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
+	.reconfigure_port = falcon_reconfigure_port,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_B0,
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 3fe6484..560a3f9 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -130,10 +130,7 @@ extern int falcon_process_eventq(struct efx_channel *channel, int rx_quota);
 extern void falcon_eventq_read_ack(struct efx_channel *channel);
 
 /* MAC/PHY */
-extern int falcon_switch_mac(struct efx_nic *efx);
-extern bool falcon_xaui_link_ok(struct efx_nic *efx);
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
-extern void falcon_deconfigure_mac_wrapper(struct efx_nic *efx);
 extern void falcon_reconfigure_mac_wrapper(struct efx_nic *efx);
 
 /* Interrupts and test events */
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index da75095..b92decc 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -352,7 +352,8 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 			err = sfe4001_poweron(efx);
 		else
 			err = sfn4111t_reset(efx);
-		efx_reconfigure_port(efx);
+		if (!err)
+			err = efx_reconfigure_port(efx);
 		if (!(new_mode & PHY_MODE_SPECIAL))
 			falcon_start_nic_stats(efx);
 	}
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index 66d499c..19dd3ac 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -22,7 +22,7 @@
  *
  *************************************************************************/
 
-static void falcon_reconfigure_gmac(struct efx_nic *efx)
+static int falcon_reconfigure_gmac(struct efx_nic *efx)
 {
 	struct efx_link_state *link_state = &efx->link_state;
 	bool loopback, tx_fc, rx_fc, bytemode;
@@ -123,6 +123,8 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 	udelay(10);
 
 	falcon_reconfigure_mac_wrapper(efx);
+
+	return 0;
 }
 
 static void falcon_update_stats_gmac(struct efx_nic *efx)
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 60dc097..898afc1 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -112,7 +112,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 }
 
 /* Get status of XAUI link */
-bool falcon_xaui_link_ok(struct efx_nic *efx)
+static bool falcon_xaui_link_ok(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 	bool align_done, link_ok = false;
@@ -143,7 +143,7 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 	return link_ok;
 }
 
-static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
+void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 {
 	unsigned int max_frame_len;
 	efx_oword_t reg;
@@ -275,7 +275,7 @@ static bool falcon_xmac_check_fault(struct efx_nic *efx)
 	return !falcon_check_xaui_link_up(efx, 5);
 }
 
-static void falcon_reconfigure_xmac(struct efx_nic *efx)
+static int falcon_reconfigure_xmac(struct efx_nic *efx)
 {
 	falcon_mask_status_intr(efx, false);
 
@@ -286,6 +286,8 @@ static void falcon_reconfigure_xmac(struct efx_nic *efx)
 
 	efx->xmac_poll_required = !falcon_check_xaui_link_up(efx, 5);
 	falcon_mask_status_intr(efx, true);
+
+	return 0;
 }
 
 static void falcon_update_stats_xmac(struct efx_nic *efx)
diff --git a/drivers/net/sfc/mac.h b/drivers/net/sfc/mac.h
index 4e70742..d2af50f 100644
--- a/drivers/net/sfc/mac.h
+++ b/drivers/net/sfc/mac.h
@@ -15,5 +15,6 @@
 
 extern struct efx_mac_operations falcon_gmac_operations;
 extern struct efx_mac_operations falcon_xmac_operations;
+extern void falcon_reconfigure_xmac_core(struct efx_nic *efx);
 
 #endif
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 231e580..1f62a5c 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -248,8 +248,6 @@ void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
 int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	struct ethtool_cmd prev;
-	bool xnp;
-	int reg;
 
 	efx->phy_op->get_settings(efx, &prev);
 
@@ -269,30 +267,47 @@ int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	    (ecmd->advertising | SUPPORTED_Autoneg) & ~prev.supported)
 		return -EINVAL;
 
-	xnp = (ecmd->advertising & ADVERTISED_10000baseT_Full
-	       || EFX_WORKAROUND_13204(efx));
+	efx_link_set_advertising(efx, ecmd->advertising | ADVERTISED_Autoneg);
+	efx_mdio_an_reconfigure(efx);
+	return 0;
+}
+
+/**
+ * efx_mdio_an_reconfigure - Push advertising flags and restart autonegotiation
+ * @efx:		Efx NIC
+ */
+void efx_mdio_an_reconfigure(struct efx_nic *efx)
+{
+	bool xnp = (efx->link_advertising & ADVERTISED_10000baseT_Full
+		    || EFX_WORKAROUND_13204(efx));
+	int reg;
+
+	WARN_ON(!(efx->mdio.mmds & MDIO_DEVS_AN));
 
 	/* Set up the base page */
 	reg = ADVERTISE_CSMA;
-	if (ecmd->advertising & ADVERTISED_10baseT_Half)
+	if (efx->link_advertising & ADVERTISED_10baseT_Half)
 		reg |= ADVERTISE_10HALF;
-	if (ecmd->advertising & ADVERTISED_10baseT_Full)
+	if (efx->link_advertising & ADVERTISED_10baseT_Full)
 		reg |= ADVERTISE_10FULL;
-	if (ecmd->advertising & ADVERTISED_100baseT_Half)
+	if (efx->link_advertising & ADVERTISED_100baseT_Half)
 		reg |= ADVERTISE_100HALF;
-	if (ecmd->advertising & ADVERTISED_100baseT_Full)
+	if (efx->link_advertising & ADVERTISED_100baseT_Full)
 		reg |= ADVERTISE_100FULL;
 	if (xnp)
 		reg |= ADVERTISE_RESV;
-	else if (ecmd->advertising & (ADVERTISED_1000baseT_Half |
-				      ADVERTISED_1000baseT_Full))
+	else if (efx->link_advertising & (ADVERTISED_1000baseT_Half |
+					  ADVERTISED_1000baseT_Full))
 		reg |= ADVERTISE_NPAGE;
-	reg |= mii_advertise_flowctrl(efx->wanted_fc);
+	if (efx->link_advertising & ADVERTISED_Pause)
+		reg |= ADVERTISE_PAUSE_CAP;
+	if (efx->link_advertising & ADVERTISED_Asym_Pause)
+		reg |= ADVERTISE_PAUSE_ASYM;
 	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
 
 	/* Set up the (extended) next page if necessary */
 	if (efx->phy_op->set_npage_adv)
-		efx->phy_op->set_npage_adv(efx, ecmd->advertising);
+		efx->phy_op->set_npage_adv(efx, efx->link_advertising);
 
 	/* Enable and restart AN */
 	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
@@ -305,8 +320,6 @@ int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	else
 		reg &= ~MDIO_AN_CTRL1_XNP;
 	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
-
-	return 0;
 }
 
 enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx)
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 75b37f1..dbc8e7d 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -86,6 +86,9 @@ extern void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
 /* Set (some of) the PHY settings over MDIO */
 extern int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd);
 
+/* Push advertising flags and restart autonegotiation */
+extern void efx_mdio_an_reconfigure(struct efx_nic *efx);
+
 /* Get pause parameters from AN if available (otherwise return
  * requested pause parameters)
  */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 1b98cd0..ecb24b9 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -517,7 +517,7 @@ static inline bool efx_link_state_equal(const struct efx_link_state *left,
  * @check_fault: Check fault state. True if fault present.
  */
 struct efx_mac_operations {
-	void (*reconfigure) (struct efx_nic *efx);
+	int (*reconfigure) (struct efx_nic *efx);
 	void (*update_stats) (struct efx_nic *efx);
 	bool (*check_fault)(struct efx_nic *efx);
 };
@@ -544,7 +544,7 @@ struct efx_phy_operations {
 	enum efx_mac_type macs;
 	int (*init) (struct efx_nic *efx);
 	void (*fini) (struct efx_nic *efx);
-	void (*reconfigure) (struct efx_nic *efx);
+	int (*reconfigure) (struct efx_nic *efx);
 	bool (*poll) (struct efx_nic *efx);
 	void (*get_settings) (struct efx_nic *efx,
 			      struct ethtool_cmd *ecmd);
@@ -730,6 +730,7 @@ union efx_multicast_hash {
  * @mdio: PHY MDIO interface
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
  * @xmac_poll_required: XMAC link state needs polling
+ * @link_advertising: Autonegotiation advertising flags
  * @link_state: Current state of the link
  * @n_link_state_changes: Number of times the link has changed state
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
@@ -813,6 +814,7 @@ struct efx_nic {
 	enum efx_phy_mode phy_mode;
 
 	bool xmac_poll_required;
+	u32 link_advertising;
 	struct efx_link_state link_state;
 	unsigned int n_link_state_changes;
 
@@ -858,6 +860,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @stop_stats: Stop the regular fetching of statistics
  * @push_irq_moderation: Apply interrupt moderation value
  * @push_multicast_hash: Apply multicast hash table
+ * @reconfigure_port: Push loopback/power/txdis changes to the MAC and PHY
  * @default_mac_ops: efx_mac_operations to set at startup
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
@@ -892,6 +895,7 @@ struct efx_nic_type {
 	void (*stop_stats)(struct efx_nic *efx);
 	void (*push_irq_moderation)(struct efx_channel *channel);
 	void (*push_multicast_hash)(struct efx_nic *efx);
+	int (*reconfigure_port)(struct efx_nic *efx);
 	struct efx_mac_operations *default_mac_ops;
 
 	int revision;
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 3d7370e..4c38516 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -178,7 +178,7 @@ static bool qt202x_phy_poll(struct efx_nic *efx)
 	return efx->link_state.up != was_up;
 }
 
-static void qt202x_phy_reconfigure(struct efx_nic *efx)
+static int qt202x_phy_reconfigure(struct efx_nic *efx)
 {
 	struct qt202x_phy_data *phy_data = efx->phy_data;
 
@@ -207,6 +207,8 @@ static void qt202x_phy_reconfigure(struct efx_nic *efx)
 	efx_mdio_phy_reconfigure(efx);
 
 	phy_data->phy_mode = efx->phy_mode;
+
+	return 0;
 }
 
 static void qt202x_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 15d4d9c..dddeb9d 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -659,7 +659,6 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
 	int phy_mode = efx->phy_mode;
 	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
-	struct ethtool_cmd ecmd;
 	struct efx_channel *channel;
 	int rc_test = 0, rc_reset = 0, rc;
 
@@ -712,7 +711,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	mutex_unlock(&efx->mac_lock);
 
 	/* free up all consumers of SRAM (including all the queues) */
-	efx_reset_down(efx, reset_method, &ecmd);
+	efx_reset_down(efx, reset_method);
 
 	rc = efx_test_chip(efx, tests);
 	if (rc && !rc_test)
@@ -726,7 +725,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	efx->phy_mode &= ~PHY_MODE_LOW_POWER;
 	efx->loopback_mode = LOOPBACK_NONE;
 
-	rc = efx_reset_up(efx, reset_method, &ecmd, rc_reset == 0);
+	rc = efx_reset_up(efx, reset_method, rc_reset == 0);
 	if (rc && !rc_reset)
 		rc_reset = rc;
 
@@ -745,10 +744,12 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 		rc_test = rc;
 
 	/* restore the PHY to the previous state */
-	efx->loopback_mode = loopback_mode;
+	mutex_lock(&efx->mac_lock);
 	efx->phy_mode = phy_mode;
 	efx->port_inhibited = false;
-	efx_ethtool_set_settings(efx->net_dev, &ecmd);
+	efx->loopback_mode = loopback_mode;
+	__efx_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
 
 	return rc_test;
 }
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 1bd7965..c301853 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -199,15 +199,16 @@ static ssize_t set_phy_short_reach(struct device *dev,
 				   const char *buf, size_t count)
 {
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	int rc;
 
 	rtnl_lock();
 	efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_PMA_10GBT_TXPWR,
 			  MDIO_PMA_10GBT_TXPWR_SHORT,
 			  count != 0 && *buf != '0');
-	efx_reconfigure_port(efx);
+	rc = efx_reconfigure_port(efx);
 	rtnl_unlock();
 
-	return count;
+	return rc < 0 ? rc : (ssize_t)count;
 }
 
 static DEVICE_ATTR(phy_short_reach, 0644, show_phy_short_reach,
@@ -300,7 +301,6 @@ static int tenxpress_init(struct efx_nic *efx)
 static int tenxpress_phy_init(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data;
-	u16 old_adv, adv;
 	int rc = 0;
 
 	falcon_board(efx)->type->init_phy(efx);
@@ -335,14 +335,14 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail;
 
-	/* Set pause advertising */
-	old_adv = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
-	adv = ((old_adv & ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)) |
-	       mii_advertise_flowctrl(efx->wanted_fc));
-	if (adv != old_adv) {
-		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, adv);
-		mdio45_nway_restart(&efx->mdio);
-	}
+	/* Initialise advertising flags */
+	efx->link_advertising = (ADVERTISED_TP | ADVERTISED_Autoneg |
+				  ADVERTISED_10000baseT_Full);
+	if (efx->phy_type != PHY_TYPE_SFX7101)
+		efx->link_advertising |= (ADVERTISED_1000baseT_Full |
+					   ADVERTISED_100baseT_Full);
+	efx_link_set_wanted_fc(efx, efx->wanted_fc);
+	efx_mdio_an_reconfigure(efx);
 
 	if (efx->phy_type == PHY_TYPE_SFT9001B) {
 		rc = device_create_file(&efx->pci_dev->dev,
@@ -500,49 +500,41 @@ static void tenxpress_low_power(struct efx_nic *efx)
 			!!(efx->phy_mode & PHY_MODE_LOW_POWER));
 }
 
-static void tenxpress_phy_reconfigure(struct efx_nic *efx)
+static int tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	struct ethtool_cmd ecmd;
 	bool phy_mode_change, loop_reset;
 
 	if (efx->phy_mode & (PHY_MODE_OFF | PHY_MODE_SPECIAL)) {
 		phy_data->phy_mode = efx->phy_mode;
-		return;
+		return 0;
 	}
 
-	tenxpress_low_power(efx);
-
 	phy_mode_change = (efx->phy_mode == PHY_MODE_NORMAL &&
 			   phy_data->phy_mode != PHY_MODE_NORMAL);
 	loop_reset = (LOOPBACK_OUT_OF(phy_data, efx, efx->phy_op->loopbacks) ||
 		      LOOPBACK_CHANGED(phy_data, efx, 1 << LOOPBACK_GPHY));
 
 	if (loop_reset || phy_mode_change) {
-		int rc;
-
-		efx->phy_op->get_settings(efx, &ecmd);
+		tenxpress_special_reset(efx);
 
-		if (loop_reset || phy_mode_change) {
-			tenxpress_special_reset(efx);
-
-			/* Reset XAUI if we were in 10G, and are staying
-			 * in 10G. If we're moving into and out of 10G
-			 * then xaui will be reset anyway */
-			if (EFX_IS10G(efx))
-				falcon_reset_xaui(efx);
-		}
-
-		rc = efx->phy_op->set_settings(efx, &ecmd);
-		WARN_ON(rc);
+		/* Reset XAUI if we were in 10G, and are staying
+		 * in 10G. If we're moving into and out of 10G
+		 * then xaui will be reset anyway */
+		if (EFX_IS10G(efx))
+			falcon_reset_xaui(efx);
 	}
 
+	tenxpress_low_power(efx);
 	efx_mdio_transmit_disable(efx);
 	efx_mdio_phy_reconfigure(efx);
 	tenxpress_ext_loopback(efx);
+	efx_mdio_an_reconfigure(efx);
 
 	phy_data->loopback_mode = efx->loopback_mode;
 	phy_data->phy_mode = efx->phy_mode;
+
+	return 0;
 }
 
 static void
@@ -646,6 +638,9 @@ sfx7101_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 	/* BIST is automatically run after a special software reset */
 	rc = tenxpress_special_reset(efx);
 	results[0] = rc ? -1 : 1;
+
+	efx_mdio_an_reconfigure(efx);
+
 	return rc;
 }
 
@@ -663,12 +658,8 @@ static const char *const sft9001_test_names[] = {
 
 static int sft9001_run_tests(struct efx_nic *efx, int *results, unsigned flags)
 {
-	struct ethtool_cmd ecmd;
 	int rc = 0, rc2, i, ctrl_reg, res_reg;
 
-	if (flags & ETH_TEST_FL_OFFLINE)
-		efx->phy_op->get_settings(efx, &ecmd);
-
 	/* Initialise cable diagnostic results to unknown failure */
 	for (i = 1; i < 9; ++i)
 		results[i] = -1;
@@ -720,9 +711,7 @@ out:
 		if (!rc)
 			rc = rc2;
 
-		rc2 = efx->phy_op->set_settings(efx, &ecmd);
-		if (!rc)
-			rc = rc2;
+		efx_mdio_an_reconfigure(efx);
 	}
 
 	return rc;
@@ -753,7 +742,6 @@ tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 
 	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
 
-	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 	if (efx->phy_type != PHY_TYPE_SFX7101) {
 		ecmd->supported |= (SUPPORTED_100baseT_Full |
 				    SUPPORTED_1000baseT_Full);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

