From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 4/4] vlan: 64 bit rx counters
Date: Thu, 24 Jun 2010 12:55:06 +0200
Message-ID: <1277376906.2816.287.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42343 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824Ab0FXKzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 06:55:10 -0400
Received: by wyi11 with SMTP id 11so1545869wyi.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 03:55:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use u64_stats_sync infrastructure to implement 64bit rx stats.

(tx stats are addressed later)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan.h      |   13 ++++++-----
 net/8021q/vlan_core.c |    7 +++---
 net/8021q/vlan_dev.c  |   46 +++++++++++++++++++++++++---------------
 3 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 6abdcac..8d9503a 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -2,6 +2,7 @@
 #define __BEN_VLAN_802_1Q_INC__
 
 #include <linux/if_vlan.h>
+#include <linux/u64_stats_sync.h>
 
 
 /**
@@ -21,14 +22,16 @@ struct vlan_priority_tci_mapping {
  *	struct vlan_rx_stats - VLAN percpu rx stats
  *	@rx_packets: number of received packets
  *	@rx_bytes: number of received bytes
- *	@multicast: number of received multicast packets
+ *	@rx_multicast: number of received multicast packets
+ *	@syncp: synchronization point for 64bit counters
  *	@rx_errors: number of errors
  */
 struct vlan_rx_stats {
-	unsigned long rx_packets;
-	unsigned long rx_bytes;
-	unsigned long multicast;
-	unsigned long rx_errors;
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			rx_multicast;
+	struct u64_stats_sync	syncp;
+	unsigned long		rx_errors;
 };
 
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 50f58f5..1b9406a 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -41,9 +41,9 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
-	rx_stats = per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
-			       smp_processor_id());
+	rx_stats = this_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats);
 
+	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->rx_packets++;
 	rx_stats->rx_bytes += skb->len;
 
@@ -51,7 +51,7 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 	case PACKET_BROADCAST:
 		break;
 	case PACKET_MULTICAST:
-		rx_stats->multicast++;
+		rx_stats->rx_multicast++;
 		break;
 	case PACKET_OTHERHOST:
 		/* Our lower layer thinks this is not local, let's make sure.
@@ -62,6 +62,7 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 			skb->pkt_type = PACKET_HOST;
 		break;
 	}
+	u64_stats_update_end(&rx_stats->syncp);
 	return 0;
 }
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5298426..c6456cb 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -166,6 +166,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	rx_stats = per_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats,
 			       smp_processor_id());
+	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->rx_packets++;
 	rx_stats->rx_bytes += skb->len;
 
@@ -182,7 +183,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		break;
 
 	case PACKET_MULTICAST:
-		rx_stats->multicast++;
+		rx_stats->rx_multicast++;
 		break;
 
 	case PACKET_OTHERHOST:
@@ -197,6 +198,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	default:
 		break;
 	}
+	u64_stats_update_end(&rx_stats->syncp);
 
 	vlan_set_encap_proto(skb, vhdr);
 
@@ -801,27 +803,37 @@ static u32 vlan_ethtool_get_flags(struct net_device *dev)
 	return dev_ethtool_get_flags(vlan->real_dev);
 }
 
-static struct net_device_stats *vlan_dev_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev)
 {
-	struct net_device_stats *stats = &dev->stats;
+	struct rtnl_link_stats64 *stats = &dev->stats64;
 
-	dev_txq_stats_fold(dev, stats);
+	dev_txq_stats_fold(dev, &dev->stats);
 
 	if (vlan_dev_info(dev)->vlan_rx_stats) {
-		struct vlan_rx_stats *p, rx = {0};
+		struct vlan_rx_stats *p, accum = {0};
 		int i;
 
 		for_each_possible_cpu(i) {
+			u64 rxpackets, rxbytes, rxmulticast;
+			unsigned int start;
+
 			p = per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats, i);
-			rx.rx_packets += p->rx_packets;
-			rx.rx_bytes   += p->rx_bytes;
-			rx.rx_errors  += p->rx_errors;
-			rx.multicast  += p->multicast;
+			do {
+				start = u64_stats_fetch_begin_bh(&p->syncp);
+				rxpackets	= p->rx_packets;
+				rxbytes		= p->rx_bytes;
+				rxmulticast	= p->rx_multicast;
+			} while (u64_stats_fetch_retry_bh(&p->syncp, start));
+			accum.rx_packets += rxpackets;
+			accum.rx_bytes   += rxbytes;
+			accum.rx_multicast += rxmulticast;
+			/* rx_errors is an ulong, not protected by syncp */
+			accum.rx_errors  += p->rx_errors;
 		}
-		stats->rx_packets = rx.rx_packets;
-		stats->rx_bytes   = rx.rx_bytes;
-		stats->rx_errors  = rx.rx_errors;
-		stats->multicast  = rx.multicast;
+		stats->rx_packets = accum.rx_packets;
+		stats->rx_bytes   = accum.rx_bytes;
+		stats->rx_errors  = accum.rx_errors;
+		stats->multicast  = accum.rx_multicast;
 	}
 	return stats;
 }
@@ -848,7 +860,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats		= vlan_dev_get_stats,
+	.ndo_get_stats64	= vlan_dev_get_stats64,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
@@ -872,7 +884,7 @@ static const struct net_device_ops vlan_netdev_accel_ops = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats		= vlan_dev_get_stats,
+	.ndo_get_stats64	= vlan_dev_get_stats64,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
@@ -897,7 +909,7 @@ static const struct net_device_ops vlan_netdev_ops_sq = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats		= vlan_dev_get_stats,
+	.ndo_get_stats64	= vlan_dev_get_stats64,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
@@ -922,7 +934,7 @@ static const struct net_device_ops vlan_netdev_accel_ops_sq = {
 	.ndo_change_rx_flags	= vlan_dev_change_rx_flags,
 	.ndo_do_ioctl		= vlan_dev_ioctl,
 	.ndo_neigh_setup	= vlan_dev_neigh_setup,
-	.ndo_get_stats		= vlan_dev_get_stats,
+	.ndo_get_stats64	= vlan_dev_get_stats64,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,


