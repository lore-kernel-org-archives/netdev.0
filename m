From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/4] ip_tunnels: record IP version in tunnel info
Date: Fri, 28 Aug 2015 16:27:26 +0200
Message-ID: <224503f4a3232da1664f1eca58b7bce87cfb3cc2.1440771116.git.jbenc@redhat.com>
References: <cover.1440771116.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538AbbH1O1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 10:27:42 -0400
In-Reply-To: <cover.1440771116.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's currently nothing preventing directing packets with IPv6
encapsulation data to IPv4 tunnels (and vice versa). If this happens,
IPv6 addresses are incorrectly interpreted as IPv4 ones.

Track whether the given ip_tunnel_key contains IPv4 or IPv6 data. Store this
in ip_tunnel_info. Reject packets at appropriate places if they are supposed
to be encapsulated into an incompatible protocol.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/geneve.c       |  3 +++
 drivers/net/vxlan.c        |  2 ++
 include/net/dst_metadata.h |  1 +
 include/net/ip_tunnels.h   | 10 ++++++++++
 net/core/filter.c          |  2 ++
 net/ipv4/ip_gre.c          |  3 ++-
 net/ipv4/ip_tunnel_core.c  |  2 +-
 net/openvswitch/flow.c     |  2 ++
 net/openvswitch/vport.c    |  2 ++
 9 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 4357bae732d7..d4882d7904f6 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -644,6 +644,9 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 		u8 *opts = NULL;
 		u8 vni[3];
 
+		if (ip_tunnel_info_af(info) != AF_INET)
+			goto err;
+
 		tunnel_id_to_vni(key->tun_id, vni);
 		if (key->tun_flags & TUNNEL_GENEVE_OPT)
 			opts = ip_tunnel_info_opts(info, info->options_len);
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bd1b8cdf2bf6..e3adfe0ef66b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1903,6 +1903,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				  dev->name);
 			goto drop;
 		}
+		if (family != ip_tunnel_info_af(info))
+			goto drop;
 
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = be64_to_cpu(info->key.tun_id);
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 2b83f0d232e0..d32f49cc621d 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -105,6 +105,7 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
 	info->key.u.ipv6.dst = ip6h->daddr;
 	info->key.tos = ipv6_get_dsfield(ip6h);
 	info->key.ttl = ip6h->hop_limit;
+	info->mode = IP_TUNNEL_INFO_IPV6;
 	return tun_dst;
 }
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 9bdb3948798f..2b4fa06e91bd 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -4,6 +4,7 @@
 #include <linux/if_tunnel.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/socket.h>
 #include <linux/types.h>
 #include <linux/u64_stats_sync.h>
 #include <net/dsfield.h>
@@ -52,6 +53,7 @@ struct ip_tunnel_key {
 
 /* Flags for ip_tunnel_info mode. */
 #define IP_TUNNEL_INFO_TX	0x01	/* represents tx tunnel parameters */
+#define IP_TUNNEL_INFO_IPV6	0x02	/* key contains IPv6 addresses */
 
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
@@ -208,6 +210,8 @@ static inline void __ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
 
 	tun_info->options = opts;
 	tun_info->options_len = opts_len;
+
+	tun_info->mode = 0;
 }
 
 static inline void ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
@@ -221,6 +225,12 @@ static inline void ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
 			      tun_id, tun_flags, opts, opts_len);
 }
 
+static inline unsigned short ip_tunnel_info_af(const struct ip_tunnel_info
+					       *tun_info)
+{
+	return tun_info->mode & IP_TUNNEL_INFO_IPV6 ? AF_INET6 : AF_INET;
+}
+
 #ifdef CONFIG_INET
 
 int ip_tunnel_init(struct net_device *dev);
diff --git a/net/core/filter.c b/net/core/filter.c
index 66500d490995..13079f03902e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1493,6 +1493,8 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 
 	if (unlikely(size != sizeof(struct bpf_tunnel_key) || flags || !info))
 		return -EINVAL;
+	if (ip_tunnel_info_af(info) != AF_INET)
+		return -EINVAL;
 
 	to->tunnel_id = be64_to_cpu(info->key.tun_id);
 	to->remote_ipv4 = be32_to_cpu(info->key.u.ipv4.src);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 1e813a9f9378..bd0679d90519 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -511,7 +511,8 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 	int err;
 
 	tun_info = skb_tunnel_info(skb);
-	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX)))
+	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
+		     ip_tunnel_info_af(tun_info) != AF_INET))
 		goto err_free_skb;
 
 	key = &tun_info->key;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 934f2ac8ad61..0c756ade1cf7 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -356,7 +356,7 @@ static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
 	if (tb[LWTUNNEL_IP6_FLAGS])
 		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP6_FLAGS]);
 
-	tun_info->mode = IP_TUNNEL_INFO_TX;
+	tun_info->mode = IP_TUNNEL_INFO_TX | IP_TUNNEL_INFO_IPV6;
 	tun_info->options = NULL;
 	tun_info->options_len = 0;
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 5a3195e538ce..9760dc43bdb9 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -688,6 +688,8 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 {
 	/* Extract metadata from packet. */
 	if (tun_info) {
+		if (ip_tunnel_info_af(tun_info) != AF_INET)
+			return -EINVAL;
 		memcpy(&key->tun_key, &tun_info->key, sizeof(key->tun_key));
 
 		if (tun_info->options) {
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index e2dc9dac59e6..40164037928e 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -587,6 +587,8 @@ int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 
 	if (unlikely(!tun_info))
 		return -EINVAL;
+	if (ip_tunnel_info_af(tun_info) != AF_INET)
+		return -EINVAL;
 
 	tun_key = &tun_info->key;
 
-- 
1.8.3.1
