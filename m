From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/16] sfc: EFX_WORKAROUND_ALWAYS is really
 specific to Falcon-architecture
Date: Tue, 27 Aug 2013 21:38:56 +0100
Message-ID: <1377635936.13272.71.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:62540 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab3H0Ui7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:38:59 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The workarounds that currently use EFX_WORKAROUND_ALWAYS are in
Falcon-specific or Falcon-arch-specific code, so get rid of the
conditions altogether.  Add/move comments as appropriate.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c      | 35 ++++++++++++++--------------------
 drivers/net/ethernet/sfc/farch.c       | 10 +++++-----
 drivers/net/ethernet/sfc/workarounds.h | 10 ----------
 3 files changed, 19 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 17bd7dc..0fd8a88 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -686,7 +686,7 @@ static void falcon_ack_status_intr(struct efx_nic *efx)
 		return;
 
 	/* We expect xgmii faults if the wireside link is down */
-	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up)
+	if (!efx->link_state.up)
 		return;
 
 	/* We can only use this interrupt to signal the negative edge of
@@ -795,29 +795,22 @@ static void falcon_reconfigure_xgxs_core(struct efx_nic *efx)
 	bool xgxs_loopback = (efx->loopback_mode == LOOPBACK_XGXS);
 	bool xaui_loopback = (efx->loopback_mode == LOOPBACK_XAUI);
 	bool xgmii_loopback = (efx->loopback_mode == LOOPBACK_XGMII);
+	bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
 
 	/* XGXS block is flaky and will need to be reset if moving
 	 * into our out of XGMII, XGXS or XAUI loopbacks. */
-	if (EFX_WORKAROUND_5147(efx)) {
-		bool old_xgmii_loopback, old_xgxs_loopback, old_xaui_loopback;
-		bool reset_xgxs;
-
-		efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
-		old_xgxs_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN);
-		old_xgmii_loopback =
-			EFX_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN);
-
-		efx_reado(efx, &reg, FR_AB_XX_SD_CTL);
-		old_xaui_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_LPBKA);
+	efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
+	old_xgxs_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_XGXS_LB_EN);
+	old_xgmii_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_XGMII_LB_EN);
 
-		/* The PHY driver may have turned XAUI off */
-		reset_xgxs = ((xgxs_loopback != old_xgxs_loopback) ||
-			      (xaui_loopback != old_xaui_loopback) ||
-			      (xgmii_loopback != old_xgmii_loopback));
+	efx_reado(efx, &reg, FR_AB_XX_SD_CTL);
+	old_xaui_loopback = EFX_OWORD_FIELD(reg, FRF_AB_XX_LPBKA);
 
-		if (reset_xgxs)
-			falcon_reset_xaui(efx);
-	}
+	/* The PHY driver may have turned XAUI off */
+	if ((xgxs_loopback != old_xgxs_loopback) ||
+	    (xaui_loopback != old_xaui_loopback) ||
+	    (xgmii_loopback != old_xgmii_loopback))
+		falcon_reset_xaui(efx);
 
 	efx_reado(efx, &reg, FR_AB_XX_CORE_STAT);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_XX_FORCE_SIG,
@@ -946,8 +939,8 @@ static void falcon_poll_xmac(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 
-	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up ||
-	    !nic_data->xmac_poll_required)
+	/* We expect xgmii faults if the wireside link is down */
+	if (!efx->link_state.up || !nic_data->xmac_poll_required)
 		return;
 
 	nic_data->xmac_poll_required = !falcon_xmac_link_ok_retry(efx, 1);
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index c3d07c5..7f50882 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -830,8 +830,7 @@ efx_farch_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 		netif_tx_lock(efx->net_dev);
 		efx_farch_notify_tx_desc(tx_queue);
 		netif_tx_unlock(efx->net_dev);
-	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_PKT_ERR) &&
-		   EFX_WORKAROUND_10727(efx)) {
+	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_PKT_ERR)) {
 		efx_schedule_reset(efx, RESET_TYPE_TX_DESC_FETCH);
 	} else {
 		netif_err(efx, tx_err, efx->net_dev,
@@ -1531,8 +1530,7 @@ irqreturn_t efx_farch_legacy_interrupt(int irq, void *dev_id)
 	}
 
 	if (queues != 0) {
-		if (EFX_WORKAROUND_15783(efx))
-			efx->irq_zero_count = 0;
+		efx->irq_zero_count = 0;
 
 		/* Schedule processing of any interrupting queues */
 		if (likely(soft_enabled)) {
@@ -1544,9 +1542,11 @@ irqreturn_t efx_farch_legacy_interrupt(int irq, void *dev_id)
 		}
 		result = IRQ_HANDLED;
 
-	} else if (EFX_WORKAROUND_15783(efx)) {
+	} else {
 		efx_qword_t *event;
 
+		/* Legacy ISR read can return zero once (SF bug 15783) */
+
 		/* We can't return IRQ_HANDLED more than once on seeing ISR=0
 		 * because this might be a shared interrupt. */
 		if (efx->irq_zero_count++ == 0)
diff --git a/drivers/net/ethernet/sfc/workarounds.h b/drivers/net/ethernet/sfc/workarounds.h
index dff565a..7e5be1d 100644
--- a/drivers/net/ethernet/sfc/workarounds.h
+++ b/drivers/net/ethernet/sfc/workarounds.h
@@ -15,25 +15,15 @@
  * Bug numbers are from Solarflare's Bugzilla.
  */
 
-#define EFX_WORKAROUND_ALWAYS(efx) 1
 #define EFX_WORKAROUND_FALCON_A(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_A1)
 #define EFX_WORKAROUND_FALCON_AB(efx) (efx_nic_rev(efx) <= EFX_REV_FALCON_B0)
 #define EFX_WORKAROUND_SIENA(efx) (efx_nic_rev(efx) == EFX_REV_SIENA_A0)
 #define EFX_WORKAROUND_10G(efx) 1
 
-/* XAUI resets if link not detected */
-#define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
-/* RX PCIe double split performance issue */
-#define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
 /* Bit-bashed I2C reads cause performance drop */
 #define EFX_WORKAROUND_7884 EFX_WORKAROUND_10G
-/* TX_EV_PKT_ERR can be caused by a dangling TX descriptor
- * or a PCIe error (bug 11028) */
-#define EFX_WORKAROUND_10727 EFX_WORKAROUND_ALWAYS
 /* Truncated IPv4 packets can confuse the TX packet parser */
 #define EFX_WORKAROUND_15592 EFX_WORKAROUND_FALCON_AB
-/* Legacy ISR read can return zero once */
-#define EFX_WORKAROUND_15783 EFX_WORKAROUND_ALWAYS
 /* Legacy interrupt storm when interrupt fifo fills */
 #define EFX_WORKAROUND_17213 EFX_WORKAROUND_SIENA
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
