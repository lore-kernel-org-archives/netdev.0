From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/16] sfc: Correct RX dropped count for drops
 while interface is down
Date: Thu, 12 Dec 2013 23:00:55 +0000
Message-ID: <1386889255.1516.343.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43730 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab3LLXA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:00:58 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

We don't directly control RX ingress on Siena or any later
controllers, and so we cannot prevent packets from entering the RX
datapath while the RX queues are not set up.  This results in
the hardware incrementing RX_NODESC_DROP_CNT, but it's not an
error and we should not include it in error stats.

When bringing an interface up or down, pull (or wait for) stats and
count the number of packets that were dropped while the interface was
down.  Subtract this from the reported RX dropped count.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  2 ++
 drivers/net/ethernet/sfc/efx.c        | 11 ++++++++
 drivers/net/ethernet/sfc/falcon.c     | 10 +++++++
 drivers/net/ethernet/sfc/mcdi.h       |  1 +
 drivers/net/ethernet/sfc/mcdi_port.c  | 49 +++++++++++++++++++++++++++--------
 drivers/net/ethernet/sfc/net_driver.h |  5 ++++
 drivers/net/ethernet/sfc/nic.c        | 12 +++++++++
 drivers/net/ethernet/sfc/nic.h        |  1 +
 drivers/net/ethernet/sfc/siena.c      |  3 +++
 9 files changed, 83 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e9c546bdbdfe..c1b85edcb204 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -902,6 +902,7 @@ static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
 		return -EAGAIN;
 
 	/* Update derived statistics */
+	efx_nic_fix_nodesc_drop_stat(efx, &stats[EF10_STAT_rx_nodesc_drops]);
 	stats[EF10_STAT_rx_good_bytes] =
 		stats[EF10_STAT_rx_bytes] -
 		stats[EF10_STAT_rx_bytes_minus_good_bytes];
@@ -3423,6 +3424,7 @@ const struct efx_nic_type efx_hunt_a0_nic_type = {
 	.describe_stats = efx_ef10_describe_stats,
 	.update_stats = efx_ef10_update_stats,
 	.start_stats = efx_mcdi_mac_start_stats,
+	.pull_stats = efx_mcdi_mac_pull_stats,
 	.stop_stats = efx_mcdi_mac_stop_stats,
 	.set_id_led = efx_mcdi_set_id_led,
 	.push_irq_moderation = efx_ef10_push_irq_moderation,
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 5e2454d07137..c734fba8c99c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1684,6 +1684,10 @@ static void efx_start_all(struct efx_nic *efx)
 	}
 
 	efx->type->start_stats(efx);
+	efx->type->pull_stats(efx);
+	spin_lock_bh(&efx->stats_lock);
+	efx->type->update_stats(efx, NULL, NULL);
+	spin_unlock_bh(&efx->stats_lock);
 }
 
 /* Flush all delayed work. Should only be called when no more delayed work
@@ -1711,6 +1715,13 @@ static void efx_stop_all(struct efx_nic *efx)
 	if (!efx->port_enabled)
 		return;
 
+	/* update stats before we go down so we can accurately count
+	 * rx_nodesc_drops
+	 */
+	efx->type->pull_stats(efx);
+	spin_lock_bh(&efx->stats_lock);
+	efx->type->update_stats(efx, NULL, NULL);
+	spin_unlock_bh(&efx->stats_lock);
 	efx->type->stop_stats(efx);
 	efx_stop_port(efx);
 
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index ff5d322b9b49..4a9e05c82e2a 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2593,6 +2593,14 @@ void falcon_start_nic_stats(struct efx_nic *efx)
 	spin_unlock_bh(&efx->stats_lock);
 }
 
+/* We don't acutally pull stats on falcon. Wait 10ms so that
+ * they arrive when we call this just after start_stats
+ */
+void falcon_pull_nic_stats(struct efx_nic *efx)
+{
+	msleep(10);
+}
+
 void falcon_stop_nic_stats(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
@@ -2672,6 +2680,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
 	.describe_stats = falcon_describe_nic_stats,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
+	.pull_stats = falcon_pull_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
 	.set_id_led = falcon_set_id_led,
 	.push_irq_moderation = falcon_push_irq_moderation,
@@ -2765,6 +2774,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.describe_stats = falcon_describe_nic_stats,
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
+	.pull_stats = falcon_pull_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
 	.set_id_led = falcon_set_id_led,
 	.push_irq_moderation = falcon_push_irq_moderation,
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 15816cacb548..d861628b7ee6 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -301,6 +301,7 @@ int efx_mcdi_set_mac(struct efx_nic *efx);
 #define EFX_MC_STATS_GENERATION_INVALID ((__force __le64)(-1))
 void efx_mcdi_mac_start_stats(struct efx_nic *efx);
 void efx_mcdi_mac_stop_stats(struct efx_nic *efx);
+void efx_mcdi_mac_pull_stats(struct efx_nic *efx);
 bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
 enum reset_type efx_mcdi_map_reset_reason(enum reset_type reason);
 int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method);
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 7b6be61d549f..7288aefc2877 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -927,12 +927,23 @@ bool efx_mcdi_mac_check_fault(struct efx_nic *efx)
 	return MCDI_DWORD(outbuf, GET_LINK_OUT_MAC_FAULT) != 0;
 }
 
-static int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
-			      u32 dma_len, int enable, int clear)
+enum efx_stats_action {
+	EFX_STATS_ENABLE,
+	EFX_STATS_DISABLE,
+	EFX_STATS_PULL,
+};
+
+static int efx_mcdi_mac_stats(struct efx_nic *efx,
+			      enum efx_stats_action action, int clear)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
 	int rc;
-	int period = enable ? 1000 : 0;
+	int change = action == EFX_STATS_PULL ? 0 : 1;
+	int enable = action == EFX_STATS_ENABLE ? 1 : 0;
+	int period = action == EFX_STATS_ENABLE ? 1000 : 0;
+	dma_addr_t dma_addr = efx->stats_buffer.dma_addr;
+	u32 dma_len = action != EFX_STATS_DISABLE ?
+		MC_CMD_MAC_NSTATS * sizeof(u64) : 0;
 
 	BUILD_BUG_ON(MC_CMD_MAC_STATS_OUT_DMA_LEN != 0);
 
@@ -940,8 +951,8 @@ static int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 	MCDI_POPULATE_DWORD_7(inbuf, MAC_STATS_IN_CMD,
 			      MAC_STATS_IN_DMA, !!enable,
 			      MAC_STATS_IN_CLEAR, clear,
-			      MAC_STATS_IN_PERIODIC_CHANGE, 1,
-			      MAC_STATS_IN_PERIODIC_ENABLE, !!enable,
+			      MAC_STATS_IN_PERIODIC_CHANGE, change,
+			      MAC_STATS_IN_PERIODIC_ENABLE, enable,
 			      MAC_STATS_IN_PERIODIC_CLEAR, 0,
 			      MAC_STATS_IN_PERIODIC_NOEVENT, 1,
 			      MAC_STATS_IN_PERIOD_MS, period);
@@ -955,8 +966,8 @@ static int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 	return 0;
 
 fail:
-	netif_err(efx, hw, efx->net_dev, "%s: %s failed rc=%d\n",
-		  __func__, enable ? "enable" : "disable", rc);
+	netif_err(efx, hw, efx->net_dev, "%s: action %d failed rc=%d\n",
+		  __func__, action, rc);
 	return rc;
 }
 
@@ -966,13 +977,29 @@ void efx_mcdi_mac_start_stats(struct efx_nic *efx)
 
 	dma_stats[MC_CMD_MAC_GENERATION_END] = EFX_MC_STATS_GENERATION_INVALID;
 
-	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr,
-			   MC_CMD_MAC_NSTATS * sizeof(u64), 1, 0);
+	efx_mcdi_mac_stats(efx, EFX_STATS_ENABLE, 0);
 }
 
 void efx_mcdi_mac_stop_stats(struct efx_nic *efx)
 {
-	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 0);
+	efx_mcdi_mac_stats(efx, EFX_STATS_DISABLE, 0);
+}
+
+#define EFX_MAC_STATS_WAIT_US 100
+#define EFX_MAC_STATS_WAIT_ATTEMPTS 10
+
+void efx_mcdi_mac_pull_stats(struct efx_nic *efx)
+{
+	__le64 *dma_stats = efx->stats_buffer.addr;
+	int attempts = EFX_MAC_STATS_WAIT_ATTEMPTS;
+
+	dma_stats[MC_CMD_MAC_GENERATION_END] = EFX_MC_STATS_GENERATION_INVALID;
+	efx_mcdi_mac_stats(efx, EFX_STATS_PULL, 0);
+
+	while (dma_stats[MC_CMD_MAC_GENERATION_END] ==
+				EFX_MC_STATS_GENERATION_INVALID &&
+			attempts-- != 0)
+		udelay(EFX_MAC_STATS_WAIT_US);
 }
 
 int efx_mcdi_port_probe(struct efx_nic *efx)
@@ -1003,7 +1030,7 @@ int efx_mcdi_port_probe(struct efx_nic *efx)
 		  efx->stats_buffer.addr,
 		  (u64)virt_to_phys(efx->stats_buffer.addr));
 
-	efx_mcdi_mac_stats(efx, efx->stats_buffer.dma_addr, 0, 0, 1);
+	efx_mcdi_mac_stats(efx, EFX_STATS_DISABLE, 1);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index d98b3f031ab5..f47bac78b92c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -857,6 +857,9 @@ struct efx_nic {
 	struct net_device *net_dev;
 
 	struct efx_buffer stats_buffer;
+	u64 rx_nodesc_drops_total;
+	u64 rx_nodesc_drops_while_down;
+	bool rx_nodesc_drops_prev_state;
 
 	unsigned int phy_type;
 	const struct efx_phy_operations *phy_op;
@@ -960,6 +963,7 @@ struct efx_mtd_partition {
  * @update_stats: Update statistics not provided by event handling.
  *	Either argument may be %NULL.
  * @start_stats: Start the regular fetching of statistics
+ * @pull_stats: Pull stats from the NIC and wait until they arrive.
  * @stop_stats: Stop the regular fetching of statistics
  * @set_id_led: Set state of identifying LED or revert to automatic function
  * @push_irq_moderation: Apply interrupt moderation value
@@ -1078,6 +1082,7 @@ struct efx_nic_type {
 	size_t (*update_stats)(struct efx_nic *efx, u64 *full_stats,
 			       struct rtnl_link_stats64 *core_stats);
 	void (*start_stats)(struct efx_nic *efx);
+	void (*pull_stats)(struct efx_nic *efx);
 	void (*stop_stats)(struct efx_nic *efx);
 	void (*set_id_led)(struct efx_nic *efx, enum efx_led_mode mode);
 	void (*push_irq_moderation)(struct efx_channel *channel);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 9c90bf56090f..79226b19e3c4 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -519,3 +519,15 @@ void efx_nic_update_stats(const struct efx_hw_stat_desc *desc, size_t count,
 		}
 	}
 }
+
+void efx_nic_fix_nodesc_drop_stat(struct efx_nic *efx, u64 *rx_nodesc_drops)
+{
+	/* if down, or this is the first update after coming up */
+	if (!(efx->net_dev->flags & IFF_UP) || !efx->rx_nodesc_drops_prev_state)
+		efx->rx_nodesc_drops_while_down +=
+			*rx_nodesc_drops - efx->rx_nodesc_drops_total;
+	efx->rx_nodesc_drops_total = *rx_nodesc_drops;
+	efx->rx_nodesc_drops_prev_state = !!(efx->net_dev->flags & IFF_UP);
+	*rx_nodesc_drops -= efx->rx_nodesc_drops_while_down;
+}
+
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index fe71e81ee8bf..7ac9c000696f 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -775,6 +775,7 @@ size_t efx_nic_describe_stats(const struct efx_hw_stat_desc *desc, size_t count,
 void efx_nic_update_stats(const struct efx_hw_stat_desc *desc, size_t count,
 			  const unsigned long *mask, u64 *stats,
 			  const void *dma_buf, bool accumulate);
+void efx_nic_fix_nodesc_drop_stat(struct efx_nic *efx, u64 *stat);
 
 #define EFX_MAX_FLUSH_TIME 5000
 
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index d034bcd124ef..f2a7ad4c76aa 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -458,6 +458,8 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 		return -EAGAIN;
 
 	/* Update derived statistics */
+	efx_nic_fix_nodesc_drop_stat(efx,
+				     &stats[SIENA_STAT_rx_nodesc_drop_cnt]);
 	efx_update_diff_stat(&stats[SIENA_STAT_tx_good_bytes],
 			     stats[SIENA_STAT_tx_bytes] -
 			     stats[SIENA_STAT_tx_bad_bytes]);
@@ -878,6 +880,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.describe_stats = siena_describe_nic_stats,
 	.update_stats = siena_update_nic_stats,
 	.start_stats = efx_mcdi_mac_start_stats,
+	.pull_stats = efx_mcdi_mac_pull_stats,
 	.stop_stats = efx_mcdi_mac_stop_stats,
 	.set_id_led = efx_mcdi_set_id_led,
 	.push_irq_moderation = siena_push_irq_moderation,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
