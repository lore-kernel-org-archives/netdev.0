From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 17/52] sfc: Use explicit bool for boolean variables, parameters and return values
Date: Mon, 1 Sep 2008 12:46:50 +0100
Message-ID: <20080901114648.GK7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:35105 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757355AbYIALqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:53 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace (cond ? 1 : 0) with cond or !!cond as appropriate, and
(cond ? 0 : 1) with !cond.

Remove some redundant boolean temporaries.

Rename one field that looks like a flag but isn't.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c      |   12 ++++----
 drivers/net/sfc/efx.c         |   47 ++++++++++++++----------------
 drivers/net/sfc/efx.h         |    6 ++--
 drivers/net/sfc/enum.h        |    9 ++---
 drivers/net/sfc/ethtool.c     |    8 ++--
 drivers/net/sfc/falcon.c      |   50 +++++++++++++++++---------------
 drivers/net/sfc/falcon.h      |    2 +-
 drivers/net/sfc/falcon_xmac.c |   63 ++++++++++++++++++++---------------------
 drivers/net/sfc/mdio_10g.c    |   12 +++----
 drivers/net/sfc/mdio_10g.h    |   11 ++++---
 drivers/net/sfc/net_driver.h  |   36 +++++++++++-----------
 drivers/net/sfc/phy.h         |    2 +-
 drivers/net/sfc/rx.c          |   14 ++++----
 drivers/net/sfc/rx.h          |    2 +-
 drivers/net/sfc/selftest.c    |   15 +++++----
 drivers/net/sfc/tenxpress.c   |   28 +++++++++---------
 drivers/net/sfc/tx.c          |   32 ++++++++++----------
 drivers/net/sfc/xfp_phy.c     |    4 +-
 18 files changed, 175 insertions(+), 178 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index d3d3dd0..99e6023 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -31,23 +31,23 @@ static void blink_led_timer(unsigned long context)
 		mod_timer(&bl->timer, jiffies + BLINK_INTERVAL);
 }
 
-static void board_blink(struct efx_nic *efx, int blink)
+static void board_blink(struct efx_nic *efx, bool blink)
 {
 	struct efx_blinker *blinker = &efx->board_info.blinker;
 
 	/* The rtnl mutex serialises all ethtool ioctls, so
 	 * nothing special needs doing here. */
 	if (blink) {
-		blinker->resubmit = 1;
-		blinker->state = 0;
+		blinker->resubmit = true;
+		blinker->state = false;
 		setup_timer(&blinker->timer, blink_led_timer,
 			    (unsigned long)efx);
 		mod_timer(&blinker->timer, jiffies + BLINK_INTERVAL);
 	} else {
-		blinker->resubmit = 0;
+		blinker->resubmit = false;
 		if (blinker->timer.function)
 			del_timer_sync(&blinker->timer);
-		efx->board_info.set_fault_led(efx, 0);
+		efx->board_info.set_fault_led(efx, false);
 	}
 }
 
@@ -78,7 +78,7 @@ static int sfe4002_init_leds(struct efx_nic *efx)
 	return 0;
 }
 
-static void sfe4002_fault_led(struct efx_nic *efx, int state)
+static void sfe4002_fault_led(struct efx_nic *efx, bool state)
 {
 	xfp_set_led(efx, SFE4002_FAULT_LED, state ? QUAKE_LED_ON :
 			QUAKE_LED_OFF);
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d3b76bd..7eb11d3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -51,7 +51,7 @@ static struct workqueue_struct *refill_workqueue;
  * This sets the default for new devices.  It can be controlled later
  * using ethtool.
  */
-static int lro = 1;
+static int lro = true;
 module_param(lro, int, 0644);
 MODULE_PARM_DESC(lro, "Large receive offload acceleration");
 
@@ -64,7 +64,7 @@ MODULE_PARM_DESC(lro, "Large receive offload acceleration");
  * This is forced to 0 for MSI interrupt mode as the interrupt vector
  * is not written
  */
-static unsigned int separate_tx_and_rx_channels = 1;
+static unsigned int separate_tx_and_rx_channels = true;
 
 /* This is the weight assigned to each of the (per-channel) virtual
  * NAPI devices.
@@ -80,7 +80,7 @@ unsigned int efx_monitor_interval = 1 * HZ;
 /* This controls whether or not the hardware monitor will trigger a
  * reset when it detects an error condition.
  */
-static unsigned int monitor_reset = 1;
+static unsigned int monitor_reset = true;
 
 /* This controls whether or not the driver will initialise devices
  * with invalid MAC addresses stored in the EEPROM or flash.  If true,
@@ -202,7 +202,7 @@ static inline void efx_channel_processed(struct efx_channel *channel)
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we acknowledge the events we've seen.  Make sure
 	 * it's cleared before then. */
-	channel->work_pending = 0;
+	channel->work_pending = false;
 	smp_wmb();
 
 	falcon_eventq_read_ack(channel);
@@ -431,8 +431,8 @@ static void efx_start_channel(struct efx_channel *channel)
 	/* The interrupt handler for this channel may set work_pending
 	 * as soon as we enable it.  Make sure it's cleared before
 	 * then.  Similarly, make sure it sees the enabled flag set. */
-	channel->work_pending = 0;
-	channel->enabled = 1;
+	channel->work_pending = false;
+	channel->enabled = true;
 	smp_wmb();
 
 	napi_enable(&channel->napi_str);
@@ -455,7 +455,7 @@ static void efx_stop_channel(struct efx_channel *channel)
 
 	EFX_LOG(channel->efx, "stop chan %d\n", channel->channel);
 
-	channel->enabled = 0;
+	channel->enabled = false;
 	napi_disable(&channel->napi_str);
 
 	/* Ensure that any worker threads have exited or will be no-ops */
@@ -525,8 +525,6 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay)
  */
 static void efx_link_status_changed(struct efx_nic *efx)
 {
-	int carrier_ok;
-
 	/* SFC Bug 5356: A net_dev notifier is registered, so we must ensure
 	 * that no events are triggered between unregister_netdev() and the
 	 * driver unloading. A more general condition is that NETDEV_CHANGE
@@ -534,8 +532,7 @@ static void efx_link_status_changed(struct efx_nic *efx)
 	if (!netif_running(efx->net_dev))
 		return;
 
-	carrier_ok = netif_carrier_ok(efx->net_dev) ? 1 : 0;
-	if (efx->link_up != carrier_ok) {
+	if (efx->link_up != netif_carrier_ok(efx->net_dev)) {
 		efx->n_link_state_changes++;
 
 		if (efx->link_up)
@@ -660,7 +657,7 @@ static int efx_init_port(struct efx_nic *efx)
 	if (rc)
 		return rc;
 
-	efx->port_initialized = 1;
+	efx->port_initialized = true;
 
 	/* Reconfigure port to program MAC registers */
 	falcon_reconfigure_xmac(efx);
@@ -677,7 +674,7 @@ static void efx_start_port(struct efx_nic *efx)
 	BUG_ON(efx->port_enabled);
 
 	mutex_lock(&efx->mac_lock);
-	efx->port_enabled = 1;
+	efx->port_enabled = true;
 	__efx_reconfigure_port(efx);
 	mutex_unlock(&efx->mac_lock);
 }
@@ -691,7 +688,7 @@ static void efx_stop_port(struct efx_nic *efx)
 	EFX_LOG(efx, "stop port\n");
 
 	mutex_lock(&efx->mac_lock);
-	efx->port_enabled = 0;
+	efx->port_enabled = false;
 	mutex_unlock(&efx->mac_lock);
 
 	/* Serialise against efx_set_multicast_list() */
@@ -709,9 +706,9 @@ static void efx_fini_port(struct efx_nic *efx)
 		return;
 
 	falcon_fini_xmac(efx);
-	efx->port_initialized = 0;
+	efx->port_initialized = false;
 
-	efx->link_up = 0;
+	efx->link_up = false;
 	efx_link_status_changed(efx);
 }
 
@@ -866,7 +863,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 
 		if (rc == 0) {
 			for (i = 0; i < efx->rss_queues; i++) {
-				efx->channel[i].has_interrupt = 1;
+				efx->channel[i].has_interrupt = true;
 				efx->channel[i].irq = xentries[i].vector;
 			}
 		} else {
@@ -882,7 +879,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		rc = pci_enable_msi(efx->pci_dev);
 		if (rc == 0) {
 			efx->channel[0].irq = efx->pci_dev->irq;
-			efx->channel[0].has_interrupt = 1;
+			efx->channel[0].has_interrupt = true;
 		} else {
 			EFX_ERR(efx, "could not enable MSI\n");
 			efx->interrupt_mode = EFX_INT_MODE_LEGACY;
@@ -894,7 +891,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		efx->rss_queues = 1;
 		/* Every channel is interruptible */
 		for (i = 0; i < EFX_MAX_CHANNELS; i++)
-			efx->channel[i].has_interrupt = 1;
+			efx->channel[i].has_interrupt = true;
 		efx->legacy_irq = efx->pci_dev->irq;
 	}
 }
@@ -935,7 +932,7 @@ static void efx_select_used(struct efx_nic *efx)
 		rx_queue = &efx->rx_queue[i];
 
 		if (i < efx->rss_queues) {
-			rx_queue->used = 1;
+			rx_queue->used = true;
 			/* If we allow multiple RX queues per channel
 			 * we need to decide that here
 			 */
@@ -1462,13 +1459,13 @@ static void efx_set_multicast_list(struct net_device *net_dev)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct dev_mc_list *mc_list = net_dev->mc_list;
 	union efx_multicast_hash *mc_hash = &efx->multicast_hash;
-	int promiscuous;
+	bool promiscuous;
 	u32 crc;
 	int bit;
 	int i;
 
 	/* Set per-MAC promiscuity flag and reconfigure MAC if necessary */
-	promiscuous = (net_dev->flags & IFF_PROMISC) ? 1 : 0;
+	promiscuous = !!(net_dev->flags & IFF_PROMISC);
 	if (efx->promiscuous != promiscuous) {
 		efx->promiscuous = promiscuous;
 		/* Close the window between efx_stop_port() and efx_flush_all()
@@ -1801,7 +1798,7 @@ int efx_port_dummy_op_int(struct efx_nic *efx)
 	return 0;
 }
 void efx_port_dummy_op_void(struct efx_nic *efx) {}
-void efx_port_dummy_op_blink(struct efx_nic *efx, int blink) {}
+void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink) {}
 
 static struct efx_phy_operations efx_dummy_phy_operations = {
 	.init		 = efx_port_dummy_op_int,
@@ -1855,7 +1852,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	efx->board_info = efx_dummy_board_info;
 
 	efx->net_dev = net_dev;
-	efx->rx_checksum_enabled = 1;
+	efx->rx_checksum_enabled = true;
 	spin_lock_init(&efx->netif_stop_lock);
 	spin_lock_init(&efx->stats_lock);
 	mutex_init(&efx->mac_lock);
@@ -1869,7 +1866,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		channel->efx = efx;
 		channel->channel = i;
 		channel->evqnum = i;
-		channel->work_pending = 0;
+		channel->work_pending = false;
 	}
 	for (i = 0; i < EFX_TX_QUEUE_COUNT; i++) {
 		tx_queue = &efx->tx_queue[i];
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 3b2f69f..29a1c58 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -28,7 +28,7 @@ extern void efx_wake_queue(struct efx_nic *efx);
 /* RX */
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
-			  unsigned int len, int checksummed, int discard);
+			  unsigned int len, bool checksummed, bool discard);
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay);
 
 /* Channels */
@@ -50,7 +50,7 @@ extern void efx_hex_dump(const u8 *, unsigned int, const char *);
 /* Dummy PHY ops for PHY drivers */
 extern int efx_port_dummy_op_int(struct efx_nic *efx);
 extern void efx_port_dummy_op_void(struct efx_nic *efx);
-extern void efx_port_dummy_op_blink(struct efx_nic *efx, int blink);
+extern void efx_port_dummy_op_blink(struct efx_nic *efx, bool blink);
 
 
 extern unsigned int efx_monitor_interval;
@@ -59,7 +59,7 @@ static inline void efx_schedule_channel(struct efx_channel *channel)
 {
 	EFX_TRACE(channel->efx, "channel %d scheduling NAPI poll on CPU%d\n",
 		  channel->channel, raw_smp_processor_id());
-	channel->work_pending = 1;
+	channel->work_pending = true;
 
 	netif_rx_schedule(channel->napi_dev, &channel->napi_str);
 }
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index c53290d..cec15db 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -52,12 +52,11 @@ extern const char *efx_loopback_mode_names[];
 #define LOOPBACK_MASK(_efx)			\
 	(1 << (_efx)->loopback_mode)
 
-#define LOOPBACK_INTERNAL(_efx)						\
-	((LOOPBACKS_10G_INTERNAL & LOOPBACK_MASK(_efx)) ? 1 : 0)
+#define LOOPBACK_INTERNAL(_efx)				\
+	(!!(LOOPBACKS_10G_INTERNAL & LOOPBACK_MASK(_efx)))
 
-#define LOOPBACK_OUT_OF(_from, _to, _mask)		\
-	(((LOOPBACK_MASK(_from) & (_mask)) &&		\
-	  ((LOOPBACK_MASK(_to) & (_mask)) == 0)) ? 1 : 0)
+#define LOOPBACK_OUT_OF(_from, _to, _mask)				\
+	((LOOPBACK_MASK(_from) & (_mask)) && !(LOOPBACK_MASK(_to) & (_mask)))
 
 /*****************************************************************************/
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index ccd82f1..6142c3a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -447,7 +447,7 @@ static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 enable)
 	/* No way to stop the hardware doing the checks; we just
 	 * ignore the result.
 	 */
-	efx->rx_checksum_enabled = (enable ? 1 : 0);
+	efx->rx_checksum_enabled = !!enable;
 
 	return 0;
 }
@@ -641,9 +641,9 @@ static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	pause->rx_pause = (efx->flow_control & EFX_FC_RX) ? 1 : 0;
-	pause->tx_pause = (efx->flow_control & EFX_FC_TX) ? 1 : 0;
-	pause->autoneg = (efx->flow_control & EFX_FC_AUTO) ? 1 : 0;
+	pause->rx_pause = !!(efx->flow_control & EFX_FC_RX);
+	pause->tx_pause = !!(efx->flow_control & EFX_FC_TX);
+	pause->autoneg = !!(efx->flow_control & EFX_FC_AUTO);
 }
 
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 8ee63da..fb06971 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -539,7 +539,7 @@ static int falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
 
 	if (EFX_WORKAROUND_11557(efx)) {
 		efx_oword_t reg;
-		int enabled;
+		bool enabled;
 
 		falcon_read_table(efx, &reg, efx->type->txd_ptr_tbl_base,
 				  tx_queue->queue);
@@ -644,8 +644,8 @@ int falcon_init_rx(struct efx_rx_queue *rx_queue)
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
 	int rc;
-	int is_b0 = falcon_rev(efx) >= FALCON_REV_B0;
-	int iscsi_digest_en = is_b0;
+	bool is_b0 = falcon_rev(efx) >= FALCON_REV_B0;
+	bool iscsi_digest_en = is_b0;
 
 	EFX_LOG(efx, "RX queue %d ring in special buffers %d-%d\n",
 		rx_queue->queue, rx_queue->rxd.index,
@@ -695,7 +695,8 @@ static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 	read_ptr = channel->eventq_read_ptr;
 	for (i = 0; i < FALCON_EVQ_SIZE; ++i) {
 		efx_qword_t *event = falcon_event(channel, read_ptr);
-		int ev_code, ev_sub_code, ev_queue, ev_failed;
+		int ev_code, ev_sub_code, ev_queue;
+		bool ev_failed;
 		if (!falcon_event_present(event))
 			break;
 
@@ -722,7 +723,7 @@ static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 
 	if (EFX_WORKAROUND_11557(efx)) {
 		efx_oword_t reg;
-		int enabled;
+		bool enabled;
 
 		falcon_read_table(efx, &reg, efx->type->rxd_ptr_tbl_base,
 				  rx_queue->queue);
@@ -851,15 +852,16 @@ static inline void falcon_handle_tx_event(struct efx_channel *channel,
 /* Detect errors included in the rx_evt_pkt_ok bit. */
 static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 				    const efx_qword_t *event,
-				    unsigned *rx_ev_pkt_ok,
-				    int *discard)
+				    bool *rx_ev_pkt_ok,
+				    bool *discard)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	unsigned rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
-	unsigned rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
-	unsigned rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
-	unsigned rx_ev_pkt_type, rx_ev_other_err, rx_ev_pause_frm;
-	unsigned rx_ev_ip_frag_err, rx_ev_hdr_type, rx_ev_mcast_pkt;
+	bool rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
+	bool rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
+	bool rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
+	bool rx_ev_other_err, rx_ev_pause_frm;
+	bool rx_ev_ip_frag_err, rx_ev_hdr_type, rx_ev_mcast_pkt;
+	unsigned rx_ev_pkt_type;
 
 	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, RX_EV_HDR_TYPE);
 	rx_ev_mcast_pkt = EFX_QWORD_FIELD(*event, RX_EV_MCAST_PKT);
@@ -954,9 +956,9 @@ static inline int falcon_handle_rx_event(struct efx_channel *channel,
 					 const efx_qword_t *event)
 {
 	unsigned int rx_ev_q_label, rx_ev_desc_ptr, rx_ev_byte_cnt;
-	unsigned int rx_ev_pkt_ok, rx_ev_hdr_type, rx_ev_mcast_pkt;
+	unsigned int rx_ev_hdr_type, rx_ev_mcast_pkt;
 	unsigned expected_ptr;
-	int discard = 0, checksummed;
+	bool rx_ev_pkt_ok, discard = false, checksummed;
 	struct efx_rx_queue *rx_queue;
 	struct efx_nic *efx = channel->efx;
 
@@ -985,7 +987,7 @@ static inline int falcon_handle_rx_event(struct efx_channel *channel,
 	} else {
 		falcon_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok,
 					&discard);
-		checksummed = 0;
+		checksummed = false;
 	}
 
 	/* Detect multicast packets that didn't match the filter */
@@ -995,7 +997,7 @@ static inline int falcon_handle_rx_event(struct efx_channel *channel,
 			EFX_QWORD_FIELD(*event, RX_EV_MCAST_HASH_MATCH);
 
 		if (unlikely(!rx_ev_mcast_hash_match))
-			discard = 1;
+			discard = true;
 	}
 
 	/* Handle received packet */
@@ -1010,23 +1012,23 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 				       efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
-	int is_phy_event = 0, handled = 0;
+	bool is_phy_event = false, handled = false;
 
 	/* Check for interrupt on either port.  Some boards have a
 	 * single PHY wired to the interrupt line for port 1. */
 	if (EFX_QWORD_FIELD(*event, G_PHY0_INTR) ||
 	    EFX_QWORD_FIELD(*event, G_PHY1_INTR) ||
 	    EFX_QWORD_FIELD(*event, XG_PHY_INTR))
-		is_phy_event = 1;
+		is_phy_event = true;
 
 	if ((falcon_rev(efx) >= FALCON_REV_B0) &&
 	    EFX_OWORD_FIELD(*event, XG_MNT_INTR_B0))
-		is_phy_event = 1;
+		is_phy_event = true;
 
 	if (is_phy_event) {
 		efx->phy_op->clear_interrupt(efx);
 		queue_work(efx->workqueue, &efx->reconfigure_work);
-		handled = 1;
+		handled = true;
 	}
 
 	if (EFX_QWORD_FIELD_VER(efx, *event, RX_RECOVERY)) {
@@ -1036,7 +1038,7 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 		atomic_inc(&efx->rx_reset);
 		efx_schedule_reset(efx, EFX_WORKAROUND_6555(efx) ?
 				   RESET_TYPE_RX_RECOVERY : RESET_TYPE_DISABLE);
-		handled = 1;
+		handled = true;
 	}
 
 	if (!handled)
@@ -1756,7 +1758,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 	int link_speed;
-	unsigned int tx_fc;
+	bool tx_fc;
 
 	if (efx->link_options & GM_LPA_10000)
 		link_speed = 0x3;
@@ -1791,7 +1793,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	/* Transmission of pause frames when RX crosses the threshold is
 	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
 	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
-	tx_fc = (efx->flow_control & EFX_FC_TX) ? 1 : 0;
+	tx_fc = !!(efx->flow_control & EFX_FC_TX);
 	falcon_read(efx, &reg, RX_CFG_REG_KER);
 	EFX_SET_OWORD_FIELD_VER(efx, reg, RX_XOFF_MAC_EN, tx_fc);
 
@@ -2064,7 +2066,7 @@ int falcon_probe_port(struct efx_nic *efx)
 		return rc;
 
 	/* Set up GMII structure for PHY */
-	efx->mii.supports_gmii = 1;
+	efx->mii.supports_gmii = true;
 	falcon_init_mdio(&efx->mii);
 
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 492f9bc..a72f50e 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -65,7 +65,7 @@ extern int falcon_probe_port(struct efx_nic *efx);
 extern void falcon_remove_port(struct efx_nic *efx);
 
 /* MAC/PHY */
-extern int falcon_xaui_link_ok(struct efx_nic *efx);
+extern bool falcon_xaui_link_ok(struct efx_nic *efx);
 extern int falcon_dma_stats(struct efx_nic *efx,
 			    unsigned int done_offset);
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index ab114b4..be5a86f 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -70,7 +70,7 @@ static int falcon_reset_xmac(struct efx_nic *efx)
 	}
 
 	/* This often fails when DSP is disabled, ignore it */
-	if (sfe4001_phy_flash_cfg != 0)
+	if (sfe4001_phy_flash_cfg)
 		return 0;
 
 	EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
@@ -217,12 +217,12 @@ int falcon_reset_xaui(struct efx_nic *efx)
 	return rc;
 }
 
-static int falcon_xgmii_status(struct efx_nic *efx)
+static bool falcon_xgmii_status(struct efx_nic *efx)
 {
 	efx_dword_t reg;
 
 	if (falcon_rev(efx) < FALCON_REV_B0)
-		return 1;
+		return true;
 
 	/* The ISR latches, so clear it and re-read */
 	falcon_xmac_readl(efx, &reg, XM_MGT_INT_REG_MAC_B0);
@@ -231,13 +231,13 @@ static int falcon_xgmii_status(struct efx_nic *efx)
 	if (EFX_DWORD_FIELD(reg, XM_LCLFLT) ||
 	    EFX_DWORD_FIELD(reg, XM_RMTFLT)) {
 		EFX_INFO(efx, "MGT_INT: "EFX_DWORD_FMT"\n", EFX_DWORD_VAL(reg));
-		return 0;
+		return false;
 	}
 
-	return 1;
+	return true;
 }
 
-static void falcon_mask_status_intr(struct efx_nic *efx, int enable)
+static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 {
 	efx_dword_t reg;
 
@@ -274,7 +274,7 @@ int falcon_init_xmac(struct efx_nic *efx)
 	if (rc)
 		goto fail2;
 
-	falcon_mask_status_intr(efx, 1);
+	falcon_mask_status_intr(efx, true);
 	return 0;
 
  fail2:
@@ -283,13 +283,14 @@ int falcon_init_xmac(struct efx_nic *efx)
 	return rc;
 }
 
-int falcon_xaui_link_ok(struct efx_nic *efx)
+bool falcon_xaui_link_ok(struct efx_nic *efx)
 {
 	efx_dword_t reg;
-	int align_done, sync_status, link_ok = 0;
+	bool align_done, link_ok = false;
+	int sync_status;
 
 	if (LOOPBACK_INTERNAL(efx))
-		return 1;
+		return true;
 
 	/* Read link status */
 	falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
@@ -297,7 +298,7 @@ int falcon_xaui_link_ok(struct efx_nic *efx)
 	align_done = EFX_DWORD_FIELD(reg, XX_ALIGN_DONE);
 	sync_status = EFX_DWORD_FIELD(reg, XX_SYNC_STAT);
 	if (align_done && (sync_status == XX_SYNC_STAT_DECODE_SYNCED))
-		link_ok = 1;
+		link_ok = true;
 
 	/* Clear link status ready for next read */
 	EFX_SET_DWORD_FIELD(reg, XX_COMMA_DET, XX_COMMA_DET_RESET);
@@ -309,8 +310,7 @@ int falcon_xaui_link_ok(struct efx_nic *efx)
 	 * (error conditions from the wire side propoagate back through
 	 * the phy to the xaui side). */
 	if (efx->link_up && link_ok) {
-		int has_phyxs = efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS);
-		if (has_phyxs)
+		if (efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS))
 			link_ok = mdio_clause45_phyxgxs_lane_sync(efx);
 	}
 
@@ -326,7 +326,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 {
 	unsigned int max_frame_len;
 	efx_dword_t reg;
-	int rx_fc = (efx->flow_control & EFX_FC_RX) ? 1 : 0;
+	bool rx_fc = !!(efx->flow_control & EFX_FC_RX);
 
 	/* Configure MAC  - cut-thru mode is hard wired on */
 	EFX_POPULATE_DWORD_3(reg,
@@ -365,7 +365,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 
 	EFX_POPULATE_DWORD_2(reg,
 			     XM_PAUSE_TIME, 0xfffe, /* MAX PAUSE TIME */
-			     XM_DIS_FCNTL, rx_fc ? 0 : 1);
+			     XM_DIS_FCNTL, !rx_fc);
 	falcon_xmac_writel(efx, &reg, XM_FC_REG_MAC);
 
 	/* Set MAC address */
@@ -384,16 +384,15 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 {
 	efx_dword_t reg;
-	int xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS) ? 1 : 0;
-	int xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI) ? 1 : 0;
-	int xgmii_loopback =
-		(efx->loopback_mode == LOOPBACK_XGMII) ? 1 : 0;
+	bool xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS);
+	bool xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI);
+	bool xgmii_loopback = (efx->loopback_mode == LOOPBACK_XGMII);
 
 	/* XGXS block is flaky and will need to be reset if moving
 	 * into our out of XGMII, XGXS or XAUI loopbacks. */
 	if (EFX_WORKAROUND_5147(efx)) {
-		int old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
-		int reset_xgxs;
+		bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
+		bool reset_xgxs;
 
 		falcon_xmac_readl(efx, &reg, XX_CORE_STAT_REG_MAC);
 		old_xgxs_loopback = EFX_DWORD_FIELD(reg, XX_XGXS_LB_EN);
@@ -438,7 +437,7 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 
 /* Try and bring the Falcon side of the Falcon-Phy XAUI link fails
  * to come back up. Bash it until it comes back up */
-static int falcon_check_xaui_link_up(struct efx_nic *efx)
+static bool falcon_check_xaui_link_up(struct efx_nic *efx)
 {
 	int max_tries, tries;
 	tries = EFX_WORKAROUND_5147(efx) ? 5 : 1;
@@ -446,11 +445,11 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
 
 	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
 	    (efx->phy_type == PHY_TYPE_NONE))
-		return 0;
+		return false;
 
 	while (tries) {
 		if (falcon_xaui_link_ok(efx))
-			return 1;
+			return true;
 
 		EFX_LOG(efx, "%s Clobbering XAUI (%d tries left).\n",
 			__func__, tries);
@@ -461,14 +460,14 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
 
 	EFX_LOG(efx, "Failed to bring XAUI link back up in %d tries!\n",
 		max_tries);
-	return 0;
+	return false;
 }
 
 void falcon_reconfigure_xmac(struct efx_nic *efx)
 {
-	int xaui_link_ok;
+	bool xaui_link_ok;
 
-	falcon_mask_status_intr(efx, 0);
+	falcon_mask_status_intr(efx, false);
 
 	falcon_deconfigure_mac_wrapper(efx);
 
@@ -484,7 +483,7 @@ void falcon_reconfigure_xmac(struct efx_nic *efx)
 	xaui_link_ok = falcon_check_xaui_link_up(efx);
 
 	if (xaui_link_ok && efx->link_up)
-		falcon_mask_status_intr(efx, 1);
+		falcon_mask_status_intr(efx, true);
 }
 
 void falcon_fini_xmac(struct efx_nic *efx)
@@ -563,14 +562,14 @@ void falcon_update_stats_xmac(struct efx_nic *efx)
 
 int falcon_check_xmac(struct efx_nic *efx)
 {
-	unsigned xaui_link_ok;
+	bool xaui_link_ok;
 	int rc;
 
 	if ((efx->loopback_mode == LOOPBACK_NETWORK) ||
 	    (efx->phy_type == PHY_TYPE_NONE))
 		return 0;
 
-	falcon_mask_status_intr(efx, 0);
+	falcon_mask_status_intr(efx, false);
 	xaui_link_ok = falcon_xaui_link_ok(efx);
 
 	if (EFX_WORKAROUND_5147(efx) && !xaui_link_ok)
@@ -581,7 +580,7 @@ int falcon_check_xmac(struct efx_nic *efx)
 
 	/* Unmask interrupt if everything was (and still is) ok */
 	if (xaui_link_ok && efx->link_up)
-		falcon_mask_status_intr(efx, 1);
+		falcon_mask_status_intr(efx, true);
 
 	return rc;
 }
@@ -622,7 +621,7 @@ int falcon_xmac_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 
 int falcon_xmac_set_pause(struct efx_nic *efx, enum efx_fc_type flow_control)
 {
-	int reset;
+	bool reset;
 
 	if (flow_control & EFX_FC_AUTO) {
 		EFX_LOG(efx, "10G does not support flow control "
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index c4f540e..4064946 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -159,20 +159,19 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 	return 0;
 }
 
-int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
+bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 {
 	int phy_id = efx->mii.phy_id;
 	int status;
-	int ok = 1;
+	bool ok = true;
 	int mmd = 0;
-	int good;
 
 	/* If the port is in loopback, then we should only consider a subset
 	 * of mmd's */
 	if (LOOPBACK_INTERNAL(efx))
-		return 1;
+		return true;
 	else if (efx->loopback_mode == LOOPBACK_NETWORK)
-		return 0;
+		return false;
 	else if (efx->loopback_mode == LOOPBACK_PHYXS)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS0_PHYXS |
 			      MDIO_MMDREG_DEVS0_PCS |
@@ -192,8 +191,7 @@ int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 			status = mdio_clause45_read(efx, phy_id,
 						    mmd, MDIO_MMDREG_STAT1);
 
-			good = status & (1 << MDIO_MMDREG_STAT1_LINK_LBN);
-			ok = ok && good;
+			ok = ok && (status & (1 << MDIO_MMDREG_STAT1_LINK_LBN));
 		}
 		mmd_mask = (mmd_mask >> 1);
 		mmd++;
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 3bb6b55..19c42ea 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -199,16 +199,17 @@ static inline u32 mdio_clause45_read_id(struct efx_nic *efx, int mmd)
 	return (id_hi << 16) | (id_low);
 }
 
-static inline int mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx)
+static inline bool mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx)
 {
-	int i, sync, lane_status;
+	int i, lane_status;
+	bool sync;
 
 	for (i = 0; i < 2; ++i)
 		lane_status = mdio_clause45_read(efx, efx->mii.phy_id,
 						 MDIO_MMD_PHYXS,
 						 MDIO_PHYXS_LANE_STATE);
 
-	sync = (lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN)) != 0;
+	sync = !!(lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN));
 	if (!sync)
 		EFX_LOG(efx, "XGXS lane status: %x\n", lane_status);
 	return sync;
@@ -230,8 +231,8 @@ int mdio_clause45_check_mmds(struct efx_nic *efx,
 			     unsigned int mmd_mask, unsigned int fatal_mask);
 
 /* Check the link status of specified mmds in bit mask */
-extern int mdio_clause45_links_ok(struct efx_nic *efx,
-				  unsigned int mmd_mask);
+extern bool mdio_clause45_links_ok(struct efx_nic *efx,
+				   unsigned int mmd_mask);
 
 /* Generic transmit disable support though PMAPMD */
 extern void mdio_clause45_transmit_disable(struct efx_nic *efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 6369f92..1b92186 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -137,8 +137,8 @@ struct efx_tx_buffer {
 	struct efx_tso_header *tsoh;
 	dma_addr_t dma_addr;
 	unsigned short len;
-	unsigned char continuation;
-	unsigned char unmap_single;
+	bool continuation;
+	bool unmap_single;
 	unsigned short unmap_len;
 };
 
@@ -162,7 +162,7 @@ struct efx_tx_buffer {
  * @txd: The hardware descriptor ring
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both rings.
- * @stopped: Stopped flag.
+ * @stopped: Stopped count.
  *	Set if this TX queue is currently stopping its port.
  * @insert_count: Current insert pointer
  *	This is the number of buffers that have been added to the
@@ -265,7 +265,7 @@ struct efx_rx_buffer {
 struct efx_rx_queue {
 	struct efx_nic *efx;
 	int queue;
-	int used;
+	bool used;
 	struct efx_channel *channel;
 	struct efx_rx_buffer *buffer;
 	struct efx_special_buffer rxd;
@@ -359,13 +359,13 @@ struct efx_channel {
 	int evqnum;
 	int channel;
 	int used_flags;
-	int enabled;
+	bool enabled;
 	int irq;
-	unsigned int has_interrupt;
+	bool has_interrupt;
 	unsigned int irq_moderation;
 	struct net_device *napi_dev;
 	struct napi_struct napi_str;
-	int work_pending;
+	bool work_pending;
 	struct efx_special_buffer eventq;
 	unsigned int eventq_read_ptr;
 	unsigned int last_eventq_read_ptr;
@@ -388,7 +388,7 @@ struct efx_channel {
 	 * access with prefetches.
 	 */
 	struct efx_rx_buffer *rx_pkt;
-	int rx_pkt_csummed;
+	bool rx_pkt_csummed;
 
 };
 
@@ -401,8 +401,8 @@ struct efx_channel {
  */
 struct efx_blinker {
 	int led_num;
-	int state;
-	int resubmit;
+	bool state;
+	bool resubmit;
 	struct timer_list timer;
 };
 
@@ -430,8 +430,8 @@ struct efx_board {
 	 * have a separate init callback that happens later than
 	 * board init. */
 	int (*init_leds)(struct efx_nic *efx);
-	void (*set_fault_led) (struct efx_nic *efx, int state);
-	void (*blink) (struct efx_nic *efx, int start);
+	void (*set_fault_led) (struct efx_nic *efx, bool state);
+	void (*blink) (struct efx_nic *efx, bool start);
 	void (*fini) (struct efx_nic *nic);
 	struct efx_blinker blinker;
 	struct i2c_client *hwmon_client, *ioexp_client;
@@ -714,11 +714,11 @@ struct efx_nic {
 	struct falcon_nic_data *nic_data;
 
 	struct mutex mac_lock;
-	int port_enabled;
+	bool port_enabled;
 
-	int port_initialized;
+	bool port_initialized;
 	struct net_device *net_dev;
-	int rx_checksum_enabled;
+	bool rx_checksum_enabled;
 
 	atomic_t netif_stop_count;
 	spinlock_t netif_stop_lock;
@@ -734,13 +734,13 @@ struct efx_nic {
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mii_if_info mii;
-	unsigned tx_disabled;
+	bool tx_disabled;
 
-	int link_up;
+	bool link_up;
 	unsigned int link_options;
 	unsigned int n_link_state_changes;
 
-	int promiscuous;
+	bool promiscuous;
 	union efx_multicast_hash multicast_hash;
 	enum efx_fc_type flow_control;
 	struct work_struct reconfigure_work;
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 9d02c84..25bd18e 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -23,7 +23,7 @@ enum tenxpress_state {
 
 extern void tenxpress_set_state(struct efx_nic *efx,
 				enum tenxpress_state state);
-extern void tenxpress_phy_blink(struct efx_nic *efx, int blink);
+extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
 extern void tenxpress_crc_err(struct efx_nic *efx);
 
 /****************************************************************************
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 0d27dd3..17aa81e 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -508,8 +508,8 @@ void efx_rx_work(struct work_struct *data)
 
 static inline void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 					    struct efx_rx_buffer *rx_buf,
-					    int len, int *discard,
-					    int *leak_packet)
+					    int len, bool *discard,
+					    bool *leak_packet)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned max_len = rx_buf->len - efx->type->rx_buffer_padding;
@@ -520,7 +520,7 @@ static inline void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 	/* The packet must be discarded, but this is only a fatal error
 	 * if the caller indicated it was
 	 */
-	*discard = 1;
+	*discard = true;
 
 	if ((len > rx_buf->len) && EFX_WORKAROUND_8071(efx)) {
 		EFX_ERR_RL(efx, " RX queue %d seriously overlength "
@@ -621,11 +621,11 @@ static inline struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_buf,
 }
 
 void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
-		   unsigned int len, int checksummed, int discard)
+		   unsigned int len, bool checksummed, bool discard)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_rx_buffer *rx_buf;
-	int leak_packet = 0;
+	bool leak_packet = false;
 
 	rx_buf = efx_rx_buffer(rx_queue, index);
 	EFX_BUG_ON_PARANOID(!rx_buf->data);
@@ -683,11 +683,11 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 
 /* Handle a received packet.  Second half: Touches packet payload. */
 void __efx_rx_packet(struct efx_channel *channel,
-		     struct efx_rx_buffer *rx_buf, int checksummed)
+		     struct efx_rx_buffer *rx_buf, bool checksummed)
 {
 	struct efx_nic *efx = channel->efx;
 	struct sk_buff *skb;
-	int lro = efx->net_dev->features & NETIF_F_LRO;
+	bool lro = !!(efx->net_dev->features & NETIF_F_LRO);
 
 	/* If we're in loopback test, then pass the packet directly to the
 	 * loopback layer, and free the rx_buf here
diff --git a/drivers/net/sfc/rx.h b/drivers/net/sfc/rx.h
index f35e377..187b110 100644
--- a/drivers/net/sfc/rx.h
+++ b/drivers/net/sfc/rx.h
@@ -24,6 +24,6 @@ void efx_rx_strategy(struct efx_channel *channel);
 void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
 void efx_rx_work(struct work_struct *data);
 void __efx_rx_packet(struct efx_channel *channel,
-		     struct efx_rx_buffer *rx_buf, int checksummed);
+		     struct efx_rx_buffer *rx_buf, bool checksummed);
 
 #endif /* EFX_RX_H */
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 53fa4ed..ff7b84c 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -60,12 +60,12 @@ static const char *payload_msg =
  * @payload:		Payload used in tests
  */
 struct efx_selftest_state {
-	int flush;
+	bool flush;
 	int packet_count;
 	struct sk_buff **skbs;
 
 	/* Checksums are being offloaded */
-	int offload_csum;
+	bool offload_csum;
 
 	atomic_t rx_good;
 	atomic_t rx_bad;
@@ -537,7 +537,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 				      state->packet_count, GFP_KERNEL);
 		if (!state->skbs)
 			return -ENOMEM;
-		state->flush = 0;
+		state->flush = false;
 
 		EFX_LOG(efx, "TX queue %d testing %s loopback with %d "
 			"packets\n", tx_queue->queue, LOOPBACK_MODE(efx),
@@ -580,7 +580,8 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 	struct ethtool_cmd ecmd, ecmd_loopback;
 	struct efx_tx_queue *tx_queue;
 	enum efx_loopback_mode old_mode, mode;
-	int count, rc, link_up;
+	bool link_up;
+	int count, rc;
 
 	rc = efx_ethtool_get_settings(efx->net_dev, &ecmd);
 	if (rc) {
@@ -611,7 +612,7 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 			continue;
 
 		/* Move the port into the specified loopback mode. */
-		state->flush = 1;
+		state->flush = true;
 		efx->loopback_mode = mode;
 		efx_reconfigure_port(efx);
 
@@ -664,7 +665,7 @@ static int efx_test_loopbacks(struct efx_nic *efx,
 
  out:
 	/* Take out of loopback and restore PHY settings */
-	state->flush = 1;
+	state->flush = true;
 	efx->loopback_mode = old_mode;
 	efx_ethtool_set_settings(efx->net_dev, &ecmd);
 
@@ -716,7 +717,7 @@ int efx_offline_test(struct efx_nic *efx,
 	 * all received packets will be dropped. Mark the state as
 	 * "flushing" so all inflight packets are dropped */
 	BUG_ON(efx->loopback_selftest);
-	state->flush = 1;
+	state->flush = true;
 	efx->loopback_selftest = state;
 
 	rc = efx_test_loopbacks(efx, tests, loopback_modes);
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index c014606..b92b24b 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -122,7 +122,7 @@ struct tenxpress_phy_data {
 	enum tenxpress_state state;
 	enum efx_loopback_mode loopback_mode;
 	atomic_t bad_crc_count;
-	int tx_disabled;
+	bool tx_disabled;
 	int bad_lp_tries;
 };
 
@@ -274,7 +274,7 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 	return 0;
 }
 
-static void tenxpress_set_bad_lp(struct efx_nic *efx, int bad_lp)
+static void tenxpress_set_bad_lp(struct efx_nic *efx, bool bad_lp)
 {
 	struct tenxpress_phy_data *pd = efx->phy_data;
 	int reg;
@@ -311,15 +311,15 @@ static void tenxpress_set_bad_lp(struct efx_nic *efx, int bad_lp)
  * into a non-10GBT port and if so warn the user that they won't get
  * link any time soon as we are 10GBT only, unless caller specified
  * not to do this check (it isn't useful in loopback) */
-static int tenxpress_link_ok(struct efx_nic *efx, int check_lp)
+static bool tenxpress_link_ok(struct efx_nic *efx, bool check_lp)
 {
-	int ok = mdio_clause45_links_ok(efx, TENXPRESS_REQUIRED_DEVS);
+	bool ok = mdio_clause45_links_ok(efx, TENXPRESS_REQUIRED_DEVS);
 
 	if (ok) {
-		tenxpress_set_bad_lp(efx, 0);
+		tenxpress_set_bad_lp(efx, false);
 	} else if (check_lp) {
 		/* Are we plugged into the wrong sort of link? */
-		int bad_lp = 0;
+		bool bad_lp = false;
 		int phy_id = efx->mii.phy_id;
 		int an_stat = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
 						 MDIO_AN_STATUS);
@@ -332,7 +332,7 @@ static int tenxpress_link_ok(struct efx_nic *efx, int check_lp)
 		 * bit has the advantage of not clearing when autoneg
 		 * restarts. */
 		if (!(xphy_stat & (1 << PMA_PMD_XSTAT_FLP_LBN))) {
-			tenxpress_set_bad_lp(efx, 0);
+			tenxpress_set_bad_lp(efx, false);
 			return ok;
 		}
 
@@ -367,8 +367,8 @@ static void tenxpress_phyxs_loopback(struct efx_nic *efx)
 static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	int loop_change = LOOPBACK_OUT_OF(phy_data, efx,
-					  TENXPRESS_LOOPBACKS);
+	bool loop_change = LOOPBACK_OUT_OF(phy_data, efx,
+					   TENXPRESS_LOOPBACKS);
 
 	if (!tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL))
 		return;
@@ -388,7 +388,7 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 
 	phy_data->tx_disabled = efx->tx_disabled;
 	phy_data->loopback_mode = efx->loopback_mode;
-	efx->link_up = tenxpress_link_ok(efx, 0);
+	efx->link_up = tenxpress_link_ok(efx, false);
 	efx->link_options = GM_LPA_10000FULL;
 }
 
@@ -402,10 +402,10 @@ static void tenxpress_phy_clear_interrupt(struct efx_nic *efx)
 static int tenxpress_phy_check_hw(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	int phy_up = tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL);
-	int link_ok;
+	bool phy_up = tenxpress_state_is(efx, TENXPRESS_STATUS_NORMAL);
+	bool link_ok;
 
-	link_ok = phy_up && tenxpress_link_ok(efx, 1);
+	link_ok = phy_up && tenxpress_link_ok(efx, true);
 
 	if (link_ok != efx->link_up)
 		falcon_xmac_sim_phy_event(efx);
@@ -444,7 +444,7 @@ static void tenxpress_phy_fini(struct efx_nic *efx)
 
 /* Set the RX and TX LEDs and Link LED flashing. The other LEDs
  * (which probably aren't wired anyway) are left in AUTO mode */
-void tenxpress_phy_blink(struct efx_nic *efx, int blink)
+void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 {
 	int reg;
 
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 5f01371..51429b6 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -73,7 +73,7 @@ static inline void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 			pci_unmap_page(pci_dev, unmap_addr, buffer->unmap_len,
 				       PCI_DMA_TODEVICE);
 		buffer->unmap_len = 0;
-		buffer->unmap_single = 0;
+		buffer->unmap_single = false;
 	}
 
 	if (buffer->skb) {
@@ -150,7 +150,7 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 	unsigned int len, unmap_len = 0, fill_level, insert_ptr, misalign;
 	dma_addr_t dma_addr, unmap_addr = 0;
 	unsigned int dma_len;
-	unsigned unmap_single;
+	bool unmap_single;
 	int q_space, i = 0;
 	int rc = NETDEV_TX_OK;
 
@@ -169,7 +169,7 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 	 * since this is more efficient on machines with sparse
 	 * memory.
 	 */
-	unmap_single = 1;
+	unmap_single = true;
 	dma_addr = pci_map_single(pci_dev, skb->data, len, PCI_DMA_TODEVICE);
 
 	/* Process all fragments */
@@ -215,7 +215,7 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 			EFX_BUG_ON_PARANOID(buffer->tsoh);
 			EFX_BUG_ON_PARANOID(buffer->skb);
 			EFX_BUG_ON_PARANOID(buffer->len);
-			EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+			EFX_BUG_ON_PARANOID(!buffer->continuation);
 			EFX_BUG_ON_PARANOID(buffer->unmap_len);
 
 			dma_len = (((~dma_addr) & efx->type->tx_dma_mask) + 1);
@@ -248,14 +248,14 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 		page_offset = fragment->page_offset;
 		i++;
 		/* Map for DMA */
-		unmap_single = 0;
+		unmap_single = false;
 		dma_addr = pci_map_page(pci_dev, page, page_offset, len,
 					PCI_DMA_TODEVICE);
 	}
 
 	/* Transfer ownership of the skb to the final buffer */
 	buffer->skb = skb;
-	buffer->continuation = 0;
+	buffer->continuation = false;
 
 	/* Pass off to hardware */
 	falcon_push_buffers(tx_queue);
@@ -326,7 +326,7 @@ static inline void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 		}
 
 		efx_dequeue_buffer(tx_queue, buffer);
-		buffer->continuation = 1;
+		buffer->continuation = true;
 		buffer->len = 0;
 
 		++tx_queue->read_count;
@@ -428,7 +428,7 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 	if (!tx_queue->buffer)
 		return -ENOMEM;
 	for (i = 0; i <= efx->type->txd_ring_mask; ++i)
-		tx_queue->buffer[i].continuation = 1;
+		tx_queue->buffer[i].continuation = true;
 
 	/* Allocate hardware ring */
 	rc = falcon_probe_tx(tx_queue);
@@ -469,7 +469,7 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 		buffer = &tx_queue->buffer[tx_queue->read_count &
 					   tx_queue->efx->type->txd_ring_mask];
 		efx_dequeue_buffer(tx_queue, buffer);
-		buffer->continuation = 1;
+		buffer->continuation = true;
 		buffer->len = 0;
 
 		++tx_queue->read_count;
@@ -567,7 +567,7 @@ struct tso_state {
 		/* DMA address and length of the whole fragment */
 		unsigned int unmap_len;
 		dma_addr_t unmap_addr;
-		unsigned int unmap_single;
+		bool unmap_single;
 	} ifc;
 
 	struct {
@@ -746,7 +746,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 		EFX_BUG_ON_PARANOID(buffer->len);
 		EFX_BUG_ON_PARANOID(buffer->unmap_len);
 		EFX_BUG_ON_PARANOID(buffer->skb);
-		EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+		EFX_BUG_ON_PARANOID(!buffer->continuation);
 		EFX_BUG_ON_PARANOID(buffer->tsoh);
 
 		buffer->dma_addr = dma_addr;
@@ -792,7 +792,7 @@ static inline void efx_tso_put_header(struct efx_tx_queue *tx_queue,
 	EFX_BUG_ON_PARANOID(buffer->len);
 	EFX_BUG_ON_PARANOID(buffer->unmap_len);
 	EFX_BUG_ON_PARANOID(buffer->skb);
-	EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+	EFX_BUG_ON_PARANOID(!buffer->continuation);
 	EFX_BUG_ON_PARANOID(buffer->tsoh);
 	buffer->len = len;
 	buffer->dma_addr = tsoh->dma_addr;
@@ -816,7 +816,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->skb);
 		buffer->len = 0;
-		buffer->continuation = 1;
+		buffer->continuation = true;
 		if (buffer->unmap_len) {
 			unmap_addr = (buffer->dma_addr + buffer->len -
 				      buffer->unmap_len);
@@ -855,7 +855,7 @@ static inline void tso_start(struct tso_state *st, const struct sk_buff *skb)
 	st->packet_space = st->p.full_packet_size;
 	st->remaining_len = skb->len - st->p.header_length;
 	st->ifc.unmap_len = 0;
-	st->ifc.unmap_single = 0;
+	st->ifc.unmap_single = false;
 }
 
 static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
@@ -865,7 +865,7 @@ static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 					  frag->page_offset, frag->size,
 					  PCI_DMA_TODEVICE);
 	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->ifc.unmap_addr))) {
-		st->ifc.unmap_single = 0;
+		st->ifc.unmap_single = false;
 		st->ifc.unmap_len = frag->size;
 		st->ifc.len = frag->size;
 		st->ifc.dma_addr = st->ifc.unmap_addr;
@@ -884,7 +884,7 @@ tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
 	st->ifc.unmap_addr = pci_map_single(efx->pci_dev, skb->data + hl,
 					    len, PCI_DMA_TODEVICE);
 	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->ifc.unmap_addr))) {
-		st->ifc.unmap_single = 1;
+		st->ifc.unmap_single = true;
 		st->ifc.unmap_len = len;
 		st->ifc.len = len;
 		st->ifc.dma_addr = st->ifc.unmap_addr;
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index f3684ad..fd4045b 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -40,7 +40,7 @@ void xfp_set_led(struct efx_nic *p, int led, int mode)
 }
 
 struct xfp_phy_data {
-	int tx_disabled;
+	bool tx_disabled;
 };
 
 #define XFP_MAX_RESET_TIME 500
@@ -151,7 +151,7 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 static void xfp_phy_fini(struct efx_nic *efx)
 {
 	/* Clobber the LED if it was blinking */
-	efx->board_info.blink(efx, 0);
+	efx->board_info.blink(efx, false);
 
 	/* Free the context block */
 	kfree(efx->phy_data);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

