From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 net-next 7/8] geneve: Consolidate Geneve functionality in single module.
Date: Mon, 24 Aug 2015 10:43:14 -0700
Message-ID: <1440438195-5695-8-git-send-email-pshelar@nicira.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36636 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbbHXRnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:43:31 -0400
Received: by pacgr6 with SMTP id gr6so1076919pac.3
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 10:43:31 -0700 (PDT)
In-Reply-To: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

geneve_core module handles send and receive functionality.
This way OVS could use the Geneve API. Now with use of
tunnel meatadata mode OVS can directly use Geneve netdevice.
So there is no need for separate module for Geneve. Following
patch consolidates Geneve protocol processing in single module.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2-v3:
- Fixed Kconfig dependency.
- unified geneve_build_skb()
- Fixed geneve_build_skb() error path.
---
 drivers/net/Kconfig    |    4 +-
 drivers/net/geneve.c   |  494 +++++++++++++++++++++++++++++++++++++++---------
 include/net/geneve.h   |   34 ----
 net/ipv4/Kconfig       |   14 --
 net/ipv4/Makefile      |    1 -
 net/ipv4/geneve_core.c |  447 -------------------------------------------
 6 files changed, 407 insertions(+), 587 deletions(-)
 delete mode 100644 net/ipv4/geneve_core.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f503736..7727b8b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -180,8 +180,8 @@ config VXLAN
 	  will be called vxlan.
 
 config GENEVE
-       tristate "Generic Network Virtualization Encapsulation netdev"
-       depends on INET && GENEVE_CORE
+       tristate "Generic Network Virtualization Encapsulation"
+       depends on INET && NET_UDP_TUNNEL
        select NET_IP_TUNNEL
        ---help---
 	  This allows one to create geneve virtual interfaces that provide
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index c05bc13..8eb875d 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -18,6 +18,7 @@
 #include <net/dst_metadata.h>
 #include <net/rtnetlink.h>
 #include <net/geneve.h>
+#include <net/protocol.h>
 
 #define GENEVE_NETDEV_VER	"0.6"
 
@@ -33,13 +34,18 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+#define GENEVE_VER 0
+#define GENEVE_BASE_HLEN (sizeof(struct udphdr) + sizeof(struct genevehdr))
+
 /* per-network namespace private data for this module */
 struct geneve_net {
-	struct list_head  geneve_list;
-	struct hlist_head vni_list[VNI_HASH_SIZE];
-	struct geneve_dev __rcu *collect_md_tun;
+	struct list_head	geneve_list;
+	struct hlist_head	vni_list[VNI_HASH_SIZE];
+	struct list_head	sock_list;
 };
 
+static int geneve_net_id;
+
 /* Pseudo network device */
 struct geneve_dev {
 	struct hlist_node  hlist;	/* vni hash table */
@@ -55,7 +61,15 @@ struct geneve_dev {
 	bool		   collect_md;
 };
 
-static int geneve_net_id;
+struct geneve_sock {
+	bool			collect_md;
+	struct geneve_net	*gn;
+	struct list_head	list;
+	struct socket		*sock;
+	struct rcu_head		rcu;
+	int			refcnt;
+	struct udp_offload	udp_offloads;
+};
 
 static inline __u32 geneve_net_vni_hash(u8 vni[3])
 {
@@ -76,51 +90,63 @@ static __be64 vni_to_tunnel_id(const __u8 *vni)
 #endif
 }
 
-static struct geneve_dev *geneve_lookup(struct geneve_net *gn,
-					struct geneve_sock *gs,
-					struct iphdr *iph,
-					struct genevehdr *gnvh)
+static struct geneve_dev *geneve_lookup(struct geneve_net *gn, __be16 port,
+					__be32 addr, u8 vni[])
 {
-	struct inet_sock *sk = inet_sk(gs->sock->sk);
 	struct hlist_head *vni_list_head;
 	struct geneve_dev *geneve;
 	__u32 hash;
 
-	geneve = rcu_dereference(gn->collect_md_tun);
-	if (geneve)
-		return geneve;
-
 	/* Find the device for this VNI */
-	hash = geneve_net_vni_hash(gnvh->vni);
+	hash = geneve_net_vni_hash(vni);
 	vni_list_head = &gn->vni_list[hash];
 	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
-		if (!memcmp(gnvh->vni, geneve->vni, sizeof(geneve->vni)) &&
-		    iph->saddr == geneve->remote.sin_addr.s_addr &&
-		    sk->inet_sport == geneve->dst_port) {
+		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
+		    addr == geneve->remote.sin_addr.s_addr &&
+		    port == geneve->dst_port) {
 			return geneve;
 		}
 	}
 	return NULL;
 }
 
+static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
+{
+	return (struct genevehdr *)(udp_hdr(skb) + 1);
+}
+
 /* geneve receive/decap routine */
 static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 {
+	struct inet_sock *sk = inet_sk(gs->sock->sk);
 	struct genevehdr *gnvh = geneve_hdr(skb);
+	struct geneve_net *gn = gs->gn;
 	struct metadata_dst *tun_dst = NULL;
 	struct geneve_dev *geneve = NULL;
 	struct pcpu_sw_netstats *stats;
-	struct geneve_net *gn;
 	struct iphdr *iph;
+	u8 *vni;
+	__be32 addr;
+	bool xnet;
 	int err;
 
 	iph = ip_hdr(skb); /* Still outer IP header... */
-	gn = gs->rcv_data;
-	geneve = geneve_lookup(gn, gs, iph, gnvh);
+
+	if (gs->collect_md) {
+		static u8 zero_vni[3];
+
+		vni = zero_vni;
+		addr = 0;
+	} else {
+		vni = gnvh->vni;
+		addr = iph->saddr;
+	}
+
+	geneve = geneve_lookup(gn, sk->inet_sport, addr, vni);
 	if (!geneve)
 		goto drop;
 
-	if (ip_tunnel_collect_metadata() && geneve->collect_md) {
+	if (ip_tunnel_collect_metadata() || gs->collect_md) {
 		__be16 flags;
 		void *opts;
 
@@ -138,16 +164,18 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 		opts = ip_tunnel_info_opts(&tun_dst->u.tun_info,
 					   gnvh->opt_len * 4);
 		memcpy(opts, gnvh->options, gnvh->opt_len * 4);
+		xnet = false;
 	} else {
 		/* Drop packets w/ critical options,
 		 * since we don't support any...
 		 */
 		if (gnvh->critical)
 			goto drop;
+		xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 	}
 
 	skb_reset_mac_header(skb);
-	skb_scrub_packet(skb, !net_eq(geneve->net, dev_net(geneve->dev)));
+	skb_scrub_packet(skb, xnet);
 	skb->protocol = eth_type_trans(skb, geneve->dev);
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
@@ -207,31 +235,326 @@ static void geneve_uninit(struct net_device *dev)
 	free_percpu(dev->tstats);
 }
 
+/* Callback from net/ipv4/udp.c to receive packets */
+static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
+{
+	struct genevehdr *geneveh;
+	struct geneve_sock *gs;
+	int opts_len;
+
+	/* Need Geneve and inner Ethernet header to be present */
+	if (unlikely(!pskb_may_pull(skb, GENEVE_BASE_HLEN)))
+		goto error;
+
+	/* Return packets with reserved bits set */
+	geneveh = geneve_hdr(skb);
+	if (unlikely(geneveh->ver != GENEVE_VER))
+		goto error;
+
+	if (unlikely(geneveh->proto_type != htons(ETH_P_TEB)))
+		goto error;
+
+	opts_len = geneveh->opt_len * 4;
+	if (iptunnel_pull_header(skb, GENEVE_BASE_HLEN + opts_len,
+				 htons(ETH_P_TEB)))
+		goto drop;
+
+	gs = rcu_dereference_sk_user_data(sk);
+	if (!gs)
+		goto drop;
+
+	geneve_rx(gs, skb);
+	return 0;
+
+drop:
+	/* Consume bad packet */
+	kfree_skb(skb);
+	return 0;
+
+error:
+	/* Let the UDP layer deal with the skb */
+	return 1;
+}
+
+static struct socket *geneve_create_sock(struct net *net, bool ipv6,
+					 __be16 port)
+{
+	struct socket *sock;
+	struct udp_port_cfg udp_conf;
+	int err;
+
+	memset(&udp_conf, 0, sizeof(udp_conf));
+
+	if (ipv6) {
+		udp_conf.family = AF_INET6;
+	} else {
+		udp_conf.family = AF_INET;
+		udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
+	}
+
+	udp_conf.local_udp_port = port;
+
+	/* Open UDP socket */
+	err = udp_sock_create(net, &udp_conf, &sock);
+	if (err < 0)
+		return ERR_PTR(err);
+
+	return sock;
+}
+
+static void geneve_notify_add_rx_port(struct geneve_sock *gs)
+{
+	struct sock *sk = gs->sock->sk;
+	sa_family_t sa_family = sk->sk_family;
+	int err;
+
+	if (sa_family == AF_INET) {
+		err = udp_add_offload(&gs->udp_offloads);
+		if (err)
+			pr_warn("geneve: udp_add_offload failed with status %d\n",
+				err);
+	}
+}
+
+static int geneve_hlen(struct genevehdr *gh)
+{
+	return sizeof(*gh) + gh->opt_len * 4;
+}
+
+static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
+					   struct sk_buff *skb,
+					   struct udp_offload *uoff)
+{
+	struct sk_buff *p, **pp = NULL;
+	struct genevehdr *gh, *gh2;
+	unsigned int hlen, gh_len, off_gnv;
+	const struct packet_offload *ptype;
+	__be16 type;
+	int flush = 1;
+
+	off_gnv = skb_gro_offset(skb);
+	hlen = off_gnv + sizeof(*gh);
+	gh = skb_gro_header_fast(skb, off_gnv);
+	if (skb_gro_header_hard(skb, hlen)) {
+		gh = skb_gro_header_slow(skb, hlen, off_gnv);
+		if (unlikely(!gh))
+			goto out;
+	}
+
+	if (gh->ver != GENEVE_VER || gh->oam)
+		goto out;
+	gh_len = geneve_hlen(gh);
+
+	hlen = off_gnv + gh_len;
+	if (skb_gro_header_hard(skb, hlen)) {
+		gh = skb_gro_header_slow(skb, hlen, off_gnv);
+		if (unlikely(!gh))
+			goto out;
+	}
+
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		gh2 = (struct genevehdr *)(p->data + off_gnv);
+		if (gh->opt_len != gh2->opt_len ||
+		    memcmp(gh, gh2, gh_len)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+	}
+
+	type = gh->proto_type;
+
+	rcu_read_lock();
+	ptype = gro_find_receive_by_type(type);
+	if (!ptype) {
+		flush = 1;
+		goto out_unlock;
+	}
+
+	skb_gro_pull(skb, gh_len);
+	skb_gro_postpull_rcsum(skb, gh, gh_len);
+	pp = ptype->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int geneve_gro_complete(struct sk_buff *skb, int nhoff,
+			       struct udp_offload *uoff)
+{
+	struct genevehdr *gh;
+	struct packet_offload *ptype;
+	__be16 type;
+	int gh_len;
+	int err = -ENOSYS;
+
+	udp_tunnel_gro_complete(skb, nhoff);
+
+	gh = (struct genevehdr *)(skb->data + nhoff);
+	gh_len = geneve_hlen(gh);
+	type = gh->proto_type;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype)
+		err = ptype->callbacks.gro_complete(skb, nhoff + gh_len);
+
+	rcu_read_unlock();
+	return err;
+}
+
+/* Create new listen socket if needed */
+static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
+						bool ipv6)
+{
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
+	struct geneve_sock *gs;
+	struct socket *sock;
+	struct udp_tunnel_sock_cfg tunnel_cfg;
+
+	gs = kzalloc(sizeof(*gs), GFP_KERNEL);
+	if (!gs)
+		return ERR_PTR(-ENOMEM);
+
+	sock = geneve_create_sock(net, ipv6, port);
+	if (IS_ERR(sock)) {
+		kfree(gs);
+		return ERR_CAST(sock);
+	}
+
+	gs->sock = sock;
+	gs->refcnt = 1;
+	gs->gn = gn;
+
+	/* Initialize the geneve udp offloads structure */
+	gs->udp_offloads.port = port;
+	gs->udp_offloads.callbacks.gro_receive  = geneve_gro_receive;
+	gs->udp_offloads.callbacks.gro_complete = geneve_gro_complete;
+	geneve_notify_add_rx_port(gs);
+
+	/* Mark socket as an encapsulation socket */
+	tunnel_cfg.sk_user_data = gs;
+	tunnel_cfg.encap_type = 1;
+	tunnel_cfg.encap_rcv = geneve_udp_encap_recv;
+	tunnel_cfg.encap_destroy = NULL;
+	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
+
+	list_add(&gs->list, &gn->sock_list);
+	return gs;
+}
+
+static void geneve_notify_del_rx_port(struct geneve_sock *gs)
+{
+	struct sock *sk = gs->sock->sk;
+	sa_family_t sa_family = sk->sk_family;
+
+	if (sa_family == AF_INET)
+		udp_del_offload(&gs->udp_offloads);
+}
+
+static void geneve_sock_release(struct geneve_sock *gs)
+{
+	if (--gs->refcnt)
+		return;
+
+	list_del(&gs->list);
+	geneve_notify_del_rx_port(gs);
+	udp_tunnel_sock_release(gs->sock);
+	kfree_rcu(gs, rcu);
+}
+
+static struct geneve_sock *geneve_find_sock(struct geneve_net *gn,
+					    __be16 dst_port)
+{
+	struct geneve_sock *gs;
+
+	list_for_each_entry(gs, &gn->sock_list, list) {
+		if (inet_sk(gs->sock->sk)->inet_sport == dst_port &&
+		    inet_sk(gs->sock->sk)->sk.sk_family == AF_INET) {
+			return gs;
+		}
+	}
+	return NULL;
+}
+
 static int geneve_open(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct net *net = geneve->net;
-	struct geneve_net *gn = net_generic(geneve->net, geneve_net_id);
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 
-	gs = geneve_sock_add(net, geneve->dst_port, geneve_rx, gn,
-	                     false, false);
+	gs = geneve_find_sock(gn, geneve->dst_port);
+	if (gs) {
+		gs->refcnt++;
+		goto out;
+	}
+
+	gs = geneve_socket_create(net, geneve->dst_port, false);
 	if (IS_ERR(gs))
 		return PTR_ERR(gs);
 
+out:
+	gs->collect_md = geneve->collect_md;
 	geneve->sock = gs;
-
 	return 0;
 }
 
 static int geneve_stop(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
-	struct geneve_sock *gs = geneve->sock;
 
-	geneve_sock_release(gs);
+	geneve_sock_release(geneve->sock);
+	return 0;
+}
 
+static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
+			    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
+			    bool csum)
+{
+	struct genevehdr *gnvh;
+	int min_headroom;
+	int err;
+
+	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
+			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr);
+	err = skb_cow_head(skb, min_headroom);
+	if (unlikely(err)) {
+		kfree_skb(skb);
+		goto free_rt;
+	}
+
+	skb = udp_tunnel_handle_offloads(skb, csum);
+	if (IS_ERR(skb)) {
+		err = PTR_ERR(skb);
+		goto free_rt;
+	}
+
+	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
+	gnvh->ver = GENEVE_VER;
+	gnvh->opt_len = opt_len / 4;
+	gnvh->oam = !!(tun_flags & TUNNEL_OAM);
+	gnvh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
+	gnvh->rsvd1 = 0;
+	memcpy(gnvh->vni, vni, 3);
+	gnvh->proto_type = htons(ETH_P_TEB);
+	gnvh->rsvd2 = 0;
+	memcpy(gnvh->options, opt, opt_len);
+
+	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
+
+free_rt:
+	ip_rt_put(rt);
+	return err;
 }
 
 static struct rtable *geneve_get_rt(struct sk_buff *skb,
@@ -275,7 +598,6 @@ static struct rtable *geneve_get_rt(struct sk_buff *skb,
 		ip_rt_put(rt);
 		return ERR_PTR(-EINVAL);
 	}
-
 	return rt;
 }
 
@@ -299,15 +621,13 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct geneve_sock *gs = geneve->sock;
 	struct ip_tunnel_info *info = NULL;
 	struct rtable *rt = NULL;
-	const struct iphdr *iip; /* interior IP header */
 	struct flowi4 fl4;
 	__u8 tos, ttl;
 	__be16 sport;
-	bool xnet;
+	bool xnet, udp_csum;
+	__be16 df;
 	int err;
 
-	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
-
 	if (geneve->collect_md) {
 		info = skb_tunnel_info(skb);
 		if (unlikely(info && info->mode != IP_TUNNEL_INFO_TX)) {
@@ -322,52 +642,59 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->stats.tx_carrier_errors++;
 		goto tx_error;
 	}
+
+	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 	skb_reset_mac_header(skb);
-	xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 
 	if (info) {
 		const struct ip_tunnel_key *key = &info->key;
-		bool udp_csum;
 		u8 *opts = NULL;
 		u8 vni[3];
-		__be16 df;
 
 		tunnel_id_to_vni(key->tun_id, vni);
-		df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
-		udp_csum = !!(key->tun_flags & TUNNEL_CSUM);
-
 		if (key->tun_flags & TUNNEL_GENEVE_OPT)
 			opts = ip_tunnel_info_opts(info, info->options_len);
 
-		err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr,
-				      key->tos, key->ttl, df,
-				      sport, geneve->dst_port,
-				      key->tun_flags, vni,
-				      info->options_len, opts, udp_csum, xnet);
+		udp_csum = !!(key->tun_flags & TUNNEL_CSUM);
+		err = geneve_build_skb(rt, skb, key->tun_flags, vni,
+				       info->options_len, opts, udp_csum);
+		if (unlikely(err))
+			goto err;
+
+		tos = key->tos;
+		ttl = key->ttl;
+		df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
+		xnet = false;
 	} else {
+		const struct iphdr *iip; /* interior IP header */
+
+		udp_csum = false;
+		err = geneve_build_skb(rt, skb, 0, geneve->vni,
+				       0, NULL, udp_csum);
+		if (unlikely(err))
+			goto err;
+
 		iip = ip_hdr(skb);
 		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, iip, skb);
-
 		ttl = geneve->ttl;
 		if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
 			ttl = 1;
-
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-
-		/* no need to handle local destination and encap bypass...yet... */
-		err = geneve_xmit_skb(gs, rt, skb, fl4.saddr, fl4.daddr, tos,
-				      ttl, 0, sport, geneve->dst_port, 0,
-				      geneve->vni, 0, NULL, false, xnet);
+		df = 0;
+		xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 	}
-	if (err < 0)
-		ip_rt_put(rt);
+
+	err = udp_tunnel_xmit_skb(rt, gs->sock->sk, skb, fl4.saddr, fl4.daddr,
+				  tos, ttl, df, sport, geneve->dst_port,
+				  xnet, !udp_csum);
 
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
 
 tx_error:
-	dev->stats.tx_errors++;
 	dev_kfree_skb(skb);
+err:
+	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
 
@@ -465,20 +792,14 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 			    __u16 dst_port, bool metadata)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
-	struct geneve_dev *dummy, *geneve = netdev_priv(dev);
-	struct hlist_head *vni_list_head;
-	struct sockaddr_in remote;	/* IPv4 address for link partner */
+	struct geneve_dev *t, *geneve = netdev_priv(dev);
+	struct geneve_sock *gs;
 	__u32 hash;
 	int err;
 
 	if (metadata) {
-		if (rtnl_dereference(gn->collect_md_tun))
-			return -EEXIST;
-		if (!list_empty(&gn->geneve_list))
-			return -EPERM;
-	} else {
-		if (rtnl_dereference(gn->collect_md_tun))
-			return -EPERM;
+		if (rem_addr || vni || tos || ttl)
+			return -EINVAL;
 	}
 
 	geneve->net = net;
@@ -492,36 +813,36 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
 		return -EINVAL;
 
-	remote = geneve->remote;
-	if (metadata) {
-		if (rem_addr || vni || tos || ttl)
-			return -EINVAL;
-	}
-
-	hash = geneve_net_vni_hash(geneve->vni);
-	vni_list_head = &gn->vni_list[hash];
-	hlist_for_each_entry_rcu(dummy, vni_list_head, hlist) {
-		if (!memcmp(geneve->vni, dummy->vni, sizeof(dummy->vni)) &&
-		    !memcmp(&remote, &dummy->remote, sizeof(dummy->remote)) &&
-		    htons(dst_port) == dummy->dst_port) {
-			return -EBUSY;
-		}
-	}
-
 	geneve->ttl = ttl;
 	geneve->tos = tos;
 	geneve->dst_port = htons(dst_port);
 	geneve->collect_md = metadata;
 
+	gs = geneve_find_sock(gn, geneve->dst_port);
+	if (gs) {
+		if (metadata) {
+			if (gs->collect_md)
+				return -EEXIST;
+			else
+				return -EPERM;
+		} else {
+			if (gs->collect_md)
+				return -EPERM;
+
+			t = geneve_lookup(gn, htons(dst_port),
+					  rem_addr, geneve->vni);
+			if (t)
+				return -EBUSY;
+		}
+	}
+
 	err = register_netdevice(dev);
 	if (err)
 		return err;
 
 	list_add(&geneve->next, &gn->geneve_list);
+	hash = geneve_net_vni_hash(geneve->vni);
 	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
-
-	if (geneve->collect_md)
-		rcu_assign_pointer(gn->collect_md_tun, geneve);
 	return 0;
 }
 
@@ -560,12 +881,6 @@ static void geneve_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 
-	if (geneve->collect_md) {
-		struct geneve_net *gn = net_generic(geneve->net, geneve_net_id);
-
-		rcu_assign_pointer(gn->collect_md_tun, NULL);
-	}
-
 	if (!hlist_unhashed(&geneve->hlist))
 		hlist_del_rcu(&geneve->hlist);
 
@@ -657,6 +972,7 @@ static __net_init int geneve_init_net(struct net *net)
 
 	INIT_LIST_HEAD(&gn->geneve_list);
 
+	INIT_LIST_HEAD(&gn->sock_list);
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&gn->vni_list[h]);
 
diff --git a/include/net/geneve.h b/include/net/geneve.h
index 4245e1d..3106ed6 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -62,41 +62,7 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
-static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
-{
-	return (struct genevehdr *)(udp_hdr(skb) + 1);
-}
-
 #ifdef CONFIG_INET
-struct geneve_sock;
-
-typedef void (geneve_rcv_t)(struct geneve_sock *gs, struct sk_buff *skb);
-
-struct geneve_sock {
-	struct list_head	list;
-	geneve_rcv_t		*rcv;
-	void			*rcv_data;
-	struct socket		*sock;
-	struct rcu_head		rcu;
-	int			refcnt;
-	struct udp_offload	udp_offloads;
-};
-
-#define GENEVE_VER 0
-#define GENEVE_BASE_HLEN (sizeof(struct udphdr) + sizeof(struct genevehdr))
-
-struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
-				    geneve_rcv_t *rcv, void *data,
-				    bool no_share, bool ipv6);
-
-void geneve_sock_release(struct geneve_sock *vs);
-
-int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
-		    struct sk_buff *skb, __be32 src, __be32 dst, __u8 tos,
-		    __u8 ttl, __be16 df, __be16 src_port, __be16 dst_port,
-		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
-		    bool csum, bool xnet);
-
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port);
 #endif /*ifdef CONFIG_INET */
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 6fb3c90..416dfa0 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -331,20 +331,6 @@ config NET_FOU_IP_TUNNELS
 	  When this option is enabled IP tunnels can be configured to use
 	  FOU or GUE encapsulation.
 
-config GENEVE_CORE
-	tristate "Generic Network Virtualization Encapsulation library"
-	depends on INET
-	select NET_UDP_TUNNEL
-	---help---
-	This allows one to create Geneve virtual interfaces that provide
-	Layer 2 Networks over Layer 3 Networks. Geneve is often used
-	to tunnel virtual network infrastructure in virtualized environments.
-	For more information see:
-	  http://tools.ietf.org/html/draft-gross-geneve-01
-
-	  To compile this driver as a module, choose M here: the module
-
-
 config INET_AH
 	tristate "IP: AH transformation"
 	select XFRM_ALGO
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index efc43f3..89aacb6 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -57,7 +57,6 @@ obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_MEMCG_KMEM) += tcp_memcontrol.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
-obj-$(CONFIG_GENEVE_CORE) += geneve_core.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o xfrm4_protocol.o
diff --git a/net/ipv4/geneve_core.c b/net/ipv4/geneve_core.c
deleted file mode 100644
index 311a4ba..0000000
--- a/net/ipv4/geneve_core.c
+++ /dev/null
@@ -1,447 +0,0 @@
-/*
- * Geneve: Generic Network Virtualization Encapsulation
- *
- * Copyright (c) 2014 Nicira, Inc.
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/module.h>
-#include <linux/errno.h>
-#include <linux/slab.h>
-#include <linux/skbuff.h>
-#include <linux/list.h>
-#include <linux/netdevice.h>
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <linux/udp.h>
-#include <linux/igmp.h>
-#include <linux/etherdevice.h>
-#include <linux/if_ether.h>
-#include <linux/if_vlan.h>
-#include <linux/ethtool.h>
-#include <linux/mutex.h>
-#include <net/arp.h>
-#include <net/ndisc.h>
-#include <net/ip.h>
-#include <net/ip_tunnels.h>
-#include <net/icmp.h>
-#include <net/udp.h>
-#include <net/rtnetlink.h>
-#include <net/route.h>
-#include <net/dsfield.h>
-#include <net/inet_ecn.h>
-#include <net/net_namespace.h>
-#include <net/netns/generic.h>
-#include <net/geneve.h>
-#include <net/protocol.h>
-#include <net/udp_tunnel.h>
-#if IS_ENABLED(CONFIG_IPV6)
-#include <net/ipv6.h>
-#include <net/addrconf.h>
-#include <net/ip6_tunnel.h>
-#include <net/ip6_checksum.h>
-#endif
-
-/* Protects sock_list and refcounts. */
-static DEFINE_MUTEX(geneve_mutex);
-
-/* per-network namespace private data for this module */
-struct geneve_net {
-	struct list_head	sock_list;
-};
-
-static int geneve_net_id;
-
-static struct geneve_sock *geneve_find_sock(struct net *net,
-					    sa_family_t family, __be16 port)
-{
-	struct geneve_net *gn = net_generic(net, geneve_net_id);
-	struct geneve_sock *gs;
-
-	list_for_each_entry(gs, &gn->sock_list, list) {
-		if (inet_sk(gs->sock->sk)->inet_sport == port &&
-		    inet_sk(gs->sock->sk)->sk.sk_family == family)
-			return gs;
-	}
-
-	return NULL;
-}
-
-static void geneve_build_header(struct genevehdr *geneveh,
-				__be16 tun_flags, u8 vni[3],
-				u8 options_len, u8 *options)
-{
-	geneveh->ver = GENEVE_VER;
-	geneveh->opt_len = options_len / 4;
-	geneveh->oam = !!(tun_flags & TUNNEL_OAM);
-	geneveh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
-	geneveh->rsvd1 = 0;
-	memcpy(geneveh->vni, vni, 3);
-	geneveh->proto_type = htons(ETH_P_TEB);
-	geneveh->rsvd2 = 0;
-
-	memcpy(geneveh->options, options, options_len);
-}
-
-/* Transmit a fully formatted Geneve frame.
- *
- * When calling this function. The skb->data should point
- * to the geneve header which is fully formed.
- *
- * This function will add other UDP tunnel headers.
- */
-int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
-		    struct sk_buff *skb, __be32 src, __be32 dst, __u8 tos,
-		    __u8 ttl, __be16 df, __be16 src_port, __be16 dst_port,
-		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
-		    bool csum, bool xnet)
-{
-	struct genevehdr *gnvh;
-	int min_headroom;
-	int err;
-
-	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr)
-			+ (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
-
-	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err)) {
-		kfree_skb(skb);
-		return err;
-	}
-
-	skb = vlan_hwaccel_push_inside(skb);
-	if (unlikely(!skb))
-		return -ENOMEM;
-
-	skb = udp_tunnel_handle_offloads(skb, csum);
-	if (IS_ERR(skb))
-		return PTR_ERR(skb);
-
-	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
-	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
-
-	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
-
-	return udp_tunnel_xmit_skb(rt, gs->sock->sk, skb, src, dst,
-				   tos, ttl, df, src_port, dst_port, xnet,
-				   !csum);
-}
-EXPORT_SYMBOL_GPL(geneve_xmit_skb);
-
-static int geneve_hlen(struct genevehdr *gh)
-{
-	return sizeof(*gh) + gh->opt_len * 4;
-}
-
-static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
-					   struct sk_buff *skb,
-					   struct udp_offload *uoff)
-{
-	struct sk_buff *p, **pp = NULL;
-	struct genevehdr *gh, *gh2;
-	unsigned int hlen, gh_len, off_gnv;
-	const struct packet_offload *ptype;
-	__be16 type;
-	int flush = 1;
-
-	off_gnv = skb_gro_offset(skb);
-	hlen = off_gnv + sizeof(*gh);
-	gh = skb_gro_header_fast(skb, off_gnv);
-	if (skb_gro_header_hard(skb, hlen)) {
-		gh = skb_gro_header_slow(skb, hlen, off_gnv);
-		if (unlikely(!gh))
-			goto out;
-	}
-
-	if (gh->ver != GENEVE_VER || gh->oam)
-		goto out;
-	gh_len = geneve_hlen(gh);
-
-	hlen = off_gnv + gh_len;
-	if (skb_gro_header_hard(skb, hlen)) {
-		gh = skb_gro_header_slow(skb, hlen, off_gnv);
-		if (unlikely(!gh))
-			goto out;
-	}
-
-	flush = 0;
-
-	for (p = *head; p; p = p->next) {
-		if (!NAPI_GRO_CB(p)->same_flow)
-			continue;
-
-		gh2 = (struct genevehdr *)(p->data + off_gnv);
-		if (gh->opt_len != gh2->opt_len ||
-		    memcmp(gh, gh2, gh_len)) {
-			NAPI_GRO_CB(p)->same_flow = 0;
-			continue;
-		}
-	}
-
-	type = gh->proto_type;
-
-	rcu_read_lock();
-	ptype = gro_find_receive_by_type(type);
-	if (!ptype) {
-		flush = 1;
-		goto out_unlock;
-	}
-
-	skb_gro_pull(skb, gh_len);
-	skb_gro_postpull_rcsum(skb, gh, gh_len);
-	pp = ptype->callbacks.gro_receive(head, skb);
-
-out_unlock:
-	rcu_read_unlock();
-out:
-	NAPI_GRO_CB(skb)->flush |= flush;
-
-	return pp;
-}
-
-static int geneve_gro_complete(struct sk_buff *skb, int nhoff,
-			       struct udp_offload *uoff)
-{
-	struct genevehdr *gh;
-	struct packet_offload *ptype;
-	__be16 type;
-	int gh_len;
-	int err = -ENOSYS;
-
-	udp_tunnel_gro_complete(skb, nhoff);
-
-	gh = (struct genevehdr *)(skb->data + nhoff);
-	gh_len = geneve_hlen(gh);
-	type = gh->proto_type;
-
-	rcu_read_lock();
-	ptype = gro_find_complete_by_type(type);
-	if (ptype)
-		err = ptype->callbacks.gro_complete(skb, nhoff + gh_len);
-
-	rcu_read_unlock();
-	return err;
-}
-
-static void geneve_notify_add_rx_port(struct geneve_sock *gs)
-{
-	struct sock *sk = gs->sock->sk;
-	sa_family_t sa_family = sk->sk_family;
-	int err;
-
-	if (sa_family == AF_INET) {
-		err = udp_add_offload(&gs->udp_offloads);
-		if (err)
-			pr_warn("geneve: udp_add_offload failed with status %d\n",
-				err);
-	}
-}
-
-static void geneve_notify_del_rx_port(struct geneve_sock *gs)
-{
-	struct sock *sk = gs->sock->sk;
-	sa_family_t sa_family = sk->sk_family;
-
-	if (sa_family == AF_INET)
-		udp_del_offload(&gs->udp_offloads);
-}
-
-/* Callback from net/ipv4/udp.c to receive packets */
-static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
-{
-	struct genevehdr *geneveh;
-	struct geneve_sock *gs;
-	int opts_len;
-
-	/* Need Geneve and inner Ethernet header to be present */
-	if (unlikely(!pskb_may_pull(skb, GENEVE_BASE_HLEN)))
-		goto error;
-
-	/* Return packets with reserved bits set */
-	geneveh = geneve_hdr(skb);
-
-	if (unlikely(geneveh->ver != GENEVE_VER))
-		goto error;
-
-	if (unlikely(geneveh->proto_type != htons(ETH_P_TEB)))
-		goto error;
-
-	opts_len = geneveh->opt_len * 4;
-	if (iptunnel_pull_header(skb, GENEVE_BASE_HLEN + opts_len,
-				 htons(ETH_P_TEB)))
-		goto drop;
-
-	gs = rcu_dereference_sk_user_data(sk);
-	if (!gs)
-		goto drop;
-
-	gs->rcv(gs, skb);
-	return 0;
-
-drop:
-	/* Consume bad packet */
-	kfree_skb(skb);
-	return 0;
-
-error:
-	/* Let the UDP layer deal with the skb */
-	return 1;
-}
-
-static struct socket *geneve_create_sock(struct net *net, bool ipv6,
-					 __be16 port)
-{
-	struct socket *sock;
-	struct udp_port_cfg udp_conf;
-	int err;
-
-	memset(&udp_conf, 0, sizeof(udp_conf));
-
-	if (ipv6) {
-		udp_conf.family = AF_INET6;
-	} else {
-		udp_conf.family = AF_INET;
-		udp_conf.local_ip.s_addr = htonl(INADDR_ANY);
-	}
-
-	udp_conf.local_udp_port = port;
-
-	/* Open UDP socket */
-	err = udp_sock_create(net, &udp_conf, &sock);
-	if (err < 0)
-		return ERR_PTR(err);
-
-	return sock;
-}
-
-/* Create new listen socket if needed */
-static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
-						geneve_rcv_t *rcv, void *data,
-						bool ipv6)
-{
-	struct geneve_net *gn = net_generic(net, geneve_net_id);
-	struct geneve_sock *gs;
-	struct socket *sock;
-	struct udp_tunnel_sock_cfg tunnel_cfg;
-
-	gs = kzalloc(sizeof(*gs), GFP_KERNEL);
-	if (!gs)
-		return ERR_PTR(-ENOMEM);
-
-	sock = geneve_create_sock(net, ipv6, port);
-	if (IS_ERR(sock)) {
-		kfree(gs);
-		return ERR_CAST(sock);
-	}
-
-	gs->sock = sock;
-	gs->refcnt = 1;
-	gs->rcv = rcv;
-	gs->rcv_data = data;
-
-	/* Initialize the geneve udp offloads structure */
-	gs->udp_offloads.port = port;
-	gs->udp_offloads.callbacks.gro_receive  = geneve_gro_receive;
-	gs->udp_offloads.callbacks.gro_complete = geneve_gro_complete;
-	geneve_notify_add_rx_port(gs);
-
-	/* Mark socket as an encapsulation socket */
-	tunnel_cfg.sk_user_data = gs;
-	tunnel_cfg.encap_type = 1;
-	tunnel_cfg.encap_rcv = geneve_udp_encap_recv;
-	tunnel_cfg.encap_destroy = NULL;
-	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
-
-	list_add(&gs->list, &gn->sock_list);
-
-	return gs;
-}
-
-struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
-				    geneve_rcv_t *rcv, void *data,
-				    bool no_share, bool ipv6)
-{
-	struct geneve_sock *gs;
-
-	mutex_lock(&geneve_mutex);
-
-	gs = geneve_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
-	if (gs) {
-		if (!no_share && gs->rcv == rcv)
-			gs->refcnt++;
-		else
-			gs = ERR_PTR(-EBUSY);
-	} else {
-		gs = geneve_socket_create(net, port, rcv, data, ipv6);
-	}
-
-	mutex_unlock(&geneve_mutex);
-
-	return gs;
-}
-EXPORT_SYMBOL_GPL(geneve_sock_add);
-
-void geneve_sock_release(struct geneve_sock *gs)
-{
-	mutex_lock(&geneve_mutex);
-
-	if (--gs->refcnt)
-		goto unlock;
-
-	list_del(&gs->list);
-	geneve_notify_del_rx_port(gs);
-	udp_tunnel_sock_release(gs->sock);
-	kfree_rcu(gs, rcu);
-
-unlock:
-	mutex_unlock(&geneve_mutex);
-}
-EXPORT_SYMBOL_GPL(geneve_sock_release);
-
-static __net_init int geneve_init_net(struct net *net)
-{
-	struct geneve_net *gn = net_generic(net, geneve_net_id);
-
-	INIT_LIST_HEAD(&gn->sock_list);
-
-	return 0;
-}
-
-static struct pernet_operations geneve_net_ops = {
-	.init = geneve_init_net,
-	.id   = &geneve_net_id,
-	.size = sizeof(struct geneve_net),
-};
-
-static int __init geneve_init_module(void)
-{
-	int rc;
-
-	rc = register_pernet_subsys(&geneve_net_ops);
-	if (rc)
-		return rc;
-
-	pr_info("Geneve core logic\n");
-
-	return 0;
-}
-module_init(geneve_init_module);
-
-static void __exit geneve_cleanup_module(void)
-{
-	unregister_pernet_subsys(&geneve_net_ops);
-}
-module_exit(geneve_cleanup_module);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
-MODULE_DESCRIPTION("Driver library for GENEVE encapsulated traffic");
-- 
1.7.1
