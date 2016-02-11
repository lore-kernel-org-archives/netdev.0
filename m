From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 5/7] net: add dst_cache to ovs vxlan lwtunnel
Date: Thu, 11 Feb 2016 11:12:01 +0100
Message-ID: <3e02e47b27bfa69fc2ed6c5a76b3cb20b89a655c.1455184959.git.pabeni@redhat.com>
References: <cover.1455184959.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbcBKKNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 05:13:23 -0500
In-Reply-To: <cover.1455184959.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of UDP traffic with datagram length
below MTU this give about 2% performance increase

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c            | 17 +++++++++--------
 include/net/ip_tunnels.h       |  1 +
 net/openvswitch/Kconfig        |  1 +
 net/openvswitch/flow.h         |  1 +
 net/openvswitch/flow_netlink.c | 11 +++++++++++
 5 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 59c1337..71c2323 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1861,6 +1861,7 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			   struct vxlan_rdst *rdst, bool did_rsc)
 {
+	struct dst_cache *dst_cache;
 	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct sock *sk;
@@ -1886,6 +1887,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = rdst->remote_vni;
 		dst = &rdst->remote_ip;
+		dst_cache = &rdst->dst_cache;
 	} else {
 		if (!info) {
 			WARN_ONCE(1, "%s: Missing encapsulation instructions\n",
@@ -1900,6 +1902,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		else
 			remote_ip.sin6.sin6_addr = info->key.u.ipv6.dst;
 		dst = &remote_ip;
+		dst_cache = info->dst_cache;
 	}
 
 	if (vxlan_addr_any(dst)) {
@@ -1958,9 +1961,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			udp_sum = !!(flags & VXLAN_F_UDP_CSUM);
 		}
 
-		use_cache = use_cache && rdst && !skb->mark;
+		use_cache = use_cache && dst_cache && !skb->mark;
 		if (use_cache)
-			rt = dst_cache_get_ip4(&rdst->dst_cache, &saddr);
+			rt = dst_cache_get_ip4(dst_cache, &saddr);
 		else
 			rt = NULL;
 
@@ -1977,8 +1980,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			}
 
 			if (use_cache)
-				dst_cache_set_ip4(&rdst->dst_cache, &rt->dst,
-						  saddr);
+				dst_cache_set_ip4(dst_cache, &rt->dst, saddr);
 		}
 
 		if (rt->dst.dev == dev) {
@@ -2022,9 +2024,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto drop;
 		sk = vxlan->vn6_sock->sock->sk;
 
-		use_cache = rdst && !skb->mark;
+		use_cache = dst_cache && !skb->mark;
 		if (use_cache)
-			ndst = dst_cache_get_ip6(&rdst->dst_cache, &saddr);
+			ndst = dst_cache_get_ip6(dst_cache, &saddr);
 		else
 			ndst = NULL;
 
@@ -2040,8 +2042,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			}
 
 			if (use_cache)
-				dst_cache_set_ip6(&rdst->dst_cache, ndst,
-						  &saddr);
+				dst_cache_set_ip6(dst_cache, ndst, &saddr);
 		}
 
 		if (ndst->dev == dev) {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index d66797e..f0e29be 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -58,6 +58,7 @@ struct ip_tunnel_key {
 
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
+	struct dst_cache	*dst_cache;
 	u8			options_len;
 	u8			mode;
 };
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index d143aa9..cd5fd9d 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -10,6 +10,7 @@ config OPENVSWITCH
 	select LIBCRC32C
 	select MPLS
 	select NET_MPLS_GSO
+	select DST_CACHE
 	---help---
 	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
 	  environments.  In addition to supporting a variety of features
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 1d055c5..edaf6ca 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -48,6 +48,7 @@ struct sk_buff;
 
 struct ovs_tunnel_info {
 	struct metadata_dst	*tun_dst;
+	struct dst_cache	dst_cache;
 };
 
 #define OVS_SW_FLOW_KEY_METADATA_SIZE			\
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d1bd4a4..f181186 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1698,6 +1698,7 @@ static void ovs_nla_free_set_action(const struct nlattr *a)
 	case OVS_KEY_ATTR_TUNNEL_INFO:
 		ovs_tun = nla_data(ovs_key);
 		dst_release((struct dst_entry *)ovs_tun->tun_dst);
+		dst_cache_destroy(&ovs_tun->dst_cache);
 		break;
 	}
 }
@@ -1928,6 +1929,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 {
 	struct sw_flow_match match;
 	struct sw_flow_key key;
+	struct dst_cache dst_cache;
 	struct metadata_dst *tun_dst;
 	struct ip_tunnel_info *tun_info;
 	struct ovs_tunnel_info *ovs_tun;
@@ -1959,15 +1961,24 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (!tun_dst)
 		return -ENOMEM;
 
+	err = dst_cache_init(&dst_cache, GFP_KERNEL);
+	if (err) {
+		dst_release((struct dst_entry *)tun_dst);
+		return err;
+	}
+
 	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
 			 sizeof(*ovs_tun), log);
 	if (IS_ERR(a)) {
 		dst_release((struct dst_entry *)tun_dst);
+		dst_cache_destroy(&dst_cache);
 		return PTR_ERR(a);
 	}
 
 	ovs_tun = nla_data(a);
 	ovs_tun->tun_dst = tun_dst;
+	ovs_tun->dst_cache = dst_cache;
+	tun_dst->u.tun_info.dst_cache = &ovs_tun->dst_cache;
 
 	tun_info = &tun_dst->u.tun_info;
 	tun_info->mode = IP_TUNNEL_INFO_TX;
-- 
1.8.3.1
