From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 4/6] openvswitch: Wrap struct ovs_key_ipv4_tunnel in a new structure.
Date: Thu,  2 Oct 2014 01:04:43 -0700
Message-ID: <1412237085-27215-5-git-send-email-azhou@nicira.com>
References: <1412237085-27215-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:53197 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752194AbaJBILF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 04:11:05 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so1644860pde.22
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 01:11:04 -0700 (PDT)
In-Reply-To: <1412237085-27215-1-git-send-email-azhou@nicira.com>
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
 net/openvswitch/actions.c        |    5 +++--
 net/openvswitch/datapath.h       |    2 +-
 net/openvswitch/flow.c           |    6 +++---
 net/openvswitch/flow.h           |   30 +++++++++++++++++-------------
 net/openvswitch/flow_netlink.c   |   38 +++++++++++++++++++++++++++++++-------
 net/openvswitch/vport-gre.c      |   16 +++++++++-------
 net/openvswitch/vport-vxlan.c    |   10 +++++-----
 net/openvswitch/vport.c          |    6 +++---
 net/openvswitch/vport.h          |    2 +-
 10 files changed, 74 insertions(+), 43 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 7c06106..6753032 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -294,7 +294,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_RECIRC_ID, /* u32 recirc id */
 
 #ifdef __KERNEL__
-	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
+	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ovs_tunnel_info */
 #endif
 	__OVS_KEY_ATTR_MAX
 };
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 6932a42..006886d 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -590,8 +590,8 @@ static int execute_set_action(struct sk_buff *skb,
 		skb->mark = nla_get_u32(nested_attr);
 		break;
 
-	case OVS_KEY_ATTR_IPV4_TUNNEL:
-		OVS_CB(skb)->egress_tun_key = nla_data(nested_attr);
+	case OVS_KEY_ATTR_TUNNEL_INFO:
+		OVS_CB(skb)->egress_tun_info = nla_data(nested_attr);
 		break;
 
 	case OVS_KEY_ATTR_ETHERNET:
@@ -778,6 +778,7 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 
 	this_cpu_inc(exec_actions_level);
+	OVS_CB(skb)->egress_tun_info = NULL;
 	err = do_execute_actions(dp, skb, key,
 				 acts->actions, acts->actions_len);
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index ac3f3df..9741354 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -102,8 +102,8 @@ struct datapath {
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
+	struct ovs_tunnel_info  *egress_tun_info;
 	struct vport		*input_vport;
-	struct ovs_key_ipv4_tunnel  *egress_tun_key;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 913bdc1..2924cb3 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -642,12 +642,12 @@ int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 	return key_extract(skb, key);
 }
 
-int ovs_flow_key_extract(struct ovs_key_ipv4_tunnel *tun_key,
+int ovs_flow_key_extract(struct ovs_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
 	/* Extract metadata from packet. */
-	if (tun_key)
-		memcpy(&key->tun_key, tun_key, sizeof(key->tun_key));
+	if (tun_info)
+		memcpy(&key->tun_key, &tun_info->tunnel, sizeof(key->tun_key));
 	else
 		memset(&key->tun_key, 0, sizeof(key->tun_key));
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 0f5db4e..fe5a71b 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -49,20 +49,24 @@ struct ovs_key_ipv4_tunnel {
 	u8   ipv4_ttl;
 } __packed __aligned(4); /* Minimize padding. */
 
-static inline void ovs_flow_tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
-					 const struct iphdr *iph, __be64 tun_id,
-					 __be16 tun_flags)
+struct ovs_tunnel_info {
+	struct ovs_key_ipv4_tunnel tunnel;
+};
+
+static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
+					  const struct iphdr *iph,
+					  __be64 tun_id, __be16 tun_flags)
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
+	memset((unsigned char *)&tun_info->tunnel + OVS_TUNNEL_KEY_SIZE, 0,
+	       sizeof(tun_info->tunnel) - OVS_TUNNEL_KEY_SIZE);
 }
 
 struct sw_flow_key {
@@ -190,8 +194,8 @@ void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key);
-int ovs_flow_key_extract(struct ovs_key_ipv4_tunnel *tun_key,
-			 struct sk_buff *skb, struct sw_flow_key *key);
+int ovs_flow_key_extract(struct ovs_tunnel_info *tun_info, struct sk_buff *skb,
+			 struct sw_flow_key *key);
 /* Extract key from packet coming from userspace. */
 int ovs_flow_key_extract_userspace(const struct nlattr *attr,
 				   struct sk_buff *skb,
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 22c855f..5d6194d 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1148,13 +1148,14 @@ out:
 	return  (struct nlattr *) ((unsigned char *)(*sfa) + next_offset);
 }
 
-static int add_action(struct sw_flow_actions **sfa, int attrtype, void *data, int len)
+static struct nlattr *__add_action(struct sw_flow_actions **sfa,
+				   int attrtype, void *data, int len)
 {
 	struct nlattr *a;
 
 	a = reserve_sfa_size(sfa, nla_attr_size(len));
 	if (IS_ERR(a))
-		return PTR_ERR(a);
+		return a;
 
 	a->nla_type = attrtype;
 	a->nla_len = nla_attr_size(len);
@@ -1163,6 +1164,18 @@ static int add_action(struct sw_flow_actions **sfa, int attrtype, void *data, in
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
 
@@ -1268,6 +1281,8 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 {
 	struct sw_flow_match match;
 	struct sw_flow_key key;
+	struct ovs_tunnel_info *tun_info;
+	struct nlattr *a;
 	int err, start;
 
 	ovs_match_init(&match, &key, NULL);
@@ -1279,8 +1294,14 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (start < 0)
 		return start;
 
-	err = add_action(sfa, OVS_KEY_ATTR_IPV4_TUNNEL, &match.key->tun_key,
-			sizeof(match.key->tun_key));
+	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
+			 sizeof(*tun_info));
+	if (IS_ERR(a))
+		return PTR_ERR(a);
+
+	tun_info = nla_data(a);
+	tun_info->tunnel = key.tun_key;
+
 	add_nested_action_end(*sfa, start);
 
 	return err;
@@ -1563,17 +1584,20 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
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
+					 nla_data(ovs_key));
 		if (err)
 			return err;
 		nla_nest_end(skb, start);
 		break;
+	}
 	default:
 		if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a), ovs_key))
 			return -EMSGSIZE;
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 309cca6..fe768bd 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -63,8 +63,10 @@ static __be16 filter_tnl_flags(__be16 flags)
 static struct sk_buff *__build_header(struct sk_buff *skb,
 				      int tunnel_hlen)
 {
-	const struct ovs_key_ipv4_tunnel *tun_key = OVS_CB(skb)->egress_tun_key;
 	struct tnl_ptk_info tpi;
+	const struct ovs_key_ipv4_tunnel *tun_key;
+
+	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
 
 	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
 	if (IS_ERR(skb))
@@ -92,7 +94,7 @@ static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
 static int gre_rcv(struct sk_buff *skb,
 		   const struct tnl_ptk_info *tpi)
 {
-	struct ovs_key_ipv4_tunnel tun_key;
+	struct ovs_tunnel_info tun_info;
 	struct ovs_net *ovs_net;
 	struct vport *vport;
 	__be64 key;
@@ -103,10 +105,10 @@ static int gre_rcv(struct sk_buff *skb,
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
 
@@ -137,12 +139,12 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	__be16 df;
 	int err;
 
-	if (unlikely(!OVS_CB(skb)->egress_tun_key)) {
+	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
 		err = -EINVAL;
 		goto error;
 	}
 
-	tun_key = OVS_CB(skb)->egress_tun_key;
+	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
 	/* Route lookup */
 	memset(&fl, 0, sizeof(fl));
 	fl.daddr = tun_key->ipv4_dst;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index f19539b..5fbff2c 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -58,7 +58,7 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 /* Called with rcu_read_lock and BH disabled. */
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 {
-	struct ovs_key_ipv4_tunnel tun_key;
+	struct ovs_tunnel_info tun_info;
 	struct vport *vport = vs->data;
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
@@ -147,12 +147,12 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	__be16 df;
 	int err;
 
-	if (unlikely(!OVS_CB(skb)->egress_tun_key)) {
+	if (unlikely(!OVS_CB(skb)->egress_tun_info)) {
 		err = -EINVAL;
 		goto error;
 	}
 
-	tun_key = OVS_CB(skb)->egress_tun_key;
+	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
 	/* Route lookup */
 	memset(&fl, 0, sizeof(fl));
 	fl.daddr = tun_key->ipv4_dst;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 5df8377..3e50ee8 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -432,7 +432,7 @@ u32 ovs_vport_find_upcall_portid(const struct vport *p, struct sk_buff *skb)
  * skb->data should point to the Ethernet header.
  */
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
-		       struct ovs_key_ipv4_tunnel *tun_key)
+		       struct ovs_tunnel_info *tun_info)
 {
 	struct pcpu_sw_netstats *stats;
 	struct sw_flow_key key;
@@ -445,9 +445,9 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	u64_stats_update_end(&stats->syncp);
 
 	OVS_CB(skb)->input_vport = vport;
-	OVS_CB(skb)->egress_tun_key = NULL;
+	OVS_CB(skb)->egress_tun_info = NULL;
 	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_key_extract(tun_key, skb, &key);
+	error = ovs_flow_key_extract(tun_info, skb, &key);
 	if (unlikely(error)) {
 		kfree_skb(skb);
 		return;
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 0efd62f..e28964a 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -207,7 +207,7 @@ static inline struct vport *vport_from_priv(void *priv)
 }
 
 void ovs_vport_receive(struct vport *, struct sk_buff *,
-		       struct ovs_key_ipv4_tunnel *);
+		       struct ovs_tunnel_info *);
 
 /* List of statically compiled vport implementations.  Don't forget to also
  * add yours to the list at the top of vport.c. */
-- 
1.7.9.5
