From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add a core netdev->rx_dropped counter
Date: Fri, 01 Oct 2010 09:06:55 +0200
Message-ID: <1285916815.2705.152.camel@edumazet-laptop>
References: <20100929113757.GA23755@core.hellgate.ch>
	 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	 <20100930080703.GA10827@core.hellgate.ch>
	 <AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
	 <1285884253.2705.25.camel@edumazet-laptop>
	 <AANLkTi=Vdcn7xzJMPxkugvEVy32N7Bp=KVtir6NESnDF@mail.gmail.com>
	 <1285909831.2705.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63655 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860Ab0JAHHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 03:07:01 -0400
Received: by fxm14 with SMTP id 14so432990fxm.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 00:06:59 -0700 (PDT)
In-Reply-To: <1285909831.2705.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 01 octobre 2010 =C3=A0 07:10 +0200, Eric Dumazet a =C3=A9cr=
it :

> This seems very reasonable ;)
>=20
> I'll add a counter, a core generalization of=20
> commit 8990f468a (net: rx_dropped accounting)
>=20
> Because we can drop packets _after_ netif_rx() if RPS is in action
> anyway.
>=20
>=20

In this patch I fold the additional dev->rx_dropped into get_stats()
structure. We might chose to not fold it, and provides this counter in =
a
new /proc/net/dev column, a new rtnetlink attribute (and appropriate
iproute2 change)

What do you think ?

[PATCH net-next] net: add a core netdev->rx_dropped counter

In various situations, a device provides a packet to our stack and we
drop it before it enters protocol stack :
- softnet backlog full (accounted in /proc/net/softnet_stat)
- bad vlan tag (not accounted)
- unknown/unregistered protocol (not accounted)

We can handle a per-device counter of such dropped frames at core level=
,
and automatically adds it to the device provided stats (rx_dropped), so
that standard tools can be used (ifconfig, ip link, cat /proc/net/dev)

This is a generalization of commit 8990f468a (net: rx_dropped
accounting), thus reverting it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/loopback.c    |    8 +-------
 include/linux/netdevice.h |    3 +++
 net/8021q/vlan.h          |    2 --
 net/8021q/vlan_core.c     |    2 ++
 net/8021q/vlan_dev.c      |   11 ++++-------
 net/core/dev.c            |   19 +++++++++++--------
 net/ipv4/ip_gre.c         |    3 +--
 net/ipv4/ipip.c           |    3 +--
 net/ipv6/ip6_tunnel.c     |    3 +--
 net/ipv6/ip6mr.c          |    3 +--
 net/ipv6/sit.c            |    3 +--
 11 files changed, 26 insertions(+), 34 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 4b0e30b..2d9663a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -64,7 +64,6 @@ struct pcpu_lstats {
 	u64			packets;
 	u64			bytes;
 	struct u64_stats_sync	syncp;
-	unsigned long		drops;
 };
=20
 /*
@@ -90,8 +89,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 		lb_stats->bytes +=3D len;
 		lb_stats->packets++;
 		u64_stats_update_end(&lb_stats->syncp);
-	} else
-		lb_stats->drops++;
+	}
=20
 	return NETDEV_TX_OK;
 }
@@ -101,7 +99,6 @@ static struct rtnl_link_stats64 *loopback_get_stats6=
4(struct net_device *dev,
 {
 	u64 bytes =3D 0;
 	u64 packets =3D 0;
-	u64 drops =3D 0;
 	int i;
=20
 	for_each_possible_cpu(i) {
@@ -115,14 +112,11 @@ static struct rtnl_link_stats64 *loopback_get_sta=
ts64(struct net_device *dev,
 			tbytes =3D lb_stats->bytes;
 			tpackets =3D lb_stats->packets;
 		} while (u64_stats_fetch_retry(&lb_stats->syncp, start));
-		drops   +=3D lb_stats->drops;
 		bytes   +=3D tbytes;
 		packets +=3D tpackets;
 	}
 	stats->rx_packets =3D packets;
 	stats->tx_packets =3D packets;
-	stats->rx_dropped =3D drops;
-	stats->rx_errors  =3D drops;
 	stats->rx_bytes   =3D bytes;
 	stats->tx_bytes   =3D bytes;
 	return stats;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ceed347..444f042 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -884,6 +884,9 @@ struct net_device {
 	int			iflink;
=20
 	struct net_device_stats	stats;
+	atomic_long_t		rx_dropped; /* dropped packets by core network
+					     * Do not use this in drivers.
+					     */
=20
 #ifdef CONFIG_WIRELESS_EXT
 	/* List of functions to handle Wireless Extensions (instead of ioctl)=
=2E
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index b26ce34..8d9503a 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -25,7 +25,6 @@ struct vlan_priority_tci_mapping {
  *	@rx_multicast: number of received multicast packets
  *	@syncp: synchronization point for 64bit counters
  *	@rx_errors: number of errors
- *	@rx_dropped: number of dropped packets
  */
 struct vlan_rx_stats {
 	u64			rx_packets;
@@ -33,7 +32,6 @@ struct vlan_rx_stats {
 	u64			rx_multicast;
 	struct u64_stats_sync	syncp;
 	unsigned long		rx_errors;
-	unsigned long		rx_dropped;
 };
=20
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 0eb486d..35a04a1 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -30,6 +30,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vla=
n_group *grp,
 	return polling ? netif_receive_skb(skb) : netif_rx(skb);
=20
 drop:
+	atomic_long_inc(&skb->dev->rx_dropped);
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -117,6 +118,7 @@ vlan_gro_common(struct napi_struct *napi, struct vl=
an_group *grp,
 	return dev_gro_receive(napi, skb);
=20
 drop:
+	atomic_long_inc(&skb->dev->rx_dropped);
 	return GRO_DROP;
 }
=20
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f6fbcc0..f54251e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -225,16 +225,15 @@ int vlan_skb_recv(struct sk_buff *skb, struct net=
_device *dev,
 		}
 	}
=20
-	if (unlikely(netif_rx(skb) =3D=3D NET_RX_DROP)) {
-		if (rx_stats)
-			rx_stats->rx_dropped++;
-	}
+	netif_rx(skb);
+
 	rcu_read_unlock();
 	return NET_RX_SUCCESS;
=20
 err_unlock:
 	rcu_read_unlock();
 err_free:
+	atomic_long_inc(&dev->rx_dropped);
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
@@ -846,15 +845,13 @@ static struct rtnl_link_stats64 *vlan_dev_get_sta=
ts64(struct net_device *dev, st
 			accum.rx_packets +=3D rxpackets;
 			accum.rx_bytes   +=3D rxbytes;
 			accum.rx_multicast +=3D rxmulticast;
-			/* rx_errors, rx_dropped are ulong, not protected by syncp */
+			/* rx_errors is ulong, not protected by syncp */
 			accum.rx_errors  +=3D p->rx_errors;
-			accum.rx_dropped +=3D p->rx_dropped;
 		}
 		stats->rx_packets =3D accum.rx_packets;
 		stats->rx_bytes   =3D accum.rx_bytes;
 		stats->rx_errors  =3D accum.rx_errors;
 		stats->multicast  =3D accum.rx_multicast;
-		stats->rx_dropped =3D accum.rx_dropped;
 	}
 	return stats;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index a313bab..5143663 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1483,8 +1483,9 @@ int dev_forward_skb(struct net_device *dev, struc=
t sk_buff *skb)
 	skb_orphan(skb);
 	nf_reset(skb);
=20
-	if (!(dev->flags & IFF_UP) ||
-	    (skb->len > (dev->mtu + dev->hard_header_len))) {
+	if (unlikely(!(dev->flags & IFF_UP) ||
+		     (skb->len > (dev->mtu + dev->hard_header_len)))) {
+		atomic_long_inc(&dev->rx_dropped);
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
@@ -2548,6 +2549,7 @@ enqueue:
=20
 	local_irq_restore(flags);
=20
+	atomic_long_inc(&skb->dev->rx_dropped);
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
@@ -2996,6 +2998,7 @@ ncls:
 	if (pt_prev) {
 		ret =3D pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
+		atomic_long_inc(&skb->dev->rx_dropped);
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
@@ -5431,14 +5434,14 @@ struct rtnl_link_stats64 *dev_get_stats(struct =
net_device *dev,
=20
 	if (ops->ndo_get_stats64) {
 		memset(storage, 0, sizeof(*storage));
-		return ops->ndo_get_stats64(dev, storage);
-	}
-	if (ops->ndo_get_stats) {
+		ops->ndo_get_stats64(dev, storage);
+	} else if (ops->ndo_get_stats) {
 		netdev_stats_to_stats64(storage, ops->ndo_get_stats(dev));
-		return storage;
+	} else {
+		netdev_stats_to_stats64(storage, &dev->stats);
+		dev_txq_stats_fold(dev, storage);
 	}
-	netdev_stats_to_stats64(storage, &dev->stats);
-	dev_txq_stats_fold(dev, storage);
+	storage->rx_dropped +=3D atomic_long_read(&dev->rx_dropped);
 	return storage;
 }
 EXPORT_SYMBOL(dev_get_stats);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fbe2c47..9d421f4 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -679,8 +679,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
=20
-		if (netif_rx(skb) =3D=3D NET_RX_DROP)
-			tunnel->dev->stats.rx_dropped++;
+		netif_rx(skb);
=20
 		rcu_read_unlock();
 		return 0;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 6ad46c2..e9b816e 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -414,8 +414,7 @@ static int ipip_rcv(struct sk_buff *skb)
=20
 		ipip_ecn_decapsulate(iph, skb);
=20
-		if (netif_rx(skb) =3D=3D NET_RX_DROP)
-			tunnel->dev->stats.rx_dropped++;
+		netif_rx(skb);
=20
 		rcu_read_unlock();
 		return 0;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8be3c45..c2c0f89 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -768,8 +768,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 p=
rotocol,
=20
 		dscp_ecn_decapsulate(t, ipv6h, skb);
=20
-		if (netif_rx(skb) =3D=3D NET_RX_DROP)
-			t->dev->stats.rx_dropped++;
+		netif_rx(skb);
=20
 		rcu_read_unlock();
 		return 0;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 2640c9b..6f32ffc 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -666,8 +666,7 @@ static int pim6_rcv(struct sk_buff *skb)
=20
 	skb_tunnel_rx(skb, reg_dev);
=20
-	if (netif_rx(skb) =3D=3D NET_RX_DROP)
-		reg_dev->stats.rx_dropped++;
+	netif_rx(skb);
=20
 	dev_put(reg_dev);
 	return 0;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d770178..367a6cc 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -600,8 +600,7 @@ static int ipip6_rcv(struct sk_buff *skb)
=20
 		ipip6_ecn_decapsulate(iph, skb);
=20
-		if (netif_rx(skb) =3D=3D NET_RX_DROP)
-			tunnel->dev->stats.rx_dropped++;
+		netif_rx(skb);
=20
 		rcu_read_unlock();
 		return 0;


