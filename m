From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 08/10] openvswitch: Wrap struct ovs_key_ipv4_tunnel in a new structure.
Date: Tue, 22 Jul 2014 03:19:51 -0700
Message-ID: <1406024393-6778-9-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:48823 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751471AbaGVKbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:31:55 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so11729140pab.16
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:31:55 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

Currently, the flow information that is matched for tunnels and
the tunnel data passed around with packets is the same. However,
as additional information is added this is not necessarily desirable,
as in the case of pointers.

This adds a new structure for tunnel metadata which currently contains
only the existing struct. This change is purely internal to the kernel
since the current OVS_KEY_ATTR_IPV4_TUNNEL is simply a compressed version
of OVS_KEY_ATTR_TUNNEL that is translated at flow setup.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/uapi/linux/openvswitch.h |    2 +-
 net/openvswitch/actions.c        |    6 +++---
 net/openvswitch/datapath.h       |    3 ++-
 net/openvswitch/flow.c           |   11 +++++++----
 net/openvswitch/flow.h           |   22 +++++++++++++---------
 net/openvswitch/flow_netlink.c   |   38 +++++++++++++++++++++++++++++++-------
 net/openvswitch/vport-gre.c      |   29 +++++++++++++++--------------
 net/openvswitch/vport-vxlan.c    |   27 +++++++++++++++------------
 net/openvswitch/vport.c          |    4 ++--
 net/openvswitch/vport.h          |    2 +-
 10 files changed, 90 insertions(+), 54 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 5e83a95..3b72277 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -286,7 +286,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_TCP_FLAGS,	/* be16 TCP flags. */
 
 #ifdef __KERNEL__
-	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
+	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ovs_tunnel_info */
 #endif
 	__OVS_KEY_ATTR_MAX
 };
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e70d8b1..45292da 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -473,8 +473,8 @@ static int execute_set_action(struct sk_buff *skb,
 		skb->mark = nla_get_u32(nested_attr);
 		break;
 
-	case OVS_KEY_ATTR_IPV4_TUNNEL:
-		OVS_CB(skb)->tun_key = nla_data(nested_attr);
+	case OVS_KEY_ATTR_TUNNEL_INFO:
+		OVS_CB(skb)->tun_info = nla_data(nested_attr);
 		break;
 
 	case OVS_KEY_ATTR_ETHERNET:
@@ -578,7 +578,7 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 {
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 
-	OVS_CB(skb)->tun_key = NULL;
+	OVS_CB(skb)->tun_info = NULL;
 	return do_execute_actions(dp, skb, acts->actions,
 					 acts->actions_len, false);
 }
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 7ede507..3b81051 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -102,7 +102,8 @@ struct datapath {
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
 	struct sw_flow_key	*pkt_key;
-	struct ovs_key_ipv4_tunnel  *tun_key;
+	struct ovs_tunnel_info  *tun_info;
+	struct vport	        *input_vport;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 7691b11..3d0adc5 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -450,12 +450,15 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 	int error;
 	struct ethhdr *eth;
 
-	key->phy.priority = skb->priority;
-	if (OVS_CB(skb)->tun_key)
-		memcpy(&key->tun_key, OVS_CB(skb)->tun_key, sizeof(key->tun_key));
-	else
+	if (OVS_CB(skb)->tun_info) {
+		struct ovs_tunnel_info *tun_info = OVS_CB(skb)->tun_info;
+		memcpy(&key->tun_key, &tun_info->tunnel,
+			sizeof(key->tun_key));
+	} else {
 		memset(&key->tun_key, 0, sizeof(key->tun_key));
+	}
 
+	key->phy.priority = skb->priority;
 	key->phy.in_port = in_port;
 	key->phy.skb_mark = skb->mark;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 5e5aaed..6261ad0 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -49,20 +49,24 @@ struct ovs_key_ipv4_tunnel {
 	u8   ipv4_ttl;
 } __packed __aligned(4); /* Minimize padding. */
 
-static inline void ovs_flow_tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
+struct ovs_tunnel_info {
+	struct ovs_key_ipv4_tunnel tunnel;
+};
+
+static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					 const struct iphdr *iph, __be64 tun_id,
 					 __be16 tun_flags)
 {
-	tun_key->tun_id = tun_id;
-	tun_key->ipv4_src = iph->saddr;
-	tun_key->ipv4_dst = iph->daddr;
-	tun_key->ipv4_tos = iph->tos;
-	tun_key->ipv4_ttl = iph->ttl;
-	tun_key->tun_flags = tun_flags;
+	tun_info->tunnel.tun_id = tun_id;
+	tun_info->tunnel.ipv4_src = iph->saddr;
+	tun_info->tunnel.ipv4_dst = iph->daddr;
+	tun_info->tunnel.ipv4_tos = iph->tos;
+	tun_info->tunnel.ipv4_ttl = iph->ttl;
+	tun_info->tunnel.tun_flags = tun_flags;
 
 	/* clear struct padding. */
-	memset((unsigned char *) tun_key + OVS_TUNNEL_KEY_SIZE, 0,
-	       sizeof(*tun_key) - OVS_TUNNEL_KEY_SIZE);
+	memset((unsigned char *) &tun_info->tunnel + OVS_TUNNEL_KEY_SIZE, 0,
+	       sizeof(tun_info->tunnel) - OVS_TUNNEL_KEY_SIZE);
 }
 
 struct sw_flow_key {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d5837d3..aa7c3d5 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1134,13 +1134,14 @@ out:
 	return  (struct nlattr *) ((unsigned char *)(*sfa) + next_offset);
 }
 
-static int add_action(struct sw_flow_actions **sfa, int attrtype, void *data, int len)
+static struct nlattr *__add_action(struct sw_flow_actions **sfa, int attrtype,
+				   void *data, int len)
 {
 	struct nlattr *a;
 
 	a = reserve_sfa_size(sfa, nla_attr_size(len));
 	if (IS_ERR(a))
-		return PTR_ERR(a);
+		return a;
 
 	a->nla_type = attrtype;
 	a->nla_len = nla_attr_size(len);
@@ -1149,6 +1150,18 @@ static int add_action(struct sw_flow_actions **sfa, int attrtype, void *data, in
 		memcpy(nla_data(a), data, len);
 	memset((unsigned char *) a + a->nla_len, 0, nla_padlen(len));
 
+	return a;
+}
+
+static int add_action(struct sw_flow_actions **sfa, int attrtype,
+		      void *data, int len)
+{
+	struct nlattr *a;
+
+	a = __add_action(sfa, attrtype, data, len);
+	if (IS_ERR(a))
+		return PTR_ERR(a);
+
 	return 0;
 }
 
@@ -1254,6 +1267,8 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 {
 	struct sw_flow_match match;
 	struct sw_flow_key key;
+	struct ovs_tunnel_info *tun_info;
+	struct nlattr *a;
 	int err, start;
 
 	ovs_match_init(&match, &key, NULL);
@@ -1265,8 +1280,14 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (start < 0)
 		return start;
 
-	err = add_action(sfa, OVS_KEY_ATTR_IPV4_TUNNEL, &match.key->tun_key,
-			sizeof(match.key->tun_key));
+	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
+			sizeof(*tun_info));
+	if (IS_ERR(a))
+		return PTR_ERR(a);
+
+	tun_info = nla_data(a);
+	tun_info->tunnel = key.tun_key;
+
 	add_nested_action_end(*sfa, start);
 
 	return err;
@@ -1532,17 +1553,20 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 	int err;
 
 	switch (key_type) {
-	case OVS_KEY_ATTR_IPV4_TUNNEL:
+	case OVS_KEY_ATTR_TUNNEL_INFO: {
+		struct ovs_tunnel_info *tun_info = nla_data(ovs_key);
+
 		start = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
 		if (!start)
 			return -EMSGSIZE;
 
-		err = ipv4_tun_to_nlattr(skb, nla_data(ovs_key),
-					     nla_data(ovs_key));
+		err = ipv4_tun_to_nlattr(skb, &tun_info->tunnel,
+					 &tun_info->tunnel);
 		if (err)
 			return err;
 		nla_nest_end(skb, start);
 		break;
+	}
 	default:
 		if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a), ovs_key))
 			return -EMSGSIZE;
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index f49148a..d4fcbb2 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -63,7 +63,7 @@ static __be16 filter_tnl_flags(__be16 flags)
 static struct sk_buff *__build_header(struct sk_buff *skb,
 				      int tunnel_hlen)
 {
-	const struct ovs_key_ipv4_tunnel *tun_key = OVS_CB(skb)->tun_key;
+	const struct ovs_key_ipv4_tunnel *tun_key = &OVS_CB(skb)->tun_info->tunnel;
 	struct tnl_ptk_info tpi;
 
 	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
@@ -92,7 +92,7 @@ static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
 static int gre_rcv(struct sk_buff *skb,
 		   const struct tnl_ptk_info *tpi)
 {
-	struct ovs_key_ipv4_tunnel tun_key;
+	struct ovs_tunnel_info tun_info;
 	struct ovs_net *ovs_net;
 	struct vport *vport;
 	__be64 key;
@@ -103,10 +103,10 @@ static int gre_rcv(struct sk_buff *skb,
 		return PACKET_REJECT;
 
 	key = key_to_tunnel_id(tpi->key, tpi->seq);
-	ovs_flow_tun_key_init(&tun_key, ip_hdr(skb), key,
-			      filter_tnl_flags(tpi->flags));
+	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), key,
+			       filter_tnl_flags(tpi->flags));
 
-	ovs_vport_receive(vport, skb, &tun_key);
+	ovs_vport_receive(vport, skb, &tun_info);
 	return PACKET_RCVD;
 }
 
@@ -128,6 +128,7 @@ static int gre_err(struct sk_buff *skb, u32 info,
 
 static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
+	const struct ovs_key_ipv4_tunnel *tun_key = &OVS_CB(skb)->tun_info->tunnel;
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct flowi4 fl;
 	struct rtable *rt;
@@ -136,16 +137,16 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	__be16 df;
 	int err;
 
-	if (unlikely(!OVS_CB(skb)->tun_key)) {
+	if (unlikely(!tun_key)) {
 		err = -EINVAL;
 		goto error;
 	}
 
 	/* Route lookup */
 	memset(&fl, 0, sizeof(fl));
-	fl.daddr = OVS_CB(skb)->tun_key->ipv4_dst;
-	fl.saddr = OVS_CB(skb)->tun_key->ipv4_src;
-	fl.flowi4_tos = RT_TOS(OVS_CB(skb)->tun_key->ipv4_tos);
+	fl.daddr = tun_key->ipv4_dst;
+	fl.saddr = tun_key->ipv4_src;
+	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
 	fl.flowi4_mark = skb->mark;
 	fl.flowi4_proto = IPPROTO_GRE;
 
@@ -153,7 +154,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
-	tunnel_hlen = ip_gre_calc_hlen(OVS_CB(skb)->tun_key->tun_flags);
+	tunnel_hlen = ip_gre_calc_hlen(tun_key->tun_flags);
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ tunnel_hlen + sizeof(struct iphdr)
@@ -185,15 +186,15 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 		goto err_free_rt;
 	}
 
-	df = OVS_CB(skb)->tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
+	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
 		htons(IP_DF) : 0;
 
 	skb->ignore_df = 1;
 
 	return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
-			     OVS_CB(skb)->tun_key->ipv4_dst, IPPROTO_GRE,
-			     OVS_CB(skb)->tun_key->ipv4_tos,
-			     OVS_CB(skb)->tun_key->ipv4_ttl, df, false);
+			     tun_key->ipv4_dst, IPPROTO_GRE,
+			     tun_key->ipv4_tos,
+			     tun_key->ipv4_ttl, df, false);
 err_free_rt:
 	ip_rt_put(rt);
 error:
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d523e74..3835143 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -58,7 +58,7 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 /* Called with rcu_read_lock and BH disabled. */
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 {
-	struct ovs_key_ipv4_tunnel tun_key;
+	struct ovs_tunnel_info tun_info;
 	struct vport *vport = vs->uts.data;
 	struct iphdr *iph;
 	__be64 key;
@@ -66,9 +66,9 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 	/* Save outer tunnel values */
 	iph = ip_hdr(skb);
 	key = cpu_to_be64(ntohl(vx_vni) >> 8);
-	ovs_flow_tun_key_init(&tun_key, iph, key, TUNNEL_KEY);
+	ovs_flow_tun_info_init(&tun_info, iph, key, TUNNEL_KEY);
 
-	ovs_vport_receive(vport, skb, &tun_key);
+	ovs_vport_receive(vport, skb, &tun_info);
 }
 
 static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
@@ -138,6 +138,7 @@ error:
 
 static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
+	struct ovs_key_ipv4_tunnel *tun_key;
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
 	__be16 dst_port = inet_sk(vxlan_port->vs->uts.sock->sk)->inet_sport;
@@ -147,16 +148,18 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	__be16 df;
 	int err;
 
-	if (unlikely(!OVS_CB(skb)->tun_key)) {
+	if (unlikely(!OVS_CB(skb)->tun_info)) {
 		err = -EINVAL;
 		goto error;
 	}
 
+	tun_key = &OVS_CB(skb)->tun_info->tunnel;
+
 	/* Route lookup */
 	memset(&fl, 0, sizeof(fl));
-	fl.daddr = OVS_CB(skb)->tun_key->ipv4_dst;
-	fl.saddr = OVS_CB(skb)->tun_key->ipv4_src;
-	fl.flowi4_tos = RT_TOS(OVS_CB(skb)->tun_key->ipv4_tos);
+	fl.daddr = tun_key->ipv4_dst;
+	fl.saddr = tun_key->ipv4_src;
+	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
 	fl.flowi4_mark = skb->mark;
 	fl.flowi4_proto = IPPROTO_UDP;
 
@@ -166,7 +169,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 		goto error;
 	}
 
-	df = OVS_CB(skb)->tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
+	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
 		htons(IP_DF) : 0;
 
 	skb->ignore_df = 1;
@@ -174,11 +177,11 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
-			     fl.saddr, OVS_CB(skb)->tun_key->ipv4_dst,
-			     OVS_CB(skb)->tun_key->ipv4_tos,
-			     OVS_CB(skb)->tun_key->ipv4_ttl, df,
+			     fl.saddr, tun_key->ipv4_dst,
+			     tun_key->ipv4_tos,
+			     tun_key->ipv4_ttl, df,
 			     src_port, dst_port,
-			     htonl(be64_to_cpu(OVS_CB(skb)->tun_key->tun_id) << 8),
+			     htonl(be64_to_cpu(tun_key->tun_id) << 8),
 			     false);
 	if (err < 0)
 		ip_rt_put(rt);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 5b4cb82..39e2c9c 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -340,7 +340,7 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
  * skb->data should point to the Ethernet header.
  */
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
-		       struct ovs_key_ipv4_tunnel *tun_key)
+		       struct ovs_tunnel_info *tun_info)
 {
 	struct pcpu_sw_netstats *stats;
 
@@ -350,7 +350,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	OVS_CB(skb)->tun_key = tun_key;
+	OVS_CB(skb)->tun_info = tun_info;
 	ovs_dp_process_received_packet(vport, skb);
 }
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 8d721e6..400cd1e 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -191,7 +191,7 @@ static inline struct vport *vport_from_priv(void *priv)
 }
 
 void ovs_vport_receive(struct vport *, struct sk_buff *,
-		       struct ovs_key_ipv4_tunnel *);
+		       struct ovs_tunnel_info *);
 
 /* List of statically compiled vport implementations.  Don't forget to also
  * add yours to the list at the top of vport.c. */
-- 
1.7.9.5
