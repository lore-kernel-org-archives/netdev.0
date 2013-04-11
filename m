From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 20:02:59 +0200
Message-ID: <20130411180259.GO1910@1wt.eu>
References: <CABJ1b_TQDabT1J7ffo5cb1Th=71bcSduifMJaDpfVRiiHvtWDw@mail.gmail.com>
 <20130411150326.GA19978@1wt.eu>
 <CABJ1b_TRxm97DKJLP_h0VwMJvcYmSpjoJvtg1KvBNGah=VzqMQ@mail.gmail.com>
 <20130411.133119.913809939413807690.davem@davemloft.net>
 <20130411175147.GN1910@1wt.eu> <1365703155.3887.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, jason@lakedaemon.net, benh@kernel.crashing.org,
 linux-kernel@vger.kernel.org, florian@openwrt.org, smoch@web.de,
 paulus@samba.org, linux-arm-kernel@lists.infradead.org, dale@farnsworth.org,
 netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>, buytenh@wantstofly.org,
 sebastian.hesselbarth@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1365703155.3887.184.camel@edumazet-glaptop>
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

On Thu, Apr 11, 2013 at 10:59:15AM -0700, Eric Dumazet wrote:
> On Thu, 2013-04-11 at 19:51 +0200, Willy Tarreau wrote:
> 
> > Eric provided me with one such experimental patch in the past for this
> > driver. It worked for me but we never tried to clean it up to propose
> > it for inclusion.
> > 
> > If anyone is interested, I might still have it in experimental shape.
> 
> We are interested a lot ;)

Just found it in one of my local branches :-)

Here it is. It was experimental. At first glance, I'm seeing it does not
remove NETIF_F_LRO as we used it for experimentation only, but that's
a trivial thing to fix.

Original work by you Eric, tested by me on 3.6.


diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index ea2cedc..81a6cb0 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -55,9 +55,9 @@
 #include <linux/mv643xx_eth.h>
 #include <linux/io.h>
 #include <linux/types.h>
-#include <linux/inet_lro.h>
 #include <linux/slab.h>
 #include <linux/clk.h>
+#include <linux/interrupt.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
 static char mv643xx_eth_driver_version[] = "1.4";
@@ -343,12 +343,6 @@ struct mib_counters {
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
 
@@ -363,8 +357,6 @@ struct rx_queue {
 	int rx_desc_area_size;
 	void		**rx_data;
 	unsigned int frag_size;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_arr[8];
 };
 
 struct tx_queue {
@@ -400,8 +392,6 @@ struct mv643xx_eth_private {
 	spinlock_t mib_counters_lock;
 	struct mib_counters mib_counters;
 
-	struct lro_counters lro_counters;
-
 	struct work_struct tx_timeout_task;
 
 	struct napi_struct napi;
@@ -533,33 +523,6 @@ static void txq_maybe_wake(struct tx_queue *txq)
 }
 
 
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
 static void mv_frag_free(const struct rx_queue *rxq, void *data)
 {
 	if (rxq->frag_size)
@@ -568,14 +531,12 @@ static void mv_frag_free(const struct rx_queue *rxq, void *data)
 		kfree(data);
 }
 
-static int rxq_process(struct rx_queue *rxq, int budget)
+static int rxq_process(struct napi_struct *napi, struct rx_queue *rxq, int budget)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
 	struct net_device_stats *stats = &mp->dev->stats;
-	int lro_flush_needed;
 	int rx;
 
-	lro_flush_needed = 0;
 	rx = 0;
 	while (rx < budget && rxq->rx_desc_count) {
 		struct rx_desc *rx_desc;
@@ -646,12 +607,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		skb->protocol = eth_type_trans(skb, mp->dev);
 
-		if (skb->dev->features & NETIF_F_LRO &&
-		    skb->ip_summed == CHECKSUM_UNNECESSARY) {
-			lro_receive_skb(&rxq->lro_mgr, skb, (void *)cmd_sts);
-			lro_flush_needed = 1;
-		} else
-			netif_receive_skb(skb);
+		napi_gro_receive(napi, skb);
 
 		continue;
 
@@ -671,9 +627,6 @@ err:
 		dev_kfree_skb(skb);
 	}
 
-	if (lro_flush_needed)
-		lro_flush_all(&rxq->lro_mgr);
-
 	if (rx < budget)
 		mp->work_rx &= ~(1 << rxq->index);
 
@@ -723,7 +676,6 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		rxq->rx_data[rx] = data;
 		wmb();
 		rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
-
 	}
 
 	if (refilled < budget)
@@ -1214,26 +1166,6 @@ static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
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
@@ -1397,10 +1329,6 @@ struct mv643xx_eth_stats {
 	{ #m, FIELD_SIZEOF(struct mib_counters, m),		\
 	  -1, offsetof(struct mv643xx_eth_private, mib_counters.m) }
 
-#define LROSTAT(m)						\
-	{ #m, FIELD_SIZEOF(struct lro_counters, m),		\
-	  -1, offsetof(struct mv643xx_eth_private, lro_counters.m) }
-
 static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	SSTAT(rx_packets),
 	SSTAT(tx_packets),
@@ -1442,9 +1370,6 @@ static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	MIBSTAT(late_collision),
 	MIBSTAT(rx_discard),
 	MIBSTAT(rx_overrun),
-	LROSTAT(lro_aggregated),
-	LROSTAT(lro_flushed),
-	LROSTAT(lro_no_desc),
 };
 
 static int
@@ -1642,7 +1567,6 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
 
 	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
-	mv643xx_eth_grab_lro_stats(mp);
 
 	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
 		const struct mv643xx_eth_stats *stat;
@@ -1915,19 +1839,6 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
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
 
 
@@ -2192,7 +2103,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 			work_done += txq_reclaim(mp->txq + queue, work_tbd, 0);
 			txq_maybe_wake(mp->txq + queue);
 		} else if (mp->work_rx & queue_mask) {
-			work_done += rxq_process(mp->rxq + queue, work_tbd);
+			work_done += rxq_process(napi, mp->rxq + queue, work_tbd);
 		} else if (!mp->oom && (mp->work_rx_refill & queue_mask)) {
 			work_done += rxq_refill(mp->rxq + queue, work_tbd);
 		} else {

Regards,
Willy
