From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 6/7] geneve: add dst caching support
Date: Thu, 11 Feb 2016 11:12:02 +0100
Message-ID: <dbb10ad7f466010876bb8826bb86e0c27af5d273.1455184959.git.pabeni@redhat.com>
References: <cover.1455184959.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbcBKKN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 05:13:27 -0500
In-Reply-To: <cover.1455184959.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use generic dst implementation for both plain geneve devices and
lwtunnels.

In case of UDP traffic with datagram length below MTU this give
about 2% performance increase for plain geneve tunnel over ipv4,
about 65% performance increase for ipv6 tunnel.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/geneve.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 0b14ac3..bc865dc 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -72,6 +72,7 @@ struct geneve_dev {
 	bool		   collect_md;
 	struct gro_cells   gro_cells;
 	u32		   flags;
+	struct dst_cache   dst_cache;
 };
 
 /* Geneve device flags */
@@ -297,6 +298,13 @@ static int geneve_init(struct net_device *dev)
 		return err;
 	}
 
+	err = dst_cache_init(&geneve->dst_cache, GFP_KERNEL);
+	if (err) {
+		free_percpu(dev->tstats);
+		gro_cells_destroy(&geneve->gro_cells);
+		return err;
+	}
+
 	return 0;
 }
 
@@ -304,6 +312,7 @@ static void geneve_uninit(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 
+	dst_cache_destroy(&geneve->dst_cache);
 	gro_cells_destroy(&geneve->gro_cells);
 	free_percpu(dev->tstats);
 }
@@ -754,7 +763,9 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct rtable *rt = NULL;
+	struct dst_cache *dst_cache;
 	__u8 tos;
+	bool use_cache = true;
 
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_mark = skb->mark;
@@ -764,16 +775,26 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 		fl4->daddr = info->key.u.ipv4.dst;
 		fl4->saddr = info->key.u.ipv4.src;
 		fl4->flowi4_tos = RT_TOS(info->key.tos);
+		dst_cache = info->dst_cache;
 	} else {
 		tos = geneve->tos;
 		if (tos == 1) {
 			const struct iphdr *iip = ip_hdr(skb);
 
 			tos = ip_tunnel_get_dsfield(iip, skb);
+			use_cache = false;
 		}
 
 		fl4->flowi4_tos = RT_TOS(tos);
 		fl4->daddr = geneve->remote.sin.sin_addr.s_addr;
+		dst_cache = &geneve->dst_cache;
+	}
+
+	use_cache = use_cache && dst_cache && !skb->mark;
+	if (use_cache) {
+		rt = dst_cache_get_ip4(dst_cache, &fl4->saddr);
+		if (rt)
+			return rt;
 	}
 
 	rt = ip_route_output_key(geneve->net, fl4);
@@ -786,6 +807,8 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 		ip_rt_put(rt);
 		return ERR_PTR(-ELOOP);
 	}
+	if (use_cache)
+		dst_cache_set_ip4(dst_cache, &rt->dst, fl4->saddr);
 	return rt;
 }
 
@@ -798,7 +821,9 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct geneve_sock *gs6 = geneve->sock6;
 	struct dst_entry *dst = NULL;
+	bool use_cache = true;
 	__u8 prio;
+	struct dst_cache *dst_cache;
 
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->flowi6_mark = skb->mark;
@@ -808,16 +833,26 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 		fl6->daddr = info->key.u.ipv6.dst;
 		fl6->saddr = info->key.u.ipv6.src;
 		fl6->flowi6_tos = RT_TOS(info->key.tos);
+		dst_cache = info->dst_cache;
 	} else {
 		prio = geneve->tos;
 		if (prio == 1) {
 			const struct iphdr *iip = ip_hdr(skb);
 
 			prio = ip_tunnel_get_dsfield(iip, skb);
+			use_cache = false;
 		}
 
 		fl6->flowi6_tos = RT_TOS(prio);
 		fl6->daddr = geneve->remote.sin6.sin6_addr;
+		dst_cache = &geneve->dst_cache;
+	}
+
+	use_cache = use_cache && dst_cache && !skb->mark;
+	if (use_cache) {
+		dst = dst_cache_get_ip6(dst_cache, &fl6->saddr);
+		if (dst)
+			return dst;
 	}
 
 	if (ipv6_stub->ipv6_dst_lookup(geneve->net, gs6->sock->sk, &dst, fl6)) {
@@ -830,6 +865,8 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 		return ERR_PTR(-ELOOP);
 	}
 
+	if (use_cache)
+		dst_cache_set_ip6(dst_cache, dst, &fl6->saddr);
 	return dst;
 }
 #endif
@@ -1272,6 +1309,8 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 			return -EPERM;
 	}
 
+	dst_cache_reset(&geneve->dst_cache);
+
 	err = register_netdevice(dev);
 	if (err)
 		return err;
-- 
1.8.3.1
