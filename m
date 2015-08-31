From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] ip-tunnel: Use API to access tunnel metadata options.
Date: Sun, 30 Aug 2015 18:09:38 -0700
Message-ID: <1440983378-2107-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35983 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbHaBJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 21:09:44 -0400
Received: by pacrd3 with SMTP id rd3so4245088pac.3
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2015 18:09:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tun-info options pointer is used in few cases to
pass options around. But tunnel options can be accessed using
ip_tunnel_info_opts() API without using the pointer. Following
patch removes the redundant pointer and consistently make use
of API.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c           |    9 ++---
 drivers/net/vxlan.c            |    4 +-
 include/net/dst_metadata.h     |   31 ++++++++----------
 include/net/ip_tunnels.h       |   67 ++++++++++++++++++---------------------
 net/ipv4/ip_tunnel_core.c      |    2 -
 net/openvswitch/actions.c      |    8 +++--
 net/openvswitch/datapath.c     |    3 +-
 net/openvswitch/datapath.h     |    3 +-
 net/openvswitch/flow.c         |    7 ++--
 net/openvswitch/flow_netlink.c |   27 ++++++---------
 net/openvswitch/flow_netlink.h |    3 +-
 net/openvswitch/vport-geneve.c |    5 +--
 net/openvswitch/vport-gre.c    |    5 +--
 net/openvswitch/vport-vxlan.c  |    4 +-
 net/openvswitch/vport.c        |   27 ++++++++--------
 net/openvswitch/vport.h        |    7 ++--
 16 files changed, 100 insertions(+), 112 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 68b0f03..da3259c 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -143,7 +143,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 
 	if (ip_tunnel_collect_metadata() || gs->collect_md) {
 		__be16 flags;
-		void *opts;
 
 		flags = TUNNEL_KEY | TUNNEL_GENEVE_OPT |
 			(gnvh->oam ? TUNNEL_OAM : 0) |
@@ -154,11 +153,9 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 					 gnvh->opt_len * 4);
 		if (!tun_dst)
 			goto drop;
-
 		/* Update tunnel dst according to Geneve options. */
-		opts = ip_tunnel_info_opts(&tun_dst->u.tun_info,
-					   gnvh->opt_len * 4);
-		memcpy(opts, gnvh->options, gnvh->opt_len * 4);
+		ip_tunnel_info_opts_set(&tun_dst->u.tun_info,
+					gnvh->options, gnvh->opt_len * 4);
 	} else {
 		/* Drop packets w/ critical options,
 		 * since we don't support any...
@@ -663,7 +660,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		tunnel_id_to_vni(key->tun_id, vni);
 		if (key->tun_flags & TUNNEL_GENEVE_OPT)
-			opts = ip_tunnel_info_opts(info, info->options_len);
+			opts = ip_tunnel_info_opts(info);
 
 		udp_csum = !!(key->tun_flags & TUNNEL_CSUM);
 		err = geneve_build_skb(rt, skb, key->tun_flags, vni,
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6c5269a..ce988fd 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1271,7 +1271,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 
 		info = &tun_dst->u.tun_info;
-		md = ip_tunnel_info_opts(info, sizeof(*md));
+		md = ip_tunnel_info_opts(info);
 	} else {
 		memset(md, 0, sizeof(*md));
 	}
@@ -1948,7 +1948,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = info->key.tos;
 
 		if (info->options_len)
-			md = ip_tunnel_info_opts(info, sizeof(*md));
+			md = ip_tunnel_info_opts(info);
 	} else {
 		md->gbp = skb->mark;
 	}
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index d32f49c..547ab82 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -48,21 +48,16 @@ static inline bool skb_valid_dst(const struct sk_buff *skb)
 struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
 struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags);
 
-static inline struct metadata_dst *tun_rx_dst(__be16 flags,
-					      __be64 tunnel_id, int md_size)
+static inline struct metadata_dst *tun_rx_dst(int md_size)
 {
 	struct metadata_dst *tun_dst;
-	struct ip_tunnel_info *info;
 
 	tun_dst = metadata_dst_alloc(md_size, GFP_ATOMIC);
 	if (!tun_dst)
 		return NULL;
 
-	info = &tun_dst->u.tun_info;
-	info->key.tun_flags = flags;
-	info->key.tun_id = tunnel_id;
-	info->key.tp_src = 0;
-	info->key.tp_dst = 0;
+	tun_dst->u.tun_info.options_len = 0;
+	tun_dst->u.tun_info.mode = 0;
 	return tun_dst;
 }
 
@@ -73,17 +68,14 @@ static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct metadata_dst *tun_dst;
-	struct ip_tunnel_info *info;
 
-	tun_dst = tun_rx_dst(flags, tunnel_id, md_size);
+	tun_dst = tun_rx_dst(md_size);
 	if (!tun_dst)
 		return NULL;
 
-	info = &tun_dst->u.tun_info;
-	info->key.u.ipv4.src = iph->saddr;
-	info->key.u.ipv4.dst = iph->daddr;
-	info->key.tos = iph->tos;
-	info->key.ttl = iph->ttl;
+	ip_tunnel_key_init(&tun_dst->u.tun_info.key,
+			   iph->saddr, iph->daddr, iph->tos, iph->ttl,
+			   0, 0, tunnel_id, flags);
 	return tun_dst;
 }
 
@@ -96,16 +88,21 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
 	struct metadata_dst *tun_dst;
 	struct ip_tunnel_info *info;
 
-	tun_dst = tun_rx_dst(flags, tunnel_id, md_size);
+	tun_dst = tun_rx_dst(md_size);
 	if (!tun_dst)
 		return NULL;
 
 	info = &tun_dst->u.tun_info;
+	info->mode = IP_TUNNEL_INFO_IPV6;
+	info->key.tun_flags = flags;
+	info->key.tun_id = tunnel_id;
+	info->key.tp_src = 0;
+	info->key.tp_dst = 0;
+
 	info->key.u.ipv6.src = ip6h->saddr;
 	info->key.u.ipv6.dst = ip6h->daddr;
 	info->key.tos = ipv6_get_dsfield(ip6h);
 	info->key.ttl = ip6h->hop_limit;
-	info->mode = IP_TUNNEL_INFO_IPV6;
 	return tun_dst;
 }
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 2b4fa06..9a6a3ba 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -57,7 +57,6 @@ struct ip_tunnel_key {
 
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
-	const void		*options;
 	u8			options_len;
 	u8			mode;
 };
@@ -180,49 +179,32 @@ int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *op,
 int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
 			    unsigned int num);
 
-static inline void __ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
-					 __be32 saddr, __be32 daddr,
-					 u8 tos, u8 ttl,
-					 __be16 tp_src, __be16 tp_dst,
-					 __be64 tun_id, __be16 tun_flags,
-					 const void *opts, u8 opts_len)
+static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
+				      __be32 saddr, __be32 daddr,
+				      u8 tos, u8 ttl,
+				      __be16 tp_src, __be16 tp_dst,
+				      __be64 tun_id, __be16 tun_flags)
 {
-	tun_info->key.tun_id = tun_id;
-	tun_info->key.u.ipv4.src = saddr;
-	tun_info->key.u.ipv4.dst = daddr;
-	memset((unsigned char *)&tun_info->key + IP_TUNNEL_KEY_IPV4_PAD,
+	key->tun_id = tun_id;
+	key->u.ipv4.src = saddr;
+	key->u.ipv4.dst = daddr;
+	memset((unsigned char *)key + IP_TUNNEL_KEY_IPV4_PAD,
 	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
-	tun_info->key.tos = tos;
-	tun_info->key.ttl = ttl;
-	tun_info->key.tun_flags = tun_flags;
+	key->tos = tos;
+	key->ttl = ttl;
+	key->tun_flags = tun_flags;
 
 	/* For the tunnel types on the top of IPsec, the tp_src and tp_dst of
 	 * the upper tunnel are used.
 	 * E.g: GRE over IPSEC, the tp_src and tp_port are zero.
 	 */
-	tun_info->key.tp_src = tp_src;
-	tun_info->key.tp_dst = tp_dst;
+	key->tp_src = tp_src;
+	key->tp_dst = tp_dst;
 
 	/* Clear struct padding. */
-	if (sizeof(tun_info->key) != IP_TUNNEL_KEY_SIZE)
-		memset((unsigned char *)&tun_info->key + IP_TUNNEL_KEY_SIZE,
-		       0, sizeof(tun_info->key) - IP_TUNNEL_KEY_SIZE);
-
-	tun_info->options = opts;
-	tun_info->options_len = opts_len;
-
-	tun_info->mode = 0;
-}
-
-static inline void ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
-				       const struct iphdr *iph,
-				       __be16 tp_src, __be16 tp_dst,
-				       __be64 tun_id, __be16 tun_flags,
-				       const void *opts, u8 opts_len)
-{
-	__ip_tunnel_info_init(tun_info, iph->saddr, iph->daddr,
-			      iph->tos, iph->ttl, tp_src, tp_dst,
-			      tun_id, tun_flags, opts, opts_len);
+	if (sizeof(*key) != IP_TUNNEL_KEY_SIZE)
+		memset((unsigned char *)key + IP_TUNNEL_KEY_SIZE,
+		       0, sizeof(*key) - IP_TUNNEL_KEY_SIZE);
 }
 
 static inline unsigned short ip_tunnel_info_af(const struct ip_tunnel_info
@@ -317,11 +299,24 @@ static inline void iptunnel_xmit_stats(int err,
 	}
 }
 
-static inline void *ip_tunnel_info_opts(struct ip_tunnel_info *info, size_t n)
+static inline void *ip_tunnel_info_opts(struct ip_tunnel_info *info)
 {
 	return info + 1;
 }
 
+static inline void ip_tunnel_info_opts_get(void *to,
+					   const struct ip_tunnel_info *info)
+{
+	memcpy(to, info + 1, info->options_len);
+}
+
+static inline void ip_tunnel_info_opts_set(struct ip_tunnel_info *info,
+					   const void *from, int len)
+{
+	memcpy(ip_tunnel_info_opts(info), from, len);
+	info->options_len = len;
+}
+
 static inline struct ip_tunnel_info *lwt_tun_info(struct lwtunnel_state *lwtstate)
 {
 	return (struct ip_tunnel_info *)lwtstate->data;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 0c756ad..29ed6c5 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -249,7 +249,6 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP_FLAGS]);
 
 	tun_info->mode = IP_TUNNEL_INFO_TX;
-	tun_info->options = NULL;
 	tun_info->options_len = 0;
 
 	*ts = new_state;
@@ -357,7 +356,6 @@ static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
 		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP6_FLAGS]);
 
 	tun_info->mode = IP_TUNNEL_INFO_TX | IP_TUNNEL_INFO_IPV6;
-	tun_info->options = NULL;
 	tun_info->options_len = 0;
 
 	*ts = new_state;
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 090d9e3..315f533 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -793,11 +793,13 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			if (vport) {
 				int err;
 
+				upcall.egress_tun_info = &info;
 				err = ovs_vport_get_egress_tun_info(vport, skb,
-								    &info);
-				if (!err)
-					upcall.egress_tun_info = &info;
+								    &upcall);
+				if (err)
+					upcall.egress_tun_info = NULL;
 			}
+
 			break;
 		}
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 60c2ab8..6fbd2de 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -491,7 +491,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	if (upcall_info->egress_tun_info) {
 		nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_EGRESS_TUN_KEY);
 		err = ovs_nla_put_egress_tunnel_key(user_skb,
-						    upcall_info->egress_tun_info);
+						    upcall_info->egress_tun_info,
+						    upcall_info->egress_tun_opts);
 		BUG_ON(err);
 		nla_nest_end(user_skb, nla);
 	}
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index c05b7d9..f88038a 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -116,7 +116,8 @@ struct ovs_skb_cb {
  * @mru: If not zero, Maximum received IP fragment size.
  */
 struct dp_upcall_info {
-	const struct ip_tunnel_info *egress_tun_info;
+	struct ip_tunnel_info *egress_tun_info;
+	const void *egress_tun_opts;
 	const struct nlattr *userdata;
 	const struct nlattr *actions;
 	int actions_len;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index bed8d09..c8db44a 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -702,12 +702,13 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			return -EINVAL;
 		memcpy(&key->tun_key, &tun_info->key, sizeof(key->tun_key));
 
-		if (tun_info->options) {
+		if (tun_info->options_len) {
 			BUILD_BUG_ON((1 << (sizeof(tun_info->options_len) *
 						   8)) - 1
 					> sizeof(key->tun_opts));
-			memcpy(TUN_METADATA_OPTS(key, tun_info->options_len),
-			       tun_info->options, tun_info->options_len);
+
+			ip_tunnel_info_opts_get(TUN_METADATA_OPTS(key, tun_info->options_len),
+						tun_info);
 			key->tun_opts_len = tun_info->options_len;
 		} else {
 			key->tun_opts_len = 0;
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index e22c5bf..c92d6a2 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -716,10 +716,11 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 }
 
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *skb,
-				  const struct ip_tunnel_info *egress_tun_info)
+				  const struct ip_tunnel_info *egress_tun_info,
+				  const void *egress_tun_opts)
 {
 	return __ipv4_tun_to_nlattr(skb, &egress_tun_info->key,
-				    egress_tun_info->options,
+				    egress_tun_opts,
 				    egress_tun_info->options_len);
 }
 
@@ -1876,20 +1877,14 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	tun_info = &tun_dst->u.tun_info;
 	tun_info->mode = IP_TUNNEL_INFO_TX;
 	tun_info->key = key.tun_key;
-	tun_info->options_len = key.tun_opts_len;
-
-	if (tun_info->options_len) {
-		/* We need to store the options in the action itself since
-		 * everything else will go away after flow setup. We can append
-		 * it to tun_info and then point there.
-		 */
-		memcpy((tun_info + 1),
-		       TUN_METADATA_OPTS(&key, key.tun_opts_len), key.tun_opts_len);
-		tun_info->options = (tun_info + 1);
-	} else {
-		tun_info->options = NULL;
-	}
 
+	/* We need to store the options in the action itself since
+	 * everything else will go away after flow setup. We can append
+	 * it to tun_info and then point there.
+	 */
+	ip_tunnel_info_opts_set(tun_info,
+				TUN_METADATA_OPTS(&key, key.tun_opts_len),
+				key.tun_opts_len);
 	add_nested_action_end(*sfa, start);
 
 	return err;
@@ -2345,7 +2340,7 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 
 		err = ipv4_tun_to_nlattr(skb, &tun_info->key,
 					 tun_info->options_len ?
-						tun_info->options : NULL,
+					     ip_tunnel_info_opts(tun_info) : NULL,
 					 tun_info->options_len);
 		if (err)
 			return err;
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 07878e2..6ca3f0b 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -56,7 +56,8 @@ int ovs_nla_get_match(struct net *, struct sw_flow_match *,
 		      const struct nlattr *key, const struct nlattr *mask,
 		      bool log);
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
-				  const struct ip_tunnel_info *);
+				  const struct ip_tunnel_info *,
+				  const void *egress_tun_opts);
 
 bool ovs_nla_get_ufid(struct sw_flow_id *, const struct nlattr *, bool log);
 int ovs_nla_get_identifier(struct sw_flow_id *sfid, const struct nlattr *ufid,
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 24c56e5..2735e9c 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -53,15 +53,14 @@ static int geneve_get_options(const struct vport *vport,
 }
 
 static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				      struct ip_tunnel_info *egress_tun_info)
+				      struct dp_upcall_info *upcall)
 {
 	struct geneve_port *geneve_port = geneve_vport(vport);
 	struct net *net = ovs_dp_get_net(vport->dp);
 	__be16 dport = htons(geneve_port->port_no);
 	__be16 sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
 
-	return ovs_tunnel_get_egress_info(egress_tun_info,
-					  ovs_dp_get_net(vport->dp),
+	return ovs_tunnel_get_egress_info(upcall, ovs_dp_get_net(vport->dp),
 					  skb, IPPROTO_UDP, sport, dport);
 }
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 36c3984..4d24481 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -85,10 +85,9 @@ static struct vport *gre_create(const struct vport_parms *parms)
 }
 
 static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				   struct ip_tunnel_info *egress_tun_info)
+				   struct dp_upcall_info *upcall)
 {
-	return ovs_tunnel_get_egress_info(egress_tun_info,
-					  ovs_dp_get_net(vport->dp),
+	return ovs_tunnel_get_egress_info(upcall, ovs_dp_get_net(vport->dp),
 					  skb, IPPROTO_GRE, 0, 0);
 }
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index ed7b23f..c11413d 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -147,7 +147,7 @@ static struct vport *vxlan_create(const struct vport_parms *parms)
 }
 
 static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				     struct ip_tunnel_info *egress_tun_info)
+				     struct dp_upcall_info *upcall)
 {
 	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
 	struct net *net = ovs_dp_get_net(vport->dp);
@@ -159,7 +159,7 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 	inet_get_local_port_range(net, &port_min, &port_max);
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
-	return ovs_tunnel_get_egress_info(egress_tun_info, net,
+	return ovs_tunnel_get_egress_info(upcall, net,
 					  skb, IPPROTO_UDP,
 					  src_port, dst_port);
 }
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 1679dea..dc81dc6 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -487,13 +487,14 @@ void ovs_vport_deferred_free(struct vport *vport)
 }
 EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
 
-int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
+int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
 			       struct net *net,
 			       struct sk_buff *skb,
 			       u8 ipproto,
 			       __be16 tp_src,
 			       __be16 tp_dst)
 {
+	struct ip_tunnel_info *egress_tun_info = upcall->egress_tun_info;
 	const struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
 	const struct ip_tunnel_key *tun_key;
 	u32 skb_mark = skb->mark;
@@ -520,26 +521,26 @@ int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 	/* Generate egress_tun_info based on tun_info,
 	 * saddr, tp_src and tp_dst
 	 */
-	__ip_tunnel_info_init(egress_tun_info,
-			      fl.saddr, tun_key->u.ipv4.dst,
-			      tun_key->tos,
-			      tun_key->ttl,
-			      tp_src, tp_dst,
-			      tun_key->tun_id,
-			      tun_key->tun_flags,
-			      tun_info->options,
-			      tun_info->options_len);
-
+	ip_tunnel_key_init(&egress_tun_info->key,
+			   fl.saddr, tun_key->u.ipv4.dst,
+			   tun_key->tos,
+			   tun_key->ttl,
+			   tp_src, tp_dst,
+			   tun_key->tun_id,
+			   tun_key->tun_flags);
+	egress_tun_info->options_len = tun_info->options_len;
+	egress_tun_info->mode = tun_info->mode;
+	upcall->egress_tun_opts = ip_tunnel_info_opts(egress_tun_info);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ovs_tunnel_get_egress_info);
 
 int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				  struct ip_tunnel_info *info)
+				  struct dp_upcall_info *upcall)
 {
 	/* get_egress_tun_info() is only implemented on tunnel ports. */
 	if (unlikely(!vport->ops->get_egress_tun_info))
 		return -EINVAL;
 
-	return vport->ops->get_egress_tun_info(vport, skb, info);
+	return vport->ops->get_egress_tun_info(vport, skb, upcall);
 }
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 4b6f4a5..a413f3a 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -53,14 +53,15 @@ int ovs_vport_set_upcall_portids(struct vport *, const struct nlattr *pids);
 int ovs_vport_get_upcall_portids(const struct vport *, struct sk_buff *);
 u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
-int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
+int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
 			       struct net *net,
 			       struct sk_buff *,
 			       u8 ipproto,
 			       __be16 tp_src,
 			       __be16 tp_dst);
+
 int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				  struct ip_tunnel_info *info);
+				  struct dp_upcall_info *upcall);
 
 /**
  * struct vport_portids - array of netlink portids of a vport.
@@ -154,7 +155,7 @@ struct vport_ops {
 
 	void (*send)(struct vport *, struct sk_buff *);
 	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
-				   struct ip_tunnel_info *);
+				   struct dp_upcall_info *upcall);
 
 	struct module *owner;
 	struct list_head list;
-- 
1.7.1
