From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 3/5] openvswitch: Use tun_key only for egress tunnel path.
Date: Tue, 16 Sep 2014 00:23:52 -0700
Message-ID: <1410852232-1543-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:58312 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752485AbaIPHXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 03:23:31 -0400
Received: by mail-pd0-f170.google.com with SMTP id fp1so8130567pdb.1
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 00:23:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tun_key is used for passing tunnel information
on ingress and egress path, this cause confusion.  Following
patch removes its use on ingress path make it egress only parameter.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/actions.c     |  3 +--
 net/openvswitch/datapath.c    | 20 ++++++--------------
 net/openvswitch/datapath.h    |  8 ++++----
 net/openvswitch/flow.c        |  7 ++++---
 net/openvswitch/flow.h        |  3 ++-
 net/openvswitch/vport-gre.c   | 23 ++++++++++++-----------
 net/openvswitch/vport-vxlan.c | 21 +++++++++++----------
 net/openvswitch/vport.c       | 12 ++++++++++--
 8 files changed, 50 insertions(+), 47 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 8a1eb56..1cdb539 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -510,7 +510,7 @@ static int execute_set_action(struct sk_buff *skb,
 		break;
 
 	case OVS_KEY_ATTR_IPV4_TUNNEL:
-		OVS_CB(skb)->tun_key = nla_data(nested_attr);
+		OVS_CB(skb)->egress_tun_key = nla_data(nested_attr);
 		break;
 
 	case OVS_KEY_ATTR_ETHERNET:
@@ -613,7 +613,6 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 {
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 
-	OVS_CB(skb)->tun_key = NULL;
 	return do_execute_actions(dp, skb, key,
 				  acts->actions, acts->actions_len);
 }
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0cce8e6..7e08199 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -237,33 +237,25 @@ void ovs_dp_detach_port(struct vport *p)
 }
 
 /* Must be called with rcu_read_lock. */
-void ovs_dp_process_received_packet(struct sk_buff *skb)
+void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	const struct vport *p = OVS_CB(skb)->input_vport;
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
+	flow = ovs_flow_tbl_lookup_stats(&dp->table, key, &n_mask_hit);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
+		int error;
 
 		upcall.cmd = OVS_PACKET_CMD_MISS;
-		upcall.key = &key;
+		upcall.key = key;
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		error = ovs_dp_upcall(dp, skb, &upcall);
@@ -277,8 +269,8 @@ void ovs_dp_process_received_packet(struct sk_buff *skb)
 
 	OVS_CB(skb)->flow = flow;
 
-	ovs_flow_stats_update(OVS_CB(skb)->flow, key.tp.flags, skb);
-	ovs_execute_actions(dp, skb, &key);
+	ovs_flow_stats_update(OVS_CB(skb)->flow, key->tp.flags, skb);
+	ovs_execute_actions(dp, skb, key);
 	stats_counter = &stats->n_hit;
 
 out:
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 2b982fa..25b0e88 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -95,15 +95,15 @@ struct datapath {
 /**
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
- * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
- * packet is not being tunneled.
+ * @egress_tun_key: Tunnel information about this packet on egress path.
+ * NULL if the packet is not being tunneled.
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
-	struct ovs_key_ipv4_tunnel  *tun_key;
 	struct vport		*input_vport;
+	struct ovs_key_ipv4_tunnel  *egress_tun_key;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
@@ -184,7 +184,7 @@ static inline struct vport *ovs_vport_ovsl(const struct datapath *dp, int port_n
 extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_family dp_vport_genl_family;
 
-void ovs_dp_process_received_packet(struct sk_buff *);
+void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key);
 void ovs_dp_detach_port(struct vport *);
 int ovs_dp_upcall(struct datapath *, struct sk_buff *,
 		  const struct dp_upcall_info *);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index d186eb6..bf84420 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -606,12 +606,13 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
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
index f49148a..309cca6 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2013 Nicira, Inc.
+ * Copyright (c) 2007-2014 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
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
@@ -185,15 +187,14 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
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
+			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df, false);
 err_free_rt:
 	ip_rt_put(rt);
 error:
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d8b7e24..f19539b 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2013 Nicira, Inc.
+ * Copyright (c) 2014 Nicira, Inc.
  * Copyright (c) 2013 Cisco Systems, Inc.
  *
  * This program is free software; you can redistribute it and/or
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
@@ -173,11 +175,10 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
-			     fl.saddr, OVS_CB(skb)->tun_key->ipv4_dst,
-			     OVS_CB(skb)->tun_key->ipv4_tos,
-			     OVS_CB(skb)->tun_key->ipv4_ttl, df,
+			     fl.saddr, tun_key->ipv4_dst,
+			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df,
 			     src_port, dst_port,
-			     htonl(be64_to_cpu(OVS_CB(skb)->tun_key->tun_id) << 8),
+			     htonl(be64_to_cpu(tun_key->tun_id) << 8),
 			     false);
 	if (err < 0)
 		ip_rt_put(rt);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index acf31aa..5df8377 100644
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
+	ovs_dp_process_packet(skb, &key);
 }
 
 /**
-- 
1.9.3
