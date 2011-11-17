From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH FIX net-next v1] net-forcedeth: fix possible stats inaccuracies on 32b hosts
Date: Thu, 17 Nov 2011 11:38:23 -0800
Message-ID: <34add86253ddd91d5d4d4c7fee9c90f63a8d8edf.1321558587.git.david.decotigny@google.com>
References: <cover.1321558587.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321558587.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The software stats are updated from BH, this change ensures that 32b
UP hosts use appropriate protection.

Tested:
  - HW/SW stats consistent with pktgen (in particular tx=rx)
  - HW/SW stats consistent when tx/rx offloads disabled
  - no problem with+without lockdep (SMP 16-way)



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 0d8d5c0..4990534 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1756,19 +1756,19 @@ nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 
 	/* software stats */
 	do {
-		syncp_start = u64_stats_fetch_begin(&np->swstats_rx_syncp);
+		syncp_start = u64_stats_fetch_begin_bh(&np->swstats_rx_syncp);
 		storage->rx_packets       = np->stat_rx_packets;
 		storage->rx_bytes         = np->stat_rx_bytes;
 		storage->rx_dropped       = np->stat_rx_dropped;
 		storage->rx_missed_errors = np->stat_rx_missed_errors;
-	} while (u64_stats_fetch_retry(&np->swstats_rx_syncp, syncp_start));
+	} while (u64_stats_fetch_retry_bh(&np->swstats_rx_syncp, syncp_start));
 
 	do {
-		syncp_start = u64_stats_fetch_begin(&np->swstats_tx_syncp);
+		syncp_start = u64_stats_fetch_begin_bh(&np->swstats_tx_syncp);
 		storage->tx_packets = np->stat_tx_packets;
 		storage->tx_bytes   = np->stat_tx_bytes;
 		storage->tx_dropped = np->stat_tx_dropped;
-	} while (u64_stats_fetch_retry(&np->swstats_tx_syncp, syncp_start));
+	} while (u64_stats_fetch_retry_bh(&np->swstats_tx_syncp, syncp_start));
 
 	/* If the nic supports hw counters then retrieve latest values */
 	if (np->driver_data & DEV_HAS_STATISTICS_V123) {
-- 
1.7.3.1
