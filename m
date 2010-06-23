From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/5] sfc: Implement message level control
Date: Wed, 23 Jun 2010 22:30:07 +0100
Message-ID: <1277328607.2101.9.camel@achroite.uk.solarflarecom.com>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18521 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab0FWVaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 17:30:12 -0400
In-Reply-To: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace EFX_ERR() with netif_err(), EFX_INFO() with netif_info(),
EFX_LOG() with netif_dbg() and EFX_TRACE() and EFX_REGDUMP() with
netif_vdbg().

Replace EFX_ERR_RL(), EFX_INFO_RL() and EFX_LOG_RL() using explicit
calls to net_ratelimit().

Implement the ethtool operations to get and set message level flags,
and add a 'debug' module parameter for the initial value.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |  223 +++++++++++++++++++++++---------------
 drivers/net/sfc/efx.h           |    5 +-
 drivers/net/sfc/ethtool.c       |   46 ++++++---
 drivers/net/sfc/falcon.c        |  176 +++++++++++++++++++------------
 drivers/net/sfc/falcon_boards.c |   30 +++---
 drivers/net/sfc/falcon_xmac.c   |    5 +-
 drivers/net/sfc/io.h            |   30 +++--
 drivers/net/sfc/mcdi.c          |   98 ++++++++++--------
 drivers/net/sfc/mcdi_mac.c      |    8 +-
 drivers/net/sfc/mcdi_phy.c      |   20 ++--
 drivers/net/sfc/mdio_10g.c      |   39 ++++---
 drivers/net/sfc/mdio_10g.h      |    3 +-
 drivers/net/sfc/net_driver.h    |   35 +-----
 drivers/net/sfc/nic.c           |  219 ++++++++++++++++++++++-----------------
 drivers/net/sfc/qt202x_phy.c    |   42 ++++---
 drivers/net/sfc/rx.c            |   56 ++++++----
 drivers/net/sfc/selftest.c      |  126 +++++++++++++---------
 drivers/net/sfc/siena.c         |   42 +++++---
 drivers/net/sfc/tenxpress.c     |   12 ++-
 drivers/net/sfc/tx.c            |   41 ++++---
 20 files changed, 727 insertions(+), 529 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 8ad476a..7251400 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -189,6 +189,13 @@ module_param(irq_adapt_high_thresh, uint, 0644);
 MODULE_PARM_DESC(irq_adapt_high_thresh,
 		 "Threshold score for increasing IRQ moderation");
 
+static unsigned debug = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
+			 NETIF_MSG_LINK | NETIF_MSG_IFDOWN |
+			 NETIF_MSG_IFUP | NETIF_MSG_RX_ERR |
+			 NETIF_MSG_TX_ERR | NETIF_MSG_HW);
+module_param(debug, uint, 0);
+MODULE_PARM_DESC(debug, "Bitmapped debugging message enable value");
+
 /**************************************************************************
  *
  * Utility functions and prototypes
@@ -272,16 +279,16 @@ static int efx_poll(struct napi_struct *napi, int budget)
 {
 	struct efx_channel *channel =
 		container_of(napi, struct efx_channel, napi_str);
+	struct efx_nic *efx = channel->efx;
 	int spent;
 
-	EFX_TRACE(channel->efx, "channel %d NAPI poll executing on CPU %d\n",
-		  channel->channel, raw_smp_processor_id());
+	netif_vdbg(efx, intr, efx->net_dev,
+		   "channel %d NAPI poll executing on CPU %d\n",
+		   channel->channel, raw_smp_processor_id());
 
 	spent = efx_process_channel(channel, budget);
 
 	if (spent < budget) {
-		struct efx_nic *efx = channel->efx;
-
 		if (channel->channel < efx->n_rx_channels &&
 		    efx->irq_rx_adaptive &&
 		    unlikely(++channel->irq_count == 1000)) {
@@ -357,7 +364,8 @@ void efx_process_channel_now(struct efx_channel *channel)
  */
 static int efx_probe_eventq(struct efx_channel *channel)
 {
-	EFX_LOG(channel->efx, "chan %d create event queue\n", channel->channel);
+	netif_dbg(channel->efx, probe, channel->efx->net_dev,
+		  "chan %d create event queue\n", channel->channel);
 
 	return efx_nic_probe_eventq(channel);
 }
@@ -365,7 +373,8 @@ static int efx_probe_eventq(struct efx_channel *channel)
 /* Prepare channel's event queue */
 static void efx_init_eventq(struct efx_channel *channel)
 {
-	EFX_LOG(channel->efx, "chan %d init event queue\n", channel->channel);
+	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+		  "chan %d init event queue\n", channel->channel);
 
 	channel->eventq_read_ptr = 0;
 
@@ -374,14 +383,16 @@ static void efx_init_eventq(struct efx_channel *channel)
 
 static void efx_fini_eventq(struct efx_channel *channel)
 {
-	EFX_LOG(channel->efx, "chan %d fini event queue\n", channel->channel);
+	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+		  "chan %d fini event queue\n", channel->channel);
 
 	efx_nic_fini_eventq(channel);
 }
 
 static void efx_remove_eventq(struct efx_channel *channel)
 {
-	EFX_LOG(channel->efx, "chan %d remove event queue\n", channel->channel);
+	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+		  "chan %d remove event queue\n", channel->channel);
 
 	efx_nic_remove_eventq(channel);
 }
@@ -398,7 +409,8 @@ static int efx_probe_channel(struct efx_channel *channel)
 	struct efx_rx_queue *rx_queue;
 	int rc;
 
-	EFX_LOG(channel->efx, "creating channel %d\n", channel->channel);
+	netif_dbg(channel->efx, probe, channel->efx->net_dev,
+		  "creating channel %d\n", channel->channel);
 
 	rc = efx_probe_eventq(channel);
 	if (rc)
@@ -474,7 +486,8 @@ static void efx_init_channels(struct efx_nic *efx)
 
 	/* Initialise the channels */
 	efx_for_each_channel(channel, efx) {
-		EFX_LOG(channel->efx, "init chan %d\n", channel->channel);
+		netif_dbg(channel->efx, drv, channel->efx->net_dev,
+			  "init chan %d\n", channel->channel);
 
 		efx_init_eventq(channel);
 
@@ -501,7 +514,8 @@ static void efx_start_channel(struct efx_channel *channel)
 {
 	struct efx_rx_queue *rx_queue;
 
-	EFX_LOG(channel->efx, "starting chan %d\n", channel->channel);
+	netif_dbg(channel->efx, ifup, channel->efx->net_dev,
+		  "starting chan %d\n", channel->channel);
 
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we enable it.  Make sure it's cleared before
@@ -526,7 +540,8 @@ static void efx_stop_channel(struct efx_channel *channel)
 	if (!channel->enabled)
 		return;
 
-	EFX_LOG(channel->efx, "stop chan %d\n", channel->channel);
+	netif_dbg(channel->efx, ifdown, channel->efx->net_dev,
+		  "stop chan %d\n", channel->channel);
 
 	channel->enabled = false;
 	napi_disable(&channel->napi_str);
@@ -548,16 +563,19 @@ static void efx_fini_channels(struct efx_nic *efx)
 		 * descriptor caches reference memory we're about to free,
 		 * but falcon_reconfigure_mac_wrapper() won't reconnect
 		 * the MACs because of the pending reset. */
-		EFX_ERR(efx, "Resetting to recover from flush failure\n");
+		netif_err(efx, drv, efx->net_dev,
+			  "Resetting to recover from flush failure\n");
 		efx_schedule_reset(efx, RESET_TYPE_ALL);
 	} else if (rc) {
-		EFX_ERR(efx, "failed to flush queues\n");
+		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
 	} else {
-		EFX_LOG(efx, "successfully flushed all queues\n");
+		netif_dbg(efx, drv, efx->net_dev,
+			  "successfully flushed all queues\n");
 	}
 
 	efx_for_each_channel(channel, efx) {
-		EFX_LOG(channel->efx, "shut down chan %d\n", channel->channel);
+		netif_dbg(channel->efx, drv, channel->efx->net_dev,
+			  "shut down chan %d\n", channel->channel);
 
 		efx_for_each_channel_rx_queue(rx_queue, channel)
 			efx_fini_rx_queue(rx_queue);
@@ -572,7 +590,8 @@ static void efx_remove_channel(struct efx_channel *channel)
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 
-	EFX_LOG(channel->efx, "destroy chan %d\n", channel->channel);
+	netif_dbg(channel->efx, drv, channel->efx->net_dev,
+		  "destroy chan %d\n", channel->channel);
 
 	efx_for_each_channel_rx_queue(rx_queue, channel)
 		efx_remove_rx_queue(rx_queue);
@@ -623,12 +642,13 @@ void efx_link_status_changed(struct efx_nic *efx)
 
 	/* Status message for kernel log */
 	if (link_state->up) {
-		EFX_INFO(efx, "link up at %uMbps %s-duplex (MTU %d)%s\n",
-			 link_state->speed, link_state->fd ? "full" : "half",
-			 efx->net_dev->mtu,
-			 (efx->promiscuous ? " [PROMISC]" : ""));
+		netif_info(efx, link, efx->net_dev,
+			   "link up at %uMbps %s-duplex (MTU %d)%s\n",
+			   link_state->speed, link_state->fd ? "full" : "half",
+			   efx->net_dev->mtu,
+			   (efx->promiscuous ? " [PROMISC]" : ""));
 	} else {
-		EFX_INFO(efx, "link down\n");
+		netif_info(efx, link, efx->net_dev, "link down\n");
 	}
 
 }
@@ -732,7 +752,7 @@ static int efx_probe_port(struct efx_nic *efx)
 {
 	int rc;
 
-	EFX_LOG(efx, "create port\n");
+	netif_dbg(efx, probe, efx->net_dev, "create port\n");
 
 	if (phy_flash_cfg)
 		efx->phy_mode = PHY_MODE_SPECIAL;
@@ -746,15 +766,16 @@ static int efx_probe_port(struct efx_nic *efx)
 	if (is_valid_ether_addr(efx->mac_address)) {
 		memcpy(efx->net_dev->dev_addr, efx->mac_address, ETH_ALEN);
 	} else {
-		EFX_ERR(efx, "invalid MAC address %pM\n",
-			efx->mac_address);
+		netif_err(efx, probe, efx->net_dev, "invalid MAC address %pM\n",
+			  efx->mac_address);
 		if (!allow_bad_hwaddr) {
 			rc = -EINVAL;
 			goto err;
 		}
 		random_ether_addr(efx->net_dev->dev_addr);
-		EFX_INFO(efx, "using locally-generated MAC %pM\n",
-			 efx->net_dev->dev_addr);
+		netif_info(efx, probe, efx->net_dev,
+			   "using locally-generated MAC %pM\n",
+			   efx->net_dev->dev_addr);
 	}
 
 	return 0;
@@ -768,7 +789,7 @@ static int efx_init_port(struct efx_nic *efx)
 {
 	int rc;
 
-	EFX_LOG(efx, "init port\n");
+	netif_dbg(efx, drv, efx->net_dev, "init port\n");
 
 	mutex_lock(&efx->mac_lock);
 
@@ -799,7 +820,7 @@ fail1:
 
 static void efx_start_port(struct efx_nic *efx)
 {
-	EFX_LOG(efx, "start port\n");
+	netif_dbg(efx, ifup, efx->net_dev, "start port\n");
 	BUG_ON(efx->port_enabled);
 
 	mutex_lock(&efx->mac_lock);
@@ -816,7 +837,7 @@ static void efx_start_port(struct efx_nic *efx)
 /* Prevent efx_mac_work() and efx_monitor() from working */
 static void efx_stop_port(struct efx_nic *efx)
 {
-	EFX_LOG(efx, "stop port\n");
+	netif_dbg(efx, ifdown, efx->net_dev, "stop port\n");
 
 	mutex_lock(&efx->mac_lock);
 	efx->port_enabled = false;
@@ -831,7 +852,7 @@ static void efx_stop_port(struct efx_nic *efx)
 
 static void efx_fini_port(struct efx_nic *efx)
 {
-	EFX_LOG(efx, "shut down port\n");
+	netif_dbg(efx, drv, efx->net_dev, "shut down port\n");
 
 	if (!efx->port_initialized)
 		return;
@@ -845,7 +866,7 @@ static void efx_fini_port(struct efx_nic *efx)
 
 static void efx_remove_port(struct efx_nic *efx)
 {
-	EFX_LOG(efx, "destroying port\n");
+	netif_dbg(efx, drv, efx->net_dev, "destroying port\n");
 
 	efx->type->remove_port(efx);
 }
@@ -863,11 +884,12 @@ static int efx_init_io(struct efx_nic *efx)
 	dma_addr_t dma_mask = efx->type->max_dma_mask;
 	int rc;
 
-	EFX_LOG(efx, "initialising I/O\n");
+	netif_dbg(efx, probe, efx->net_dev, "initialising I/O\n");
 
 	rc = pci_enable_device(pci_dev);
 	if (rc) {
-		EFX_ERR(efx, "failed to enable PCI device\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to enable PCI device\n");
 		goto fail1;
 	}
 
@@ -885,39 +907,45 @@ static int efx_init_io(struct efx_nic *efx)
 		dma_mask >>= 1;
 	}
 	if (rc) {
-		EFX_ERR(efx, "could not find a suitable DMA mask\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "could not find a suitable DMA mask\n");
 		goto fail2;
 	}
-	EFX_LOG(efx, "using DMA mask %llx\n", (unsigned long long) dma_mask);
+	netif_dbg(efx, probe, efx->net_dev,
+		  "using DMA mask %llx\n", (unsigned long long) dma_mask);
 	rc = pci_set_consistent_dma_mask(pci_dev, dma_mask);
 	if (rc) {
 		/* pci_set_consistent_dma_mask() is not *allowed* to
 		 * fail with a mask that pci_set_dma_mask() accepted,
 		 * but just in case...
 		 */
-		EFX_ERR(efx, "failed to set consistent DMA mask\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to set consistent DMA mask\n");
 		goto fail2;
 	}
 
 	efx->membase_phys = pci_resource_start(efx->pci_dev, EFX_MEM_BAR);
 	rc = pci_request_region(pci_dev, EFX_MEM_BAR, "sfc");
 	if (rc) {
-		EFX_ERR(efx, "request for memory BAR failed\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "request for memory BAR failed\n");
 		rc = -EIO;
 		goto fail3;
 	}
 	efx->membase = ioremap_nocache(efx->membase_phys,
 				       efx->type->mem_map_size);
 	if (!efx->membase) {
-		EFX_ERR(efx, "could not map memory BAR at %llx+%x\n",
-			(unsigned long long)efx->membase_phys,
-			efx->type->mem_map_size);
+		netif_err(efx, probe, efx->net_dev,
+			  "could not map memory BAR at %llx+%x\n",
+			  (unsigned long long)efx->membase_phys,
+			  efx->type->mem_map_size);
 		rc = -ENOMEM;
 		goto fail4;
 	}
-	EFX_LOG(efx, "memory BAR at %llx+%x (virtual %p)\n",
-		(unsigned long long)efx->membase_phys,
-		efx->type->mem_map_size, efx->membase);
+	netif_dbg(efx, probe, efx->net_dev,
+		  "memory BAR at %llx+%x (virtual %p)\n",
+		  (unsigned long long)efx->membase_phys,
+		  efx->type->mem_map_size, efx->membase);
 
 	return 0;
 
@@ -933,7 +961,7 @@ static int efx_init_io(struct efx_nic *efx)
 
 static void efx_fini_io(struct efx_nic *efx)
 {
-	EFX_LOG(efx, "shutting down I/O\n");
+	netif_dbg(efx, drv, efx->net_dev, "shutting down I/O\n");
 
 	if (efx->membase) {
 		iounmap(efx->membase);
@@ -997,9 +1025,11 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 			xentries[i].entry = i;
 		rc = pci_enable_msix(efx->pci_dev, xentries, n_channels);
 		if (rc > 0) {
-			EFX_ERR(efx, "WARNING: Insufficient MSI-X vectors"
-				" available (%d < %d).\n", rc, n_channels);
-			EFX_ERR(efx, "WARNING: Performance may be reduced.\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "WARNING: Insufficient MSI-X vectors"
+				  " available (%d < %d).\n", rc, n_channels);
+			netif_err(efx, drv, efx->net_dev,
+				  "WARNING: Performance may be reduced.\n");
 			EFX_BUG_ON_PARANOID(rc >= n_channels);
 			n_channels = rc;
 			rc = pci_enable_msix(efx->pci_dev, xentries,
@@ -1023,7 +1053,8 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		} else {
 			/* Fall back to single channel MSI */
 			efx->interrupt_mode = EFX_INT_MODE_MSI;
-			EFX_ERR(efx, "could not enable MSI-X\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "could not enable MSI-X\n");
 		}
 	}
 
@@ -1036,7 +1067,8 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		if (rc == 0) {
 			efx->channel[0].irq = efx->pci_dev->irq;
 		} else {
-			EFX_ERR(efx, "could not enable MSI\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "could not enable MSI\n");
 			efx->interrupt_mode = EFX_INT_MODE_LEGACY;
 		}
 	}
@@ -1090,7 +1122,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 {
 	int rc;
 
-	EFX_LOG(efx, "creating NIC\n");
+	netif_dbg(efx, probe, efx->net_dev, "creating NIC\n");
 
 	/* Carry out hardware-type specific initialisation */
 	rc = efx->type->probe(efx);
@@ -1112,7 +1144,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 
 static void efx_remove_nic(struct efx_nic *efx)
 {
-	EFX_LOG(efx, "destroying NIC\n");
+	netif_dbg(efx, drv, efx->net_dev, "destroying NIC\n");
 
 	efx_remove_interrupts(efx);
 	efx->type->remove(efx);
@@ -1132,14 +1164,14 @@ static int efx_probe_all(struct efx_nic *efx)
 	/* Create NIC */
 	rc = efx_probe_nic(efx);
 	if (rc) {
-		EFX_ERR(efx, "failed to create NIC\n");
+		netif_err(efx, probe, efx->net_dev, "failed to create NIC\n");
 		goto fail1;
 	}
 
 	/* Create port */
 	rc = efx_probe_port(efx);
 	if (rc) {
-		EFX_ERR(efx, "failed to create port\n");
+		netif_err(efx, probe, efx->net_dev, "failed to create port\n");
 		goto fail2;
 	}
 
@@ -1147,8 +1179,9 @@ static int efx_probe_all(struct efx_nic *efx)
 	efx_for_each_channel(channel, efx) {
 		rc = efx_probe_channel(channel);
 		if (rc) {
-			EFX_ERR(efx, "failed to create channel %d\n",
-				channel->channel);
+			netif_err(efx, probe, efx->net_dev,
+				  "failed to create channel %d\n",
+				  channel->channel);
 			goto fail3;
 		}
 	}
@@ -1344,8 +1377,9 @@ static void efx_monitor(struct work_struct *data)
 	struct efx_nic *efx = container_of(data, struct efx_nic,
 					   monitor_work.work);
 
-	EFX_TRACE(efx, "hardware monitor executing on CPU %d\n",
-		  raw_smp_processor_id());
+	netif_vdbg(efx, timer, efx->net_dev,
+		   "hardware monitor executing on CPU %d\n",
+		   raw_smp_processor_id());
 	BUG_ON(efx->type->monitor == NULL);
 
 	/* If the mac_lock is already held then it is likely a port
@@ -1452,8 +1486,8 @@ static int efx_net_open(struct net_device *net_dev)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
-	EFX_LOG(efx, "opening device %s on CPU %d\n", net_dev->name,
-		raw_smp_processor_id());
+	netif_dbg(efx, ifup, efx->net_dev, "opening device on CPU %d\n",
+		  raw_smp_processor_id());
 
 	if (efx->state == STATE_DISABLED)
 		return -EIO;
@@ -1478,8 +1512,8 @@ static int efx_net_stop(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	EFX_LOG(efx, "closing %s on CPU %d\n", net_dev->name,
-		raw_smp_processor_id());
+	netif_dbg(efx, ifdown, efx->net_dev, "closing on CPU %d\n",
+		  raw_smp_processor_id());
 
 	if (efx->state != STATE_DISABLED) {
 		/* Stop the device and flush all the channels */
@@ -1532,8 +1566,9 @@ static void efx_watchdog(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	EFX_ERR(efx, "TX stuck with port_enabled=%d: resetting channels\n",
-		efx->port_enabled);
+	netif_err(efx, tx_err, efx->net_dev,
+		  "TX stuck with port_enabled=%d: resetting channels\n",
+		  efx->port_enabled);
 
 	efx_schedule_reset(efx, RESET_TYPE_TX_WATCHDOG);
 }
@@ -1552,7 +1587,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 
 	efx_stop_all(efx);
 
-	EFX_LOG(efx, "changing MTU to %d\n", new_mtu);
+	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
 	efx_fini_channels(efx);
 
@@ -1578,8 +1613,9 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	if (!is_valid_ether_addr(new_addr)) {
-		EFX_ERR(efx, "invalid ethernet MAC address requested: %pM\n",
-			new_addr);
+		netif_err(efx, drv, efx->net_dev,
+			  "invalid ethernet MAC address requested: %pM\n",
+			  new_addr);
 		return -EINVAL;
 	}
 
@@ -1682,7 +1718,6 @@ static int efx_register_netdev(struct efx_nic *efx)
 	net_dev->watchdog_timeo = 5 * HZ;
 	net_dev->irq = efx->pci_dev->irq;
 	net_dev->netdev_ops = &efx_netdev_ops;
-	SET_NETDEV_DEV(net_dev, &efx->pci_dev->dev);
 	SET_ETHTOOL_OPS(net_dev, &efx_ethtool_ops);
 
 	/* Clear MAC statistics */
@@ -1707,7 +1742,8 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_type);
 	if (rc) {
-		EFX_ERR(efx, "failed to init net dev attributes\n");
+		netif_err(efx, drv, efx->net_dev,
+			  "failed to init net dev attributes\n");
 		goto fail_registered;
 	}
 
@@ -1715,7 +1751,7 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 fail_locked:
 	rtnl_unlock();
-	EFX_ERR(efx, "could not register net dev\n");
+	netif_err(efx, drv, efx->net_dev, "could not register net dev\n");
 	return rc;
 
 fail_registered:
@@ -1780,7 +1816,7 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 
 	rc = efx->type->init(efx);
 	if (rc) {
-		EFX_ERR(efx, "failed to initialise NIC\n");
+		netif_err(efx, drv, efx->net_dev, "failed to initialise NIC\n");
 		goto fail;
 	}
 
@@ -1792,7 +1828,8 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 		if (rc)
 			goto fail;
 		if (efx->phy_op->reconfigure(efx))
-			EFX_ERR(efx, "could not restore PHY settings\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "could not restore PHY settings\n");
 	}
 
 	efx->mac_op->reconfigure(efx);
@@ -1825,13 +1862,14 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 	int rc, rc2;
 	bool disabled;
 
-	EFX_INFO(efx, "resetting (%s)\n", RESET_TYPE(method));
+	netif_info(efx, drv, efx->net_dev, "resetting (%s)\n",
+		   RESET_TYPE(method));
 
 	efx_reset_down(efx, method);
 
 	rc = efx->type->reset(efx, method);
 	if (rc) {
-		EFX_ERR(efx, "failed to reset hardware\n");
+		netif_err(efx, drv, efx->net_dev, "failed to reset hardware\n");
 		goto out;
 	}
 
@@ -1856,10 +1894,10 @@ out:
 
 	if (disabled) {
 		dev_close(efx->net_dev);
-		EFX_ERR(efx, "has been disabled\n");
+		netif_err(efx, drv, efx->net_dev, "has been disabled\n");
 		efx->state = STATE_DISABLED;
 	} else {
-		EFX_LOG(efx, "reset complete\n");
+		netif_dbg(efx, drv, efx->net_dev, "reset complete\n");
 	}
 	return rc;
 }
@@ -1877,7 +1915,8 @@ static void efx_reset_work(struct work_struct *data)
 	/* If we're not RUNNING then don't reset. Leave the reset_pending
 	 * flag set so that efx_pci_probe_main will be retried */
 	if (efx->state != STATE_RUNNING) {
-		EFX_INFO(efx, "scheduled reset quenched. NIC not RUNNING\n");
+		netif_info(efx, drv, efx->net_dev,
+			   "scheduled reset quenched. NIC not RUNNING\n");
 		return;
 	}
 
@@ -1891,7 +1930,8 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	enum reset_type method;
 
 	if (efx->reset_pending != RESET_TYPE_NONE) {
-		EFX_INFO(efx, "quenching already scheduled reset\n");
+		netif_info(efx, drv, efx->net_dev,
+			   "quenching already scheduled reset\n");
 		return;
 	}
 
@@ -1915,10 +1955,12 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 	}
 
 	if (method != type)
-		EFX_LOG(efx, "scheduling %s reset for %s\n",
-			RESET_TYPE(method), RESET_TYPE(type));
+		netif_dbg(efx, drv, efx->net_dev,
+			  "scheduling %s reset for %s\n",
+			  RESET_TYPE(method), RESET_TYPE(type));
 	else
-		EFX_LOG(efx, "scheduling %s reset\n", RESET_TYPE(method));
+		netif_dbg(efx, drv, efx->net_dev, "scheduling %s reset\n",
+			  RESET_TYPE(method));
 
 	efx->reset_pending = method;
 
@@ -2005,6 +2047,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	INIT_WORK(&efx->reset_work, efx_reset_work);
 	INIT_DELAYED_WORK(&efx->monitor_work, efx_monitor);
 	efx->pci_dev = pci_dev;
+	efx->msg_enable = debug;
 	efx->state = STATE_INIT;
 	efx->reset_pending = RESET_TYPE_NONE;
 	strlcpy(efx->name, pci_name(pci_dev), sizeof(efx->name));
@@ -2124,7 +2167,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	efx_pci_remove_main(efx);
 
 	efx_fini_io(efx);
-	EFX_LOG(efx, "shutdown successful\n");
+	netif_dbg(efx, drv, efx->net_dev, "shutdown successful\n");
 
 	pci_set_drvdata(pci_dev, NULL);
 	efx_fini_struct(efx);
@@ -2149,13 +2192,15 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 
 	rc = efx->type->init(efx);
 	if (rc) {
-		EFX_ERR(efx, "failed to initialise NIC\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to initialise NIC\n");
 		goto fail3;
 	}
 
 	rc = efx_init_port(efx);
 	if (rc) {
-		EFX_ERR(efx, "failed to initialise port\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to initialise port\n");
 		goto fail4;
 	}
 
@@ -2211,11 +2256,13 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 				   NETIF_F_HIGHDMA | NETIF_F_TSO);
 	efx = netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
+	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 	rc = efx_init_struct(efx, type, pci_dev, net_dev);
 	if (rc)
 		goto fail1;
 
-	EFX_INFO(efx, "Solarflare Communications NIC detected\n");
+	netif_info(efx, probe, efx->net_dev,
+		   "Solarflare Communications NIC detected\n");
 
 	/* Set up basic I/O (BAR mappings etc) */
 	rc = efx_init_io(efx);
@@ -2253,7 +2300,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	}
 
 	if (rc) {
-		EFX_ERR(efx, "Could not reset NIC\n");
+		netif_err(efx, probe, efx->net_dev, "Could not reset NIC\n");
 		goto fail4;
 	}
 
@@ -2265,7 +2312,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	if (rc)
 		goto fail5;
 
-	EFX_LOG(efx, "initialisation successful\n");
+	netif_dbg(efx, probe, efx->net_dev, "initialisation successful\n");
 
 	rtnl_lock();
 	efx_mtd_probe(efx); /* allowed to fail */
@@ -2281,7 +2328,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	efx_fini_struct(efx);
  fail1:
 	WARN_ON(rc > 0);
-	EFX_LOG(efx, "initialisation failed. rc=%d\n", rc);
+	netif_dbg(efx, drv, efx->net_dev, "initialisation failed. rc=%d\n", rc);
 	free_netdev(net_dev);
 	return rc;
 }
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index e1e4488..060dc95 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -106,8 +106,9 @@ extern unsigned int efx_monitor_interval;
 
 static inline void efx_schedule_channel(struct efx_channel *channel)
 {
-	EFX_TRACE(channel->efx, "channel %d scheduling NAPI poll on CPU%d\n",
-		  channel->channel, raw_smp_processor_id());
+	netif_vdbg(channel->efx, intr, channel->efx->net_dev,
+		   "channel %d scheduling NAPI poll on CPU%d\n",
+		   channel->channel, raw_smp_processor_id());
 	channel->work_pending = true;
 
 	napi_schedule(&channel->napi_str);
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 81b7f39..27230a9 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -218,8 +218,8 @@ int efx_ethtool_set_settings(struct net_device *net_dev,
 
 	/* GMAC does not support 1000Mbps HD */
 	if (ecmd->speed == SPEED_1000 && ecmd->duplex != DUPLEX_FULL) {
-		EFX_LOG(efx, "rejecting unsupported 1000Mbps HD"
-			" setting\n");
+		netif_dbg(efx, drv, efx->net_dev,
+			  "rejecting unsupported 1000Mbps HD setting\n");
 		return -EINVAL;
 	}
 
@@ -256,6 +256,18 @@ static void efx_ethtool_get_regs(struct net_device *net_dev,
 	efx_nic_get_regs(efx, buf);
 }
 
+static u32 efx_ethtool_get_msglevel(struct net_device *net_dev)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	return efx->msg_enable;
+}
+
+static void efx_ethtool_set_msglevel(struct net_device *net_dev, u32 msg_enable)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	efx->msg_enable = msg_enable;
+}
+
 /**
  * efx_fill_test - fill in an individual self-test entry
  * @test_index:		Index of the test
@@ -553,7 +565,8 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 	if (!already_up) {
 		rc = dev_open(efx->net_dev);
 		if (rc) {
-			EFX_ERR(efx, "failed opening device.\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "failed opening device.\n");
 			goto fail2;
 		}
 	}
@@ -565,9 +578,9 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 	if (!already_up)
 		dev_close(efx->net_dev);
 
-	EFX_LOG(efx, "%s %sline self-tests\n",
-		rc == 0 ? "passed" : "failed",
-		(test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
+	netif_dbg(efx, drv, efx->net_dev, "%s %sline self-tests\n",
+		  rc == 0 ? "passed" : "failed",
+		  (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
 
  fail2:
  fail1:
@@ -693,8 +706,8 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 		return -EOPNOTSUPP;
 
 	if (coalesce->rx_coalesce_usecs || coalesce->tx_coalesce_usecs) {
-		EFX_ERR(efx, "invalid coalescing setting. "
-			"Only rx/tx_coalesce_usecs_irq are supported\n");
+		netif_err(efx, drv, efx->net_dev, "invalid coalescing setting. "
+			  "Only rx/tx_coalesce_usecs_irq are supported\n");
 		return -EOPNOTSUPP;
 	}
 
@@ -706,8 +719,8 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	efx_for_each_tx_queue(tx_queue, efx) {
 		if ((tx_queue->channel->channel < efx->n_rx_channels) &&
 		    tx_usecs) {
-			EFX_ERR(efx, "Channel is shared. "
-				"Only RX coalescing may be set\n");
+			netif_err(efx, drv, efx->net_dev, "Channel is shared. "
+				  "Only RX coalescing may be set\n");
 			return -EOPNOTSUPP;
 		}
 	}
@@ -735,13 +748,15 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 		     (pause->autoneg ? EFX_FC_AUTO : 0));
 
 	if ((wanted_fc & EFX_FC_TX) && !(wanted_fc & EFX_FC_RX)) {
-		EFX_LOG(efx, "Flow control unsupported: tx ON rx OFF\n");
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Flow control unsupported: tx ON rx OFF\n");
 		rc = -EINVAL;
 		goto out;
 	}
 
 	if ((wanted_fc & EFX_FC_AUTO) && !efx->link_advertising) {
-		EFX_LOG(efx, "Autonegotiation is disabled\n");
+		netif_dbg(efx, drv, efx->net_dev,
+			  "Autonegotiation is disabled\n");
 		rc = -EINVAL;
 		goto out;
 	}
@@ -772,8 +787,9 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	    (efx->wanted_fc ^ old_fc) & EFX_FC_AUTO) {
 		rc = efx->phy_op->reconfigure(efx);
 		if (rc) {
-			EFX_ERR(efx, "Unable to advertise requested flow "
-				"control setting\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "Unable to advertise requested flow "
+				  "control setting\n");
 			goto out;
 		}
 	}
@@ -850,6 +866,8 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_drvinfo		= efx_ethtool_get_drvinfo,
 	.get_regs_len		= efx_ethtool_get_regs_len,
 	.get_regs		= efx_ethtool_get_regs,
+	.get_msglevel		= efx_ethtool_get_msglevel,
+	.set_msglevel		= efx_ethtool_set_msglevel,
 	.nway_reset		= efx_ethtool_nway_reset,
 	.get_link		= efx_ethtool_get_link,
 	.get_eeprom_len		= efx_ethtool_get_eeprom_len,
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 8558865..92d38ed 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -167,13 +167,15 @@ irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 	 * exit without having touched the hardware.
 	 */
 	if (unlikely(EFX_OWORD_IS_ZERO(*int_ker))) {
-		EFX_TRACE(efx, "IRQ %d on CPU %d not for me\n", irq,
-			  raw_smp_processor_id());
+		netif_vdbg(efx, intr, efx->net_dev,
+			   "IRQ %d on CPU %d not for me\n", irq,
+			   raw_smp_processor_id());
 		return IRQ_NONE;
 	}
 	efx->last_irq_cpu = raw_smp_processor_id();
-	EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_OWORD_FMT "\n",
-		  irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
+	netif_vdbg(efx, intr, efx->net_dev,
+		   "IRQ %d on CPU %d status " EFX_OWORD_FMT "\n",
+		   irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
 
 	/* Determine interrupting queues, clear interrupt status
 	 * register and acknowledge the device interrupt.
@@ -239,7 +241,8 @@ static int falcon_spi_wait(struct efx_nic *efx)
 		if (!falcon_spi_poll(efx))
 			return 0;
 		if (time_after_eq(jiffies, timeout)) {
-			EFX_ERR(efx, "timed out waiting for SPI\n");
+			netif_err(efx, hw, efx->net_dev,
+				  "timed out waiting for SPI\n");
 			return -ETIMEDOUT;
 		}
 		schedule_timeout_uninterruptible(1);
@@ -333,9 +336,10 @@ falcon_spi_wait_write(struct efx_nic *efx, const struct efx_spi_device *spi)
 		if (!(status & SPI_STATUS_NRDY))
 			return 0;
 		if (time_after_eq(jiffies, timeout)) {
-			EFX_ERR(efx, "SPI write timeout on device %d"
-				" last status=0x%02x\n",
-				spi->device_id, status);
+			netif_err(efx, hw, efx->net_dev,
+				  "SPI write timeout on device %d"
+				  " last status=0x%02x\n",
+				  spi->device_id, status);
 			return -ETIMEDOUT;
 		}
 		schedule_timeout_uninterruptible(1);
@@ -469,7 +473,8 @@ static void falcon_reset_macs(struct efx_nic *efx)
 				udelay(10);
 			}
 
-			EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
+			netif_err(efx, hw, efx->net_dev,
+				  "timed out waiting for XMAC core reset\n");
 		}
 	}
 
@@ -492,12 +497,13 @@ static void falcon_reset_macs(struct efx_nic *efx)
 		if (!EFX_OWORD_FIELD(reg, FRF_AB_RST_XGTX) &&
 		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_XGRX) &&
 		    !EFX_OWORD_FIELD(reg, FRF_AB_RST_EM)) {
-			EFX_LOG(efx, "Completed MAC reset after %d loops\n",
-				count);
+			netif_dbg(efx, hw, efx->net_dev,
+				  "Completed MAC reset after %d loops\n",
+				  count);
 			break;
 		}
 		if (count > 20) {
-			EFX_ERR(efx, "MAC reset failed\n");
+			netif_err(efx, hw, efx->net_dev, "MAC reset failed\n");
 			break;
 		}
 		count++;
@@ -627,7 +633,8 @@ static void falcon_stats_complete(struct efx_nic *efx)
 		rmb(); /* read the done flag before the stats */
 		efx->mac_op->update_stats(efx);
 	} else {
-		EFX_ERR(efx, "timed out waiting for statistics\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "timed out waiting for statistics\n");
 	}
 }
 
@@ -717,16 +724,17 @@ static int falcon_gmii_wait(struct efx_nic *efx)
 		if (EFX_OWORD_FIELD(md_stat, FRF_AB_MD_BSY) == 0) {
 			if (EFX_OWORD_FIELD(md_stat, FRF_AB_MD_LNFL) != 0 ||
 			    EFX_OWORD_FIELD(md_stat, FRF_AB_MD_BSERR) != 0) {
-				EFX_ERR(efx, "error from GMII access "
-					EFX_OWORD_FMT"\n",
-					EFX_OWORD_VAL(md_stat));
+				netif_err(efx, hw, efx->net_dev,
+					  "error from GMII access "
+					  EFX_OWORD_FMT"\n",
+					  EFX_OWORD_VAL(md_stat));
 				return -EIO;
 			}
 			return 0;
 		}
 		udelay(10);
 	}
-	EFX_ERR(efx, "timed out waiting for GMII\n");
+	netif_err(efx, hw, efx->net_dev, "timed out waiting for GMII\n");
 	return -ETIMEDOUT;
 }
 
@@ -738,7 +746,8 @@ static int falcon_mdio_write(struct net_device *net_dev,
 	efx_oword_t reg;
 	int rc;
 
-	EFX_REGDUMP(efx, "writing MDIO %d register %d.%d with 0x%04x\n",
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing MDIO %d register %d.%d with 0x%04x\n",
 		    prtad, devad, addr, value);
 
 	mutex_lock(&efx->mdio_lock);
@@ -812,8 +821,9 @@ static int falcon_mdio_read(struct net_device *net_dev,
 	if (rc == 0) {
 		efx_reado(efx, &reg, FR_AB_MD_RXD);
 		rc = EFX_OWORD_FIELD(reg, FRF_AB_MD_RXD);
-		EFX_REGDUMP(efx, "read from MDIO %d register %d.%d, got %04x\n",
-			    prtad, devad, addr, rc);
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "read from MDIO %d register %d.%d, got %04x\n",
+			   prtad, devad, addr, rc);
 	} else {
 		/* Abort the read operation */
 		EFX_POPULATE_OWORD_2(reg,
@@ -821,8 +831,9 @@ static int falcon_mdio_read(struct net_device *net_dev,
 				     FRF_AB_MD_GC, 1);
 		efx_writeo(efx, &reg, FR_AB_MD_CS);
 
-		EFX_LOG(efx, "read from MDIO %d register %d.%d, got error %d\n",
-			prtad, devad, addr, rc);
+		netif_dbg(efx, hw, efx->net_dev,
+			  "read from MDIO %d register %d.%d, got error %d\n",
+			  prtad, devad, addr, rc);
 	}
 
 out:
@@ -873,7 +884,8 @@ static void falcon_switch_mac(struct efx_nic *efx)
 
 	falcon_clock_mac(efx);
 
-	EFX_LOG(efx, "selected %cMAC\n", EFX_IS10G(efx) ? 'X' : 'G');
+	netif_dbg(efx, hw, efx->net_dev, "selected %cMAC\n",
+		  EFX_IS10G(efx) ? 'X' : 'G');
 	/* Not all macs support a mac-level link state */
 	efx->xmac_poll_required = false;
 	falcon_reset_macs(efx);
@@ -897,8 +909,8 @@ static int falcon_probe_port(struct efx_nic *efx)
 		efx->phy_op = &falcon_qt202x_phy_ops;
 		break;
 	default:
-		EFX_ERR(efx, "Unknown PHY type %d\n",
-			efx->phy_type);
+		netif_err(efx, probe, efx->net_dev, "Unknown PHY type %d\n",
+			  efx->phy_type);
 		return -ENODEV;
 	}
 
@@ -926,10 +938,11 @@ static int falcon_probe_port(struct efx_nic *efx)
 				  FALCON_MAC_STATS_SIZE);
 	if (rc)
 		return rc;
-	EFX_LOG(efx, "stats buffer at %llx (virt %p phys %llx)\n",
-		(u64)efx->stats_buffer.dma_addr,
-		efx->stats_buffer.addr,
-		(u64)virt_to_phys(efx->stats_buffer.addr));
+	netif_dbg(efx, probe, efx->net_dev,
+		  "stats buffer at %llx (virt %p phys %llx)\n",
+		  (u64)efx->stats_buffer.dma_addr,
+		  efx->stats_buffer.addr,
+		  (u64)virt_to_phys(efx->stats_buffer.addr));
 
 	return 0;
 }
@@ -969,8 +982,8 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	rc = falcon_spi_read(efx, spi, 0, FALCON_NVCONFIG_END, NULL, region);
 	mutex_unlock(&efx->spi_lock);
 	if (rc) {
-		EFX_ERR(efx, "Failed to read %s\n",
-			efx->spi_flash ? "flash" : "EEPROM");
+		netif_err(efx, hw, efx->net_dev, "Failed to read %s\n",
+			  efx->spi_flash ? "flash" : "EEPROM");
 		rc = -EIO;
 		goto out;
 	}
@@ -980,11 +993,13 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 
 	rc = -EINVAL;
 	if (magic_num != FALCON_NVCONFIG_BOARD_MAGIC_NUM) {
-		EFX_ERR(efx, "NVRAM bad magic 0x%x\n", magic_num);
+		netif_err(efx, hw, efx->net_dev,
+			  "NVRAM bad magic 0x%x\n", magic_num);
 		goto out;
 	}
 	if (struct_ver < 2) {
-		EFX_ERR(efx, "NVRAM has ancient version 0x%x\n", struct_ver);
+		netif_err(efx, hw, efx->net_dev,
+			  "NVRAM has ancient version 0x%x\n", struct_ver);
 		goto out;
 	} else if (struct_ver < 4) {
 		word = &nvconfig->board_magic_num;
@@ -997,7 +1012,8 @@ falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 		csum += le16_to_cpu(*word);
 
 	if (~csum & 0xffff) {
-		EFX_ERR(efx, "NVRAM has incorrect checksum\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "NVRAM has incorrect checksum\n");
 		goto out;
 	}
 
@@ -1075,22 +1091,25 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 	efx_oword_t glb_ctl_reg_ker;
 	int rc;
 
-	EFX_LOG(efx, "performing %s hardware reset\n", RESET_TYPE(method));
+	netif_dbg(efx, hw, efx->net_dev, "performing %s hardware reset\n",
+		  RESET_TYPE(method));
 
 	/* Initiate device reset */
 	if (method == RESET_TYPE_WORLD) {
 		rc = pci_save_state(efx->pci_dev);
 		if (rc) {
-			EFX_ERR(efx, "failed to backup PCI state of primary "
-				"function prior to hardware reset\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "failed to backup PCI state of primary "
+				  "function prior to hardware reset\n");
 			goto fail1;
 		}
 		if (efx_nic_is_dual_func(efx)) {
 			rc = pci_save_state(nic_data->pci_dev2);
 			if (rc) {
-				EFX_ERR(efx, "failed to backup PCI state of "
-					"secondary function prior to "
-					"hardware reset\n");
+				netif_err(efx, drv, efx->net_dev,
+					  "failed to backup PCI state of "
+					  "secondary function prior to "
+					  "hardware reset\n");
 				goto fail2;
 			}
 		}
@@ -1115,7 +1134,7 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 	}
 	efx_writeo(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
 
-	EFX_LOG(efx, "waiting for hardware reset\n");
+	netif_dbg(efx, hw, efx->net_dev, "waiting for hardware reset\n");
 	schedule_timeout_uninterruptible(HZ / 20);
 
 	/* Restore PCI configuration if needed */
@@ -1123,28 +1142,32 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 		if (efx_nic_is_dual_func(efx)) {
 			rc = pci_restore_state(nic_data->pci_dev2);
 			if (rc) {
-				EFX_ERR(efx, "failed to restore PCI config for "
-					"the secondary function\n");
+				netif_err(efx, drv, efx->net_dev,
+					  "failed to restore PCI config for "
+					  "the secondary function\n");
 				goto fail3;
 			}
 		}
 		rc = pci_restore_state(efx->pci_dev);
 		if (rc) {
-			EFX_ERR(efx, "failed to restore PCI config for the "
-				"primary function\n");
+			netif_err(efx, drv, efx->net_dev,
+				  "failed to restore PCI config for the "
+				  "primary function\n");
 			goto fail4;
 		}
-		EFX_LOG(efx, "successfully restored PCI config\n");
+		netif_dbg(efx, drv, efx->net_dev,
+			  "successfully restored PCI config\n");
 	}
 
 	/* Assert that reset complete */
 	efx_reado(efx, &glb_ctl_reg_ker, FR_AB_GLB_CTL);
 	if (EFX_OWORD_FIELD(glb_ctl_reg_ker, FRF_AB_SWRST) != 0) {
 		rc = -ETIMEDOUT;
-		EFX_ERR(efx, "timed out waiting for hardware reset\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "timed out waiting for hardware reset\n");
 		goto fail5;
 	}
-	EFX_LOG(efx, "hardware reset complete\n");
+	netif_dbg(efx, hw, efx->net_dev, "hardware reset complete\n");
 
 	return 0;
 
@@ -1167,8 +1190,9 @@ static void falcon_monitor(struct efx_nic *efx)
 
 	rc = falcon_board(efx)->type->monitor(efx);
 	if (rc) {
-		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
-			(rc == -ERANGE) ? "reported fault" : "failed");
+		netif_err(efx, hw, efx->net_dev,
+			  "Board sensor %s; shutting down PHY\n",
+			  (rc == -ERANGE) ? "reported fault" : "failed");
 		efx->phy_mode |= PHY_MODE_LOW_POWER;
 		rc = __efx_reconfigure_port(efx);
 		WARN_ON(rc);
@@ -1219,7 +1243,8 @@ static int falcon_reset_sram(struct efx_nic *efx)
 	/* Wait for SRAM reset to complete */
 	count = 0;
 	do {
-		EFX_LOG(efx, "waiting for SRAM reset (attempt %d)...\n", count);
+		netif_dbg(efx, hw, efx->net_dev,
+			  "waiting for SRAM reset (attempt %d)...\n", count);
 
 		/* SRAM reset is slow; expect around 16ms */
 		schedule_timeout_uninterruptible(HZ / 50);
@@ -1227,13 +1252,14 @@ static int falcon_reset_sram(struct efx_nic *efx)
 		/* Check for reset complete */
 		efx_reado(efx, &srm_cfg_reg_ker, FR_AZ_SRM_CFG);
 		if (!EFX_OWORD_FIELD(srm_cfg_reg_ker, FRF_AZ_SRM_INIT_EN)) {
-			EFX_LOG(efx, "SRAM reset complete\n");
+			netif_dbg(efx, hw, efx->net_dev,
+				  "SRAM reset complete\n");
 
 			return 0;
 		}
 	} while (++count < 20);	/* wait upto 0.4 sec */
 
-	EFX_ERR(efx, "timed out waiting for SRAM reset\n");
+	netif_err(efx, hw, efx->net_dev, "timed out waiting for SRAM reset\n");
 	return -ETIMEDOUT;
 }
 
@@ -1292,7 +1318,8 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 
 	rc = falcon_read_nvram(efx, nvconfig);
 	if (rc == -EINVAL) {
-		EFX_ERR(efx, "NVRAM is invalid therefore using defaults\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "NVRAM is invalid therefore using defaults\n");
 		efx->phy_type = PHY_TYPE_NONE;
 		efx->mdio.prtad = MDIO_PRTAD_NONE;
 		board_rev = 0;
@@ -1326,7 +1353,8 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	/* Read the MAC addresses */
 	memcpy(efx->mac_address, nvconfig->mac_address[0], ETH_ALEN);
 
-	EFX_LOG(efx, "PHY is %d phy_id %d\n", efx->phy_type, efx->mdio.prtad);
+	netif_dbg(efx, probe, efx->net_dev, "PHY is %d phy_id %d\n",
+		  efx->phy_type, efx->mdio.prtad);
 
 	rc = falcon_probe_board(efx, board_rev);
 	if (rc)
@@ -1355,14 +1383,16 @@ static void falcon_probe_spi_devices(struct efx_nic *efx)
 	if (EFX_OWORD_FIELD(gpio_ctl, FRF_AB_GPIO3_PWRUP_VALUE)) {
 		boot_dev = (EFX_OWORD_FIELD(nic_stat, FRF_AB_SF_PRST) ?
 			    FFE_AB_SPI_DEVICE_FLASH : FFE_AB_SPI_DEVICE_EEPROM);
-		EFX_LOG(efx, "Booted from %s\n",
-			boot_dev == FFE_AB_SPI_DEVICE_FLASH ? "flash" : "EEPROM");
+		netif_dbg(efx, probe, efx->net_dev, "Booted from %s\n",
+			  boot_dev == FFE_AB_SPI_DEVICE_FLASH ?
+			  "flash" : "EEPROM");
 	} else {
 		/* Disable VPD and set clock dividers to safe
 		 * values for initial programming. */
 		boot_dev = -1;
-		EFX_LOG(efx, "Booted from internal ASIC settings;"
-			" setting SPI config\n");
+		netif_dbg(efx, probe, efx->net_dev,
+			  "Booted from internal ASIC settings;"
+			  " setting SPI config\n");
 		EFX_POPULATE_OWORD_3(ee_vpd_cfg, FRF_AB_EE_VPD_EN, 0,
 				     /* 125 MHz / 7 ~= 20 MHz */
 				     FRF_AB_EE_SF_CLOCK_DIV, 7,
@@ -1396,7 +1426,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	rc = -ENODEV;
 
 	if (efx_nic_fpga_ver(efx) != 0) {
-		EFX_ERR(efx, "Falcon FPGA not supported\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "Falcon FPGA not supported\n");
 		goto fail1;
 	}
 
@@ -1406,16 +1437,19 @@ static int falcon_probe_nic(struct efx_nic *efx)
 		u8 pci_rev = efx->pci_dev->revision;
 
 		if ((pci_rev == 0xff) || (pci_rev == 0)) {
-			EFX_ERR(efx, "Falcon rev A0 not supported\n");
+			netif_err(efx, probe, efx->net_dev,
+				  "Falcon rev A0 not supported\n");
 			goto fail1;
 		}
 		efx_reado(efx, &nic_stat, FR_AB_NIC_STAT);
 		if (EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) == 0) {
-			EFX_ERR(efx, "Falcon rev A1 1G not supported\n");
+			netif_err(efx, probe, efx->net_dev,
+				  "Falcon rev A1 1G not supported\n");
 			goto fail1;
 		}
 		if (EFX_OWORD_FIELD(nic_stat, FRF_AA_STRAP_PCIE) == 0) {
-			EFX_ERR(efx, "Falcon rev A1 PCI-X not supported\n");
+			netif_err(efx, probe, efx->net_dev,
+				  "Falcon rev A1 PCI-X not supported\n");
 			goto fail1;
 		}
 
@@ -1429,7 +1463,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 			}
 		}
 		if (!nic_data->pci_dev2) {
-			EFX_ERR(efx, "failed to find secondary function\n");
+			netif_err(efx, probe, efx->net_dev,
+				  "failed to find secondary function\n");
 			rc = -ENODEV;
 			goto fail2;
 		}
@@ -1438,7 +1473,7 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	/* Now we can reset the NIC */
 	rc = falcon_reset_hw(efx, RESET_TYPE_ALL);
 	if (rc) {
-		EFX_ERR(efx, "failed to reset NIC\n");
+		netif_err(efx, probe, efx->net_dev, "failed to reset NIC\n");
 		goto fail3;
 	}
 
@@ -1448,9 +1483,11 @@ static int falcon_probe_nic(struct efx_nic *efx)
 		goto fail4;
 	BUG_ON(efx->irq_status.dma_addr & 0x0f);
 
-	EFX_LOG(efx, "INT_KER at %llx (virt %p phys %llx)\n",
-		(u64)efx->irq_status.dma_addr,
-		efx->irq_status.addr, (u64)virt_to_phys(efx->irq_status.addr));
+	netif_dbg(efx, probe, efx->net_dev,
+		  "INT_KER at %llx (virt %p phys %llx)\n",
+		  (u64)efx->irq_status.dma_addr,
+		  efx->irq_status.addr,
+		  (u64)virt_to_phys(efx->irq_status.addr));
 
 	falcon_probe_spi_devices(efx);
 
@@ -1474,7 +1511,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 
 	rc = falcon_board(efx)->type->init(efx);
 	if (rc) {
-		EFX_ERR(efx, "failed to initialise board\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to initialise board\n");
 		goto fail6;
 	}
 
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index c7a933a..92b35e3 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -106,12 +106,12 @@ static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 	alarms1 &= mask;
 	alarms2 &= mask >> 8;
 	if (alarms1 || alarms2) {
-		EFX_ERR(efx,
-			"LM87 detected a hardware failure (status %02x:%02x)"
-			"%s%s\n",
-			alarms1, alarms2,
-			(alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
-			(alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
+		netif_err(efx, hw, efx->net_dev,
+			  "LM87 detected a hardware failure (status %02x:%02x)"
+			  "%s%s\n",
+			  alarms1, alarms2,
+			  (alarms1 & LM87_ALARM_TEMP_INT) ? " INTERNAL" : "",
+			  (alarms1 & LM87_ALARM_TEMP_EXT1) ? " EXTERNAL" : "");
 		return -ERANGE;
 	}
 
@@ -243,7 +243,7 @@ static int sfe4001_poweron(struct efx_nic *efx)
 		       (0 << P0_EN_3V3X_LBN) | (0 << P0_EN_5V_LBN) |
 		       (0 << P0_EN_1V0X_LBN));
 	if (rc != out) {
-		EFX_INFO(efx, "power-cycling PHY\n");
+		netif_info(efx, hw, efx->net_dev, "power-cycling PHY\n");
 		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
 		if (rc)
 			goto fail_on;
@@ -269,7 +269,8 @@ static int sfe4001_poweron(struct efx_nic *efx)
 		if (rc)
 			goto fail_on;
 
-		EFX_INFO(efx, "waiting for DSP boot (attempt %d)...\n", i);
+		netif_info(efx, hw, efx->net_dev,
+			   "waiting for DSP boot (attempt %d)...\n", i);
 
 		/* In flash config mode, DSP does not turn on AFE, so
 		 * just wait 1 second.
@@ -291,7 +292,7 @@ static int sfe4001_poweron(struct efx_nic *efx)
 		}
 	}
 
-	EFX_INFO(efx, "timed out waiting for DSP boot\n");
+	netif_info(efx, hw, efx->net_dev, "timed out waiting for DSP boot\n");
 	rc = -ETIMEDOUT;
 fail_on:
 	sfe4001_poweroff(efx);
@@ -377,7 +378,7 @@ static void sfe4001_fini(struct efx_nic *efx)
 {
 	struct falcon_board *board = falcon_board(efx);
 
-	EFX_INFO(efx, "%s\n", __func__);
+	netif_info(efx, drv, efx->net_dev, "%s\n", __func__);
 
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
 	sfe4001_poweroff(efx);
@@ -461,7 +462,7 @@ static int sfe4001_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_on;
 
-	EFX_INFO(efx, "PHY is powered on\n");
+	netif_info(efx, hw, efx->net_dev, "PHY is powered on\n");
 	return 0;
 
 fail_on:
@@ -493,7 +494,7 @@ static int sfn4111t_check_hw(struct efx_nic *efx)
 
 static void sfn4111t_fini(struct efx_nic *efx)
 {
-	EFX_INFO(efx, "%s\n", __func__);
+	netif_info(efx, drv, efx->net_dev, "%s\n", __func__);
 
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
 	i2c_unregister_device(falcon_board(efx)->hwmon_client);
@@ -742,13 +743,14 @@ int falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 			board->type = &board_types[i];
 
 	if (board->type) {
-		EFX_INFO(efx, "board is %s rev %c%d\n",
+		netif_info(efx, probe, efx->net_dev, "board is %s rev %c%d\n",
 			 (efx->pci_dev->subsystem_vendor == EFX_VENDID_SFC)
 			 ? board->type->ref_model : board->type->gen_type,
 			 'A' + board->major, board->minor);
 		return 0;
 	} else {
-		EFX_ERR(efx, "unknown board type %d\n", type_id);
+		netif_err(efx, probe, efx->net_dev, "unknown board type %d\n",
+			  type_id);
 		return -ENODEV;
 	}
 }
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index c84a2ce..bae656d 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -81,7 +81,8 @@ int falcon_reset_xaui(struct efx_nic *efx)
 		}
 		udelay(10);
 	}
-	EFX_ERR(efx, "timed out waiting for XAUI/XGXS reset\n");
+	netif_err(efx, hw, efx->net_dev,
+		  "timed out waiting for XAUI/XGXS reset\n");
 	return -ETIMEDOUT;
 }
 
@@ -256,7 +257,7 @@ static bool falcon_xmac_link_ok_retry(struct efx_nic *efx, int tries)
 	falcon_stop_nic_stats(efx);
 
 	while (!mac_up && tries) {
-		EFX_LOG(efx, "bashing xaui\n");
+		netif_dbg(efx, hw, efx->net_dev, "bashing xaui\n");
 		falcon_reset_xaui(efx);
 		udelay(200);
 
diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index 4317574..85a99fe 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -78,8 +78,9 @@ static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
 {
 	unsigned long flags __attribute__ ((unused));
 
-	EFX_REGDUMP(efx, "writing register %x with " EFX_OWORD_FMT "\n", reg,
-		    EFX_OWORD_VAL(*value));
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing register %x with " EFX_OWORD_FMT "\n", reg,
+		   EFX_OWORD_VAL(*value));
 
 	spin_lock_irqsave(&efx->biu_lock, flags);
 #ifdef EFX_USE_QWORD_IO
@@ -105,8 +106,9 @@ static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 	unsigned int addr = index * sizeof(*value);
 	unsigned long flags __attribute__ ((unused));
 
-	EFX_REGDUMP(efx, "writing SRAM address %x with " EFX_QWORD_FMT "\n",
-		    addr, EFX_QWORD_VAL(*value));
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing SRAM address %x with " EFX_QWORD_FMT "\n",
+		   addr, EFX_QWORD_VAL(*value));
 
 	spin_lock_irqsave(&efx->biu_lock, flags);
 #ifdef EFX_USE_QWORD_IO
@@ -129,8 +131,9 @@ static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 static inline void efx_writed(struct efx_nic *efx, efx_dword_t *value,
 			      unsigned int reg)
 {
-	EFX_REGDUMP(efx, "writing partial register %x with "EFX_DWORD_FMT"\n",
-		    reg, EFX_DWORD_VAL(*value));
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "writing partial register %x with "EFX_DWORD_FMT"\n",
+		   reg, EFX_DWORD_VAL(*value));
 
 	/* No lock required */
 	_efx_writed(efx, value->u32[0], reg);
@@ -155,8 +158,9 @@ static inline void efx_reado(struct efx_nic *efx, efx_oword_t *value,
 	value->u32[3] = _efx_readd(efx, reg + 12);
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 
-	EFX_REGDUMP(efx, "read from register %x, got " EFX_OWORD_FMT "\n", reg,
-		    EFX_OWORD_VAL(*value));
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "read from register %x, got " EFX_OWORD_FMT "\n", reg,
+		   EFX_OWORD_VAL(*value));
 }
 
 /* Read an 8-byte SRAM entry through supplied mapping,
@@ -177,8 +181,9 @@ static inline void efx_sram_readq(struct efx_nic *efx, void __iomem *membase,
 #endif
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
 
-	EFX_REGDUMP(efx, "read from SRAM address %x, got "EFX_QWORD_FMT"\n",
-		    addr, EFX_QWORD_VAL(*value));
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "read from SRAM address %x, got "EFX_QWORD_FMT"\n",
+		   addr, EFX_QWORD_VAL(*value));
 }
 
 /* Read dword from register that allows partial writes (sic) */
@@ -186,8 +191,9 @@ static inline void efx_readd(struct efx_nic *efx, efx_dword_t *value,
 				unsigned int reg)
 {
 	value->u32[0] = _efx_readd(efx, reg);
-	EFX_REGDUMP(efx, "read from register %x, got "EFX_DWORD_FMT"\n",
-		    reg, EFX_DWORD_VAL(*value));
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "read from register %x, got "EFX_DWORD_FMT"\n",
+		   reg, EFX_DWORD_VAL(*value));
 }
 
 /* Write to a register forming part of a table */
diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 93cc3c1..3912b8f 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -168,11 +168,12 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	error = EFX_DWORD_FIELD(reg, MCDI_HEADER_ERROR);
 
 	if (error && mcdi->resplen == 0) {
-		EFX_ERR(efx, "MC rebooted\n");
+		netif_err(efx, hw, efx->net_dev, "MC rebooted\n");
 		rc = EIO;
 	} else if ((respseq ^ mcdi->seqno) & SEQ_MASK) {
-		EFX_ERR(efx, "MC response mismatch tx seq 0x%x rx seq 0x%x\n",
-			respseq, mcdi->seqno);
+		netif_err(efx, hw, efx->net_dev,
+			  "MC response mismatch tx seq 0x%x rx seq 0x%x\n",
+			  respseq, mcdi->seqno);
 		rc = EIO;
 	} else if (error) {
 		efx_readd(efx, &reg, pdu + 4);
@@ -303,8 +304,9 @@ static void efx_mcdi_ev_cpl(struct efx_nic *efx, unsigned int seqno,
 			/* The request has been cancelled */
 			--mcdi->credits;
 		else
-			EFX_ERR(efx, "MC response mismatch tx seq 0x%x rx "
-				"seq 0x%x\n", seqno, mcdi->seqno);
+			netif_err(efx, hw, efx->net_dev,
+				  "MC response mismatch tx seq 0x%x rx "
+				  "seq 0x%x\n", seqno, mcdi->seqno);
 	} else {
 		mcdi->resprc = errno;
 		mcdi->resplen = datalen;
@@ -352,8 +354,9 @@ int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 		++mcdi->credits;
 		spin_unlock_bh(&mcdi->iface_lock);
 
-		EFX_ERR(efx, "MC command 0x%x inlen %d mode %d timed out\n",
-			cmd, (int)inlen, mcdi->mode);
+		netif_err(efx, hw, efx->net_dev,
+			  "MC command 0x%x inlen %d mode %d timed out\n",
+			  cmd, (int)inlen, mcdi->mode);
 	} else {
 		size_t resplen;
 
@@ -374,11 +377,13 @@ int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 		} else if (cmd == MC_CMD_REBOOT && rc == -EIO)
 			; /* Don't reset if MC_CMD_REBOOT returns EIO */
 		else if (rc == -EIO || rc == -EINTR) {
-			EFX_ERR(efx, "MC fatal error %d\n", -rc);
+			netif_err(efx, hw, efx->net_dev, "MC fatal error %d\n",
+				  -rc);
 			efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
 		} else
-			EFX_ERR(efx, "MC command 0x%x inlen %d failed rc=%d\n",
-				cmd, (int)inlen, -rc);
+			netif_err(efx, hw, efx->net_dev,
+				  "MC command 0x%x inlen %d failed rc=%d\n",
+				  cmd, (int)inlen, -rc);
 	}
 
 	efx_mcdi_release(mcdi);
@@ -534,8 +539,9 @@ static void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev)
 	EFX_BUG_ON_PARANOID(state >= ARRAY_SIZE(sensor_status_names));
 	state_txt = sensor_status_names[state];
 
-	EFX_ERR(efx, "Sensor %d (%s) reports condition '%s' for raw value %d\n",
-		monitor, name, state_txt, value);
+	netif_err(efx, hw, efx->net_dev,
+		  "Sensor %d (%s) reports condition '%s' for raw value %d\n",
+		  monitor, name, state_txt, value);
 }
 
 /* Called from  falcon_process_eventq for MCDI events */
@@ -548,12 +554,13 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 
 	switch (code) {
 	case MCDI_EVENT_CODE_BADSSERT:
-		EFX_ERR(efx, "MC watchdog or assertion failure at 0x%x\n", data);
+		netif_err(efx, hw, efx->net_dev,
+			  "MC watchdog or assertion failure at 0x%x\n", data);
 		efx_mcdi_ev_death(efx, EINTR);
 		break;
 
 	case MCDI_EVENT_CODE_PMNOTICE:
-		EFX_INFO(efx, "MCDI PM event.\n");
+		netif_info(efx, wol, efx->net_dev, "MCDI PM event.\n");
 		break;
 
 	case MCDI_EVENT_CODE_CMDDONE:
@@ -570,10 +577,11 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		efx_mcdi_sensor_event(efx, event);
 		break;
 	case MCDI_EVENT_CODE_SCHEDERR:
-		EFX_INFO(efx, "MC Scheduler error address=0x%x\n", data);
+		netif_info(efx, hw, efx->net_dev,
+			   "MC Scheduler error address=0x%x\n", data);
 		break;
 	case MCDI_EVENT_CODE_REBOOT:
-		EFX_INFO(efx, "MC Reboot\n");
+		netif_info(efx, hw, efx->net_dev, "MC Reboot\n");
 		efx_mcdi_ev_death(efx, EIO);
 		break;
 	case MCDI_EVENT_CODE_MAC_STATS_DMA:
@@ -581,7 +589,8 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		break;
 
 	default:
-		EFX_ERR(efx, "Unknown MCDI event 0x%x\n", code);
+		netif_err(efx, hw, efx->net_dev, "Unknown MCDI event 0x%x\n",
+			  code);
 	}
 }
 
@@ -627,7 +636,7 @@ int efx_mcdi_fwver(struct efx_nic *efx, u64 *version, u32 *build)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, probe, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -657,7 +666,7 @@ int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, probe, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -695,7 +704,8 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d len=%d\n", __func__, rc, (int)outlen);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d len=%d\n",
+		  __func__, rc, (int)outlen);
 
 	return rc;
 }
@@ -724,7 +734,7 @@ int efx_mcdi_log_ctrl(struct efx_nic *efx, bool evq, bool uart, u32 dest_evq)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -749,8 +759,8 @@ int efx_mcdi_nvram_types(struct efx_nic *efx, u32 *nvram_types_out)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n",
-		__func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+		  __func__, rc);
 	return rc;
 }
 
@@ -781,7 +791,7 @@ int efx_mcdi_nvram_info(struct efx_nic *efx, unsigned int type,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -802,7 +812,7 @@ int efx_mcdi_nvram_update_start(struct efx_nic *efx, unsigned int type)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -827,7 +837,7 @@ int efx_mcdi_nvram_read(struct efx_nic *efx, unsigned int type,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -853,7 +863,7 @@ int efx_mcdi_nvram_write(struct efx_nic *efx, unsigned int type,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -877,7 +887,7 @@ int efx_mcdi_nvram_erase(struct efx_nic *efx, unsigned int type,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -898,7 +908,7 @@ int efx_mcdi_nvram_update_finish(struct efx_nic *efx, unsigned int type)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -948,9 +958,10 @@ int efx_mcdi_nvram_test_all(struct efx_nic *efx)
 	return 0;
 
 fail2:
-	EFX_ERR(efx, "%s: failed type=%u\n", __func__, type);
+	netif_err(efx, hw, efx->net_dev, "%s: failed type=%u\n",
+		  __func__, type);
 fail1:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -994,14 +1005,15 @@ static int efx_mcdi_read_assertion(struct efx_nic *efx)
 		: (flags == MC_CMD_GET_ASSERTS_FLAGS_WDOG_FIRED)
 		? "watchdog reset"
 		: "unknown assertion";
-	EFX_ERR(efx, "MCPU %s at PC = 0x%.8x in thread 0x%.8x\n", reason,
-		MCDI_DWORD(outbuf, GET_ASSERTS_OUT_SAVED_PC_OFFS),
-		MCDI_DWORD(outbuf, GET_ASSERTS_OUT_THREAD_OFFS));
+	netif_err(efx, hw, efx->net_dev,
+		  "MCPU %s at PC = 0x%.8x in thread 0x%.8x\n", reason,
+		  MCDI_DWORD(outbuf, GET_ASSERTS_OUT_SAVED_PC_OFFS),
+		  MCDI_DWORD(outbuf, GET_ASSERTS_OUT_THREAD_OFFS));
 
 	/* Print out the registers */
 	ofst = MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_OFST;
 	for (index = 1; index < 32; index++) {
-		EFX_ERR(efx, "R%.2d (?): 0x%.8x\n", index,
+		netif_err(efx, hw, efx->net_dev, "R%.2d (?): 0x%.8x\n", index,
 			MCDI_DWORD2(outbuf, ofst));
 		ofst += sizeof(efx_dword_t);
 	}
@@ -1050,14 +1062,16 @@ void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 	rc = efx_mcdi_rpc(efx, MC_CMD_SET_ID_LED, inbuf, sizeof(inbuf),
 			  NULL, 0, NULL);
 	if (rc)
-		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+		netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+			  __func__, rc);
 }
 
 int efx_mcdi_reset_port(struct efx_nic *efx)
 {
 	int rc = efx_mcdi_rpc(efx, MC_CMD_PORT_RESET, NULL, 0, NULL, 0, NULL);
 	if (rc)
-		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+		netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+			  __func__, rc);
 	return rc;
 }
 
@@ -1075,7 +1089,7 @@ int efx_mcdi_reset_mc(struct efx_nic *efx)
 		return 0;
 	if (rc == 0)
 		rc = -EIO;
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -1108,7 +1122,7 @@ int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
 
 fail:
 	*id_out = -1;
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 
 }
@@ -1143,7 +1157,7 @@ int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out)
 
 fail:
 	*id_out = -1;
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -1163,7 +1177,7 @@ int efx_mcdi_wol_filter_remove(struct efx_nic *efx, int id)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -1179,7 +1193,7 @@ int efx_mcdi_wol_filter_reset(struct efx_nic *efx)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
diff --git a/drivers/net/sfc/mcdi_mac.c b/drivers/net/sfc/mcdi_mac.c
index 3918263..f88f4bf 100644
--- a/drivers/net/sfc/mcdi_mac.c
+++ b/drivers/net/sfc/mcdi_mac.c
@@ -69,8 +69,8 @@ static int efx_mcdi_get_mac_faults(struct efx_nic *efx, u32 *faults)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n",
-		__func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+		  __func__, rc);
 	return rc;
 }
 
@@ -110,8 +110,8 @@ int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: %s failed rc=%d\n",
-		__func__, enable ? "enable" : "disable", rc);
+	netif_err(efx, hw, efx->net_dev, "%s: %s failed rc=%d\n",
+		  __func__, enable ? "enable" : "disable", rc);
 	return rc;
 }
 
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 86e43b1..0121e71 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -71,7 +71,7 @@ efx_mcdi_get_phy_cfg(struct efx_nic *efx, struct efx_mcdi_phy_data *cfg)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -97,7 +97,7 @@ static int efx_mcdi_set_link(struct efx_nic *efx, u32 capabilities,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -122,7 +122,7 @@ static int efx_mcdi_loopback_modes(struct efx_nic *efx, u64 *loopback_modes)
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -150,7 +150,7 @@ int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -178,7 +178,7 @@ int efx_mcdi_mdio_write(struct efx_nic *efx, unsigned int bus,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
@@ -466,8 +466,8 @@ void efx_mcdi_phy_check_fcntl(struct efx_nic *efx, u32 lpa)
 		rmtadv |=  ADVERTISED_Asym_Pause;
 
 	if ((efx->wanted_fc & EFX_FC_TX) && rmtadv == ADVERTISED_Asym_Pause)
-		EFX_ERR(efx, "warning: link partner doesn't support "
-			"pause frames");
+		netif_err(efx, link, efx->net_dev,
+			  "warning: link partner doesn't support pause frames");
 }
 
 static bool efx_mcdi_phy_poll(struct efx_nic *efx)
@@ -483,7 +483,8 @@ static bool efx_mcdi_phy_poll(struct efx_nic *efx)
 	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
 			  outbuf, sizeof(outbuf), NULL);
 	if (rc) {
-		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+		netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+			  __func__, rc);
 		efx->link_state.up = false;
 	} else {
 		efx_mcdi_phy_decode_link(
@@ -526,7 +527,8 @@ static void efx_mcdi_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *e
 	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
 			  outbuf, sizeof(outbuf), NULL);
 	if (rc) {
-		EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+		netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n",
+			  __func__, rc);
 		return;
 	}
 	ecmd->lp_advertising =
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 0548fcb..eeaf0bd 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -63,7 +63,8 @@ static int efx_mdio_check_mmd(struct efx_nic *efx, int mmd, int fault_fatal)
 		/* Read MMD STATUS2 to check it is responding. */
 		status = efx_mdio_read(efx, mmd, MDIO_STAT2);
 		if ((status & MDIO_STAT2_DEVPRST) != MDIO_STAT2_DEVPRST_VAL) {
-			EFX_ERR(efx, "PHY MMD %d not responding.\n", mmd);
+			netif_err(efx, hw, efx->net_dev,
+				  "PHY MMD %d not responding.\n", mmd);
 			return -EIO;
 		}
 	}
@@ -72,12 +73,14 @@ static int efx_mdio_check_mmd(struct efx_nic *efx, int mmd, int fault_fatal)
 	status = efx_mdio_read(efx, mmd, MDIO_STAT1);
 	if (status & MDIO_STAT1_FAULT) {
 		if (fault_fatal) {
-			EFX_ERR(efx, "PHY MMD %d reporting fatal"
-				" fault: status %x\n", mmd, status);
+			netif_err(efx, hw, efx->net_dev,
+				  "PHY MMD %d reporting fatal"
+				  " fault: status %x\n", mmd, status);
 			return -EIO;
 		} else {
-			EFX_LOG(efx, "PHY MMD %d reporting status"
-				" %x (expected)\n", mmd, status);
+			netif_dbg(efx, hw, efx->net_dev,
+				  "PHY MMD %d reporting status"
+				  " %x (expected)\n", mmd, status);
 		}
 	}
 	return 0;
@@ -103,8 +106,9 @@ int efx_mdio_wait_reset_mmds(struct efx_nic *efx, unsigned int mmd_mask)
 			if (mask & 1) {
 				stat = efx_mdio_read(efx, mmd, MDIO_CTRL1);
 				if (stat < 0) {
-					EFX_ERR(efx, "failed to read status of"
-						" MMD %d\n", mmd);
+					netif_err(efx, hw, efx->net_dev,
+						  "failed to read status of"
+						  " MMD %d\n", mmd);
 					return -EIO;
 				}
 				if (stat & MDIO_CTRL1_RESET)
@@ -119,8 +123,9 @@ int efx_mdio_wait_reset_mmds(struct efx_nic *efx, unsigned int mmd_mask)
 		msleep(spintime);
 	}
 	if (in_reset != 0) {
-		EFX_ERR(efx, "not all MMDs came out of reset in time."
-			" MMDs still in reset: %x\n", in_reset);
+		netif_err(efx, hw, efx->net_dev,
+			  "not all MMDs came out of reset in time."
+			  " MMDs still in reset: %x\n", in_reset);
 		rc = -ETIMEDOUT;
 	}
 	return rc;
@@ -142,16 +147,18 @@ int efx_mdio_check_mmds(struct efx_nic *efx,
 	devs1 = efx_mdio_read(efx, probe_mmd, MDIO_DEVS1);
 	devs2 = efx_mdio_read(efx, probe_mmd, MDIO_DEVS2);
 	if (devs1 < 0 || devs2 < 0) {
-		EFX_ERR(efx, "failed to read devices present\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "failed to read devices present\n");
 		return -EIO;
 	}
 	devices = devs1 | (devs2 << 16);
 	if ((devices & mmd_mask) != mmd_mask) {
-		EFX_ERR(efx, "required MMDs not present: got %x, "
-			"wanted %x\n", devices, mmd_mask);
+		netif_err(efx, hw, efx->net_dev,
+			  "required MMDs not present: got %x, wanted %x\n",
+			  devices, mmd_mask);
 		return -ENODEV;
 	}
-	EFX_TRACE(efx, "Devices present: %x\n", devices);
+	netif_vdbg(efx, hw, efx->net_dev, "Devices present: %x\n", devices);
 
 	/* Check all required MMDs are responding and happy. */
 	while (mmd_mask) {
@@ -219,7 +226,7 @@ static void efx_mdio_set_mmd_lpower(struct efx_nic *efx,
 {
 	int stat = efx_mdio_read(efx, mmd, MDIO_STAT1);
 
-	EFX_TRACE(efx, "Setting low power mode for MMD %d to %d\n",
+	netif_vdbg(efx, drv, efx->net_dev, "Setting low power mode for MMD %d to %d\n",
 		  mmd, lpower);
 
 	if (stat & MDIO_STAT1_LPOWERABLE) {
@@ -349,8 +356,8 @@ int efx_mdio_test_alive(struct efx_nic *efx)
 
 	if ((physid1 == 0x0000) || (physid1 == 0xffff) ||
 	    (physid2 == 0x0000) || (physid2 == 0xffff)) {
-		EFX_ERR(efx, "no MDIO PHY present with ID %d\n",
-			efx->mdio.prtad);
+		netif_err(efx, hw, efx->net_dev,
+			  "no MDIO PHY present with ID %d\n", efx->mdio.prtad);
 		rc = -EINVAL;
 	} else {
 		rc = efx_mdio_check_mmds(efx, efx->mdio.mmds, 0);
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index f89e719..75791d3 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -51,7 +51,8 @@ static inline bool efx_mdio_phyxgxs_lane_sync(struct efx_nic *efx)
 
 	sync = !!(lane_status & MDIO_PHYXS_LNSTAT_ALIGN);
 	if (!sync)
-		EFX_LOG(efx, "XGXS lane status: %x\n", lane_status);
+		netif_dbg(efx, hw, efx->net_dev, "XGXS lane status: %x\n",
+			  lane_status);
 	return sync;
 }
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index a8783b4..33c62ae 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -13,6 +13,10 @@
 #ifndef EFX_NET_DRIVER_H
 #define EFX_NET_DRIVER_H
 
+#if defined(EFX_ENABLE_DEBUG) && !defined(DEBUG)
+#define DEBUG
+#endif
+
 #include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -48,35 +52,6 @@
 #define EFX_WARN_ON_PARANOID(x) do {} while (0)
 #endif
 
-/* Un-rate-limited logging */
-#define EFX_ERR(efx, fmt, args...) \
-dev_err(&((efx)->pci_dev->dev), "ERR: %s " fmt, efx_dev_name(efx), ##args)
-
-#define EFX_INFO(efx, fmt, args...) \
-dev_info(&((efx)->pci_dev->dev), "INFO: %s " fmt, efx_dev_name(efx), ##args)
-
-#ifdef EFX_ENABLE_DEBUG
-#define EFX_LOG(efx, fmt, args...) \
-dev_info(&((efx)->pci_dev->dev), "DBG: %s " fmt, efx_dev_name(efx), ##args)
-#else
-#define EFX_LOG(efx, fmt, args...) \
-dev_dbg(&((efx)->pci_dev->dev), "DBG: %s " fmt, efx_dev_name(efx), ##args)
-#endif
-
-#define EFX_TRACE(efx, fmt, args...) do {} while (0)
-
-#define EFX_REGDUMP(efx, fmt, args...) do {} while (0)
-
-/* Rate-limited logging */
-#define EFX_ERR_RL(efx, fmt, args...) \
-do {if (net_ratelimit()) EFX_ERR(efx, fmt, ##args); } while (0)
-
-#define EFX_INFO_RL(efx, fmt, args...) \
-do {if (net_ratelimit()) EFX_INFO(efx, fmt, ##args); } while (0)
-
-#define EFX_LOG_RL(efx, fmt, args...) \
-do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); } while (0)
-
 /**************************************************************************
  *
  * Efx data structures
@@ -662,6 +637,7 @@ union efx_multicast_hash {
  * @interrupt_mode: Interrupt mode
  * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
  * @irq_rx_moderation: IRQ moderation time for RX event queues
+ * @msg_enable: Log message enable flags
  * @state: Device state flag. Serialised by the rtnl_lock.
  * @reset_pending: Pending reset method (normally RESET_TYPE_NONE)
  * @tx_queue: TX DMA queues
@@ -744,6 +720,7 @@ struct efx_nic {
 	enum efx_int_mode interrupt_mode;
 	bool irq_rx_adaptive;
 	unsigned int irq_rx_moderation;
+	u32 msg_enable;
 
 	enum nic_state state;
 	enum reset_type reset_pending;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 67235f1..3083657 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -179,9 +179,10 @@ int efx_nic_test_registers(struct efx_nic *efx,
 	return 0;
 
 fail:
-	EFX_ERR(efx, "wrote "EFX_OWORD_FMT" read "EFX_OWORD_FMT
-		" at address 0x%x mask "EFX_OWORD_FMT"\n", EFX_OWORD_VAL(reg),
-		EFX_OWORD_VAL(buf), address, EFX_OWORD_VAL(mask));
+	netif_err(efx, hw, efx->net_dev,
+		  "wrote "EFX_OWORD_FMT" read "EFX_OWORD_FMT
+		  " at address 0x%x mask "EFX_OWORD_FMT"\n", EFX_OWORD_VAL(reg),
+		  EFX_OWORD_VAL(buf), address, EFX_OWORD_VAL(mask));
 	return -EIO;
 }
 
@@ -214,8 +215,9 @@ efx_init_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 	for (i = 0; i < buffer->entries; i++) {
 		index = buffer->index + i;
 		dma_addr = buffer->dma_addr + (i * 4096);
-		EFX_LOG(efx, "mapping special buffer %d at %llx\n",
-			index, (unsigned long long)dma_addr);
+		netif_dbg(efx, probe, efx->net_dev,
+			  "mapping special buffer %d at %llx\n",
+			  index, (unsigned long long)dma_addr);
 		EFX_POPULATE_QWORD_3(buf_desc,
 				     FRF_AZ_BUF_ADR_REGION, 0,
 				     FRF_AZ_BUF_ADR_FBUF, dma_addr >> 12,
@@ -235,8 +237,8 @@ efx_fini_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 	if (!buffer->entries)
 		return;
 
-	EFX_LOG(efx, "unmapping special buffers %d-%d\n",
-		buffer->index, buffer->index + buffer->entries - 1);
+	netif_dbg(efx, hw, efx->net_dev, "unmapping special buffers %d-%d\n",
+		  buffer->index, buffer->index + buffer->entries - 1);
 
 	EFX_POPULATE_OWORD_4(buf_tbl_upd,
 			     FRF_AZ_BUF_UPD_CMD, 0,
@@ -276,11 +278,12 @@ static int efx_alloc_special_buffer(struct efx_nic *efx,
 	buffer->index = efx->next_buffer_table;
 	efx->next_buffer_table += buffer->entries;
 
-	EFX_LOG(efx, "allocating special buffers %d-%d at %llx+%x "
-		"(virt %p phys %llx)\n", buffer->index,
-		buffer->index + buffer->entries - 1,
-		(u64)buffer->dma_addr, len,
-		buffer->addr, (u64)virt_to_phys(buffer->addr));
+	netif_dbg(efx, probe, efx->net_dev,
+		  "allocating special buffers %d-%d at %llx+%x "
+		  "(virt %p phys %llx)\n", buffer->index,
+		  buffer->index + buffer->entries - 1,
+		  (u64)buffer->dma_addr, len,
+		  buffer->addr, (u64)virt_to_phys(buffer->addr));
 
 	return 0;
 }
@@ -291,11 +294,12 @@ efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 	if (!buffer->addr)
 		return;
 
-	EFX_LOG(efx, "deallocating special buffers %d-%d at %llx+%x "
-		"(virt %p phys %llx)\n", buffer->index,
-		buffer->index + buffer->entries - 1,
-		(u64)buffer->dma_addr, buffer->len,
-		buffer->addr, (u64)virt_to_phys(buffer->addr));
+	netif_dbg(efx, hw, efx->net_dev,
+		  "deallocating special buffers %d-%d at %llx+%x "
+		  "(virt %p phys %llx)\n", buffer->index,
+		  buffer->index + buffer->entries - 1,
+		  (u64)buffer->dma_addr, buffer->len,
+		  buffer->addr, (u64)virt_to_phys(buffer->addr));
 
 	pci_free_consistent(efx->pci_dev, buffer->len, buffer->addr,
 			    buffer->dma_addr);
@@ -555,9 +559,10 @@ void efx_nic_init_rx(struct efx_rx_queue *rx_queue)
 	bool is_b0 = efx_nic_rev(efx) >= EFX_REV_FALCON_B0;
 	bool iscsi_digest_en = is_b0;
 
-	EFX_LOG(efx, "RX queue %d ring in special buffers %d-%d\n",
-		rx_queue->queue, rx_queue->rxd.index,
-		rx_queue->rxd.index + rx_queue->rxd.entries - 1);
+	netif_dbg(efx, hw, efx->net_dev,
+		  "RX queue %d ring in special buffers %d-%d\n",
+		  rx_queue->queue, rx_queue->rxd.index,
+		  rx_queue->rxd.index + rx_queue->rxd.entries - 1);
 
 	rx_queue->flushed = FLUSH_NONE;
 
@@ -694,9 +699,10 @@ efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 		   EFX_WORKAROUND_10727(efx)) {
 		efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
 	} else {
-		EFX_ERR(efx, "channel %d unexpected TX event "
-			EFX_QWORD_FMT"\n", channel->channel,
-			EFX_QWORD_VAL(*event));
+		netif_err(efx, tx_err, efx->net_dev,
+			  "channel %d unexpected TX event "
+			  EFX_QWORD_FMT"\n", channel->channel,
+			  EFX_QWORD_VAL(*event));
 	}
 
 	return tx_packets;
@@ -759,20 +765,21 @@ static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	 * to a FIFO overflow.
 	 */
 #ifdef EFX_ENABLE_DEBUG
-	if (rx_ev_other_err) {
-		EFX_INFO_RL(efx, " RX queue %d unexpected RX event "
-			    EFX_QWORD_FMT "%s%s%s%s%s%s%s%s\n",
-			    rx_queue->queue, EFX_QWORD_VAL(*event),
-			    rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
-			    rx_ev_ip_hdr_chksum_err ?
-			    " [IP_HDR_CHKSUM_ERR]" : "",
-			    rx_ev_tcp_udp_chksum_err ?
-			    " [TCP_UDP_CHKSUM_ERR]" : "",
-			    rx_ev_eth_crc_err ? " [ETH_CRC_ERR]" : "",
-			    rx_ev_frm_trunc ? " [FRM_TRUNC]" : "",
-			    rx_ev_drib_nib ? " [DRIB_NIB]" : "",
-			    rx_ev_tobe_disc ? " [TOBE_DISC]" : "",
-			    rx_ev_pause_frm ? " [PAUSE]" : "");
+	if (rx_ev_other_err && net_ratelimit()) {
+		netif_dbg(efx, rx_err, efx->net_dev,
+			  " RX queue %d unexpected RX event "
+			  EFX_QWORD_FMT "%s%s%s%s%s%s%s%s\n",
+			  rx_queue->queue, EFX_QWORD_VAL(*event),
+			  rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
+			  rx_ev_ip_hdr_chksum_err ?
+			  " [IP_HDR_CHKSUM_ERR]" : "",
+			  rx_ev_tcp_udp_chksum_err ?
+			  " [TCP_UDP_CHKSUM_ERR]" : "",
+			  rx_ev_eth_crc_err ? " [ETH_CRC_ERR]" : "",
+			  rx_ev_frm_trunc ? " [FRM_TRUNC]" : "",
+			  rx_ev_drib_nib ? " [DRIB_NIB]" : "",
+			  rx_ev_tobe_disc ? " [TOBE_DISC]" : "",
+			  rx_ev_pause_frm ? " [PAUSE]" : "");
 	}
 #endif
 }
@@ -786,8 +793,9 @@ efx_handle_rx_bad_index(struct efx_rx_queue *rx_queue, unsigned index)
 
 	expected = rx_queue->removed_count & EFX_RXQ_MASK;
 	dropped = (index - expected) & EFX_RXQ_MASK;
-	EFX_INFO(efx, "dropped %d events (index=%d expected=%d)\n",
-		dropped, index, expected);
+	netif_info(efx, rx_err, efx->net_dev,
+		   "dropped %d events (index=%d expected=%d)\n",
+		   dropped, index, expected);
 
 	efx_schedule_reset(efx, EFX_WORKAROUND_5676(efx) ?
 			   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
@@ -873,9 +881,9 @@ efx_handle_generated_event(struct efx_channel *channel, efx_qword_t *event)
 		 * queue. Refill it here */
 		efx_fast_push_rx_descriptors(&efx->rx_queue[channel->channel]);
 	else
-		EFX_LOG(efx, "channel %d received generated "
-			"event "EFX_QWORD_FMT"\n", channel->channel,
-			EFX_QWORD_VAL(*event));
+		netif_dbg(efx, hw, efx->net_dev, "channel %d received "
+			  "generated event "EFX_QWORD_FMT"\n",
+			  channel->channel, EFX_QWORD_VAL(*event));
 }
 
 /* Global events are basically PHY events */
@@ -901,8 +909,9 @@ efx_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
 	if (efx_nic_rev(efx) <= EFX_REV_FALCON_A1 ?
 	    EFX_QWORD_FIELD(*event, FSF_AA_GLB_EV_RX_RECOVERY) :
 	    EFX_QWORD_FIELD(*event, FSF_BB_GLB_EV_RX_RECOVERY)) {
-		EFX_ERR(efx, "channel %d seen global RX_RESET "
-			"event. Resetting.\n", channel->channel);
+		netif_err(efx, rx_err, efx->net_dev,
+			  "channel %d seen global RX_RESET event. Resetting.\n",
+			  channel->channel);
 
 		atomic_inc(&efx->rx_reset);
 		efx_schedule_reset(efx, EFX_WORKAROUND_6555(efx) ?
@@ -911,9 +920,10 @@ efx_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
 	}
 
 	if (!handled)
-		EFX_ERR(efx, "channel %d unknown global event "
-			EFX_QWORD_FMT "\n", channel->channel,
-			EFX_QWORD_VAL(*event));
+		netif_err(efx, hw, efx->net_dev,
+			  "channel %d unknown global event "
+			  EFX_QWORD_FMT "\n", channel->channel,
+			  EFX_QWORD_VAL(*event));
 }
 
 static void
@@ -928,31 +938,35 @@ efx_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 
 	switch (ev_sub_code) {
 	case FSE_AZ_TX_DESCQ_FLS_DONE_EV:
-		EFX_TRACE(efx, "channel %d TXQ %d flushed\n",
-			  channel->channel, ev_sub_data);
+		netif_vdbg(efx, hw, efx->net_dev, "channel %d TXQ %d flushed\n",
+			   channel->channel, ev_sub_data);
 		break;
 	case FSE_AZ_RX_DESCQ_FLS_DONE_EV:
-		EFX_TRACE(efx, "channel %d RXQ %d flushed\n",
-			  channel->channel, ev_sub_data);
+		netif_vdbg(efx, hw, efx->net_dev, "channel %d RXQ %d flushed\n",
+			   channel->channel, ev_sub_data);
 		break;
 	case FSE_AZ_EVQ_INIT_DONE_EV:
-		EFX_LOG(efx, "channel %d EVQ %d initialised\n",
-			channel->channel, ev_sub_data);
+		netif_dbg(efx, hw, efx->net_dev,
+			  "channel %d EVQ %d initialised\n",
+			  channel->channel, ev_sub_data);
 		break;
 	case FSE_AZ_SRM_UPD_DONE_EV:
-		EFX_TRACE(efx, "channel %d SRAM update done\n",
-			  channel->channel);
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d SRAM update done\n", channel->channel);
 		break;
 	case FSE_AZ_WAKE_UP_EV:
-		EFX_TRACE(efx, "channel %d RXQ %d wakeup event\n",
-			  channel->channel, ev_sub_data);
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d RXQ %d wakeup event\n",
+			   channel->channel, ev_sub_data);
 		break;
 	case FSE_AZ_TIMER_EV:
-		EFX_TRACE(efx, "channel %d RX queue %d timer expired\n",
-			  channel->channel, ev_sub_data);
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d RX queue %d timer expired\n",
+			   channel->channel, ev_sub_data);
 		break;
 	case FSE_AA_RX_RECOVER_EV:
-		EFX_ERR(efx, "channel %d seen DRIVER RX_RESET event. "
+		netif_err(efx, rx_err, efx->net_dev,
+			  "channel %d seen DRIVER RX_RESET event. "
 			"Resetting.\n", channel->channel);
 		atomic_inc(&efx->rx_reset);
 		efx_schedule_reset(efx,
@@ -961,19 +975,22 @@ efx_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 				   RESET_TYPE_DISABLE);
 		break;
 	case FSE_BZ_RX_DSC_ERROR_EV:
-		EFX_ERR(efx, "RX DMA Q %d reports descriptor fetch error."
-			" RX Q %d is disabled.\n", ev_sub_data, ev_sub_data);
+		netif_err(efx, rx_err, efx->net_dev,
+			  "RX DMA Q %d reports descriptor fetch error."
+			  " RX Q %d is disabled.\n", ev_sub_data, ev_sub_data);
 		efx_schedule_reset(efx, RESET_TYPE_RX_DESC_FETCH);
 		break;
 	case FSE_BZ_TX_DSC_ERROR_EV:
-		EFX_ERR(efx, "TX DMA Q %d reports descriptor fetch error."
-			" TX Q %d is disabled.\n", ev_sub_data, ev_sub_data);
+		netif_err(efx, tx_err, efx->net_dev,
+			  "TX DMA Q %d reports descriptor fetch error."
+			  " TX Q %d is disabled.\n", ev_sub_data, ev_sub_data);
 		efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
 		break;
 	default:
-		EFX_TRACE(efx, "channel %d unknown driver event code %d "
-			  "data %04x\n", channel->channel, ev_sub_code,
-			  ev_sub_data);
+		netif_vdbg(efx, hw, efx->net_dev,
+			   "channel %d unknown driver event code %d "
+			   "data %04x\n", channel->channel, ev_sub_code,
+			   ev_sub_data);
 		break;
 	}
 }
@@ -996,8 +1013,9 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 			/* End of events */
 			break;
 
-		EFX_TRACE(channel->efx, "channel %d event is "EFX_QWORD_FMT"\n",
-			  channel->channel, EFX_QWORD_VAL(event));
+		netif_vdbg(channel->efx, intr, channel->efx->net_dev,
+			   "channel %d event is "EFX_QWORD_FMT"\n",
+			   channel->channel, EFX_QWORD_VAL(event));
 
 		/* Clear this event by marking it all ones */
 		EFX_SET_QWORD(*p_event);
@@ -1033,9 +1051,10 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 			efx_mcdi_process_event(channel, &event);
 			break;
 		default:
-			EFX_ERR(channel->efx, "channel %d unknown event type %d"
-				" (data " EFX_QWORD_FMT ")\n", channel->channel,
-				ev_code, EFX_QWORD_VAL(event));
+			netif_err(channel->efx, hw, channel->efx->net_dev,
+				  "channel %d unknown event type %d (data "
+				  EFX_QWORD_FMT ")\n", channel->channel,
+				  ev_code, EFX_QWORD_VAL(event));
 		}
 	}
 
@@ -1060,9 +1079,10 @@ void efx_nic_init_eventq(struct efx_channel *channel)
 	efx_oword_t reg;
 	struct efx_nic *efx = channel->efx;
 
-	EFX_LOG(efx, "channel %d event queue in special buffers %d-%d\n",
-		channel->channel, channel->eventq.index,
-		channel->eventq.index + channel->eventq.entries - 1);
+	netif_dbg(efx, hw, efx->net_dev,
+		  "channel %d event queue in special buffers %d-%d\n",
+		  channel->channel, channel->eventq.index,
+		  channel->eventq.index + channel->eventq.entries - 1);
 
 	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0) {
 		EFX_POPULATE_OWORD_3(reg,
@@ -1240,14 +1260,16 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 	 * leading to a reset, or fake up success anyway */
 	efx_for_each_tx_queue(tx_queue, efx) {
 		if (tx_queue->flushed != FLUSH_DONE)
-			EFX_ERR(efx, "tx queue %d flush command timed out\n",
-				tx_queue->queue);
+			netif_err(efx, hw, efx->net_dev,
+				  "tx queue %d flush command timed out\n",
+				  tx_queue->queue);
 		tx_queue->flushed = FLUSH_DONE;
 	}
 	efx_for_each_rx_queue(rx_queue, efx) {
 		if (rx_queue->flushed != FLUSH_DONE)
-			EFX_ERR(efx, "rx queue %d flush command timed out\n",
-				rx_queue->queue);
+			netif_err(efx, hw, efx->net_dev,
+				  "rx queue %d flush command timed out\n",
+				  rx_queue->queue);
 		rx_queue->flushed = FLUSH_DONE;
 	}
 
@@ -1319,10 +1341,10 @@ irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx)
 	efx_reado(efx, &fatal_intr, FR_AZ_FATAL_INTR_KER);
 	error = EFX_OWORD_FIELD(fatal_intr, FRF_AZ_FATAL_INTR);
 
-	EFX_ERR(efx, "SYSTEM ERROR " EFX_OWORD_FMT " status "
-		EFX_OWORD_FMT ": %s\n", EFX_OWORD_VAL(*int_ker),
-		EFX_OWORD_VAL(fatal_intr),
-		error ? "disabling bus mastering" : "no recognised error");
+	netif_err(efx, hw, efx->net_dev, "SYSTEM ERROR "EFX_OWORD_FMT" status "
+		  EFX_OWORD_FMT ": %s\n", EFX_OWORD_VAL(*int_ker),
+		  EFX_OWORD_VAL(fatal_intr),
+		  error ? "disabling bus mastering" : "no recognised error");
 
 	/* If this is a memory parity error dump which blocks are offending */
 	mem_perr = (EFX_OWORD_FIELD(fatal_intr, FRF_AZ_MEM_PERR_INT_KER) ||
@@ -1330,8 +1352,9 @@ irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx)
 	if (mem_perr) {
 		efx_oword_t reg;
 		efx_reado(efx, &reg, FR_AZ_MEM_STAT);
-		EFX_ERR(efx, "SYSTEM ERROR: memory parity error "
-			EFX_OWORD_FMT "\n", EFX_OWORD_VAL(reg));
+		netif_err(efx, hw, efx->net_dev,
+			  "SYSTEM ERROR: memory parity error "EFX_OWORD_FMT"\n",
+			  EFX_OWORD_VAL(reg));
 	}
 
 	/* Disable both devices */
@@ -1348,11 +1371,13 @@ irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx)
 			jiffies + EFX_INT_ERROR_EXPIRE * HZ;
 	}
 	if (++efx->int_error_count < EFX_MAX_INT_ERRORS) {
-		EFX_ERR(efx, "SYSTEM ERROR - reset scheduled\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "SYSTEM ERROR - reset scheduled\n");
 		efx_schedule_reset(efx, RESET_TYPE_INT_ERROR);
 	} else {
-		EFX_ERR(efx, "SYSTEM ERROR - max number of errors seen."
-			"NIC will be disabled\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "SYSTEM ERROR - max number of errors seen."
+			  "NIC will be disabled\n");
 		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
 	}
 
@@ -1415,8 +1440,9 @@ static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 
 	if (result == IRQ_HANDLED) {
 		efx->last_irq_cpu = raw_smp_processor_id();
-		EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_DWORD_FMT "\n",
-			  irq, raw_smp_processor_id(), EFX_DWORD_VAL(reg));
+		netif_vdbg(efx, intr, efx->net_dev,
+			   "IRQ %d on CPU %d status " EFX_DWORD_FMT "\n",
+			   irq, raw_smp_processor_id(), EFX_DWORD_VAL(reg));
 	}
 
 	return result;
@@ -1437,8 +1463,9 @@ static irqreturn_t efx_msi_interrupt(int irq, void *dev_id)
 	int syserr;
 
 	efx->last_irq_cpu = raw_smp_processor_id();
-	EFX_TRACE(efx, "IRQ %d on CPU %d status " EFX_OWORD_FMT "\n",
-		  irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
+	netif_vdbg(efx, intr, efx->net_dev,
+		   "IRQ %d on CPU %d status " EFX_OWORD_FMT "\n",
+		   irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
 
 	/* Check to see if we have a serious error condition */
 	if (channel->channel == efx->fatal_irq_level) {
@@ -1494,8 +1521,9 @@ int efx_nic_init_interrupt(struct efx_nic *efx)
 		rc = request_irq(efx->legacy_irq, handler, IRQF_SHARED,
 				 efx->name, efx);
 		if (rc) {
-			EFX_ERR(efx, "failed to hook legacy IRQ %d\n",
-				efx->pci_dev->irq);
+			netif_err(efx, drv, efx->net_dev,
+				  "failed to hook legacy IRQ %d\n",
+				  efx->pci_dev->irq);
 			goto fail1;
 		}
 		return 0;
@@ -1507,7 +1535,8 @@ int efx_nic_init_interrupt(struct efx_nic *efx)
 				 IRQF_PROBE_SHARED, /* Not shared */
 				 channel->name, channel);
 		if (rc) {
-			EFX_ERR(efx, "failed to hook IRQ %d\n", channel->irq);
+			netif_err(efx, drv, efx->net_dev,
+				  "failed to hook IRQ %d\n", channel->irq);
 			goto fail2;
 		}
 	}
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index e077bef..68813d1 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -91,9 +91,10 @@ static int qt2025c_wait_heartbeat(struct efx_nic *efx)
 		if (time_after(jiffies, timeout)) {
 			/* Some cables have EEPROMs that conflict with the
 			 * PHY's on-board EEPROM so it cannot load firmware */
-			EFX_ERR(efx, "If an SFP+ direct attach cable is"
-				" connected, please check that it complies"
-				" with the SFP+ specification\n");
+			netif_err(efx, hw, efx->net_dev,
+				  "If an SFP+ direct attach cable is"
+				  " connected, please check that it complies"
+				  " with the SFP+ specification\n");
 			return -ETIMEDOUT;
 		}
 		msleep(QT2025C_HEARTB_WAIT);
@@ -145,7 +146,8 @@ static int qt2025c_wait_reset(struct efx_nic *efx)
 		/* Bug 17689: occasionally heartbeat starts but firmware status
 		 * code never progresses beyond 0x00.  Try again, once, after
 		 * restarting execution of the firmware image. */
-		EFX_LOG(efx, "bashing QT2025C microcontroller\n");
+		netif_dbg(efx, hw, efx->net_dev,
+			  "bashing QT2025C microcontroller\n");
 		qt2025c_restart_firmware(efx);
 		rc = qt2025c_wait_heartbeat(efx);
 		if (rc != 0)
@@ -165,11 +167,12 @@ static void qt2025c_firmware_id(struct efx_nic *efx)
 	for (i = 0; i < sizeof(firmware_id); i++)
 		firmware_id[i] = efx_mdio_read(efx, MDIO_MMD_PCS,
 					       PCS_FW_PRODUCT_CODE_1 + i);
-	EFX_INFO(efx, "QT2025C firmware %xr%d v%d.%d.%d.%d [20%02d-%02d-%02d]\n",
-		 (firmware_id[0] << 8) | firmware_id[1], firmware_id[2],
-		 firmware_id[3] >> 4, firmware_id[3] & 0xf,
-		 firmware_id[4], firmware_id[5],
-		 firmware_id[6], firmware_id[7], firmware_id[8]);
+	netif_info(efx, probe, efx->net_dev,
+		   "QT2025C firmware %xr%d v%d.%d.%d.%d [20%02d-%02d-%02d]\n",
+		   (firmware_id[0] << 8) | firmware_id[1], firmware_id[2],
+		   firmware_id[3] >> 4, firmware_id[3] & 0xf,
+		   firmware_id[4], firmware_id[5],
+		   firmware_id[6], firmware_id[7], firmware_id[8]);
 	phy_data->firmware_ver = ((firmware_id[3] & 0xf0) << 20) |
 				 ((firmware_id[3] & 0x0f) << 16) |
 				 (firmware_id[4] << 8) | firmware_id[5];
@@ -198,7 +201,7 @@ static void qt2025c_bug17190_workaround(struct efx_nic *efx)
 	}
 
 	if (time_after_eq(jiffies, phy_data->bug17190_timer)) {
-		EFX_LOG(efx, "bashing QT2025C PMA/PMD\n");
+		netif_dbg(efx, hw, efx->net_dev, "bashing QT2025C PMA/PMD\n");
 		efx_mdio_set_flag(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1,
 				  MDIO_PMA_CTRL1_LOOPBACK, true);
 		msleep(100);
@@ -231,7 +234,8 @@ static int qt2025c_select_phy_mode(struct efx_nic *efx)
 	reg = efx_mdio_read(efx, 1, 0xc319);
 	if ((reg & 0x0038) == phy_op_mode)
 		return 0;
-	EFX_LOG(efx, "Switching PHY to mode 0x%04x\n", phy_op_mode);
+	netif_dbg(efx, hw, efx->net_dev, "Switching PHY to mode 0x%04x\n",
+		  phy_op_mode);
 
 	/* This sequence replicates the register writes configured in the boot
 	 * EEPROM (including the differences between board revisions), except
@@ -287,8 +291,9 @@ static int qt2025c_select_phy_mode(struct efx_nic *efx)
 	/* Wait for the microcontroller to be ready again */
 	rc = qt2025c_wait_reset(efx);
 	if (rc < 0) {
-		EFX_ERR(efx, "PHY microcontroller reset during mode switch "
-				"timed out\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "PHY microcontroller reset during mode switch "
+			  "timed out\n");
 		return rc;
 	}
 
@@ -324,7 +329,7 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 	return 0;
 
  fail:
-	EFX_ERR(efx, "PHY reset timed out\n");
+	netif_err(efx, hw, efx->net_dev, "PHY reset timed out\n");
 	return rc;
 }
 
@@ -353,14 +358,15 @@ static int qt202x_phy_init(struct efx_nic *efx)
 
 	rc = qt202x_reset_phy(efx);
 	if (rc) {
-		EFX_ERR(efx, "PHY init failed\n");
+		netif_err(efx, probe, efx->net_dev, "PHY init failed\n");
 		return rc;
 	}
 
 	devid = efx_mdio_read_id(efx, MDIO_MMD_PHYXS);
-	EFX_INFO(efx, "PHY ID reg %x (OUI %06x model %02x revision %x)\n",
-		 devid, efx_mdio_id_oui(devid), efx_mdio_id_model(devid),
-		 efx_mdio_id_rev(devid));
+	netif_info(efx, probe, efx->net_dev,
+		   "PHY ID reg %x (OUI %06x model %02x revision %x)\n",
+		   devid, efx_mdio_id_oui(devid), efx_mdio_id_model(devid),
+		   efx_mdio_id_rev(devid));
 
 	if (efx->phy_type == PHY_TYPE_QT2025C)
 		qt2025c_firmware_id(efx);
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 9fb698e..d9ed20e 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -348,10 +348,11 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 	if (space < EFX_RX_BATCH)
 		goto out;
 
-	EFX_TRACE(rx_queue->efx, "RX queue %d fast-filling descriptor ring from"
-		  " level %d to level %d using %s allocation\n",
-		  rx_queue->queue, fill_level, rx_queue->fast_fill_limit,
-		  channel->rx_alloc_push_pages ? "page" : "skb");
+	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
+		   "RX queue %d fast-filling descriptor ring from"
+		   " level %d to level %d using %s allocation\n",
+		   rx_queue->queue, fill_level, rx_queue->fast_fill_limit,
+		   channel->rx_alloc_push_pages ? "page" : "skb");
 
 	do {
 		if (channel->rx_alloc_push_pages)
@@ -366,9 +367,10 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 		}
 	} while ((space -= EFX_RX_BATCH) >= EFX_RX_BATCH);
 
-	EFX_TRACE(rx_queue->efx, "RX queue %d fast-filled descriptor ring "
-		  "to level %d\n", rx_queue->queue,
-		  rx_queue->added_count - rx_queue->removed_count);
+	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
+		   "RX queue %d fast-filled descriptor ring "
+		   "to level %d\n", rx_queue->queue,
+		   rx_queue->added_count - rx_queue->removed_count);
 
  out:
 	if (rx_queue->notified_count != rx_queue->added_count)
@@ -402,10 +404,12 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 	*discard = true;
 
 	if ((len > rx_buf->len) && EFX_WORKAROUND_8071(efx)) {
-		EFX_ERR_RL(efx, " RX queue %d seriously overlength "
-			   "RX event (0x%x > 0x%x+0x%x). Leaking\n",
-			   rx_queue->queue, len, max_len,
-			   efx->type->rx_buffer_padding);
+		if (net_ratelimit())
+			netif_err(efx, rx_err, efx->net_dev,
+				  " RX queue %d seriously overlength "
+				  "RX event (0x%x > 0x%x+0x%x). Leaking\n",
+				  rx_queue->queue, len, max_len,
+				  efx->type->rx_buffer_padding);
 		/* If this buffer was skb-allocated, then the meta
 		 * data at the end of the skb will be trashed. So
 		 * we have no choice but to leak the fragment.
@@ -413,8 +417,11 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 		*leak_packet = (rx_buf->skb != NULL);
 		efx_schedule_reset(efx, RESET_TYPE_RX_RECOVERY);
 	} else {
-		EFX_ERR_RL(efx, " RX queue %d overlength RX event "
-			   "(0x%x > 0x%x)\n", rx_queue->queue, len, max_len);
+		if (net_ratelimit())
+			netif_err(efx, rx_err, efx->net_dev,
+				  " RX queue %d overlength RX event "
+				  "(0x%x > 0x%x)\n",
+				  rx_queue->queue, len, max_len);
 	}
 
 	rx_queue->channel->n_rx_overlength++;
@@ -502,11 +509,12 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	efx_rx_packet__check_len(rx_queue, rx_buf, len,
 				 &discard, &leak_packet);
 
-	EFX_TRACE(efx, "RX queue %d received id %x at %llx+%x %s%s\n",
-		  rx_queue->queue, index,
-		  (unsigned long long)rx_buf->dma_addr, len,
-		  (checksummed ? " [SUMMED]" : ""),
-		  (discard ? " [DISCARD]" : ""));
+	netif_vdbg(efx, rx_status, efx->net_dev,
+		   "RX queue %d received id %x at %llx+%x %s%s\n",
+		   rx_queue->queue, index,
+		   (unsigned long long)rx_buf->dma_addr, len,
+		   (checksummed ? " [SUMMED]" : ""),
+		   (discard ? " [DISCARD]" : ""));
 
 	/* Discard packet, if instructed to do so */
 	if (unlikely(discard)) {
@@ -621,7 +629,8 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 	unsigned int rxq_size;
 	int rc;
 
-	EFX_LOG(efx, "creating RX queue %d\n", rx_queue->queue);
+	netif_dbg(efx, probe, efx->net_dev,
+		  "creating RX queue %d\n", rx_queue->queue);
 
 	/* Allocate RX buffers */
 	rxq_size = EFX_RXQ_SIZE * sizeof(*rx_queue->buffer);
@@ -641,7 +650,8 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	unsigned int max_fill, trigger, limit;
 
-	EFX_LOG(rx_queue->efx, "initialising RX queue %d\n", rx_queue->queue);
+	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
+		  "initialising RX queue %d\n", rx_queue->queue);
 
 	/* Initialise ptr fields */
 	rx_queue->added_count = 0;
@@ -668,7 +678,8 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 	int i;
 	struct efx_rx_buffer *rx_buf;
 
-	EFX_LOG(rx_queue->efx, "shutting down RX queue %d\n", rx_queue->queue);
+	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
+		  "shutting down RX queue %d\n", rx_queue->queue);
 
 	del_timer_sync(&rx_queue->slow_fill);
 	efx_nic_fini_rx(rx_queue);
@@ -684,7 +695,8 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 
 void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
 {
-	EFX_LOG(rx_queue->efx, "destroying RX queue %d\n", rx_queue->queue);
+	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
+		  "destroying RX queue %d\n", rx_queue->queue);
 
 	efx_nic_remove_rx(rx_queue);
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 1f83404..85f015f 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -123,7 +123,7 @@ static int efx_test_interrupts(struct efx_nic *efx,
 {
 	struct efx_channel *channel;
 
-	EFX_LOG(efx, "testing interrupts\n");
+	netif_dbg(efx, drv, efx->net_dev, "testing interrupts\n");
 	tests->interrupt = -1;
 
 	/* Reset interrupt flag */
@@ -142,16 +142,17 @@ static int efx_test_interrupts(struct efx_nic *efx,
 	efx_nic_generate_interrupt(efx);
 
 	/* Wait for arrival of test interrupt. */
-	EFX_LOG(efx, "waiting for test interrupt\n");
+	netif_dbg(efx, drv, efx->net_dev, "waiting for test interrupt\n");
 	schedule_timeout_uninterruptible(HZ / 10);
 	if (efx->last_irq_cpu >= 0)
 		goto success;
 
-	EFX_ERR(efx, "timed out waiting for interrupt\n");
+	netif_err(efx, drv, efx->net_dev, "timed out waiting for interrupt\n");
 	return -ETIMEDOUT;
 
  success:
-	EFX_LOG(efx, "%s test interrupt seen on CPU%d\n", INT_MODE(efx),
+	netif_dbg(efx, drv, efx->net_dev, "%s test interrupt seen on CPU%d\n",
+		  INT_MODE(efx),
 		efx->last_irq_cpu);
 	tests->interrupt = 1;
 	return 0;
@@ -161,6 +162,7 @@ static int efx_test_interrupts(struct efx_nic *efx,
 static int efx_test_eventq_irq(struct efx_channel *channel,
 			       struct efx_self_tests *tests)
 {
+	struct efx_nic *efx = channel->efx;
 	unsigned int magic_count, count;
 
 	tests->eventq_dma[channel->channel] = -1;
@@ -185,29 +187,32 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 			goto eventq_ok;
 	} while (++count < 2);
 
-	EFX_ERR(channel->efx, "channel %d timed out waiting for event queue\n",
-		channel->channel);
+	netif_err(efx, drv, efx->net_dev,
+		  "channel %d timed out waiting for event queue\n",
+		  channel->channel);
 
 	/* See if interrupt arrived */
 	if (channel->efx->last_irq_cpu >= 0) {
-		EFX_ERR(channel->efx, "channel %d saw interrupt on CPU%d "
-			"during event queue test\n", channel->channel,
-			raw_smp_processor_id());
+		netif_err(efx, drv, efx->net_dev,
+			  "channel %d saw interrupt on CPU%d "
+			  "during event queue test\n", channel->channel,
+			  raw_smp_processor_id());
 		tests->eventq_int[channel->channel] = 1;
 	}
 
 	/* Check to see if event was received even if interrupt wasn't */
 	efx_process_channel_now(channel);
 	if (channel->magic_count != magic_count) {
-		EFX_ERR(channel->efx, "channel %d event was generated, but "
-			"failed to trigger an interrupt\n", channel->channel);
+		netif_err(efx, drv, efx->net_dev,
+			  "channel %d event was generated, but "
+			  "failed to trigger an interrupt\n", channel->channel);
 		tests->eventq_dma[channel->channel] = 1;
 	}
 
 	return -ETIMEDOUT;
  eventq_ok:
-	EFX_LOG(channel->efx, "channel %d event queue passed\n",
-		channel->channel);
+	netif_dbg(efx, drv, efx->net_dev, "channel %d event queue passed\n",
+		  channel->channel);
 	tests->eventq_dma[channel->channel] = 1;
 	tests->eventq_int[channel->channel] = 1;
 	tests->eventq_poll[channel->channel] = 1;
@@ -260,51 +265,57 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
 
 	/* Check that header exists */
 	if (pkt_len < sizeof(received->header)) {
-		EFX_ERR(efx, "saw runt RX packet (length %d) in %s loopback "
-			"test\n", pkt_len, LOOPBACK_MODE(efx));
+		netif_err(efx, drv, efx->net_dev,
+			  "saw runt RX packet (length %d) in %s loopback "
+			  "test\n", pkt_len, LOOPBACK_MODE(efx));
 		goto err;
 	}
 
 	/* Check that the ethernet header exists */
 	if (memcmp(&received->header, &payload->header, ETH_HLEN) != 0) {
-		EFX_ERR(efx, "saw non-loopback RX packet in %s loopback test\n",
-			LOOPBACK_MODE(efx));
+		netif_err(efx, drv, efx->net_dev,
+			  "saw non-loopback RX packet in %s loopback test\n",
+			  LOOPBACK_MODE(efx));
 		goto err;
 	}
 
 	/* Check packet length */
 	if (pkt_len != sizeof(*payload)) {
-		EFX_ERR(efx, "saw incorrect RX packet length %d (wanted %d) in "
-			"%s loopback test\n", pkt_len, (int)sizeof(*payload),
-			LOOPBACK_MODE(efx));
+		netif_err(efx, drv, efx->net_dev,
+			  "saw incorrect RX packet length %d (wanted %d) in "
+			  "%s loopback test\n", pkt_len, (int)sizeof(*payload),
+			  LOOPBACK_MODE(efx));
 		goto err;
 	}
 
 	/* Check that IP header matches */
 	if (memcmp(&received->ip, &payload->ip, sizeof(payload->ip)) != 0) {
-		EFX_ERR(efx, "saw corrupted IP header in %s loopback test\n",
-			LOOPBACK_MODE(efx));
+		netif_err(efx, drv, efx->net_dev,
+			  "saw corrupted IP header in %s loopback test\n",
+			  LOOPBACK_MODE(efx));
 		goto err;
 	}
 
 	/* Check that msg and padding matches */
 	if (memcmp(&received->msg, &payload->msg, sizeof(received->msg)) != 0) {
-		EFX_ERR(efx, "saw corrupted RX packet in %s loopback test\n",
-			LOOPBACK_MODE(efx));
+		netif_err(efx, drv, efx->net_dev,
+			  "saw corrupted RX packet in %s loopback test\n",
+			  LOOPBACK_MODE(efx));
 		goto err;
 	}
 
 	/* Check that iteration matches */
 	if (received->iteration != payload->iteration) {
-		EFX_ERR(efx, "saw RX packet from iteration %d (wanted %d) in "
-			"%s loopback test\n", ntohs(received->iteration),
-			ntohs(payload->iteration), LOOPBACK_MODE(efx));
+		netif_err(efx, drv, efx->net_dev,
+			  "saw RX packet from iteration %d (wanted %d) in "
+			  "%s loopback test\n", ntohs(received->iteration),
+			  ntohs(payload->iteration), LOOPBACK_MODE(efx));
 		goto err;
 	}
 
 	/* Increase correct RX count */
-	EFX_TRACE(efx, "got loopback RX in %s loopback test\n",
-		  LOOPBACK_MODE(efx));
+	netif_vdbg(efx, drv, efx->net_dev,
+		   "got loopback RX in %s loopback test\n", LOOPBACK_MODE(efx));
 
 	atomic_inc(&state->rx_good);
 	return;
@@ -312,10 +323,10 @@ void efx_loopback_rx_packet(struct efx_nic *efx,
  err:
 #ifdef EFX_ENABLE_DEBUG
 	if (atomic_read(&state->rx_bad) == 0) {
-		EFX_ERR(efx, "received packet:\n");
+		netif_err(efx, drv, efx->net_dev, "received packet:\n");
 		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
 			       buf_ptr, pkt_len, 0);
-		EFX_ERR(efx, "expected packet:\n");
+		netif_err(efx, drv, efx->net_dev, "expected packet:\n");
 		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 0x10, 1,
 			       &state->payload, sizeof(state->payload), 0);
 	}
@@ -396,9 +407,11 @@ static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 			netif_tx_unlock_bh(efx->net_dev);
 
 		if (rc != NETDEV_TX_OK) {
-			EFX_ERR(efx, "TX queue %d could not transmit packet %d "
-				"of %d in %s loopback test\n", tx_queue->queue,
-				i + 1, state->packet_count, LOOPBACK_MODE(efx));
+			netif_err(efx, drv, efx->net_dev,
+				  "TX queue %d could not transmit packet %d of "
+				  "%d in %s loopback test\n", tx_queue->queue,
+				  i + 1, state->packet_count,
+				  LOOPBACK_MODE(efx));
 
 			/* Defer cleaning up the other skbs for the caller */
 			kfree_skb(skb);
@@ -454,20 +467,22 @@ static int efx_end_loopback(struct efx_tx_queue *tx_queue,
 		/* Don't free the skbs; they will be picked up on TX
 		 * overflow or channel teardown.
 		 */
-		EFX_ERR(efx, "TX queue %d saw only %d out of an expected %d "
-			"TX completion events in %s loopback test\n",
-			tx_queue->queue, tx_done, state->packet_count,
-			LOOPBACK_MODE(efx));
+		netif_err(efx, drv, efx->net_dev,
+			  "TX queue %d saw only %d out of an expected %d "
+			  "TX completion events in %s loopback test\n",
+			  tx_queue->queue, tx_done, state->packet_count,
+			  LOOPBACK_MODE(efx));
 		rc = -ETIMEDOUT;
 		/* Allow to fall through so we see the RX errors as well */
 	}
 
 	/* We may always be up to a flush away from our desired packet total */
 	if (rx_good != state->packet_count) {
-		EFX_LOG(efx, "TX queue %d saw only %d out of an expected %d "
-			"received packets in %s loopback test\n",
-			tx_queue->queue, rx_good, state->packet_count,
-			LOOPBACK_MODE(efx));
+		netif_dbg(efx, drv, efx->net_dev,
+			  "TX queue %d saw only %d out of an expected %d "
+			  "received packets in %s loopback test\n",
+			  tx_queue->queue, rx_good, state->packet_count,
+			  LOOPBACK_MODE(efx));
 		rc = -ETIMEDOUT;
 		/* Fall through */
 	}
@@ -499,9 +514,10 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 			return -ENOMEM;
 		state->flush = false;
 
-		EFX_LOG(efx, "TX queue %d testing %s loopback with %d "
-			"packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
-			state->packet_count);
+		netif_dbg(efx, drv, efx->net_dev,
+			  "TX queue %d testing %s loopback with %d packets\n",
+			  tx_queue->queue, LOOPBACK_MODE(efx),
+			  state->packet_count);
 
 		efx_iterate_state(efx);
 		begin_rc = efx_begin_loopback(tx_queue);
@@ -525,9 +541,10 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		}
 	}
 
-	EFX_LOG(efx, "TX queue %d passed %s loopback test with a burst length "
-		"of %d packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
-		state->packet_count);
+	netif_dbg(efx, drv, efx->net_dev,
+		  "TX queue %d passed %s loopback test with a burst length "
+		  "of %d packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
+		  state->packet_count);
 
 	return 0;
 }
@@ -602,15 +619,17 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 		rc = __efx_reconfigure_port(efx);
 		mutex_unlock(&efx->mac_lock);
 		if (rc) {
-			EFX_ERR(efx, "unable to move into %s loopback\n",
-				LOOPBACK_MODE(efx));
+			netif_err(efx, drv, efx->net_dev,
+				  "unable to move into %s loopback\n",
+				  LOOPBACK_MODE(efx));
 			goto out;
 		}
 
 		rc = efx_wait_for_link(efx);
 		if (rc) {
-			EFX_ERR(efx, "loopback %s never came up\n",
-				LOOPBACK_MODE(efx));
+			netif_err(efx, drv, efx->net_dev,
+				  "loopback %s never came up\n",
+				  LOOPBACK_MODE(efx));
 			goto out;
 		}
 
@@ -718,7 +737,8 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 		rc_reset = rc;
 
 	if (rc_reset) {
-		EFX_ERR(efx, "Unable to recover from chip test\n");
+		netif_err(efx, drv, efx->net_dev,
+			  "Unable to recover from chip test\n");
 		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
 		return rc_reset;
 	}
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index f2b1e61..59d1dc6 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -118,10 +118,11 @@ static int siena_probe_port(struct efx_nic *efx)
 				  MC_CMD_MAC_NSTATS * sizeof(u64));
 	if (rc)
 		return rc;
-	EFX_LOG(efx, "stats buffer at %llx (virt %p phys %llx)\n",
-		(u64)efx->stats_buffer.dma_addr,
-		efx->stats_buffer.addr,
-		(u64)virt_to_phys(efx->stats_buffer.addr));
+	netif_dbg(efx, probe, efx->net_dev,
+		  "stats buffer at %llx (virt %p phys %llx)\n",
+		  (u64)efx->stats_buffer.dma_addr,
+		  efx->stats_buffer.addr,
+		  (u64)virt_to_phys(efx->stats_buffer.addr));
 
 	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 1);
 
@@ -216,7 +217,8 @@ static int siena_probe_nic(struct efx_nic *efx)
 	efx->nic_data = nic_data;
 
 	if (efx_nic_fpga_ver(efx) != 0) {
-		EFX_ERR(efx, "Siena FPGA not supported\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "Siena FPGA not supported\n");
 		rc = -ENODEV;
 		goto fail1;
 	}
@@ -233,8 +235,8 @@ static int siena_probe_nic(struct efx_nic *efx)
 
 	rc = efx_mcdi_fwver(efx, &nic_data->fw_version, &nic_data->fw_build);
 	if (rc) {
-		EFX_ERR(efx, "Failed to read MCPU firmware version - "
-			"rc %d\n", rc);
+		netif_err(efx, probe, efx->net_dev,
+			  "Failed to read MCPU firmware version - rc %d\n", rc);
 		goto fail1; /* MCPU absent? */
 	}
 
@@ -242,17 +244,19 @@ static int siena_probe_nic(struct efx_nic *efx)
 	 * filter settings. We must do this before we reset the NIC */
 	rc = efx_mcdi_drv_attach(efx, true, &already_attached);
 	if (rc) {
-		EFX_ERR(efx, "Unable to register driver with MCPU\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "Unable to register driver with MCPU\n");
 		goto fail2;
 	}
 	if (already_attached)
 		/* Not a fatal error */
-		EFX_ERR(efx, "Host already registered with MCPU\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "Host already registered with MCPU\n");
 
 	/* Now we can reset the NIC */
 	rc = siena_reset_hw(efx, RESET_TYPE_ALL);
 	if (rc) {
-		EFX_ERR(efx, "failed to reset NIC\n");
+		netif_err(efx, probe, efx->net_dev, "failed to reset NIC\n");
 		goto fail3;
 	}
 
@@ -264,15 +268,17 @@ static int siena_probe_nic(struct efx_nic *efx)
 		goto fail4;
 	BUG_ON(efx->irq_status.dma_addr & 0x0f);
 
-	EFX_LOG(efx, "INT_KER at %llx (virt %p phys %llx)\n",
-		(unsigned long long)efx->irq_status.dma_addr,
-		efx->irq_status.addr,
-		(unsigned long long)virt_to_phys(efx->irq_status.addr));
+	netif_dbg(efx, probe, efx->net_dev,
+		  "INT_KER at %llx (virt %p phys %llx)\n",
+		  (unsigned long long)efx->irq_status.dma_addr,
+		  efx->irq_status.addr,
+		  (unsigned long long)virt_to_phys(efx->irq_status.addr));
 
 	/* Read in the non-volatile configuration */
 	rc = siena_probe_nvconfig(efx);
 	if (rc == -EINVAL) {
-		EFX_ERR(efx, "NVRAM is invalid therefore using defaults\n");
+		netif_err(efx, probe, efx->net_dev,
+			  "NVRAM is invalid therefore using defaults\n");
 		efx->phy_type = PHY_TYPE_NONE;
 		efx->mdio.prtad = MDIO_PRTAD_NONE;
 	} else if (rc) {
@@ -344,7 +350,8 @@ static int siena_init_nic(struct efx_nic *efx)
 
 	if (efx_nic_rx_xoff_thresh >= 0 || efx_nic_rx_xon_thresh >= 0)
 		/* No MCDI operation has been defined to set thresholds */
-		EFX_ERR(efx, "ignoring RX flow control thresholds\n");
+		netif_err(efx, hw, efx->net_dev,
+			  "ignoring RX flow control thresholds\n");
 
 	/* Enable event logging */
 	rc = efx_mcdi_log_ctrl(efx, true, false, 0);
@@ -565,7 +572,8 @@ static int siena_set_wol(struct efx_nic *efx, u32 type)
 
 	return 0;
  fail:
-	EFX_ERR(efx, "%s failed: type=%d rc=%d\n", __func__, type, rc);
+	netif_err(efx, hw, efx->net_dev, "%s failed: type=%d rc=%d\n",
+		  __func__, type, rc);
 	return rc;
 }
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index f21efe7..6791be9 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -228,7 +228,8 @@ int sft9001_wait_boot(struct efx_nic *efx)
 		boot_stat = efx_mdio_read(efx, MDIO_MMD_PCS,
 					  PCS_BOOT_STATUS_REG);
 		if (boot_stat >= 0) {
-			EFX_LOG(efx, "PHY boot status = %#x\n", boot_stat);
+			netif_dbg(efx, hw, efx->net_dev,
+				  "PHY boot status = %#x\n", boot_stat);
 			switch (boot_stat &
 				((1 << PCS_BOOT_FATAL_ERROR_LBN) |
 				 (3 << PCS_BOOT_PROGRESS_LBN) |
@@ -463,10 +464,11 @@ static void sfx7101_check_bad_lp(struct efx_nic *efx, bool link_ok)
 			reg |= PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN;
 		} else {
 			reg |= PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN;
-			EFX_ERR(efx, "appears to be plugged into a port"
-				" that is not 10GBASE-T capable. The PHY"
-				" supports 10GBASE-T ONLY, so no link can"
-				" be established\n");
+			netif_err(efx, link, efx->net_dev,
+				  "appears to be plugged into a port"
+				  " that is not 10GBASE-T capable. The PHY"
+				  " supports 10GBASE-T ONLY, so no link can"
+				  " be established\n");
 		}
 		efx_mdio_write(efx, MDIO_MMD_PMAPMD,
 			       PMA_PMD_LED_OVERR_REG, reg);
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 6bb12a8..c6942da 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -42,7 +42,7 @@ void efx_stop_queue(struct efx_channel *channel)
 		return;
 
 	spin_lock_bh(&channel->tx_stop_lock);
-	EFX_TRACE(efx, "stop TX queue\n");
+	netif_vdbg(efx, tx_queued, efx->net_dev, "stop TX queue\n");
 
 	atomic_inc(&channel->tx_stop_count);
 	netif_tx_stop_queue(
@@ -64,7 +64,7 @@ void efx_wake_queue(struct efx_channel *channel)
 	local_bh_disable();
 	if (atomic_dec_and_lock(&channel->tx_stop_count,
 				&channel->tx_stop_lock)) {
-		EFX_TRACE(efx, "waking TX queue\n");
+		netif_vdbg(efx, tx_queued, efx->net_dev, "waking TX queue\n");
 		netif_tx_wake_queue(
 			netdev_get_tx_queue(
 				efx->net_dev,
@@ -94,8 +94,9 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 	if (buffer->skb) {
 		dev_kfree_skb_any((struct sk_buff *) buffer->skb);
 		buffer->skb = NULL;
-		EFX_TRACE(tx_queue->efx, "TX queue %d transmission id %x "
-			  "complete\n", tx_queue->queue, read_ptr);
+		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
+			   "TX queue %d transmission id %x complete\n",
+			   tx_queue->queue, tx_queue->read_count);
 	}
 }
 
@@ -300,9 +301,10 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	return NETDEV_TX_OK;
 
  pci_err:
-	EFX_ERR_RL(efx, " TX queue %d could not map skb with %d bytes %d "
-		   "fragments for DMA\n", tx_queue->queue, skb->len,
-		   skb_shinfo(skb)->nr_frags + 1);
+	netif_err(efx, tx_err, efx->net_dev,
+		  " TX queue %d could not map skb with %d bytes %d "
+		  "fragments for DMA\n", tx_queue->queue, skb->len,
+		  skb_shinfo(skb)->nr_frags + 1);
 
 	/* Mark the packet as transmitted, and free the SKB ourselves */
 	dev_kfree_skb_any(skb);
@@ -354,9 +356,9 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 	while (read_ptr != stop_index) {
 		struct efx_tx_buffer *buffer = &tx_queue->buffer[read_ptr];
 		if (unlikely(buffer->len == 0)) {
-			EFX_ERR(tx_queue->efx, "TX queue %d spurious TX "
-				"completion id %x\n", tx_queue->queue,
-				read_ptr);
+			netif_err(efx, tx_err, efx->net_dev,
+				  "TX queue %d spurious TX completion id %x\n",
+				  tx_queue->queue, read_ptr);
 			efx_schedule_reset(efx, RESET_TYPE_TX_SKIP);
 			return;
 		}
@@ -431,7 +433,8 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 	unsigned int txq_size;
 	int i, rc;
 
-	EFX_LOG(efx, "creating TX queue %d\n", tx_queue->queue);
+	netif_dbg(efx, probe, efx->net_dev, "creating TX queue %d\n",
+		  tx_queue->queue);
 
 	/* Allocate software ring */
 	txq_size = EFX_TXQ_SIZE * sizeof(*tx_queue->buffer);
@@ -456,7 +459,8 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 
 void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 {
-	EFX_LOG(tx_queue->efx, "initialising TX queue %d\n", tx_queue->queue);
+	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
+		  "initialising TX queue %d\n", tx_queue->queue);
 
 	tx_queue->insert_count = 0;
 	tx_queue->write_count = 0;
@@ -488,7 +492,8 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 
 void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 {
-	EFX_LOG(tx_queue->efx, "shutting down TX queue %d\n", tx_queue->queue);
+	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
+		  "shutting down TX queue %d\n", tx_queue->queue);
 
 	/* Flush TX queue, remove descriptor ring */
 	efx_nic_fini_tx(tx_queue);
@@ -507,7 +512,8 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 {
-	EFX_LOG(tx_queue->efx, "destroying TX queue %d\n", tx_queue->queue);
+	netif_dbg(tx_queue->efx, drv, tx_queue->efx->net_dev,
+		  "destroying TX queue %d\n", tx_queue->queue);
 	efx_nic_remove_tx(tx_queue);
 
 	kfree(tx_queue->buffer);
@@ -639,8 +645,8 @@ static int efx_tsoh_block_alloc(struct efx_tx_queue *tx_queue)
 
 	base_kva = pci_alloc_consistent(pci_dev, PAGE_SIZE, &dma_addr);
 	if (base_kva == NULL) {
-		EFX_ERR(tx_queue->efx, "Unable to allocate page for TSO"
-			" headers\n");
+		netif_err(tx_queue->efx, tx_err, tx_queue->efx->net_dev,
+			  "Unable to allocate page for TSO headers\n");
 		return -ENOMEM;
 	}
 
@@ -1124,7 +1130,8 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	return NETDEV_TX_OK;
 
  mem_err:
-	EFX_ERR(efx, "Out of memory for TSO headers, or PCI mapping error\n");
+	netif_err(efx, tx_err, efx->net_dev,
+		  "Out of memory for TSO headers, or PCI mapping error\n");
 	dev_kfree_skb_any(skb);
 	goto unwind;
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

