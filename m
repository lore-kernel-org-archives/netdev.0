From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] net: Replace u64_stats_fetch_begin_bh to u64_stats_fetch_begin_irq
Date: Thu, 13 Mar 2014 21:26:42 -0700
Message-ID: <8738il4d8d.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com> <87fvmobfnr.fsf_-_@xmission.com>
	<1394589986.21721.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140312212429.GA14893@electric-eye.fr.zoreil.com>
	<1394661695.21721.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41951 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbaCNE0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 00:26:53 -0400
In-Reply-To: <1394661695.21721.50.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 12 Mar 2014 15:01:35 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace the bh safe variant with the hard irq safe variant.

We need a hard irq safe variant to deal with netpoll transmitting
packets from hard irq context, and we need it in most if not all of
the places using the bh safe variant.  

Except on 32bit uni-processor the code is exactly the same so don't
bother with a bh variant, just have a hard irq safe variant that
everyone can use.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

It turned out this was easy so.  So here is this change to get it off of
my plate.

 block/blk-cgroup.h                                |    8 ++++----
 drivers/net/dummy.c                               |    4 ++--
 drivers/net/ethernet/broadcom/b44.c               |    8 ++++----
 drivers/net/ethernet/emulex/benet/be_ethtool.c    |   12 ++++++------
 drivers/net/ethernet/emulex/benet/be_main.c       |   16 ++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    |    8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c       |   16 ++++++++--------
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |   12 ++++++------
 drivers/net/ethernet/intel/igb/igb_main.c         |    8 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |    8 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    8 ++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    8 ++++----
 drivers/net/ethernet/marvell/mvneta.c             |    4 ++--
 drivers/net/ethernet/marvell/sky2.c               |    8 ++++----
 drivers/net/ethernet/neterion/vxge/vxge-main.c    |    8 ++++----
 drivers/net/ethernet/nvidia/forcedeth.c           |    8 ++++----
 drivers/net/ethernet/realtek/8139too.c            |    8 ++++----
 drivers/net/ethernet/realtek/r8169.c              |    8 ++++----
 drivers/net/ethernet/tile/tilepro.c               |    4 ++--
 drivers/net/ethernet/via/via-rhine.c              |    8 ++++----
 drivers/net/ifb.c                                 |    8 ++++----
 drivers/net/loopback.c                            |    4 ++--
 drivers/net/macvlan.c                             |    4 ++--
 drivers/net/nlmon.c                               |    4 ++--
 drivers/net/team/team.c                           |    4 ++--
 drivers/net/team/team_mode_loadbalance.c          |    4 ++--
 drivers/net/veth.c                                |    4 ++--
 drivers/net/virtio_net.c                          |    8 ++++----
 drivers/net/xen-netfront.c                        |    4 ++--
 include/linux/u64_stats_sync.h                    |   16 ++++++++--------
 net/8021q/vlan_dev.c                              |    4 ++--
 net/bridge/br_device.c                            |    4 ++--
 net/ipv4/af_inet.c                                |    4 ++--
 net/ipv4/ip_tunnel_core.c                         |    4 ++--
 net/ipv6/ip6_tunnel.c                             |    4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c                    |    4 ++--
 net/openvswitch/datapath.c                        |    4 ++--
 net/openvswitch/vport.c                           |    4 ++--
 38 files changed, 132 insertions(+), 132 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 86154eab9523..604f6d99ab92 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -435,9 +435,9 @@ static inline uint64_t blkg_stat_read(struct blkg_stat *stat)
 	uint64_t v;
 
 	do {
-		start = u64_stats_fetch_begin_bh(&stat->syncp);
+		start = u64_stats_fetch_begin_irq(&stat->syncp);
 		v = stat->cnt;
-	} while (u64_stats_fetch_retry_bh(&stat->syncp, start));
+	} while (u64_stats_fetch_retry_irq(&stat->syncp, start));
 
 	return v;
 }
@@ -508,9 +508,9 @@ static inline struct blkg_rwstat blkg_rwstat_read(struct blkg_rwstat *rwstat)
 	struct blkg_rwstat tmp;
 
 	do {
-		start = u64_stats_fetch_begin_bh(&rwstat->syncp);
+		start = u64_stats_fetch_begin_irq(&rwstat->syncp);
 		tmp = *rwstat;
-	} while (u64_stats_fetch_retry_bh(&rwstat->syncp, start));
+	} while (u64_stats_fetch_retry_irq(&rwstat->syncp, start));
 
 	return tmp;
 }
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 1656317c96f8..0932ffbf381b 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -63,10 +63,10 @@ static struct rtnl_link_stats64 *dummy_get_stats64(struct net_device *dev,
 
 		dstats = per_cpu_ptr(dev->dstats, i);
 		do {
-			start = u64_stats_fetch_begin_bh(&dstats->syncp);
+			start = u64_stats_fetch_begin_irq(&dstats->syncp);
 			tbytes = dstats->tx_bytes;
 			tpackets = dstats->tx_packets;
-		} while (u64_stats_fetch_retry_bh(&dstats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&dstats->syncp, start));
 		stats->tx_bytes += tbytes;
 		stats->tx_packets += tpackets;
 	}
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 8a7bf7dad898..05ba62589017 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1685,7 +1685,7 @@ static struct rtnl_link_stats64 *b44_get_stats64(struct net_device *dev,
 	unsigned int start;
 
 	do {
-		start = u64_stats_fetch_begin_bh(&hwstat->syncp);
+		start = u64_stats_fetch_begin_irq(&hwstat->syncp);
 
 		/* Convert HW stats into rtnl_link_stats64 stats. */
 		nstat->rx_packets = hwstat->rx_pkts;
@@ -1719,7 +1719,7 @@ static struct rtnl_link_stats64 *b44_get_stats64(struct net_device *dev,
 		/* Carrier lost counter seems to be broken for some devices */
 		nstat->tx_carrier_errors = hwstat->tx_carrier_lost;
 #endif
-	} while (u64_stats_fetch_retry_bh(&hwstat->syncp, start));
+	} while (u64_stats_fetch_retry_irq(&hwstat->syncp, start));
 
 	return nstat;
 }
@@ -2073,12 +2073,12 @@ static void b44_get_ethtool_stats(struct net_device *dev,
 	do {
 		data_src = &hwstat->tx_good_octets;
 		data_dst = data;
-		start = u64_stats_fetch_begin_bh(&hwstat->syncp);
+		start = u64_stats_fetch_begin_irq(&hwstat->syncp);
 
 		for (i = 0; i < ARRAY_SIZE(b44_gstrings); i++)
 			*data_dst++ = *data_src++;
 
-	} while (u64_stats_fetch_retry_bh(&hwstat->syncp, start));
+	} while (u64_stats_fetch_retry_irq(&hwstat->syncp, start));
 }
 
 static void b44_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index cf09d8faca84..252fb59f65b3 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -357,10 +357,10 @@ be_get_ethtool_stats(struct net_device *netdev,
 		struct be_rx_stats *stats = rx_stats(rxo);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&stats->sync);
+			start = u64_stats_fetch_begin_irq(&stats->sync);
 			data[base] = stats->rx_bytes;
 			data[base + 1] = stats->rx_pkts;
-		} while (u64_stats_fetch_retry_bh(&stats->sync, start));
+		} while (u64_stats_fetch_retry_irq(&stats->sync, start));
 
 		for (i = 2; i < ETHTOOL_RXSTATS_NUM; i++) {
 			p = (u8 *)stats + et_rx_stats[i].offset;
@@ -373,19 +373,19 @@ be_get_ethtool_stats(struct net_device *netdev,
 		struct be_tx_stats *stats = tx_stats(txo);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&stats->sync_compl);
+			start = u64_stats_fetch_begin_irq(&stats->sync_compl);
 			data[base] = stats->tx_compl;
-		} while (u64_stats_fetch_retry_bh(&stats->sync_compl, start));
+		} while (u64_stats_fetch_retry_irq(&stats->sync_compl, start));
 
 		do {
-			start = u64_stats_fetch_begin_bh(&stats->sync);
+			start = u64_stats_fetch_begin_irq(&stats->sync);
 			for (i = 1; i < ETHTOOL_TXSTATS_NUM; i++) {
 				p = (u8 *)stats + et_tx_stats[i].offset;
 				data[base + i] =
 					(et_tx_stats[i].size == sizeof(u64)) ?
 						*(u64 *)p : *(u32 *)p;
 			}
-		} while (u64_stats_fetch_retry_bh(&stats->sync, start));
+		} while (u64_stats_fetch_retry_irq(&stats->sync, start));
 		base += ETHTOOL_TXSTATS_NUM;
 	}
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2eee0b2577f8..768912dc6e2c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -591,10 +591,10 @@ static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
 	for_all_rx_queues(adapter, rxo, i) {
 		const struct be_rx_stats *rx_stats = rx_stats(rxo);
 		do {
-			start = u64_stats_fetch_begin_bh(&rx_stats->sync);
+			start = u64_stats_fetch_begin_irq(&rx_stats->sync);
 			pkts = rx_stats(rxo)->rx_pkts;
 			bytes = rx_stats(rxo)->rx_bytes;
-		} while (u64_stats_fetch_retry_bh(&rx_stats->sync, start));
+		} while (u64_stats_fetch_retry_irq(&rx_stats->sync, start));
 		stats->rx_packets += pkts;
 		stats->rx_bytes += bytes;
 		stats->multicast += rx_stats(rxo)->rx_mcast_pkts;
@@ -605,10 +605,10 @@ static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
 	for_all_tx_queues(adapter, txo, i) {
 		const struct be_tx_stats *tx_stats = tx_stats(txo);
 		do {
-			start = u64_stats_fetch_begin_bh(&tx_stats->sync);
+			start = u64_stats_fetch_begin_irq(&tx_stats->sync);
 			pkts = tx_stats(txo)->tx_pkts;
 			bytes = tx_stats(txo)->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&tx_stats->sync, start));
+		} while (u64_stats_fetch_retry_irq(&tx_stats->sync, start));
 		stats->tx_packets += pkts;
 		stats->tx_bytes += bytes;
 	}
@@ -1386,15 +1386,15 @@ static void be_eqd_update(struct be_adapter *adapter)
 
 		rxo = &adapter->rx_obj[eqo->idx];
 		do {
-			start = u64_stats_fetch_begin_bh(&rxo->stats.sync);
+			start = u64_stats_fetch_begin_irq(&rxo->stats.sync);
 			rx_pkts = rxo->stats.rx_pkts;
-		} while (u64_stats_fetch_retry_bh(&rxo->stats.sync, start));
+		} while (u64_stats_fetch_retry_irq(&rxo->stats.sync, start));
 
 		txo = &adapter->tx_obj[eqo->idx];
 		do {
-			start = u64_stats_fetch_begin_bh(&txo->stats.sync);
+			start = u64_stats_fetch_begin_irq(&txo->stats.sync);
 			tx_pkts = txo->stats.tx_reqs;
-		} while (u64_stats_fetch_retry_bh(&txo->stats.sync, start));
+		} while (u64_stats_fetch_retry_irq(&txo->stats.sync, start));
 
 
 		/* Skip, if wrapped around or first calculation */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b1d7d8c5cb9b..6e61691c3abe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -649,18 +649,18 @@ static void i40e_get_ethtool_stats(struct net_device *netdev,
 
 		/* process Tx ring statistics */
 		do {
-			start = u64_stats_fetch_begin_bh(&tx_ring->syncp);
+			start = u64_stats_fetch_begin_irq(&tx_ring->syncp);
 			data[i] = tx_ring->stats.packets;
 			data[i + 1] = tx_ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&tx_ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&tx_ring->syncp, start));
 
 		/* Rx ring is the 2nd half of the queue pair */
 		rx_ring = &tx_ring[1];
 		do {
-			start = u64_stats_fetch_begin_bh(&rx_ring->syncp);
+			start = u64_stats_fetch_begin_irq(&rx_ring->syncp);
 			data[i + 2] = rx_ring->stats.packets;
 			data[i + 3] = rx_ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&rx_ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&rx_ring->syncp, start));
 	}
 	rcu_read_unlock();
 	if (vsi == pf->vsi[pf->lan_vsi]) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 53f3ed2df796..9cf8d5df1362 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -376,20 +376,20 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
 			continue;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&tx_ring->syncp);
+			start = u64_stats_fetch_begin_irq(&tx_ring->syncp);
 			packets = tx_ring->stats.packets;
 			bytes   = tx_ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&tx_ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&tx_ring->syncp, start));
 
 		stats->tx_packets += packets;
 		stats->tx_bytes   += bytes;
 		rx_ring = &tx_ring[1];
 
 		do {
-			start = u64_stats_fetch_begin_bh(&rx_ring->syncp);
+			start = u64_stats_fetch_begin_irq(&rx_ring->syncp);
 			packets = rx_ring->stats.packets;
 			bytes   = rx_ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&rx_ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&rx_ring->syncp, start));
 
 		stats->rx_packets += packets;
 		stats->rx_bytes   += bytes;
@@ -770,10 +770,10 @@ void i40e_update_stats(struct i40e_vsi *vsi)
 		p = ACCESS_ONCE(vsi->tx_rings[q]);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&p->syncp);
+			start = u64_stats_fetch_begin_irq(&p->syncp);
 			packets = p->stats.packets;
 			bytes = p->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&p->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&p->syncp, start));
 		tx_b += bytes;
 		tx_p += packets;
 		tx_restart += p->tx_stats.restart_queue;
@@ -782,10 +782,10 @@ void i40e_update_stats(struct i40e_vsi *vsi)
 		/* Rx queue is part of the same block as Tx queue */
 		p = &p[1];
 		do {
-			start = u64_stats_fetch_begin_bh(&p->syncp);
+			start = u64_stats_fetch_begin_irq(&p->syncp);
 			packets = p->stats.packets;
 			bytes = p->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&p->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&p->syncp, start));
 		rx_b += bytes;
 		rx_p += packets;
 		rx_buf += p->rx_stats.alloc_buff_failed;
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index c7f574165298..ffcc423a7353 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2273,15 +2273,15 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 
 		ring = adapter->tx_ring[j];
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->tx_syncp);
+			start = u64_stats_fetch_begin_irq(&ring->tx_syncp);
 			data[i]   = ring->tx_stats.packets;
 			data[i+1] = ring->tx_stats.bytes;
 			data[i+2] = ring->tx_stats.restart_queue;
-		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->tx_syncp, start));
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->tx_syncp2);
+			start = u64_stats_fetch_begin_irq(&ring->tx_syncp2);
 			restart2  = ring->tx_stats.restart_queue2;
-		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp2, start));
+		} while (u64_stats_fetch_retry_irq(&ring->tx_syncp2, start));
 		data[i+2] += restart2;
 
 		i += IGB_TX_QUEUE_STATS_LEN;
@@ -2289,13 +2289,13 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 	for (j = 0; j < adapter->num_rx_queues; j++) {
 		ring = adapter->rx_ring[j];
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->rx_syncp);
+			start = u64_stats_fetch_begin_irq(&ring->rx_syncp);
 			data[i]   = ring->rx_stats.packets;
 			data[i+1] = ring->rx_stats.bytes;
 			data[i+2] = ring->rx_stats.drops;
 			data[i+3] = ring->rx_stats.csum_err;
 			data[i+4] = ring->rx_stats.alloc_failed;
-		} while (u64_stats_fetch_retry_bh(&ring->rx_syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->rx_syncp, start));
 		i += IGB_RX_QUEUE_STATS_LEN;
 	}
 	spin_unlock(&adapter->stats64_lock);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 42cf29d94d62..8e14c1ba0a15 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5127,10 +5127,10 @@ void igb_update_stats(struct igb_adapter *adapter,
 		}
 
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->rx_syncp);
+			start = u64_stats_fetch_begin_irq(&ring->rx_syncp);
 			_bytes = ring->rx_stats.bytes;
 			_packets = ring->rx_stats.packets;
-		} while (u64_stats_fetch_retry_bh(&ring->rx_syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->rx_syncp, start));
 		bytes += _bytes;
 		packets += _packets;
 	}
@@ -5143,10 +5143,10 @@ void igb_update_stats(struct igb_adapter *adapter,
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *ring = adapter->tx_ring[i];
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->tx_syncp);
+			start = u64_stats_fetch_begin_irq(&ring->tx_syncp);
 			_bytes = ring->tx_stats.bytes;
 			_packets = ring->tx_stats.packets;
-		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->tx_syncp, start));
 		bytes += _bytes;
 		packets += _packets;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index f2d35c04159c..beada78dba63 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1127,10 +1127,10 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		}
 
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
 			data[i]   = ring->stats.packets;
 			data[i+1] = ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 		i += 2;
 #ifdef BP_EXTENDED_STATS
 		data[i] = ring->stats.yields;
@@ -1155,10 +1155,10 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		}
 
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
 			data[i]   = ring->stats.packets;
 			data[i+1] = ring->stats.bytes;
-		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 		i += 2;
 #ifdef BP_EXTENDED_STATS
 		data[i] = ring->stats.yields;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d6451c0e8b8d..7ad4466039da 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7293,10 +7293,10 @@ static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
 
 		if (ring) {
 			do {
-				start = u64_stats_fetch_begin_bh(&ring->syncp);
+				start = u64_stats_fetch_begin_irq(&ring->syncp);
 				packets = ring->stats.packets;
 				bytes   = ring->stats.bytes;
-			} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+			} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 			stats->rx_packets += packets;
 			stats->rx_bytes   += bytes;
 		}
@@ -7309,10 +7309,10 @@ static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
 
 		if (ring) {
 			do {
-				start = u64_stats_fetch_begin_bh(&ring->syncp);
+				start = u64_stats_fetch_begin_irq(&ring->syncp);
 				packets = ring->stats.packets;
 				bytes   = ring->stats.bytes;
-			} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+			} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 			stats->tx_packets += packets;
 			stats->tx_bytes   += bytes;
 		}
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 57e0cd89b3dc..a4c7c280c612 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3337,10 +3337,10 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		ring = adapter->rx_ring[i];
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
 			bytes = ring->stats.bytes;
 			packets = ring->stats.packets;
-		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 		stats->rx_bytes += bytes;
 		stats->rx_packets += packets;
 	}
@@ -3348,10 +3348,10 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		ring = adapter->tx_ring[i];
 		do {
-			start = u64_stats_fetch_begin_bh(&ring->syncp);
+			start = u64_stats_fetch_begin_irq(&ring->syncp);
 			bytes = ring->stats.bytes;
 			packets = ring->stats.packets;
-		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&ring->syncp, start));
 		stats->tx_bytes += bytes;
 		stats->tx_packets += packets;
 	}
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 12c6a66e54d1..f3afcbdbb725 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -508,12 +508,12 @@ struct rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
 
 		cpu_stats = per_cpu_ptr(pp->stats, cpu);
 		do {
-			start = u64_stats_fetch_begin_bh(&cpu_stats->syncp);
+			start = u64_stats_fetch_begin_irq(&cpu_stats->syncp);
 			rx_packets = cpu_stats->rx_packets;
 			rx_bytes   = cpu_stats->rx_bytes;
 			tx_packets = cpu_stats->tx_packets;
 			tx_bytes   = cpu_stats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&cpu_stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, start));
 
 		stats->rx_packets += rx_packets;
 		stats->rx_bytes   += rx_bytes;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 55a37ae11440..e8daafde5f23 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3906,19 +3906,19 @@ static struct rtnl_link_stats64 *sky2_get_stats(struct net_device *dev,
 	u64 _bytes, _packets;
 
 	do {
-		start = u64_stats_fetch_begin_bh(&sky2->rx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&sky2->rx_stats.syncp);
 		_bytes = sky2->rx_stats.bytes;
 		_packets = sky2->rx_stats.packets;
-	} while (u64_stats_fetch_retry_bh(&sky2->rx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&sky2->rx_stats.syncp, start));
 
 	stats->rx_packets = _packets;
 	stats->rx_bytes = _bytes;
 
 	do {
-		start = u64_stats_fetch_begin_bh(&sky2->tx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&sky2->tx_stats.syncp);
 		_bytes = sky2->tx_stats.bytes;
 		_packets = sky2->tx_stats.packets;
-	} while (u64_stats_fetch_retry_bh(&sky2->tx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&sky2->tx_stats.syncp, start));
 
 	stats->tx_packets = _packets;
 	stats->tx_bytes = _bytes;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index c83cedd26dec..c5bb1ace4a74 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3134,12 +3134,12 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		u64 packets, bytes, multicast;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&rxstats->syncp);
+			start = u64_stats_fetch_begin_irq(&rxstats->syncp);
 
 			packets   = rxstats->rx_frms;
 			multicast = rxstats->rx_mcast;
 			bytes     = rxstats->rx_bytes;
-		} while (u64_stats_fetch_retry_bh(&rxstats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&rxstats->syncp, start));
 
 		net_stats->rx_packets += packets;
 		net_stats->rx_bytes += bytes;
@@ -3149,11 +3149,11 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		net_stats->rx_dropped += rxstats->rx_dropped;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&txstats->syncp);
+			start = u64_stats_fetch_begin_irq(&txstats->syncp);
 
 			packets = txstats->tx_frms;
 			bytes   = txstats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&txstats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&txstats->syncp, start));
 
 		net_stats->tx_packets += packets;
 		net_stats->tx_bytes += bytes;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index bad3c057ee8a..811be0bccd14 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1753,19 +1753,19 @@ nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 
 	/* software stats */
 	do {
-		syncp_start = u64_stats_fetch_begin_bh(&np->swstats_rx_syncp);
+		syncp_start = u64_stats_fetch_begin_irq(&np->swstats_rx_syncp);
 		storage->rx_packets       = np->stat_rx_packets;
 		storage->rx_bytes         = np->stat_rx_bytes;
 		storage->rx_dropped       = np->stat_rx_dropped;
 		storage->rx_missed_errors = np->stat_rx_missed_errors;
-	} while (u64_stats_fetch_retry_bh(&np->swstats_rx_syncp, syncp_start));
+	} while (u64_stats_fetch_retry_irq(&np->swstats_rx_syncp, syncp_start));
 
 	do {
-		syncp_start = u64_stats_fetch_begin_bh(&np->swstats_tx_syncp);
+		syncp_start = u64_stats_fetch_begin_irq(&np->swstats_tx_syncp);
 		storage->tx_packets = np->stat_tx_packets;
 		storage->tx_bytes   = np->stat_tx_bytes;
 		storage->tx_dropped = np->stat_tx_dropped;
-	} while (u64_stats_fetch_retry_bh(&np->swstats_tx_syncp, syncp_start));
+	} while (u64_stats_fetch_retry_irq(&np->swstats_tx_syncp, syncp_start));
 
 	/* If the nic supports hw counters then retrieve latest values */
 	if (np->driver_data & DEV_HAS_STATISTICS_V123) {
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 8cb2f357026e..2e5df148af4c 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2522,16 +2522,16 @@ rtl8139_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	netdev_stats_to_stats64(stats, &dev->stats);
 
 	do {
-		start = u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&tp->rx_stats.syncp);
 		stats->rx_packets = tp->rx_stats.packets;
 		stats->rx_bytes = tp->rx_stats.bytes;
-	} while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&tp->rx_stats.syncp, start));
 
 	do {
-		start = u64_stats_fetch_begin_bh(&tp->tx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&tp->tx_stats.syncp);
 		stats->tx_packets = tp->tx_stats.packets;
 		stats->tx_bytes = tp->tx_stats.bytes;
-	} while (u64_stats_fetch_retry_bh(&tp->tx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&tp->tx_stats.syncp, start));
 
 	return stats;
 }
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cf947337e0d6..51b20a731a70 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6590,17 +6590,17 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		rtl8169_rx_missed(dev, ioaddr);
 
 	do {
-		start = u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&tp->rx_stats.syncp);
 		stats->rx_packets = tp->rx_stats.packets;
 		stats->rx_bytes	= tp->rx_stats.bytes;
-	} while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&tp->rx_stats.syncp, start));
 
 
 	do {
-		start = u64_stats_fetch_begin_bh(&tp->tx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&tp->tx_stats.syncp);
 		stats->tx_packets = tp->tx_stats.packets;
 		stats->tx_bytes	= tp->tx_stats.bytes;
-	} while (u64_stats_fetch_retry_bh(&tp->tx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&tp->tx_stats.syncp, start));
 
 	stats->rx_dropped	= dev->stats.rx_dropped;
 	stats->tx_dropped	= dev->stats.tx_dropped;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index edb2e12a0fe2..7e33973487ee 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2068,14 +2068,14 @@ static struct rtnl_link_stats64 *tile_net_get_stats64(struct net_device *dev,
 		cpu_stats = &priv->cpu[i]->stats;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&cpu_stats->syncp);
+			start = u64_stats_fetch_begin_irq(&cpu_stats->syncp);
 			trx_packets = cpu_stats->rx_packets;
 			ttx_packets = cpu_stats->tx_packets;
 			trx_bytes   = cpu_stats->rx_bytes;
 			ttx_bytes   = cpu_stats->tx_bytes;
 			trx_errors  = cpu_stats->rx_errors;
 			trx_dropped = cpu_stats->rx_dropped;
-		} while (u64_stats_fetch_retry_bh(&cpu_stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, start));
 
 		rx_packets += trx_packets;
 		tx_packets += ttx_packets;
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index ef312bc6b865..5bc1a2d02dc1 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2070,16 +2070,16 @@ rhine_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	netdev_stats_to_stats64(stats, &dev->stats);
 
 	do {
-		start = u64_stats_fetch_begin_bh(&rp->rx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&rp->rx_stats.syncp);
 		stats->rx_packets = rp->rx_stats.packets;
 		stats->rx_bytes = rp->rx_stats.bytes;
-	} while (u64_stats_fetch_retry_bh(&rp->rx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&rp->rx_stats.syncp, start));
 
 	do {
-		start = u64_stats_fetch_begin_bh(&rp->tx_stats.syncp);
+		start = u64_stats_fetch_begin_irq(&rp->tx_stats.syncp);
 		stats->tx_packets = rp->tx_stats.packets;
 		stats->tx_bytes = rp->tx_stats.bytes;
-	} while (u64_stats_fetch_retry_bh(&rp->tx_stats.syncp, start));
+	} while (u64_stats_fetch_retry_irq(&rp->tx_stats.syncp, start));
 
 	return stats;
 }
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index c14d39bf32d0..1da36764b1a4 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -136,18 +136,18 @@ static struct rtnl_link_stats64 *ifb_stats64(struct net_device *dev,
 	unsigned int start;
 
 	do {
-		start = u64_stats_fetch_begin_bh(&dp->rsync);
+		start = u64_stats_fetch_begin_irq(&dp->rsync);
 		stats->rx_packets = dp->rx_packets;
 		stats->rx_bytes = dp->rx_bytes;
-	} while (u64_stats_fetch_retry_bh(&dp->rsync, start));
+	} while (u64_stats_fetch_retry_irq(&dp->rsync, start));
 
 	do {
-		start = u64_stats_fetch_begin_bh(&dp->tsync);
+		start = u64_stats_fetch_begin_irq(&dp->tsync);
 
 		stats->tx_packets = dp->tx_packets;
 		stats->tx_bytes = dp->tx_bytes;
 
-	} while (u64_stats_fetch_retry_bh(&dp->tsync, start));
+	} while (u64_stats_fetch_retry_irq(&dp->tsync, start));
 
 	stats->rx_dropped = dev->stats.rx_dropped;
 	stats->tx_dropped = dev->stats.tx_dropped;
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 282effee7e1c..bb96409f8c05 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -111,10 +111,10 @@ static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev,
 
 		lb_stats = per_cpu_ptr(dev->lstats, i);
 		do {
-			start = u64_stats_fetch_begin_bh(&lb_stats->syncp);
+			start = u64_stats_fetch_begin_irq(&lb_stats->syncp);
 			tbytes = lb_stats->bytes;
 			tpackets = lb_stats->packets;
-		} while (u64_stats_fetch_retry_bh(&lb_stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&lb_stats->syncp, start));
 		bytes   += tbytes;
 		packets += tpackets;
 	}
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c683ac2c8c94..753a8c23d15d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -582,13 +582,13 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 		for_each_possible_cpu(i) {
 			p = per_cpu_ptr(vlan->pcpu_stats, i);
 			do {
-				start = u64_stats_fetch_begin_bh(&p->syncp);
+				start = u64_stats_fetch_begin_irq(&p->syncp);
 				rx_packets	= p->rx_packets;
 				rx_bytes	= p->rx_bytes;
 				rx_multicast	= p->rx_multicast;
 				tx_packets	= p->tx_packets;
 				tx_bytes	= p->tx_bytes;
-			} while (u64_stats_fetch_retry_bh(&p->syncp, start));
+			} while (u64_stats_fetch_retry_irq(&p->syncp, start));
 
 			stats->rx_packets	+= rx_packets;
 			stats->rx_bytes		+= rx_bytes;
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index 14ce7de6a933..6929b03ec638 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -90,10 +90,10 @@ nlmon_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		nl_stats = per_cpu_ptr(dev->lstats, i);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&nl_stats->syncp);
+			start = u64_stats_fetch_begin_irq(&nl_stats->syncp);
 			tbytes = nl_stats->bytes;
 			tpackets = nl_stats->packets;
-		} while (u64_stats_fetch_retry_bh(&nl_stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&nl_stats->syncp, start));
 
 		packets += tpackets;
 		bytes += tbytes;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index dbc06ab3793d..33008c1d1d67 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1759,13 +1759,13 @@ team_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	for_each_possible_cpu(i) {
 		p = per_cpu_ptr(team->pcpu_stats, i);
 		do {
-			start = u64_stats_fetch_begin_bh(&p->syncp);
+			start = u64_stats_fetch_begin_irq(&p->syncp);
 			rx_packets	= p->rx_packets;
 			rx_bytes	= p->rx_bytes;
 			rx_multicast	= p->rx_multicast;
 			tx_packets	= p->tx_packets;
 			tx_bytes	= p->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&p->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&p->syncp, start));
 
 		stats->rx_packets	+= rx_packets;
 		stats->rx_bytes		+= rx_bytes;
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index d671fc3ac5ac..dbde3412ee5e 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -432,9 +432,9 @@ static void __lb_one_cpu_stats_add(struct lb_stats *acc_stats,
 	struct lb_stats tmp;
 
 	do {
-		start = u64_stats_fetch_begin_bh(syncp);
+		start = u64_stats_fetch_begin_irq(syncp);
 		tmp.tx_bytes = cpu_stats->tx_bytes;
-	} while (u64_stats_fetch_retry_bh(syncp, start));
+	} while (u64_stats_fetch_retry_irq(syncp, start));
 	acc_stats->tx_bytes += tmp.tx_bytes;
 }
 
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3aca92e80e1e..e1c77d4b80e4 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -156,10 +156,10 @@ static u64 veth_stats_one(struct pcpu_vstats *result, struct net_device *dev)
 		unsigned int start;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&stats->syncp);
+			start = u64_stats_fetch_begin_irq(&stats->syncp);
 			packets = stats->packets;
 			bytes = stats->bytes;
-		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&stats->syncp, start));
 		result->packets += packets;
 		result->bytes += bytes;
 	}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5632a99cbbd2..80d84c446962 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1000,16 +1000,16 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 		u64 tpackets, tbytes, rpackets, rbytes;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&stats->tx_syncp);
+			start = u64_stats_fetch_begin_irq(&stats->tx_syncp);
 			tpackets = stats->tx_packets;
 			tbytes   = stats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&stats->tx_syncp, start));
+		} while (u64_stats_fetch_retry_irq(&stats->tx_syncp, start));
 
 		do {
-			start = u64_stats_fetch_begin_bh(&stats->rx_syncp);
+			start = u64_stats_fetch_begin_irq(&stats->rx_syncp);
 			rpackets = stats->rx_packets;
 			rbytes   = stats->rx_bytes;
-		} while (u64_stats_fetch_retry_bh(&stats->rx_syncp, start));
+		} while (u64_stats_fetch_retry_irq(&stats->rx_syncp, start));
 
 		tot->rx_packets += rpackets;
 		tot->tx_packets += tpackets;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a38f03ded5a4..49f3b3dbbed8 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1060,13 +1060,13 @@ static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
 		unsigned int start;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&stats->syncp);
+			start = u64_stats_fetch_begin_irq(&stats->syncp);
 
 			rx_packets = stats->rx_packets;
 			tx_packets = stats->tx_packets;
 			rx_bytes = stats->rx_bytes;
 			tx_bytes = stats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&stats->syncp, start));
 
 		tot->rx_packets += rx_packets;
 		tot->tx_packets += tx_packets;
diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_sync.h
index 7bfabd20204c..4b4439e75f45 100644
--- a/include/linux/u64_stats_sync.h
+++ b/include/linux/u64_stats_sync.h
@@ -27,8 +27,8 @@
  *    (On UP, there is no seqcount_t protection, a reader allowing interrupts could
  *     read partial values)
  *
- * 7) For softirq uses, readers can use u64_stats_fetch_begin_bh() and
- *    u64_stats_fetch_retry_bh() helpers
+ * 7) For irq and softirq uses, readers can use u64_stats_fetch_begin_irq() and
+ *    u64_stats_fetch_retry_irq() helpers
  *
  * Usage :
  *
@@ -114,31 +114,31 @@ static inline bool u64_stats_fetch_retry(const struct u64_stats_sync *syncp,
 }
 
 /*
- * In case softirq handlers can update u64 counters, readers can use following helpers
+ * In case irq handlers can update u64 counters, readers can use following helpers
  * - SMP 32bit arches use seqcount protection, irq safe.
- * - UP 32bit must disable BH.
+ * - UP 32bit must disable irqs.
  * - 64bit have no problem atomically reading u64 values, irq safe.
  */
-static inline unsigned int u64_stats_fetch_begin_bh(const struct u64_stats_sync *syncp)
+static inline unsigned int u64_stats_fetch_begin_irq(const struct u64_stats_sync *syncp)
 {
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	return read_seqcount_begin(&syncp->seq);
 #else
 #if BITS_PER_LONG==32
-	local_bh_disable();
+	local_irq_disable();
 #endif
 	return 0;
 #endif
 }
 
-static inline bool u64_stats_fetch_retry_bh(const struct u64_stats_sync *syncp,
+static inline bool u64_stats_fetch_retry_irq(const struct u64_stats_sync *syncp,
 					 unsigned int start)
 {
 #if BITS_PER_LONG==32 && defined(CONFIG_SMP)
 	return read_seqcount_retry(&syncp->seq, start);
 #else
 #if BITS_PER_LONG==32
-	local_bh_enable();
+	local_irq_enable();
 #endif
 	return false;
 #endif
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b382b8e301fb..1cd88546b8ab 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -675,13 +675,13 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 
 			p = per_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats, i);
 			do {
-				start = u64_stats_fetch_begin_bh(&p->syncp);
+				start = u64_stats_fetch_begin_irq(&p->syncp);
 				rxpackets	= p->rx_packets;
 				rxbytes		= p->rx_bytes;
 				rxmulticast	= p->rx_multicast;
 				txpackets	= p->tx_packets;
 				txbytes		= p->tx_bytes;
-			} while (u64_stats_fetch_retry_bh(&p->syncp, start));
+			} while (u64_stats_fetch_retry_irq(&p->syncp, start));
 
 			stats->rx_packets	+= rxpackets;
 			stats->rx_bytes		+= rxbytes;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index e529ae6bd79e..0dd01a05bd59 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -136,9 +136,9 @@ static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
 		const struct pcpu_sw_netstats *bstats
 			= per_cpu_ptr(br->stats, cpu);
 		do {
-			start = u64_stats_fetch_begin_bh(&bstats->syncp);
+			start = u64_stats_fetch_begin_irq(&bstats->syncp);
 			memcpy(&tmp, bstats, sizeof(tmp));
-		} while (u64_stats_fetch_retry_bh(&bstats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&bstats->syncp, start));
 		sum.tx_bytes   += tmp.tx_bytes;
 		sum.tx_packets += tmp.tx_packets;
 		sum.rx_bytes   += tmp.rx_bytes;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 19ab78aca547..8c54870db792 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1505,9 +1505,9 @@ u64 snmp_fold_field64(void __percpu *mib[], int offt, size_t syncp_offset)
 		bhptr = per_cpu_ptr(mib[0], cpu);
 		syncp = (struct u64_stats_sync *)(bhptr + syncp_offset);
 		do {
-			start = u64_stats_fetch_begin_bh(syncp);
+			start = u64_stats_fetch_begin_irq(syncp);
 			v = *(((u64 *) bhptr) + offt);
-		} while (u64_stats_fetch_retry_bh(syncp, start));
+		} while (u64_stats_fetch_retry_irq(syncp, start));
 
 		res += v;
 	}
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6f847dd56dbc..b86f0a37fa7c 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -161,12 +161,12 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 		unsigned int start;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&tstats->syncp);
+			start = u64_stats_fetch_begin_irq(&tstats->syncp);
 			rx_packets = tstats->rx_packets;
 			tx_packets = tstats->tx_packets;
 			rx_bytes = tstats->rx_bytes;
 			tx_bytes = tstats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&tstats->syncp, start));
 
 		tot->rx_packets += rx_packets;
 		tot->tx_packets += tx_packets;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8ad59f4811df..e1df691d78be 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -108,12 +108,12 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 						   per_cpu_ptr(dev->tstats, i);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&tstats->syncp);
+			start = u64_stats_fetch_begin_irq(&tstats->syncp);
 			tmp.rx_packets = tstats->rx_packets;
 			tmp.rx_bytes = tstats->rx_bytes;
 			tmp.tx_packets = tstats->tx_packets;
 			tmp.tx_bytes =  tstats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&tstats->syncp, start));
 
 		sum.rx_packets += tmp.rx_packets;
 		sum.rx_bytes   += tmp.rx_bytes;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 35be035ee0ce..d6d75841352a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2177,10 +2177,10 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 		__u64 inbytes, outbytes;
 
 		do {
-			start = u64_stats_fetch_begin_bh(&u->syncp);
+			start = u64_stats_fetch_begin_irq(&u->syncp);
 			inbytes = u->ustats.inbytes;
 			outbytes = u->ustats.outbytes;
-		} while (u64_stats_fetch_retry_bh(&u->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&u->syncp, start));
 
 		seq_printf(seq, "%3X %8X %8X %8X %16LX %16LX\n",
 			   i, u->ustats.conns, u->ustats.inpkts,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 36f8872cb072..c53fe0c9697c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -606,9 +606,9 @@ static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats,
 		percpu_stats = per_cpu_ptr(dp->stats_percpu, i);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&percpu_stats->syncp);
+			start = u64_stats_fetch_begin_irq(&percpu_stats->syncp);
 			local_stats = *percpu_stats;
-		} while (u64_stats_fetch_retry_bh(&percpu_stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&percpu_stats->syncp, start));
 
 		stats->n_hit += local_stats.n_hit;
 		stats->n_missed += local_stats.n_missed;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 3b4db3220456..42c0f4a0b78c 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -277,9 +277,9 @@ void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 		percpu_stats = per_cpu_ptr(vport->percpu_stats, i);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&percpu_stats->syncp);
+			start = u64_stats_fetch_begin_irq(&percpu_stats->syncp);
 			local_stats = *percpu_stats;
-		} while (u64_stats_fetch_retry_bh(&percpu_stats->syncp, start));
+		} while (u64_stats_fetch_retry_irq(&percpu_stats->syncp, start));
 
 		stats->rx_bytes		+= local_stats.rx_bytes;
 		stats->rx_packets	+= local_stats.rx_packets;
-- 
1.7.5.4
