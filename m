From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v4 1/8] forcedeth: fix stats on hardware without extended stats support
Date: Tue, 15 Nov 2011 11:25:34 -0800
Message-ID: <6be75e56196a0f77b2eda0a7742e439de6255172.1321384662.git.david.decotigny@google.com>
References: <cover.1321384662.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	david decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
In-Reply-To: <cover.1321384662.git.david.decotigny@google.com>
References: <cover.1321384662.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: david decotigny <david.decotigny@google.com>

This change makes sure that tx_packets/rx_bytes ifconfig counters are
updated even on NICs that don't provide hardware support for these
stats: they are now updated in software. For the sake of consistency,
we also now have tx_bytes updated in software (hardware counters
include ethernet CRC, and software doesn't account for it).

This reverts parts of:
 - "forcedeth: statistics optimization" (21828163b2)
 - "forcedeth: Improve stats counters" (0bdfea8ba8)
 - "forcedeth: remove unneeded stats updates" (4687f3f364)

Tested:
  pktgen + loopback (http://patchwork.ozlabs.org/patch/124698/)
  reports identical tx_packets/rx_packets and tx_bytes/rx_bytes.

Signed-off-by: David Decotigny <david.decotigny@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
(cherry picked from commit 898bdf2cb43eb0a962c397eb4dd1aec2c7211be2)


---
 drivers/net/ethernet/nvidia/forcedeth.c |   36 +++++++++++++++++++++++-------
 1 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index e8a5ae3..374625b 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -609,7 +609,7 @@ struct nv_ethtool_str {
 };
 
 static const struct nv_ethtool_str nv_estats_str[] = {
-	{ "tx_bytes" },
+	{ "tx_bytes" }, /* includes Ethernet FCS CRC */
 	{ "tx_zero_rexmt" },
 	{ "tx_one_rexmt" },
 	{ "tx_many_rexmt" },
@@ -637,7 +637,7 @@ static const struct nv_ethtool_str nv_estats_str[] = {
 	/* version 2 stats */
 	{ "tx_deferral" },
 	{ "tx_packets" },
-	{ "rx_bytes" },
+	{ "rx_bytes" }, /* includes Ethernet FCS CRC */
 	{ "tx_pause" },
 	{ "rx_pause" },
 	{ "rx_drop_frame" },
@@ -649,7 +649,7 @@ static const struct nv_ethtool_str nv_estats_str[] = {
 };
 
 struct nv_ethtool_stats {
-	u64 tx_bytes;
+	u64 tx_bytes; /* should be ifconfig->tx_bytes + 4*tx_packets */
 	u64 tx_zero_rexmt;
 	u64 tx_one_rexmt;
 	u64 tx_many_rexmt;
@@ -670,14 +670,14 @@ struct nv_ethtool_stats {
 	u64 rx_unicast;
 	u64 rx_multicast;
 	u64 rx_broadcast;
-	u64 rx_packets;
+	u64 rx_packets; /* should be ifconfig->rx_packets */
 	u64 rx_errors_total;
 	u64 tx_errors_total;
 
 	/* version 2 stats */
 	u64 tx_deferral;
-	u64 tx_packets;
-	u64 rx_bytes;
+	u64 tx_packets; /* should be ifconfig->tx_packets */
+	u64 rx_bytes;   /* should be ifconfig->rx_bytes + 4*rx_packets */
 	u64 tx_pause;
 	u64 rx_pause;
 	u64 rx_drop_frame;
@@ -1706,10 +1706,17 @@ static struct net_device_stats *nv_get_stats(struct net_device *dev)
 	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_STATISTICS_V3)) {
 		nv_get_hw_stats(dev);
 
+		/*
+		 * Note: because HW stats are not always available and
+		 * for consistency reasons, the following ifconfig
+		 * stats are managed by software: rx_bytes, tx_bytes,
+		 * rx_packets and tx_packets. The related hardware
+		 * stats reported by ethtool should be equivalent to
+		 * these ifconfig stats, with 4 additional bytes per
+		 * packet (Ethernet FCS CRC).
+		 */
+
 		/* copy to net_device stats */
-		dev->stats.tx_packets = np->estats.tx_packets;
-		dev->stats.rx_bytes = np->estats.rx_bytes;
-		dev->stats.tx_bytes = np->estats.tx_bytes;
 		dev->stats.tx_fifo_errors = np->estats.tx_fifo_errors;
 		dev->stats.tx_carrier_errors = np->estats.tx_carrier_errors;
 		dev->stats.rx_crc_errors = np->estats.rx_crc_errors;
@@ -2380,6 +2387,9 @@ static int nv_tx_done(struct net_device *dev, int limit)
 				if (flags & NV_TX_ERROR) {
 					if ((flags & NV_TX_RETRYERROR) && !(flags & NV_TX_RETRYCOUNT_MASK))
 						nv_legacybackoff_reseed(dev);
+				} else {
+					dev->stats.tx_packets++;
+					dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
@@ -2390,6 +2400,9 @@ static int nv_tx_done(struct net_device *dev, int limit)
 				if (flags & NV_TX2_ERROR) {
 					if ((flags & NV_TX2_RETRYERROR) && !(flags & NV_TX2_RETRYCOUNT_MASK))
 						nv_legacybackoff_reseed(dev);
+				} else {
+					dev->stats.tx_packets++;
+					dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
@@ -2429,6 +2442,9 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 					else
 						nv_legacybackoff_reseed(dev);
 				}
+			} else {
+				dev->stats.tx_packets++;
+				dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 			}
 
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
@@ -2678,6 +2694,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb->protocol = eth_type_trans(skb, dev);
 		napi_gro_receive(&np->napi, skb);
 		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
 next_pkt:
 		if (unlikely(np->get_rx.orig++ == np->last_rx.orig))
 			np->get_rx.orig = np->first_rx.orig;
@@ -2761,6 +2778,7 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			}
 			napi_gro_receive(&np->napi, skb);
 			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += len;
 		} else {
 			dev_kfree_skb(skb);
 		}
-- 
1.7.3.1
