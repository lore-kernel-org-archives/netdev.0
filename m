From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 2/4] openvswitch: Use tun_key only for egress tunnel path.
Date: Thu, 11 Sep 2014 16:28:08 -0700
Message-ID: <1410478088-1465-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:38843 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752504AbaIKX1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:27:40 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so9573914pad.28
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 16:27:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tun_key is used for passing tunnel information
on ingress and egress path, this cause confusion.  Following
patch removes its use on ingress path make it egress only parameter.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/actions.c     |  3 +--
 net/openvswitch/datapath.c    | 19 ++++++-------------
 net/openvswitch/datapath.h    |  8 ++++----
 net/openvswitch/flow.c        |  7 ++++---
 net/openvswitch/flow.h        |  3 ++-
 net/openvswitch/vport-gre.c   | 22 ++++++++++++----------
 net/openvswitch/vport-vxlan.c | 20 +++++++++++---------
 net/openvswitch/vport.c       | 12 ++++++++++--
 8 files changed, 50 insertions(+), 44 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 5231652..39c722f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -511,7 +511,7 @@ static int execute_set_action(struct sk_buff *skb,
 		break;
 
 	case OVS_KEY_ATTR_IPV4_TUNNEL:
-		OVS_CB(skb)->tun_key = nla_data(nested_attr);
+		OVS_CB(skb)->egress_tun_key = nla_data(nested_attr);
 		break;
 
 	case OVS_KEY_ATTR_ETHERNET:
@@ -612,6 +612,5 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 {
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 
-	OVS_CB(skb)->tun_key = NULL;
 	return do_execute_actions(dp, skb, acts->actions, acts->actions_len);
 }
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7c3939a..4046bc2 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -237,33 +237,26 @@ void ovs_dp_detach_port(struct vport *p)
 }
 
 /* Must be called with rcu_read_lock. */
-void ovs_dp_process_received_packet(struct sk_buff *skb)
+void ovs_dp_process_packet(struct sk_buff *skb)
 {
 	const struct vport *p = OVS_CB(skb)->input_vport;
+	struct sw_flow_key *pkt_key = OVS_CB(skb)->pkt_key;
 	struct datapath *dp = p->dp;
 	struct sw_flow *flow;
 	struct dp_stats_percpu *stats;
-	struct sw_flow_key key;
 	u64 *stats_counter;
 	u32 n_mask_hit;
-	int error;
 
 	stats = this_cpu_ptr(dp->stats_percpu);
 
-	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_key_extract(skb, &key);
-	if (unlikely(error)) {
-		kfree_skb(skb);
-		return;
-	}
-
 	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup_stats(&dp->table, &key, &n_mask_hit);
+	flow = ovs_flow_tbl_lookup_stats(&dp->table, pkt_key, &n_mask_hit);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
+		int error;
 
 		upcall.cmd = OVS_PACKET_CMD_MISS;
-		upcall.key = &key;
+		upcall.key = pkt_key;
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		error = ovs_dp_upcall(dp, skb, &upcall);
@@ -276,7 +269,7 @@ void ovs_dp_process_received_packet(struct sk_buff *skb)
 	}
 	OVS_CB(skb)->flow = flow;
 
-	ovs_flow_stats_update(OVS_CB(skb)->flow, key.tp.flags, skb);
+	ovs_flow_stats_update(OVS_CB(skb)->flow, pkt_key->tp.flags, skb);
 	ovs_execute_actions(dp, skb);
 	stats_counter = &stats->n_hit;
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 9d5b7d1..fdd96c0 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -96,15 +96,15 @@ struct datapath {
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
  * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
- * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
- * packet is not being tunneled.
+ * @egress_tun_key: Tunnel information about this packet on egress path.
+ * NULL if the packet is not being tunneled.
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
 	struct sw_flow_key	*pkt_key;
-	struct ovs_key_ipv4_tunnel  *tun_key;
+	struct ovs_key_ipv4_tunnel  *egress_tun_key;
 	struct vport		*input_vport;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
@@ -186,7 +186,7 @@ static inline struct vport *ovs_vport_ovsl(const struct datapath *dp, int port_n
 extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_family dp_vport_genl_family;
 
-void ovs_dp_process_received_packet(struct sk_buff *);
+void ovs_dp_process_packet(struct sk_buff *);
 void ovs_dp_detach_port(struct vport *);
 int ovs_dp_upcall(struct datapath *, struct sk_buff *,
 		  const struct dp_upcall_info *);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index d264125..3faffb9 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -608,12 +608,13 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	return 0;
 }
 
-int ovs_flow_key_extract(struct sk_buff *skb, struct sw_flow_key *key)
+int ovs_flow_key_extract(struct ovs_key_ipv4_tunnel *tun_key,
+			 struct sk_buff *skb, struct sw_flow_key *key)
 {
 	/* Extract metadata from packet. */
 	memset(key, 0, sizeof(*key));
-	if (OVS_CB(skb)->tun_key)
-		memcpy(&key->tun_key, OVS_CB(skb)->tun_key, sizeof(key->tun_key));
+	if (tun_key)
+		memcpy(&key->tun_key, tun_key, sizeof(key->tun_key));
 
 	key->phy.priority = skb->priority;
 	key->phy.in_port = OVS_CB(skb)->input_vport->port_no;
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 251789b..3869a54 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -187,7 +187,8 @@ void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
 void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
-int ovs_flow_key_extract(struct sk_buff *skb, struct sw_flow_key *key);
+int ovs_flow_key_extract(struct ovs_key_ipv4_tunnel *tun_key,
+			 struct sk_buff *skb, struct sw_flow_key *key);
 /* Extract key from packet coming from userspace. */
 int ovs_flow_key_extract_userspace(const struct nlattr *attr,
 				   struct sk_buff *skb,
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index f49148a..e92617b 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -63,7 +63,7 @@ static __be16 filter_tnl_flags(__be16 flags)
 static struct sk_buff *__build_header(struct sk_buff *skb,
 				      int tunnel_hlen)
 {
-	const struct ovs_key_ipv4_tunnel *tun_key = OVS_CB(skb)->tun_key;
+	const struct ovs_key_ipv4_tunnel *tun_key = OVS_CB(skb)->egress_tun_key;
 	struct tnl_ptk_info tpi;
 
 	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
@@ -129,6 +129,7 @@ static int gre_err(struct sk_buff *skb, u32 info,
 static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
+	struct ovs_key_ipv4_tunnel *tun_key;
 	struct flowi4 fl;
 	struct rtable *rt;
 	int min_headroom;
@@ -136,16 +137,17 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	__be16 df;
 	int err;
 
-	if (unlikely(!OVS_CB(skb)->tun_key)) {
+	if (unlikely(!OVS_CB(skb)->egress_tun_key)) {
 		err = -EINVAL;
 		goto error;
 	}
 
+	tun_key = OVS_CB(skb)->egress_tun_key;
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
 
@@ -153,7 +155,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
-	tunnel_hlen = ip_gre_calc_hlen(OVS_CB(skb)->tun_key->tun_flags);
+	tunnel_hlen = ip_gre_calc_hlen(tun_key->tun_flags);
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ tunnel_hlen + sizeof(struct iphdr)
@@ -185,15 +187,15 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
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
index d8b7e24..d3f088f 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -140,22 +140,24 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
 	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
+	struct ovs_key_ipv4_tunnel *tun_key;
 	struct rtable *rt;
 	struct flowi4 fl;
 	__be16 src_port;
 	__be16 df;
 	int err;
 
-	if (unlikely(!OVS_CB(skb)->tun_key)) {
+	if (unlikely(!OVS_CB(skb)->egress_tun_key)) {
 		err = -EINVAL;
 		goto error;
 	}
 
+	tun_key = OVS_CB(skb)->egress_tun_key;
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
 
@@ -165,7 +167,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 		goto error;
 	}
 
-	df = OVS_CB(skb)->tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
+	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
 		htons(IP_DF) : 0;
 
 	skb->ignore_df = 1;
@@ -173,11 +175,11 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
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
index d21251f..d3f76df 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -435,6 +435,8 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 		       struct ovs_key_ipv4_tunnel *tun_key)
 {
 	struct pcpu_sw_netstats *stats;
+	struct sw_flow_key key;
+	int error;
 
 	stats = this_cpu_ptr(vport->percpu_stats);
 	u64_stats_update_begin(&stats->syncp);
@@ -442,9 +444,15 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	OVS_CB(skb)->tun_key = tun_key;
 	OVS_CB(skb)->input_vport = vport;
-	ovs_dp_process_received_packet(skb);
+	OVS_CB(skb)->egress_tun_key = NULL;
+	/* Extract flow from 'skb' into 'key'. */
+	error = ovs_flow_key_extract(tun_key, skb, &key);
+	if (unlikely(error)) {
+		kfree_skb(skb);
+		return;
+	}
+	ovs_dp_process_packet(skb);
 }
 
 /**
-- 
1.9.3
