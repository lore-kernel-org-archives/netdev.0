From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v5 2/4] ip_gre: Add support to collect tunnel metadata.
Date: Fri,  7 Aug 2015 23:51:42 -0700
Message-ID: <1439016702-15554-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33522 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbHJDsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 23:48:13 -0400
Received: by pabyb7 with SMTP id yb7so96663608pab.0
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 20:48:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch create new tunnel flag which enable
tunnel metadata collection on given device.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/ip_tunnels.h       |   7 +-
 include/uapi/linux/if_tunnel.h |   1 +
 net/ipv4/ip_gre.c              | 195 +++++++++++++++++++++++++++++++++++++----
 net/ipv4/ip_tunnel.c           |  37 ++++++--
 net/ipv4/ipip.c                |   2 +-
 net/ipv6/sit.c                 |   2 +-
 6 files changed, 216 insertions(+), 28 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 4798441..984dbfa 100644
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
+	bool			collect_md;
 };
 
 #define TUNNEL_CSUM		__cpu_to_be16(0x01)
@@ -149,6 +152,7 @@ struct tnl_ptk_info {
 struct ip_tunnel_net {
 	struct net_device *fb_tunnel_dev;
 	struct hlist_head tunnels[IP_TNL_HASH_SIZE];
+	struct ip_tunnel __rcu *collect_md_tun;
 };
 
 struct ip_tunnel_encap_ops {
@@ -235,7 +239,8 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 				   __be32 key);
 
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
-		  const struct tnl_ptk_info *tpi, bool log_ecn_error);
+		  const struct tnl_ptk_info *tpi, struct metadata_dst *tun_dst,
+		  bool log_ecn_error);
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 			 struct ip_tunnel_parm *p);
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index bd3cc11..af4de90 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -112,6 +112,7 @@ enum {
 	IFLA_GRE_ENCAP_FLAGS,
 	IFLA_GRE_ENCAP_SPORT,
 	IFLA_GRE_ENCAP_DPORT,
+	IFLA_GRE_COLLECT_METADATA,
 	__IFLA_GRE_MAX,
 };
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5fd7064..554a760 100644
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
@@ -218,40 +240,162 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 
 	if (tunnel) {
 		skb_pop_mac_header(skb);
-		ip_tunnel_rcv(tunnel, skb, tpi, log_ecn_error);
+		if (tunnel->collect_md) {
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
 
+static void build_header(struct sk_buff *skb, int hdr_len, __be16 flags,
+			 __be16 proto, __be32 key, __be32 seq)
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
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct tnl_ptk_info tpi;
 
-	tpi.flags = tunnel->parms.o_flags;
-	tpi.proto = proto;
-	tpi.key = tunnel->parms.o_key;
 	if (tunnel->parms.o_flags & TUNNEL_SEQ)
 		tunnel->o_seqno++;
-	tpi.seq = htonl(tunnel->o_seqno);
 
 	/* Push GRE header. */
-	gre_build_header(skb, &tpi, tunnel->tun_hlen);
-
-	skb_set_inner_protocol(skb, tpi.proto);
+	build_header(skb, tunnel->tun_hlen, tunnel->parms.o_flags,
+		     proto, tunnel->parms.o_key, htonl(tunnel->o_seqno));
 
+	skb_set_inner_protocol(skb, proto);
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
 
+static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip_tunnel_info *tun_info;
+	struct net *net = dev_net(dev);
+	const struct ip_tunnel_key *key;
+	struct flowi4 fl;
+	struct rtable *rt;
+	int min_headroom;
+	int tunnel_hlen;
+	__be16 df, flags;
+	int err;
+
+	tun_info = skb_tunnel_info(skb, AF_INET);
+	if (unlikely(!tun_info || tun_info->mode != IP_TUNNEL_INFO_TX))
+		goto err_free_skb;
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
+	if (IS_ERR(rt))
+		goto err_free_skb;
+
+	tunnel_hlen = ip_gre_calc_hlen(key->tun_flags);
+
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+			+ tunnel_hlen + sizeof(struct iphdr);
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
+	/* Push Tunnel header. */
+	skb = gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM));
+	if (IS_ERR(skb)) {
+		skb = NULL;
+		goto err_free_rt;
+	}
+
+	flags = tun_info->key.tun_flags & (TUNNEL_CSUM | TUNNEL_KEY);
+	build_header(skb, tunnel_hlen, flags, htons(ETH_P_TEB),
+		     tunnel_id_to_key(tun_info->key.tun_id), 0);
+
+	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
+	err = iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
+			    key->ipv4_dst, IPPROTO_GRE,
+			    key->ipv4_tos, key->ipv4_ttl, df, false);
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
 static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 			      struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr *tnl_params;
 
+	if (tunnel->collect_md) {
+		gre_fb_xmit(skb, dev);
+		return NETDEV_TX_OK;
+	}
+
 	if (dev->header_ops) {
 		/* Need space for new headers */
 		if (skb_cow_head(skb, dev->needed_headroom -
@@ -277,7 +421,6 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 		goto out;
 
 	__gre_xmit(skb, dev, tnl_params, skb->protocol);
-
 	return NETDEV_TX_OK;
 
 free_skb:
@@ -292,6 +435,11 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
+	if (tunnel->collect_md) {
+		gre_fb_xmit(skb, dev);
+		return NETDEV_TX_OK;
+	}
+
 	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
 	if (IS_ERR(skb))
 		goto out;
@@ -300,7 +448,6 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 		goto free_skb;
 
 	__gre_xmit(skb, dev, &tunnel->parms.iph, htons(ETH_P_TEB));
-
 	return NETDEV_TX_OK;
 
 free_skb:
@@ -596,8 +743,10 @@ out:
 	return ipgre_tunnel_validate(tb, data);
 }
 
-static void ipgre_netlink_parms(struct nlattr *data[], struct nlattr *tb[],
-			       struct ip_tunnel_parm *parms)
+static void ipgre_netlink_parms(struct net_device *dev,
+				struct nlattr *data[],
+				struct nlattr *tb[],
+				struct ip_tunnel_parm *parms)
 {
 	memset(parms, 0, sizeof(*parms));
 
@@ -635,6 +784,12 @@ static void ipgre_netlink_parms(struct nlattr *data[], struct nlattr *tb[],
 
 	if (!data[IFLA_GRE_PMTUDISC] || nla_get_u8(data[IFLA_GRE_PMTUDISC]))
 		parms->iph.frag_off = htons(IP_DF);
+
+	if (data[IFLA_GRE_COLLECT_METADATA]) {
+		struct ip_tunnel *t = netdev_priv(dev);
+
+		t->collect_md = true;
+	}
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -712,7 +867,7 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 			return err;
 	}
 
-	ipgre_netlink_parms(data, tb, &p);
+	ipgre_netlink_parms(dev, data, tb, &p);
 	return ip_tunnel_newlink(dev, tb, &p);
 }
 
@@ -730,7 +885,7 @@ static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			return err;
 	}
 
-	ipgre_netlink_parms(data, tb, &p);
+	ipgre_netlink_parms(dev, data, tb, &p);
 	return ip_tunnel_changelink(dev, tb, &p);
 }
 
@@ -765,6 +920,8 @@ static size_t ipgre_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_GRE_ENCAP_DPORT */
 		nla_total_size(2) +
+		/* IFLA_GRE_COLLECT_METADATA */
+		nla_total_size(0) +
 		0;
 }
 
@@ -796,6 +953,11 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			t->encap.flags))
 		goto nla_put_failure;
 
+	if (t->collect_md) {
+		if (nla_put_flag(skb, IFLA_GRE_COLLECT_METADATA))
+			goto nla_put_failure;
+	}
+
 	return 0;
 
 nla_put_failure:
@@ -817,6 +979,7 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_ENCAP_FLAGS]	= { .type = NLA_U16 },
 	[IFLA_GRE_ENCAP_SPORT]	= { .type = NLA_U16 },
 	[IFLA_GRE_ENCAP_DPORT]	= { .type = NLA_U16 },
+	[IFLA_GRE_COLLECT_METADATA]	= { .type = NLA_FLAG },
 };
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
@@ -851,7 +1014,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 
 static int __net_init ipgre_tap_init_net(struct net *net)
 {
-	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, NULL);
+	return ip_tunnel_init_net(net, gre_tap_net_id, &ipgre_tap_ops, "gretap0");
 }
 
 static void __net_exit ipgre_tap_exit_net(struct net *net)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 626d9e5..cbb51f3 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -230,10 +230,13 @@ skip_key_lookup:
 	if (cand)
 		return cand;
 
+	t = rcu_dereference(itn->collect_md_tun);
+	if (t)
+		return t;
+
 	if (itn->fb_tunnel_dev && itn->fb_tunnel_dev->flags & IFF_UP)
 		return netdev_priv(itn->fb_tunnel_dev);
 
-
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_lookup);
@@ -261,11 +264,15 @@ static void ip_tunnel_add(struct ip_tunnel_net *itn, struct ip_tunnel *t)
 {
 	struct hlist_head *head = ip_bucket(itn, &t->parms);
 
+	if (t->collect_md)
+		rcu_assign_pointer(itn->collect_md_tun, t);
 	hlist_add_head_rcu(&t->hash_node, head);
 }
 
-static void ip_tunnel_del(struct ip_tunnel *t)
+static void ip_tunnel_del(struct ip_tunnel_net *itn, struct ip_tunnel *t)
 {
+	if (t->collect_md)
+		rcu_assign_pointer(itn->collect_md_tun, NULL);
 	hlist_del_init_rcu(&t->hash_node);
 }
 
@@ -419,7 +426,8 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 }
 
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
-		  const struct tnl_ptk_info *tpi, bool log_ecn_error)
+		  const struct tnl_ptk_info *tpi, struct metadata_dst *tun_dst,
+		  bool log_ecn_error)
 {
 	struct pcpu_sw_netstats *tstats;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -478,6 +486,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		skb->dev = tunnel->dev;
 	}
 
+	if (tun_dst)
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
@@ -806,7 +817,7 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 			     struct ip_tunnel_parm *p,
 			     bool set_mtu)
 {
-	ip_tunnel_del(t);
+	ip_tunnel_del(itn, t);
 	t->parms.iph.saddr = p->iph.saddr;
 	t->parms.iph.daddr = p->iph.daddr;
 	t->parms.i_key = p->i_key;
@@ -967,7 +978,7 @@ void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
 	itn = net_generic(tunnel->net, tunnel->ip_tnl_net_id);
 
 	if (itn->fb_tunnel_dev != dev) {
-		ip_tunnel_del(netdev_priv(dev));
+		ip_tunnel_del(itn, netdev_priv(dev));
 		unregister_netdevice_queue(dev, head);
 	}
 }
@@ -1072,8 +1083,13 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 	nt = netdev_priv(dev);
 	itn = net_generic(net, nt->ip_tnl_net_id);
 
-	if (ip_tunnel_find(itn, p, dev->type))
-		return -EEXIST;
+	if (nt->collect_md) {
+		if (rtnl_dereference(itn->collect_md_tun))
+			return -EEXIST;
+	} else {
+		if (ip_tunnel_find(itn, p, dev->type))
+			return -EEXIST;
+	}
 
 	nt->net = net;
 	nt->parms = *p;
@@ -1089,7 +1105,6 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		dev->mtu = mtu;
 
 	ip_tunnel_add(itn, nt);
-
 out:
 	return err;
 }
@@ -1163,6 +1178,10 @@ int ip_tunnel_init(struct net_device *dev)
 	iph->version		= 4;
 	iph->ihl		= 5;
 
+	if (tunnel->collect_md) {
+		dev->features |= NETIF_F_NETNS_LOCAL;
+		netif_keep_dst(dev);
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init);
@@ -1176,7 +1195,7 @@ void ip_tunnel_uninit(struct net_device *dev)
 	itn = net_generic(net, tunnel->ip_tnl_net_id);
 	/* fb_tunnel_dev will be unregisted in net-exit call. */
 	if (itn->fb_tunnel_dev != dev)
-		ip_tunnel_del(netdev_priv(dev));
+		ip_tunnel_del(itn, netdev_priv(dev));
 
 	ip_tunnel_dst_reset_all(tunnel);
 }
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
-- 
1.8.3.1
