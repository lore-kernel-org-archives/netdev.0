From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 07/18] net/ena: refactor ena_get_stats64 to be atomic context safe
Date: Sun, 20 Nov 2016 10:45:36 +0200
Message-ID: <1479631547-29354-8-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ndo_get_stat64 can be called from atomic context.
However the current implementation sends an admin command to retrieve
the statistics from the device.
This admin commands uses sleep.

Refactor the implementation of ena_get_stats64 to take the
{rx,tx}bytes/cnt from the driver's inner counters
and to take the rx drops counter
from the asynchronous keep alive (heart bit) event.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_admin_defs.h |  8 ++++
 drivers/net/ethernet/amazon/ena/ena_netdev.c     | 57 +++++++++++++++++-------
 drivers/net/ethernet/amazon/ena/ena_netdev.h     |  1 +
 3 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
index c78f0b2..35ae511 100644
--- a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
+++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
@@ -904,6 +904,14 @@ struct ena_admin_aenq_link_change_desc {
 	u32 flags;
 };
 
+struct ena_admin_aenq_keep_alive_desc {
+	struct ena_admin_aenq_common_desc aenq_common_desc;
+
+	u32 rx_drops_low;
+
+	u32 rx_drops_high;
+};
+
 struct ena_admin_ena_mmio_req_read_less_resp {
 	u16 req_id;
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index e7dda8b..44dc298 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2185,28 +2185,46 @@ static struct rtnl_link_stats64 *ena_get_stats64(struct net_device *netdev,
 						 struct rtnl_link_stats64 *stats)
 {
 	struct ena_adapter *adapter = netdev_priv(netdev);
-	struct ena_admin_basic_stats ena_stats;
-	int rc;
+	struct ena_ring *rx_ring, *tx_ring;
+	unsigned int start;
+	u64 rx_drops;
+	int i;
 
 	if (!test_bit(ENA_FLAG_DEV_UP, &adapter->flags))
 		return NULL;
 
-	rc = ena_com_get_dev_basic_stats(adapter->ena_dev, &ena_stats);
-	if (rc)
-		return NULL;
+	for (i = 0; i < adapter->num_queues; i++) {
+		u64 bytes, packets;
+
+		tx_ring = &adapter->tx_ring[i];
+
+		do {
+			start = u64_stats_fetch_begin_irq(&tx_ring->syncp);
+			packets = tx_ring->tx_stats.cnt;
+			bytes = tx_ring->tx_stats.bytes;
+		} while (u64_stats_fetch_retry_irq(&tx_ring->syncp, start));
+
+		stats->tx_packets += packets;
+		stats->tx_bytes += bytes;
 
-	stats->tx_bytes = ((u64)ena_stats.tx_bytes_high << 32) |
-		ena_stats.tx_bytes_low;
-	stats->rx_bytes = ((u64)ena_stats.rx_bytes_high << 32) |
-		ena_stats.rx_bytes_low;
+		rx_ring = &adapter->rx_ring[i];
+
+		do {
+			start = u64_stats_fetch_begin_irq(&rx_ring->syncp);
+			packets = rx_ring->rx_stats.cnt;
+			bytes = rx_ring->rx_stats.bytes;
+		} while (u64_stats_fetch_retry_irq(&rx_ring->syncp, start));
 
-	stats->rx_packets = ((u64)ena_stats.rx_pkts_high << 32) |
-		ena_stats.rx_pkts_low;
-	stats->tx_packets = ((u64)ena_stats.tx_pkts_high << 32) |
-		ena_stats.tx_pkts_low;
+		stats->rx_packets += packets;
+		stats->rx_bytes += bytes;
+	}
+
+	do {
+		start = u64_stats_fetch_begin_irq(&rx_ring->syncp);
+		rx_drops = adapter->dev_stats.rx_drops;
+	} while (u64_stats_fetch_retry_irq(&rx_ring->syncp, start));
 
-	stats->rx_dropped = ((u64)ena_stats.rx_drops_high << 32) |
-		ena_stats.rx_drops_low;
+	stats->rx_dropped = rx_drops;
 
 	stats->multicast = 0;
 	stats->collisions = 0;
@@ -3272,8 +3290,17 @@ static void ena_keep_alive_wd(void *adapter_data,
 			      struct ena_admin_aenq_entry *aenq_e)
 {
 	struct ena_adapter *adapter = (struct ena_adapter *)adapter_data;
+	struct ena_admin_aenq_keep_alive_desc *desc;
+	u64 rx_drops;
 
+	desc = (struct ena_admin_aenq_keep_alive_desc *)aenq_e;
 	adapter->last_keep_alive_jiffies = jiffies;
+
+	rx_drops = ((u64)desc->rx_drops_high << 32) | desc->rx_drops_low;
+
+	u64_stats_update_begin(&adapter->syncp);
+	adapter->dev_stats.rx_drops = rx_drops;
+	u64_stats_update_end(&adapter->syncp);
 }
 
 static void ena_notification(void *adapter_data,
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index f8ef1f0..2897fab 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -251,6 +251,7 @@ struct ena_stats_dev {
 	u64 interface_up;
 	u64 interface_down;
 	u64 admin_q_pause;
+	u64 rx_drops;
 };
 
 enum ena_flags_t {
-- 
1.9.1
