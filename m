From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v2] net: mv643xx_eth: remove deprecated inet_lro support
Date: Fri, 12 Apr 2013 11:20:00 +0200
Message-ID: <1365758400-12565-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365707488-28819-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Eric Dumazet <eric.dumazet@gmail.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 Soeren Moch <smoch@web.de>, Paul Mackerras <paulus@samba.org>,
 linux-arm-kernel@lists.infradead.org, Dale Farnsworth <dale@farnsworth.org>,
 Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, Florian Fainelli <florian@openwrt.org>,
 Lennert Buytenhek <buytenh@wantstofly.org>, Willy Tarreau <w@1wt.eu>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1365707488-28819-1-git-send-email-sebastian.hesselbarth@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

With recent support for GRO, there is no need to keep both LRO and
GRO. This patch therefore removes the deprecated inet_lro support
from mv643xx_eth. This is work is based on an experimental patch
provided by Eric Dumazet and Willy Tarreau.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Based-on-patch-by: Eric Dumazet <eric.dumazet@gmail.com>
Based-on-patch-by: Willy Tarreau <w@1wt.eu>
---
Changes from v1:
- also remove INET_LRO from Kconfig (Reported by Eric Dumazet)

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Florian Fainelli <florian@openwrt.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Soeren Moch <smoch@web.de>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Willy Tarreau <w@1wt.eu>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/Kconfig       |    1 -
 drivers/net/ethernet/marvell/mv643xx_eth.c |   97 +---------------------------
 2 files changed, 3 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 5170ecb..0051f0e 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -21,7 +21,6 @@ if NET_VENDOR_MARVELL
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
-	select INET_LRO
 	select PHYLIB
 	select MVMDIO
 	---help---
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index c850d04..d0afeea 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -56,8 +56,8 @@
 #include <linux/phy.h>
 #include <linux/mv643xx_eth.h>
 #include <linux/io.h>
+#include <linux/interrupt.h>
 #include <linux/types.h>
-#include <linux/inet_lro.h>
 #include <linux/slab.h>
 #include <linux/clk.h>
 
@@ -316,12 +316,6 @@ struct mib_counters {
 	u32 rx_overrun;
 };
 
-struct lro_counters {
-	u32 lro_aggregated;
-	u32 lro_flushed;
-	u32 lro_no_desc;
-};
-
 struct rx_queue {
 	int index;
 
@@ -335,9 +329,6 @@ struct rx_queue {
 	dma_addr_t rx_desc_dma;
 	int rx_desc_area_size;
 	struct sk_buff **rx_skb;
-
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_arr[8];
 };
 
 struct tx_queue {
@@ -373,8 +364,6 @@ struct mv643xx_eth_private {
 	spinlock_t mib_counters_lock;
 	struct mib_counters mib_counters;
 
-	struct lro_counters lro_counters;
-
 	struct work_struct tx_timeout_task;
 
 	struct napi_struct napi;
@@ -503,42 +492,12 @@ static void txq_maybe_wake(struct tx_queue *txq)
 	}
 }
 
-
-/* rx napi ******************************************************************/
-static int
-mv643xx_get_skb_header(struct sk_buff *skb, void **iphdr, void **tcph,
-		       u64 *hdr_flags, void *priv)
-{
-	unsigned long cmd_sts = (unsigned long)priv;
-
-	/*
-	 * Make sure that this packet is Ethernet II, is not VLAN
-	 * tagged, is IPv4, has a valid IP header, and is TCP.
-	 */
-	if ((cmd_sts & (RX_IP_HDR_OK | RX_PKT_IS_IPV4 |
-		       RX_PKT_IS_ETHERNETV2 | RX_PKT_LAYER4_TYPE_MASK |
-		       RX_PKT_IS_VLAN_TAGGED)) !=
-	    (RX_IP_HDR_OK | RX_PKT_IS_IPV4 |
-	     RX_PKT_IS_ETHERNETV2 | RX_PKT_LAYER4_TYPE_TCP_IPV4))
-		return -1;
-
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, ip_hdrlen(skb));
-	*iphdr = ip_hdr(skb);
-	*tcph = tcp_hdr(skb);
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-
-	return 0;
-}
-
 static int rxq_process(struct rx_queue *rxq, int budget)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
 	struct net_device_stats *stats = &mp->dev->stats;
-	int lro_flush_needed;
 	int rx;
 
-	lro_flush_needed = 0;
 	rx = 0;
 	while (rx < budget && rxq->rx_desc_count) {
 		struct rx_desc *rx_desc;
@@ -599,12 +558,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		skb->protocol = eth_type_trans(skb, mp->dev);
 
-		if (skb->dev->features & NETIF_F_LRO &&
-		    skb->ip_summed == CHECKSUM_UNNECESSARY) {
-			lro_receive_skb(&rxq->lro_mgr, skb, (void *)cmd_sts);
-			lro_flush_needed = 1;
-		} else
-			napi_gro_receive(&mp->napi, skb);
+		napi_gro_receive(&mp->napi, skb);
 
 		continue;
 
@@ -624,9 +578,6 @@ err:
 		dev_kfree_skb(skb);
 	}
 
-	if (lro_flush_needed)
-		lro_flush_all(&rxq->lro_mgr);
-
 	if (rx < budget)
 		mp->work_rx &= ~(1 << rxq->index);
 
@@ -1118,26 +1069,6 @@ static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
 	return stats;
 }
 
-static void mv643xx_eth_grab_lro_stats(struct mv643xx_eth_private *mp)
-{
-	u32 lro_aggregated = 0;
-	u32 lro_flushed = 0;
-	u32 lro_no_desc = 0;
-	int i;
-
-	for (i = 0; i < mp->rxq_count; i++) {
-		struct rx_queue *rxq = mp->rxq + i;
-
-		lro_aggregated += rxq->lro_mgr.stats.aggregated;
-		lro_flushed += rxq->lro_mgr.stats.flushed;
-		lro_no_desc += rxq->lro_mgr.stats.no_desc;
-	}
-
-	mp->lro_counters.lro_aggregated = lro_aggregated;
-	mp->lro_counters.lro_flushed = lro_flushed;
-	mp->lro_counters.lro_no_desc = lro_no_desc;
-}
-
 static inline u32 mib_read(struct mv643xx_eth_private *mp, int offset)
 {
 	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
@@ -1301,10 +1232,6 @@ struct mv643xx_eth_stats {
 	{ #m, FIELD_SIZEOF(struct mib_counters, m),		\
 	  -1, offsetof(struct mv643xx_eth_private, mib_counters.m) }
 
-#define LROSTAT(m)						\
-	{ #m, FIELD_SIZEOF(struct lro_counters, m),		\
-	  -1, offsetof(struct mv643xx_eth_private, lro_counters.m) }
-
 static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	SSTAT(rx_packets),
 	SSTAT(tx_packets),
@@ -1346,9 +1273,6 @@ static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	MIBSTAT(late_collision),
 	MIBSTAT(rx_discard),
 	MIBSTAT(rx_overrun),
-	LROSTAT(lro_aggregated),
-	LROSTAT(lro_flushed),
-	LROSTAT(lro_no_desc),
 };
 
 static int
@@ -1578,7 +1502,6 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
 
 	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
-	mv643xx_eth_grab_lro_stats(mp);
 
 	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
 		const struct mv643xx_eth_stats *stat;
@@ -1851,19 +1774,6 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 					nexti * sizeof(struct rx_desc);
 	}
 
-	rxq->lro_mgr.dev = mp->dev;
-	memset(&rxq->lro_mgr.stats, 0, sizeof(rxq->lro_mgr.stats));
-	rxq->lro_mgr.features = LRO_F_NAPI;
-	rxq->lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
-	rxq->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	rxq->lro_mgr.max_desc = ARRAY_SIZE(rxq->lro_arr);
-	rxq->lro_mgr.max_aggr = 32;
-	rxq->lro_mgr.frag_align_pad = 0;
-	rxq->lro_mgr.lro_arr = rxq->lro_arr;
-	rxq->lro_mgr.get_skb_header = mv643xx_get_skb_header;
-
-	memset(&rxq->lro_arr, 0, sizeof(rxq->lro_arr));
-
 	return 0;
 
 
@@ -2851,8 +2761,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->watchdog_timeo = 2 * HZ;
 	dev->base_addr = 0;
 
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_RXCSUM | NETIF_F_LRO;
+	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM;
 
-- 
1.7.10.4
