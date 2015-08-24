From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 net-next 5/8] geneve: Add support to collect tunnel metadata.
Date: Mon, 24 Aug 2015 10:43:12 -0700
Message-ID: <1440438195-5695-6-git-send-email-pshelar@nicira.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34789 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169AbbHXRn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:43:28 -0400
Received: by pabzx8 with SMTP id zx8so11378789pab.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 10:43:27 -0700 (PDT)
In-Reply-To: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch create new tunnel flag which enable
tunnel metadata collection on given device. These devices
can be used by tunnel metadata based routing or by OVS.
Geneve Consolidation patch get rid of collect_md_tun to
simplify tunnel lookup further.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2-v3:
Do not allow regular and metadata tunnel devices on same port.
---
 drivers/net/geneve.c         |  360 ++++++++++++++++++++++++++++++++----------
 include/net/geneve.h         |    3 +
 include/uapi/linux/if_link.h |    1 +
 3 files changed, 280 insertions(+), 84 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 0a6d974..c05bc13 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -15,6 +15,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/hash.h>
+#include <net/dst_metadata.h>
 #include <net/rtnetlink.h>
 #include <net/geneve.h>
 
@@ -36,6 +37,7 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 struct geneve_net {
 	struct list_head  geneve_list;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
+	struct geneve_dev __rcu *collect_md_tun;
 };
 
 /* Pseudo network device */
@@ -50,6 +52,7 @@ struct geneve_dev {
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
 	struct list_head   next;	/* geneve's per namespace list */
 	__be16		   dst_port;
+	bool		   collect_md;
 };
 
 static int geneve_net_id;
@@ -62,48 +65,95 @@ static inline __u32 geneve_net_vni_hash(u8 vni[3])
 	return hash_32(vnid, VNI_HASH_BITS);
 }
 
-/* geneve receive/decap routine */
-static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
+static __be64 vni_to_tunnel_id(const __u8 *vni)
+{
+#ifdef __BIG_ENDIAN
+	return (vni[0] << 16) | (vni[1] << 8) | vni[2];
+#else
+	return (__force __be64)(((__force u64)vni[0] << 40) |
+				((__force u64)vni[1] << 48) |
+				((__force u64)vni[2] << 56));
+#endif
+}
+
+static struct geneve_dev *geneve_lookup(struct geneve_net *gn,
+					struct geneve_sock *gs,
+					struct iphdr *iph,
+					struct genevehdr *gnvh)
 {
 	struct inet_sock *sk = inet_sk(gs->sock->sk);
-	struct genevehdr *gnvh = geneve_hdr(skb);
-	struct geneve_dev *dummy, *geneve = NULL;
-	struct geneve_net *gn;
-	struct iphdr *iph = NULL;
-	struct pcpu_sw_netstats *stats;
 	struct hlist_head *vni_list_head;
-	int err = 0;
+	struct geneve_dev *geneve;
 	__u32 hash;
 
-	iph = ip_hdr(skb); /* Still outer IP header... */
-
-	gn = gs->rcv_data;
+	geneve = rcu_dereference(gn->collect_md_tun);
+	if (geneve)
+		return geneve;
 
 	/* Find the device for this VNI */
 	hash = geneve_net_vni_hash(gnvh->vni);
 	vni_list_head = &gn->vni_list[hash];
-	hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
-		if (!memcmp(gnvh->vni, dummy->vni, sizeof(dummy->vni)) &&
-		    iph->saddr == dummy->remote.sin_addr.s_addr &&
-		    sk->inet_sport == dummy->dst_port) {
-			geneve = dummy;
-			break;
+	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
+		if (!memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)) &&
+		    iph->saddr == geneve->remote.sin_addr.s_addr &&
+		    sk->inet_sport == geneve->dst_port) {
+			return geneve;
 		}
 	}
+	return NULL;
+}
+
+/* geneve receive/decap routine */
+static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
+{
+	struct genevehdr *gnvh = geneve_hdr(skb);
+	struct metadata_dst *tun_dst = NULL;
+	struct geneve_dev *geneve = NULL;
+	struct pcpu_sw_netstats *stats;
+	struct geneve_net *gn;
+	struct iphdr *iph;
+	int err;
+
+	iph = ip_hdr(skb); /* Still outer IP header... */
+	gn = gs->rcv_data;
+	geneve = geneve_lookup(gn, gs, iph, gnvh);
 	if (!geneve)
 		goto drop;
 
-	/* Drop packets w/ critical options,
-	 * since we don't support any...
-	 */
-	if (gnvh->critical)
-		goto drop;
+	if (ip_tunnel_collect_metadata() && geneve->collect_md) {
+		__be16 flags;
+		void *opts;
+
+		flags = TUNNEL_KEY | TUNNEL_GENEVE_OPT |
+			(gnvh->oam ? TUNNEL_OAM : 0) |
+			(gnvh->critical ? TUNNEL_CRIT_OPT : 0);
+
+		tun_dst = udp_tun_rx_dst(skb, AF_INET, flags,
+					 vni_to_tunnel_id(gnvh->vni),
+					 gnvh->opt_len * 4);
+		if (!tun_dst)
+			goto drop;
+
+		/* Update tunnel dst according to Geneve options. */
+		opts = ip_tunnel_info_opts(&tun_dst->u.tun_info,
+					   gnvh->opt_len * 4);
+		memcpy(opts, gnvh->options, gnvh->opt_len * 4);
+	} else {
+		/* Drop packets w/ critical options,
+		 * since we don't support any...
+		 */
+		if (gnvh->critical)
+			goto drop;
+	}
 
 	skb_reset_mac_header(skb);
 	skb_scrub_packet(skb, !net_eq(geneve->net, dev_net(geneve->dev)));
 	skb->protocol = eth_type_trans(skb, geneve->dev);
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
+	if (tun_dst)
+		skb_dst_set(skb, &tun_dst->dst);
+
 	/* Ignore packet loops (and multicast echo) */
 	if (ether_addr_equal(eth_hdr(skb)->h_source, geneve->dev->dev_addr))
 		goto drop;
@@ -131,7 +181,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	u64_stats_update_end(&stats->syncp);
 
 	netif_rx(skb);
-
 	return;
 drop:
 	/* Consume bad packet */
@@ -141,10 +190,15 @@ drop:
 /* Setup stats when device is created */
 static int geneve_init(struct net_device *dev)
 {
+	struct geneve_dev *geneve = netdev_priv(dev);
+
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	if (geneve->collect_md)
+		dev->features |= NETIF_F_NETNS_LOCAL;
+
 	return 0;
 }
 
@@ -180,69 +234,137 @@ static int geneve_stop(struct net_device *dev)
 	return 0;
 }
 
+static struct rtable *geneve_get_rt(struct sk_buff *skb,
+				    struct net_device *dev,
+				    struct flowi4 *fl4,
+				    struct ip_tunnel_info *info)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct rtable *rt = NULL;
+	__u8 tos;
+
+	memset(fl4, 0, sizeof(*fl4));
+	fl4->flowi4_mark = skb->mark;
+	fl4->flowi4_proto = IPPROTO_UDP;
+
+	if (info) {
+		fl4->daddr = info->key.u.ipv4.dst;
+		fl4->saddr = info->key.u.ipv4.src;
+		fl4->flowi4_tos = RT_TOS(info->key.tos);
+	} else {
+		tos = geneve->tos;
+		if (tos == 1) {
+			const struct iphdr *iip = ip_hdr(skb);
+
+			tos = ip_tunnel_get_dsfield(iip, skb);
+		}
+
+		fl4->flowi4_tos = RT_TOS(tos);
+		fl4->daddr = geneve->remote.sin_addr.s_addr;
+	}
+
+	rt = ip_route_output_key(geneve->net, fl4);
+	if (IS_ERR(rt)) {
+		netdev_dbg(dev, "no route to %pI4\n", &fl4->daddr);
+		dev->stats.tx_carrier_errors++;
+		return rt;
+	}
+	if (rt->dst.dev == dev) { /* is this necessary? */
+		netdev_dbg(dev, "circular route to %pI4\n", &fl4->daddr);
+		dev->stats.collisions++;
+		ip_rt_put(rt);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return rt;
+}
+
+/* Convert 64 bit tunnel ID to 24 bit VNI. */
+static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
+{
+#ifdef __BIG_ENDIAN
+	vni[0] = (__force __u8)(tun_id >> 16);
+	vni[1] = (__force __u8)(tun_id >> 8);
+	vni[2] = (__force __u8)tun_id;
+#else
+	vni[0] = (__force __u8)((__force u64)tun_id >> 40);
+	vni[1] = (__force __u8)((__force u64)tun_id >> 48);
+	vni[2] = (__force __u8)((__force u64)tun_id >> 56);
+#endif
+}
+
 static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct geneve_sock *gs = geneve->sock;
+	struct ip_tunnel_info *info = NULL;
 	struct rtable *rt = NULL;
 	const struct iphdr *iip; /* interior IP header */
 	struct flowi4 fl4;
-	int err;
-	__be16 sport;
 	__u8 tos, ttl;
+	__be16 sport;
+	bool xnet;
+	int err;
 
-	iip = ip_hdr(skb);
-
-	skb_reset_mac_header(skb);
-
-	/* TODO: port min/max limits should be configurable */
-	sport = udp_flow_src_port(dev_net(dev), skb, 0, 0, true);
-
-	tos = geneve->tos;
-	if (tos == 1)
-		tos = ip_tunnel_get_dsfield(iip, skb);
+	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 
-	memset(&fl4, 0, sizeof(fl4));
-	fl4.flowi4_tos = RT_TOS(tos);
-	fl4.daddr = geneve->remote.sin_addr.s_addr;
-	fl4.flowi4_mark = skb->mark;
-	fl4.flowi4_proto = IPPROTO_UDP;
+	if (geneve->collect_md) {
+		info = skb_tunnel_info(skb);
+		if (unlikely(info && info->mode != IP_TUNNEL_INFO_TX)) {
+			netdev_dbg(dev, "no tunnel metadata\n");
+			goto tx_error;
+		}
+	}
 
-	rt = ip_route_output_key(geneve->net, &fl4);
+	rt = geneve_get_rt(skb, dev, &fl4, info);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to %pI4\n", &fl4.daddr);
 		dev->stats.tx_carrier_errors++;
 		goto tx_error;
 	}
-	if (rt->dst.dev == dev) { /* is this necessary? */
-		netdev_dbg(dev, "circular route to %pI4\n", &fl4.daddr);
-		dev->stats.collisions++;
-		goto rt_tx_error;
+	skb_reset_mac_header(skb);
+	xnet = !net_eq(geneve->net, dev_net(geneve->dev));
+
+	if (info) {
+		const struct ip_tunnel_key *key = &info->key;
+		bool udp_csum;
+		u8 *opts = NULL;
+		u8 vni[3];
+		__be16 df;
+
+		tunnel_id_to_vni(key->tun_id, vni);
+		df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
+		udp_csum = !!(key->tun_flags & TUNNEL_CSUM);
+
+		if (key->tun_flags & TUNNEL_GENEVE_OPT)
+			opts = ip_tunnel_info_opts(info, info->options_len);
+
+		err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr,
+				      key->tos, key->ttl, df,
+				      sport, geneve->dst_port,
+				      key->tun_flags, vni,
+				      info->options_len, opts, udp_csum, xnet);
+	} else {
+		iip = ip_hdr(skb);
+		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, iip, skb);
+
+		ttl = geneve->ttl;
+		if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
+			ttl = 1;
+
+		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
+
+		/* no need to handle local destination and encap bypass...yet... */
+		err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr, tos,
+				      ttl, 0, sport, geneve->dst_port, 0,
+				      geneve->vni, 0, NULL, false, xnet);
 	}
-
-	tos = ip_tunnel_ecn_encap(tos, iip, skb);
-
-	ttl = geneve->ttl;
-	if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
-		ttl = 1;
-
-	ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-
-	/* no need to handle local destination and encap bypass...yet... */
-
-	err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr,
-			      tos, ttl, 0, sport, geneve->dst_port, 0,
-	                      geneve->vni, 0, NULL, false,
-	                      !net_eq(geneve->net, dev_net(geneve->dev)));
 	if (err < 0)
 		ip_rt_put(rt);
 
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
-
 	return NETDEV_TX_OK;
 
-rt_tx_error:
-	ip_rt_put(rt);
 tx_error:
 	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
@@ -312,6 +434,7 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_TTL]		= { .type = NLA_U8 },
 	[IFLA_GENEVE_TOS]		= { .type = NLA_U8 },
 	[IFLA_GENEVE_PORT]		= { .type = NLA_U16 },
+	[IFLA_GENEVE_COLLECT_METADATA]	= { .type = NLA_FLAG },
 };
 
 static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -337,71 +460,112 @@ static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int geneve_newlink(struct net *net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+static int geneve_configure(struct net *net, struct net_device *dev,
+			    __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
+			    __u16 dst_port, bool metadata)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_dev *dummy, *geneve = netdev_priv(dev);
 	struct hlist_head *vni_list_head;
 	struct sockaddr_in remote;	/* IPv4 address for link partner */
-	__u32 vni, hash;
-	__be16 dst_port;
+	__u32 hash;
 	int err;
 
-	if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
-		return -EINVAL;
+	if (metadata) {
+		if (rtnl_dereference(gn->collect_md_tun))
+			return -EEXIST;
+		if (!list_empty(&gn->geneve_list))
+			return -EPERM;
+	} else {
+		if (rtnl_dereference(gn->collect_md_tun))
+			return -EPERM;
+	}
 
 	geneve->net = net;
 	geneve->dev = dev;
 
-	vni = nla_get_u32(data[IFLA_GENEVE_ID]);
 	geneve->vni[0] = (vni & 0x00ff0000) >> 16;
 	geneve->vni[1] = (vni & 0x0000ff00) >> 8;
 	geneve->vni[2] =  vni & 0x000000ff;
 
-	geneve->remote.sin_addr.s_addr =
-		nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
+	geneve->remote.sin_addr.s_addr = rem_addr;
 	if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
 		return -EINVAL;
 
-	if (data[IFLA_GENEVE_PORT])
-		dst_port = htons(nla_get_u16(data[IFLA_GENEVE_PORT]));
-	else
-		dst_port = htons(GENEVE_UDP_PORT);
-
 	remote = geneve->remote;
+	if (metadata) {
+		if (rem_addr || vni || tos || ttl)
+			return -EINVAL;
+	}
+
 	hash = geneve_net_vni_hash(geneve->vni);
 	vni_list_head = &gn->vni_list[hash];
 	hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
 		if (!memcmp(geneve->vni, dummy->vni, sizeof(dummy->vni)) &&
 		    !memcmp(&remote, &dummy->remote, sizeof(dummy->remote)) &&
-		    dst_port == dummy->dst_port) {
+		    htons(dst_port) == dummy->dst_port) {
 			return -EBUSY;
 		}
 	}
 
+	geneve->ttl = ttl;
+	geneve->tos = tos;
+	geneve->dst_port = htons(dst_port);
+	geneve->collect_md = metadata;
+
 	err = register_netdevice(dev);
 	if (err)
 		return err;
 
+	list_add(&geneve->next, &gn->geneve_list);
+	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
+
+	if (geneve->collect_md)
+		rcu_assign_pointer(gn->collect_md_tun, geneve);
+	return 0;
+}
+
+static int geneve_newlink(struct net *net, struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[])
+{
+	__u16 dst_port = GENEVE_UDP_PORT;
+	__u8 ttl = 0, tos = 0;
+	bool metadata = false;
+	__be32 rem_addr;
+	__u32 vni;
+
+	if (!data[IFLA_GENEVE_ID] || !data[IFLA_GENEVE_REMOTE])
+		return -EINVAL;
+
+	vni = nla_get_u32(data[IFLA_GENEVE_ID]);
+	rem_addr = nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
+
 	if (data[IFLA_GENEVE_TTL])
-		geneve->ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
+		ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
 
 	if (data[IFLA_GENEVE_TOS])
-		geneve->tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
+		tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
 
-	geneve->dst_port = dst_port;
-	list_add(&geneve->next, &gn->geneve_list);
+	if (data[IFLA_GENEVE_PORT])
+		dst_port = nla_get_u16(data[IFLA_GENEVE_PORT]);
 
-	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
+	if (data[IFLA_GENEVE_COLLECT_METADATA])
+		metadata = true;
 
-	return 0;
+	return geneve_configure(net, dev, rem_addr, vni,
+				ttl, tos, dst_port, metadata);
 }
 
 static void geneve_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 
+	if (geneve->collect_md) {
+		struct geneve_net *gn = net_generic(geneve->net, geneve_net_id);
+
+		rcu_assign_pointer(gn->collect_md_tun, NULL);
+	}
+
 	if (!hlist_unhashed(&geneve->hlist))
 		hlist_del_rcu(&geneve->hlist);
 
@@ -416,6 +580,7 @@ static size_t geneve_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
 		nla_total_size(sizeof(__u16)) +  /* IFLA_GENEVE_PORT */
+		nla_total_size(0) +	 /* IFLA_GENEVE_COLLECT_METADATA */
 		0;
 }
 
@@ -439,6 +604,11 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u16(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
 		goto nla_put_failure;
 
+	if (geneve->collect_md) {
+		if (nla_put_flag(skb, IFLA_GENEVE_COLLECT_METADATA))
+			goto nla_put_failure;
+	}
+
 	return 0;
 
 nla_put_failure:
@@ -458,6 +628,28 @@ static struct rtnl_link_ops geneve_link_ops __read_mostly = {
 	.fill_info	= geneve_fill_info,
 };
 
+struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
+					u8 name_assign_type, u16 dst_port)
+{
+	struct nlattr *tb[IFLA_MAX + 1];
+	struct net_device *dev;
+	int err;
+
+	memset(tb, 0, sizeof(tb));
+	dev = rtnl_create_link(net, name, name_assign_type,
+			       &geneve_link_ops, tb);
+	if (IS_ERR(dev))
+		return dev;
+
+	err = geneve_configure(net, dev, 0, 0, 0, 0, dst_port, true);
+	if (err) {
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+	return dev;
+}
+EXPORT_SYMBOL_GPL(geneve_dev_create_fb);
+
 static __net_init int geneve_init_net(struct net *net)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
diff --git a/include/net/geneve.h b/include/net/geneve.h
index 2a0543a..4245e1d 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -96,6 +96,9 @@ int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
 		    __u8 ttl, __be16 df, __be16 src_port, __be16 dst_port,
 		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
 		    bool csum, bool xnet);
+
+struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
+					u8 name_assign_type, u16 dst_port);
 #endif /*ifdef CONFIG_INET */
 
 #endif /*ifdef__NET_GENEVE_H */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index aa0d0f1..2a8807c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -410,6 +410,7 @@ enum {
 	IFLA_GENEVE_TTL,
 	IFLA_GENEVE_TOS,
 	IFLA_GENEVE_PORT,	/* destination port */
+	IFLA_GENEVE_COLLECT_METADATA,
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
-- 
1.7.1
