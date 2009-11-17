From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next-2.6] vlan: Precise RX stats accounting
Date: Tue, 17 Nov 2009 15:53:09 +0100
Message-ID: <4B02B8D5.8040402@gmail.com>
References: <4B01558F.5000306@gmail.com> <20091117.002037.229474882.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53594 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbZKQOxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 09:53:08 -0500
In-Reply-To: <20091117.002037.229474882.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> Eric, please make allocation failure cause the vlan_setup()
> to fail and propagate -EFAULT back to the caller.
>=20

Given that vlan_setup(struct net_device *) is void and cannot
return error status, unless using a global variable (ugly),
or changing all setup() prototypes (oh well...)

One possibility is to perform the allocation in vlan_dev_init()
(called from register_netdevice()), and freeing it in vlan_dev_uninit()=
=2E

Thanks

[PATCH net-next-2.6 take2] vlan: Precise RX stats accounting

With multi queue devices, its possible that several cpus call
vlan RX routines simultaneously for the same vlan device.

We update RX stats counter without any locking, so we can
get slightly wrong counters.

One possible fix is to use percpu counters, to get precise
accounting and also get guarantee of no cache line ping pongs
between cpus.

Note: this adds 16 bytes (32 bytes on 64bit arches) of percpu
data per vlan device.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan.h      |   17 ++++++++++++++
 net/8021q/vlan_core.c |   12 +++++-----
 net/8021q/vlan_dev.c  |   47 ++++++++++++++++++++++++++++++++++------
 3 files changed, 65 insertions(+), 11 deletions(-)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 68f9290..5685296 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -16,6 +16,21 @@ struct vlan_priority_tci_mapping {
 	struct vlan_priority_tci_mapping	*next;
 };
=20
+
+/**
+ *	struct vlan_rx_stats - VLAN percpu rx stats
+ *	@rx_packets: number of received packets
+ *	@rx_bytes: number of received bytes
+ *	@multicast: number of received multicast packets
+ *	@rx_errors: number of errors
+ */
+struct vlan_rx_stats {
+	unsigned long rx_packets;
+	unsigned long rx_bytes;
+	unsigned long multicast;
+	unsigned long rx_errors;
+};
+
 /**
  *	struct vlan_dev_info - VLAN private device data
  *	@nr_ingress_mappings: number of ingress priority mappings
@@ -29,6 +44,7 @@ struct vlan_priority_tci_mapping {
  *	@dent: proc dir entry
  *	@cnt_inc_headroom_on_tx: statistic - number of skb expansions on TX
  *	@cnt_encap_on_xmit: statistic - number of skb encapsulations on TX
+ *	@vlan_rx_stats: ptr to percpu rx stats
  */
 struct vlan_dev_info {
 	unsigned int				nr_ingress_mappings;
@@ -45,6 +61,7 @@ struct vlan_dev_info {
 	struct proc_dir_entry			*dent;
 	unsigned long				cnt_inc_headroom_on_tx;
 	unsigned long				cnt_encap_on_xmit;
+	struct vlan_rx_stats			*vlan_rx_stats;
 };
=20
 static inline struct vlan_dev_info *vlan_dev_info(const struct net_dev=
ice *dev)
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 971d375..e75a2f3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -31,7 +31,7 @@ EXPORT_SYMBOL(__vlan_hwaccel_rx);
 int vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
 	struct net_device *dev =3D skb->dev;
-	struct net_device_stats *stats;
+	struct vlan_rx_stats     *rx_stats;
=20
 	skb->dev =3D vlan_dev_info(dev)->real_dev;
 	netif_nit_deliver(skb);
@@ -40,15 +40,17 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 	skb->priority =3D vlan_get_ingress_priority(dev, skb->vlan_tci);
 	skb->vlan_tci =3D 0;
=20
-	stats =3D &dev->stats;
-	stats->rx_packets++;
-	stats->rx_bytes +=3D skb->len;
+	rx_stats =3D per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
+			       smp_processor_id());
+
+	rx_stats->rx_packets++;
+	rx_stats->rx_bytes +=3D skb->len;
=20
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST:
 		break;
 	case PACKET_MULTICAST:
-		stats->multicast++;
+		rx_stats->multicast++;
 		break;
 	case PACKET_OTHERHOST:
 		/* Our lower layer thinks this is not local, let's make sure.
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9159659..de0dc6b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -140,7 +140,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_d=
evice *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
 	struct vlan_hdr *vhdr;
-	struct net_device_stats *stats;
+	struct vlan_rx_stats *rx_stats;
 	u16 vlan_id;
 	u16 vlan_tci;
=20
@@ -163,9 +163,10 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_=
device *dev,
 		goto err_unlock;
 	}
=20
-	stats =3D &skb->dev->stats;
-	stats->rx_packets++;
-	stats->rx_bytes +=3D skb->len;
+	rx_stats =3D per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
+			       smp_processor_id());
+	rx_stats->rx_packets++;
+	rx_stats->rx_bytes +=3D skb->len;
=20
 	skb_pull_rcsum(skb, VLAN_HLEN);
=20
@@ -180,7 +181,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_d=
evice *dev,
 		break;
=20
 	case PACKET_MULTICAST:
-		stats->multicast++;
+		rx_stats->multicast++;
 		break;
=20
 	case PACKET_OTHERHOST:
@@ -200,7 +201,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_d=
evice *dev,
=20
 	skb =3D vlan_check_reorder_header(skb);
 	if (!skb) {
-		stats->rx_errors++;
+		rx_stats->rx_errors++;
 		goto err_unlock;
 	}
=20
@@ -731,6 +732,11 @@ static int vlan_dev_init(struct net_device *dev)
 		subclass =3D 1;
=20
 	vlan_dev_set_lockdep_class(dev, subclass);
+
+	vlan_dev_info(dev)->vlan_rx_stats =3D alloc_percpu(struct vlan_rx_sta=
ts);
+	if (!vlan_dev_info(dev)->vlan_rx_stats)
+		return -ENOMEM;
+
 	return 0;
 }
=20
@@ -740,6 +746,8 @@ static void vlan_dev_uninit(struct net_device *dev)
 	struct vlan_dev_info *vlan =3D vlan_dev_info(dev);
 	int i;
=20
+	free_percpu(vlan->vlan_rx_stats);
+	vlan->vlan_rx_stats =3D NULL;
 	for (i =3D 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
 		while ((pm =3D vlan->egress_priority_map[i]) !=3D NULL) {
 			vlan->egress_priority_map[i] =3D pm->next;
@@ -775,6 +783,31 @@ static u32 vlan_ethtool_get_flags(struct net_devic=
e *dev)
 	return dev_ethtool_get_flags(vlan->real_dev);
 }
=20
+static struct net_device_stats *vlan_dev_get_stats(struct net_device *=
dev)
+{
+	struct net_device_stats *stats =3D &dev->stats;
+
+	dev_txq_stats_fold(dev, stats);
+
+	if (vlan_dev_info(dev)->vlan_rx_stats) {
+		struct vlan_rx_stats *p, rx =3D {0};
+		int i;
+
+		for_each_possible_cpu(i) {
+			p =3D per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats, i);
+			rx.rx_packets +=3D p->rx_packets;
+			rx.rx_bytes   +=3D p->rx_bytes;
+			rx.rx_errors  +=3D p->rx_errors;
+			rx.multicast  +=3D p->multicast;
+		}
+		stats->rx_packets =3D rx.rx_packets;
+		stats->rx_bytes   =3D rx.rx_bytes;
+		stats->rx_errors  =3D rx.rx_errors;
+		stats->multicast  =3D rx.multicast;
+	}
+	return stats;
+}
+
 static const struct ethtool_ops vlan_ethtool_ops =3D {
 	.get_settings	        =3D vlan_ethtool_get_settings,
 	.get_drvinfo	        =3D vlan_ethtool_get_drvinfo,
@@ -797,6 +830,7 @@ static const struct net_device_ops vlan_netdev_ops =
=3D {
 	.ndo_change_rx_flags	=3D vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		=3D vlan_dev_ioctl,
 	.ndo_neigh_setup	=3D vlan_dev_neigh_setup,
+	.ndo_get_stats		=3D vlan_dev_get_stats,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	=3D vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	=3D vlan_dev_fcoe_ddp_done,
@@ -820,6 +854,7 @@ static const struct net_device_ops vlan_netdev_acce=
l_ops =3D {
 	.ndo_change_rx_flags	=3D vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		=3D vlan_dev_ioctl,
 	.ndo_neigh_setup	=3D vlan_dev_neigh_setup,
+	.ndo_get_stats		=3D vlan_dev_get_stats,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	=3D vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	=3D vlan_dev_fcoe_ddp_done,
