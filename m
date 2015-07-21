From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 22/22] openvswitch: Use regular VXLAN net_device device
Date: Tue, 21 Jul 2015 10:44:06 +0200
Message-ID: <221945c7236c471669a11e89cb175406f5551818.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40241 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbbGUIoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 04:44:38 -0400
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gets rid of all OVS specific VXLAN code in the receive and
transmit path by using a VXLAN net_device to represent the vport.
Only a small shim layer remains which takes care of handling the
VXLAN specific OVS Netlink configuration.

Unexports vxlan_sock_add(), vxlan_sock_release(), vxlan_xmit_skb()
since they are no longer needed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c            | 242 +++++++++++++++----------------
 include/net/rtnetlink.h        |   1 +
 include/net/vxlan.h            |  24 +--
 net/core/rtnetlink.c           |  26 ++--
 net/openvswitch/Kconfig        |  12 --
 net/openvswitch/Makefile       |   1 -
 net/openvswitch/flow_netlink.c |   6 +-
 net/openvswitch/vport-netdev.c | 201 ++++++++++++++++++++++++-
 net/openvswitch/vport-vxlan.c  | 322 -----------------------------------------
 net/openvswitch/vport-vxlan.h  |  11 --
 10 files changed, 339 insertions(+), 507 deletions(-)
 delete mode 100644 net/openvswitch/vport-vxlan.c
 delete mode 100644 net/openvswitch/vport-vxlan.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 30e1f21..e9feefb 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -75,6 +75,9 @@ static struct rtnl_link_ops vxlan_link_ops;
 
 static const u8 all_zeros_mac[ETH_ALEN];
 
+static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+					 bool no_share, u32 flags);
+
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
@@ -1027,7 +1030,7 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 	return false;
 }
 
-void vxlan_sock_release(struct vxlan_sock *vs)
+static void vxlan_sock_release(struct vxlan_sock *vs)
 {
 	struct sock *sk = vs->sock->sk;
 	struct net *net = sock_net(sk);
@@ -1043,7 +1046,6 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 
 	queue_work(vxlan_wq, &vs->del_work);
 }
-EXPORT_SYMBOL_GPL(vxlan_sock_release);
 
 /* Update multicast group membership when first VNI on
  * multicast address is brought up
@@ -1126,6 +1128,102 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 	return vh;
 }
 
+static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
+		      struct vxlan_metadata *md, u32 vni,
+		      struct metadata_dst *tun_dst)
+{
+	struct iphdr *oip = NULL;
+	struct ipv6hdr *oip6 = NULL;
+	struct vxlan_dev *vxlan;
+	struct pcpu_sw_netstats *stats;
+	union vxlan_addr saddr;
+	int err = 0;
+	union vxlan_addr *remote_ip;
+
+	/* For flow based devices, map all packets to VNI 0 */
+	if (vs->flags & VXLAN_F_FLOW_BASED)
+		vni = 0;
+
+	/* Is this VNI defined? */
+	vxlan = vxlan_vs_find_vni(vs, vni);
+	if (!vxlan)
+		goto drop;
+
+	remote_ip = &vxlan->default_dst.remote_ip;
+	skb_reset_mac_header(skb);
+	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
+	skb->protocol = eth_type_trans(skb, vxlan->dev);
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+
+	/* Ignore packet loops (and multicast echo) */
+	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
+		goto drop;
+
+	/* Re-examine inner Ethernet packet */
+	if (remote_ip->sa.sa_family == AF_INET) {
+		oip = ip_hdr(skb);
+		saddr.sin.sin_addr.s_addr = oip->saddr;
+		saddr.sa.sa_family = AF_INET;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else {
+		oip6 = ipv6_hdr(skb);
+		saddr.sin6.sin6_addr = oip6->saddr;
+		saddr.sa.sa_family = AF_INET6;
+#endif
+	}
+
+	if (tun_dst) {
+		skb_dst_set(skb, (struct dst_entry *)tun_dst);
+		tun_dst = NULL;
+	}
+
+	if ((vxlan->flags & VXLAN_F_LEARN) &&
+	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
+		goto drop;
+
+	skb_reset_network_header(skb);
+	/* In flow-based mode, GBP is carried in dst_metadata */
+	if (!(vs->flags & VXLAN_F_FLOW_BASED))
+		skb->mark = md->gbp;
+
+	if (oip6)
+		err = IP6_ECN_decapsulate(oip6, skb);
+	if (oip)
+		err = IP_ECN_decapsulate(oip, skb);
+
+	if (unlikely(err)) {
+		if (log_ecn_error) {
+			if (oip6)
+				net_info_ratelimited("non-ECT from %pI6\n",
+						     &oip6->saddr);
+			if (oip)
+				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+						     &oip->saddr, oip->tos);
+		}
+		if (err > 1) {
+			++vxlan->dev->stats.rx_frame_errors;
+			++vxlan->dev->stats.rx_errors;
+			goto drop;
+		}
+	}
+
+	stats = this_cpu_ptr(vxlan->dev->tstats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
+
+	netif_rx(skb);
+
+	return;
+drop:
+	if (tun_dst)
+		dst_release((struct dst_entry *)tun_dst);
+
+	/* Consume bad packet */
+	kfree_skb(skb);
+}
+
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
@@ -1192,7 +1290,6 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			info->key.tun_flags |= TUNNEL_CSUM;
 
 		md = ip_tunnel_info_opts(info, sizeof(*md));
-		md->tun_dst = tun_dst;
 	} else {
 		memset(md, 0, sizeof(*md));
 	}
@@ -1231,8 +1328,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto bad_flags;
 	}
 
-	md->vni = vxh->vx_vni;
-	vs->rcv(vs, skb, md);
+	vxlan_rcv(vs, skb, md, vni >> 8, tun_dst);
 	return 0;
 
 drop:
@@ -1252,104 +1348,6 @@ error:
 	return 1;
 }
 
-static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
-		      struct vxlan_metadata *md)
-{
-	struct iphdr *oip = NULL;
-	struct ipv6hdr *oip6 = NULL;
-	struct vxlan_dev *vxlan;
-	struct pcpu_sw_netstats *stats;
-	union vxlan_addr saddr;
-	__u32 vni;
-	int err = 0;
-	union vxlan_addr *remote_ip;
-
-	/* For flow based devices, map all packets to VNI 0 */
-	if (vs->flags & VXLAN_F_FLOW_BASED)
-		vni = 0;
-	else
-		vni = ntohl(md->vni) >> 8;
-
-	/* Is this VNI defined? */
-	vxlan = vxlan_vs_find_vni(vs, vni);
-	if (!vxlan)
-		goto drop;
-
-	remote_ip = &vxlan->default_dst.remote_ip;
-	skb_reset_mac_header(skb);
-	skb_scrub_packet(skb, !net_eq(vxlan->net, dev_net(vxlan->dev)));
-	skb->protocol = eth_type_trans(skb, vxlan->dev);
-	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
-
-	/* Ignore packet loops (and multicast echo) */
-	if (ether_addr_equal(eth_hdr(skb)->h_source, vxlan->dev->dev_addr))
-		goto drop;
-
-	/* Re-examine inner Ethernet packet */
-	if (remote_ip->sa.sa_family == AF_INET) {
-		oip = ip_hdr(skb);
-		saddr.sin.sin_addr.s_addr = oip->saddr;
-		saddr.sa.sa_family = AF_INET;
-#if IS_ENABLED(CONFIG_IPV6)
-	} else {
-		oip6 = ipv6_hdr(skb);
-		saddr.sin6.sin6_addr = oip6->saddr;
-		saddr.sa.sa_family = AF_INET6;
-#endif
-	}
-
-	if (md->tun_dst) {
-		skb_dst_set(skb, (struct dst_entry *)md->tun_dst);
-		md->tun_dst = NULL;
-	}
-
-	if ((vxlan->flags & VXLAN_F_LEARN) &&
-	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
-		goto drop;
-
-	skb_reset_network_header(skb);
-	/* In flow-based mode, GBP is carried in dst_metadata */
-	if (!(vs->flags & VXLAN_F_FLOW_BASED))
-		skb->mark = md->gbp;
-
-	if (oip6)
-		err = IP6_ECN_decapsulate(oip6, skb);
-	if (oip)
-		err = IP_ECN_decapsulate(oip, skb);
-
-	if (unlikely(err)) {
-		if (log_ecn_error) {
-			if (oip6)
-				net_info_ratelimited("non-ECT from %pI6\n",
-						     &oip6->saddr);
-			if (oip)
-				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-						     &oip->saddr, oip->tos);
-		}
-		if (err > 1) {
-			++vxlan->dev->stats.rx_frame_errors;
-			++vxlan->dev->stats.rx_errors;
-			goto drop;
-		}
-	}
-
-	stats = this_cpu_ptr(vxlan->dev->tstats);
-	u64_stats_update_begin(&stats->syncp);
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-	u64_stats_update_end(&stats->syncp);
-
-	netif_rx(skb);
-
-	return;
-drop:
-	if (md->tun_dst)
-		dst_release((struct dst_entry *)md->tun_dst);
-
-	/* Consume bad packet */
-	kfree_skb(skb);
-}
-
 static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
@@ -1688,7 +1686,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 			   struct sk_buff *skb,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
-			   __be16 src_port, __be16 dst_port,
+			   __be16 src_port, __be16 dst_port, __u32 vni,
 			   struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
@@ -1738,7 +1736,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
-	vxh->vx_vni = md->vni;
+	vxh->vx_vni = vni;
 
 	if (type & SKB_GSO_TUNNEL_REMCSUM) {
 		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
@@ -1771,10 +1769,10 @@ err:
 }
 #endif
 
-int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port,
-		   struct vxlan_metadata *md, bool xnet, u32 vxflags)
+static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
+			  __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
+			  __be16 src_port, __be16 dst_port, __u32 vni,
+			  struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
 	int min_headroom;
@@ -1817,7 +1815,7 @@ int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = htonl(VXLAN_HF_VNI);
-	vxh->vx_vni = md->vni;
+	vxh->vx_vni = vni;
 
 	if (type & SKB_GSO_TUNNEL_REMCSUM) {
 		u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
@@ -1844,7 +1842,6 @@ int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 				   ttl, df, src_port, dst_port, xnet,
 				   !(vxflags & VXLAN_F_UDP_CSUM));
 }
-EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
 /* Bypass encapsulation if the destination is local */
 static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
@@ -2012,10 +2009,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		md->vni = htonl(vni << 8);
 		err = vxlan_xmit_skb(rt, sk, skb, fl4.saddr,
 				     dst->sin.sin_addr.s_addr, tos, ttl, df,
-				     src_port, dst_port, md,
+				     src_port, dst_port, htonl(vni << 8), md,
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
 				     flags);
 		if (err < 0) {
@@ -2070,11 +2066,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-		md->vni = htonl(vni << 8);
 		md->gbp = skb->mark;
 
 		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &fl6.saddr, &fl6.daddr,
-				      0, ttl, src_port, dst_port, md,
+				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
 				      vxlan->flags);
 #endif
@@ -2269,8 +2264,8 @@ static int vxlan_open(struct net_device *dev)
 	struct vxlan_sock *vs;
 	int ret = 0;
 
-	vs = vxlan_sock_add(vxlan->net, vxlan->cfg.dst_port, vxlan_rcv,
-			    NULL, vxlan->cfg.no_share, vxlan->flags);
+	vs = vxlan_sock_add(vxlan->net, vxlan->cfg.dst_port,
+			    vxlan->cfg.no_share, vxlan->flags);
 	if (IS_ERR(vs))
 		return PTR_ERR(vs);
 
@@ -2563,7 +2558,6 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 
 /* Create new listen socket if needed */
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv, void *data,
 					      u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
@@ -2592,8 +2586,6 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	vs->sock = sock;
 	atomic_set(&vs->refcnt, 1);
-	vs->rcv = rcv;
-	vs->data = data;
 	vs->flags = (flags & VXLAN_F_RCV_FLAGS);
 
 	/* Initialize the vxlan udp offloads structure */
@@ -2617,9 +2609,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	return vs;
 }
 
-struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, u32 flags)
+static struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
+					 bool no_share, u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
@@ -2629,7 +2620,7 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 		spin_lock(&vn->sock_lock);
 		vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port,
 				     flags);
-		if (vs && vs->rcv == rcv) {
+		if (vs) {
 			if (!atomic_add_unless(&vs->refcnt, 1, 0))
 				vs = ERR_PTR(-EBUSY);
 			spin_unlock(&vn->sock_lock);
@@ -2638,9 +2629,8 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 		spin_unlock(&vn->sock_lock);
 	}
 
-	return vxlan_socket_create(net, port, rcv, data, flags);
+	return vxlan_socket_create(net, port, flags);
 }
-EXPORT_SYMBOL_GPL(vxlan_sock_add);
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 			       struct vxlan_config *conf)
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 343d922..18fdb98 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -141,6 +141,7 @@ struct net_device *rtnl_create_link(struct net *net, const char *ifname,
 				    unsigned char name_assign_type,
 				    const struct rtnl_link_ops *ops,
 				    struct nlattr *tb[]);
+int rtnl_delete_link(struct net_device *dev);
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm);
 
 int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 19535f8..eb8d721 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -101,22 +101,12 @@ struct vxlanhdr {
 #define FDB_HASH_SIZE	(1<<FDB_HASH_BITS)
 
 struct vxlan_metadata {
-	__be32		vni;
 	u32		gbp;
-
-	/* Temporary until vxlan_rcv() API is gone */
-	struct metadata_dst *tun_dst;
 };
 
-struct vxlan_sock;
-typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb,
-			   struct vxlan_metadata *md);
-
 /* per UDP socket information */
 struct vxlan_sock {
 	struct hlist_node hlist;
-	vxlan_rcv_t	 *rcv;
-	void		 *data;
 	struct work_struct del_work;
 	struct socket	 *sock;
 	struct rcu_head	  rcu;
@@ -203,19 +193,13 @@ struct vxlan_dev {
 					 VXLAN_F_COLLECT_METADATA |	\
 					 VXLAN_F_FLOW_BASED)
 
-struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, u32 flags);
-
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
 
-void vxlan_sock_release(struct vxlan_sock *vs);
-
-int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-		   __be16 src_port, __be16 dst_port, struct vxlan_metadata *md,
-		   bool xnet, u32 vxflags);
+static inline __be16 vxlan_dev_dst_port(struct vxlan_dev *vxlan)
+{
+	return inet_sk(vxlan->vn_sock->sock->sk)->inet_sport;
+}
 
 static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 						     netdev_features_t features)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 03d61b5..5fb4af2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1960,16 +1960,30 @@ static int rtnl_group_dellink(const struct net *net, int group)
 	return 0;
 }
 
+int rtnl_delete_link(struct net_device *dev)
+{
+	const struct rtnl_link_ops *ops;
+	LIST_HEAD(list_kill);
+
+	ops = dev->rtnl_link_ops;
+	if (!ops || !ops->dellink)
+		return -EOPNOTSUPP;
+
+	ops->dellink(dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rtnl_delete_link);
+
 static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-	const struct rtnl_link_ops *ops;
 	struct net_device *dev;
 	struct ifinfomsg *ifm;
 	char ifname[IFNAMSIZ];
 	struct nlattr *tb[IFLA_MAX+1];
 	int err;
-	LIST_HEAD(list_kill);
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
@@ -1991,13 +2005,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!dev)
 		return -ENODEV;
 
-	ops = dev->rtnl_link_ops;
-	if (!ops || !ops->dellink)
-		return -EOPNOTSUPP;
-
-	ops->dellink(dev, &list_kill);
-	unregister_netdevice_many(&list_kill);
-	return 0;
+	return rtnl_delete_link(dev);
 }
 
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 1584040..1119f46 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -44,18 +44,6 @@ config OPENVSWITCH_GRE
 
 	  If unsure, say Y.
 
-config OPENVSWITCH_VXLAN
-	tristate "Open vSwitch VXLAN tunneling support"
-	depends on OPENVSWITCH
-	depends on VXLAN
-	default OPENVSWITCH
-	---help---
-	  If you say Y here, then the Open vSwitch will be able create vxlan vport.
-
-	  Say N to exclude this support and reduce the binary size.
-
-	  If unsure, say Y.
-
 config OPENVSWITCH_GENEVE
 	tristate "Open vSwitch Geneve tunneling support"
 	depends on OPENVSWITCH
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 91b9478..38e0e14 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -16,5 +16,4 @@ openvswitch-y := \
 	vport-netdev.o
 
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
-obj-$(CONFIG_OPENVSWITCH_VXLAN)	+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index e7906df..a6eb77a 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -47,9 +47,9 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 #include <net/mpls.h>
+#include <net/vxlan.h>
 
 #include "flow_netlink.h"
-#include "vport-vxlan.h"
 
 struct ovs_len_tbl {
 	int len;
@@ -475,7 +475,7 @@ static int vxlan_tun_opt_from_nlattr(const struct nlattr *a,
 {
 	struct nlattr *tb[OVS_VXLAN_EXT_MAX+1];
 	unsigned long opt_key_offset;
-	struct ovs_vxlan_opts opts;
+	struct vxlan_metadata opts;
 	int err;
 
 	BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
@@ -626,7 +626,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 static int vxlan_opt_to_nlattr(struct sk_buff *skb,
 			       const void *tun_opts, int swkey_tun_opts_len)
 {
-	const struct ovs_vxlan_opts *opts = tun_opts;
+	const struct vxlan_metadata *opts = tun_opts;
 	struct nlattr *nla;
 
 	nla = nla_nest_start(skb, OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS);
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index e682bdc..68d0582 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -27,9 +27,13 @@
 #include <linux/skbuff.h>
 #include <linux/openvswitch.h>
 
-#include <net/llc.h>
+#include <net/udp.h>
+#include <net/ip_tunnels.h>
+#include <net/rtnetlink.h>
+#include <net/vxlan.h>
 
 #include "datapath.h"
+#include "vport.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
@@ -147,7 +151,8 @@ static void free_port_rcu(struct rcu_head *rcu)
 {
 	struct vport *vport = container_of(rcu, struct vport, rcu);
 
-	dev_put(vport->dev);
+	if (vport->dev)
+		dev_put(vport->dev);
 	ovs_vport_free(vport);
 }
 
@@ -221,12 +226,202 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.send		= netdev_send,
 };
 
+/* Compat code for old userspace. */
+#if IS_ENABLED(CONFIG_VXLAN)
+static struct vport_ops ovs_vxlan_netdev_vport_ops;
+
+static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
+{
+	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
+	__be16 dst_port = vxlan->cfg.dst_port;
+
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
+		return -EMSGSIZE;
+
+	if (vxlan->flags & VXLAN_F_GBP) {
+		struct nlattr *exts;
+
+		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
+		if (!exts)
+			return -EMSGSIZE;
+
+		if (vxlan->flags & VXLAN_F_GBP &&
+		    nla_put_flag(skb, OVS_VXLAN_EXT_GBP))
+			return -EMSGSIZE;
+
+		nla_nest_end(skb, exts);
+	}
+
+	return 0;
+}
+
+static const struct nla_policy exts_policy[OVS_VXLAN_EXT_MAX + 1] = {
+	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
+};
+
+static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr,
+				struct vxlan_config *conf)
+{
+	struct nlattr *exts[OVS_VXLAN_EXT_MAX + 1];
+	int err;
+
+	if (nla_len(attr) < sizeof(struct nlattr))
+		return -EINVAL;
+
+	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy);
+	if (err < 0)
+		return err;
+
+	if (exts[OVS_VXLAN_EXT_GBP])
+		conf->flags |= VXLAN_F_GBP;
+
+	return 0;
+}
+
+static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct nlattr *options = parms->options;
+	struct net_device *dev;
+	struct vport *vport;
+	struct nlattr *a;
+	int err;
+	struct vxlan_config conf = {
+		.no_share = true,
+		.flags = VXLAN_F_FLOW_BASED | VXLAN_F_COLLECT_METADATA,
+	};
+
+	if (!options) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
+	if (a && nla_len(a) == sizeof(u16)) {
+		conf.dst_port = htons(nla_get_u16(a));
+	} else {
+		/* Require destination port from userspace. */
+		err = -EINVAL;
+		goto error;
+	}
+
+	vport = ovs_vport_alloc(0, &ovs_vxlan_netdev_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_EXTENSION);
+	if (a) {
+		err = vxlan_configure_exts(vport, a, &conf);
+		if (err) {
+			ovs_vport_free(vport);
+			goto error;
+		}
+	}
+
+	rtnl_lock();
+	dev = vxlan_dev_create(net, parms->name, NET_NAME_USER, &conf);
+	if (IS_ERR(dev)) {
+		rtnl_unlock();
+		ovs_vport_free(vport);
+		return ERR_CAST(dev);
+	}
+
+	dev_change_flags(dev, dev->flags | IFF_UP);
+	rtnl_unlock();
+	return vport;
+error:
+	return ERR_PTR(err);
+}
+
+static struct vport *vxlan_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+
+	vport = vxlan_tnl_create(parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	return netdev_link(vport, parms->name);
+}
+
+static void vxlan_destroy(struct vport *vport)
+{
+	rtnl_lock();
+	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
+		ovs_netdev_detach_dev(vport);
+
+	/* Early release so we can unregister the device */
+	dev_put(vport->dev);
+	rtnl_delete_link(vport->dev);
+	vport->dev = NULL;
+	rtnl_unlock();
+
+	call_rcu(&vport->rcu, free_port_rcu);
+}
+
+static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				     struct ip_tunnel_info *egress_tun_info)
+{
+	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
+	struct net *net = ovs_dp_get_net(vport->dp);
+	__be16 dst_port = vxlan_dev_dst_port(vxlan);
+	__be16 src_port;
+	int port_min;
+	int port_max;
+
+	inet_get_local_port_range(net, &port_min, &port_max);
+	src_port = udp_flow_src_port(net, skb, 0, 0, true);
+
+	return ovs_tunnel_get_egress_info(egress_tun_info, net,
+					  OVS_CB(skb)->egress_tun_info,
+					  IPPROTO_UDP, skb->mark,
+					  src_port, dst_port);
+}
+
+static struct vport_ops ovs_vxlan_netdev_vport_ops = {
+	.type		= OVS_VPORT_TYPE_VXLAN,
+	.create		= vxlan_create,
+	.destroy	= vxlan_destroy,
+	.get_options	= vxlan_get_options,
+	.send		= netdev_send,
+	.get_egress_tun_info	= vxlan_get_egress_tun_info,
+};
+
+static int vxlan_compat_init(void)
+{
+	return ovs_vport_ops_register(&ovs_vxlan_netdev_vport_ops);
+}
+
+static void vxlan_compat_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_vxlan_netdev_vport_ops);
+}
+#else
+static int vxlan_compat_init(void)
+{
+	return 0;
+}
+
+static void vxlan_compat_exit(void)
+{
+}
+#endif
+
 int __init ovs_netdev_init(void)
 {
-	return ovs_vport_ops_register(&ovs_netdev_vport_ops);
+	int err;
+
+	err = ovs_vport_ops_register(&ovs_netdev_vport_ops);
+	if (err)
+		return err;
+	err = vxlan_compat_init();
+	if (err)
+		vxlan_compat_exit();
+	return err;
 }
 
 void ovs_netdev_exit(void)
 {
 	ovs_vport_ops_unregister(&ovs_netdev_vport_ops);
+	vxlan_compat_exit();
 }
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
deleted file mode 100644
index 6f7986f..0000000
--- a/net/openvswitch/vport-vxlan.c
+++ /dev/null
@@ -1,322 +0,0 @@
-/*
- * Copyright (c) 2014 Nicira, Inc.
- * Copyright (c) 2013 Cisco Systems, Inc.
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <linux/net.h>
-#include <linux/rculist.h>
-#include <linux/udp.h>
-#include <linux/module.h>
-
-#include <net/icmp.h>
-#include <net/ip.h>
-#include <net/udp.h>
-#include <net/ip_tunnels.h>
-#include <net/rtnetlink.h>
-#include <net/route.h>
-#include <net/dsfield.h>
-#include <net/inet_ecn.h>
-#include <net/net_namespace.h>
-#include <net/netns/generic.h>
-#include <net/vxlan.h>
-
-#include "datapath.h"
-#include "vport.h"
-#include "vport-vxlan.h"
-
-/**
- * struct vxlan_port - Keeps track of open UDP ports
- * @vs: vxlan_sock created for the port.
- * @name: vport name.
- */
-struct vxlan_port {
-	struct vxlan_sock *vs;
-	char name[IFNAMSIZ];
-	u32 exts; /* VXLAN_F_* in <net/vxlan.h> */
-};
-
-static struct vport_ops ovs_vxlan_vport_ops;
-
-static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
-{
-	return vport_priv(vport);
-}
-
-/* Called with rcu_read_lock and BH disabled. */
-static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
-		      struct vxlan_metadata *md)
-{
-	struct ip_tunnel_info tun_info;
-	struct vxlan_port *vxlan_port;
-	struct vport *vport = vs->data;
-	struct iphdr *iph;
-	struct ovs_vxlan_opts opts = {
-		.gbp = md->gbp,
-	};
-	__be64 key;
-	__be16 flags;
-
-	flags = TUNNEL_KEY | (udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0);
-	vxlan_port = vxlan_vport(vport);
-	if (vxlan_port->exts & VXLAN_F_GBP && md->gbp)
-		flags |= TUNNEL_VXLAN_OPT;
-
-	/* Save outer tunnel values */
-	iph = ip_hdr(skb);
-	key = cpu_to_be64(ntohl(md->vni) >> 8);
-	ip_tunnel_info_init(&tun_info, iph,
-			    udp_hdr(skb)->source, udp_hdr(skb)->dest,
-			    key, flags, &opts, sizeof(opts));
-
-	ovs_vport_receive(vport, skb, &tun_info);
-}
-
-static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
-{
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
-
-	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
-		return -EMSGSIZE;
-
-	if (vxlan_port->exts) {
-		struct nlattr *exts;
-
-		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
-		if (!exts)
-			return -EMSGSIZE;
-
-		if (vxlan_port->exts & VXLAN_F_GBP &&
-		    nla_put_flag(skb, OVS_VXLAN_EXT_GBP))
-			return -EMSGSIZE;
-
-		nla_nest_end(skb, exts);
-	}
-
-	return 0;
-}
-
-static void vxlan_tnl_destroy(struct vport *vport)
-{
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-
-	vxlan_sock_release(vxlan_port->vs);
-
-	ovs_vport_deferred_free(vport);
-}
-
-static const struct nla_policy exts_policy[OVS_VXLAN_EXT_MAX+1] = {
-	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
-};
-
-static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr)
-{
-	struct nlattr *exts[OVS_VXLAN_EXT_MAX+1];
-	struct vxlan_port *vxlan_port;
-	int err;
-
-	if (nla_len(attr) < sizeof(struct nlattr))
-		return -EINVAL;
-
-	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy);
-	if (err < 0)
-		return err;
-
-	vxlan_port = vxlan_vport(vport);
-
-	if (exts[OVS_VXLAN_EXT_GBP])
-		vxlan_port->exts |= VXLAN_F_GBP;
-
-	return 0;
-}
-
-static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
-{
-	struct net *net = ovs_dp_get_net(parms->dp);
-	struct nlattr *options = parms->options;
-	struct vxlan_port *vxlan_port;
-	struct vxlan_sock *vs;
-	struct vport *vport;
-	struct nlattr *a;
-	u16 dst_port;
-	int err;
-
-	if (!options) {
-		err = -EINVAL;
-		goto error;
-	}
-	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
-	if (a && nla_len(a) == sizeof(u16)) {
-		dst_port = nla_get_u16(a);
-	} else {
-		/* Require destination port from userspace. */
-		err = -EINVAL;
-		goto error;
-	}
-
-	vport = ovs_vport_alloc(sizeof(struct vxlan_port),
-				&ovs_vxlan_vport_ops, parms);
-	if (IS_ERR(vport))
-		return vport;
-
-	vxlan_port = vxlan_vport(vport);
-	strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
-
-	a = nla_find_nested(options, OVS_TUNNEL_ATTR_EXTENSION);
-	if (a) {
-		err = vxlan_configure_exts(vport, a);
-		if (err) {
-			ovs_vport_free(vport);
-			goto error;
-		}
-	}
-
-	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true,
-			    vxlan_port->exts);
-	if (IS_ERR(vs)) {
-		ovs_vport_free(vport);
-		return (void *)vs;
-	}
-	vxlan_port->vs = vs;
-
-	return vport;
-
-error:
-	return ERR_PTR(err);
-}
-
-static int vxlan_ext_gbp(struct sk_buff *skb)
-{
-	const struct ip_tunnel_info *tun_info;
-	const struct ovs_vxlan_opts *opts;
-
-	tun_info = OVS_CB(skb)->egress_tun_info;
-	opts = tun_info->options;
-
-	if (tun_info->key.tun_flags & TUNNEL_VXLAN_OPT &&
-	    tun_info->options_len >= sizeof(*opts))
-		return opts->gbp;
-	else
-		return 0;
-}
-
-static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	struct sock *sk = vxlan_port->vs->sock->sk;
-	__be16 dst_port = inet_sk(sk)->inet_sport;
-	const struct ip_tunnel_key *tun_key;
-	struct vxlan_metadata md = {0};
-	struct rtable *rt;
-	struct flowi4 fl;
-	__be16 src_port;
-	__be16 df;
-	int err;
-	u32 vxflags;
-
-	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
-		err = -EINVAL;
-		goto error;
-	}
-
-	tun_key = &OVS_CB(skb)->egress_tun_info->key;
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_UDP);
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto error;
-	}
-
-	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
-		htons(IP_DF) : 0;
-
-	skb->ignore_df = 1;
-
-	src_port = udp_flow_src_port(net, skb, 0, 0, true);
-	md.vni = htonl(be64_to_cpu(tun_key->tun_id) << 8);
-	md.gbp = vxlan_ext_gbp(skb);
-	vxflags = vxlan_port->exts |
-		      (tun_key->tun_flags & TUNNEL_CSUM ? VXLAN_F_UDP_CSUM : 0);
-
-	err = vxlan_xmit_skb(rt, sk, skb, fl.saddr, tun_key->ipv4_dst,
-			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df,
-			     src_port, dst_port,
-			     &md, false, vxflags);
-	if (err < 0)
-		ip_rt_put(rt);
-	return err;
-error:
-	kfree_skb(skb);
-	return err;
-}
-
-static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				     struct ip_tunnel_info *egress_tun_info)
-{
-	struct net *net = ovs_dp_get_net(vport->dp);
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
-	__be16 src_port;
-	int port_min;
-	int port_max;
-
-	inet_get_local_port_range(net, &port_min, &port_max);
-	src_port = udp_flow_src_port(net, skb, 0, 0, true);
-
-	return ovs_tunnel_get_egress_info(egress_tun_info, net,
-					  OVS_CB(skb)->egress_tun_info,
-					  IPPROTO_UDP, skb->mark,
-					  src_port, dst_port);
-}
-
-static const char *vxlan_get_name(const struct vport *vport)
-{
-	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	return vxlan_port->name;
-}
-
-static struct vport_ops ovs_vxlan_vport_ops = {
-	.type		= OVS_VPORT_TYPE_VXLAN,
-	.create		= vxlan_tnl_create,
-	.destroy	= vxlan_tnl_destroy,
-	.get_name	= vxlan_get_name,
-	.get_options	= vxlan_get_options,
-	.send		= vxlan_tnl_send,
-	.get_egress_tun_info	= vxlan_get_egress_tun_info,
-	.owner		= THIS_MODULE,
-};
-
-static int __init ovs_vxlan_tnl_init(void)
-{
-	return ovs_vport_ops_register(&ovs_vxlan_vport_ops);
-}
-
-static void __exit ovs_vxlan_tnl_exit(void)
-{
-	ovs_vport_ops_unregister(&ovs_vxlan_vport_ops);
-}
-
-module_init(ovs_vxlan_tnl_init);
-module_exit(ovs_vxlan_tnl_exit);
-
-MODULE_DESCRIPTION("OVS: VXLAN switching port");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("vport-type-4");
diff --git a/net/openvswitch/vport-vxlan.h b/net/openvswitch/vport-vxlan.h
deleted file mode 100644
index 4b08233e..0000000
--- a/net/openvswitch/vport-vxlan.h
+++ /dev/null
@@ -1,11 +0,0 @@
-#ifndef VPORT_VXLAN_H
-#define VPORT_VXLAN_H 1
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-
-struct ovs_vxlan_opts {
-	__u32 gbp;
-};
-
-#endif
-- 
2.4.3
