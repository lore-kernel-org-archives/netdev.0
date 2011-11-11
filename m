From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v2 01/10] forcedeth: fix ifconfig stats on hardware without extended stats support
Date: Thu, 10 Nov 2011 17:31:26 -0800
Message-ID: <93a4143f90f2f968500b3624ffa51c8c74e3f95e.1320974990.git.david.decotigny@google.com>
References: <cover.1320974990.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320974990.git.david.decotigny@google.com>
In-Reply-To: <cover.1320974990.git.david.decotigny@google.com>
References: <cover.1320974990.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change makes sure that tx_packets/rx_bytes ifconfig counters are
updated even on NICs that don't provide hardware support for these
stats. In that case, they are updated in software.

Related commit: "forcedeth: Improve stats counters" (0bdfea8ba8)



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   34 ++++++++++++++++++++++++++----
 1 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index d24c45b..6e5213e 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -90,6 +90,7 @@
 #define DEV_HAS_STATISTICS_V2      0x0000400  /* device supports hw statistics version 2 */
 #define DEV_HAS_STATISTICS_V3      0x0000800  /* device supports hw statistics version 3 */
 #define DEV_HAS_STATISTICS_V12     0x0000600  /* device supports hw statistics version 1 and 2 */
+#define DEV_HAS_STATISTICS_V23     0x0000c00  /* device supports hw statistics version 2 and 3 */
 #define DEV_HAS_STATISTICS_V123    0x0000e00  /* device supports hw statistics version 1, 2, and 3 */
 #define DEV_HAS_TEST_EXTENDED      0x0001000  /* device supports extended diagnostic test */
 #define DEV_HAS_MGMT_UNIT          0x0002000  /* device supports management unit */
@@ -1703,12 +1704,19 @@ static struct net_device_stats *nv_get_stats(struct net_device *dev)
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* If the nic supports hw counters then retrieve latest values */
-	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_STATISTICS_V3)) {
+	if (np->driver_data & DEV_HAS_STATISTICS_V123) {
+		/* query hardware */
 		nv_get_hw_stats(dev);
 
 		/* copy to net_device stats */
-		dev->stats.tx_packets = np->estats.tx_packets;
-		dev->stats.rx_bytes = np->estats.rx_bytes;
+
+		if (np->driver_data & DEV_HAS_STATISTICS_V23) {
+			/* When HW stats are available for following
+			 * stats, we use them. Otherwise they are
+			 * updated by software. */
+			dev->stats.tx_packets = np->estats.tx_packets;
+			dev->stats.rx_bytes = np->estats.rx_bytes;
+		}
 		dev->stats.tx_bytes = np->estats.tx_bytes;
 		dev->stats.tx_fifo_errors = np->estats.tx_fifo_errors;
 		dev->stats.tx_carrier_errors = np->estats.tx_carrier_errors;
@@ -2378,8 +2386,12 @@ static int nv_tx_done(struct net_device *dev, int limit)
 		if (np->desc_ver == DESC_VER_1) {
 			if (flags & NV_TX_LASTPACKET) {
 				if (flags & NV_TX_ERROR) {
-					if ((flags & NV_TX_RETRYERROR) && !(flags & NV_TX_RETRYCOUNT_MASK))
+					if ((flags & NV_TX_RETRYERROR)
+					    && !(flags & NV_TX_RETRYCOUNT_MASK))
 						nv_legacybackoff_reseed(dev);
+				} else if (unlikely(!(np->driver_data
+						      & DEV_HAS_STATISTICS_V23))) {
+					dev->stats.tx_packets++;
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
@@ -2388,8 +2400,12 @@ static int nv_tx_done(struct net_device *dev, int limit)
 		} else {
 			if (flags & NV_TX2_LASTPACKET) {
 				if (flags & NV_TX2_ERROR) {
-					if ((flags & NV_TX2_RETRYERROR) && !(flags & NV_TX2_RETRYCOUNT_MASK))
+					if ((flags & NV_TX2_RETRYERROR)
+					    && !(flags & NV_TX2_RETRYCOUNT_MASK))
 						nv_legacybackoff_reseed(dev);
+				} else if (unlikely(!(np->driver_data
+						      & DEV_HAS_STATISTICS_V23))) {
+					dev->stats.tx_packets++;
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
@@ -2429,6 +2445,9 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 					else
 						nv_legacybackoff_reseed(dev);
 				}
+			} else if (unlikely(!(np->driver_data
+					      & DEV_HAS_STATISTICS_V23))) {
+				dev->stats.tx_packets++;
 			}
 
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
@@ -2678,6 +2697,8 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		skb->protocol = eth_type_trans(skb, dev);
 		napi_gro_receive(&np->napi, skb);
 		dev->stats.rx_packets++;
+		if (unlikely(!(np->driver_data & DEV_HAS_STATISTICS_V23)))
+			dev->stats.rx_bytes += len;
 next_pkt:
 		if (unlikely(np->get_rx.orig++ == np->last_rx.orig))
 			np->get_rx.orig = np->first_rx.orig;
@@ -2761,6 +2782,9 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			}
 			napi_gro_receive(&np->napi, skb);
 			dev->stats.rx_packets++;
+			if (unlikely(!(np->driver_data
+				       & DEV_HAS_STATISTICS_V23)))
+				dev->stats.rx_bytes += len;
 		} else {
 			dev_kfree_skb(skb);
 		}
-- 
1.7.3.1
