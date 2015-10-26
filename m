From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v7 1/3] geneve: implement support for IPv6-based tunnels
Date: Mon, 26 Oct 2015 17:01:44 -0400
Message-ID: <1445893306-31225-1-git-send-email-linville@tuxdriver.com>
References: <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
Cc: Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	=?UTF-8?q?YOSHIFUJI=20Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59207 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbbJZVK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 17:10:26 -0400
In-Reply-To: <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NOTE: Link-local IPv6 addresses for remote endpoints are not supported,
since the driver currently has no capacity for binding a geneve
interface to a specific link.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Reviewed-by: Jesse Gross <jesse@nicira.com>
---
v7:
- rebase on top of commit fc4099f17240 ("openvswitch: Fix egress tunnel info.")
- revise error handling in ipv6 tx path to match ipv4 tx path (as above)
- Added Reviewed-by from Jesse based on v6 review -- changes above are minor

v6:
- fix a typo (missing {}'s)

v5:
- wrap declaration of sock6 in geneve_dev with IS_ENABLED(CONFIG_IPV6)
- remove superfluous '!!' when assigning geneve->collect_md to bool
- use skb_scrub_packet in IPv4 tx path as well 
- check for NULL ip_tunnel_info pointer in geneve[6]_xmit_skb
- use ipv6_addr_equal for comparing IPv6 addresses
- more use of IS_ENABLED(CONFIG_IPV6) for preserving build integrity
- reject link-local ipv6 address for remote tunnel endpoint

v4:
- treat mode field of ip_tunnel_info as flags
- add a missing IS_ENABLED(CONFIG_IPV6) to geneve_rx
- remove unneeded flags field in geneve_dev
- NULL-check parameter for __geneve_sock_release
- check remote socket family for AF_UNSPEC in geneve_configure
- rename geneve_get_{rt,dst} as geneve_get_{v4_rt,v6_dst}
- refactor some error handling in the xmit paths

v3:
- declare geneve_remote_unspec as static

v2:
- do not require remote address for tx on metadata tunnels
- pass correct sockaddr family to udp_tun_rx_dst in geneve_rx
- accommodate both ipv4 and ipv6 sockets open on same tunnel
- move declaration of geneve_get_dst for aesthetic purposes

 drivers/net/geneve.c         | 473 +++++++++++++++++++++++++++++++++++--------
 include/uapi/linux/if_link.h |   1 +
 2 files changed, 395 insertions(+), 79 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 445071c163cb..393b0bddf7cf 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -46,16 +46,27 @@ struct geneve_net {
 
 static int geneve_net_id;
 
+union geneve_addr {
+	struct sockaddr_in sin;
+	struct sockaddr_in6 sin6;
+	struct sockaddr sa;
+};
+
+static union geneve_addr geneve_remote_unspec = { .sa.sa_family = AF_UNSPEC, };
+
 /* Pseudo network device */
 struct geneve_dev {
 	struct hlist_node  hlist;	/* vni hash table */
 	struct net	   *net;	/* netns for packet i/o */
 	struct net_device  *dev;	/* netdev for geneve tunnel */
-	struct geneve_sock *sock;	/* socket used for geneve tunnel */
+	struct geneve_sock *sock4;	/* IPv4 socket used for geneve tunnel */
+#if IS_ENABLED(CONFIG_IPV6)
+	struct geneve_sock *sock6;	/* IPv6 socket used for geneve tunnel */
+#endif
 	u8                 vni[3];	/* virtual network ID for tunnel */
 	u8                 ttl;		/* TTL override */
 	u8                 tos;		/* TOS override */
-	struct sockaddr_in remote;	/* IPv4 address for link partner */
+	union geneve_addr  remote;	/* IP address for link partner */
 	struct list_head   next;	/* geneve's per namespace list */
 	__be16		   dst_port;
 	bool		   collect_md;
@@ -103,11 +114,31 @@ static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 	vni_list_head = &gs->vni_list[hash];
 	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
 		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
-		    addr == geneve->remote.sin_addr.s_addr)
+		    addr == geneve->remote.sin.sin_addr.s_addr)
+			return geneve;
+	}
+	return NULL;
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static struct geneve_dev *geneve6_lookup(struct geneve_sock *gs,
+					 struct in6_addr addr6, u8 vni[])
+{
+	struct hlist_head *vni_list_head;
+	struct geneve_dev *geneve;
+	__u32 hash;
+
+	/* Find the device for this VNI */
+	hash = geneve_net_vni_hash(vni);
+	vni_list_head = &gs->vni_list[hash];
+	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
+		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
+		    ipv6_addr_equal(&addr6, &geneve->remote.sin6.sin6_addr))
 			return geneve;
 	}
 	return NULL;
 }
+#endif
 
 static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
 {
@@ -121,24 +152,49 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	struct metadata_dst *tun_dst = NULL;
 	struct geneve_dev *geneve = NULL;
 	struct pcpu_sw_netstats *stats;
-	struct iphdr *iph;
-	u8 *vni;
+	struct iphdr *iph = NULL;
 	__be32 addr;
-	int err;
+	static u8 zero_vni[3];
+	u8 *vni;
+	int err = 0;
+	sa_family_t sa_family;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6hdr *ip6h = NULL;
+	struct in6_addr addr6;
+	static struct in6_addr zero_addr6;
+#endif
 
-	iph = ip_hdr(skb); /* outer IP header... */
+	sa_family = gs->sock->sk->sk_family;
 
-	if (gs->collect_md) {
-		static u8 zero_vni[3];
+	if (sa_family == AF_INET) {
+		iph = ip_hdr(skb); /* outer IP header... */
 
-		vni = zero_vni;
-		addr = 0;
-	} else {
-		vni = gnvh->vni;
-		addr = iph->saddr;
-	}
+		if (gs->collect_md) {
+			vni = zero_vni;
+			addr = 0;
+		} else {
+			vni = gnvh->vni;
+
+			addr = iph->saddr;
+		}
+
+		geneve = geneve_lookup(gs, addr, vni);
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if (sa_family == AF_INET6) {
+		ip6h = ipv6_hdr(skb); /* outer IPv6 header... */
 
-	geneve = geneve_lookup(gs, addr, vni);
+		if (gs->collect_md) {
+			vni = zero_vni;
+			addr6 = zero_addr6;
+		} else {
+			vni = gnvh->vni;
+
+			addr6 = ip6h->saddr;
+		}
+
+		geneve = geneve6_lookup(gs, addr6, vni);
+#endif
+	}
 	if (!geneve)
 		goto drop;
 
@@ -149,7 +205,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 			(gnvh->oam ? TUNNEL_OAM : 0) |
 			(gnvh->critical ? TUNNEL_CRIT_OPT : 0);
 
-		tun_dst = udp_tun_rx_dst(skb, AF_INET, flags,
+		tun_dst = udp_tun_rx_dst(skb, sa_family, flags,
 					 vni_to_tunnel_id(gnvh->vni),
 					 gnvh->opt_len * 4);
 		if (!tun_dst)
@@ -179,12 +235,25 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	err = IP_ECN_decapsulate(iph, skb);
+	if (iph)
+		err = IP_ECN_decapsulate(iph, skb);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ip6h)
+		err = IP6_ECN_decapsulate(ip6h, skb);
+#endif
 
 	if (unlikely(err)) {
-		if (log_ecn_error)
-			net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-					     &iph->saddr, iph->tos);
+		if (log_ecn_error) {
+			if (iph)
+				net_info_ratelimited("non-ECT from %pI4 "
+						     "with TOS=%#x\n",
+						     &iph->saddr, iph->tos);
+#if IS_ENABLED(CONFIG_IPV6)
+			if (ip6h)
+				net_info_ratelimited("non-ECT from %pI6\n",
+						     &ip6h->saddr);
+#endif
+		}
 		if (err > 1) {
 			++geneve->dev->stats.rx_frame_errors;
 			++geneve->dev->stats.rx_errors;
@@ -284,6 +353,7 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 
 	if (ipv6) {
 		udp_conf.family = AF_INET6;
+		udp_conf.ipv6_v6only = 1;
 	} else {
 		udp_conf.family = AF_INET;
 		udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
@@ -458,9 +528,9 @@ static void geneve_notify_del_rx_port(struct geneve_sock *gs)
 		udp_del_offload(&gs->udp_offloads);
 }
 
-static void geneve_sock_release(struct geneve_sock *gs)
+static void __geneve_sock_release(struct geneve_sock *gs)
 {
-	if (--gs->refcnt)
+	if (!gs || --gs->refcnt)
 		return;
 
 	list_del(&gs->list);
@@ -469,66 +539,117 @@ static void geneve_sock_release(struct geneve_sock *gs)
 	kfree_rcu(gs, rcu);
 }
 
+static void geneve_sock_release(struct geneve_dev *geneve)
+{
+	__geneve_sock_release(geneve->sock4);
+#if IS_ENABLED(CONFIG_IPV6)
+	__geneve_sock_release(geneve->sock6);
+#endif
+}
+
 static struct geneve_sock *geneve_find_sock(struct geneve_net *gn,
+					    sa_family_t family,
 					    __be16 dst_port)
 {
 	struct geneve_sock *gs;
 
 	list_for_each_entry(gs, &gn->sock_list, list) {
 		if (inet_sk(gs->sock->sk)->inet_sport == dst_port &&
-		    inet_sk(gs->sock->sk)->sk.sk_family == AF_INET) {
+		    inet_sk(gs->sock->sk)->sk.sk_family == family) {
 			return gs;
 		}
 	}
 	return NULL;
 }
 
-static int geneve_open(struct net_device *dev)
+static int geneve_sock_add(struct geneve_dev *geneve, bool ipv6)
 {
-	struct geneve_dev *geneve = netdev_priv(dev);
 	struct net *net = geneve->net;
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 	__u32 hash;
 
-	gs = geneve_find_sock(gn, geneve->dst_port);
+	gs = geneve_find_sock(gn, ipv6 ? AF_INET6 : AF_INET, geneve->dst_port);
 	if (gs) {
 		gs->refcnt++;
 		goto out;
 	}
 
-	gs = geneve_socket_create(net, geneve->dst_port, false);
+	gs = geneve_socket_create(net, geneve->dst_port, ipv6);
 	if (IS_ERR(gs))
 		return PTR_ERR(gs);
 
 out:
 	gs->collect_md = geneve->collect_md;
-	geneve->sock = gs;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipv6)
+		geneve->sock6 = gs;
+	else
+#endif
+		geneve->sock4 = gs;
 
 	hash = geneve_net_vni_hash(geneve->vni);
 	hlist_add_head_rcu(&geneve->hlist, &gs->vni_list[hash]);
 	return 0;
 }
 
+static int geneve_open(struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	bool ipv6 = geneve->remote.sa.sa_family == AF_INET6;
+	bool metadata = geneve->collect_md;
+	int ret = 0;
+
+	geneve->sock4 = NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+	geneve->sock6 = NULL;
+	if (ipv6 || metadata)
+		ret = geneve_sock_add(geneve, true);
+#endif
+	if (!ret && (!ipv6 || metadata))
+		ret = geneve_sock_add(geneve, false);
+	if (ret < 0)
+		geneve_sock_release(geneve);
+
+	return ret;
+}
+
 static int geneve_stop(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
-	struct geneve_sock *gs = geneve->sock;
 
 	if (!hlist_unhashed(&geneve->hlist))
 		hlist_del_rcu(&geneve->hlist);
-	geneve_sock_release(gs);
+	geneve_sock_release(geneve);
 	return 0;
 }
 
+static void geneve_build_header(struct genevehdr *geneveh,
+				__be16 tun_flags, u8 vni[3],
+				u8 options_len, u8 *options)
+{
+	geneveh->ver = GENEVE_VER;
+	geneveh->opt_len = options_len / 4;
+	geneveh->oam = !!(tun_flags & TUNNEL_OAM);
+	geneveh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
+	geneveh->rsvd1 = 0;
+	memcpy(geneveh->vni, vni, 3);
+	geneveh->proto_type = htons(ETH_P_TEB);
+	geneveh->rsvd2 = 0;
+
+	memcpy(geneveh->options, options, options_len);
+}
+
 static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 			    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
-			    bool csum)
+			    bool csum, bool xnet)
 {
 	struct genevehdr *gnvh;
 	int min_headroom;
 	int err;
 
+	skb_scrub_packet(skb, xnet);
+
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr);
 	err = skb_cow_head(skb, min_headroom);
@@ -544,15 +665,7 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 	}
 
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
-	gnvh->ver = GENEVE_VER;
-	gnvh->opt_len = opt_len / 4;
-	gnvh->oam = !!(tun_flags & TUNNEL_OAM);
-	gnvh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
-	gnvh->rsvd1 = 0;
-	memcpy(gnvh->vni, vni, 3);
-	gnvh->proto_type = htons(ETH_P_TEB);
-	gnvh->rsvd2 = 0;
-	memcpy(gnvh->options, opt, opt_len);
+	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
@@ -562,10 +675,47 @@ free_rt:
 	return err;
 }
 
-static struct rtable *geneve_get_rt(struct sk_buff *skb,
-				    struct net_device *dev,
-				    struct flowi4 *fl4,
-				    struct ip_tunnel_info *info)
+#if IS_ENABLED(CONFIG_IPV6)
+static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
+			     __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
+			     bool csum, bool xnet)
+{
+	struct genevehdr *gnvh;
+	int min_headroom;
+	int err;
+
+	skb_scrub_packet(skb, xnet);
+
+	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
+			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct ipv6hdr);
+	err = skb_cow_head(skb, min_headroom);
+	if (unlikely(err)) {
+		kfree_skb(skb);
+		goto free_dst;
+	}
+
+	skb = udp_tunnel_handle_offloads(skb, csum);
+	if (IS_ERR(skb)) {
+		err = PTR_ERR(skb);
+		goto free_dst;
+	}
+
+	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
+	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
+
+	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
+	return 0;
+
+free_dst:
+	dst_release(dst);
+	return err;
+}
+#endif
+
+static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
+				       struct net_device *dev,
+				       struct flowi4 *fl4,
+				       struct ip_tunnel_info *info)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct rtable *rt = NULL;
@@ -588,7 +738,7 @@ static struct rtable *geneve_get_rt(struct sk_buff *skb,
 		}
 
 		fl4->flowi4_tos = RT_TOS(tos);
-		fl4->daddr = geneve->remote.sin_addr.s_addr;
+		fl4->daddr = geneve->remote.sin.sin_addr.s_addr;
 	}
 
 	rt = ip_route_output_key(geneve->net, fl4);
@@ -604,6 +754,41 @@ static struct rtable *geneve_get_rt(struct sk_buff *skb,
 	return rt;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
+					   struct net_device *dev,
+					   struct flowi6 *fl6,
+					   struct ip_tunnel_info *info)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_sock *gs6 = geneve->sock6;
+	struct dst_entry *dst = NULL;
+
+	memset(fl6, 0, sizeof(*fl6));
+	fl6->flowi6_mark = skb->mark;
+	fl6->flowi6_proto = IPPROTO_UDP;
+
+	if (info) {
+		fl6->daddr = info->key.u.ipv6.dst;
+		fl6->saddr = info->key.u.ipv6.src;
+	} else {
+		fl6->daddr = geneve->remote.sin6.sin6_addr;
+	}
+
+	if (ipv6_stub->ipv6_dst_lookup(geneve->net, gs6->sock->sk, &dst, fl6)) {
+		netdev_dbg(dev, "no route to %pI6\n", &fl6->daddr);
+		return ERR_PTR(-ENETUNREACH);
+	}
+	if (dst->dev == dev) { /* is this necessary? */
+		netdev_dbg(dev, "circular route to %pI6\n", &fl6->daddr);
+		dst_release(dst);
+		return ERR_PTR(-ELOOP);
+	}
+
+	return dst;
+}
+#endif
+
 /* Convert 64 bit tunnel ID to 24 bit VNI. */
 static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
 {
@@ -618,11 +803,11 @@ static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
 #endif
 }
 
-static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
+				   struct ip_tunnel_info *info)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
-	struct geneve_sock *gs = geneve->sock;
-	struct ip_tunnel_info *info = NULL;
+	struct geneve_sock *gs4 = geneve->sock4;
 	struct rtable *rt = NULL;
 	const struct iphdr *iip; /* interior IP header */
 	int err = -EINVAL;
@@ -631,10 +816,10 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be16 sport;
 	bool udp_csum;
 	__be16 df;
+	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 
 	if (geneve->collect_md) {
-		info = skb_tunnel_info(skb);
-		if (unlikely(info && !(info->mode & IP_TUNNEL_INFO_TX))) {
+		if (unlikely(!info || !(info->mode & IP_TUNNEL_INFO_TX))) {
 			netdev_dbg(dev, "no tunnel metadata\n");
 			goto tx_error;
 		}
@@ -642,9 +827,8 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error;
 	}
 
-	rt = geneve_get_rt(skb, dev, &fl4, info);
+	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
 	if (IS_ERR(rt)) {
-		netdev_dbg(dev, "no route to %pI4\n", &fl4.daddr);
 		err = PTR_ERR(rt);
 		goto tx_error;
 	}
@@ -665,7 +849,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		udp_csum = !!(key->tun_flags & TUNNEL_CSUM);
 		err = geneve_build_skb(rt, skb, key->tun_flags, vni,
-				       info->options_len, opts, udp_csum);
+				       info->options_len, opts, udp_csum, xnet);
 		if (unlikely(err))
 			goto err;
 
@@ -675,7 +859,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else {
 		udp_csum = false;
 		err = geneve_build_skb(rt, skb, 0, geneve->vni,
-				       0, NULL, udp_csum);
+				       0, NULL, udp_csum, xnet);
 		if (unlikely(err))
 			goto err;
 
@@ -686,7 +870,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 		df = 0;
 	}
-	err = udp_tunnel_xmit_skb(rt, gs->sock->sk, skb, fl4.saddr, fl4.daddr,
+	err = udp_tunnel_xmit_skb(rt, gs4->sock->sk, skb, fl4.saddr, fl4.daddr,
 				  tos, ttl, df, sport, geneve->dst_port,
 				  !net_eq(geneve->net, dev_net(geneve->dev)),
 				  !udp_csum);
@@ -706,6 +890,101 @@ err:
 	return NETDEV_TX_OK;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
+static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
+				    struct ip_tunnel_info *info)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_sock *gs6 = geneve->sock6;
+	struct dst_entry *dst = NULL;
+	int err = -EINVAL;
+	struct flowi6 fl6;
+	__u8 ttl;
+	__be16 sport;
+	bool udp_csum;
+	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
+
+	if (geneve->collect_md) {
+		if (unlikely(!info || !(info->mode & IP_TUNNEL_INFO_TX))) {
+			netdev_dbg(dev, "no tunnel metadata\n");
+			goto tx_error;
+		}
+	}
+
+	dst = geneve_get_v6_dst(skb, dev, &fl6, info);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
+		goto tx_error;
+	}
+
+	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
+	skb_reset_mac_header(skb);
+
+	if (info) {
+		const struct ip_tunnel_key *key = &info->key;
+		u8 *opts = NULL;
+		u8 vni[3];
+
+		tunnel_id_to_vni(key->tun_id, vni);
+		if (key->tun_flags & TUNNEL_GENEVE_OPT)
+			opts = ip_tunnel_info_opts(info);
+
+		udp_csum = !!(key->tun_flags & TUNNEL_CSUM);
+		err = geneve6_build_skb(dst, skb, key->tun_flags, vni,
+					info->options_len, opts,
+					udp_csum, xnet);
+		if (unlikely(err))
+			goto err;
+
+		ttl = key->ttl;
+	} else {
+		udp_csum = false;
+		err = geneve6_build_skb(dst, skb, 0, geneve->vni,
+					0, NULL, udp_csum, xnet);
+		if (unlikely(err))
+			goto err;
+
+		ttl = geneve->ttl;
+		if (!ttl && ipv6_addr_is_multicast(&fl6.daddr))
+			ttl = 1;
+		ttl = ttl ? : ip6_dst_hoplimit(dst);
+	}
+	err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
+				   &fl6.saddr, &fl6.daddr, 0, ttl,
+				   sport, geneve->dst_port, !udp_csum);
+
+	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	return NETDEV_TX_OK;
+
+tx_error:
+	dev_kfree_skb(skb);
+err:
+	if (err == -ELOOP)
+		dev->stats.collisions++;
+	else if (err == -ENETUNREACH)
+		dev->stats.tx_carrier_errors++;
+	else
+		dev->stats.tx_errors++;
+	return NETDEV_TX_OK;
+}
+#endif
+
+static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct ip_tunnel_info *info = NULL;
+
+	if (geneve->collect_md)
+		info = skb_tunnel_info(skb);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if ((info && ip_tunnel_info_af(info) == AF_INET6) ||
+	    (!info && geneve->remote.sa.sa_family == AF_INET6))
+		return geneve6_xmit_skb(skb, dev, info);
+#endif
+	return geneve_xmit_skb(skb, dev, info);
+}
+
 static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ip_tunnel_info *info = skb_tunnel_info(skb);
@@ -716,7 +995,7 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	if (ip_tunnel_info_af(info) != AF_INET)
 		return -EINVAL;
 
-	rt = geneve_get_rt(skb, dev, &fl4, info);
+	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
@@ -785,6 +1064,7 @@ static void geneve_setup(struct net_device *dev)
 static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_ID]		= { .type = NLA_U32 },
 	[IFLA_GENEVE_REMOTE]		= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
+	[IFLA_GENEVE_REMOTE6]		= { .len = sizeof(struct in6_addr) },
 	[IFLA_GENEVE_TTL]		= { .type = NLA_U8 },
 	[IFLA_GENEVE_TOS]		= { .type = NLA_U8 },
 	[IFLA_GENEVE_PORT]		= { .type = NLA_U16 },
@@ -816,7 +1096,7 @@ static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
 					  __be16 dst_port,
-					  __be32 rem_addr,
+					  union geneve_addr *remote,
 					  u8 vni[],
 					  bool *tun_on_same_port,
 					  bool *tun_collect_md)
@@ -832,7 +1112,7 @@ static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
 			*tun_on_same_port = true;
 		}
 		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
-		    rem_addr == geneve->remote.sin_addr.s_addr &&
+		    !memcmp(remote, &geneve->remote, sizeof(geneve->remote)) &&
 		    dst_port == geneve->dst_port)
 			t = geneve;
 	}
@@ -840,18 +1120,20 @@ static struct geneve_dev *geneve_find_dev(struct geneve_net *gn,
 }
 
 static int geneve_configure(struct net *net, struct net_device *dev,
-			    __be32 rem_addr, __u32 vni, __u8 ttl, __u8 tos,
-			    __be16 dst_port, bool metadata)
+			    union geneve_addr *remote,
+			    __u32 vni, __u8 ttl, __u8 tos, __be16 dst_port,
+			    bool metadata)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_dev *t, *geneve = netdev_priv(dev);
 	bool tun_collect_md, tun_on_same_port;
 	int err;
 
-	if (metadata) {
-		if (rem_addr || vni || tos || ttl)
-			return -EINVAL;
-	}
+	if (!remote)
+		return -EINVAL;
+	if (metadata &&
+	    (remote->sa.sa_family != AF_UNSPEC || vni || tos || ttl))
+		return -EINVAL;
 
 	geneve->net = net;
 	geneve->dev = dev;
@@ -860,16 +1142,19 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	geneve->vni[1] = (vni & 0x0000ff00) >> 8;
 	geneve->vni[2] =  vni & 0x000000ff;
 
-	geneve->remote.sin_addr.s_addr = rem_addr;
-	if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
+	if ((remote->sa.sa_family == AF_INET &&
+	     IN_MULTICAST(ntohl(remote->sin.sin_addr.s_addr))) ||
+	    (remote->sa.sa_family == AF_INET6 &&
+	     ipv6_addr_is_multicast(&remote->sin6.sin6_addr)))
 		return -EINVAL;
+	geneve->remote = *remote;
 
 	geneve->ttl = ttl;
 	geneve->tos = tos;
 	geneve->dst_port = dst_port;
 	geneve->collect_md = metadata;
 
-	t = geneve_find_dev(gn, dst_port, rem_addr, geneve->vni,
+	t = geneve_find_dev(gn, dst_port, remote, geneve->vni,
 			    &tun_on_same_port, &tun_collect_md);
 	if (t)
 		return -EBUSY;
@@ -896,15 +1181,36 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	__be16 dst_port = htons(GENEVE_UDP_PORT);
 	__u8 ttl = 0, tos = 0;
 	bool metadata = false;
-	__be32 rem_addr = 0;
+	union geneve_addr remote = geneve_remote_unspec;
 	__u32 vni = 0;
 
+	if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6])
+		return -EINVAL;
+
+	if (data[IFLA_GENEVE_REMOTE]) {
+		remote.sa.sa_family = AF_INET;
+		remote.sin.sin_addr.s_addr =
+			nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
+	}
+
+	if (data[IFLA_GENEVE_REMOTE6]) {
+		if (!IS_ENABLED(CONFIG_IPV6))
+			return -EPFNOSUPPORT;
+
+		remote.sa.sa_family = AF_INET6;
+		remote.sin6.sin6_addr =
+			nla_get_in6_addr(data[IFLA_GENEVE_REMOTE6]);
+
+		if (ipv6_addr_type(&remote.sin6.sin6_addr) &
+		    IPV6_ADDR_LINKLOCAL) {
+			netdev_dbg(dev, "link-local remote is unsupported\n");
+			return -EINVAL;
+		}
+	}
+
 	if (data[IFLA_GENEVE_ID])
 		vni = nla_get_u32(data[IFLA_GENEVE_ID]);
 
-	if (data[IFLA_GENEVE_REMOTE])
-		rem_addr = nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
-
 	if (data[IFLA_GENEVE_TTL])
 		ttl = nla_get_u8(data[IFLA_GENEVE_TTL]);
 
@@ -917,8 +1223,8 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_GENEVE_COLLECT_METADATA])
 		metadata = true;
 
-	return geneve_configure(net, dev, rem_addr, vni,
-				ttl, tos, dst_port, metadata);
+	return geneve_configure(net, dev, &remote, vni, ttl, tos, dst_port,
+				metadata);
 }
 
 static void geneve_dellink(struct net_device *dev, struct list_head *head)
@@ -932,7 +1238,7 @@ static void geneve_dellink(struct net_device *dev, struct list_head *head)
 static size_t geneve_get_size(const struct net_device *dev)
 {
 	return nla_total_size(sizeof(__u32)) +	/* IFLA_GENEVE_ID */
-		nla_total_size(sizeof(struct in_addr)) + /* IFLA_GENEVE_REMOTE */
+		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_GENEVE_REMOTE{6} */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TTL */
 		nla_total_size(sizeof(__u8)) +  /* IFLA_GENEVE_TOS */
 		nla_total_size(sizeof(__be16)) +  /* IFLA_GENEVE_PORT */
@@ -949,9 +1255,17 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u32(skb, IFLA_GENEVE_ID, vni))
 		goto nla_put_failure;
 
-	if (nla_put_in_addr(skb, IFLA_GENEVE_REMOTE,
-			    geneve->remote.sin_addr.s_addr))
-		goto nla_put_failure;
+	if (geneve->remote.sa.sa_family == AF_INET) {
+		if (nla_put_in_addr(skb, IFLA_GENEVE_REMOTE,
+				    geneve->remote.sin.sin_addr.s_addr))
+			goto nla_put_failure;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		if (nla_put_in6_addr(skb, IFLA_GENEVE_REMOTE6,
+				     &geneve->remote.sin6.sin6_addr))
+			goto nla_put_failure;
+#endif
+	}
 
 	if (nla_put_u8(skb, IFLA_GENEVE_TTL, geneve->ttl) ||
 	    nla_put_u8(skb, IFLA_GENEVE_TOS, geneve->tos))
@@ -997,7 +1311,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	if (IS_ERR(dev))
 		return dev;
 
-	err = geneve_configure(net, dev, 0, 0, 0, 0, htons(dst_port), true);
+	err = geneve_configure(net, dev, &geneve_remote_unspec,
+			       0, 0, 0, htons(dst_port), true);
 	if (err) {
 		free_netdev(dev);
 		return ERR_PTR(err);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a7aea8418abb..5ad57375a99f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -461,6 +461,7 @@ enum {
 	IFLA_GENEVE_TOS,
 	IFLA_GENEVE_PORT,	/* destination port */
 	IFLA_GENEVE_COLLECT_METADATA,
+	IFLA_GENEVE_REMOTE6,
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
-- 
2.4.3
