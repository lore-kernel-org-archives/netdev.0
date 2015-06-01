From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 01/14] ip_tunnel: Make ovs_tunnel_info and ovs_key_ipv4_tunnel generic
Date: Mon,  1 Jun 2015 16:27:25 +0200
Message-ID: <3caf01794c5f71b0c98bbb378241799d89607ed9.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50920 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbFAO1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:47 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the tunnel metadata data structures currently internal to
OVS and make them generic for use by all IP tunnels.

Both structures are kernel internal and will stay that way. Their
members are exposed to user space through individual Netlink
attributes by OVS. It will therefore be possible to extend/modify
these structures without affecting user ABI.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/ip_tunnels.h         | 63 +++++++++++++++++++++++++++++++++
 include/uapi/linux/openvswitch.h |  2 +-
 net/openvswitch/actions.c        |  2 +-
 net/openvswitch/datapath.h       |  5 +--
 net/openvswitch/flow.c           |  4 +--
 net/openvswitch/flow.h           | 76 ++--------------------------------------
 net/openvswitch/flow_netlink.c   | 16 ++++-----
 net/openvswitch/flow_netlink.h   |  2 +-
 net/openvswitch/vport-geneve.c   | 17 +++++----
 net/openvswitch/vport-gre.c      | 16 ++++-----
 net/openvswitch/vport-vxlan.c    | 18 +++++-----
 net/openvswitch/vport.c          | 30 ++++++++--------
 net/openvswitch/vport.h          | 12 +++----
 13 files changed, 128 insertions(+), 135 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index d8214cb..6b9d559 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -22,6 +22,28 @@
 /* Keep error state on tunnel for 30 sec */
 #define IPTUNNEL_ERR_TIMEO	(30*HZ)
 
+/* Used to memset ip_tunnel padding. */
+#define IP_TUNNEL_KEY_SIZE					\
+	(offsetof(struct ip_tunnel_key, tp_dst) +		\
+	 FIELD_SIZEOF(struct ip_tunnel_key, tp_dst))
+
+struct ip_tunnel_key {
+	__be64			tun_id;
+	__be32			ipv4_src;
+	__be32			ipv4_dst;
+	__be16			tun_flags;
+	__u8			ipv4_tos;
+	__u8			ipv4_ttl;
+	__be16			tp_src;
+	__be16			tp_dst;
+} __packed __aligned(4); /* Minimize padding. */
+
+struct ip_tunnel_info {
+	struct ip_tunnel_key	key;
+	const void		*options;
+	u8			options_len;
+};
+
 /* 6rd prefix/relay information */
 #ifdef CONFIG_IPV6_SIT_6RD
 struct ip_tunnel_6rd_parm {
@@ -136,6 +158,47 @@ int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *op,
 int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
 			    unsigned int num);
 
+static inline void __ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
+					 __be32 saddr, __be32 daddr,
+					 u8 tos, u8 ttl,
+					 __be16 tp_src, __be16 tp_dst,
+					 __be64 tun_id, __be16 tun_flags,
+					 const void *opts, u8 opts_len)
+{
+	tun_info->key.tun_id = tun_id;
+	tun_info->key.ipv4_src = saddr;
+	tun_info->key.ipv4_dst = daddr;
+	tun_info->key.ipv4_tos = tos;
+	tun_info->key.ipv4_ttl = ttl;
+	tun_info->key.tun_flags = tun_flags;
+
+	/* For the tunnel types on the top of IPsec, the tp_src and tp_dst of
+	 * the upper tunnel are used.
+	 * E.g: GRE over IPSEC, the tp_src and tp_port are zero.
+	 */
+	tun_info->key.tp_src = tp_src;
+	tun_info->key.tp_dst = tp_dst;
+
+	/* Clear struct padding. */
+	if (sizeof(tun_info->key) != IP_TUNNEL_KEY_SIZE)
+		memset((unsigned char *)&tun_info->key + IP_TUNNEL_KEY_SIZE,
+		       0, sizeof(tun_info->key) - IP_TUNNEL_KEY_SIZE);
+
+	tun_info->options = opts;
+	tun_info->options_len = opts_len;
+}
+
+static inline void ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
+				       const struct iphdr *iph,
+				       __be16 tp_src, __be16 tp_dst,
+				       __be64 tun_id, __be16 tun_flags,
+				       const void *opts, u8 opts_len)
+{
+	__ip_tunnel_info_init(tun_info, iph->saddr, iph->daddr,
+			      iph->tos, iph->ttl, tp_src, tp_dst,
+			      tun_id, tun_flags, opts, opts_len);
+}
+
 #ifdef CONFIG_INET
 
 int ip_tunnel_init(struct net_device *dev);
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index bbd49a0..fffe317 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -319,7 +319,7 @@ enum ovs_key_attr {
 				 * the accepted length of the array. */
 
 #ifdef __KERNEL__
-	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ovs_tunnel_info */
+	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
 #endif
 	__OVS_KEY_ATTR_MAX
 };
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b491c1c..34cad57 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -610,7 +610,7 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			    struct sw_flow_key *key, const struct nlattr *attr)
 {
-	struct ovs_tunnel_info info;
+	struct ip_tunnel_info info;
 	struct dp_upcall_info upcall;
 	const struct nlattr *a;
 	int rem;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 4ec4a48..b93fdc8 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -25,6 +25,7 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/u64_stats_sync.h>
+#include <net/ip_tunnels.h>
 
 #include "flow.h"
 #include "flow_table.h"
@@ -98,7 +99,7 @@ struct datapath {
  * when a packet is received by OVS.
  */
 struct ovs_skb_cb {
-	struct ovs_tunnel_info  *egress_tun_info;
+	struct ip_tunnel_info  *egress_tun_info;
 	struct vport		*input_vport;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
@@ -114,7 +115,7 @@ struct ovs_skb_cb {
  * @egress_tun_info: If nonnull, becomes %OVS_PACKET_ATTR_EGRESS_TUN_KEY.
  */
 struct dp_upcall_info {
-	const struct ovs_tunnel_info *egress_tun_info;
+	const struct ip_tunnel_info *egress_tun_info;
 	const struct nlattr *userdata;
 	u32 portid;
 	u8 cmd;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index bc7b0ab..8db22ef 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -682,12 +682,12 @@ int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 	return key_extract(skb, key);
 }
 
-int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
+int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
 	/* Extract metadata from packet. */
 	if (tun_info) {
-		memcpy(&key->tun_key, &tun_info->tunnel, sizeof(key->tun_key));
+		memcpy(&key->tun_key, &tun_info->key, sizeof(key->tun_key));
 
 		if (tun_info->options) {
 			BUILD_BUG_ON((1 << (sizeof(tun_info->options_len) *
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a076e44..cadc6c5 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -32,31 +32,10 @@
 #include <linux/time.h>
 #include <linux/flex_array.h>
 #include <net/inet_ecn.h>
+#include <net/ip_tunnels.h>
 
 struct sk_buff;
 
-/* Used to memset ovs_key_ipv4_tunnel padding. */
-#define OVS_TUNNEL_KEY_SIZE					\
-	(offsetof(struct ovs_key_ipv4_tunnel, tp_dst) +		\
-	 FIELD_SIZEOF(struct ovs_key_ipv4_tunnel, tp_dst))
-
-struct ovs_key_ipv4_tunnel {
-	__be64 tun_id;
-	__be32 ipv4_src;
-	__be32 ipv4_dst;
-	__be16 tun_flags;
-	u8   ipv4_tos;
-	u8   ipv4_ttl;
-	__be16 tp_src;
-	__be16 tp_dst;
-} __packed __aligned(4); /* Minimize padding. */
-
-struct ovs_tunnel_info {
-	struct ovs_key_ipv4_tunnel tunnel;
-	const void *options;
-	u8 options_len;
-};
-
 /* Store options at the end of the array if they are less than the
  * maximum size. This allows us to get the benefits of variable length
  * matching for small options.
@@ -66,55 +45,6 @@ struct ovs_tunnel_info {
 #define TUN_METADATA_OPTS(flow_key, opt_len) \
 	((void *)((flow_key)->tun_opts + TUN_METADATA_OFFSET(opt_len)))
 
-static inline void __ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
-					    __be32 saddr, __be32 daddr,
-					    u8 tos, u8 ttl,
-					    __be16 tp_src,
-					    __be16 tp_dst,
-					    __be64 tun_id,
-					    __be16 tun_flags,
-					    const void *opts,
-					    u8 opts_len)
-{
-	tun_info->tunnel.tun_id = tun_id;
-	tun_info->tunnel.ipv4_src = saddr;
-	tun_info->tunnel.ipv4_dst = daddr;
-	tun_info->tunnel.ipv4_tos = tos;
-	tun_info->tunnel.ipv4_ttl = ttl;
-	tun_info->tunnel.tun_flags = tun_flags;
-
-	/* For the tunnel types on the top of IPsec, the tp_src and tp_dst of
-	 * the upper tunnel are used.
-	 * E.g: GRE over IPSEC, the tp_src and tp_port are zero.
-	 */
-	tun_info->tunnel.tp_src = tp_src;
-	tun_info->tunnel.tp_dst = tp_dst;
-
-	/* Clear struct padding. */
-	if (sizeof(tun_info->tunnel) != OVS_TUNNEL_KEY_SIZE)
-		memset((unsigned char *)&tun_info->tunnel + OVS_TUNNEL_KEY_SIZE,
-		       0, sizeof(tun_info->tunnel) - OVS_TUNNEL_KEY_SIZE);
-
-	tun_info->options = opts;
-	tun_info->options_len = opts_len;
-}
-
-static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
-					  const struct iphdr *iph,
-					  __be16 tp_src,
-					  __be16 tp_dst,
-					  __be64 tun_id,
-					  __be16 tun_flags,
-					  const void *opts,
-					  u8 opts_len)
-{
-	__ovs_flow_tun_info_init(tun_info, iph->saddr, iph->daddr,
-				 iph->tos, iph->ttl,
-				 tp_src, tp_dst,
-				 tun_id, tun_flags,
-				 opts, opts_len);
-}
-
 #define OVS_SW_FLOW_KEY_METADATA_SIZE			\
 	(offsetof(struct sw_flow_key, recirc_id) +	\
 	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
@@ -122,7 +52,7 @@ static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 struct sw_flow_key {
 	u8 tun_opts[255];
 	u8 tun_opts_len;
-	struct ovs_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
+	struct ip_tunnel_key tun_key;	/* Encapsulating tunnel key. */
 	struct {
 		u32	priority;	/* Packet QoS priority. */
 		u32	skb_mark;	/* SKB mark. */
@@ -273,7 +203,7 @@ void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key);
-int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
+int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			 struct sk_buff *skb,
 			 struct sw_flow_key *key);
 /* Extract key from packet coming from userspace. */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 624e41c..ecfa530 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -641,7 +641,7 @@ static int vxlan_opt_to_nlattr(struct sk_buff *skb,
 }
 
 static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
-				const struct ovs_key_ipv4_tunnel *output,
+				const struct ip_tunnel_key *output,
 				const void *tun_opts, int swkey_tun_opts_len)
 {
 	if (output->tun_flags & TUNNEL_KEY &&
@@ -689,7 +689,7 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 }
 
 static int ipv4_tun_to_nlattr(struct sk_buff *skb,
-			      const struct ovs_key_ipv4_tunnel *output,
+			      const struct ip_tunnel_key *output,
 			      const void *tun_opts, int swkey_tun_opts_len)
 {
 	struct nlattr *nla;
@@ -708,9 +708,9 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 }
 
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *skb,
-				  const struct ovs_tunnel_info *egress_tun_info)
+				  const struct ip_tunnel_info *egress_tun_info)
 {
-	return __ipv4_tun_to_nlattr(skb, &egress_tun_info->tunnel,
+	return __ipv4_tun_to_nlattr(skb, &egress_tun_info->key,
 				    egress_tun_info->options,
 				    egress_tun_info->options_len);
 }
@@ -1746,7 +1746,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 {
 	struct sw_flow_match match;
 	struct sw_flow_key key;
-	struct ovs_tunnel_info *tun_info;
+	struct ip_tunnel_info *tun_info;
 	struct nlattr *a;
 	int err = 0, start, opts_type;
 
@@ -1777,7 +1777,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 		return PTR_ERR(a);
 
 	tun_info = nla_data(a);
-	tun_info->tunnel = key.tun_key;
+	tun_info->key = key.tun_key;
 	tun_info->options_len = key.tun_opts_len;
 
 	if (tun_info->options_len) {
@@ -2227,13 +2227,13 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 
 	switch (key_type) {
 	case OVS_KEY_ATTR_TUNNEL_INFO: {
-		struct ovs_tunnel_info *tun_info = nla_data(ovs_key);
+		struct ip_tunnel_info *tun_info = nla_data(ovs_key);
 
 		start = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
 		if (!start)
 			return -EMSGSIZE;
 
-		err = ipv4_tun_to_nlattr(skb, &tun_info->tunnel,
+		err = ipv4_tun_to_nlattr(skb, &tun_info->key,
 					 tun_info->options_len ?
 						tun_info->options : NULL,
 					 tun_info->options_len);
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 5c3d75b..ec53eb6 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -55,7 +55,7 @@ int ovs_nla_put_mask(const struct sw_flow *flow, struct sk_buff *skb);
 int ovs_nla_get_match(struct sw_flow_match *, const struct nlattr *key,
 		      const struct nlattr *mask, bool log);
 int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
-				  const struct ovs_tunnel_info *);
+				  const struct ip_tunnel_info *);
 
 bool ovs_nla_get_ufid(struct sw_flow_id *, const struct nlattr *, bool log);
 int ovs_nla_get_identifier(struct sw_flow_id *sfid, const struct nlattr *ufid,
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 208c576..1da3a14 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -77,7 +77,7 @@ static void geneve_rcv(struct geneve_sock *gs, struct sk_buff *skb)
 	struct vport *vport = gs->rcv_data;
 	struct genevehdr *geneveh = geneve_hdr(skb);
 	int opts_len;
-	struct ovs_tunnel_info tun_info;
+	struct ip_tunnel_info tun_info;
 	__be64 key;
 	__be16 flags;
 
@@ -90,10 +90,9 @@ static void geneve_rcv(struct geneve_sock *gs, struct sk_buff *skb)
 
 	key = vni_to_tunnel_id(geneveh->vni);
 
-	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb),
-			       udp_hdr(skb)->source, udp_hdr(skb)->dest,
-			       key, flags,
-			       geneveh->options, opts_len);
+	ip_tunnel_info_init(&tun_info, ip_hdr(skb),
+			    udp_hdr(skb)->source, udp_hdr(skb)->dest,
+			    key, flags, geneveh->options, opts_len);
 
 	ovs_vport_receive(vport, skb, &tun_info);
 }
@@ -165,8 +164,8 @@ error:
 
 static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
-	const struct ovs_key_ipv4_tunnel *tun_key;
-	struct ovs_tunnel_info *tun_info;
+	const struct ip_tunnel_key *tun_key;
+	struct ip_tunnel_info *tun_info;
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct geneve_port *geneve_port = geneve_vport(vport);
 	__be16 dport = inet_sk(geneve_port->gs->sock->sk)->inet_sport;
@@ -183,7 +182,7 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 		goto error;
 	}
 
-	tun_key = &tun_info->tunnel;
+	tun_key = &tun_info->key;
 	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
@@ -225,7 +224,7 @@ static const char *geneve_get_name(const struct vport *vport)
 }
 
 static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				      struct ovs_tunnel_info *egress_tun_info)
+				      struct ip_tunnel_info *egress_tun_info)
 {
 	struct geneve_port *geneve_port = geneve_vport(vport);
 	struct net *net = ovs_dp_get_net(vport->dp);
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index f17ac96..b87656c 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -67,9 +67,9 @@ static struct sk_buff *__build_header(struct sk_buff *skb,
 				      int tunnel_hlen)
 {
 	struct tnl_ptk_info tpi;
-	const struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ip_tunnel_key *tun_key;
 
-	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
+	tun_key = &OVS_CB(skb)->egress_tun_info->key;
 
 	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
 	if (IS_ERR(skb))
@@ -97,7 +97,7 @@ static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
 static int gre_rcv(struct sk_buff *skb,
 		   const struct tnl_ptk_info *tpi)
 {
-	struct ovs_tunnel_info tun_info;
+	struct ip_tunnel_info tun_info;
 	struct ovs_net *ovs_net;
 	struct vport *vport;
 	__be64 key;
@@ -108,8 +108,8 @@ static int gre_rcv(struct sk_buff *skb,
 		return PACKET_REJECT;
 
 	key = key_to_tunnel_id(tpi->key, tpi->seq);
-	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), 0, 0, key,
-			       filter_tnl_flags(tpi->flags), NULL, 0);
+	ip_tunnel_info_init(&tun_info, ip_hdr(skb), 0, 0, key,
+			    filter_tnl_flags(tpi->flags), NULL, 0);
 
 	ovs_vport_receive(vport, skb, &tun_info);
 	return PACKET_RCVD;
@@ -134,7 +134,7 @@ static int gre_err(struct sk_buff *skb, u32 info,
 static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
-	const struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ip_tunnel_key *tun_key;
 	struct flowi4 fl;
 	struct rtable *rt;
 	int min_headroom;
@@ -147,7 +147,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 		goto err_free_skb;
 	}
 
-	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
+	tun_key = &OVS_CB(skb)->egress_tun_info->key;
 	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_GRE);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
@@ -277,7 +277,7 @@ static void gre_tnl_destroy(struct vport *vport)
 }
 
 static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				   struct ovs_tunnel_info *egress_tun_info)
+				   struct ip_tunnel_info *egress_tun_info)
 {
 	return ovs_tunnel_get_egress_info(egress_tun_info,
 					  ovs_dp_get_net(vport->dp),
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 6d39766..6f7986f 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -64,7 +64,7 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 		      struct vxlan_metadata *md)
 {
-	struct ovs_tunnel_info tun_info;
+	struct ip_tunnel_info tun_info;
 	struct vxlan_port *vxlan_port;
 	struct vport *vport = vs->data;
 	struct iphdr *iph;
@@ -82,9 +82,9 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	/* Save outer tunnel values */
 	iph = ip_hdr(skb);
 	key = cpu_to_be64(ntohl(md->vni) >> 8);
-	ovs_flow_tun_info_init(&tun_info, iph,
-			       udp_hdr(skb)->source, udp_hdr(skb)->dest,
-			       key, flags, &opts, sizeof(opts));
+	ip_tunnel_info_init(&tun_info, iph,
+			    udp_hdr(skb)->source, udp_hdr(skb)->dest,
+			    key, flags, &opts, sizeof(opts));
 
 	ovs_vport_receive(vport, skb, &tun_info);
 }
@@ -205,13 +205,13 @@ error:
 
 static int vxlan_ext_gbp(struct sk_buff *skb)
 {
-	const struct ovs_tunnel_info *tun_info;
+	const struct ip_tunnel_info *tun_info;
 	const struct ovs_vxlan_opts *opts;
 
 	tun_info = OVS_CB(skb)->egress_tun_info;
 	opts = tun_info->options;
 
-	if (tun_info->tunnel.tun_flags & TUNNEL_VXLAN_OPT &&
+	if (tun_info->key.tun_flags & TUNNEL_VXLAN_OPT &&
 	    tun_info->options_len >= sizeof(*opts))
 		return opts->gbp;
 	else
@@ -224,7 +224,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
 	struct sock *sk = vxlan_port->vs->sock->sk;
 	__be16 dst_port = inet_sk(sk)->inet_sport;
-	const struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ip_tunnel_key *tun_key;
 	struct vxlan_metadata md = {0};
 	struct rtable *rt;
 	struct flowi4 fl;
@@ -238,7 +238,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 		goto error;
 	}
 
-	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
+	tun_key = &OVS_CB(skb)->egress_tun_info->key;
 	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
@@ -269,7 +269,7 @@ error:
 }
 
 static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				     struct ovs_tunnel_info *egress_tun_info)
+				     struct ip_tunnel_info *egress_tun_info)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 067a3ff..af23ba0 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -469,7 +469,7 @@ u32 ovs_vport_find_upcall_portid(const struct vport *vport, struct sk_buff *skb)
  * skb->data should point to the Ethernet header.
  */
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
-		       const struct ovs_tunnel_info *tun_info)
+		       const struct ip_tunnel_info *tun_info)
 {
 	struct pcpu_sw_netstats *stats;
 	struct sw_flow_key key;
@@ -572,22 +572,22 @@ void ovs_vport_deferred_free(struct vport *vport)
 }
 EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
 
-int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
+int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 			       struct net *net,
-			       const struct ovs_tunnel_info *tun_info,
+			       const struct ip_tunnel_info *tun_info,
 			       u8 ipproto,
 			       u32 skb_mark,
 			       __be16 tp_src,
 			       __be16 tp_dst)
 {
-	const struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ip_tunnel_key *tun_key;
 	struct rtable *rt;
 	struct flowi4 fl;
 
 	if (unlikely(!tun_info))
 		return -EINVAL;
 
-	tun_key = &tun_info->tunnel;
+	tun_key = &tun_info->key;
 
 	/* Route lookup to get srouce IP address.
 	 * The process may need to be changed if the corresponding process
@@ -602,22 +602,22 @@ int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
 	/* Generate egress_tun_info based on tun_info,
 	 * saddr, tp_src and tp_dst
 	 */
-	__ovs_flow_tun_info_init(egress_tun_info,
-				 fl.saddr, tun_key->ipv4_dst,
-				 tun_key->ipv4_tos,
-				 tun_key->ipv4_ttl,
-				 tp_src, tp_dst,
-				 tun_key->tun_id,
-				 tun_key->tun_flags,
-				 tun_info->options,
-				 tun_info->options_len);
+	__ip_tunnel_info_init(egress_tun_info,
+			      fl.saddr, tun_key->ipv4_dst,
+			      tun_key->ipv4_tos,
+			      tun_key->ipv4_ttl,
+			      tp_src, tp_dst,
+			      tun_key->tun_id,
+			      tun_key->tun_flags,
+			      tun_info->options,
+			      tun_info->options_len);
 
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ovs_tunnel_get_egress_info);
 
 int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				  struct ovs_tunnel_info *info)
+				  struct ip_tunnel_info *info)
 {
 	/* get_egress_tun_info() is only implemented on tunnel ports. */
 	if (unlikely(!vport->ops->get_egress_tun_info))
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index bc85331..4750fb6 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -58,15 +58,15 @@ u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
 int ovs_vport_send(struct vport *, struct sk_buff *);
 
-int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
+int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 			       struct net *net,
-			       const struct ovs_tunnel_info *tun_info,
+			       const struct ip_tunnel_info *tun_info,
 			       u8 ipproto,
 			       u32 skb_mark,
 			       __be16 tp_src,
 			       __be16 tp_dst);
 int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
-				  struct ovs_tunnel_info *info);
+				  struct ip_tunnel_info *info);
 
 /* The following definitions are for implementers of vport devices: */
 
@@ -176,7 +176,7 @@ struct vport_ops {
 
 	int (*send)(struct vport *, struct sk_buff *);
 	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
-				   struct ovs_tunnel_info *);
+				   struct ip_tunnel_info *);
 
 	struct module *owner;
 	struct list_head list;
@@ -226,7 +226,7 @@ static inline struct vport *vport_from_priv(void *priv)
 }
 
 void ovs_vport_receive(struct vport *, struct sk_buff *,
-		       const struct ovs_tunnel_info *);
+		       const struct ip_tunnel_info *);
 
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
@@ -239,7 +239,7 @@ int ovs_vport_ops_register(struct vport_ops *ops);
 void ovs_vport_ops_unregister(struct vport_ops *ops);
 
 static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
-						     const struct ovs_key_ipv4_tunnel *key,
+						     const struct ip_tunnel_key *key,
 						     u32 mark,
 						     struct flowi4 *fl,
 						     u8 protocol)
-- 
2.3.5
