From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next] sfc: Add per-queue statistics in ethtool
Date: Wed, 16 Jul 2014 09:16:18 +0100
Message-ID: <53C634D2.80801@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:23417 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751339AbaGPIQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 04:16:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Implement per channel software TX and RX packet counters
accessed as ethtool statistics.

This allows confirmation with MAC statistics.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c    | 58 +++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/sfc/net_driver.h |  4 +++
 drivers/net/ethernet/sfc/rx.c         |  2 ++
 drivers/net/ethernet/sfc/tx.c         |  4 +++
 4 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 74739c4..24bd066 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -360,6 +360,37 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 	return n;
 }
 
+static size_t efx_describe_per_queue_stats(struct efx_nic *efx, u8 *strings)
+{
+	size_t n_stats = 0;
+	struct efx_channel *channel;
+
+	efx_for_each_channel(channel, efx) {
+		if (efx_channel_has_tx_queues(channel)) {
+			n_stats++;
+			if (strings != NULL) {
+				snprintf(strings, ETH_GSTRING_LEN,
+					 "tx-%u.tx_packets",
+					 channel->tx_queue[0].queue /
+					 EFX_TXQ_TYPES);
+
+				strings += ETH_GSTRING_LEN;
+			}
+		}
+	}
+	efx_for_each_channel(channel, efx) {
+		if (efx_channel_has_rx_queue(channel)) {
+			n_stats++;
+			if (strings != NULL) {
+				snprintf(strings, ETH_GSTRING_LEN,
+					 "rx-%d.rx_packets", channel->channel);
+				strings += ETH_GSTRING_LEN;
+			}
+		}
+	}
+	return n_stats;
+}
+
 static int efx_ethtool_get_sset_count(struct net_device *net_dev,
 				      int string_set)
 {
@@ -368,8 +399,9 @@ static int efx_ethtool_get_sset_count(struct net_device *net_dev,
 	switch (string_set) {
 	case ETH_SS_STATS:
 		return efx->type->describe_stats(efx, NULL) +
-			EFX_ETHTOOL_SW_STAT_COUNT +
-			efx_ptp_describe_stats(efx, NULL);
+		       EFX_ETHTOOL_SW_STAT_COUNT +
+		       efx_describe_per_queue_stats(efx, NULL) +
+		       efx_ptp_describe_stats(efx, NULL);
 	case ETH_SS_TEST:
 		return efx_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
 	default:
@@ -391,6 +423,8 @@ static void efx_ethtool_get_strings(struct net_device *net_dev,
 			strlcpy(strings + i * ETH_GSTRING_LEN,
 				efx_sw_stat_desc[i].name, ETH_GSTRING_LEN);
 		strings += EFX_ETHTOOL_SW_STAT_COUNT * ETH_GSTRING_LEN;
+		strings += (efx_describe_per_queue_stats(efx, strings) *
+			    ETH_GSTRING_LEN);
 		efx_ptp_describe_stats(efx, strings);
 		break;
 	case ETH_SS_TEST:
@@ -410,6 +444,7 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	const struct efx_sw_stat_desc *stat;
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
+	struct efx_rx_queue *rx_queue;
 	int i;
 
 	spin_lock_bh(&efx->stats_lock);
@@ -445,6 +480,25 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 
 	spin_unlock_bh(&efx->stats_lock);
 
+	efx_for_each_channel(channel, efx) {
+		if (efx_channel_has_tx_queues(channel)) {
+			*data = 0;
+			efx_for_each_channel_tx_queue(tx_queue, channel) {
+				data[0] += tx_queue->tx_packets;
+			}
+			data++;
+		}
+	}
+	efx_for_each_channel(channel, efx) {
+		if (efx_channel_has_rx_queue(channel)) {
+			data[0] = 0;
+			efx_for_each_channel_rx_queue(rx_queue, channel) {
+				data[0] += rx_queue->rx_packets;
+			}
+			data++;
+		}
+	}
+
 	efx_ptp_update_stats(efx, data);
 }
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 5bdae8e..dca6409 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -249,6 +249,8 @@ struct efx_tx_queue {
 	unsigned int tso_packets;
 	unsigned int pushes;
 	unsigned int pio_packets;
+	/* Statistics to supplement MAC stats */
+	unsigned long tx_packets;
 
 	/* Members shared between paths and sometimes updated */
 	unsigned int empty_read_count ____cacheline_aligned_in_smp;
@@ -358,6 +360,8 @@ struct efx_rx_queue {
 	unsigned int recycle_count;
 	struct timer_list slow_fill;
 	unsigned int slow_fill_count;
+	/* Statistics to supplement MAC stats */
+	unsigned long rx_packets;
 };
 
 enum efx_sync_events_state {
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 48588dd..4928c59 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -528,6 +528,8 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 	struct efx_rx_buffer *rx_buf;
 
+	rx_queue->rx_packets++;
+
 	rx_buf = efx_rx_buffer(rx_queue, index);
 	rx_buf->flags |= flags;
 
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index ede8dcc..283e5f8 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -452,6 +452,8 @@ finish_packet:
 	/* Pass off to hardware */
 	efx_nic_push_buffers(tx_queue);
 
+	tx_queue->tx_packets++;
+
 	efx_tx_maybe_stop_queue(tx_queue);
 
 	return NETDEV_TX_OK;
@@ -1245,6 +1247,8 @@ static int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 
 	++tx_queue->tso_packets;
 
+	++tx_queue->tx_packets;
+
 	return 0;
 }
 
