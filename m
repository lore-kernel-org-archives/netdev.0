From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next V2] igb: fix stats handling
Date: Sun, 10 Oct 2010 10:14:44 +0200
Message-ID: <1286698484.2692.205.camel@edumazet-laptop>
References: <20101005141833.20929.10943.stgit@localhost>
	 <1286289703.2796.292.camel@edumazet-laptop>
	 <1286290393.7071.38.camel@firesoul.comx.local>
	 <1286291947.2796.387.camel@edumazet-laptop>
	 <1286312479.2593.35.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
	 <AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
	 <1286335729.4861.13.camel@edumazet-laptop>
	 <1286339791.4861.26.camel@edumazet-laptop>
	 <EA929A9653AAE14F841771FB1DE5A1366027AC5DB5@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45827 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab0JJIOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Oct 2010 04:14:53 -0400
Received: by wyb28 with SMTP id 28so2200619wyb.19
        for <netdev@vger.kernel.org>; Sun, 10 Oct 2010 01:14:51 -0700 (PDT)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1366027AC5DB5@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 09 octobre 2010 =C3=A0 17:57 -0600, Tantilov, Emil S a =C3=A9=
crit :
> Eric Dumazet wrote:
> > Le mercredi 06 octobre 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9=
crit :
> >=20
> >> I'll let Intel guys doing the backporting work, but for old kernel=
s,
> >> you'll probably need to use "unsigned long" instead of "u64"
> >>=20
> >> My plan is :
> >>=20
> >> - Provide 64bit counters even on 32bit arch
> >> - with proper synchro (include/linux/u64_stats_sync.h)
> >> - Add a spinlock so we can apply Jesper patch.
> >=20
> > Here is the net-next-2.6 patch, I am currently enable to test it, t=
he
> > dev machine with IGB NIC cannot be restarted until tomorrow, my son
> > Nicolas is currently using it ;)
> >=20
> > Could you and/or Jesper test it, possibly on 32 and 64 bit kernels =
?
> >=20
> > Thanks !
> >=20
> > [PATCH net-next] igb: fix stats handling
> >=20
> > There are currently some problems with igb.
> >=20
> > - On 32bit arches, maintaining 64bit counters without proper
> > synchronization between writers and readers.
> >=20
> > - Stats updated every two seconds, as reported by Jesper.
> >    (Jesper provided a patch for this)
> >=20
> > - Potential problem between worker thread and ethtool -S
> >=20
> > This patch uses u64_stats_sync, and convert everything to be 64bit
> > safe,=20
> > SMP safe, even on 32bit arches.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  drivers/net/igb/igb.h         |    7 +-
> >  drivers/net/igb/igb_ethtool.c |   10 +-
> >  drivers/net/igb/igb_main.c    |  111 +++++++++++++++++++++++------=
---
> >  3 files changed, 94 insertions(+), 34 deletions(-)
>=20
> This patch is causing a hang when testing with 2 sessions in a while =
loop reading /proc/net/dev/ and ethtool -S. I think even just reading /=
proc/net/dev/ is sufficient, but have not confirmed it yet. I have seen=
 the hang somewhere between 15 min to an hour. Without the patch same t=
est ran 24+ hours without issues.
>=20
> There was no trace on the screen, I got this with magic sysrq:
>=20
> [15388.393579] SysRq : Show Regs=20
> [15388.397341] Modules linked in: igb [last unloaded: scsi_wait_scan]=
 [15388.404846] =20
> [15388.406889] Pid: 16218, comm: kworker/4:1 Not tainted 2.6.36-rc3-n=
et-next-igb-100810+ #2 S5520HC/S5520HC=20
> [15388.418393] EIP: 0060:[<c13fead2>] EFLAGS: 00000297 CPU: 4=20
> [15388.424908] EIP is at _raw_spin_lock+0x13/0x19=20
> [15388.430257] EAX: f6eab55c EBX: f6eab380 ECX: 00000001 EDX: 00004e4=
a [15388.437629] ESI: f6eab000 EDI: f6eab41c EBP: f3d9bf4c ESP: f3d9bf4=
c [15388.445011]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068=20
> [15388.451422] Process kworker/4:1 (pid: 16218, ti=3Df3d9a000 task=3D=
f5ce0ed0 task.ti=3Df3d9a000)=20
> [15388.461173] Stack:=20
> [15388.463796]  f3d9bf64 f8586c57 f3d9bf5c f6eab41c f6901e00 c8703cc0=
 f3d9bf90 c1041379=20
> [15388.473116] <0> 00000004 00000000 f8586b16 00000000 c8707b05 c8707=
b00 f6901e00 c8703cc4=20
> [15388.483379] <0> c8703cc0 f3d9bfb8 c1042879 c16bb640 c8703cc4 00000=
c54 c16bb640 f6901e10=20
> [15388.494219] Call Trace:=20
> [15388.497336]  [<f8586c57>] ? igb_watchdog_task+0x141/0x21a [igb]=20
> [15388.504336]  [<c1041379>] ? process_one_work+0x18e/0x265=20
> [15388.510643]  [<f8586b16>] ? igb_watchdog_task+0x0/0x21a [igb]=20
> [15388.517455]  [<c1042879>] ? worker_thread+0xf3/0x1ef=20
> [15388.523384]  [<c1042786>] ? worker_thread+0x0/0x1ef=20
> [15388.529222]  [<c104506b>] ? kthread+0x62/0x67=20
> [15388.534475]  [<c1045009>] ? kthread+0x0/0x67=20
> [15388.539623]  [<c1002d36>] ? kernel_thread_helper+0x6/0x10=20
> [15388.546034] Code: 00 75 05 f0 66 0f b1 0a 0f 94 c1 0f b6 c1 85 c0 =
0f 95 c0 0f b6 c0 5d c3 55 ba 00 01 00 00 89 e5 f0 66 0f c1 10 38 f2 74=
 06 f3 90 <8a> 10 eb f6 5d c3 55 89 e5 9c 59 fa ba 00 01 00 00 f0 66 0f=
 c1
>=20
> Thanks,
> Emil
>=20

Hi Emil, thanks for testing.

It seems one one the u64_stats_sync invariant is not met.

I believe problem comes from "restart_queue"

This one can be updated in // by two cpus.

So we can lose one of the u64_stats_update_begin() /
u64_stats_update_end() increment and freeze a reader.

So igb had a previous bug here, un-noticed :)

restart_queue can be updated by start_xmit() (so only one cpu can be
there, because of txqueue lock serialization), but it also can be
updated by the igb_clean_tx_irq() function (one cpu there too).

One solution to this problem is to use two separate counters, with two
separate syncp.

[PATCH net-next V2] igb: fix stats handling

There are currently some problems with igb.

- On 32bit arches, maintaining 64bit counters without proper
synchronization between writers and readers.

- Stats updated every two seconds, as reported by Jesper.
   (Jesper provided a patch for this)

- Potential problem between worker thread and ethtool -S

This patch uses u64_stats_sync, and convert everything to be 64bit safe=
,
SMP safe, even on 32bit arches. It integrates Jesper idea of providing
accurate stats at the time user reads them.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: Add a second restart_queue field, with separate syncp, because
original restart_queue was potentially udpated by two cpus.
   Corrected igb_get_ethtool_stats() to also use appropriate syncp,
   and do the sum of two restart_queue fields.

 drivers/net/igb/igb.h         |    9 ++
 drivers/net/igb/igb_ethtool.c |   52 ++++++++++----
 drivers/net/igb/igb_main.c    |  113 +++++++++++++++++++++++---------
 3 files changed, 129 insertions(+), 45 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 44e0ff1..edab9c4 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -159,6 +159,7 @@ struct igb_tx_queue_stats {
 	u64 packets;
 	u64 bytes;
 	u64 restart_queue;
+	u64 restart_queue2;
 };
=20
 struct igb_rx_queue_stats {
@@ -210,11 +211,14 @@ struct igb_ring {
 		/* TX */
 		struct {
 			struct igb_tx_queue_stats tx_stats;
+			struct u64_stats_sync tx_syncp;
+			struct u64_stats_sync tx_syncp2;
 			bool detect_tx_hung;
 		};
 		/* RX */
 		struct {
 			struct igb_rx_queue_stats rx_stats;
+			struct u64_stats_sync rx_syncp;
 			u32 rx_buffer_len;
 		};
 	};
@@ -288,6 +292,9 @@ struct igb_adapter {
 	struct timecompare compare;
 	struct hwtstamp_config hwtstamp_config;
=20
+	spinlock_t stats64_lock;
+	struct rtnl_link_stats64 stats64;
+
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
 	struct e1000_hw_stats stats;
@@ -357,7 +364,7 @@ extern netdev_tx_t igb_xmit_frame_ring_adv(struct s=
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
index 26bf6a1..a70e16b 100644
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
@@ -111,8 +111,9 @@ static const struct igb_stats igb_gstrings_net_stat=
s[] =3D {
 	(sizeof(igb_gstrings_net_stats) / sizeof(struct igb_stats))
 #define IGB_RX_QUEUE_STATS_LEN \
 	(sizeof(struct igb_rx_queue_stats) / sizeof(u64))
-#define IGB_TX_QUEUE_STATS_LEN \
-	(sizeof(struct igb_tx_queue_stats) / sizeof(u64))
+
+#define IGB_TX_QUEUE_STATS_LEN 3 /* packets, bytes, restart_queue */
+
 #define IGB_QUEUE_STATS_LEN \
 	((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues * \
 	  IGB_RX_QUEUE_STATS_LEN) + \
@@ -2070,12 +2071,14 @@ static void igb_get_ethtool_stats(struct net_de=
vice *netdev,
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
-	struct net_device_stats *net_stats =3D &netdev->stats;
-	u64 *queue_stat;
-	int i, j, k;
+	struct rtnl_link_stats64 *net_stats =3D &adapter->stats64;
+	unsigned int start;
+	struct igb_ring *ring;
+	int i, j;
 	char *p;
=20
-	igb_update_stats(adapter);
+	spin_lock(&adapter->stats64_lock);
+	igb_update_stats(adapter, net_stats);
=20
 	for (i =3D 0; i < IGB_GLOBAL_STATS_LEN; i++) {
 		p =3D (char *)adapter + igb_gstrings_stats[i].stat_offset;
@@ -2088,15 +2091,36 @@ static void igb_get_ethtool_stats(struct net_de=
vice *netdev,
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	for (j =3D 0; j < adapter->num_tx_queues; j++) {
-		queue_stat =3D (u64 *)&adapter->tx_ring[j]->tx_stats;
-		for (k =3D 0; k < IGB_TX_QUEUE_STATS_LEN; k++, i++)
-			data[i] =3D queue_stat[k];
+		u64	restart2;
+
+		ring =3D adapter->tx_ring[j];
+		do {
+			start =3D u64_stats_fetch_begin_bh(&ring->tx_syncp);
+			data[i]   =3D ring->tx_stats.packets;
+			data[i+1] =3D ring->tx_stats.bytes;
+			data[i+2] =3D ring->tx_stats.restart_queue;
+		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp, start));
+		do {
+			start =3D u64_stats_fetch_begin_bh(&ring->tx_syncp2);
+			restart2  =3D ring->tx_stats.restart_queue2;
+		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp2, start));
+		data[i+2] +=3D restart2;
+
+		i +=3D IGB_TX_QUEUE_STATS_LEN;
 	}
 	for (j =3D 0; j < adapter->num_rx_queues; j++) {
-		queue_stat =3D (u64 *)&adapter->rx_ring[j]->rx_stats;
-		for (k =3D 0; k < IGB_RX_QUEUE_STATS_LEN; k++, i++)
-			data[i] =3D queue_stat[k];
+		ring =3D adapter->rx_ring[j];
+		do {
+			start =3D u64_stats_fetch_begin_bh(&ring->rx_syncp);
+			data[i]   =3D ring->rx_stats.packets;
+			data[i+1] =3D ring->rx_stats.bytes;
+			data[i+2] =3D ring->rx_stats.drops;
+			data[i+3] =3D ring->rx_stats.csum_err;
+			data[i+4] =3D ring->rx_stats.alloc_failed;
+		} while (u64_stats_fetch_retry_bh(&ring->rx_syncp, start));
+		i +=3D IGB_RX_QUEUE_STATS_LEN;
 	}
+	spin_unlock(&adapter->stats64_lock);
 }
=20
 static void igb_get_strings(struct net_device *netdev, u32 stringset, =
u8 *data)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 55edcb7..c8f1249 100644
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
-	tx_ring->tx_stats.restart_queue++;
+
+	u64_stats_update_begin(&tx_ring->tx_syncp2);
+	tx_ring->tx_stats.restart_queue2++;
+	u64_stats_update_end(&tx_ring->tx_syncp2);
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
+			start =3D u64_stats_fetch_begin_bh(&ring->rx_syncp);
+			_bytes =3D ring->rx_stats.bytes;
+			_packets =3D ring->rx_stats.packets;
+		} while (u64_stats_fetch_retry_bh(&ring->rx_syncp, start));
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
+			start =3D u64_stats_fetch_begin_bh(&ring->tx_syncp);
+			_bytes =3D ring->tx_stats.bytes;
+			_packets =3D ring->tx_stats.packets;
+		} while (u64_stats_fetch_retry_bh(&ring->tx_syncp, start));
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
+			u64_stats_update_begin(&tx_ring->tx_syncp);
 			tx_ring->tx_stats.restart_queue++;
+			u64_stats_update_end(&tx_ring->tx_syncp);
 		}
 	}
=20
@@ -5437,8 +5476,10 @@ static bool igb_clean_tx_irq(struct igb_q_vector=
 *q_vector)
 	}
 	tx_ring->total_bytes +=3D total_bytes;
 	tx_ring->total_packets +=3D total_packets;
+	u64_stats_update_begin(&tx_ring->tx_syncp);
 	tx_ring->tx_stats.bytes +=3D total_bytes;
 	tx_ring->tx_stats.packets +=3D total_packets;
+	u64_stats_update_end(&tx_ring->tx_syncp);
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
+			u64_stats_update_begin(&ring->rx_syncp);
 			ring->rx_stats.csum_err++;
-
+			u64_stats_update_end(&ring->rx_syncp);
+		}
 		/* let the stack verify checksum errors */
 		return;
 	}
@@ -5669,8 +5712,10 @@ next_desc:
=20
 	rx_ring->total_packets +=3D total_packets;
 	rx_ring->total_bytes +=3D total_bytes;
+	u64_stats_update_begin(&rx_ring->rx_syncp);
 	rx_ring->rx_stats.packets +=3D total_packets;
 	rx_ring->rx_stats.bytes +=3D total_bytes;
+	u64_stats_update_end(&rx_ring->rx_syncp);
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
+					u64_stats_update_begin(&rx_ring->rx_syncp);
 					rx_ring->rx_stats.alloc_failed++;
+					u64_stats_update_end(&rx_ring->rx_syncp);
 					goto no_buffers;
 				}
 				buffer_info->page_offset =3D 0;
@@ -5714,7 +5761,9 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx=
_ring, int cleaned_count)
 			if (dma_mapping_error(rx_ring->dev,
 					      buffer_info->page_dma)) {
 				buffer_info->page_dma =3D 0;
+				u64_stats_update_begin(&rx_ring->rx_syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_syncp);
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
+				u64_stats_update_begin(&rx_ring->rx_syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_syncp);
 				goto no_buffers;
 			}
=20
@@ -5737,7 +5788,9 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx=
_ring, int cleaned_count)
 			if (dma_mapping_error(rx_ring->dev,
 					      buffer_info->dma)) {
 				buffer_info->dma =3D 0;
+				u64_stats_update_begin(&rx_ring->rx_syncp);
 				rx_ring->rx_stats.alloc_failed++;
+				u64_stats_update_end(&rx_ring->rx_syncp);
 				goto no_buffers;
 			}
 		}


