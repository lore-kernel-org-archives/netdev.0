From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 5/6] sfc: set interrupt moderation via MCDI
Date: Thu, 11 Aug 2016 13:02:09 +0100
Message-ID: <201b64d1-5946-c4fb-52b2-052986f4cd83@solarflare.com>
References: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:3652 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932388AbcHKMZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:25:52 -0400
In-Reply-To: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFN8000-series NICs require a new method of setting interrupt moderation,
via MCDI. This is indicated by a workaround flag. This new MCDI command
takes an explicit time value rather than a number of ticks. It therefore
makes sense to also store the moderation values in terms of time, since
that is what the ethtool interface is interested in.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c        | 38 +++++++++++----
 drivers/net/ethernet/sfc/efx.c         | 89 ++++++++++++++++++----------------
 drivers/net/ethernet/sfc/efx.h         |  2 +
 drivers/net/ethernet/sfc/falcon.c      |  7 ++-
 drivers/net/ethernet/sfc/net_driver.h  | 10 ++--
 drivers/net/ethernet/sfc/nic.h         |  2 +
 drivers/net/ethernet/sfc/ptp.c         |  2 +-
 drivers/net/ethernet/sfc/siena.c       | 11 +++--
 drivers/net/ethernet/sfc/workarounds.h |  4 ++
 9 files changed, 103 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e57fa2e..5f6c4fa 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1749,27 +1749,43 @@ static size_t efx_ef10_update_stats_vf(struct efx_nic *efx, u64 *full_stats,
 static void efx_ef10_push_irq_moderation(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
-	unsigned int mode, value;
+	unsigned int mode, usecs;
 	efx_dword_t timer_cmd;
 
-	if (channel->irq_moderation) {
+	if (channel->irq_moderation_us) {
 		mode = 3;
-		value = channel->irq_moderation - 1;
+		usecs = channel->irq_moderation_us;
 	} else {
 		mode = 0;
-		value = 0;
+		usecs = 0;
 	}
 
-	if (EFX_EF10_WORKAROUND_35388(efx)) {
+	if (EFX_EF10_WORKAROUND_61265(efx)) {
+		MCDI_DECLARE_BUF(inbuf, MC_CMD_SET_EVQ_TMR_IN_LEN);
+		unsigned int ns = usecs * 1000;
+
+		MCDI_SET_DWORD(inbuf, SET_EVQ_TMR_IN_INSTANCE,
+			       channel->channel);
+		MCDI_SET_DWORD(inbuf, SET_EVQ_TMR_IN_TMR_LOAD_REQ_NS, ns);
+		MCDI_SET_DWORD(inbuf, SET_EVQ_TMR_IN_TMR_RELOAD_REQ_NS, ns);
+		MCDI_SET_DWORD(inbuf, SET_EVQ_TMR_IN_TMR_MODE, mode);
+
+		efx_mcdi_rpc_async(efx, MC_CMD_SET_EVQ_TMR,
+				   inbuf, sizeof(inbuf), 0, NULL, 0);
+	} else if (EFX_EF10_WORKAROUND_35388(efx)) {
+		unsigned int ticks = efx_usecs_to_ticks(efx, usecs);
+
 		EFX_POPULATE_DWORD_3(timer_cmd, ERF_DD_EVQ_IND_TIMER_FLAGS,
 				     EFE_DD_EVQ_IND_TIMER_FLAGS,
 				     ERF_DD_EVQ_IND_TIMER_MODE, mode,
-				     ERF_DD_EVQ_IND_TIMER_VAL, value);
+				     ERF_DD_EVQ_IND_TIMER_VAL, ticks);
 		efx_writed_page(efx, &timer_cmd, ER_DD_EVQ_INDIRECT,
 				channel->channel);
 	} else {
+		unsigned int ticks = efx_usecs_to_ticks(efx, usecs);
+
 		EFX_POPULATE_DWORD_2(timer_cmd, ERF_DZ_TC_TIMER_MODE, mode,
-				     ERF_DZ_TC_TIMER_VAL, value);
+				     ERF_DZ_TC_TIMER_VAL, ticks);
 		efx_writed_page(efx, &timer_cmd, ER_DZ_EVQ_TMR,
 				channel->channel);
 	}
@@ -2615,10 +2631,11 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 	/* Successfully created event queue on channel 0 */
 	rc = efx_mcdi_get_workarounds(efx, &implemented, &enabled);
 	if (rc == -ENOSYS) {
-		/* GET_WORKAROUNDS was implemented before the bug26807
-		 * workaround, thus the latter must be unavailable in this fw
+		/* GET_WORKAROUNDS was implemented before these workarounds,
+		 * thus they must be unavailable in this firmware.
 		 */
 		nic_data->workaround_26807 = false;
+		nic_data->workaround_61265 = false;
 		rc = 0;
 	} else if (rc) {
 		goto fail;
@@ -2658,6 +2675,9 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 				rc = 0;
 			}
 		}
+
+		nic_data->workaround_61265 =
+			!!(implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG61265);
 	}
 
 	if (!rc)
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 14b821b..b26e1f9 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -281,6 +281,27 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
  * NAPI guarantees serialisation of polls of the same device, which
  * provides the guarantee required by efx_process_channel().
  */
+static void efx_update_irq_mod(struct efx_nic *efx, struct efx_channel *channel)
+{
+	int step = efx->irq_mod_step_us;
+
+	if (channel->irq_mod_score < irq_adapt_low_thresh) {
+		if (channel->irq_moderation_us > step) {
+			channel->irq_moderation_us -= step;
+			efx->type->push_irq_moderation(channel);
+		}
+	} else if (channel->irq_mod_score > irq_adapt_high_thresh) {
+		if (channel->irq_moderation_us <
+		    efx->irq_rx_moderation_us) {
+			channel->irq_moderation_us += step;
+			efx->type->push_irq_moderation(channel);
+		}
+	}
+
+	channel->irq_count = 0;
+	channel->irq_mod_score = 0;
+}
+
 static int efx_poll(struct napi_struct *napi, int budget)
 {
 	struct efx_channel *channel =
@@ -301,22 +322,7 @@ static int efx_poll(struct napi_struct *napi, int budget)
 		if (efx_channel_has_rx_queue(channel) &&
 		    efx->irq_rx_adaptive &&
 		    unlikely(++channel->irq_count == 1000)) {
-			if (unlikely(channel->irq_mod_score <
-				     irq_adapt_low_thresh)) {
-				if (channel->irq_moderation > 1) {
-					channel->irq_moderation -= 1;
-					efx->type->push_irq_moderation(channel);
-				}
-			} else if (unlikely(channel->irq_mod_score >
-					    irq_adapt_high_thresh)) {
-				if (channel->irq_moderation <
-				    efx->irq_rx_moderation) {
-					channel->irq_moderation += 1;
-					efx->type->push_irq_moderation(channel);
-				}
-			}
-			channel->irq_count = 0;
-			channel->irq_mod_score = 0;
+			efx_update_irq_mod(efx, channel);
 		}
 
 		efx_filter_rfs_expire(channel);
@@ -1703,6 +1709,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 	netif_set_real_num_rx_queues(efx->net_dev, efx->n_rx_channels);
 
 	/* Initialise the interrupt moderation settings */
+	efx->irq_mod_step_us = DIV_ROUND_UP(efx->timer_quantum_ns, 1000);
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true,
 				true);
 
@@ -1949,14 +1956,21 @@ static void efx_remove_all(struct efx_nic *efx)
  * Interrupt moderation
  *
  **************************************************************************/
-
-static unsigned int irq_mod_ticks(unsigned int usecs, unsigned int quantum_ns)
+unsigned int efx_usecs_to_ticks(struct efx_nic *efx, unsigned int usecs)
 {
 	if (usecs == 0)
 		return 0;
-	if (usecs * 1000 < quantum_ns)
+	if (usecs * 1000 < efx->timer_quantum_ns)
 		return 1; /* never round down to 0 */
-	return usecs * 1000 / quantum_ns;
+	return usecs * 1000 / efx->timer_quantum_ns;
+}
+
+unsigned int efx_ticks_to_usecs(struct efx_nic *efx, unsigned int ticks)
+{
+	/* We must round up when converting ticks to microseconds
+	 * because we round down when converting the other way.
+	 */
+	return DIV_ROUND_UP(ticks * efx->timer_quantum_ns, 1000);
 }
 
 /* Set interrupt moderation parameters */
@@ -1968,18 +1982,12 @@ int efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 	unsigned int irq_mod_max = DIV_ROUND_UP(efx->type->timer_period_max *
 						efx->timer_quantum_ns,
 						1000);
-	unsigned int tx_ticks;
-	unsigned int rx_ticks;
-
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	if (tx_usecs > irq_mod_max || rx_usecs > irq_mod_max)
 		return -EINVAL;
 
-	tx_ticks = irq_mod_ticks(tx_usecs, efx->timer_quantum_ns);
-	rx_ticks = irq_mod_ticks(rx_usecs, efx->timer_quantum_ns);
-
-	if (tx_ticks != rx_ticks && efx->tx_channel_offset == 0 &&
+	if (tx_usecs != rx_usecs && efx->tx_channel_offset == 0 &&
 	    !rx_may_override_tx) {
 		netif_err(efx, drv, efx->net_dev, "Channels are shared. "
 			  "RX and TX IRQ moderation must be equal\n");
@@ -1987,12 +1995,12 @@ int efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 	}
 
 	efx->irq_rx_adaptive = rx_adaptive;
-	efx->irq_rx_moderation = rx_ticks;
+	efx->irq_rx_moderation_us = rx_usecs;
 	efx_for_each_channel(channel, efx) {
 		if (efx_channel_has_rx_queue(channel))
-			channel->irq_moderation = rx_ticks;
+			channel->irq_moderation_us = rx_usecs;
 		else if (efx_channel_has_tx_queues(channel))
-			channel->irq_moderation = tx_ticks;
+			channel->irq_moderation_us = tx_usecs;
 	}
 
 	return 0;
@@ -2001,26 +2009,21 @@ int efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 void efx_get_irq_moderation(struct efx_nic *efx, unsigned int *tx_usecs,
 			    unsigned int *rx_usecs, bool *rx_adaptive)
 {
-	/* We must round up when converting ticks to microseconds
-	 * because we round down when converting the other way.
-	 */
-
 	*rx_adaptive = efx->irq_rx_adaptive;
-	*rx_usecs = DIV_ROUND_UP(efx->irq_rx_moderation *
-				 efx->timer_quantum_ns,
-				 1000);
+	*rx_usecs = efx->irq_rx_moderation_us;
 
 	/* If channels are shared between RX and TX, so is IRQ
 	 * moderation.  Otherwise, IRQ moderation is the same for all
 	 * TX channels and is not adaptive.
 	 */
-	if (efx->tx_channel_offset == 0)
+	if (efx->tx_channel_offset == 0) {
 		*tx_usecs = *rx_usecs;
-	else
-		*tx_usecs = DIV_ROUND_UP(
-			efx->channel[efx->tx_channel_offset]->irq_moderation *
-			efx->timer_quantum_ns,
-			1000);
+	} else {
+		struct efx_channel *tx_channel;
+
+		tx_channel = efx->channel[efx->tx_channel_offset];
+		*tx_usecs = tx_channel->irq_moderation_us;
+	}
 }
 
 /**************************************************************************
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index c3ae739..342ae16 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -204,6 +204,8 @@ int efx_try_recovery(struct efx_nic *efx);
 
 /* Global */
 void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
+unsigned int efx_usecs_to_ticks(struct efx_nic *efx, unsigned int usecs);
+unsigned int efx_ticks_to_usecs(struct efx_nic *efx, unsigned int ticks);
 int efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 			    unsigned int rx_usecs, bool rx_adaptive,
 			    bool rx_may_override_tx);
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index d790cb8..d3d0bcc 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -378,12 +378,15 @@ static void falcon_push_irq_moderation(struct efx_channel *channel)
 	struct efx_nic *efx = channel->efx;
 
 	/* Set timer register */
-	if (channel->irq_moderation) {
+	if (channel->irq_moderation_us) {
+		unsigned int ticks;
+
+		ticks = efx_usecs_to_ticks(efx, channel->irq_moderation_us);
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     FRF_AB_TC_TIMER_MODE,
 				     FFE_BB_TIMER_MODE_INT_HLDOFF,
 				     FRF_AB_TC_TIMER_VAL,
-				     channel->irq_moderation - 1);
+				     ticks - 1);
 	} else {
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     FRF_AB_TC_TIMER_MODE,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 9ff062a..3e8c6fb 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -392,7 +392,7 @@ enum efx_sync_events_state {
  * @eventq_init: Event queue initialised flag
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
- * @irq_moderation: IRQ moderation value (in hardware ticks)
+ * @irq_moderation_us: IRQ moderation value (in microseconds)
  * @napi_dev: Net device used with NAPI
  * @napi_str: NAPI control structure
  * @state: state for NAPI vs busy polling
@@ -433,7 +433,7 @@ struct efx_channel {
 	bool eventq_init;
 	bool enabled;
 	int irq;
-	unsigned int irq_moderation;
+	unsigned int irq_moderation_us;
 	struct net_device *napi_dev;
 	struct napi_struct napi_str;
 #ifdef CONFIG_NET_RX_BUSY_POLL
@@ -811,7 +811,8 @@ struct vfdi_status;
  * @interrupt_mode: Interrupt mode
  * @timer_quantum_ns: Interrupt timer quantum, in nanoseconds
  * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
- * @irq_rx_moderation: IRQ moderation time for RX event queues
+ * @irq_rx_mod_step_us: Step size for IRQ moderation for RX event queues
+ * @irq_rx_moderation_us: IRQ moderation time for RX event queues
  * @msg_enable: Log message enable flags
  * @state: Device state number (%STATE_*). Serialised by the rtnl_lock.
  * @reset_pending: Bitmask for pending resets
@@ -941,7 +942,8 @@ struct efx_nic {
 	enum efx_int_mode interrupt_mode;
 	unsigned int timer_quantum_ns;
 	bool irq_rx_adaptive;
-	unsigned int irq_rx_moderation;
+	unsigned int irq_mod_step_us;
+	unsigned int irq_rx_moderation_us;
 	u32 msg_enable;
 
 	enum nic_state state;
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 531c5a8..d8b1694 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -507,6 +507,7 @@ enum {
  * @stats: Hardware statistics
  * @workaround_35388: Flag: firmware supports workaround for bug 35388
  * @workaround_26807: Flag: firmware supports workaround for bug 26807
+ * @workaround_61265: Flag: firmware supports workaround for bug 61265
  * @must_check_datapath_caps: Flag: @datapath_caps needs to be revalidated
  *	after MC reboot
  * @datapath_caps: Capabilities of datapath firmware (FLAGS1 field of
@@ -542,6 +543,7 @@ struct efx_ef10_nic_data {
 	u64 stats[EF10_STAT_COUNT];
 	bool workaround_35388;
 	bool workaround_26807;
+	bool workaround_61265;
 	bool must_check_datapath_caps;
 	u32 datapath_caps;
 	u32 datapath_caps2;
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index c771e0a..dd204d9 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1306,7 +1306,7 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
 
-	channel->irq_moderation = 0;
+	channel->irq_moderation_us = 0;
 	channel->rx_queue.core_index = 0;
 
 	return efx_ptp_probe(efx, channel);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 2219b54..994e33f 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -34,19 +34,24 @@ static void siena_init_wol(struct efx_nic *efx);
 
 static void siena_push_irq_moderation(struct efx_channel *channel)
 {
+	struct efx_nic *efx = channel->efx;
 	efx_dword_t timer_cmd;
 
-	if (channel->irq_moderation)
+	if (channel->irq_moderation_us) {
+		unsigned int ticks;
+
+		ticks = efx_usecs_to_ticks(efx, channel->irq_moderation_us);
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     FRF_CZ_TC_TIMER_MODE,
 				     FFE_CZ_TIMER_MODE_INT_HLDOFF,
 				     FRF_CZ_TC_TIMER_VAL,
-				     channel->irq_moderation - 1);
-	else
+				     ticks - 1);
+	} else {
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     FRF_CZ_TC_TIMER_MODE,
 				     FFE_CZ_TIMER_MODE_DIS,
 				     FRF_CZ_TC_TIMER_VAL, 0);
+	}
 	efx_writed_page_locked(channel->efx, &timer_cmd, FR_BZ_TIMER_COMMAND_P0,
 			       channel->channel);
 }
diff --git a/drivers/net/ethernet/sfc/workarounds.h b/drivers/net/ethernet/sfc/workarounds.h
index 2310b75..351cd14 100644
--- a/drivers/net/ethernet/sfc/workarounds.h
+++ b/drivers/net/ethernet/sfc/workarounds.h
@@ -50,4 +50,8 @@
 #define EFX_WORKAROUND_35388(efx)					\
 	(efx_nic_rev(efx) == EFX_REV_HUNT_A0 && EFX_EF10_WORKAROUND_35388(efx))
 
+/* Moderation timer access must go through MCDI */
+#define EFX_EF10_WORKAROUND_61265(efx)					\
+	(((struct efx_ef10_nic_data *)efx->nic_data)->workaround_61265)
+
 #endif /* EFX_WORKAROUNDS_H */
-- 
2.7.4
