From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igb: fix stats handling
Date: Wed, 06 Oct 2010 06:36:31 +0200
Message-ID: <1286339791.4861.26.camel@edumazet-laptop>
References: <20101005141833.20929.10943.stgit@localhost>
	 <1286289703.2796.292.camel@edumazet-laptop>
	 <1286290393.7071.38.camel@firesoul.comx.local>
	 <1286291947.2796.387.camel@edumazet-laptop>
	 <1286312479.2593.35.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
	 <AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
	 <1286335729.4861.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33366 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321Ab0JFEgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 00:36:36 -0400
Received: by wyb28 with SMTP id 28so6816658wyb.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 21:36:35 -0700 (PDT)
In-Reply-To: <1286335729.4861.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 octobre 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9cr=
it :

> I'll let Intel guys doing the backporting work, but for old kernels,
> you'll probably need to use "unsigned long" instead of "u64"
>=20
> My plan is :
>=20
> - Provide 64bit counters even on 32bit arch
> - with proper synchro (include/linux/u64_stats_sync.h)
> - Add a spinlock so we can apply Jesper patch.

Here is the net-next-2.6 patch, I am currently enable to test it, the
dev machine with IGB NIC cannot be restarted until tomorrow, my son
Nicolas is currently using it ;)

Could you and/or Jesper test it, possibly on 32 and 64 bit kernels ?

Thanks !

[PATCH net-next] igb: fix stats handling

There are currently some problems with igb.

- On 32bit arches, maintaining 64bit counters without proper
synchronization between writers and readers.

- Stats updated every two seconds, as reported by Jesper.
   (Jesper provided a patch for this)

- Potential problem between worker thread and ethtool -S

This patch uses u64_stats_sync, and convert everything to be 64bit safe=
,
SMP safe, even on 32bit arches.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/igb/igb.h         |    7 +-
 drivers/net/igb/igb_ethtool.c |   10 +-
 drivers/net/igb/igb_main.c    |  111 +++++++++++++++++++++++---------
 3 files changed, 94 insertions(+), 34 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 44e0ff1..a1b9584 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -159,6 +159,7 @@ struct igb_tx_queue_stats {
 	u64 packets;
 	u64 bytes;
 	u64 restart_queue;
+	struct u64_stats_sync syncp;
 };
=20
 struct igb_rx_queue_stats {
@@ -167,6 +168,7 @@ struct igb_rx_queue_stats {
 	u64 drops;
 	u64 csum_err;
 	u64 alloc_failed;
+	struct u64_stats_sync syncp;
 };
=20
 struct igb_q_vector {
@@ -288,6 +290,9 @@ struct igb_adapter {
 	struct timecompare compare;
 	struct hwtstamp_config hwtstamp_config;
=20
+	spinlock_t stats64_lock;
+	struct rtnl_link_stats64 stats64;
+
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
 	struct e1000_hw_stats stats;
@@ -357,7 +362,7 @@ extern netdev_tx_t igb_xmit_frame_ring_adv(struct s=
k_buff *, struct igb_ring *);
 extern void igb_unmap_and_free_tx_resource(struct igb_ring *,
 					   struct igb_buffer *);
 extern void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
-extern void igb_update_stats(struct igb_adapter *);
+extern void igb_update_stats(struct igb_adapter *, struct rtnl_link_st=
ats64 *);
 extern bool igb_has_link(struct igb_adapter *adapter);
 extern void igb_set_ethtool_ops(struct net_device *);
 extern void igb_power_up_link(struct igb_adapter *);
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtoo=
l.c
index 26bf6a1..e51c233 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -90,8 +90,8 @@ static const struct igb_stats igb_gstrings_stats[] =3D=
 {
=20
 #define IGB_NETDEV_STAT(_net_stat) { \
 	.stat_string =3D __stringify(_net_stat), \
-	.sizeof_stat =3D FIELD_SIZEOF(struct net_device_stats, _net_stat), \
-	.stat_offset =3D offsetof(struct net_device_stats, _net_stat) \
+	.sizeof_stat =3D FIELD_SIZEOF(struct rtnl_link_stats64, _net_stat), \
+	.stat_offset =3D offsetof(struct rtnl_link_stats64, _net_stat) \
 }
 static const struct igb_stats igb_gstrings_net_stats[] =3D {
 	IGB_NETDEV_STAT(rx_errors),
@@ -2070,12 +2070,13 @@ static void igb_get_ethtool_stats(struct net_de=
vice *netdev,
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
-	struct net_device_stats *net_stats =3D &netdev->stats;
+	struct rtnl_link_stats64 *net_stats =3D &adapter->stats64;
 	u64 *queue_stat;
 	int i, j, k;
 	char *p;
=20
-	igb_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, net_stats);
=20
 	for (i =3D 0; i < IGB_GLOBAL_STATS_LEN; i++) {
 		p =3D (char *)adapter + igb_gstrings_stats[i].stat_offset;
@@ -2097,6 +2098,7 @@ static void igb_get_ethtool_stats(struct net_devi=
ce *netdev,
 		for (k =3D 0; k < IGB_RX_QUEUE_STATS_LEN; k++, i++)
 			data[i] =3D queue_stat[k];
 	}
+	spin_unlock(&adapter->stats64_lock);
 }
=20
 static void igb_get_strings(struct net_device *netdev, u32 stringset, =
u8 *data)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 55edcb7..8a009ff 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -96,7 +96,6 @@ static int igb_setup_all_rx_resources(struct igb_adap=
ter *);
 static void igb_free_all_tx_resources(struct igb_adapter *);
 static void igb_free_all_rx_resources(struct igb_adapter *);
 static void igb_setup_mrqc(struct igb_adapter *);
-void igb_update_stats(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
 static int igb_sw_init(struct igb_adapter *);
@@ -113,7 +112,8 @@ static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
 static netdev_tx_t igb_xmit_frame_adv(struct sk_buff *skb, struct net_=
device *);
-static struct net_device_stats *igb_get_stats(struct net_device *);
+static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *de=
v,
+						 struct rtnl_link_stats64 *stats);
 static int igb_change_mtu(struct net_device *, int);
 static int igb_set_mac(struct net_device *, void *);
 static void igb_set_uta(struct igb_adapter *adapter);
@@ -1536,7 +1536,9 @@ void igb_down(struct igb_adapter *adapter)
 	netif_carrier_off(netdev);
=20
 	/* record the stats before reset*/
-	igb_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, &adapter->stats64);
+	spin_unlock(&adapter->stats64_lock);
=20
 	adapter->link_speed =3D 0;
 	adapter->link_duplex =3D 0;
@@ -1689,7 +1691,7 @@ static const struct net_device_ops igb_netdev_ops=
 =3D {
 	.ndo_open		=3D igb_open,
 	.ndo_stop		=3D igb_close,
 	.ndo_start_xmit		=3D igb_xmit_frame_adv,
-	.ndo_get_stats		=3D igb_get_stats,
+	.ndo_get_stats64	=3D igb_get_stats64,
 	.ndo_set_rx_mode	=3D igb_set_rx_mode,
 	.ndo_set_multicast_list	=3D igb_set_rx_mode,
 	.ndo_set_mac_address	=3D igb_set_mac,
@@ -2276,6 +2278,7 @@ static int __devinit igb_sw_init(struct igb_adapt=
er *adapter)
 	adapter->max_frame_size =3D netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size =3D ETH_ZLEN + ETH_FCS_LEN;
=20
+	spin_lock_init(&adapter->stats64_lock);
 #ifdef CONFIG_PCI_IOV
 	if (hw->mac.type =3D=3D e1000_82576)
 		adapter->vfs_allocated_count =3D (max_vfs > 7) ? 7 : max_vfs;
@@ -3483,7 +3486,9 @@ static void igb_watchdog_task(struct work_struct =
*work)
 		}
 	}
=20
-	igb_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, &adapter->stats64);
+	spin_unlock(&adapter->stats64_lock);
=20
 	for (i =3D 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *tx_ring =3D adapter->tx_ring[i];
@@ -3550,6 +3555,8 @@ static void igb_update_ring_itr(struct igb_q_vect=
or *q_vector)
 	int new_val =3D q_vector->itr_val;
 	int avg_wire_size =3D 0;
 	struct igb_adapter *adapter =3D q_vector->adapter;
+	struct igb_ring *ring;
+	unsigned int packets;
=20
 	/* For non-gigabit speeds, just fix the interrupt rate at 4000
 	 * ints/sec - ITR timer value of 120 ticks.
@@ -3559,16 +3566,21 @@ static void igb_update_ring_itr(struct igb_q_ve=
ctor *q_vector)
 		goto set_itr_val;
 	}
=20
-	if (q_vector->rx_ring && q_vector->rx_ring->total_packets) {
-		struct igb_ring *ring =3D q_vector->rx_ring;
-		avg_wire_size =3D ring->total_bytes / ring->total_packets;
+	ring =3D q_vector->rx_ring;
+	if (ring) {
+		packets =3D ACCESS_ONCE(ring->total_packets);
+
+		if (packets)=20
+			avg_wire_size =3D ring->total_bytes / packets;
 	}
=20
-	if (q_vector->tx_ring && q_vector->tx_ring->total_packets) {
-		struct igb_ring *ring =3D q_vector->tx_ring;
-		avg_wire_size =3D max_t(u32, avg_wire_size,
-		                      (ring->total_bytes /
-		                       ring->total_packets));
+	ring =3D q_vector->tx_ring;
+	if (ring) {
+		packets =3D ACCESS_ONCE(ring->total_packets);
+
+		if (packets)
+			avg_wire_size =3D max_t(u32, avg_wire_size,
+			                      ring->total_bytes / packets);
 	}
=20
 	/* if avg_wire_size isn't set no work was done */
@@ -4077,7 +4089,11 @@ static int __igb_maybe_stop_tx(struct igb_ring *=
tx_ring, int size)
=20
 	/* A reprieve! */
 	netif_wake_subqueue(netdev, tx_ring->queue_index);
+
+	u64_stats_update_begin(&tx_ring->tx_stats.syncp);
 	tx_ring->tx_stats.restart_queue++;
+	u64_stats_update_end(&tx_ring->tx_stats.syncp);
+
 	return 0;
 }
=20
@@ -4214,16 +4230,22 @@ static void igb_reset_task(struct work_struct *=
work)
 }
=20
 /**
- * igb_get_stats - Get System Network Statistics
+ * igb_get_stats64 - Get System Network Statistics
  * @netdev: network interface device structure
+ * @stats: rtnl_link_stats64 pointer
  *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
  **/
-static struct net_device_stats *igb_get_stats(struct net_device *netde=
v)
+static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *ne=
tdev,
+						 struct rtnl_link_stats64 *stats)
 {
-	/* only return the current stats */
-	return &netdev->stats;
+	struct igb_adapter *adapter =3D netdev_priv(netdev);
+
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, &adapter->stats64);
+	memcpy(stats, &adapter->stats64, sizeof(*stats));
+	spin_unlock(&adapter->stats64_lock);
+
+	return stats;
 }
=20
 /**
@@ -4305,15 +4327,17 @@ static int igb_change_mtu(struct net_device *ne=
tdev, int new_mtu)
  * @adapter: board private structure
  **/
=20
-void igb_update_stats(struct igb_adapter *adapter)
+void igb_update_stats(struct igb_adapter *adapter,
+		      struct rtnl_link_stats64 *net_stats)
 {
-	struct net_device_stats *net_stats =3D igb_get_stats(adapter->netdev)=
;
 	struct e1000_hw *hw =3D &adapter->hw;
 	struct pci_dev *pdev =3D adapter->pdev;
 	u32 reg, mpc;
 	u16 phy_tmp;
 	int i;
 	u64 bytes, packets;
+	unsigned int start;
+	u64 _bytes, _packets;
=20
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
=20
@@ -4331,10 +4355,17 @@ void igb_update_stats(struct igb_adapter *adapt=
er)
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
 		u32 rqdpc_tmp =3D rd32(E1000_RQDPC(i)) & 0x0FFF;
 		struct igb_ring *ring =3D adapter->rx_ring[i];
+
 		ring->rx_stats.drops +=3D rqdpc_tmp;
 		net_stats->rx_fifo_errors +=3D rqdpc_tmp;
-		bytes +=3D ring->rx_stats.bytes;
-		packets +=3D ring->rx_stats.packets;
+	=09
+		do {
+			start =3D u64_stats_fetch_begin_bh(&ring->rx_stats.syncp);
+			_bytes =3D ring->rx_stats.bytes;
+			_packets =3D ring->rx_stats.packets;
+		} while (u64_stats_fetch_retry_bh(&ring->rx_stats.syncp, start));
+		bytes +=3D _bytes;
+		packets +=3D _packets;
 	}
=20
 	net_stats->rx_bytes =3D bytes;
@@ -4344,8 +4375,13 @@ void igb_update_stats(struct igb_adapter *adapte=
r)
 	packets =3D 0;
 	for (i =3D 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *ring =3D adapter->tx_ring[i];
-		bytes +=3D ring->tx_stats.bytes;
-		packets +=3D ring->tx_stats.packets;
+		do {
+			start =3D u64_stats_fetch_begin_bh(&ring->tx_stats.syncp);
+			_bytes =3D ring->tx_stats.bytes;
+			_packets =3D ring->tx_stats.packets;
+		} while (u64_stats_fetch_retry_bh(&ring->tx_stats.syncp, start));
+		bytes +=3D _bytes;
+		packets +=3D _packets;
 	}
 	net_stats->tx_bytes =3D bytes;
 	net_stats->tx_packets =3D packets;
@@ -5397,7 +5433,10 @@ static bool igb_clean_tx_irq(struct igb_q_vector=
 *q_vector)
 		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
 		    !(test_bit(__IGB_DOWN, &adapter->state))) {
 			netif_wake_subqueue(netdev, tx_ring->queue_index);
+
+			u64_stats_update_begin(&tx_ring->tx_stats.syncp);
 			tx_ring->tx_stats.restart_queue++;
+			u64_stats_update_end(&tx_ring->tx_stats.syncp);
 		}
 	}
=20
@@ -5437,8 +5476,10 @@ static bool igb_clean_tx_irq(struct igb_q_vector=
 *q_vector)
 	}
 	tx_ring->total_bytes +=3D total_bytes;
 	tx_ring->total_packets +=3D total_packets;
+	u64_stats_update_begin(&tx_ring->tx_stats.syncp);
 	tx_ring->tx_stats.bytes +=3D total_bytes;
 	tx_ring->tx_stats.packets +=3D total_packets;
+	u64_stats_update_end(&tx_ring->tx_stats.syncp);
 	return count < tx_ring->count;
 }
=20
@@ -5480,9 +5521,11 @@ static inline void igb_rx_checksum_adv(struct ig=
b_ring *ring,
 		 * packets, (aka let the stack check the crc32c)
 		 */
 		if ((skb->len =3D=3D 60) &&
-		    (ring->flags & IGB_RING_FLAG_RX_SCTP_CSUM))
+		    (ring->flags & IGB_RING_FLAG_RX_SCTP_CSUM)) {
+			u64_stats_update_begin(&ring->rx_stats.syncp);
 			ring->rx_stats.csum_err++;
-
+			u64_stats_update_end(&ring->rx_stats.syncp);
+		}
 		/* let the stack verify checksum errors */
 		return;
 	}
@@ -5669,8 +5712,10 @@ next_desc:
=20
 	rx_ring->total_packets +=3D total_packets;
 	rx_ring->total_bytes +=3D total_bytes;
+	u64_stats_update_begin(&rx_ring->rx_stats.syncp);
 	rx_ring->rx_stats.packets +=3D total_packets;
 	rx_ring->rx_stats.bytes +=3D total_bytes;
+	u64_stats_update_end(&rx_ring->rx_stats.syncp);
 	return cleaned;
 }
=20
@@ -5698,8 +5743,10 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *r=
x_ring, int cleaned_count)
 		if ((bufsz < IGB_RXBUFFER_1024) && !buffer_info->page_dma) {
 			if (!buffer_info->page) {
 				buffer_info->page =3D netdev_alloc_page(netdev);
-				if (!buffer_info->page) {
+				if (unlikely(!buffer_info->page)) {
+					u64_stats_update_begin(&rx_ring->rx_stats.syncp);
 					rx_ring->rx_stats.alloc_failed++;
+					u64_stats_update_end(&rx_ring->rx_stats.syncp);
 					goto no_buffers;
 				}
 				buffer_info->page_offset =3D 0;
@@ -5714,7 +5761,9 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx=
_ring, int cleaned_count)
 			if (dma_mapping_error(rx_ring->dev,
 					      buffer_info->page_dma)) {
 				buffer_info->page_dma =3D 0;
+				u64_stats_update_begin(&rx_ring->rx_stats.syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_stats.syncp);
 				goto no_buffers;
 			}
 		}
@@ -5722,8 +5771,10 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *r=
x_ring, int cleaned_count)
 		skb =3D buffer_info->skb;
 		if (!skb) {
 			skb =3D netdev_alloc_skb_ip_align(netdev, bufsz);
-			if (!skb) {
+			if (unlikely(!skb)) {
+				u64_stats_update_begin(&rx_ring->rx_stats.syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_stats.syncp);
 				goto no_buffers;
 			}
=20
@@ -5737,7 +5788,9 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx=
_ring, int cleaned_count)
 			if (dma_mapping_error(rx_ring->dev,
 					      buffer_info->dma)) {
 				buffer_info->dma =3D 0;
+				u64_stats_update_begin(&rx_ring->rx_stats.syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_stats.syncp);
 				goto no_buffers;
 			}
 		}


