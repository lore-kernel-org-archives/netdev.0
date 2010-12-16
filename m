From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH v2] e1000e: convert to stats64
Date: Thu, 16 Dec 2010 10:31:31 -0200
Message-ID: <20101216123131.GA3070@redhat.com>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
	<1292362173.2478.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1292362173.2478.6.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 10:29:33PM +0100, Eric Dumazet wrote:
> Le mardi 14 d=E9cembre 2010 =E0 18:32 -0200, Flavio Leitner a =E9crit :
> > Provides accurate stats at the time user reads them.
> > =

> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> > ---
> >  drivers/net/e1000e/e1000.h   |    5 ++-
> >  drivers/net/e1000e/ethtool.c |   27 +++++++++-------
> >  drivers/net/e1000e/netdev.c  |   68 ++++++++++++++++++++++++----------=
-------
> >  3 files changed, 59 insertions(+), 41 deletions(-)
> > =

> > diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> > index fdc67fe..5a5e944 100644
> > --- a/drivers/net/e1000e/e1000.h
> > +++ b/drivers/net/e1000e/e1000.h
> > @@ -363,6 +363,8 @@ struct e1000_adapter {
> >  	/* structs defined in e1000_hw.h */
> >  	struct e1000_hw hw;
> >  =

> > +	spinlock_t stats64_lock;
> > +	struct rtnl_link_stats64 stats64;
> =

> I am not sure why you add this stats64 in e1000_adapter ?
> =

> Why isnt it provided by callers (automatic variable, or provided to
> ndo_get_stats64()). I dont see accumulators, only a full rewrite of this
> structure in e1000e_update_stats() ?

Good point. I have modified the patch to fix that. =

thanks!

>From 3487bd7dacd0c23bba315270139dab6e00e5ff02 Mon Sep 17 00:00:00 2001
From: Flavio Leitner <fleitner@redhat.com>
Date: Thu, 16 Dec 2010 10:26:03 -0200
Subject: [PATCH] e1000e: convert to stats64

Provides accurate stats at the time user reads them.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/e1000e/e1000.h   |    3 ++
 drivers/net/e1000e/ethtool.c |   25 ++++++++-------
 drivers/net/e1000e/netdev.c  |   68 +++++++++++++++++++++++++++++++++-----=
---
 3 files changed, 70 insertions(+), 26 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index fdc67fe..d8fc3bc 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -363,6 +363,7 @@ struct e1000_adapter {
 	/* structs defined in e1000_hw.h */
 	struct e1000_hw hw;
 =

+	spinlock_t stats64_lock;
 	struct e1000_hw_stats stats;
 	struct e1000_phy_info phy_info;
 	struct e1000_phy_stats phy_stats;
@@ -493,6 +494,8 @@ extern int e1000e_setup_tx_resources(struct e1000_adapt=
er *adapter);
 extern void e1000e_free_rx_resources(struct e1000_adapter *adapter);
 extern void e1000e_free_tx_resources(struct e1000_adapter *adapter);
 extern void e1000e_update_stats(struct e1000_adapter *adapter);
+extern struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *net=
dev,
+                                                   struct rtnl_link_stats6=
4 *stats);
 extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapte=
r);
 extern void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8984d16..f43b412 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -49,8 +49,8 @@ struct e1000_stats {
 				sizeof(((struct e1000_adapter *)0)->m), \
 		      		offsetof(struct e1000_adapter, m)
 #define E1000_NETDEV_STAT(m)	NETDEV_STATS, \
-				sizeof(((struct net_device *)0)->m), \
-				offsetof(struct net_device, m)
+				sizeof(((struct rtnl_link_stats64 *)0)->m), \
+				offsetof(struct rtnl_link_stats64, m)
 =

 static const struct e1000_stats e1000_gstrings_stats[] =3D {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
@@ -61,21 +61,21 @@ static const struct e1000_stats e1000_gstrings_stats[] =
=3D {
 	{ "tx_broadcast", E1000_STAT(stats.bptc) },
 	{ "rx_multicast", E1000_STAT(stats.mprc) },
 	{ "tx_multicast", E1000_STAT(stats.mptc) },
-	{ "rx_errors", E1000_NETDEV_STAT(stats.rx_errors) },
-	{ "tx_errors", E1000_NETDEV_STAT(stats.tx_errors) },
-	{ "tx_dropped", E1000_NETDEV_STAT(stats.tx_dropped) },
+	{ "rx_errors", E1000_NETDEV_STAT(rx_errors) },
+	{ "tx_errors", E1000_NETDEV_STAT(tx_errors) },
+	{ "tx_dropped", E1000_NETDEV_STAT(tx_dropped) },
 	{ "multicast", E1000_STAT(stats.mprc) },
 	{ "collisions", E1000_STAT(stats.colc) },
-	{ "rx_length_errors", E1000_NETDEV_STAT(stats.rx_length_errors) },
-	{ "rx_over_errors", E1000_NETDEV_STAT(stats.rx_over_errors) },
+	{ "rx_length_errors", E1000_NETDEV_STAT(rx_length_errors) },
+	{ "rx_over_errors", E1000_NETDEV_STAT(rx_over_errors) },
 	{ "rx_crc_errors", E1000_STAT(stats.crcerrs) },
-	{ "rx_frame_errors", E1000_NETDEV_STAT(stats.rx_frame_errors) },
+	{ "rx_frame_errors", E1000_NETDEV_STAT(rx_frame_errors) },
 	{ "rx_no_buffer_count", E1000_STAT(stats.rnbc) },
 	{ "rx_missed_errors", E1000_STAT(stats.mpc) },
 	{ "tx_aborted_errors", E1000_STAT(stats.ecol) },
 	{ "tx_carrier_errors", E1000_STAT(stats.tncrs) },
-	{ "tx_fifo_errors", E1000_NETDEV_STAT(stats.tx_fifo_errors) },
-	{ "tx_heartbeat_errors", E1000_NETDEV_STAT(stats.tx_heartbeat_errors) },
+	{ "tx_fifo_errors", E1000_NETDEV_STAT(tx_fifo_errors) },
+	{ "tx_heartbeat_errors", E1000_NETDEV_STAT(tx_heartbeat_errors) },
 	{ "tx_window_errors", E1000_STAT(stats.latecol) },
 	{ "tx_abort_late_coll", E1000_STAT(stats.latecol) },
 	{ "tx_deferred_ok", E1000_STAT(stats.dc) },
@@ -1972,14 +1972,15 @@ static void e1000_get_ethtool_stats(struct net_devi=
ce *netdev,
 				    u64 *data)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	struct rtnl_link_stats64 net_stats;
 	int i;
 	char *p =3D NULL;
 =

-	e1000e_update_stats(adapter);
+	e1000e_get_stats64(netdev, &net_stats);
 	for (i =3D 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		switch (e1000_gstrings_stats[i].type) {
 		case NETDEV_STATS:
-			p =3D (char *) netdev +
+			p =3D (char *) &net_stats +
 					e1000_gstrings_stats[i].stat_offset;
 			break;
 		case E1000_STATS:
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c4ca162..b3c4b7d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -894,8 +894,6 @@ next_desc:
 =

 	adapter->total_rx_bytes +=3D total_rx_bytes;
 	adapter->total_rx_packets +=3D total_rx_packets;
-	netdev->stats.rx_bytes +=3D total_rx_bytes;
-	netdev->stats.rx_packets +=3D total_rx_packets;
 	return cleaned;
 }
 =

@@ -1051,8 +1049,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *=
adapter)
 	}
 	adapter->total_tx_bytes +=3D total_tx_bytes;
 	adapter->total_tx_packets +=3D total_tx_packets;
-	netdev->stats.tx_bytes +=3D total_tx_bytes;
-	netdev->stats.tx_packets +=3D total_tx_packets;
 	return count < tx_ring->count;
 }
 =

@@ -1240,8 +1236,6 @@ next_desc:
 =

 	adapter->total_rx_bytes +=3D total_rx_bytes;
 	adapter->total_rx_packets +=3D total_rx_packets;
-	netdev->stats.rx_bytes +=3D total_rx_bytes;
-	netdev->stats.rx_packets +=3D total_rx_packets;
 	return cleaned;
 }
 =

@@ -1421,8 +1415,6 @@ next_desc:
 =

 	adapter->total_rx_bytes +=3D total_rx_bytes;
 	adapter->total_rx_packets +=3D total_rx_packets;
-	netdev->stats.rx_bytes +=3D total_rx_bytes;
-	netdev->stats.rx_packets +=3D total_rx_packets;
 	return cleaned;
 }
 =

@@ -3367,6 +3359,11 @@ void e1000e_down(struct e1000_adapter *adapter)
 	del_timer_sync(&adapter->phy_info_timer);
 =

 	netif_carrier_off(netdev);
+
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter);
+	spin_unlock(&adapter->stats64_lock);
+
 	adapter->link_speed =3D 0;
 	adapter->link_duplex =3D 0;
 =

@@ -3408,6 +3405,8 @@ static int __devinit e1000_sw_init(struct e1000_adapt=
er *adapter)
 	adapter->max_frame_size =3D netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size =3D ETH_ZLEN + ETH_FCS_LEN;
 =

+	spin_lock_init(&adapter->stats64_lock);
+
 	e1000e_set_interrupt_capability(adapter);
 =

 	if (e1000_alloc_queues(adapter))
@@ -4279,7 +4278,9 @@ static void e1000_watchdog_task(struct work_struct *w=
ork)
 	}
 =

 link_up:
+	spin_lock(&adapter->stats64_lock);
 	e1000e_update_stats(adapter);
+	spin_unlock(&adapter->stats64_lock);
 =

 	mac->tx_packet_delta =3D adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old =3D adapter->stats.tpt;
@@ -4891,16 +4892,55 @@ static void e1000_reset_task(struct work_struct *wo=
rk)
 }
 =

 /**
- * e1000_get_stats - Get System Network Statistics
+ * e1000_get_stats64 - Get System Network Statistics
  * @netdev: network interface device structure
+ * @stats: rtnl_link_stats64 pointer
  *
  * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
  **/
-static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
+struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
+						   struct rtnl_link_stats64 *stats)
 {
-	/* only return the current stats */
-	return &netdev->stats;
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+
+	memset(stats, 0, sizeof(struct rtnl_link_stats64));
+	spin_lock(&adapter->stats64_lock);
+	e1000e_update_stats(adapter);
+	/* Fill out the OS statistics structure */
+	stats->rx_bytes =3D adapter->stats.gorc;
+	stats->rx_packets =3D adapter->stats.gprc;
+	stats->tx_bytes =3D adapter->stats.gotc;
+	stats->tx_packets =3D adapter->stats.gptc;
+	stats->multicast =3D adapter->stats.mprc;
+	stats->collisions =3D adapter->stats.colc;
+
+	/* Rx Errors */
+
+	/*
+	 * RLEC on some newer hardware can be incorrect so build
+	 * our own version based on RUC and ROC
+	 */
+	stats->rx_errors =3D adapter->stats.rxerrc +
+		adapter->stats.crcerrs + adapter->stats.algnerrc +
+		adapter->stats.ruc + adapter->stats.roc +
+		adapter->stats.cexterr;
+	stats->rx_length_errors =3D adapter->stats.ruc +
+					      adapter->stats.roc;
+	stats->rx_crc_errors =3D adapter->stats.crcerrs;
+	stats->rx_frame_errors =3D adapter->stats.algnerrc;
+	stats->rx_missed_errors =3D adapter->stats.mpc;
+
+	/* Tx Errors */
+	stats->tx_errors =3D adapter->stats.ecol +
+				       adapter->stats.latecol;
+	stats->tx_aborted_errors =3D adapter->stats.ecol;
+	stats->tx_window_errors =3D adapter->stats.latecol;
+	stats->tx_carrier_errors =3D adapter->stats.tncrs;
+
+	/* Tx Dropped needs to be maintained elsewhere */
+
+	spin_unlock(&adapter->stats64_lock);
+	return stats;
 }
 =

 /**
@@ -5624,7 +5664,7 @@ static const struct net_device_ops e1000e_netdev_ops =
=3D {
 	.ndo_open		=3D e1000_open,
 	.ndo_stop		=3D e1000_close,
 	.ndo_start_xmit		=3D e1000_xmit_frame,
-	.ndo_get_stats		=3D e1000_get_stats,
+	.ndo_get_stats64	=3D e1000e_get_stats64,
 	.ndo_set_multicast_list	=3D e1000_set_multi,
 	.ndo_set_mac_address	=3D e1000_set_mac,
 	.ndo_change_mtu		=3D e1000_change_mtu,
-- =

1.7.3.1


---------------------------------------------------------------------------=
---
Lotusphere 2011
Register now for Lotusphere 2011 and learn how
to connect the dots, take your collaborative environment
to the next level, and enter the era of Social Business.
http://p.sf.net/sfu/lotusphere-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
