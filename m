From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 5/5] sfc: Implement adaptive IRQ moderation
Date: Fri, 20 Mar 2009 23:30:37 +0000
Message-ID: <1237591837.3217.17.camel@achroite>
References: <1237591540.3217.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:55857 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763460AbZCTXal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 19:30:41 -0400
In-Reply-To: <1237591540.3217.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calculate a score for each 1000 IRQs:
- TX completions are worth 1 point
- RX completions are worth 4 if merged using LRO or 2 otherwise

Reduce moderation if the score is less than 10000, down to a minimum
of 5 us.  Increase moderation if the score is more than 20000, up to
the specified maximum.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   46 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/sfc/efx.h        |    2 +-
 drivers/net/sfc/ethtool.c    |   19 +++++-----------
 drivers/net/sfc/falcon.c     |   16 ++++++++++----
 drivers/net/sfc/falcon.h     |    2 +
 drivers/net/sfc/net_driver.h |    9 ++++++++
 6 files changed, 73 insertions(+), 21 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 8fa68d8..6eff9ca 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -133,6 +133,16 @@ static int phy_flash_cfg;
 module_param(phy_flash_cfg, int, 0644);
 MODULE_PARM_DESC(phy_flash_cfg, "Set PHYs into reflash mode initially");
 
+static unsigned irq_adapt_low_thresh = 10000;
+module_param(irq_adapt_low_thresh, uint, 0644);
+MODULE_PARM_DESC(irq_adapt_low_thresh,
+		 "Threshold score for reducing IRQ moderation");
+
+static unsigned irq_adapt_high_thresh = 20000;
+module_param(irq_adapt_high_thresh, uint, 0644);
+MODULE_PARM_DESC(irq_adapt_high_thresh,
+		 "Threshold score for increasing IRQ moderation");
+
 /**************************************************************************
  *
  * Utility functions and prototypes
@@ -223,6 +233,35 @@ static int efx_poll(struct napi_struct *napi, int budget)
 	rx_packets = efx_process_channel(channel, budget);
 
 	if (rx_packets < budget) {
+		struct efx_nic *efx = channel->efx;
+
+		if (channel->used_flags & EFX_USED_BY_RX &&
+		    efx->irq_rx_adaptive &&
+		    unlikely(++channel->irq_count == 1000)) {
+			unsigned old_irq_moderation = channel->irq_moderation;
+
+			if (unlikely(channel->irq_mod_score <
+				     irq_adapt_low_thresh)) {
+				channel->irq_moderation =
+					max_t(int,
+					      channel->irq_moderation -
+					      FALCON_IRQ_MOD_RESOLUTION,
+					      FALCON_IRQ_MOD_RESOLUTION);
+			} else if (unlikely(channel->irq_mod_score >
+					    irq_adapt_high_thresh)) {
+				channel->irq_moderation =
+					min(channel->irq_moderation +
+					    FALCON_IRQ_MOD_RESOLUTION,
+					    efx->irq_rx_moderation);
+			}
+
+			if (channel->irq_moderation != old_irq_moderation)
+				falcon_set_int_moderation(channel);
+
+			channel->irq_count = 0;
+			channel->irq_mod_score = 0;
+		}
+
 		/* There is no race here; although napi_disable() will
 		 * only wait for napi_complete(), this isn't a problem
 		 * since efx_channel_processed() will have no effect if
@@ -991,7 +1030,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 	efx_set_channels(efx);
 
 	/* Initialise the interrupt moderation settings */
-	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec);
+	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true);
 
 	return 0;
 }
@@ -1188,7 +1227,8 @@ void efx_flush_queues(struct efx_nic *efx)
  **************************************************************************/
 
 /* Set interrupt moderation parameters */
-void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs)
+void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
+			     bool rx_adaptive)
 {
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
@@ -1198,6 +1238,8 @@ void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs)
 	efx_for_each_tx_queue(tx_queue, efx)
 		tx_queue->channel->irq_moderation = tx_usecs;
 
+	efx->irq_rx_adaptive = rx_adaptive;
+	efx->irq_rx_moderation = rx_usecs;
 	efx_for_each_rx_queue(rx_queue, efx)
 		rx_queue->channel->irq_moderation = rx_usecs;
 }
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 8bde1d2..da157aa 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -52,7 +52,7 @@ extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
 extern void efx_suspend(struct efx_nic *efx);
 extern void efx_resume(struct efx_nic *efx);
 extern void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs,
-				    int rx_usecs);
+				    int rx_usecs, bool rx_adaptive);
 extern int efx_request_power(struct efx_nic *efx, int mw, const char *name);
 extern void efx_hex_dump(const u8 *, unsigned int, const char *);
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 589d132..64309f4 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -604,7 +604,6 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_tx_queue *tx_queue;
-	struct efx_rx_queue *rx_queue;
 	struct efx_channel *channel;
 
 	memset(coalesce, 0, sizeof(*coalesce));
@@ -622,14 +621,8 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 		}
 	}
 
-	/* Find lowest IRQ moderation across all used RX queues */
-	coalesce->rx_coalesce_usecs_irq = ~((u32) 0);
-	efx_for_each_rx_queue(rx_queue, efx) {
-		channel = rx_queue->channel;
-		if (channel->irq_moderation < coalesce->rx_coalesce_usecs_irq)
-			coalesce->rx_coalesce_usecs_irq =
-				channel->irq_moderation;
-	}
+	coalesce->use_adaptive_rx_coalesce = efx->irq_rx_adaptive;
+	coalesce->rx_coalesce_usecs_irq = efx->irq_rx_moderation;
 
 	return 0;
 }
@@ -643,10 +636,9 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
-	unsigned tx_usecs, rx_usecs;
+	unsigned tx_usecs, rx_usecs, adaptive;
 
-	if (coalesce->use_adaptive_rx_coalesce ||
-	    coalesce->use_adaptive_tx_coalesce)
+	if (coalesce->use_adaptive_tx_coalesce)
 		return -EOPNOTSUPP;
 
 	if (coalesce->rx_coalesce_usecs || coalesce->tx_coalesce_usecs) {
@@ -657,6 +649,7 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 
 	rx_usecs = coalesce->rx_coalesce_usecs_irq;
 	tx_usecs = coalesce->tx_coalesce_usecs_irq;
+	adaptive = coalesce->use_adaptive_rx_coalesce;
 
 	/* If the channel is shared only allow RX parameters to be set */
 	efx_for_each_tx_queue(tx_queue, efx) {
@@ -668,7 +661,7 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 		}
 	}
 
-	efx_init_irq_moderation(efx, tx_usecs, rx_usecs);
+	efx_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive);
 
 	/* Reset channel to pick up new moderation value.  Note that
 	 * this may change the value of the irq_moderation field
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index f42fc60..23a1b14 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -729,6 +729,9 @@ static void falcon_handle_tx_event(struct efx_channel *channel,
 		tx_ev_desc_ptr = EFX_QWORD_FIELD(*event, TX_EV_DESC_PTR);
 		tx_ev_q_label = EFX_QWORD_FIELD(*event, TX_EV_Q_LABEL);
 		tx_queue = &efx->tx_queue[tx_ev_q_label];
+		channel->irq_mod_score +=
+			(tx_ev_desc_ptr - tx_queue->read_count) &
+			efx->type->txd_ring_mask;
 		efx_xmit_done(tx_queue, tx_ev_desc_ptr);
 	} else if (EFX_QWORD_FIELD(*event, TX_EV_WQ_FF_FULL)) {
 		/* Rewrite the FIFO write pointer */
@@ -898,6 +901,8 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 			discard = true;
 	}
 
+	channel->irq_mod_score += 2;
+
 	/* Handle received packet */
 	efx_rx_packet(rx_queue, rx_ev_desc_ptr, rx_ev_byte_cnt,
 		      checksummed, discard);
@@ -1075,14 +1080,15 @@ void falcon_set_int_moderation(struct efx_channel *channel)
 		 * program is based at 0.  So actual interrupt moderation
 		 * achieved is ((x + 1) * res).
 		 */
-		unsigned int res = 5;
-		channel->irq_moderation -= (channel->irq_moderation % res);
-		if (channel->irq_moderation < res)
-			channel->irq_moderation = res;
+		channel->irq_moderation -= (channel->irq_moderation %
+					    FALCON_IRQ_MOD_RESOLUTION);
+		if (channel->irq_moderation < FALCON_IRQ_MOD_RESOLUTION)
+			channel->irq_moderation = FALCON_IRQ_MOD_RESOLUTION;
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     TIMER_MODE, TIMER_MODE_INT_HLDOFF,
 				     TIMER_VAL,
-				     (channel->irq_moderation / res) - 1);
+				     channel->irq_moderation /
+				     FALCON_IRQ_MOD_RESOLUTION - 1);
 	} else {
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     TIMER_MODE, TIMER_MODE_DIS,
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 7869c3d..77f2e0d 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -85,6 +85,8 @@ extern void falcon_set_int_moderation(struct efx_channel *channel);
 extern void falcon_disable_interrupts(struct efx_nic *efx);
 extern void falcon_fini_interrupt(struct efx_nic *efx);
 
+#define FALCON_IRQ_MOD_RESOLUTION 5
+
 /* Global Resources */
 extern int falcon_probe_nic(struct efx_nic *efx);
 extern int falcon_probe_resources(struct efx_nic *efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index b81fc72..e169e5d 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -336,6 +336,8 @@ enum efx_rx_alloc_method {
  * @eventq_read_ptr: Event queue read pointer
  * @last_eventq_read_ptr: Last event queue read pointer value.
  * @eventq_magic: Event queue magic value for driver-generated test events
+ * @irq_count: Number of IRQs since last adaptive moderation decision
+ * @irq_mod_score: IRQ moderation score
  * @rx_alloc_level: Watermark based heuristic counter for pushing descriptors
  *	and diagnostic counters
  * @rx_alloc_push_pages: RX allocation method currently in use for pushing
@@ -364,6 +366,9 @@ struct efx_channel {
 	unsigned int last_eventq_read_ptr;
 	unsigned int eventq_magic;
 
+	unsigned int irq_count;
+	unsigned int irq_mod_score;
+
 	int rx_alloc_level;
 	int rx_alloc_push_pages;
 
@@ -703,6 +708,8 @@ union efx_multicast_hash {
  * @membase: Memory BAR value
  * @biu_lock: BIU (bus interface unit) lock
  * @interrupt_mode: Interrupt mode
+ * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
+ * @irq_rx_moderation: IRQ moderation time for RX event queues
  * @i2c_adap: I2C adapter
  * @board_info: Board-level information
  * @state: Device state flag. Serialised by the rtnl_lock.
@@ -784,6 +791,8 @@ struct efx_nic {
 	void __iomem *membase;
 	spinlock_t biu_lock;
 	enum efx_int_mode interrupt_mode;
+	bool irq_rx_adaptive;
+	unsigned int irq_rx_moderation;
 
 	struct i2c_adapter i2c_adap;
 	struct efx_board board_info;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

