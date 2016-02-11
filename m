From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 4/7] net: use dst_cache for vxlan device
Date: Thu, 11 Feb 2016 11:12:00 +0100
Message-ID: <2661aab079345237e14b9b2bc261f8d53c4071cf.1455184959.git.pabeni@redhat.com>
References: <cover.1455184959.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbcBKKNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 05:13:20 -0500
In-Reply-To: <cover.1455184959.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of UDP traffic with datagram length
below MTU this give about 3% performance increase
when tunneling over ipv4 and about 70% when
tunneling over ipv6.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c | 84 ++++++++++++++++++++++++++++++++++++++++-------------
 include/net/vxlan.h |  1 +
 2 files changed, 65 insertions(+), 20 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 65f5247..59c1337 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -480,6 +480,8 @@ static int vxlan_fdb_replace(struct vxlan_fdb *f,
 	rd = list_first_entry_or_null(&f->remotes, struct vxlan_rdst, list);
 	if (!rd)
 		return 0;
+
+	dst_cache_reset(&rd->dst_cache);
 	rd->remote_ip = *ip;
 	rd->remote_port = port;
 	rd->remote_vni = vni;
@@ -501,6 +503,12 @@ static int vxlan_fdb_append(struct vxlan_fdb *f,
 	rd = kmalloc(sizeof(*rd), GFP_ATOMIC);
 	if (rd == NULL)
 		return -ENOBUFS;
+
+	if (dst_cache_init(&rd->dst_cache, GFP_ATOMIC)) {
+		kfree(rd);
+		return -ENOBUFS;
+	}
+
 	rd->remote_ip = *ip;
 	rd->remote_port = port;
 	rd->remote_vni = vni;
@@ -749,8 +757,10 @@ static void vxlan_fdb_free(struct rcu_head *head)
 	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
 	struct vxlan_rdst *rd, *nd;
 
-	list_for_each_entry_safe(rd, nd, &f->remotes, list)
+	list_for_each_entry_safe(rd, nd, &f->remotes, list) {
+		dst_cache_destroy(&rd->dst_cache);
 		kfree(rd);
+	}
 	kfree(f);
 }
 
@@ -1857,6 +1867,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	union vxlan_addr *dst;
+	struct dst_entry *ndst;
 	union vxlan_addr remote_ip;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
@@ -1866,7 +1877,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	__u8 tos, ttl;
 	int err;
 	u32 flags = vxlan->flags;
-	bool udp_sum = false;
+	bool use_cache, udp_sum = false;
 	bool xnet = !net_eq(vxlan->net, dev_net(vxlan->dev));
 
 	info = skb_tunnel_info(skb);
@@ -1907,9 +1918,17 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		ttl = 1;
 
 	tos = vxlan->cfg.tos;
-	if (tos == 1)
+	if (tos == 1) {
 		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
+		/* the dst cache can be used only if the routing decision
+		 * do not take in account per frame info, i.e. this packet tos
+		 */
+		use_cache = false;
+	} else {
+		use_cache = true;
+	}
+
 	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
 				     vxlan->cfg.port_max, true);
 
@@ -1917,6 +1936,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		ttl = info->key.ttl;
 		tos = info->key.tos;
 		udp_sum = !!(info->key.tun_flags & TUNNEL_CSUM);
+		use_cache = true;
 
 		if (info->options_len)
 			md = ip_tunnel_info_opts(info);
@@ -1938,14 +1958,27 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			udp_sum = !!(flags & VXLAN_F_UDP_CSUM);
 		}
 
-		rt = vxlan_get_route(vxlan, skb,
-				     rdst ? rdst->remote_ifindex : 0, tos,
-				     dst->sin.sin_addr.s_addr, &saddr);
-		if (IS_ERR(rt)) {
-			netdev_dbg(dev, "no route to %pI4\n",
-				   &dst->sin.sin_addr.s_addr);
-			dev->stats.tx_carrier_errors++;
-			goto tx_error;
+		use_cache = use_cache && rdst && !skb->mark;
+		if (use_cache)
+			rt = dst_cache_get_ip4(&rdst->dst_cache, &saddr);
+		else
+			rt = NULL;
+
+		if (!rt) {
+			rt = vxlan_get_route(vxlan, skb,
+					     rdst ? rdst->remote_ifindex : 0,
+					     tos, dst->sin.sin_addr.s_addr,
+					     &saddr);
+			if (IS_ERR(rt)) {
+				netdev_dbg(dev, "no route to %pI4\n",
+					   &dst->sin.sin_addr.s_addr);
+				dev->stats.tx_carrier_errors++;
+				goto tx_error;
+			}
+
+			if (use_cache)
+				dst_cache_set_ip4(&rdst->dst_cache, &rt->dst,
+						  saddr);
 		}
 
 		if (rt->dst.dev == dev) {
@@ -1982,7 +2015,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				    src_port, dst_port, xnet, !udp_sum);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		struct dst_entry *ndst;
 		struct in6_addr saddr;
 		u32 rt6i_flags;
 
@@ -1990,14 +2022,26 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto drop;
 		sk = vxlan->vn6_sock->sock->sk;
 
-		ndst = vxlan6_get_route(vxlan, skb,
-					rdst ? rdst->remote_ifindex : 0,
-					&dst->sin6.sin6_addr, &saddr);
-		if (IS_ERR(ndst)) {
-			netdev_dbg(dev, "no route to %pI6\n",
-				   &dst->sin6.sin6_addr);
-			dev->stats.tx_carrier_errors++;
-			goto tx_error;
+		use_cache = rdst && !skb->mark;
+		if (use_cache)
+			ndst = dst_cache_get_ip6(&rdst->dst_cache, &saddr);
+		else
+			ndst = NULL;
+
+		if (!ndst) {
+			ndst = vxlan6_get_route(vxlan, skb,
+						rdst ? rdst->remote_ifindex : 0,
+						&dst->sin6.sin6_addr, &saddr);
+			if (IS_ERR(ndst)) {
+				netdev_dbg(dev, "no route to %pI6\n",
+					   &dst->sin6.sin6_addr);
+				dev->stats.tx_carrier_errors++;
+				goto tx_error;
+			}
+
+			if (use_cache)
+				dst_cache_set_ip6(&rdst->dst_cache, ndst,
+						  &saddr);
 		}
 
 		if (ndst->dev == dev) {
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 25bd919..b314e4a 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -148,6 +148,7 @@ struct vxlan_rdst {
 	u32			 remote_ifindex;
 	struct list_head	 list;
 	struct rcu_head		 rcu;
+	struct dst_cache	 dst_cache;
 };
 
 struct vxlan_config {
-- 
1.8.3.1
