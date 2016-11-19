From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v2 1/4] geneve: Unify LWT and netdev handling.
Date: Fri, 18 Nov 2016 18:10:08 -0800
Message-ID: <1479521411-53012-2-git-send-email-pshelar@ovn.org>
References: <1479521411-53012-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:45411 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbcKSCKV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 21:10:21 -0500
In-Reply-To: <1479521411-53012-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current geneve implementation has two separate cases to handle.
1. netdev xmit
2. LWT xmit.

In case of netdev, geneve configuration is stored in various
struct geneve_dev members. For example geneve_addr, ttl, tos,
label, flags, dst_cache, etc. For LWT ip_tunnel_info is passed
to the device in ip_tunnel_info.

Following patch uses ip_tunnel_info struct to store almost all
of configuration of a geneve netdevice. This allows us to unify
most of geneve driver code around ip_tunnel_info struct.
This dramatically simplify geneve code, since it does not
need to handle two different configuration cases. Removes
duplicate code, single code path can handle either type
of geneve devices.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/geneve.c | 612 ++++++++++++++++++++++-----------------------------
 1 file changed, 263 insertions(+), 349 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 85a423a..b5e65cd 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -45,41 +45,22 @@ struct geneve_net {
 
 static int geneve_net_id;
 
-union geneve_addr {
-	struct sockaddr_in sin;
-	struct sockaddr_in6 sin6;
-	struct sockaddr sa;
-};
-
-static union geneve_addr geneve_remote_unspec = { .sa.sa_family = AF_UNSPEC, };
-
 /* Pseudo network device */
 struct geneve_dev {
 	struct hlist_node  hlist;	/* vni hash table */
 	struct net	   *net;	/* netns for packet i/o */
 	struct net_device  *dev;	/* netdev for geneve tunnel */
+	struct ip_tunnel_info info;
 	struct geneve_sock __rcu *sock4;	/* IPv4 socket used for geneve tunnel */
 #if IS_ENABLED(CONFIG_IPV6)
 	struct geneve_sock __rcu *sock6;	/* IPv6 socket used for geneve tunnel */
 #endif
-	u8                 vni[3];	/* virtual network ID for tunnel */
-	u8                 ttl;		/* TTL override */
-	u8                 tos;		/* TOS override */
-	union geneve_addr  remote;	/* IP address for link partner */
 	struct list_head   next;	/* geneve's per namespace list */
-	__be32		   label;	/* IPv6 flowlabel override */
-	__be16		   dst_port;
-	bool		   collect_md;
 	struct gro_cells   gro_cells;
-	u32		   flags;
-	struct dst_cache   dst_cache;
+	bool		   collect_md;
+	bool		   use_udp6_rx_checksums;
 };
 
-/* Geneve device flags */
-#define GENEVE_F_UDP_ZERO_CSUM_TX	BIT(0)
-#define GENEVE_F_UDP_ZERO_CSUM6_TX	BIT(1)
-#define GENEVE_F_UDP_ZERO_CSUM6_RX	BIT(2)
-
 struct geneve_sock {
 	bool			collect_md;
 	struct list_head	list;
@@ -87,7 +68,6 @@ struct geneve_sock {
 	struct rcu_head		rcu;
 	int			refcnt;
 	struct hlist_head	vni_list[VNI_HASH_SIZE];
-	u32			flags;
 };
 
 static inline __u32 geneve_net_vni_hash(u8 vni[3])
@@ -109,6 +89,20 @@ static __be64 vni_to_tunnel_id(const __u8 *vni)
 #endif
 }
 
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
 static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
 {
 	return gs->sock->sk->sk_family;
@@ -117,6 +111,7 @@ static sa_family_t geneve_get_sk_family(struct geneve_sock *gs)
 static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 					__be32 addr, u8 vni[])
 {
+	__be64 id = vni_to_tunnel_id(vni);
 	struct hlist_head *vni_list_head;
 	struct geneve_dev *geneve;
 	__u32 hash;
@@ -125,8 +120,8 @@ static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 	hash = geneve_net_vni_hash(vni);
 	vni_list_head = &gs->vni_list[hash];
 	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
-		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
-		    addr == geneve->remote.sin.sin_addr.s_addr)
+		if (!memcmp(&id, &geneve->info.key.tun_id, sizeof(id)) &&
+		    addr == geneve->info.key.u.ipv4.dst)
 			return geneve;
 	}
 	return NULL;
@@ -136,6 +131,7 @@ static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 static struct geneve_dev *geneve6_lookup(struct geneve_sock *gs,
 					 struct in6_addr addr6, u8 vni[])
 {
+	__be64 id = vni_to_tunnel_id(vni);
 	struct hlist_head *vni_list_head;
 	struct geneve_dev *geneve;
 	__u32 hash;
@@ -144,8 +140,8 @@ static struct geneve_dev *geneve6_lookup(struct geneve_sock *gs,
 	hash = geneve_net_vni_hash(vni);
 	vni_list_head = &gs->vni_list[hash];
 	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
-		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
-		    ipv6_addr_equal(&addr6, &geneve->remote.sin6.sin6_addr))
+		if (!memcmp(&id, &geneve->info.key.tun_id, sizeof(id)) &&
+		    ipv6_addr_equal(&addr6, &geneve->info.key.u.ipv6.dst))
 			return geneve;
 	}
 	return NULL;
@@ -160,15 +156,12 @@ static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
 static struct geneve_dev *geneve_lookup_skb(struct geneve_sock *gs,
 					    struct sk_buff *skb)
 {
-	u8 *vni;
-	__be32 addr;
 	static u8 zero_vni[3];
-#if IS_ENABLED(CONFIG_IPV6)
-	static struct in6_addr zero_addr6;
-#endif
+	u8 *vni;
 
 	if (geneve_get_sk_family(gs) == AF_INET) {
 		struct iphdr *iph;
+		__be32 addr;
 
 		iph = ip_hdr(skb); /* outer IP header... */
 
@@ -183,6 +176,7 @@ static struct geneve_dev *geneve_lookup_skb(struct geneve_sock *gs,
 		return geneve_lookup(gs, addr, vni);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else if (geneve_get_sk_family(gs) == AF_INET6) {
+		static struct in6_addr zero_addr6;
 		struct ipv6hdr *ip6h;
 		struct in6_addr addr6;
 
@@ -305,13 +299,12 @@ static int geneve_init(struct net_device *dev)
 		return err;
 	}
 
-	err = dst_cache_init(&geneve->dst_cache, GFP_KERNEL);
+	err = dst_cache_init(&geneve->info.dst_cache, GFP_KERNEL);
 	if (err) {
 		free_percpu(dev->tstats);
 		gro_cells_destroy(&geneve->gro_cells);
 		return err;
 	}
-
 	return 0;
 }
 
@@ -319,7 +312,7 @@ static void geneve_uninit(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 
-	dst_cache_destroy(&geneve->dst_cache);
+	dst_cache_destroy(&geneve->info.dst_cache);
 	gro_cells_destroy(&geneve->gro_cells);
 	free_percpu(dev->tstats);
 }
@@ -368,7 +361,7 @@ static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 }
 
 static struct socket *geneve_create_sock(struct net *net, bool ipv6,
-					 __be16 port, u32 flags)
+					 __be16 port, bool ipv6_rx_csum)
 {
 	struct socket *sock;
 	struct udp_port_cfg udp_conf;
@@ -379,8 +372,7 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 	if (ipv6) {
 		udp_conf.family = AF_INET6;
 		udp_conf.ipv6_v6only = 1;
-		udp_conf.use_udp6_rx_checksums =
-		    !(flags & GENEVE_F_UDP_ZERO_CSUM6_RX);
+		udp_conf.use_udp6_rx_checksums = ipv6_rx_csum;
 	} else {
 		udp_conf.family = AF_INET;
 		udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
@@ -491,7 +483,7 @@ static int geneve_gro_complete(struct sock *sk, struct sk_buff *skb,
 
 /* Create new listen socket if needed */
 static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
-						bool ipv6, u32 flags)
+						bool ipv6, bool ipv6_rx_csum)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
@@ -503,7 +495,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	if (!gs)
 		return ERR_PTR(-ENOMEM);
 
-	sock = geneve_create_sock(net, ipv6, port, flags);
+	sock = geneve_create_sock(net, ipv6, port, ipv6_rx_csum);
 	if (IS_ERR(sock)) {
 		kfree(gs);
 		return ERR_CAST(sock);
@@ -579,21 +571,22 @@ static int geneve_sock_add(struct geneve_dev *geneve, bool ipv6)
 	struct net *net = geneve->net;
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
+	__u8 vni[3];
 	__u32 hash;
 
-	gs = geneve_find_sock(gn, ipv6 ? AF_INET6 : AF_INET, geneve->dst_port);
+	gs = geneve_find_sock(gn, ipv6 ? AF_INET6 : AF_INET, geneve->info.key.tp_dst);
 	if (gs) {
 		gs->refcnt++;
 		goto out;
 	}
 
-	gs = geneve_socket_create(net, geneve->dst_port, ipv6, geneve->flags);
+	gs = geneve_socket_create(net, geneve->info.key.tp_dst, ipv6,
+				  geneve->use_udp6_rx_checksums);
 	if (IS_ERR(gs))
 		return PTR_ERR(gs);
 
 out:
 	gs->collect_md = geneve->collect_md;
-	gs->flags = geneve->flags;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (ipv6)
 		rcu_assign_pointer(geneve->sock6, gs);
@@ -601,7 +594,8 @@ static int geneve_sock_add(struct geneve_dev *geneve, bool ipv6)
 #endif
 		rcu_assign_pointer(geneve->sock4, gs);
 
-	hash = geneve_net_vni_hash(geneve->vni);
+	tunnel_id_to_vni(geneve->info.key.tun_id, vni);
+	hash = geneve_net_vni_hash(vni);
 	hlist_add_head_rcu(&geneve->hlist, &gs->vni_list[hash]);
 	return 0;
 }
@@ -609,7 +603,7 @@ static int geneve_sock_add(struct geneve_dev *geneve, bool ipv6)
 static int geneve_open(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
-	bool ipv6 = geneve->remote.sa.sa_family == AF_INET6;
+	bool ipv6 = !!(geneve->info.mode & IP_TUNNEL_INFO_IPV6);
 	bool metadata = geneve->collect_md;
 	int ret = 0;
 
@@ -653,12 +647,12 @@ static void geneve_build_header(struct genevehdr *geneveh,
 
 static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 			    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
-			    u32 flags, bool xnet)
+			    bool xnet)
 {
+	bool udp_sum = !!(tun_flags & TUNNEL_CSUM);
 	struct genevehdr *gnvh;
 	int min_headroom;
 	int err;
-	bool udp_sum = !(flags & GENEVE_F_UDP_ZERO_CSUM_TX);
 
 	skb_scrub_packet(skb, xnet);
 
@@ -686,12 +680,12 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 #if IS_ENABLED(CONFIG_IPV6)
 static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 			     __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
-			     u32 flags, bool xnet)
+			     bool xnet)
 {
+	bool udp_sum = !!(tun_flags & TUNNEL_CSUM);
 	struct genevehdr *gnvh;
 	int min_headroom;
 	int err;
-	bool udp_sum = !(flags & GENEVE_F_UDP_ZERO_CSUM6_TX);
 
 	skb_scrub_packet(skb, xnet);
 
@@ -734,32 +728,22 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_mark = skb->mark;
 	fl4->flowi4_proto = IPPROTO_UDP;
+	fl4->daddr = info->key.u.ipv4.dst;
+	fl4->saddr = info->key.u.ipv4.src;
 
-	if (info) {
-		fl4->daddr = info->key.u.ipv4.dst;
-		fl4->saddr = info->key.u.ipv4.src;
-		fl4->flowi4_tos = RT_TOS(info->key.tos);
-		dst_cache = &info->dst_cache;
-	} else {
-		tos = geneve->tos;
-		if (tos == 1) {
-			const struct iphdr *iip = ip_hdr(skb);
-
-			tos = ip_tunnel_get_dsfield(iip, skb);
-			use_cache = false;
-		}
-
-		fl4->flowi4_tos = RT_TOS(tos);
-		fl4->daddr = geneve->remote.sin.sin_addr.s_addr;
-		dst_cache = &geneve->dst_cache;
+	tos = info->key.tos;
+	if (!geneve->collect_md && (tos == 1)) {
+		tos = ip_tunnel_get_dsfield(ip_hdr(skb), skb);
+		use_cache = false;
 	}
+	fl4->flowi4_tos = RT_TOS(tos);
 
+	dst_cache = &info->dst_cache;
 	if (use_cache) {
 		rt = dst_cache_get_ip4(dst_cache, &fl4->saddr);
 		if (rt)
 			return rt;
 	}
-
 	rt = ip_route_output_key(geneve->net, fl4);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to %pI4\n", &fl4->daddr);
@@ -795,34 +779,22 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->flowi6_mark = skb->mark;
 	fl6->flowi6_proto = IPPROTO_UDP;
-
-	if (info) {
-		fl6->daddr = info->key.u.ipv6.dst;
-		fl6->saddr = info->key.u.ipv6.src;
-		fl6->flowlabel = ip6_make_flowinfo(RT_TOS(info->key.tos),
-						   info->key.label);
-		dst_cache = &info->dst_cache;
-	} else {
-		prio = geneve->tos;
-		if (prio == 1) {
-			const struct iphdr *iip = ip_hdr(skb);
-
-			prio = ip_tunnel_get_dsfield(iip, skb);
-			use_cache = false;
-		}
-
-		fl6->flowlabel = ip6_make_flowinfo(RT_TOS(prio),
-						   geneve->label);
-		fl6->daddr = geneve->remote.sin6.sin6_addr;
-		dst_cache = &geneve->dst_cache;
+	fl6->daddr = info->key.u.ipv6.dst;
+	fl6->saddr = info->key.u.ipv6.src;
+	prio = info->key.tos;
+	if (!geneve->collect_md && (prio == 1)) {
+		prio = ip_tunnel_get_dsfield(ip_hdr(skb), skb);
+		use_cache = false;
 	}
 
+	fl6->flowlabel = ip6_make_flowinfo(RT_TOS(prio),
+					   info->key.label);
+	dst_cache = &info->dst_cache;
 	if (use_cache) {
 		dst = dst_cache_get_ip6(dst_cache, &fl6->saddr);
 		if (dst)
 			return dst;
 	}
-
 	if (ipv6_stub->ipv6_dst_lookup(geneve->net, gs6->sock->sk, &dst, fl6)) {
 		netdev_dbg(dev, "no route to %pI6\n", &fl6->daddr);
 		return ERR_PTR(-ENETUNREACH);
@@ -839,195 +811,130 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 }
 #endif
 
-/* Convert 64 bit tunnel ID to 24 bit VNI. */
-static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
-{
-#ifdef __BIG_ENDIAN
-	vni[0] = (__force __u8)(tun_id >> 16);
-	vni[1] = (__force __u8)(tun_id >> 8);
-	vni[2] = (__force __u8)tun_id;
-#else
-	vni[0] = (__force __u8)((__force u64)tun_id >> 40);
-	vni[1] = (__force __u8)((__force u64)tun_id >> 48);
-	vni[2] = (__force __u8)((__force u64)tun_id >> 56);
-#endif
-}
-
-static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
-				   struct ip_tunnel_info *info)
+static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
+			   struct geneve_dev *geneve, struct ip_tunnel_info *info)
 {
-	struct geneve_dev *geneve = netdev_priv(dev);
-	struct geneve_sock *gs4;
-	struct rtable *rt = NULL;
-	const struct iphdr *iip; /* interior IP header */
+	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
+	struct geneve_sock *gs4 = rcu_dereference(geneve->sock4);
+	const struct ip_tunnel_key *key = &info->key;
+	struct rtable *rt;
 	int err = -EINVAL;
 	struct flowi4 fl4;
+	u8 *opts = NULL;
 	__u8 tos, ttl;
 	__be16 sport;
 	__be16 df;
-	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
-	u32 flags = geneve->flags;
+	u8 vni[3];
 
-	gs4 = rcu_dereference(geneve->sock4);
 	if (!gs4)
-		goto tx_error;
-
-	if (geneve->collect_md) {
-		if (unlikely(!info || !(info->mode & IP_TUNNEL_INFO_TX))) {
-			netdev_dbg(dev, "no tunnel metadata\n");
-			goto tx_error;
-		}
-		if (info && ip_tunnel_info_af(info) != AF_INET)
-			goto tx_error;
-	}
+		return err;
 
 	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto tx_error;
-	}
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
 
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
-	skb_reset_mac_header(skb);
-
-	iip = ip_hdr(skb);
-
-	if (info) {
-		const struct ip_tunnel_key *key = &info->key;
-		u8 *opts = NULL;
-		u8 vni[3];
-
-		tunnel_id_to_vni(key->tun_id, vni);
-		if (info->options_len)
-			opts = ip_tunnel_info_opts(info);
-
-		if (key->tun_flags & TUNNEL_CSUM)
-			flags &= ~GENEVE_F_UDP_ZERO_CSUM_TX;
-		else
-			flags |= GENEVE_F_UDP_ZERO_CSUM_TX;
-
-		err = geneve_build_skb(rt, skb, key->tun_flags, vni,
-				       info->options_len, opts, flags, xnet);
-		if (unlikely(err))
-			goto tx_error;
-
-		tos = ip_tunnel_ecn_encap(key->tos, iip, skb);
+	if (geneve->collect_md) {
+		tos = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
 		ttl = key->ttl;
-		df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
 	} else {
-		err = geneve_build_skb(rt, skb, 0, geneve->vni,
-				       0, NULL, flags, xnet);
-		if (unlikely(err))
-			goto tx_error;
-
-		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, iip, skb);
-		ttl = geneve->ttl;
-		if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
-			ttl = 1;
-		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		df = 0;
+		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, ip_hdr(skb), skb);
+		ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
 	}
-	udp_tunnel_xmit_skb(rt, gs4->sock->sk, skb, fl4.saddr, fl4.daddr,
-			    tos, ttl, df, sport, geneve->dst_port,
-			    !net_eq(geneve->net, dev_net(geneve->dev)),
-			    !!(flags & GENEVE_F_UDP_ZERO_CSUM_TX));
+	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
 
-	return NETDEV_TX_OK;
-
-tx_error:
-	dev_kfree_skb(skb);
+	tunnel_id_to_vni(key->tun_id, vni);
+	if (info->options_len)
+		opts = ip_tunnel_info_opts(info);
 
-	if (err == -ELOOP)
-		dev->stats.collisions++;
-	else if (err == -ENETUNREACH)
-		dev->stats.tx_carrier_errors++;
+	skb_reset_mac_header(skb);
+	err = geneve_build_skb(rt, skb, key->tun_flags, vni,
+			       info->options_len, opts, xnet);
+	if (unlikely(err))
+		return err;
 
-	dev->stats.tx_errors++;
-	return NETDEV_TX_OK;
+	udp_tunnel_xmit_skb(rt, gs4->sock->sk, skb, fl4.saddr, fl4.daddr,
+			    tos, ttl, df, sport, geneve->info.key.tp_dst,
+			    !net_eq(geneve->net, dev_net(geneve->dev)),
+			    !(info->key.tun_flags & TUNNEL_CSUM));
+	return 0;
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
-				    struct ip_tunnel_info *info)
+static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
+			    struct geneve_dev *geneve, struct ip_tunnel_info *info)
 {
-	struct geneve_dev *geneve = netdev_priv(dev);
+	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
+	struct geneve_sock *gs6 = rcu_dereference(geneve->sock6);
+	const struct ip_tunnel_key *key = &info->key;
 	struct dst_entry *dst = NULL;
-	const struct iphdr *iip; /* interior IP header */
-	struct geneve_sock *gs6;
 	int err = -EINVAL;
 	struct flowi6 fl6;
+	u8 *opts = NULL;
 	__u8 prio, ttl;
 	__be16 sport;
-	__be32 label;
-	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
-	u32 flags = geneve->flags;
+	u8 vni[3];
 
-	gs6 = rcu_dereference(geneve->sock6);
 	if (!gs6)
-		goto tx_error;
-
-	if (geneve->collect_md) {
-		if (unlikely(!info || !(info->mode & IP_TUNNEL_INFO_TX))) {
-			netdev_dbg(dev, "no tunnel metadata\n");
-			goto tx_error;
-		}
-	}
+		return err;
 
 	dst = geneve_get_v6_dst(skb, dev, &fl6, info);
-	if (IS_ERR(dst)) {
-		err = PTR_ERR(dst);
-		goto tx_error;
-	}
+	if (IS_ERR(dst))
+		return PTR_ERR(dst);
 
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
-	skb_reset_mac_header(skb);
-
-	iip = ip_hdr(skb);
+	if (geneve->collect_md) {
+		prio = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
+		ttl = key->ttl;
+	} else {
+		prio = ip_tunnel_ecn_encap(ip6_tclass(fl6.flowlabel),
+					   ip_hdr(skb), skb);
+		ttl = key->ttl ? : ip6_dst_hoplimit(dst);
+	}
+	tunnel_id_to_vni(key->tun_id, vni);
+	if (info->options_len)
+		opts = ip_tunnel_info_opts(info);
 
-	if (info) {
-		const struct ip_tunnel_key *key = &info->key;
-		u8 *opts = NULL;
-		u8 vni[3];
+	skb_reset_mac_header(skb);
+	err = geneve6_build_skb(dst, skb, key->tun_flags, vni,
+				info->options_len, opts, xnet);
+	if (unlikely(err))
+		return err;
 
-		tunnel_id_to_vni(key->tun_id, vni);
-		if (info->options_len)
-			opts = ip_tunnel_info_opts(info);
+	udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
+			     &fl6.saddr, &fl6.daddr, prio, ttl,
+			     info->key.label, sport, geneve->info.key.tp_dst,
+			     !(info->key.tun_flags & TUNNEL_CSUM));
+	return 0;
+}
+#endif
 
-		if (key->tun_flags & TUNNEL_CSUM)
-			flags &= ~GENEVE_F_UDP_ZERO_CSUM6_TX;
-		else
-			flags |= GENEVE_F_UDP_ZERO_CSUM6_TX;
+static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct ip_tunnel_info *info = NULL;
+	int err;
 
-		err = geneve6_build_skb(dst, skb, key->tun_flags, vni,
-					info->options_len, opts,
-					flags, xnet);
-		if (unlikely(err))
+	if (geneve->collect_md) {
+		info = skb_tunnel_info(skb);
+		if (unlikely(!info || !(info->mode & IP_TUNNEL_INFO_TX))) {
+			err = -EINVAL;
+			netdev_dbg(dev, "no tunnel metadata\n");
 			goto tx_error;
-
-		prio = ip_tunnel_ecn_encap(key->tos, iip, skb);
-		ttl = key->ttl;
-		label = info->key.label;
+		}
 	} else {
-		err = geneve6_build_skb(dst, skb, 0, geneve->vni,
-					0, NULL, flags, xnet);
-		if (unlikely(err))
-			goto tx_error;
-
-		prio = ip_tunnel_ecn_encap(ip6_tclass(fl6.flowlabel),
-					   iip, skb);
-		ttl = geneve->ttl;
-		if (!ttl && ipv6_addr_is_multicast(&fl6.daddr))
-			ttl = 1;
-		ttl = ttl ? : ip6_dst_hoplimit(dst);
-		label = geneve->label;
+		info = &geneve->info;
 	}
 
-	udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
-			     &fl6.saddr, &fl6.daddr, prio, ttl, label,
-			     sport, geneve->dst_port,
-			     !!(flags & GENEVE_F_UDP_ZERO_CSUM6_TX));
-	return NETDEV_TX_OK;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (info->mode & IP_TUNNEL_INFO_IPV6)
+		err = geneve6_xmit_skb(skb, dev, geneve, info);
+	else
+#endif
+		err = geneve_xmit_skb(skb, dev, geneve, info);
 
+	if (likely(!err))
+		return NETDEV_TX_OK;
 tx_error:
 	dev_kfree_skb(skb);
 
@@ -1039,23 +946,6 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
-#endif
-
-static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	struct geneve_dev *geneve = netdev_priv(dev);
-	struct ip_tunnel_info *info = NULL;
-
-	if (geneve->collect_md)
-		info = skb_tunnel_info(skb);
-
-#if IS_ENABLED(CONFIG_IPV6)
-	if ((info && ip_tunnel_info_af(info) == AF_INET6) ||
-	    (!info && geneve->remote.sa.sa_family == AF_INET6))
-		return geneve6_xmit_skb(skb, dev, info);
-#endif
-	return geneve_xmit_skb(skb, dev, info);
-}
 
 static int geneve_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -1073,14 +963,11 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ip_tunnel_info *info = skb_tunnel_info(skb);
 	struct geneve_dev *geneve = netdev_priv(dev);
-	struct rtable *rt;
-	struct flowi4 fl4;
-#if IS_ENABLED(CONFIG_IPV6)
-	struct dst_entry *dst;
-	struct flowi6 fl6;
-#endif
 
 	if (ip_tunnel_info_af(info) == AF_INET) {
+		struct rtable *rt;
+		struct flowi4 fl4;
+
 		rt = geneve_get_v4_rt(skb, dev, &fl4, info);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
@@ -1089,6 +976,9 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 		info->key.u.ipv4.src = fl4.saddr;
 #if IS_ENABLED(CONFIG_IPV6)
 	} else if (ip_tunnel_info_af(info) == AF_INET6) {
+		struct dst_entry *dst;
+		struct flowi6 fl6;
+
 		dst = geneve_get_v6_dst(skb, dev, &fl6, info);
 		if (IS_ERR(dst))
 			return PTR_ERR(dst);
@@ -1102,7 +992,7 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 
 	info->key.tp_src = udp_flow_src_port(geneve->net, skb,
 					     1, USHRT_MAX, true);
-	info->key.tp_dst = geneve->dst_port;
+	info->key.tp_dst = geneve->info.key.tp_dst;
 	return 0;
 }
 
@@ -1224,78 +1114,69 @@ static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
-					  __be16 dst_port,
-					  union geneve_addr *remote,
-					  u8 vni[],
+					  const struct ip_tunnel_info *info,
 					  bool *tun_on_same_port,
 					  bool *tun_collect_md)
 {
-	struct geneve_dev *geneve, *t;
+	struct geneve_dev *geneve, *t = NULL;
 
 	*tun_on_same_port = false;
 	*tun_collect_md = false;
-	t = NULL;
 	list_for_each_entry(geneve, &gn->geneve_list, next) {
-		if (geneve->dst_port == dst_port) {
+		if (info->key.tp_dst == geneve->info.key.tp_dst) {
 			*tun_collect_md = geneve->collect_md;
 			*tun_on_same_port = true;
 		}
-		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
-		    !memcmp(remote, &geneve->remote, sizeof(geneve->remote)) &&
-		    dst_port == geneve->dst_port)
+		if (info->key.tun_id == geneve->info.key.tun_id &&
+		    info->key.tp_dst == geneve->info.key.tp_dst &&
+		    !memcmp(&info->key.u, &geneve->info.key.u, sizeof(info->key.u)))
 			t = geneve;
 	}
 	return t;
 }
 
+static bool is_all_zero(const u8 *fp, size_t size)
+{
+	int i;
+
+	for (i = 0; i < size; i++)
+		if (fp[i])
+			return false;
+	return true;
+}
+
+static bool is_tnl_info_zero(const struct ip_tunnel_info *info)
+{
+	if (info->key.tun_id || info->key.tun_flags || info->key.tos ||
+	    info->key.ttl || info->key.label || info->key.tp_src ||
+	    !is_all_zero((const u8 *)&info->key.u, sizeof(info->key.u)))
+		return false;
+	else
+		return true;
+}
+
 static int geneve_configure(struct net *net, struct net_device *dev,
-			    union geneve_addr *remote,
-			    __u32 vni, __u8 ttl, __u8 tos, __be32 label,
-			    __be16 dst_port, bool metadata, u32 flags)
+			    const struct ip_tunnel_info *info,
+			    bool metadata, bool ipv6_rx_csum)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_dev *t, *geneve = netdev_priv(dev);
 	bool tun_collect_md, tun_on_same_port;
 	int err, encap_len;
 
-	if (!remote)
-		return -EINVAL;
-	if (metadata &&
-	    (remote->sa.sa_family != AF_UNSPEC || vni || tos || ttl || label))
+	if (metadata && !is_tnl_info_zero(info))
 		return -EINVAL;
 
 	geneve->net = net;
 	geneve->dev = dev;
 
-	geneve->vni[0] = (vni & 0x00ff0000) >> 16;
-	geneve->vni[1] = (vni & 0x0000ff00) >> 8;
-	geneve->vni[2] =  vni & 0x000000ff;
-
-	if ((remote->sa.sa_family == AF_INET &&
-	     IN_MULTICAST(ntohl(remote->sin.sin_addr.s_addr))) ||
-	    (remote->sa.sa_family == AF_INET6 &&
-	     ipv6_addr_is_multicast(&remote->sin6.sin6_addr)))
-		return -EINVAL;
-	if (label && remote->sa.sa_family != AF_INET6)
-		return -EINVAL;
-
-	geneve->remote = *remote;
-
-	geneve->ttl = ttl;
-	geneve->tos = tos;
-	geneve->label = label;
-	geneve->dst_port = dst_port;
-	geneve->collect_md = metadata;
-	geneve->flags = flags;
-
-	t = geneve_find_dev(gn, dst_port, remote, geneve->vni,
-			    &tun_on_same_port, &tun_collect_md);
+	t = geneve_find_dev(gn, info, &tun_on_same_port, &tun_collect_md);
 	if (t)
 		return -EBUSY;
 
 	/* make enough headroom for basic scenario */
 	encap_len = GENEVE_BASE_HLEN + ETH_HLEN;
-	if (remote->sa.sa_family == AF_INET) {
+	if (ip_tunnel_info_af(info) == AF_INET) {
 		encap_len += sizeof(struct iphdr);
 		dev->max_mtu -= sizeof(struct iphdr);
 	} else {
@@ -1312,7 +1193,10 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 			return -EPERM;
 	}
 
-	dst_cache_reset(&geneve->dst_cache);
+	dst_cache_reset(&geneve->info.dst_cache);
+	geneve->info = *info;
+	geneve->collect_md = metadata;
+	geneve->use_udp6_rx_checksums = ipv6_rx_csum;
 
 	err = register_netdevice(dev);
 	if (err)
@@ -1322,74 +1206,99 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	return 0;
 }
 
+static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
+{
+	memset(info, 0, sizeof(*info));
+	info->key.tp_dst = htons(dst_port);
+}
+
 static int geneve_newlink(struct net *net, struct net_device *dev,
 			  struct nlattr *tb[], struct nlattr *data[])
 {
-	__be16 dst_port = htons(GENEVE_UDP_PORT);
-	__u8 ttl = 0, tos = 0;
+	bool use_udp6_rx_checksums = false;
+	struct ip_tunnel_info info;
 	bool metadata = false;
-	union geneve_addr remote = geneve_remote_unspec;
-	__be32 label = 0;
-	__u32 vni = 0;
-	u32 flags = 0;
+
+	init_tnl_info(&info, GENEVE_UDP_PORT);
 
 	if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6])
 		return -EINVAL;
 
 	if (data[IFLA_GENEVE_REMOTE]) {
-		remote.sa.sa_family = AF_INET;
-		remote.sin.sin_addr.s_addr =
+		info.key.u.ipv4.dst =
 			nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
+
+		if (IN_MULTICAST(ntohl(info.key.u.ipv4.dst))) {
+			netdev_dbg(dev, "multicast remote is unsupported\n");
+			return -EINVAL;
+		}
 	}
 
 	if (data[IFLA_GENEVE_REMOTE6]) {
-		if (!IS_ENABLED(CONFIG_IPV6))
-			return -EPFNOSUPPORT;
-
-		remote.sa.sa_family = AF_INET6;
-		remote.sin6.sin6_addr =
+ #if IS_ENABLED(CONFIG_IPV6)
+		info.mode = IP_TUNNEL_INFO_IPV6;
+		info.key.u.ipv6.dst =
 			nla_get_in6_addr(data[IFLA_GENEVE_REMOTE6]);
 
-		if (ipv6_addr_type(&remote.sin6.sin6_addr) &
+		if (ipv6_addr_type(&info.key.u.ipv6.dst) &
 		    IPV6_ADDR_LINKLOCAL) {
 			netdev_dbg(dev, "link-local remote is unsupported\n");
 			return -EINVAL;
 		}
+		if (ipv6_addr_is_multicast(&info.key.u.ipv6.dst)) {
+			netdev_dbg(dev, "multicast remote is unsupported\n");
+			return -EINVAL;
+		}
+		info.key.tun_flags |= TUNNEL_CSUM;
+		use_udp6_rx_checksums = true;
+#else
+		return -EPFNOSUPPORT;
+#endif
 	}
 
-	if (data[IFLA_GENEVE_ID])
+	if (data[IFLA_GENEVE_ID]) {
+		__u32 vni;
+		__u8 tvni[3];
+
 		vni = nla_get_u32(data[IFLA_GENEVE_ID]);
+		tvni[0] = (vni & 0x00ff0000) >> 16;
+		tvni[1] = (vni & 0x0000ff00) >> 8;
+		tvni[2] =  vni & 0x000000ff;
 
+		info.key.tun_id = vni_to_tunnel_id(tvni);
+	}
 	if (data[IFLA_GENEVE_TTL])
-		ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
+		info.key.ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
 
 	if (data[IFLA_GENEVE_TOS])
-		tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
+		info.key.tos = nla_get_u8(data[IFLA_GENEVE_TOS]);
 
-	if (data[IFLA_GENEVE_LABEL])
-		label = nla_get_be32(data[IFLA_GENEVE_LABEL]) &
-			IPV6_FLOWLABEL_MASK;
+	if (data[IFLA_GENEVE_LABEL]) {
+		info.key.label = nla_get_be32(data[IFLA_GENEVE_LABEL]) &
+				  IPV6_FLOWLABEL_MASK;
+		if (info.key.label && (!(info.mode & IP_TUNNEL_INFO_IPV6)))
+			return -EINVAL;
+	}
 
 	if (data[IFLA_GENEVE_PORT])
-		dst_port = nla_get_be16(data[IFLA_GENEVE_PORT]);
+		info.key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
 
 	if (data[IFLA_GENEVE_COLLECT_METADATA])
 		metadata = true;
 
 	if (data[IFLA_GENEVE_UDP_CSUM] &&
 	    !nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
-		flags |= GENEVE_F_UDP_ZERO_CSUM_TX;
+		info.key.tun_flags |= TUNNEL_CSUM;
 
 	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX] &&
 	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
-		flags |= GENEVE_F_UDP_ZERO_CSUM6_TX;
+		info.key.tun_flags &= ~TUNNEL_CSUM;
 
 	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX] &&
 	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
-		flags |= GENEVE_F_UDP_ZERO_CSUM6_RX;
+		use_udp6_rx_checksums = false;
 
-	return geneve_configure(net, dev, &remote, vni, ttl, tos, label,
-				dst_port, metadata, flags);
+	return geneve_configure(net, dev, &info, metadata, use_udp6_rx_checksums);
 }
 
 static void geneve_dellink(struct net_device *dev, struct list_head *head)
@@ -1418,45 +1327,52 @@ static size_t geneve_get_size(const struct net_device *dev)
 static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
+	struct ip_tunnel_info *info = &geneve->info;
+	__u8 tmp_vni[3];
 	__u32 vni;
 
-	vni = (geneve->vni[0] << 16) | (geneve->vni[1] << 8) | geneve->vni[2];
+	tunnel_id_to_vni(info->key.tun_id, tmp_vni);
+	vni = (tmp_vni[0] << 16) | (tmp_vni[1] << 8) | tmp_vni[2];
 	if (nla_put_u32(skb, IFLA_GENEVE_ID, vni))
 		goto nla_put_failure;
 
-	if (geneve->remote.sa.sa_family == AF_INET) {
+	if (ip_tunnel_info_af(info) == AF_INET) {
 		if (nla_put_in_addr(skb, IFLA_GENEVE_REMOTE,
-				    geneve->remote.sin.sin_addr.s_addr))
+				    info->key.u.ipv4.dst))
+			goto nla_put_failure;
+
+		if (nla_put_u8(skb, IFLA_GENEVE_UDP_CSUM,
+			       !!(info->key.tun_flags & TUNNEL_CSUM)))
 			goto nla_put_failure;
+
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		if (nla_put_in6_addr(skb, IFLA_GENEVE_REMOTE6,
-				     &geneve->remote.sin6.sin6_addr))
+				     &info->key.u.ipv6.dst))
+			goto nla_put_failure;
+
+		if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
+			       !(info->key.tun_flags & TUNNEL_CSUM)))
+			goto nla_put_failure;
+
+		if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
+			       !geneve->use_udp6_rx_checksums))
 			goto nla_put_failure;
 #endif
 	}
 
-	if (nla_put_u8(skb, IFLA_GENEVE_TTL, geneve->ttl) ||
-	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos) ||
-	    nla_put_be32(skb, IFLA_GENEVE_LABEL, geneve->label))
+	if (nla_put_u8(skb, IFLA_GENEVE_TTL, info->key.ttl) ||
+	    nla_put_u8(skb, IFLA_GENEVE_TOS, info->key.tos) ||
+	    nla_put_be32(skb, IFLA_GENEVE_LABEL, info->key.label))
 		goto nla_put_failure;
 
-	if (nla_put_be16(skb, IFLA_GENEVE_PORT, geneve->dst_port))
+	if (nla_put_be16(skb, IFLA_GENEVE_PORT, info->key.tp_dst))
 		goto nla_put_failure;
 
 	if (geneve->collect_md) {
 		if (nla_put_flag(skb, IFLA_GENEVE_COLLECT_METADATA))
 			goto nla_put_failure;
 	}
-
-	if (nla_put_u8(skb, IFLA_GENEVE_UDP_CSUM,
-		       !(geneve->flags & GENEVE_F_UDP_ZERO_CSUM_TX)) ||
-	    nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
-		       !!(geneve->flags & GENEVE_F_UDP_ZERO_CSUM6_TX)) ||
-	    nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
-		       !!(geneve->flags & GENEVE_F_UDP_ZERO_CSUM6_RX)))
-		goto nla_put_failure;
-
 	return 0;
 
 nla_put_failure:
@@ -1480,6 +1396,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port)
 {
 	struct nlattr *tb[IFLA_MAX + 1];
+	struct ip_tunnel_info info;
 	struct net_device *dev;
 	LIST_HEAD(list_kill);
 	int err;
@@ -1490,9 +1407,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	if (IS_ERR(dev))
 		return dev;
 
-	err = geneve_configure(net, dev, &geneve_remote_unspec,
-			       0, 0, 0, 0, htons(dst_port), true,
-			       GENEVE_F_UDP_ZERO_CSUM6_RX);
+	init_tnl_info(&info, dst_port);
+	err = geneve_configure(net, dev, &info, true, true);
 	if (err) {
 		free_netdev(dev);
 		return ERR_PTR(err);
@@ -1510,8 +1426,7 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 		goto err;
 
 	return dev;
-
- err:
+err:
 	geneve_dellink(dev, &list_kill);
 	unregister_netdevice_many(&list_kill);
 	return ERR_PTR(err);
@@ -1594,7 +1509,6 @@ static int __init geneve_init_module(void)
 		goto out3;
 
 	return 0;
-
 out3:
 	unregister_netdevice_notifier(&geneve_notifier_block);
 out2:
-- 
1.8.3.1
