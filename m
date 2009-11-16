From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2 net-next-2.6] vlan: Precise RX stats accounting
Date: Mon, 16 Nov 2009 14:37:19 +0100
Message-ID: <4B01558F.5000306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42458 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbZKPNhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:37:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With multi queue devices, its possible that several cpu call
vlan RX routines simultaneously for the same vlan device.

We update RX stats counter without any locking, so we can
get slightly wrong counters.

One possible fix is to use percpu counters, to get precise
accounting and also get guarantee of no cache line ping pongs
between cpus.

In case dynamic percpu allocation fails, we fallback to previous
mode (sharing dev->stats counter)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan.c      |    1 
 net/8021q/vlan.h      |   10 +++++++
 net/8021q/vlan_core.c |   19 ++++++++++----
 net/8021q/vlan_dev.c  |   53 +++++++++++++++++++++++++++++++++++-----
 4 files changed, 72 insertions(+), 11 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 39f8d01..db6a9bc 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -179,6 +179,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&grp->rcu, vlan_rcu_free);
 	}
+	free_percpu(vlan->vlan_rx_stats);
 
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 68f9290..a211a55 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -16,6 +16,15 @@ struct vlan_priority_tci_mapping {
 	struct vlan_priority_tci_mapping	*next;
 };
 
+
+/* percpu rx stats */
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
@@ -45,6 +54,7 @@ struct vlan_dev_info {
 	struct proc_dir_entry			*dent;
 	unsigned long				cnt_inc_headroom_on_tx;
 	unsigned long				cnt_encap_on_xmit;
+	struct vlan_rx_stats			*vlan_rx_stats;
 };
 
 static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 971d375..9b97ffb 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -31,7 +31,7 @@ EXPORT_SYMBOL(__vlan_hwaccel_rx);
 int vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct net_device_stats *stats;
+	struct vlan_rx_stats     *rx_stats = NULL;
 
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	netif_nit_deliver(skb);
@@ -40,15 +40,24 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
-	stats = &dev->stats;
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	if (likely(vlan_dev_info(dev)->vlan_rx_stats)) {
+		rx_stats = per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
+				       smp_processor_id());
 
+		rx_stats->rx_packets++;
+		rx_stats->rx_bytes += skb->len;
+	} else {
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
+	}
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST:
 		break;
 	case PACKET_MULTICAST:
-		stats->multicast++;
+		if (likely(rx_stats))
+			rx_stats->multicast++;
+		else
+			dev->stats.multicast++;
 		break;
 	case PACKET_OTHERHOST:
 		/* Our lower layer thinks this is not local, let's make sure.
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9159659..9ef1e0e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -140,7 +140,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
 	struct vlan_hdr *vhdr;
-	struct net_device_stats *stats;
+	struct vlan_rx_stats *rx_stats = NULL;
 	u16 vlan_id;
 	u16 vlan_tci;
 
@@ -163,9 +163,15 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		goto err_unlock;
 	}
 
-	stats = &skb->dev->stats;
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	if (likely(vlan_dev_info(dev)->vlan_rx_stats)) {
+		rx_stats = per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
+				       smp_processor_id());
+		rx_stats->rx_packets++;
+		rx_stats->rx_bytes += skb->len;
+	} else {
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
+	}
 
 	skb_pull_rcsum(skb, VLAN_HLEN);
 
@@ -180,7 +186,10 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		break;
 
 	case PACKET_MULTICAST:
-		stats->multicast++;
+		if (likely(rx_stats))
+			rx_stats->multicast++;
+		else
+			dev->stats.multicast++;
 		break;
 
 	case PACKET_OTHERHOST:
@@ -200,7 +209,10 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	skb = vlan_check_reorder_header(skb);
 	if (!skb) {
-		stats->rx_errors++;
+		if (likely(rx_stats))
+			rx_stats->rx_errors++;
+		else
+			dev->stats.rx_errors++;
 		goto err_unlock;
 	}
 
@@ -775,6 +787,31 @@ static u32 vlan_ethtool_get_flags(struct net_device *dev)
 	return dev_ethtool_get_flags(vlan->real_dev);
 }
 
+static struct net_device_stats *vlan_dev_get_stats(struct net_device *dev)
+{
+	struct net_device_stats *stats = &dev->stats;
+
+	dev_txq_stats_fold(dev, stats);
+
+	if (vlan_dev_info(dev)->vlan_rx_stats) {
+		struct vlan_rx_stats *p, rx = {0};
+		int i;
+
+		for_each_possible_cpu(i) {
+			p = per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats, i);
+			rx.rx_packets += p->rx_packets;
+			rx.rx_bytes   += p->rx_bytes;
+			rx.rx_errors  += p->rx_errors;
+			rx.multicast  += p->multicast;
+		}
+		stats->rx_packets = rx.rx_packets;
+		stats->rx_bytes   = rx.rx_bytes;
+		stats->rx_errors  = rx.rx_errors;
+		stats->multicast  = rx.multicast;
+	}
+	return stats;
+}
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
@@ -797,6 +834,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
+	.ndo_get_stats		= vlan_dev_get_stats,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
@@ -820,6 +858,7 @@ static const struct net_device_ops vlan_netdev_accel_ops = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
+	.ndo_get_stats		= vlan_dev_get_stats,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
@@ -841,5 +880,7 @@ void vlan_setup(struct net_device *dev)
 	dev->destructor		= free_netdev;
 	dev->ethtool_ops	= &vlan_ethtool_ops;
 
+	vlan_dev_info(dev)->vlan_rx_stats = alloc_percpu(struct vlan_rx_stats);
+
 	memset(dev->broadcast, 0, ETH_ALEN);
 }
