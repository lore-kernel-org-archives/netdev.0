From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 1/2] openvswitch: Use regular GRE net_device instead of vport
Date: Mon,  3 Aug 2015 17:27:26 -0700
Message-ID: <1438648046-10346-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34224 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbbHDA11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 20:27:27 -0400
Received: by pdbbo16 with SMTP id bo16so22565143pdb.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 17:27:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With addition of flow based tunneling, there is no need to
have special GRE vport. Removes all of the OVS specific
GRE code and make OVS use a ip_gre net_device.
Minimal GRE vport is kept to handle compatibility with
current userspace application.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/gre.h              |  11 +-
 include/net/ip_tunnels.h       |   6 +-
 net/ipv4/gre_demux.c           |  34 ------
 net/ipv4/ip_gre.c              | 185 ++++++++++++++++++++++++++++++++-
 net/ipv4/ip_tunnel.c           |   6 +-
 net/ipv4/ipip.c                |   2 +-
 net/ipv6/sit.c                 |   2 +-
 net/openvswitch/Kconfig        |   1 -
 net/openvswitch/vport-gre.c    | 230 ++++-------------------------------------
 net/openvswitch/vport-netdev.c |   5 +-
 net/openvswitch/vport-netdev.h |   2 +
 net/openvswitch/vport.h        |   2 +-
 12 files changed, 222 insertions(+), 264 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index b531820..4193fd7 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -33,16 +33,7 @@ struct gre_cisco_protocol {
 int gre_cisco_register(struct gre_cisco_protocol *proto);
 int gre_cisco_unregister(struct gre_cisco_protocol *proto);
 
-void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
-		      int hdr_len);
-
-static inline struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
-						  bool csum)
-{
-	return iptunnel_handle_offloads(skb, csum,
-					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
-}
-
+#define GRE_TAP_FB_NAME "gretap0"
 
 static inline int ip_gre_calc_hlen(__be16 o_flags)
 {
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 4798441..fc37624 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -82,6 +82,8 @@ struct ip_tunnel_dst {
 	__be32				 saddr;
 };
 
+struct metadata_dst;
+
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
@@ -115,6 +117,7 @@ struct ip_tunnel {
 	unsigned int		prl_count;	/* # of entries in PRL */
 	int			ip_tnl_net_id;
 	struct gro_cells	gro_cells;
+	bool			flow_based_tunnel;
 };
 
 #define TUNNEL_CSUM		__cpu_to_be16(0x01)
@@ -235,7 +238,8 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 				   __be32 key);
 
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
-		  const struct tnl_ptk_info *tpi, bool log_ecn_error);
+		  const struct tnl_ptk_info *tpi, struct metadata_dst *tun_dst,
+		  bool log_ecn_error);
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 			 struct ip_tunnel_parm *p);
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 4a7b5b2..77562e0 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -61,40 +61,6 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 }
 EXPORT_SYMBOL_GPL(gre_del_protocol);
 
-void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
-		      int hdr_len)
-{
-	struct gre_base_hdr *greh;
-
-	skb_push(skb, hdr_len);
-
-	skb_reset_transport_header(skb);
-	greh = (struct gre_base_hdr *)skb->data;
-	greh->flags = tnl_flags_to_gre_flags(tpi->flags);
-	greh->protocol = tpi->proto;
-
-	if (tpi->flags&(TUNNEL_KEY|TUNNEL_CSUM|TUNNEL_SEQ)) {
-		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
-
-		if (tpi->flags&TUNNEL_SEQ) {
-			*ptr = tpi->seq;
-			ptr--;
-		}
-		if (tpi->flags&TUNNEL_KEY) {
-			*ptr = tpi->key;
-			ptr--;
-		}
-		if (tpi->flags&TUNNEL_CSUM &&
-		    !(skb_shinfo(skb)->gso_type &
-		      (SKB_GSO_GRE|SKB_GSO_GRE_CSUM))) {
-			*ptr = 0;
-			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
-								 skb->len, 0));
-		}
-	}
-}
-EXPORT_SYMBOL_GPL(gre_build_header);
-
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			    bool *csum_err)
 {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5fd7064..31f2ec5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -25,6 +25,7 @@
 #include <linux/udp.h>
 #include <linux/if_arp.h>
 #include <linux/mroute.h>
+#include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/in6.h>
 #include <linux/inetdevice.h>
@@ -47,6 +48,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/gre.h>
+#include <net/dst_metadata.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -200,9 +202,29 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 	return PACKET_RCVD;
 }
 
+static __be64 key_to_tunnel_id(__be32 key)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be64)((__force u32)key);
+#else
+	return (__force __be64)((__force u64)key << 32);
+#endif
+}
+
+/* Returns the least-significant 32 bits of a __be64. */
+static __be32 tunnel_id_to_key(__be64 x)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be32)x;
+#else
+	return (__force __be32)((__force u64)x >> 32);
+#endif
+}
+
 static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 {
 	struct net *net = dev_net(skb->dev);
+	struct metadata_dst *tun_dst = NULL;
 	struct ip_tunnel_net *itn;
 	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
@@ -218,12 +240,67 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 
 	if (tunnel) {
 		skb_pop_mac_header(skb);
-		ip_tunnel_rcv(tunnel, skb, tpi, log_ecn_error);
+		if (tunnel->flow_based_tunnel) {
+			struct ip_tunnel_info *info;
+
+			tun_dst = metadata_dst_alloc(0, GFP_ATOMIC);
+			if (!tun_dst)
+				return PACKET_REJECT;
+
+			info = &tun_dst->u.tun_info;
+			info->key.ipv4_src = iph->saddr;
+			info->key.ipv4_dst = iph->daddr;
+			info->key.ipv4_tos = iph->tos;
+			info->key.ipv4_ttl = iph->ttl;
+
+			info->mode = IP_TUNNEL_INFO_RX;
+			info->key.tun_flags = tpi->flags &
+					      (TUNNEL_CSUM | TUNNEL_KEY);
+			info->key.tun_id = key_to_tunnel_id(tpi->key);
+
+			info->key.tp_src = 0;
+			info->key.tp_dst = 0;
+		}
+
+		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
 		return PACKET_RCVD;
 	}
 	return PACKET_REJECT;
 }
 
+static void gre_build_header(struct sk_buff *skb, int hdr_len, __be16 flags,
+			     __be16 proto, __be32 key, __be32 seq)
+{
+	struct gre_base_hdr *greh;
+
+	skb_push(skb, hdr_len);
+
+	skb_reset_transport_header(skb);
+	greh = (struct gre_base_hdr *)skb->data;
+	greh->flags = tnl_flags_to_gre_flags(flags);
+	greh->protocol = proto;
+
+	if (flags & (TUNNEL_KEY | TUNNEL_CSUM | TUNNEL_SEQ)) {
+		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
+
+		if (flags & TUNNEL_SEQ) {
+			*ptr = seq;
+			ptr--;
+		}
+		if (flags & TUNNEL_KEY) {
+			*ptr = key;
+			ptr--;
+		}
+		if (flags & TUNNEL_CSUM &&
+		    !(skb_shinfo(skb)->gso_type &
+		      (SKB_GSO_GRE | SKB_GSO_GRE_CSUM))) {
+			*ptr = 0;
+			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
+								 skb->len, 0));
+		}
+	}
+}
+
 static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 		       const struct iphdr *tnl_params,
 		       __be16 proto)
@@ -239,13 +316,20 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	tpi.seq = htonl(tunnel->o_seqno);
 
 	/* Push GRE header. */
-	gre_build_header(skb, &tpi, tunnel->tun_hlen);
+	gre_build_header(skb, tunnel->tun_hlen,
+			 tpi.flags, tpi.proto, tpi.key, tpi.seq);
 
 	skb_set_inner_protocol(skb, tpi.proto);
-
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
 
+static struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
+					   bool csum)
+{
+	return iptunnel_handle_offloads(skb, csum,
+					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
+}
+
 static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 			      struct net_device *dev)
 {
@@ -287,11 +371,94 @@ out:
 	return NETDEV_TX_OK;
 }
 
+static void gre_fb_xmit(struct sk_buff *skb, struct ip_tunnel_info *tun_info,
+			struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	const struct ip_tunnel_key *key;
+	struct flowi4 fl;
+	struct rtable *rt;
+	int min_headroom;
+	int tunnel_hlen;
+	__be16 df, flags;
+	int err;
+
+	key = &tun_info->key;
+	memset(&fl, 0, sizeof(fl));
+	fl.daddr = key->ipv4_dst;
+	fl.saddr = key->ipv4_src;
+	fl.flowi4_tos = RT_TOS(key->ipv4_tos);
+	fl.flowi4_mark = skb->mark;
+	fl.flowi4_proto = IPPROTO_GRE;
+
+	rt = ip_route_output_key(net, &fl);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		goto err_free_skb;
+	}
+
+	tunnel_hlen = ip_gre_calc_hlen(key->tun_flags);
+
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+			+ tunnel_hlen + sizeof(struct iphdr)
+			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
+	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
+		int head_delta = SKB_DATA_ALIGN(min_headroom -
+						skb_headroom(skb) +
+						16);
+		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
+				       0, GFP_ATOMIC);
+		if (unlikely(err))
+			goto err_free_rt;
+	}
+
+	skb = vlan_hwaccel_push_inside(skb);
+	if (unlikely(!skb)) {
+		err = -ENOMEM;
+		goto err_free_rt;
+	}
+
+	/* Push Tunnel header. */
+	skb = gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM));
+	if (IS_ERR(skb)) {
+		err = PTR_ERR(skb);
+		skb = NULL;
+		goto err_free_rt;
+	}
+
+	flags = tun_info->key.tun_flags & (TUNNEL_CSUM | TUNNEL_KEY);
+	gre_build_header(skb, tunnel_hlen, flags, htons(ETH_P_TEB),
+			 tunnel_id_to_key(tun_info->key.tun_id), 0);
+
+	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
+	err = iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
+			    key->ipv4_dst, IPPROTO_GRE,
+			     key->ipv4_tos, key->ipv4_ttl, df, false);
+	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	return;
+
+err_free_rt:
+	ip_rt_put(rt);
+err_free_skb:
+	kfree_skb(skb);
+	dev->stats.tx_dropped++;
+}
+
 static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
+	if (tunnel->flow_based_tunnel) {
+		struct ip_tunnel_info *tun_info;
+
+		tun_info = skb_tunnel_info(skb, AF_INET);
+		if (likely(tun_info && tun_info->mode == IP_TUNNEL_INFO_TX)) {
+			gre_fb_xmit(skb, tun_info, dev);
+			return NETDEV_TX_OK;
+		}
+	}
+
 	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
 	if (IS_ERR(skb))
 		goto out;
@@ -676,6 +843,16 @@ static int gre_tap_init(struct net_device *dev)
 	__gre_tunnel_init(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
+	/* fallback device is used for flow based tunneling. */
+	if (!strcmp(dev->name, GRE_TAP_FB_NAME)) {
+		struct ip_tunnel *t;
+
+		t = netdev_priv(dev);
+		t->flow_based_tunnel = true;
+		eth_hw_addr_random(dev);
+		netif_keep_dst(dev);
+	}
+
 	return ip_tunnel_init(dev);
 }
 
@@ -851,7 +1028,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 
 static int __net_init ipgre_tap_init_net(struct net *net)
 {
-	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, NULL);
+	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, GRE_TAP_FB_NAME);
 }
 
 static void __net_exit ipgre_tap_exit_net(struct net *net)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 626d9e5..877c548 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -419,7 +419,8 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 }
 
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
-		  const struct tnl_ptk_info *tpi, bool log_ecn_error)
+		  const struct tnl_ptk_info *tpi, struct metadata_dst *tun_dst,
+		  bool log_ecn_error)
 {
 	struct pcpu_sw_netstats *tstats;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -478,6 +479,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		skb->dev = tunnel->dev;
 	}
 
+	if (tun_dst)
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 254238d..f34c31d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -198,7 +198,7 @@ static int ipip_rcv(struct sk_buff *skb)
 			goto drop;
 		if (iptunnel_pull_header(skb, 0, tpi.proto))
 			goto drop;
-		return ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
+		return ip_tunnel_rcv(tunnel, skb, &tpi, NULL, log_ecn_error);
 	}
 
 	return -1;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ac35a28..94428fd 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -742,7 +742,7 @@ static int ipip_rcv(struct sk_buff *skb)
 			goto drop;
 		if (iptunnel_pull_header(skb, 0, tpi.proto))
 			goto drop;
-		return ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
+		return ip_tunnel_rcv(tunnel, skb, &tpi, NULL, log_ecn_error);
 	}
 
 	return 1;
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 1584040..c56f4d4 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -34,7 +34,6 @@ config OPENVSWITCH
 config OPENVSWITCH_GRE
 	tristate "Open vSwitch GRE tunneling support"
 	depends on OPENVSWITCH
-	depends on NET_IPGRE_DEMUX
 	default OPENVSWITCH
 	---help---
 	  If you say Y here, then the Open vSwitch will be able create GRE
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index b87656c..376f4a6 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -45,235 +45,49 @@
 
 #include "datapath.h"
 #include "vport.h"
+#include "vport-netdev.h"
 
 static struct vport_ops ovs_gre_vport_ops;
 
-/* Returns the least-significant 32 bits of a __be64. */
-static __be32 be64_get_low32(__be64 x)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be32)x;
-#else
-	return (__force __be32)((__force u64)x >> 32);
-#endif
-}
-
-static __be16 filter_tnl_flags(__be16 flags)
-{
-	return flags & (TUNNEL_CSUM | TUNNEL_KEY);
-}
-
-static struct sk_buff *__build_header(struct sk_buff *skb,
-				      int tunnel_hlen)
-{
-	struct tnl_ptk_info tpi;
-	const struct ip_tunnel_key *tun_key;
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-
-	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
-	if (IS_ERR(skb))
-		return skb;
-
-	tpi.flags = filter_tnl_flags(tun_key->tun_flags);
-	tpi.proto = htons(ETH_P_TEB);
-	tpi.key = be64_get_low32(tun_key->tun_id);
-	tpi.seq = 0;
-	gre_build_header(skb, &tpi, tunnel_hlen);
-
-	return skb;
-}
-
-static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be64)((__force u64)seq << 32 | (__force u32)key);
-#else
-	return (__force __be64)((__force u64)key << 32 | (__force u32)seq);
-#endif
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static int gre_rcv(struct sk_buff *skb,
-		   const struct tnl_ptk_info *tpi)
-{
-	struct ip_tunnel_info tun_info;
-	struct ovs_net *ovs_net;
-	struct vport *vport;
-	__be64 key;
-
-	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
-	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
-	if (unlikely(!vport))
-		return PACKET_REJECT;
-
-	key = key_to_tunnel_id(tpi->key, tpi->seq);
-	ip_tunnel_info_init(&tun_info, ip_hdr(skb), 0, 0, key,
-			    filter_tnl_flags(tpi->flags), NULL, 0);
-
-	ovs_vport_receive(vport, skb, &tun_info);
-	return PACKET_RCVD;
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static int gre_err(struct sk_buff *skb, u32 info,
-		   const struct tnl_ptk_info *tpi)
-{
-	struct ovs_net *ovs_net;
-	struct vport *vport;
-
-	ovs_net = net_generic(dev_net(skb->dev), ovs_net_id);
-	vport = rcu_dereference(ovs_net->vport_net.gre_vport);
-
-	if (unlikely(!vport))
-		return PACKET_REJECT;
-	else
-		return PACKET_RCVD;
-}
-
-static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	const struct ip_tunnel_key *tun_key;
-	struct flowi4 fl;
-	struct rtable *rt;
-	int min_headroom;
-	int tunnel_hlen;
-	__be16 df;
-	int err;
-
-	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
-		err = -EINVAL;
-		goto err_free_skb;
-	}
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_GRE);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto err_free_skb;
-	}
-
-	tunnel_hlen = ip_gre_calc_hlen(tun_key->tun_flags);
-
-	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ tunnel_hlen + sizeof(struct iphdr)
-			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
-	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
-		int head_delta = SKB_DATA_ALIGN(min_headroom -
-						skb_headroom(skb) +
-						16);
-		err = pskb_expand_head(skb, max_t(int, head_delta, 0),
-					0, GFP_ATOMIC);
-		if (unlikely(err))
-			goto err_free_rt;
-	}
-
-	skb = vlan_hwaccel_push_inside(skb);
-	if (unlikely(!skb)) {
-		err = -ENOMEM;
-		goto err_free_rt;
-	}
-
-	/* Push Tunnel header. */
-	skb = __build_header(skb, tunnel_hlen);
-	if (IS_ERR(skb)) {
-		err = PTR_ERR(skb);
-		skb = NULL;
-		goto err_free_rt;
-	}
-
-	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
-		htons(IP_DF) : 0;
-
-	skb->ignore_df = 1;
-
-	return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
-			     tun_key->ipv4_dst, IPPROTO_GRE,
-			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df, false);
-err_free_rt:
-	ip_rt_put(rt);
-err_free_skb:
-	kfree_skb(skb);
-	return err;
-}
-
-static struct gre_cisco_protocol gre_protocol = {
-	.handler        = gre_rcv,
-	.err_handler    = gre_err,
-	.priority       = 1,
-};
-
-static int gre_ports;
-static int gre_init(void)
-{
-	int err;
-
-	gre_ports++;
-	if (gre_ports > 1)
-		return 0;
-
-	err = gre_cisco_register(&gre_protocol);
-	if (err)
-		pr_warn("cannot register gre protocol handler\n");
-
-	return err;
-}
-
-static void gre_exit(void)
-{
-	gre_ports--;
-	if (gre_ports > 0)
-		return;
-
-	gre_cisco_unregister(&gre_protocol);
-}
-
 static const char *gre_get_name(const struct vport *vport)
 {
 	return vport_priv(vport);
 }
 
-static struct vport *gre_create(const struct vport_parms *parms)
+static struct vport *gre_tnl_create(const struct vport_parms *parms)
 {
 	struct net *net = ovs_dp_get_net(parms->dp);
-	struct ovs_net *ovs_net;
+	struct net_device *dev;
 	struct vport *vport;
-	int err;
-
-	err = gre_init();
-	if (err)
-		return ERR_PTR(err);
-
-	ovs_net = net_generic(net, ovs_net_id);
-	if (ovsl_dereference(ovs_net->vport_net.gre_vport)) {
-		vport = ERR_PTR(-EEXIST);
-		goto error;
-	}
 
 	vport = ovs_vport_alloc(IFNAMSIZ, &ovs_gre_vport_ops, parms);
 	if (IS_ERR(vport))
-		goto error;
+		return vport;
 
 	strncpy(vport_priv(vport), parms->name, IFNAMSIZ);
-	rcu_assign_pointer(ovs_net->vport_net.gre_vport, vport);
-	return vport;
+	rtnl_lock();
+	dev = dev_get_by_name(net, GRE_TAP_FB_NAME);
+	if (!dev) {
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		return ERR_PTR(-ENODEV);
+	}
 
-error:
-	gre_exit();
+	dev_change_flags(dev, dev->flags | IFF_UP);
+	dev_put(dev);
+	rtnl_unlock();
 	return vport;
 }
 
-static void gre_tnl_destroy(struct vport *vport)
+static struct vport *gre_create(const struct vport_parms *parms)
 {
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct ovs_net *ovs_net;
+	struct vport *vport;
 
-	ovs_net = net_generic(net, ovs_net_id);
+	vport = gre_tnl_create(parms);
+	if (IS_ERR(vport))
+		return vport;
 
-	RCU_INIT_POINTER(ovs_net->vport_net.gre_vport, NULL);
-	ovs_vport_deferred_free(vport);
-	gre_exit();
+	return ovs_netdev_link(vport, GRE_TAP_FB_NAME);
 }
 
 static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
@@ -288,10 +102,10 @@ static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
-	.destroy	= gre_tnl_destroy,
 	.get_name	= gre_get_name,
-	.send		= gre_tnl_send,
+	.send		= ovs_netdev_send,
 	.get_egress_tun_info	= gre_get_egress_tun_info,
+	.destroy	= ovs_netdev_destroy,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index cddb706..281cdfd 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -168,7 +168,7 @@ void ovs_netdev_detach_dev(struct vport *vport)
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_detach_dev);
 
-static void netdev_destroy(struct vport *vport)
+void ovs_netdev_destroy(struct vport *vport)
 {
 	rtnl_lock();
 	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
@@ -177,6 +177,7 @@ static void netdev_destroy(struct vport *vport)
 
 	call_rcu(&vport->rcu, ovs_vport_free_rcu);
 }
+EXPORT_SYMBOL_GPL(ovs_netdev_destroy);
 
 static unsigned int packet_length(const struct sk_buff *skb)
 {
@@ -225,7 +226,7 @@ struct vport *ovs_netdev_get_vport(struct net_device *dev)
 static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
-	.destroy	= netdev_destroy,
+	.destroy	= ovs_netdev_destroy,
 	.send		= ovs_netdev_send,
 };
 
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 8044126..a86799a 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -33,5 +33,7 @@ void ovs_vport_free_rcu(struct rcu_head *);
 
 int __init ovs_netdev_init(void);
 void ovs_netdev_exit(void);
+void ovs_netdev_destroy(struct vport *vport);
 
+struct vport *netdev_link(struct vport *vport, const char *name);
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 1a689c2..b8d215b 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -239,7 +239,7 @@ static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 
 static inline const char *ovs_vport_name(struct vport *vport)
 {
-	return vport->dev ? vport->dev->name : vport->ops->get_name(vport);
+	return vport->ops->get_name ? vport->ops->get_name(vport) : vport->dev->name;
 }
 
 int ovs_vport_ops_register(struct vport_ops *ops);
-- 
1.8.3.1
