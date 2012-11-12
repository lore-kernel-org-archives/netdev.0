From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 1/2] net: convert __IPTUNNEL_XMIT() to an inline function
Date: Mon, 12 Nov 2012 15:52:33 +0800
Message-ID: <1352706754-16594-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61672 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283Ab2KLHwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 02:52:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__IPTUNNEL_XMIT() is an ugly macro, convert it to a static
inline function, so make it more readable.

IPTUNNEL_XMIT() is unused, just remove it.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/vxlan.c       |    2 +-
 include/linux/if_tunnel.h |   10 ++++++++++
 include/net/ipip.h        |   40 +++++++++++++++++++++-------------------
 net/ipv4/ip_gre.c         |   14 +-------------
 net/ipv4/ip_vti.c         |    9 ---------
 net/ipv4/ipip.c           |   14 +-------------
 net/ipv6/ip6_gre.c        |    9 ---------
 net/ipv6/ip6_tunnel.c     |    8 --------
 net/ipv6/sit.c            |   14 +-------------
 9 files changed, 35 insertions(+), 85 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8aca888..9814d67 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -769,7 +769,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	vxlan_set_owner(dev, skb);
 
-	/* See __IPTUNNEL_XMIT */
+	/* See iptunnel_xmit() */
 	skb->ip_summed = CHECKSUM_NONE;
 	ip_select_ident(iph, &rt->dst, NULL);
 
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 1cc595a..06d1d5b 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -4,5 +4,15 @@
 #include <linux/ip.h>
 #include <linux/in6.h>
 #include <uapi/linux/if_tunnel.h>
+#include <linux/u64_stats_sync.h>
+
+/* often modified stats are per cpu, other are shared (netdev->stats) */
+struct pcpu_tstats {
+	u64	rx_packets;
+	u64	rx_bytes;
+	u64	tx_packets;
+	u64	tx_bytes;
+	struct u64_stats_sync	syncp;
+};
 
 #endif /* _IF_TUNNEL_H_ */
diff --git a/include/net/ipip.h b/include/net/ipip.h
index ddc077c..21947cf 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -48,25 +48,27 @@ struct ip_tunnel_prl_entry {
 	struct rcu_head			rcu_head;
 };
 
-#define __IPTUNNEL_XMIT(stats1, stats2) do {				\
-	int err;							\
-	int pkt_len = skb->len - skb_transport_offset(skb);		\
-									\
-	skb->ip_summed = CHECKSUM_NONE;					\
-	ip_select_ident(iph, &rt->dst, NULL);				\
-									\
-	err = ip_local_out(skb);					\
-	if (likely(net_xmit_eval(err) == 0)) {				\
-		u64_stats_update_begin(&(stats1)->syncp);		\
-		(stats1)->tx_bytes += pkt_len;				\
-		(stats1)->tx_packets++;					\
-		u64_stats_update_end(&(stats1)->syncp);			\
-	} else {							\
-		(stats2)->tx_errors++;					\
-		(stats2)->tx_aborted_errors++;				\
-	}								\
-} while (0)
+static inline void iptunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int err;
+	struct iphdr *iph = ip_hdr(skb);
+	int pkt_len = skb->len - skb_transport_offset(skb);
+	struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
 
-#define IPTUNNEL_XMIT() __IPTUNNEL_XMIT(txq, stats)
+	nf_reset(skb);
+	skb->ip_summed = CHECKSUM_NONE;
+	ip_select_ident(iph, skb_dst(skb), NULL);
+
+	err = ip_local_out(skb);
+	if (likely(net_xmit_eval(err) == 0)) {
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
+}
 
 #endif
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7240f8e..37000ae 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -171,15 +171,6 @@ struct ipgre_net {
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 static struct rtnl_link_stats64 *ipgre_get_stats64(struct net_device *dev,
 						   struct rtnl_link_stats64 *tot)
 {
@@ -753,7 +744,6 @@ drop:
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct pcpu_tstats *tstats;
 	const struct iphdr  *old_iph = ip_hdr(skb);
 	const struct iphdr  *tiph;
 	struct flowi4 fl4;
@@ -977,9 +967,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 	}
 
-	nf_reset(skb);
-	tstats = this_cpu_ptr(dev->tstats);
-	__IPTUNNEL_XMIT(tstats, &dev->stats);
+	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 1831092..e0f2c88 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -71,15 +71,6 @@ static int vti_tunnel_bind_dev(struct net_device *dev);
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct	u64_stats_sync	syncp;
-};
-
 #define VTI_XMIT(stats1, stats2) do {				\
 	int err;						\
 	int pkt_len = skb->len;					\
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 720855e..3a4ad7d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -147,15 +147,6 @@ static struct rtnl_link_ops ipip_link_ops __read_mostly;
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 static struct rtnl_link_stats64 *ipip_get_stats64(struct net_device *dev,
 						  struct rtnl_link_stats64 *tot)
 {
@@ -465,7 +456,6 @@ drop:
 static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct pcpu_tstats *tstats;
 	const struct iphdr  *tiph = &tunnel->parms.iph;
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
@@ -592,9 +582,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	old_iph->ttl;
 
-	nf_reset(skb);
-	tstats = this_cpu_ptr(dev->tstats);
-	__IPTUNNEL_XMIT(tstats, &dev->stats);
+	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 12aa473..672101d 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -116,15 +116,6 @@ static u32 HASH_ADDR(const struct in6_addr *addr)
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 static struct rtnl_link_stats64 *ip6gre_get_stats64(struct net_device *dev,
 		struct rtnl_link_stats64 *tot)
 {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 424ed45..8db4d9b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -95,14 +95,6 @@ struct ip6_tnl_net {
 	struct ip6_tnl __rcu **tnls[2];
 };
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	unsigned long	rx_packets;
-	unsigned long	rx_bytes;
-	unsigned long	tx_packets;
-	unsigned long	tx_bytes;
-} __attribute__((aligned(4*sizeof(unsigned long))));
-
 static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 {
 	struct pcpu_tstats sum = { 0 };
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b543c56..ffe83ef 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -88,15 +88,6 @@ struct sit_net {
 #define for_each_ip_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 static struct rtnl_link_stats64 *ipip6_get_stats64(struct net_device *dev,
 						   struct rtnl_link_stats64 *tot)
 {
@@ -685,7 +676,6 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 				     struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct pcpu_tstats *tstats;
 	const struct iphdr  *tiph = &tunnel->parms.iph;
 	const struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
@@ -866,9 +856,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	iph6->hop_limit;
 
-	nf_reset(skb);
-	tstats = this_cpu_ptr(dev->tstats);
-	__IPTUNNEL_XMIT(tstats, &dev->stats);
+	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
-- 
1.7.7.6
