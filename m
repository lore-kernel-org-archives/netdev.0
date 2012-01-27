From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/32] sfc: Merge efx_mac_operations into
 efx_nic_type
Date: Fri, 27 Jan 2012 20:45:52 +0000
Message-ID: <1327697152.2503.20.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63617 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751534Ab2A0Upz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:45:55 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No NICs need to switch efx_mac_operations at run-time, and the MAC
operations are fairly closely bound to NIC types.

Move efx_mac_operations::reconfigure to efx_nic_type::reconfigure_mac
and efx_mac_operations::check_fault fo efx_nic_type::check_mac_fault.
Change callers to call through efx->type or directly if the NIC type
is known.

Remove efx_mac_operations::update_stats.  The implementations for
Falcon used to fetch MAC statistics synchronously and this was used by
efx_register_netdev() to clear statistics after running self-tests.
However, it now only converts statistics that have already been
fetched (and that only for Falcon), and the call from
efx_register_netdev() has no effect.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c         |   17 ++++++-----------
 drivers/net/ethernet/sfc/ethtool.c     |    4 ++--
 drivers/net/ethernet/sfc/falcon.c      |   15 ++++++++-------
 drivers/net/ethernet/sfc/falcon_xmac.c |   13 +++----------
 drivers/net/ethernet/sfc/mac.h         |   21 ---------------------
 drivers/net/ethernet/sfc/mcdi.h        |    4 ++++
 drivers/net/ethernet/sfc/mcdi_mac.c    |   12 ++----------
 drivers/net/ethernet/sfc/net_driver.h  |   21 ++++-----------------
 drivers/net/ethernet/sfc/nic.h         |    3 +++
 drivers/net/ethernet/sfc/selftest.c    |    2 +-
 drivers/net/ethernet/sfc/siena.c       |    4 ++--
 11 files changed, 35 insertions(+), 81 deletions(-)
 delete mode 100644 drivers/net/ethernet/sfc/mac.h

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8f4cbb6..1d20e01 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -900,7 +900,7 @@ static void efx_mac_work(struct work_struct *data)
 	mutex_lock(&efx->mac_lock);
 	if (efx->port_enabled) {
 		efx->type->push_multicast_hash(efx);
-		efx->mac_op->reconfigure(efx);
+		efx->type->reconfigure_mac(efx);
 	}
 	mutex_unlock(&efx->mac_lock);
 }
@@ -941,7 +941,7 @@ static int efx_init_port(struct efx_nic *efx)
 
 	/* Reconfigure the MAC before creating dma queues (required for
 	 * Falcon/A1 where RX_INGR_EN/TX_DRAIN_EN isn't supported) */
-	efx->mac_op->reconfigure(efx);
+	efx->type->reconfigure_mac(efx);
 
 	/* Ensure the PHY advertises the correct flow control settings */
 	rc = efx->phy_op->reconfigure(efx);
@@ -969,7 +969,7 @@ static void efx_start_port(struct efx_nic *efx)
 	/* efx_mac_work() might have been scheduled after efx_stop_port(),
 	 * and then cancelled by efx_flush_all() */
 	efx->type->push_multicast_hash(efx);
-	efx->mac_op->reconfigure(efx);
+	efx->type->reconfigure_mac(efx);
 
 	mutex_unlock(&efx->mac_lock);
 }
@@ -1807,7 +1807,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	/* Reconfigure the MAC before enabling the dma queues so that
 	 * the RX buffers don't overflow */
 	net_dev->mtu = new_mtu;
-	efx->mac_op->reconfigure(efx);
+	efx->type->reconfigure_mac(efx);
 	mutex_unlock(&efx->mac_lock);
 
 	efx_init_channels(efx);
@@ -1835,7 +1835,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 
 	/* Reconfigure the MAC */
 	mutex_lock(&efx->mac_lock);
-	efx->mac_op->reconfigure(efx);
+	efx->type->reconfigure_mac(efx);
 	mutex_unlock(&efx->mac_lock);
 
 	return 0;
@@ -1949,10 +1949,6 @@ static int efx_register_netdev(struct efx_nic *efx)
 	net_dev->netdev_ops = &efx_netdev_ops;
 	SET_ETHTOOL_OPS(net_dev, &efx_ethtool_ops);
 
-	/* Clear MAC statistics */
-	efx->mac_op->update_stats(efx);
-	memset(&efx->mac_stats, 0, sizeof(efx->mac_stats));
-
 	rtnl_lock();
 
 	rc = dev_alloc_name(net_dev, net_dev->name);
@@ -2069,7 +2065,7 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 				  "could not restore PHY settings\n");
 	}
 
-	efx->mac_op->reconfigure(efx);
+	efx->type->reconfigure_mac(efx);
 
 	efx_init_channels(efx);
 	efx_restore_filters(efx);
@@ -2274,7 +2270,6 @@ static int efx_init_struct(struct efx_nic *efx, const struct efx_nic_type *type,
 	efx->net_dev = net_dev;
 	spin_lock_init(&efx->stats_lock);
 	mutex_init(&efx->mac_lock);
-	efx->mac_op = type->default_mac_ops;
 	efx->phy_op = &efx_dummy_phy_operations;
 	efx->mdio.dev = net_dev;
 	INIT_WORK(&efx->mac_work, efx_mac_work);
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 55a25b1..1a7f7ba 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -750,7 +750,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 			/* Recover by resetting the EM block */
 			falcon_stop_nic_stats(efx);
 			falcon_drain_tx_fifo(efx);
-			efx->mac_op->reconfigure(efx);
+			falcon_reconfigure_xmac(efx);
 			falcon_start_nic_stats(efx);
 		} else {
 			/* Schedule a reset to recover */
@@ -775,7 +775,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	/* Reconfigure the MAC. The PHY *may* generate a link state change event
 	 * if the user just changed the advertised capabilities, but there's no
 	 * harm doing this twice */
-	efx->mac_op->reconfigure(efx);
+	efx->type->reconfigure_mac(efx);
 
 out:
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 5c75489..1a8a316 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -19,7 +19,6 @@
 #include "net_driver.h"
 #include "bitfield.h"
 #include "efx.h"
-#include "mac.h"
 #include "spi.h"
 #include "nic.h"
 #include "regs.h"
@@ -613,7 +612,7 @@ static void falcon_stats_complete(struct efx_nic *efx)
 	nic_data->stats_pending = false;
 	if (*nic_data->stats_dma_done == FALCON_STATS_DONE) {
 		rmb(); /* read the done flag before the stats */
-		efx->mac_op->update_stats(efx);
+		falcon_update_stats_xmac(efx);
 	} else {
 		netif_err(efx, hw, efx->net_dev,
 			  "timed out waiting for statistics\n");
@@ -670,7 +669,7 @@ static int falcon_reconfigure_port(struct efx_nic *efx)
 	falcon_reset_macs(efx);
 
 	efx->phy_op->reconfigure(efx);
-	rc = efx->mac_op->reconfigure(efx);
+	rc = falcon_reconfigure_xmac(efx);
 	BUG_ON(rc);
 
 	falcon_start_nic_stats(efx);
@@ -1218,7 +1217,7 @@ static void falcon_monitor(struct efx_nic *efx)
 		falcon_deconfigure_mac_wrapper(efx);
 
 		falcon_reset_macs(efx);
-		rc = efx->mac_op->reconfigure(efx);
+		rc = falcon_reconfigure_xmac(efx);
 		BUG_ON(rc);
 
 		falcon_start_nic_stats(efx);
@@ -1676,7 +1675,7 @@ static void falcon_update_nic_stats(struct efx_nic *efx)
 	    *nic_data->stats_dma_done == FALCON_STATS_DONE) {
 		nic_data->stats_pending = false;
 		rmb(); /* read the done flag before the stats */
-		efx->mac_op->update_stats(efx);
+		falcon_update_stats_xmac(efx);
 	}
 }
 
@@ -1769,11 +1768,12 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
+	.reconfigure_mac = falcon_reconfigure_xmac,
+	.check_mac_fault = falcon_xmac_check_fault,
 	.get_wol = falcon_get_wol,
 	.set_wol = falcon_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
 	.test_nvram = falcon_test_nvram,
-	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_A1,
 	.mem_map_size = 0x20000,
@@ -1811,12 +1811,13 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
+	.reconfigure_mac = falcon_reconfigure_xmac,
+	.check_mac_fault = falcon_xmac_check_fault,
 	.get_wol = falcon_get_wol,
 	.set_wol = falcon_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
 	.test_registers = falcon_b0_test_registers,
 	.test_nvram = falcon_test_nvram,
-	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_B0,
 	/* Map everything up to and including the RSS indirection
diff --git a/drivers/net/ethernet/sfc/falcon_xmac.c b/drivers/net/ethernet/sfc/falcon_xmac.c
index 5743459..6106ef1 100644
--- a/drivers/net/ethernet/sfc/falcon_xmac.c
+++ b/drivers/net/ethernet/sfc/falcon_xmac.c
@@ -14,7 +14,6 @@
 #include "nic.h"
 #include "regs.h"
 #include "io.h"
-#include "mac.h"
 #include "mdio_10g.h"
 #include "workarounds.h"
 
@@ -270,12 +269,12 @@ static bool falcon_xmac_link_ok_retry(struct efx_nic *efx, int tries)
 	return mac_up;
 }
 
-static bool falcon_xmac_check_fault(struct efx_nic *efx)
+bool falcon_xmac_check_fault(struct efx_nic *efx)
 {
 	return !falcon_xmac_link_ok_retry(efx, 5);
 }
 
-static int falcon_reconfigure_xmac(struct efx_nic *efx)
+int falcon_reconfigure_xmac(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 
@@ -290,7 +289,7 @@ static int falcon_reconfigure_xmac(struct efx_nic *efx)
 	return 0;
 }
 
-static void falcon_update_stats_xmac(struct efx_nic *efx)
+void falcon_update_stats_xmac(struct efx_nic *efx)
 {
 	struct efx_mac_stats *mac_stats = &efx->mac_stats;
 
@@ -361,9 +360,3 @@ void falcon_poll_xmac(struct efx_nic *efx)
 	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 1);
 	falcon_ack_status_intr(efx);
 }
-
-const struct efx_mac_operations falcon_xmac_operations = {
-	.reconfigure	= falcon_reconfigure_xmac,
-	.update_stats	= falcon_update_stats_xmac,
-	.check_fault	= falcon_xmac_check_fault,
-};
diff --git a/drivers/net/ethernet/sfc/mac.h b/drivers/net/ethernet/sfc/mac.h
deleted file mode 100644
index d6a255d..0000000
--- a/drivers/net/ethernet/sfc/mac.h
+++ /dev/null
@@ -1,21 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2005-2006 Fen Systems Ltd.
- * Copyright 2006-2009 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_MAC_H
-#define EFX_MAC_H
-
-#include "net_driver.h"
-
-extern const struct efx_mac_operations falcon_xmac_operations;
-extern const struct efx_mac_operations efx_mcdi_mac_operations;
-extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
-			      u32 dma_len, int enable, int clear);
-
-#endif
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index aced2a7..c59667b 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -126,5 +126,9 @@ extern int efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,
 extern int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out);
 extern int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id);
 extern int efx_mcdi_wol_filter_reset(struct efx_nic *efx);
+extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
+			      u32 dma_len, int enable, int clear);
+extern int efx_mcdi_mac_reconfigure(struct efx_nic *efx);
+extern bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
 
 #endif /* EFX_MCDI_H */
diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
index 85fe24f..4907062 100644
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ b/drivers/net/ethernet/sfc/mcdi_mac.c
@@ -9,7 +9,6 @@
 
 #include "net_driver.h"
 #include "efx.h"
-#include "mac.h"
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 
@@ -115,7 +114,7 @@ fail:
 	return rc;
 }
 
-static int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
+int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
 {
 	int rc;
 
@@ -130,16 +129,9 @@ static int efx_mcdi_mac_reconfigure(struct efx_nic *efx)
 }
 

-static bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
+bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
 {
 	u32 faults;
 	int rc = efx_mcdi_get_mac_faults(efx, &faults);
 	return (rc != 0) || (faults != 0);
 }
-
-
-const struct efx_mac_operations efx_mcdi_mac_operations = {
-	.reconfigure	= efx_mcdi_mac_reconfigure,
-	.update_stats	= efx_port_dummy_op_void,
-	.check_fault	= efx_mcdi_mac_check_fault,
-};
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index b604014..aa5a321 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -474,18 +474,6 @@ static inline bool efx_link_state_equal(const struct efx_link_state *left,
 }
 
 /**
- * struct efx_mac_operations - Efx MAC operations table
- * @reconfigure: Reconfigure MAC. Serialised by the mac_lock
- * @update_stats: Update statistics
- * @check_fault: Check fault state. True if fault present.
- */
-struct efx_mac_operations {
-	int (*reconfigure) (struct efx_nic *efx);
-	void (*update_stats) (struct efx_nic *efx);
-	bool (*check_fault)(struct efx_nic *efx);
-};
-
-/**
  * struct efx_phy_operations - Efx PHY operations table
  * @probe: Probe PHY and initialise efx->mdio.mode_support, efx->mdio.mmds,
  *	efx->loopback_modes.
@@ -676,7 +664,6 @@ struct efx_filter_state;
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
  * @stats_buffer: DMA buffer for statistics
- * @mac_op: MAC interface
  * @phy_type: PHY type
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
@@ -767,8 +754,6 @@ struct efx_nic {
 
 	struct efx_buffer stats_buffer;
 
-	const struct efx_mac_operations *mac_op;
-
 	unsigned int phy_type;
 	const struct efx_phy_operations *phy_op;
 	void *phy_data;
@@ -843,12 +828,13 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @push_irq_moderation: Apply interrupt moderation value
  * @push_multicast_hash: Apply multicast hash table
  * @reconfigure_port: Push loopback/power/txdis changes to the MAC and PHY
+ * @reconfigure_mac: Reconfigure MAC only. Serialised by the mac_lock
+ * @check_mac_fault: Check MAC fault state. True if fault present.
  * @get_wol: Get WoL configuration from driver state
  * @set_wol: Push WoL configuration to the NIC
  * @resume_wol: Synchronise WoL state between driver and MC (e.g. after resume)
  * @test_registers: Test read/write functionality of control registers
  * @test_nvram: Test validity of NVRAM contents
- * @default_mac_ops: efx_mac_operations to set at startup
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
  * @txd_ptr_tbl_base: TX descriptor ring base address
@@ -888,12 +874,13 @@ struct efx_nic_type {
 	void (*push_irq_moderation)(struct efx_channel *channel);
 	void (*push_multicast_hash)(struct efx_nic *efx);
 	int (*reconfigure_port)(struct efx_nic *efx);
+	int (*reconfigure_mac)(struct efx_nic *efx);
+	bool (*check_mac_fault)(struct efx_nic *efx);
 	void (*get_wol)(struct efx_nic *efx, struct ethtool_wolinfo *wol);
 	int (*set_wol)(struct efx_nic *efx, u32 type);
 	void (*resume_wol)(struct efx_nic *efx);
 	int (*test_registers)(struct efx_nic *efx);
 	int (*test_nvram)(struct efx_nic *efx);
-	const struct efx_mac_operations *default_mac_ops;
 
 	int revision;
 	unsigned int mem_map_size;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 5fb24d3..cfda6de 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -189,6 +189,9 @@ extern bool efx_nic_event_present(struct efx_channel *channel);
 /* MAC/PHY */
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
 extern void falcon_reconfigure_mac_wrapper(struct efx_nic *efx);
+extern bool falcon_xmac_check_fault(struct efx_nic *efx);
+extern int falcon_reconfigure_xmac(struct efx_nic *efx);
+extern void falcon_update_stats_xmac(struct efx_nic *efx);
 
 /* Interrupts and test events */
 extern int efx_nic_init_interrupt(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 5226d98..9df2a79 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -569,7 +569,7 @@ static int efx_wait_for_link(struct efx_nic *efx)
 		mutex_lock(&efx->mac_lock);
 		link_up = link_state->up;
 		if (link_up)
-			link_up = !efx->mac_op->check_fault(efx);
+			link_up = !efx->type->check_mac_fault(efx);
 		mutex_unlock(&efx->mac_lock);
 
 		if (link_up) {
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 4d5d619..775b678 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -18,7 +18,6 @@
 #include "bitfield.h"
 #include "efx.h"
 #include "nic.h"
-#include "mac.h"
 #include "spi.h"
 #include "regs.h"
 #include "io.h"
@@ -631,13 +630,14 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.set_id_led = efx_mcdi_set_id_led,
 	.push_irq_moderation = siena_push_irq_moderation,
 	.push_multicast_hash = siena_push_multicast_hash,
+	.reconfigure_mac = efx_mcdi_mac_reconfigure,
+	.check_mac_fault = efx_mcdi_mac_check_fault,
 	.reconfigure_port = efx_mcdi_phy_reconfigure,
 	.get_wol = siena_get_wol,
 	.set_wol = siena_set_wol,
 	.resume_wol = siena_init_wol,
 	.test_registers = siena_test_registers,
 	.test_nvram = efx_mcdi_nvram_test_all,
-	.default_mac_ops = &efx_mcdi_mac_operations,
 
 	.revision = EFX_REV_SIENA_A0,
 	.mem_map_size = (FR_CZ_MC_TREG_SMEM +
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
