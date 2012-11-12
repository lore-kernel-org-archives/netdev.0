From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 2/2] net: unify for_each_ip_tunnel_rcu()
Date: Mon, 12 Nov 2012 15:52:34 +0800
Message-ID: <1352706754-16594-2-git-send-email-amwang@redhat.com>
References: <1352706754-16594-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283Ab2KLHw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 02:52:59 -0500
In-Reply-To: <1352706754-16594-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The defitions of for_each_ip_tunnel_rcu() are same,
so unify it. Also, don't hide the parameter 't'.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/if_tunnel.h |    7 +++++++
 net/ipv4/ip_gre.c         |   14 ++++----------
 net/ipv4/ip_vti.c         |   13 ++++---------
 net/ipv4/ipip.c           |   13 +++----------
 net/ipv6/ip6_gre.c        |   14 ++++----------
 net/ipv6/sit.c            |   13 +++----------
 6 files changed, 25 insertions(+), 49 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 06d1d5b..f4e56ec 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -6,6 +6,13 @@
 #include <uapi/linux/if_tunnel.h>
 #include <linux/u64_stats_sync.h>
 
+/*
+ * Locking : hash tables are protected by RCU and RTNL
+ */
+
+#define for_each_ip_tunnel_rcu(pos, start) \
+	for (pos = rcu_dereference(start); pos; pos = rcu_dereference(pos->next))
+
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_tstats {
 	u64	rx_packets;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 37000ae..127f2a1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -164,12 +164,6 @@ struct ipgre_net {
 #define tunnels_r	tunnels[2]
 #define tunnels_l	tunnels[1]
 #define tunnels_wc	tunnels[0]
-/*
- * Locking : hash tables are protected by RCU and RTNL
- */
-
-#define for_each_ip_tunnel_rcu(start) \
-	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
 static struct rtnl_link_stats64 *ipgre_get_stats64(struct net_device *dev,
 						   struct rtnl_link_stats64 *tot)
@@ -241,7 +235,7 @@ static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 		       ARPHRD_ETHER : ARPHRD_IPGRE;
 	int score, cand_score = 4;
 
-	for_each_ip_tunnel_rcu(ign->tunnels_r_l[h0 ^ h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_r_l[h0 ^ h1]) {
 		if (local != t->parms.iph.saddr ||
 		    remote != t->parms.iph.daddr ||
 		    !(t->dev->flags & IFF_UP))
@@ -268,7 +262,7 @@ static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for_each_ip_tunnel_rcu(ign->tunnels_r[h0 ^ h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_r[h0 ^ h1]) {
 		if (remote != t->parms.iph.daddr ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
@@ -294,7 +288,7 @@ static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for_each_ip_tunnel_rcu(ign->tunnels_l[h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_l[h1]) {
 		if ((local != t->parms.iph.saddr &&
 		     (local != t->parms.iph.daddr ||
 		      !ipv4_is_multicast(local))) ||
@@ -322,7 +316,7 @@ static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for_each_ip_tunnel_rcu(ign->tunnels_wc[h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_wc[h1]) {
 		if (t->parms.i_key != key ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index e0f2c88..516188b 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -66,11 +66,6 @@ static void vti_tunnel_setup(struct net_device *dev);
 static void vti_dev_free(struct net_device *dev);
 static int vti_tunnel_bind_dev(struct net_device *dev);
 
-/* Locking : hash tables are protected by RCU and RTNL */
-
-#define for_each_ip_tunnel_rcu(start) \
-	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
-
 #define VTI_XMIT(stats1, stats2) do {				\
 	int err;						\
 	int pkt_len = skb->len;					\
@@ -133,19 +128,19 @@ static struct ip_tunnel *vti_tunnel_lookup(struct net *net,
 	struct ip_tunnel *t;
 	struct vti_net *ipn = net_generic(net, vti_net_id);
 
-	for_each_ip_tunnel_rcu(ipn->tunnels_r_l[h0 ^ h1])
+	for_each_ip_tunnel_rcu(t, ipn->tunnels_r_l[h0 ^ h1])
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
-	for_each_ip_tunnel_rcu(ipn->tunnels_r[h0])
+	for_each_ip_tunnel_rcu(t, ipn->tunnels_r[h0])
 		if (remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
 
-	for_each_ip_tunnel_rcu(ipn->tunnels_l[h1])
+	for_each_ip_tunnel_rcu(t, ipn->tunnels_l[h1])
 		if (local == t->parms.iph.saddr && (t->dev->flags&IFF_UP))
 			return t;
 
-	for_each_ip_tunnel_rcu(ipn->tunnels_wc[0])
+	for_each_ip_tunnel_rcu(t, ipn->tunnels_wc[0])
 		if (t && (t->dev->flags&IFF_UP))
 			return t;
 	return NULL;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 3a4ad7d..099fc1c 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -140,13 +140,6 @@ static void ipip_tunnel_setup(struct net_device *dev);
 static void ipip_dev_free(struct net_device *dev);
 static struct rtnl_link_ops ipip_link_ops __read_mostly;
 
-/*
- * Locking : hash tables are protected by RCU and RTNL
- */
-
-#define for_each_ip_tunnel_rcu(start) \
-	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
-
 static struct rtnl_link_stats64 *ipip_get_stats64(struct net_device *dev,
 						  struct rtnl_link_stats64 *tot)
 {
@@ -189,16 +182,16 @@ static struct ip_tunnel *ipip_tunnel_lookup(struct net *net,
 	struct ip_tunnel *t;
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
-	for_each_ip_tunnel_rcu(ipn->tunnels_r_l[h0 ^ h1])
+	for_each_ip_tunnel_rcu(t, ipn->tunnels_r_l[h0 ^ h1])
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
 
-	for_each_ip_tunnel_rcu(ipn->tunnels_r[h0])
+	for_each_ip_tunnel_rcu(t, ipn->tunnels_r[h0])
 		if (remote == t->parms.iph.daddr && (t->dev->flags&IFF_UP))
 			return t;
 
-	for_each_ip_tunnel_rcu(ipn->tunnels_l[h1])
+	for_each_ip_tunnel_rcu(t, ipn->tunnels_l[h1])
 		if (local == t->parms.iph.saddr && (t->dev->flags&IFF_UP))
 			return t;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 672101d..823fd64 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -109,12 +109,6 @@ static u32 HASH_ADDR(const struct in6_addr *addr)
 #define tunnels_r	tunnels[2]
 #define tunnels_l	tunnels[1]
 #define tunnels_wc	tunnels[0]
-/*
- * Locking : hash tables are protected by RCU and RTNL
- */
-
-#define for_each_ip_tunnel_rcu(start) \
-	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
 static struct rtnl_link_stats64 *ip6gre_get_stats64(struct net_device *dev,
 		struct rtnl_link_stats64 *tot)
@@ -172,7 +166,7 @@ static struct ip6_tnl *ip6gre_tunnel_lookup(struct net_device *dev,
 		       ARPHRD_ETHER : ARPHRD_IP6GRE;
 	int score, cand_score = 4;
 
-	for_each_ip_tunnel_rcu(ign->tunnels_r_l[h0 ^ h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_r_l[h0 ^ h1]) {
 		if (!ipv6_addr_equal(local, &t->parms.laddr) ||
 		    !ipv6_addr_equal(remote, &t->parms.raddr) ||
 		    key != t->parms.i_key ||
@@ -197,7 +191,7 @@ static struct ip6_tnl *ip6gre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for_each_ip_tunnel_rcu(ign->tunnels_r[h0 ^ h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_r[h0 ^ h1]) {
 		if (!ipv6_addr_equal(remote, &t->parms.raddr) ||
 		    key != t->parms.i_key ||
 		    !(t->dev->flags & IFF_UP))
@@ -221,7 +215,7 @@ static struct ip6_tnl *ip6gre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for_each_ip_tunnel_rcu(ign->tunnels_l[h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_l[h1]) {
 		if ((!ipv6_addr_equal(local, &t->parms.laddr) &&
 			  (!ipv6_addr_equal(local, &t->parms.raddr) ||
 				 !ipv6_addr_is_multicast(local))) ||
@@ -247,7 +241,7 @@ static struct ip6_tnl *ip6gre_tunnel_lookup(struct net_device *dev,
 		}
 	}
 
-	for_each_ip_tunnel_rcu(ign->tunnels_wc[h1]) {
+	for_each_ip_tunnel_rcu(t, ign->tunnels_wc[h1]) {
 		if (t->parms.i_key != key ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ffe83ef..5bce2f6 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -81,13 +81,6 @@ struct sit_net {
 	struct net_device *fb_tunnel_dev;
 };
 
-/*
- * Locking : hash tables are protected by RCU and RTNL
- */
-
-#define for_each_ip_tunnel_rcu(start) \
-	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
-
 static struct rtnl_link_stats64 *ipip6_get_stats64(struct net_device *dev,
 						   struct rtnl_link_stats64 *tot)
 {
@@ -133,20 +126,20 @@ static struct ip_tunnel *ipip6_tunnel_lookup(struct net *net,
 	struct ip_tunnel *t;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	for_each_ip_tunnel_rcu(sitn->tunnels_r_l[h0 ^ h1]) {
+	for_each_ip_tunnel_rcu(t, sitn->tunnels_r_l[h0 ^ h1]) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
 		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	for_each_ip_tunnel_rcu(sitn->tunnels_r[h0]) {
+	for_each_ip_tunnel_rcu(t, sitn->tunnels_r[h0]) {
 		if (remote == t->parms.iph.daddr &&
 		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-	for_each_ip_tunnel_rcu(sitn->tunnels_l[h1]) {
+	for_each_ip_tunnel_rcu(t, sitn->tunnels_l[h1]) {
 		if (local == t->parms.iph.saddr &&
 		    (!dev || !t->parms.link || dev->iflink == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
-- 
1.7.7.6
