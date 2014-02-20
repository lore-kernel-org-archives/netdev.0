From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2] sit: fix panic with route cache in ip tunnels
Date: Thu, 20 Feb 2014 10:19:31 +0100
Message-ID: <1392887971-10590-1-git-send-email-nicolas.dichtel@6wind.com>
References: <5304DA44.2090305@6wind.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <therbert@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38334 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaBTJTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 04:19:37 -0500
In-Reply-To: <5304DA44.2090305@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug introduced by commit 7d442fab0a67 ("ipv4: Cache dst in tunnels").

Because sit code does not call ip_tunnel_init(), the dst_cache was not
initialized.

CC: Tom Herbert <therbert@google.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: fix dst release
    fix fb dev init

 include/net/ip_tunnels.h |  1 +
 net/ipv4/ip_tunnel.c     |  7 ++++---
 net/ipv6/sit.c           | 19 +++++++++++++++++++
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 48ed75c21260..e77c10405d51 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -129,6 +129,7 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p);
 void ip_tunnel_setup(struct net_device *dev, int net_id);
+void ip_tunnel_dst_reset_all(struct ip_tunnel *t);
 
 /* Extract dsfield from inner protocol */
 static inline u8 ip_tunnel_get_dsfield(const struct iphdr *iph,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 50228be5c17b..74df7f12d76e 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -93,13 +93,14 @@ static void tunnel_dst_reset(struct ip_tunnel *t)
 	tunnel_dst_set(t, NULL);
 }
 
-static void tunnel_dst_reset_all(struct ip_tunnel *t)
+void ip_tunnel_dst_reset_all(struct ip_tunnel *t)
 {
 	int i;
 
 	for_each_possible_cpu(i)
 		__tunnel_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
 }
+EXPORT_SYMBOL(ip_tunnel_dst_reset_all);
 
 static struct rtable *tunnel_rtable_get(struct ip_tunnel *t, u32 cookie)
 {
@@ -759,7 +760,7 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 		if (set_mtu)
 			dev->mtu = mtu;
 	}
-	tunnel_dst_reset_all(t);
+	ip_tunnel_dst_reset_all(t);
 	netdev_state_change(dev);
 }
 
@@ -1088,7 +1089,7 @@ void ip_tunnel_uninit(struct net_device *dev)
 	if (itn->fb_tunnel_dev != dev)
 		ip_tunnel_del(netdev_priv(dev));
 
-	tunnel_dst_reset_all(tunnel);
+	ip_tunnel_dst_reset_all(tunnel);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_uninit);
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3dfbcf1dcb1c..b4d74c86586c 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -475,6 +475,7 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 		ipip6_tunnel_unlink(sitn, tunnel);
 		ipip6_tunnel_del_prl(tunnel, NULL);
 	}
+	ip_tunnel_dst_reset_all(tunnel);
 	dev_put(dev);
 }
 
@@ -1082,6 +1083,7 @@ static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
 		t->parms.link = p->link;
 		ipip6_tunnel_bind_dev(t->dev);
 	}
+	ip_tunnel_dst_reset_all(t);
 	netdev_state_change(t->dev);
 }
 
@@ -1112,6 +1114,7 @@ static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 	t->ip6rd.relay_prefix = relay_prefix;
 	t->ip6rd.prefixlen = ip6rd->prefixlen;
 	t->ip6rd.relay_prefixlen = ip6rd->relay_prefixlen;
+	ip_tunnel_dst_reset_all(t);
 	netdev_state_change(t->dev);
 	return 0;
 }
@@ -1271,6 +1274,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			err = ipip6_tunnel_add_prl(t, &prl, cmd == SIOCCHGPRL);
 			break;
 		}
+		ip_tunnel_dst_reset_all(t);
 		netdev_state_change(dev);
 		break;
 
@@ -1326,6 +1330,9 @@ static const struct net_device_ops ipip6_netdev_ops = {
 
 static void ipip6_dev_free(struct net_device *dev)
 {
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	free_percpu(tunnel->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1375,6 +1382,12 @@ static int ipip6_tunnel_init(struct net_device *dev)
 		u64_stats_init(&ipip6_tunnel_stats->syncp);
 	}
 
+	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
+	if (!tunnel->dst_cache) {
+		free_percpu(dev->tstats);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
@@ -1405,6 +1418,12 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 		u64_stats_init(&ipip6_fb_stats->syncp);
 	}
 
+	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
+	if (!tunnel->dst_cache) {
+		free_percpu(dev->tstats);
+		return -ENOMEM;
+	}
+
 	dev_hold(dev);
 	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
 	return 0;
-- 
1.8.5.4
