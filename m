From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 6/6] sfc: get timer configuration from adapter
Date: Thu, 11 Aug 2016 13:02:36 +0100
Message-ID: <57b794f5-c541-8633-b290-b2ca4cc57d30@solarflare.com>
References: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:27093 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932346AbcHKMZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:25:50 -0400
In-Reply-To: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On SFN8000 series adapters the MC provides a method to get the timer
quantum and the maximum timer setting. We revert to the old values if the
new call is unavailable.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 142 +++++++++++++++++++++++++++-------
 drivers/net/ethernet/sfc/efx.c        |   9 ++-
 drivers/net/ethernet/sfc/falcon.c     |   2 +
 drivers/net/ethernet/sfc/net_driver.h |   2 +
 drivers/net/ethernet/sfc/siena.c      |   3 +
 5 files changed, 125 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 5f6c4fa..b8c9f18 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -233,6 +233,116 @@ static int efx_ef10_get_sysclk_freq(struct efx_nic *efx)
 	return rc > 0 ? rc : -ERANGE;
 }
 
+static int efx_ef10_get_timer_workarounds(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	unsigned int implemented;
+	unsigned int enabled;
+	int rc;
+
+	nic_data->workaround_35388 = false;
+	nic_data->workaround_61265 = false;
+
+	rc = efx_mcdi_get_workarounds(efx, &implemented, &enabled);
+
+	if (rc == -ENOSYS) {
+		/* Firmware without GET_WORKAROUNDS - not a problem. */
+		rc = 0;
+	} else if (rc == 0) {
+		/* Bug61265 workaround is always enabled if implemented. */
+		if (enabled & MC_CMD_GET_WORKAROUNDS_OUT_BUG61265)
+			nic_data->workaround_61265 = true;
+
+		if (enabled & MC_CMD_GET_WORKAROUNDS_OUT_BUG35388) {
+			nic_data->workaround_35388 = true;
+		} else if (implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG35388) {
+			/* Workaround is implemented but not enabled.
+			 * Try to enable it.
+			 */
+			rc = efx_mcdi_set_workaround(efx,
+						     MC_CMD_WORKAROUND_BUG35388,
+						     true, NULL);
+			if (rc == 0)
+				nic_data->workaround_35388 = true;
+			/* If we failed to set the workaround just carry on. */
+			rc = 0;
+		}
+	}
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "workaround for bug 35388 is %sabled\n",
+		  nic_data->workaround_35388 ? "en" : "dis");
+	netif_dbg(efx, probe, efx->net_dev,
+		  "workaround for bug 61265 is %sabled\n",
+		  nic_data->workaround_61265 ? "en" : "dis");
+
+	return rc;
+}
+
+static void efx_ef10_process_timer_config(struct efx_nic *efx,
+					  const efx_dword_t *data)
+{
+	unsigned int max_count;
+
+	if (EFX_EF10_WORKAROUND_61265(efx)) {
+		efx->timer_quantum_ns = MCDI_DWORD(data,
+			GET_EVQ_TMR_PROPERTIES_OUT_MCDI_TMR_STEP_NS);
+		efx->timer_max_ns = MCDI_DWORD(data,
+			GET_EVQ_TMR_PROPERTIES_OUT_MCDI_TMR_MAX_NS);
+	} else if (EFX_EF10_WORKAROUND_35388(efx)) {
+		efx->timer_quantum_ns = MCDI_DWORD(data,
+			GET_EVQ_TMR_PROPERTIES_OUT_BUG35388_TMR_NS_PER_COUNT);
+		max_count = MCDI_DWORD(data,
+			GET_EVQ_TMR_PROPERTIES_OUT_BUG35388_TMR_MAX_COUNT);
+		efx->timer_max_ns = max_count * efx->timer_quantum_ns;
+	} else {
+		efx->timer_quantum_ns = MCDI_DWORD(data,
+			GET_EVQ_TMR_PROPERTIES_OUT_TMR_REG_NS_PER_COUNT);
+		max_count = MCDI_DWORD(data,
+			GET_EVQ_TMR_PROPERTIES_OUT_TMR_REG_MAX_COUNT);
+		efx->timer_max_ns = max_count * efx->timer_quantum_ns;
+	}
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "got timer properties from MC: quantum %u ns; max %u ns\n",
+		  efx->timer_quantum_ns, efx->timer_max_ns);
+}
+
+static int efx_ef10_get_timer_config(struct efx_nic *efx)
+{
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_LEN);
+	int rc;
+
+	rc = efx_ef10_get_timer_workarounds(efx);
+	if (rc)
+		return rc;
+
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_GET_EVQ_TMR_PROPERTIES, NULL, 0,
+				outbuf, sizeof(outbuf), NULL);
+
+	if (rc == 0) {
+		efx_ef10_process_timer_config(efx, outbuf);
+	} else if (rc == -ENOSYS || rc == -EPERM) {
+		/* Not available - fall back to Huntington defaults. */
+		unsigned int quantum;
+
+		rc = efx_ef10_get_sysclk_freq(efx);
+		if (rc < 0)
+			return rc;
+
+		quantum = 1536000 / rc; /* 1536 cycles */
+		efx->timer_quantum_ns = quantum;
+		efx->timer_max_ns = efx->type->timer_period_max * quantum;
+		rc = 0;
+	} else {
+		efx_mcdi_display_error(efx, MC_CMD_GET_EVQ_TMR_PROPERTIES,
+				       MC_CMD_GET_EVQ_TMR_PROPERTIES_OUT_LEN,
+				       NULL, 0, rc);
+	}
+
+	return rc;
+}
+
 static int efx_ef10_get_mac_address_pf(struct efx_nic *efx, u8 *mac_address)
 {
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_MAC_ADDRESSES_OUT_LEN);
@@ -533,33 +643,11 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail5;
 
-	rc = efx_ef10_get_sysclk_freq(efx);
+	rc = efx_ef10_get_timer_config(efx);
 	if (rc < 0)
 		goto fail5;
 	efx->timer_quantum_ns = 1536000 / rc; /* 1536 cycles */
 
-	/* Check whether firmware supports bug 35388 workaround.
-	 * First try to enable it, then if we get EPERM, just
-	 * ask if it's already enabled
-	 */
-	rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG35388, true, NULL);
-	if (rc == 0) {
-		nic_data->workaround_35388 = true;
-	} else if (rc == -EPERM) {
-		unsigned int enabled;
-
-		rc = efx_mcdi_get_workarounds(efx, NULL, &enabled);
-		if (rc)
-			goto fail3;
-		nic_data->workaround_35388 = enabled &
-			MC_CMD_GET_WORKAROUNDS_OUT_BUG35388;
-	} else if (rc != -ENOSYS && rc != -ENOENT) {
-		goto fail5;
-	}
-	netif_dbg(efx, probe, efx->net_dev,
-		  "workaround for bug 35388 is %sabled\n",
-		  nic_data->workaround_35388 ? "en" : "dis");
-
 	rc = efx_mcdi_mon_probe(efx);
 	if (rc && rc != -EPERM)
 		goto fail5;
@@ -2631,11 +2719,10 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 	/* Successfully created event queue on channel 0 */
 	rc = efx_mcdi_get_workarounds(efx, &implemented, &enabled);
 	if (rc == -ENOSYS) {
-		/* GET_WORKAROUNDS was implemented before these workarounds,
-		 * thus they must be unavailable in this firmware.
+		/* GET_WORKAROUNDS was implemented before this workaround,
+		 * thus it must be unavailable in this firmware.
 		 */
 		nic_data->workaround_26807 = false;
-		nic_data->workaround_61265 = false;
 		rc = 0;
 	} else if (rc) {
 		goto fail;
@@ -2675,9 +2762,6 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 				rc = 0;
 			}
 		}
-
-		nic_data->workaround_61265 =
-			!!(implemented & MC_CMD_GET_WORKAROUNDS_OUT_BUG61265);
 	}
 
 	if (!rc)
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b26e1f9..f3826ae 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1979,12 +1979,13 @@ int efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 			    bool rx_may_override_tx)
 {
 	struct efx_channel *channel;
-	unsigned int irq_mod_max = DIV_ROUND_UP(efx->type->timer_period_max *
-						efx->timer_quantum_ns,
-						1000);
+	unsigned int timer_max_us;
+
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
-	if (tx_usecs > irq_mod_max || rx_usecs > irq_mod_max)
+	timer_max_us = efx->timer_max_ns / 1000;
+
+	if (tx_usecs > timer_max_us || rx_usecs > timer_max_us)
 		return -EINVAL;
 
 	if (tx_usecs != rx_usecs && efx->tx_channel_offset == 0 &&
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index d3d0bcc..1a70926 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2376,6 +2376,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 			     EFX_MAX_CHANNELS);
 	efx->max_tx_channels = efx->max_channels;
 	efx->timer_quantum_ns = 4968; /* 621 cycles */
+	efx->timer_max_ns = efx->type->timer_period_max *
+			    efx->timer_quantum_ns;
 
 	/* Initialise I2C adapter */
 	board = falcon_board(efx);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 3e8c6fb..13b7f52 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -810,6 +810,7 @@ struct vfdi_status;
  * @membase: Memory BAR value
  * @interrupt_mode: Interrupt mode
  * @timer_quantum_ns: Interrupt timer quantum, in nanoseconds
+ * @timer_max_ns: Interrupt timer maximum value, in nanoseconds
  * @irq_rx_adaptive: Adaptive IRQ moderation enabled for RX event queues
  * @irq_rx_mod_step_us: Step size for IRQ moderation for RX event queues
  * @irq_rx_moderation_us: IRQ moderation time for RX event queues
@@ -941,6 +942,7 @@ struct efx_nic {
 
 	enum efx_int_mode interrupt_mode;
 	unsigned int timer_quantum_ns;
+	unsigned int timer_max_ns;
 	bool irq_rx_adaptive;
 	unsigned int irq_mod_step_us;
 	unsigned int irq_rx_moderation_us;
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 994e33f..04ed1b4 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -227,6 +227,9 @@ static int siena_probe_nvconfig(struct efx_nic *efx)
 	efx->timer_quantum_ns =
 		(caps & (1 << MC_CMD_CAPABILITIES_TURBO_ACTIVE_LBN)) ?
 		3072 : 6144; /* 768 cycles */
+	efx->timer_max_ns = efx->type->timer_period_max *
+			    efx->timer_quantum_ns;
+
 	return rc;
 }
 
-- 
2.7.4
