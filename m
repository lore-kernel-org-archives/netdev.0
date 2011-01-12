From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: remove dev_txq_stats_fold()
Date: Wed, 12 Jan 2011 23:13:14 +0100
Message-ID: <1294870394.3335.75.camel@edumazet-laptop>
References: <20110112122811.GA9513@ff.dom.local>
	 <1294837632.3981.18.camel@edumazet-laptop>
	 <20110112132314.GA9920@ff.dom.local>
	 <1294839140.3981.23.camel@edumazet-laptop>
	 <1294840379.3981.31.camel@edumazet-laptop>
	 <1294844520.3981.84.camel@edumazet-laptop>
	 <20110112210518.GA2152@del.dom.local> <20110112211806.GB2152@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	David Brownell <david-b@pacbell.net>,
	Neil Jones <neiljay@gmail.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	Sandeep Gopalpet <sandeep.kumar@freescale.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34167 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab1ALWNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 17:13:21 -0500
In-Reply-To: <20110112211806.GB2152@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 janvier 2011 =C3=A0 22:18 +0100, Jarek Poplawski a =C3=A9=
crit :
> Btw, I updated Michal's email (according to linux-kernel).
>=20
> Jarek P.
>=20
> On Wed, Jan 12, 2011 at 10:05:18PM +0100, Jarek Poplawski wrote:
> > On Wed, Jan 12, 2011 at 04:02:00PM +0100, Eric Dumazet wrote:
> > > Le mercredi 12 janvier 2011 ?? 14:52 +0100, Eric Dumazet a =C3=A9=
crit :
> > >=20
> > > > Or even better, remove these counters since there is no users l=
eft but
> > > > ixgbe.
> > > >=20
> > > > (vlans, tunnels, ... now use percpu stats)
> > > >=20
> > > >=20
> > >=20
> > > Thanks Jarek for the reminder :)
> > >=20
> > > [PATCH] net: remove dev_txq_stats_fold()
> > >=20
> > > After recent changes, (percpu stats on vlan/tunnels...), we dont =
need
> > > anymore per struct netdev_queue tx_bytes/tx_packets/tx_dropped co=
unters.
> > >=20
> > > Only remaining users are ixgbe, sch_teql & macvlan :
> >=20
> > And gianfar (not counting staging/bcm) but I'm not sure if that's a=
ll.
> >=20

Hmm, I did a "allyesconfig", but on x86_64 ;)

> > >=20
> > > 1) ixgbe can be converted to use existing tx_ring counters.
> > >=20
> > > 2) macvlan incremented txq->tx_dropped, it can use the
> > > dev->stats.tx_dropped counter.
> > >=20
> > > 3) sch_teql : almost revert ab35cd4b8f42 (Use net_device internal=
 stats)
> > >     Now we have ndo_get_stats64(), use it.
> >=20
> > Btw, why doesn't sch_teql need locking (for 32-bits)?

Yes you're right, thanks !

[PATCH v2] net: remove dev_txq_stats_fold()

After recent changes, (percpu stats on vlan/tunnels...), we dont need
anymore per struct netdev_queue tx_bytes/tx_packets/tx_dropped counters=
=2E

Only remaining users are ixgbe, sch_teql, gianfar & macvlan :

1) ixgbe can be converted to use existing tx_ring counters.

2) macvlan incremented txq->tx_dropped, it can use the
dev->stats.tx_dropped counter.

3) sch_teql : almost revert ab35cd4b8f42 (Use net_device internal stats=
)
    Now we have ndo_get_stats64(), use it, even for "unsigned long"
fields (No need to bring back a struct net_device_stats)

4) gianfar adds a stats structure per tx queue to hold
tx_bytes/tx_packets

This removes a lockdep warning (and possible lockup) in rndis gadget,
calling dev_get_stats() from hard IRQ context.

Ref: http://www.spinics.net/lists/netdev/msg149202.html

Reported-by: Neil Jones <neiljay@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Sandeep Gopalpet <sandeep.kumar@freescale.com>
CC: Michal Nazarewicz <mina86@mina86.com>
---
v2: added gianfar, removed u64 fields from sch_teql to avoid extra
locking

 drivers/net/gianfar.c          |   10 ++++------
 drivers/net/gianfar.h          |   10 ++++++++++
 drivers/net/ixgbe/ixgbe_main.c |   23 ++++++++++++++++-------
 drivers/net/macvtap.c          |    2 +-
 include/linux/netdevice.h      |    5 -----
 net/core/dev.c                 |   29 -----------------------------
 net/sched/sch_teql.c           |   26 +++++++++++++++++++++-----
 7 files changed, 52 insertions(+), 53 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6de4675..119aa20 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -434,7 +434,6 @@ static void gfar_init_mac(struct net_device *ndev)
 static struct net_device_stats *gfar_get_stats(struct net_device *dev)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
-	struct netdev_queue *txq;
 	unsigned long rx_packets =3D 0, rx_bytes =3D 0, rx_dropped =3D 0;
 	unsigned long tx_packets =3D 0, tx_bytes =3D 0;
 	int i =3D 0;
@@ -450,9 +449,8 @@ static struct net_device_stats *gfar_get_stats(stru=
ct net_device *dev)
 	dev->stats.rx_dropped =3D rx_dropped;
=20
 	for (i =3D 0; i < priv->num_tx_queues; i++) {
-		txq =3D netdev_get_tx_queue(dev, i);
-		tx_bytes +=3D txq->tx_bytes;
-		tx_packets +=3D txq->tx_packets;
+		tx_bytes +=3D priv->tx_queue[i]->stats.tx_bytes;
+		tx_packets +=3D priv->tx_queue[i]->stats.tx_packets;
 	}
=20
 	dev->stats.tx_bytes =3D tx_bytes;
@@ -2109,8 +2107,8 @@ static int gfar_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 	}
=20
 	/* Update transmit stats */
-	txq->tx_bytes +=3D skb->len;
-	txq->tx_packets ++;
+	tx_queue->stats.tx_bytes +=3D skb->len;
+	tx_queue->stats.tx_packets++;
=20
 	txbdp =3D txbdp_start =3D tx_queue->cur_tx;
 	lstatus =3D txbdp->lstatus;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 68984eb..54de413 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -907,12 +907,21 @@ enum {
 	MQ_MG_MODE
 };
=20
+/*
+ * Per TX queue stats
+ */
+struct tx_q_stats {
+	unsigned long tx_packets;
+	unsigned long tx_bytes;
+};
+
 /**
  *	struct gfar_priv_tx_q - per tx queue structure
  *	@txlock: per queue tx spin lock
  *	@tx_skbuff:skb pointers
  *	@skb_curtx: to be used skb pointer
  *	@skb_dirtytx:the last used skb pointer
+ *	@stats: bytes/packets stats
  *	@qindex: index of this queue
  *	@dev: back pointer to the dev structure
  *	@grp: back pointer to the group to which this queue belongs
@@ -934,6 +943,7 @@ struct gfar_priv_tx_q {
 	struct	txbd8 *tx_bd_base;
 	struct	txbd8 *cur_tx;
 	struct	txbd8 *dirty_tx;
+	struct tx_q_stats stats;
 	struct	net_device *dev;
 	struct gfar_priv_grp *grp;
 	u16	skb_curtx;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index a060610..602078b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6667,8 +6667,6 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff =
*skb,
 			  struct ixgbe_adapter *adapter,
 			  struct ixgbe_ring *tx_ring)
 {
-	struct net_device *netdev =3D tx_ring->netdev;
-	struct netdev_queue *txq;
 	unsigned int first;
 	unsigned int tx_flags =3D 0;
 	u8 hdr_len =3D 0;
@@ -6765,9 +6763,6 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff =
*skb,
 		/* add the ATR filter if ATR is on */
 		if (test_bit(__IXGBE_TX_FDIR_INIT_DONE, &tx_ring->state))
 			ixgbe_atr(tx_ring, skb, tx_flags, protocol);
-		txq =3D netdev_get_tx_queue(netdev, tx_ring->queue_index);
-		txq->tx_bytes +=3D skb->len;
-		txq->tx_packets++;
 		ixgbe_tx_queue(tx_ring, tx_flags, count, skb->len, hdr_len);
 		ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
=20
@@ -6925,8 +6920,6 @@ static struct rtnl_link_stats64 *ixgbe_get_stats6=
4(struct net_device *netdev,
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
 	int i;
=20
-	/* accurate rx/tx bytes/packets stats */
-	dev_txq_stats_fold(netdev, stats);
 	rcu_read_lock();
 	for (i =3D 0; i < adapter->num_rx_queues; i++) {
 		struct ixgbe_ring *ring =3D ACCESS_ONCE(adapter->rx_ring[i]);
@@ -6943,6 +6936,22 @@ static struct rtnl_link_stats64 *ixgbe_get_stats=
64(struct net_device *netdev,
 			stats->rx_bytes   +=3D bytes;
 		}
 	}
+
+	for (i =3D 0; i < adapter->num_tx_queues; i++) {
+		struct ixgbe_ring *ring =3D ACCESS_ONCE(adapter->tx_ring[i]);
+		u64 bytes, packets;
+		unsigned int start;
+
+		if (ring) {
+			do {
+				start =3D u64_stats_fetch_begin_bh(&ring->syncp);
+				packets =3D ring->stats.packets;
+				bytes   =3D ring->stats.bytes;
+			} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+			stats->tx_packets +=3D packets;
+			stats->tx_bytes   +=3D bytes;
+		}
+	}
 	rcu_read_unlock();
 	/* following stats updated by ixgbe_watchdog_task() */
 	stats->multicast	=3D netdev->stats.multicast;
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 21845af..5933621 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -585,7 +585,7 @@ err:
 	rcu_read_lock_bh();
 	vlan =3D rcu_dereference(q->vlan);
 	if (vlan)
-		netdev_get_tx_queue(vlan->dev, 0)->tx_dropped++;
+		vlan->dev->stats.tx_dropped++;
 	rcu_read_unlock_bh();
=20
 	return err;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be4957c..d971346 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -520,9 +520,6 @@ struct netdev_queue {
 	 * please use this field instead of dev->trans_start
 	 */
 	unsigned long		trans_start;
-	u64			tx_bytes;
-	u64			tx_packets;
-	u64			tx_dropped;
 } ____cacheline_aligned_in_smp;
=20
 static inline int netdev_queue_numa_node_read(const struct netdev_queu=
e *q)
@@ -2265,8 +2262,6 @@ extern void		dev_load(struct net *net, const char=
 *name);
 extern void		dev_mcast_init(void);
 extern struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					       struct rtnl_link_stats64 *storage);
-extern void		dev_txq_stats_fold(const struct net_device *dev,
-					   struct rtnl_link_stats64 *stats);
=20
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
diff --git a/net/core/dev.c b/net/core/dev.c
index a3ef808..83507c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5523,34 +5523,6 @@ void netdev_run_todo(void)
 	}
 }
=20
-/**
- *	dev_txq_stats_fold - fold tx_queues stats
- *	@dev: device to get statistics from
- *	@stats: struct rtnl_link_stats64 to hold results
- */
-void dev_txq_stats_fold(const struct net_device *dev,
-			struct rtnl_link_stats64 *stats)
-{
-	u64 tx_bytes =3D 0, tx_packets =3D 0, tx_dropped =3D 0;
-	unsigned int i;
-	struct netdev_queue *txq;
-
-	for (i =3D 0; i < dev->num_tx_queues; i++) {
-		txq =3D netdev_get_tx_queue(dev, i);
-		spin_lock_bh(&txq->_xmit_lock);
-		tx_bytes   +=3D txq->tx_bytes;
-		tx_packets +=3D txq->tx_packets;
-		tx_dropped +=3D txq->tx_dropped;
-		spin_unlock_bh(&txq->_xmit_lock);
-	}
-	if (tx_bytes || tx_packets || tx_dropped) {
-		stats->tx_bytes   =3D tx_bytes;
-		stats->tx_packets =3D tx_packets;
-		stats->tx_dropped =3D tx_dropped;
-	}
-}
-EXPORT_SYMBOL(dev_txq_stats_fold);
-
 /* Convert net_device_stats to rtnl_link_stats64.  They have the same
  * fields in the same order, with only the type differing.
  */
@@ -5594,7 +5566,6 @@ struct rtnl_link_stats64 *dev_get_stats(struct ne=
t_device *dev,
 		netdev_stats_to_stats64(storage, ops->ndo_get_stats(dev));
 	} else {
 		netdev_stats_to_stats64(storage, &dev->stats);
-		dev_txq_stats_fold(dev, storage);
 	}
 	storage->rx_dropped +=3D atomic_long_read(&dev->rx_dropped);
 	return storage;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index af9360d..8ab66a4 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -59,6 +59,10 @@ struct teql_master
 	struct net_device *dev;
 	struct Qdisc *slaves;
 	struct list_head master_list;
+	unsigned long	tx_bytes;
+	unsigned long	tx_packets;
+	unsigned long	tx_errors;
+	unsigned long	tx_dropped;
 };
=20
 struct teql_sched_data
@@ -274,7 +278,6 @@ static inline int teql_resolve(struct sk_buff *skb,
 static netdev_tx_t teql_master_xmit(struct sk_buff *skb, struct net_de=
vice *dev)
 {
 	struct teql_master *master =3D netdev_priv(dev);
-	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
 	struct Qdisc *start, *q;
 	int busy;
 	int nores;
@@ -314,8 +317,8 @@ restart:
 					__netif_tx_unlock(slave_txq);
 					master->slaves =3D NEXT_SLAVE(q);
 					netif_wake_queue(dev);
-					txq->tx_packets++;
-					txq->tx_bytes +=3D length;
+ 					master->tx_packets++;
+ 					master->tx_bytes +=3D length;
 					return NETDEV_TX_OK;
 				}
 				__netif_tx_unlock(slave_txq);
@@ -342,10 +345,10 @@ restart:
 		netif_stop_queue(dev);
 		return NETDEV_TX_BUSY;
 	}
-	dev->stats.tx_errors++;
+	master->tx_errors++;
=20
 drop:
-	txq->tx_dropped++;
+	master->tx_dropped++;
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
@@ -398,6 +401,18 @@ static int teql_master_close(struct net_device *de=
v)
 	return 0;
 }
=20
+static struct rtnl_link_stats64 *teql_master_stats64(struct net_device=
 *dev,
+						     struct rtnl_link_stats64 *stats)
+{
+	struct teql_master *m =3D netdev_priv(dev);
+
+	stats->tx_packets	=3D m->tx_packets;
+	stats->tx_bytes		=3D m->tx_bytes;
+	stats->tx_errors	=3D m->tx_errors;
+	stats->tx_dropped	=3D m->tx_dropped;
+	return stats;
+}
+
 static int teql_master_mtu(struct net_device *dev, int new_mtu)
 {
 	struct teql_master *m =3D netdev_priv(dev);
@@ -422,6 +437,7 @@ static const struct net_device_ops teql_netdev_ops =
=3D {
 	.ndo_open	=3D teql_master_open,
 	.ndo_stop	=3D teql_master_close,
 	.ndo_start_xmit	=3D teql_master_xmit,
+	.ndo_get_stats64 =3D teql_master_stats64,
 	.ndo_change_mtu	=3D teql_master_mtu,
 };
=20


