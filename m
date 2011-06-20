From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/5] ifb: convert to 64 bit stats
Date: Mon, 20 Jun 2011 23:42:52 +0200
Message-ID: <1308606172.2658.31.camel@edumazet-laptop>
References: <20110620203506.363818794@vyatta.com>
	 <20110620.135607.2158729745388010853.davem@davemloft.net>
	 <20110620141253.00249218@nehalam.ftrdhcpuser.net>
	 <1308604980.2658.23.camel@edumazet-laptop>
	 <1308605221.2658.25.camel@edumazet-laptop>
	 <20110620143813.233f1642@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45924 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225Ab1FTVm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:42:56 -0400
Received: by wyb38 with SMTP id 38so1970914wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 14:42:55 -0700 (PDT)
In-Reply-To: <20110620143813.233f1642@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>


Le lundi 20 juin 2011 =C3=A0 14:38 -0700, Stephen Hemminger a =C3=A9cri=
t :
> On Mon, 20 Jun 2011 23:27:01 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le lundi 20 juin 2011 =C3=A0 23:23 +0200, Eric Dumazet a =C3=A9crit=
 :
> > > Le lundi 20 juin 2011 =C3=A0 14:12 -0700, Stephen Hemminger a =C3=
=A9crit :
> > > > Convert input functional block device to use 64 bit stats.
> > > >=20
> > > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > > >=20
> > > > ---
> > > > v2 - add stats_sync
> > > >=20
> > >=20
> > > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> > >=20
> >=20
> > Ah well, I am wondering if ri_tasklet() & ifb_xmit() could run
> > concurrently
> >=20
> > If so, we need two separate syncp, one for each function.
>=20
> For the normal case that isn't possible but
> someone could be perverse and put an address on the ifb device and
> try and use like loopback?

Hmm, this can occur on normal case I think, on SMP.

Here is an updated patch

[PATCH net-next v3] ifb: convert to 64 bit stats

Convert input functional block device to use 64 bit stats.

[Eric Dumazet]: Use two different synchronization points for rx and tx.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
v2 - add stats_sync
v3 - must use two different sync

 drivers/net/ifb.c |   58 +++++++++++++++++++++++++++++++++++++-------
 1 file changed, 49 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ce53f4a..2443e90 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -41,8 +41,16 @@
 struct ifb_private {
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
+
 	struct sk_buff_head     rq;
+	u64			rx_packets;
+	u64			rx_bytes;
+	struct u64_stats_sync	stats_rx_sync;
+
 	struct sk_buff_head     tq;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	stats_tx_sync;
 };
=20
 static int numifbs =3D 2;
@@ -54,10 +62,8 @@ static int ifb_close(struct net_device *dev);
=20
 static void ri_tasklet(unsigned long dev)
 {
-
 	struct net_device *_dev =3D (struct net_device *)dev;
 	struct ifb_private *dp =3D netdev_priv(_dev);
-	struct net_device_stats *stats =3D &_dev->stats;
 	struct netdev_queue *txq;
 	struct sk_buff *skb;
=20
@@ -77,15 +83,18 @@ static void ri_tasklet(unsigned long dev)
=20
 		skb->tc_verd =3D 0;
 		skb->tc_verd =3D SET_TC_NCLS(skb->tc_verd);
-		stats->tx_packets++;
-		stats->tx_bytes +=3Dskb->len;
+
+		u64_stats_update_begin(&dp->stats_tx_sync);
+		dp->tx_packets++;
+		dp->tx_bytes +=3D skb->len;
+		u64_stats_update_end(&dp->stats_tx_sync);
=20
 		rcu_read_lock();
 		skb->dev =3D dev_get_by_index_rcu(&init_net, skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
-			stats->tx_dropped++;
+			_dev->stats.tx_dropped++;
 			if (skb_queue_len(&dp->tq) !=3D 0)
 				goto resched;
 			break;
@@ -120,9 +129,39 @@ resched:
=20
 }
=20
+static struct rtnl_link_stats64 *ifb_stats64(struct net_device *dev,
+					     struct rtnl_link_stats64 *stats)
+{
+	const struct ifb_private *dp =3D netdev_priv(dev);
+	unsigned int start;
+
+	do {
+		start =3D u64_stats_fetch_begin_bh(&dp->stats_rx_sync);
+
+		stats->rx_packets =3D dp->rx_packets;
+		stats->rx_bytes =3D dp->rx_bytes;
+
+	} while (u64_stats_fetch_retry_bh(&dp->stats_rx_sync, start));
+
+	do {
+		start =3D u64_stats_fetch_begin_bh(&dp->stats_tx_sync);
+
+		stats->tx_packets =3D dp->tx_packets;
+		stats->tx_bytes =3D dp->tx_bytes;
+
+	} while (u64_stats_fetch_retry_bh(&dp->stats_tx_sync, start));
+
+	stats->rx_dropped =3D dev->stats.rx_dropped;
+	stats->tx_dropped =3D dev->stats.tx_dropped;
+
+	return stats;
+}
+
+
 static const struct net_device_ops ifb_netdev_ops =3D {
 	.ndo_open	=3D ifb_open,
 	.ndo_stop	=3D ifb_close,
+	.ndo_get_stats64 =3D ifb_stats64,
 	.ndo_start_xmit	=3D ifb_xmit,
 	.ndo_validate_addr =3D eth_validate_addr,
 };
@@ -153,15 +192,16 @@ static void ifb_setup(struct net_device *dev)
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *de=
v)
 {
 	struct ifb_private *dp =3D netdev_priv(dev);
-	struct net_device_stats *stats =3D &dev->stats;
 	u32 from =3D G_TC_FROM(skb->tc_verd);
=20
-	stats->rx_packets++;
-	stats->rx_bytes+=3Dskb->len;
+	u64_stats_update_begin(&dp->stats_rx_sync);
+	dp->rx_packets++;
+	dp->rx_bytes +=3D skb->len;
+	u64_stats_update_end(&dp->stats_rx_sync);
=20
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->skb_iif) {
 		dev_kfree_skb(skb);
-		stats->rx_dropped++;
+		dev->stats.rx_dropped++;
 		return NETDEV_TX_OK;
 	}
=20


