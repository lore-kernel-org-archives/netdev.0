From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/4] openvswitch: split flow structures into ovs specific and generic ones
Date: Wed, 19 Mar 2014 16:33:49 +0100
Message-ID: <1395243232-32630-2-git-send-email-jiri@resnulli.us>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:47980 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965001AbaCSPeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 11:34:01 -0400
Received: by mail-ee0-f49.google.com with SMTP id c41so6673184eek.22
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:33:59 -0700 (PDT)
In-Reply-To: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After this, flow related structures can be used in other code.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/sw_flow.h        | 105 +++++++++++++++++++++++++++++++++++
 net/openvswitch/datapath.c     |  45 +++++++--------
 net/openvswitch/datapath.h     |   4 +-
 net/openvswitch/flow.c         |  12 ++--
 net/openvswitch/flow.h         | 123 +++++++++--------------------------------
 net/openvswitch/flow_netlink.c |  24 ++++----
 net/openvswitch/flow_netlink.h |   4 +-
 net/openvswitch/flow_table.c   | 100 +++++++++++++++++----------------
 net/openvswitch/flow_table.h   |  18 +++---
 net/openvswitch/vport-gre.c    |   4 +-
 net/openvswitch/vport-vxlan.c  |   2 +-
 net/openvswitch/vport.c        |   2 +-
 net/openvswitch/vport.h        |   2 +-
 13 files changed, 241 insertions(+), 204 deletions(-)
 create mode 100644 include/linux/sw_flow.h

diff --git a/include/linux/sw_flow.h b/include/linux/sw_flow.h
new file mode 100644
index 0000000..e7b1ef9
--- /dev/null
+++ b/include/linux/sw_flow.h
@@ -0,0 +1,105 @@
+/*
+ * Copyright (c) 2007-2012 Nicira, Inc.
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef _LINUX_SW_FLOW_H_
+#define _LINUX_SW_FLOW_H_
+
+struct sw_flow_key_ipv4_tunnel {
+	__be64 tun_id;
+	__be32 ipv4_src;
+	__be32 ipv4_dst;
+	__be16 tun_flags;
+	u8   ipv4_tos;
+	u8   ipv4_ttl;
+};
+
+struct sw_flow_key {
+	struct sw_flow_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
+	struct {
+		u32	priority;	/* Packet QoS priority. */
+		u32	skb_mark;	/* SKB mark. */
+		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
+	} phy;
+	struct {
+		u8     src[ETH_ALEN];	/* Ethernet source address. */
+		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
+		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+		__be16 type;		/* Ethernet frame type. */
+	} eth;
+	struct {
+		u8     proto;		/* IP protocol or lower 8 bits of ARP opcode. */
+		u8     tos;		/* IP ToS. */
+		u8     ttl;		/* IP TTL/hop limit. */
+		u8     frag;		/* One of OVS_FRAG_TYPE_*. */
+	} ip;
+	union {
+		struct {
+			struct {
+				__be32 src;	/* IP source address. */
+				__be32 dst;	/* IP destination address. */
+			} addr;
+			union {
+				struct {
+					__be16 src;		/* TCP/UDP/SCTP source port. */
+					__be16 dst;		/* TCP/UDP/SCTP destination port. */
+					__be16 flags;		/* TCP flags. */
+				} tp;
+				struct {
+					u8 sha[ETH_ALEN];	/* ARP source hardware address. */
+					u8 tha[ETH_ALEN];	/* ARP target hardware address. */
+				} arp;
+			};
+		} ipv4;
+		struct {
+			struct {
+				struct in6_addr src;	/* IPv6 source address. */
+				struct in6_addr dst;	/* IPv6 destination address. */
+			} addr;
+			__be32 label;			/* IPv6 flow label. */
+			struct {
+				__be16 src;		/* TCP/UDP/SCTP source port. */
+				__be16 dst;		/* TCP/UDP/SCTP destination port. */
+				__be16 flags;		/* TCP flags. */
+			} tp;
+			struct {
+				struct in6_addr target;	/* ND target address. */
+				u8 sll[ETH_ALEN];	/* ND source link layer address. */
+				u8 tll[ETH_ALEN];	/* ND target link layer address. */
+			} nd;
+		} ipv6;
+	};
+} __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
+
+struct sw_flow_key_range {
+	unsigned short int start;
+	unsigned short int end;
+};
+
+struct sw_flow_mask {
+	struct sw_flow_key_range range;
+	struct sw_flow_key key;
+};
+
+struct sw_flow {
+	struct sw_flow_key key;
+	struct sw_flow_key unmasked_key;
+	struct sw_flow_mask *mask;
+};
+
+#endif /* _LINUX_SW_FLOW_H_ */
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index c53fe0c..7906fe0 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -216,7 +216,7 @@ void ovs_dp_detach_port(struct vport *p)
 void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 {
 	struct datapath *dp = p->dp;
-	struct sw_flow *flow;
+	struct ovs_flow *flow;
 	struct dp_stats_percpu *stats;
 	struct sw_flow_key key;
 	u64 *stats_counter;
@@ -488,7 +488,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct nlattr **a = info->attrs;
 	struct sw_flow_actions *acts;
 	struct sk_buff *packet;
-	struct sw_flow *flow;
+	struct ovs_flow *flow;
 	struct datapath *dp;
 	struct ethhdr *eth;
 	int len;
@@ -525,11 +525,11 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(flow))
 		goto err_kfree_skb;
 
-	err = ovs_flow_extract(packet, -1, &flow->key);
+	err = ovs_flow_extract(packet, -1, &flow->flow.key);
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_nla_get_flow_metadata(flow, a[OVS_PACKET_ATTR_KEY]);
+	err = ovs_nla_get_flow_metadata(&flow->flow, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
 	acts = ovs_nla_alloc_flow_actions(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
@@ -538,15 +538,15 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_flow_free;
 
 	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
-				   &flow->key, 0, &acts);
+				   &flow->flow.key, 0, &acts);
 	rcu_assign_pointer(flow->sf_acts, acts);
 	if (err)
 		goto err_flow_free;
 
 	OVS_CB(packet)->flow = flow;
-	OVS_CB(packet)->pkt_key = &flow->key;
-	packet->priority = flow->key.phy.priority;
-	packet->mark = flow->key.phy.skb_mark;
+	OVS_CB(packet)->pkt_key = &flow->flow.key;
+	packet->priority = flow->flow.key.phy.priority;
+	packet->mark = flow->flow.key.phy.skb_mark;
 
 	rcu_read_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
@@ -649,7 +649,7 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 }
 
 /* Called with ovs_mutex. */
-static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
+static int ovs_flow_cmd_fill_info(struct ovs_flow *flow, struct datapath *dp,
 				  struct sk_buff *skb, u32 portid,
 				  u32 seq, u32 flags, u8 cmd)
 {
@@ -673,7 +673,8 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	if (!nla)
 		goto nla_put_failure;
 
-	err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb);
+	err = ovs_nla_put_flow(&flow->flow.unmasked_key,
+			       &flow->flow.unmasked_key, skb);
 	if (err)
 		goto error;
 	nla_nest_end(skb, nla);
@@ -682,7 +683,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	if (!nla)
 		goto nla_put_failure;
 
-	err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb);
+	err = ovs_nla_put_flow(&flow->flow.key, &flow->flow.mask->key, skb);
 	if (err)
 		goto error;
 
@@ -739,7 +740,7 @@ error:
 	return err;
 }
 
-static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow,
+static struct sk_buff *ovs_flow_cmd_alloc_info(struct ovs_flow *flow,
 					       struct genl_info *info)
 {
 	size_t len;
@@ -749,7 +750,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow,
 	return genlmsg_new_unicast(len, info, GFP_KERNEL);
 }
 
-static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
+static struct sk_buff *ovs_flow_cmd_build_info(struct ovs_flow *flow,
 					       struct datapath *dp,
 					       struct genl_info *info,
 					       u8 cmd)
@@ -772,12 +773,12 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key, masked_key;
-	struct sw_flow *flow = NULL;
+	struct ovs_flow *flow = NULL;
 	struct sw_flow_mask mask;
 	struct sk_buff *reply;
 	struct datapath *dp;
 	struct sw_flow_actions *acts = NULL;
-	struct sw_flow_match match;
+	struct ovs_flow_match match;
 	bool exact_5tuple;
 	int error;
 
@@ -832,8 +833,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			goto err_unlock_ovs;
 		}
 
-		flow->key = masked_key;
-		flow->unmasked_key = key;
+		flow->flow.key = masked_key;
+		flow->flow.unmasked_key = key;
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		/* Put flow in bucket. */
@@ -899,9 +900,9 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
 	struct sk_buff *reply;
-	struct sw_flow *flow;
+	struct ovs_flow *flow;
 	struct datapath *dp;
-	struct sw_flow_match match;
+	struct ovs_flow_match match;
 	int err;
 
 	if (!a[OVS_FLOW_ATTR_KEY]) {
@@ -946,9 +947,9 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
 	struct sk_buff *reply;
-	struct sw_flow *flow;
+	struct ovs_flow *flow;
 	struct datapath *dp;
-	struct sw_flow_match match;
+	struct ovs_flow_match match;
 	int err;
 
 	ovs_lock();
@@ -1011,7 +1012,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	ti = rcu_dereference(dp->table.ti);
 	for (;;) {
-		struct sw_flow *flow;
+		struct ovs_flow *flow;
 		u32 bucket, obj;
 
 		bucket = cb->args[0];
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 0531738..5388cac 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -100,9 +100,9 @@ struct datapath {
  * packet is not being tunneled.
  */
 struct ovs_skb_cb {
-	struct sw_flow		*flow;
+	struct ovs_flow		*flow;
 	struct sw_flow_key	*pkt_key;
-	struct ovs_key_ipv4_tunnel  *tun_key;
+	struct sw_flow_key_ipv4_tunnel  *tun_key;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 16f4b46..52e4466 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -61,7 +61,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 
 #define TCP_FLAGS_BE16(tp) (*(__be16 *)&tcp_flag_word(tp) & htons(0x0FFF))
 
-void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb)
+void ovs_flow_stats_update(struct ovs_flow *flow, struct sk_buff *skb)
 {
 	struct flow_stats *stats;
 	__be16 tcp_flags = 0;
@@ -71,9 +71,9 @@ void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb)
 	else
 		stats = this_cpu_ptr(flow->stats.cpu_stats);
 
-	if ((flow->key.eth.type == htons(ETH_P_IP) ||
-	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
-	    flow->key.ip.proto == IPPROTO_TCP &&
+	if ((flow->flow.key.eth.type == htons(ETH_P_IP) ||
+	     flow->flow.key.eth.type == htons(ETH_P_IPV6)) &&
+	    flow->flow.key.ip.proto == IPPROTO_TCP &&
 	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
 		tcp_flags = TCP_FLAGS_BE16(tcp_hdr(skb));
 	}
@@ -99,7 +99,7 @@ static void stats_read(struct flow_stats *stats,
 	spin_unlock(&stats->lock);
 }
 
-void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *ovs_stats,
+void ovs_flow_stats_get(struct ovs_flow *flow, struct ovs_flow_stats *ovs_stats,
 			unsigned long *used, __be16 *tcp_flags)
 {
 	int cpu, cur_cpu;
@@ -138,7 +138,7 @@ static void stats_reset(struct flow_stats *stats)
 	spin_unlock(&stats->lock);
 }
 
-void ovs_flow_stats_clear(struct sw_flow *flow)
+void ovs_flow_stats_clear(struct ovs_flow *flow)
 {
 	int cpu, cur_cpu;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 2d770e2..1ece896 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -32,24 +32,16 @@
 #include <linux/time.h>
 #include <linux/flex_array.h>
 #include <net/inet_ecn.h>
+#include <linux/sw_flow.h>
 
 struct sk_buff;
 
-/* Used to memset ovs_key_ipv4_tunnel padding. */
+/* Used to memset sw_flow_key_ipv4_tunnel padding. */
 #define OVS_TUNNEL_KEY_SIZE					\
-	(offsetof(struct ovs_key_ipv4_tunnel, ipv4_ttl) +	\
-	FIELD_SIZEOF(struct ovs_key_ipv4_tunnel, ipv4_ttl))
-
-struct ovs_key_ipv4_tunnel {
-	__be64 tun_id;
-	__be32 ipv4_src;
-	__be32 ipv4_dst;
-	__be16 tun_flags;
-	u8   ipv4_tos;
-	u8   ipv4_ttl;
-};
+	(offsetof(struct sw_flow_key_ipv4_tunnel, ipv4_ttl) +	\
+	FIELD_SIZEOF(struct sw_flow_key_ipv4_tunnel, ipv4_ttl))
 
-static inline void ovs_flow_tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
+static inline void ovs_flow_tun_key_init(struct sw_flow_key_ipv4_tunnel *tun_key,
 					 const struct iphdr *iph, __be64 tun_id,
 					 __be16 tun_flags)
 {
@@ -65,77 +57,28 @@ static inline void ovs_flow_tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
 	       sizeof(*tun_key) - OVS_TUNNEL_KEY_SIZE);
 }
 
-struct sw_flow_key {
-	struct ovs_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
-	struct {
-		u32	priority;	/* Packet QoS priority. */
-		u32	skb_mark;	/* SKB mark. */
-		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
-	} phy;
-	struct {
-		u8     src[ETH_ALEN];	/* Ethernet source address. */
-		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
-		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
-		__be16 type;		/* Ethernet frame type. */
-	} eth;
-	struct {
-		u8     proto;		/* IP protocol or lower 8 bits of ARP opcode. */
-		u8     tos;		/* IP ToS. */
-		u8     ttl;		/* IP TTL/hop limit. */
-		u8     frag;		/* One of OVS_FRAG_TYPE_*. */
-	} ip;
-	union {
-		struct {
-			struct {
-				__be32 src;	/* IP source address. */
-				__be32 dst;	/* IP destination address. */
-			} addr;
-			union {
-				struct {
-					__be16 src;		/* TCP/UDP/SCTP source port. */
-					__be16 dst;		/* TCP/UDP/SCTP destination port. */
-					__be16 flags;		/* TCP flags. */
-				} tp;
-				struct {
-					u8 sha[ETH_ALEN];	/* ARP source hardware address. */
-					u8 tha[ETH_ALEN];	/* ARP target hardware address. */
-				} arp;
-			};
-		} ipv4;
-		struct {
-			struct {
-				struct in6_addr src;	/* IPv6 source address. */
-				struct in6_addr dst;	/* IPv6 destination address. */
-			} addr;
-			__be32 label;			/* IPv6 flow label. */
-			struct {
-				__be16 src;		/* TCP/UDP/SCTP source port. */
-				__be16 dst;		/* TCP/UDP/SCTP destination port. */
-				__be16 flags;		/* TCP flags. */
-			} tp;
-			struct {
-				struct in6_addr target;	/* ND target address. */
-				u8 sll[ETH_ALEN];	/* ND source link layer address. */
-				u8 tll[ETH_ALEN];	/* ND target link layer address. */
-			} nd;
-		} ipv6;
-	};
-} __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
+struct arp_eth_header {
+	__be16      ar_hrd;	/* format of hardware address   */
+	__be16      ar_pro;	/* format of protocol address   */
+	unsigned char   ar_hln;	/* length of hardware address   */
+	unsigned char   ar_pln;	/* length of protocol address   */
+	__be16      ar_op;	/* ARP opcode (command)     */
 
-struct sw_flow_key_range {
-	unsigned short int start;
-	unsigned short int end;
-};
+	/* Ethernet+IPv4 specific members. */
+	unsigned char       ar_sha[ETH_ALEN];	/* sender hardware address  */
+	unsigned char       ar_sip[4];		/* sender IP address        */
+	unsigned char       ar_tha[ETH_ALEN];	/* target hardware address  */
+	unsigned char       ar_tip[4];		/* target IP address        */
+} __packed;
 
-struct sw_flow_mask {
+struct ovs_flow_mask {
 	int ref_count;
 	struct rcu_head rcu;
 	struct list_head list;
-	struct sw_flow_key_range range;
-	struct sw_flow_key key;
+	struct sw_flow_mask mask;
 };
 
-struct sw_flow_match {
+struct ovs_flow_match {
 	struct sw_flow_key *key;
 	struct sw_flow_key_range range;
 	struct sw_flow_mask *mask;
@@ -163,36 +106,20 @@ struct sw_flow_stats {
 	};
 };
 
-struct sw_flow {
+struct ovs_flow {
 	struct rcu_head rcu;
 	struct hlist_node hash_node[2];
 	u32 hash;
 
-	struct sw_flow_key key;
-	struct sw_flow_key unmasked_key;
-	struct sw_flow_mask *mask;
+	struct sw_flow flow;
 	struct sw_flow_actions __rcu *sf_acts;
 	struct sw_flow_stats stats;
 };
 
-struct arp_eth_header {
-	__be16      ar_hrd;	/* format of hardware address   */
-	__be16      ar_pro;	/* format of protocol address   */
-	unsigned char   ar_hln;	/* length of hardware address   */
-	unsigned char   ar_pln;	/* length of protocol address   */
-	__be16      ar_op;	/* ARP opcode (command)     */
-
-	/* Ethernet+IPv4 specific members. */
-	unsigned char       ar_sha[ETH_ALEN];	/* sender hardware address  */
-	unsigned char       ar_sip[4];		/* sender IP address        */
-	unsigned char       ar_tha[ETH_ALEN];	/* target hardware address  */
-	unsigned char       ar_tip[4];		/* target IP address        */
-} __packed;
-
-void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb);
-void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *stats,
+void ovs_flow_stats_update(struct ovs_flow *flow, struct sk_buff *skb);
+void ovs_flow_stats_get(struct ovs_flow *flow, struct ovs_flow_stats *stats,
 			unsigned long *used, __be16 *tcp_flags);
-void ovs_flow_stats_clear(struct sw_flow *flow);
+void ovs_flow_stats_clear(struct ovs_flow *flow);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 4d000ac..179ab98 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -46,7 +46,7 @@
 
 #include "flow_netlink.h"
 
-static void update_range__(struct sw_flow_match *match,
+static void update_range__(struct ovs_flow_match *match,
 			   size_t offset, size_t size, bool is_mask)
 {
 	struct sw_flow_key_range *range = NULL;
@@ -103,7 +103,7 @@ static u16 range_n_bytes(const struct sw_flow_key_range *range)
 	return range->end - range->start;
 }
 
-static bool match_validate(const struct sw_flow_match *match,
+static bool match_validate(const struct ovs_flow_match *match,
 			   u64 key_attrs, u64 mask_attrs)
 {
 	u64 key_expected = 1 << OVS_KEY_ATTR_ETHERNET;
@@ -339,7 +339,7 @@ static int parse_flow_nlattrs(const struct nlattr *attr,
 }
 
 static int ipv4_tun_from_nlattr(const struct nlattr *attr,
-				struct sw_flow_match *match, bool is_mask)
+				struct ovs_flow_match *match, bool is_mask)
 {
 	struct nlattr *a;
 	int rem;
@@ -428,8 +428,8 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 }
 
 static int ipv4_tun_to_nlattr(struct sk_buff *skb,
-			      const struct ovs_key_ipv4_tunnel *tun_key,
-			      const struct ovs_key_ipv4_tunnel *output)
+			      const struct sw_flow_key_ipv4_tunnel *tun_key,
+			      const struct sw_flow_key_ipv4_tunnel *output)
 {
 	struct nlattr *nla;
 
@@ -463,7 +463,7 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 }
 
 
-static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
+static int metadata_from_nlattrs(struct ovs_flow_match *match,  u64 *attrs,
 				 const struct nlattr **a, bool is_mask)
 {
 	if (*attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
@@ -501,7 +501,7 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	return 0;
 }
 
-static int ovs_key_from_nlattrs(struct sw_flow_match *match,  bool *exact_5tuple,
+static int ovs_key_from_nlattrs(struct ovs_flow_match *match,  bool *exact_5tuple,
 				u64 attrs, const struct nlattr **a,
 				bool is_mask)
 {
@@ -799,7 +799,7 @@ static void sw_flow_mask_set(struct sw_flow_mask *mask,
  * @mask: Optional. Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink
  * attribute specifies the mask field of the wildcarded flow.
  */
-int ovs_nla_get_match(struct sw_flow_match *match,
+int ovs_nla_get_match(struct ovs_flow_match *match,
 		      bool *exact_5tuple,
 		      const struct nlattr *key,
 		      const struct nlattr *mask)
@@ -922,11 +922,11 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 int ovs_nla_get_flow_metadata(struct sw_flow *flow,
 			      const struct nlattr *attr)
 {
-	struct ovs_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
+	struct sw_flow_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
 	u64 attrs = 0;
 	int err;
-	struct sw_flow_match match;
+	struct ovs_flow_match match;
 
 	flow->key.phy.in_port = DP_MAX_PORTS;
 	flow->key.phy.priority = 0;
@@ -1320,7 +1320,7 @@ static int validate_tp_port(const struct sw_flow_key *flow_key)
 	return -EINVAL;
 }
 
-void ovs_match_init(struct sw_flow_match *match,
+void ovs_match_init(struct ovs_flow_match *match,
 		    struct sw_flow_key *key,
 		    struct sw_flow_mask *mask)
 {
@@ -1339,7 +1339,7 @@ void ovs_match_init(struct sw_flow_match *match,
 static int validate_and_copy_set_tun(const struct nlattr *attr,
 				     struct sw_flow_actions **sfa)
 {
-	struct sw_flow_match match;
+	struct ovs_flow_match match;
 	struct sw_flow_key key;
 	int err, start;
 
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index b31fbe2..f223929 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -37,14 +37,14 @@
 
 #include "flow.h"
 
-void ovs_match_init(struct sw_flow_match *match,
+void ovs_match_init(struct ovs_flow_match *match,
 		    struct sw_flow_key *key, struct sw_flow_mask *mask);
 
 int ovs_nla_put_flow(const struct sw_flow_key *,
 		     const struct sw_flow_key *, struct sk_buff *);
 int ovs_nla_get_flow_metadata(struct sw_flow *flow,
 			      const struct nlattr *attr);
-int ovs_nla_get_match(struct sw_flow_match *match,
+int ovs_nla_get_match(struct ovs_flow_match *match,
 		      bool *exact_5tuple,
 		      const struct nlattr *,
 		      const struct nlattr *);
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 3c268b3..053ece9 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -70,9 +70,9 @@ void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		*d++ = *s++ & *m++;
 }
 
-struct sw_flow *ovs_flow_alloc(bool percpu_stats)
+struct ovs_flow *ovs_flow_alloc(bool percpu_stats)
 {
-	struct sw_flow *flow;
+	struct ovs_flow *flow;
 	int cpu;
 
 	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
@@ -80,7 +80,7 @@ struct sw_flow *ovs_flow_alloc(bool percpu_stats)
 		return ERR_PTR(-ENOMEM);
 
 	flow->sf_acts = NULL;
-	flow->mask = NULL;
+	flow->flow.mask = NULL;
 
 	flow->stats.is_percpu = percpu_stats;
 
@@ -136,7 +136,7 @@ static struct flex_array *alloc_buckets(unsigned int n_buckets)
 	return buckets;
 }
 
-static void flow_free(struct sw_flow *flow)
+static void flow_free(struct ovs_flow *flow)
 {
 	kfree((struct sf_flow_acts __force *)flow->sf_acts);
 	if (flow->stats.is_percpu)
@@ -148,18 +148,20 @@ static void flow_free(struct sw_flow *flow)
 
 static void rcu_free_flow_callback(struct rcu_head *rcu)
 {
-	struct sw_flow *flow = container_of(rcu, struct sw_flow, rcu);
+	struct ovs_flow *flow = container_of(rcu, struct ovs_flow, rcu);
 
 	flow_free(flow);
 }
 
-void ovs_flow_free(struct sw_flow *flow, bool deferred)
+void ovs_flow_free(struct ovs_flow *flow, bool deferred)
 {
 	if (!flow)
 		return;
 
-	if (flow->mask) {
-		struct sw_flow_mask *mask = flow->mask;
+	if (flow->flow.mask) {
+		struct ovs_flow_mask *mask = container_of(flow->flow.mask,
+							  struct ovs_flow_mask,
+							  mask);
 
 		/* ovs-lock is required to protect mask-refcount and
 		 * mask list.
@@ -250,7 +252,7 @@ static void table_instance_destroy(struct table_instance *ti, bool deferred)
 		goto skip_flows;
 
 	for (i = 0; i < ti->n_buckets; i++) {
-		struct sw_flow *flow;
+		struct ovs_flow *flow;
 		struct hlist_head *head = flex_array_get(ti->buckets, i);
 		struct hlist_node *n;
 		int ver = ti->node_ver;
@@ -275,10 +277,10 @@ void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
 	table_instance_destroy(ti, deferred);
 }
 
-struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
+struct ovs_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
 				       u32 *bucket, u32 *last)
 {
-	struct sw_flow *flow;
+	struct ovs_flow *flow;
 	struct hlist_head *head;
 	int ver;
 	int i;
@@ -309,7 +311,8 @@ static struct hlist_head *find_bucket(struct table_instance *ti, u32 hash)
 				(hash & (ti->n_buckets - 1)));
 }
 
-static void table_instance_insert(struct table_instance *ti, struct sw_flow *flow)
+static void table_instance_insert(struct table_instance *ti,
+				  struct ovs_flow *flow)
 {
 	struct hlist_head *head;
 
@@ -328,7 +331,7 @@ static void flow_table_copy_flows(struct table_instance *old,
 
 	/* Insert in new table. */
 	for (i = 0; i < old->n_buckets; i++) {
-		struct sw_flow *flow;
+		struct ovs_flow *flow;
 		struct hlist_head *head;
 
 		head = flex_array_get(old->buckets, i);
@@ -415,21 +418,21 @@ static bool flow_cmp_masked_key(const struct sw_flow *flow,
 	return cmp_key(&flow->key, key, key_start, key_end);
 }
 
-bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-			       struct sw_flow_match *match)
+bool ovs_flow_cmp_unmasked_key(const struct ovs_flow *flow,
+			       struct ovs_flow_match *match)
 {
 	struct sw_flow_key *key = match->key;
 	int key_start = flow_key_start(key);
 	int key_end = match->range.end;
 
-	return cmp_key(&flow->unmasked_key, key, key_start, key_end);
+	return cmp_key(&flow->flow.unmasked_key, key, key_start, key_end);
 }
 
-static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
-					  const struct sw_flow_key *unmasked,
-					  struct sw_flow_mask *mask)
+static struct ovs_flow *masked_flow_lookup(struct table_instance *ti,
+					   const struct sw_flow_key *unmasked,
+					   struct sw_flow_mask *mask)
 {
-	struct sw_flow *flow;
+	struct ovs_flow *flow;
 	struct hlist_head *head;
 	int key_start = mask->range.start;
 	int key_end = mask->range.end;
@@ -440,34 +443,34 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 	hash = flow_hash(&masked_key, key_start, key_end);
 	head = find_bucket(ti, hash);
 	hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
-		if (flow->mask == mask && flow->hash == hash &&
-		    flow_cmp_masked_key(flow, &masked_key,
+		if (flow->flow.mask == mask && flow->hash == hash &&
+		    flow_cmp_masked_key(&flow->flow, &masked_key,
 					  key_start, key_end))
 			return flow;
 	}
 	return NULL;
 }
 
-struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *tbl,
-				    const struct sw_flow_key *key,
-				    u32 *n_mask_hit)
+struct ovs_flow *ovs_flow_tbl_lookup_stats(struct flow_table *tbl,
+					   const struct sw_flow_key *key,
+					   u32 *n_mask_hit)
 {
 	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
-	struct sw_flow_mask *mask;
-	struct sw_flow *flow;
+	struct ovs_flow_mask *mask;
+	struct ovs_flow *flow;
 
 	*n_mask_hit = 0;
 	list_for_each_entry_rcu(mask, &tbl->mask_list, list) {
 		(*n_mask_hit)++;
-		flow = masked_flow_lookup(ti, key, mask);
+		flow = masked_flow_lookup(ti, key, &mask->mask);
 		if (flow)  /* Found */
 			return flow;
 	}
 	return NULL;
 }
 
-struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
-				    const struct sw_flow_key *key)
+struct ovs_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
+				     const struct sw_flow_key *key)
 {
 	u32 __always_unused n_mask_hit;
 
@@ -476,7 +479,7 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 
 int ovs_flow_tbl_num_masks(const struct flow_table *table)
 {
-	struct sw_flow_mask *mask;
+	struct ovs_flow_mask *mask;
 	int num = 0;
 
 	list_for_each_entry(mask, &table->mask_list, list)
@@ -490,7 +493,7 @@ static struct table_instance *table_instance_expand(struct table_instance *ti)
 	return table_instance_rehash(ti, ti->n_buckets * 2);
 }
 
-void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
+void ovs_flow_tbl_remove(struct flow_table *table, struct ovs_flow *flow)
 {
 	struct table_instance *ti = ovsl_dereference(table->ti);
 
@@ -499,9 +502,9 @@ void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 	table->count--;
 }
 
-static struct sw_flow_mask *mask_alloc(void)
+static struct ovs_flow_mask *mask_alloc(void)
 {
-	struct sw_flow_mask *mask;
+	struct ovs_flow_mask *mask;
 
 	mask = kmalloc(sizeof(*mask), GFP_KERNEL);
 	if (mask)
@@ -521,15 +524,15 @@ static bool mask_equal(const struct sw_flow_mask *a,
 		&& (memcmp(a_, b_, range_n_bytes(&a->range)) == 0);
 }
 
-static struct sw_flow_mask *flow_mask_find(const struct flow_table *tbl,
-					   const struct sw_flow_mask *mask)
+static struct ovs_flow_mask *flow_mask_find(const struct flow_table *tbl,
+					    const struct sw_flow_mask *mask)
 {
 	struct list_head *ml;
 
 	list_for_each(ml, &tbl->mask_list) {
-		struct sw_flow_mask *m;
-		m = container_of(ml, struct sw_flow_mask, list);
-		if (mask_equal(mask, m))
+		struct ovs_flow_mask *m;
+		m = container_of(ml, struct ovs_flow_mask, list);
+		if (mask_equal(mask, &m->mask))
 			return m;
 	}
 
@@ -537,29 +540,30 @@ static struct sw_flow_mask *flow_mask_find(const struct flow_table *tbl,
 }
 
 /* Add 'mask' into the mask list, if it is not already there. */
-static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
+static int flow_mask_insert(struct flow_table *tbl, struct ovs_flow *flow,
 			    struct sw_flow_mask *new)
 {
-	struct sw_flow_mask *mask;
+	struct ovs_flow_mask *mask;
+
 	mask = flow_mask_find(tbl, new);
 	if (!mask) {
 		/* Allocate a new mask if none exsits. */
 		mask = mask_alloc();
 		if (!mask)
 			return -ENOMEM;
-		mask->key = new->key;
-		mask->range = new->range;
+		mask->mask.key = new->key;
+		mask->mask.range = new->range;
 		list_add_rcu(&mask->list, &tbl->mask_list);
 	} else {
 		BUG_ON(!mask->ref_count);
 		mask->ref_count++;
 	}
 
-	flow->mask = mask;
+	flow->flow.mask = &mask->mask;
 	return 0;
 }
 
-int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
+int ovs_flow_tbl_insert(struct flow_table *table, struct ovs_flow *flow,
 			struct sw_flow_mask *mask)
 {
 	struct table_instance *new_ti = NULL;
@@ -570,8 +574,8 @@ int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
 	if (err)
 		return err;
 
-	flow->hash = flow_hash(&flow->key, flow->mask->range.start,
-			flow->mask->range.end);
+	flow->hash = flow_hash(&flow->flow.key, flow->flow.mask->range.start,
+			        flow->flow.mask->range.end);
 	ti = ovsl_dereference(table->ti);
 	table_instance_insert(ti, flow);
 	table->count++;
@@ -597,7 +601,7 @@ int ovs_flow_init(void)
 	BUILD_BUG_ON(__alignof__(struct sw_flow_key) % __alignof__(long));
 	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
 
-	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
+	flow_cache = kmem_cache_create("ovs_flow", sizeof(struct ovs_flow), 0,
 					0, NULL);
 	if (flow_cache == NULL)
 		return -ENOMEM;
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index baaeb10..c6abd84 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -55,28 +55,28 @@ struct flow_table {
 int ovs_flow_init(void);
 void ovs_flow_exit(void);
 
-struct sw_flow *ovs_flow_alloc(bool percpu_stats);
-void ovs_flow_free(struct sw_flow *, bool deferred);
+struct ovs_flow *ovs_flow_alloc(bool percpu_stats);
+void ovs_flow_free(struct ovs_flow *, bool deferred);
 
 int ovs_flow_tbl_init(struct flow_table *);
 int ovs_flow_tbl_count(struct flow_table *table);
 void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
 int ovs_flow_tbl_flush(struct flow_table *flow_table);
 
-int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
+int ovs_flow_tbl_insert(struct flow_table *table, struct ovs_flow *flow,
 			struct sw_flow_mask *mask);
-void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
+void ovs_flow_tbl_remove(struct flow_table *table, struct ovs_flow *flow);
 int  ovs_flow_tbl_num_masks(const struct flow_table *table);
-struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
+struct ovs_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
 				       u32 *bucket, u32 *idx);
-struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *,
+struct ovs_flow *ovs_flow_tbl_lookup_stats(struct flow_table *,
 				    const struct sw_flow_key *,
 				    u32 *n_mask_hit);
-struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
+struct ovs_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *);
 
-bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-			       struct sw_flow_match *match);
+bool ovs_flow_cmp_unmasked_key(const struct ovs_flow *flow,
+			       struct ovs_flow_match *match);
 
 void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask);
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index a3d6951..f940cbd 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -63,7 +63,7 @@ static __be16 filter_tnl_flags(__be16 flags)
 static struct sk_buff *__build_header(struct sk_buff *skb,
 				      int tunnel_hlen)
 {
-	const struct ovs_key_ipv4_tunnel *tun_key = OVS_CB(skb)->tun_key;
+	const struct sw_flow_key_ipv4_tunnel *tun_key = OVS_CB(skb)->tun_key;
 	struct tnl_ptk_info tpi;
 
 	skb = gre_handle_offloads(skb, !!(tun_key->tun_flags & TUNNEL_CSUM));
@@ -92,7 +92,7 @@ static __be64 key_to_tunnel_id(__be32 key, __be32 seq)
 static int gre_rcv(struct sk_buff *skb,
 		   const struct tnl_ptk_info *tpi)
 {
-	struct ovs_key_ipv4_tunnel tun_key;
+	struct sw_flow_key_ipv4_tunnel tun_key;
 	struct ovs_net *ovs_net;
 	struct vport *vport;
 	__be64 key;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index e797a50..e0be18e 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -58,7 +58,7 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 /* Called with rcu_read_lock and BH disabled. */
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 {
-	struct ovs_key_ipv4_tunnel tun_key;
+	struct sw_flow_key_ipv4_tunnel tun_key;
 	struct vport *vport = vs->data;
 	struct iphdr *iph;
 	__be64 key;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 42c0f4a..81b083c 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -337,7 +337,7 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
  * skb->data should point to the Ethernet header.
  */
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
-		       struct ovs_key_ipv4_tunnel *tun_key)
+		       struct sw_flow_key_ipv4_tunnel *tun_key)
 {
 	struct pcpu_sw_netstats *stats;
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index d7e50a1..0979304 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -191,7 +191,7 @@ static inline struct vport *vport_from_priv(const void *priv)
 }
 
 void ovs_vport_receive(struct vport *, struct sk_buff *,
-		       struct ovs_key_ipv4_tunnel *);
+		       struct sw_flow_key_ipv4_tunnel *);
 
 /* List of statically compiled vport implementations.  Don't forget to also
  * add yours to the list at the top of vport.c. */
-- 
1.8.5.3
