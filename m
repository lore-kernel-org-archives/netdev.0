From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v10 4/5] openvswitch: add layer 3 flow/port support
Date: Thu,  2 Jun 2016 15:24:45 +0900
Message-ID: <1464848686-7656-5-git-send-email-simon.horman@netronome.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35216 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbcFBGZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 02:25:06 -0400
Received: by mail-pf0-f169.google.com with SMTP id g64so27511271pfb.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 23:25:06 -0700 (PDT)
In-Reply-To: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorand Jakab <lojakab@cisco.com>

Implementation of the pop_eth and push_eth actions in the kernel, and
layer 3 flow support.

This doesn't actually do anything yet as no layer 2 tunnel ports are
supported yet. The original patch by Lorand was against the Open vSwitch
tree which has L2 LISP tunnels but that is not supported in mainline Linux.
I (Simon) plan to follow up with support for non-TEB GRE ports based on
work by Thomas Morin.

Cc: Thomas Morin <thomas.morin@orange.com>
Signed-off-by: Lorand Jakab <lojakab@cisco.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
v10 [Simon Horman]
* Move outermost VLAN into skb metadata in pop_eth and
  leave any VLAN as-is in push_eth. The effect is to allow the presence
  of a vlan to be independent of pushing and popping ethernet headers.
* Omit unnecessary type field from push_eth action
* Squash with the following patches to make a more complete patch:
  "openvswitch: add layer 3 support to ovs_packet_cmd_execute()"
  "openvswitch: extend layer 3 support to cover non-IP packets"

v9 [Simon Horman]
* Rebase
* Minor coding style updates
* Prohibit push/pop MPLS on l3 packets
* There are no layer 3 ports supported at this time so only
  send and receive layer 2 packets: that is don't actually
  use this new infrastructure yet
* Expect that vports that can handle layer 3 packets will: have
  a type other than ARPHRD_IPETHER; can also handle layer 2 packets;
  and that packets can be differentiated by layer 2 packets having
  skb->protocol set to htons(ETH_P_TEB)

v1 - v8 [Lorand Jakub]

wip: fix: openvswitch: add support to push and pop

* Consistently use skb_hdr() in push_eth() by assigning
  its value to a local variable.
* Limit scope of hdr in push_mpls()
* Recalculate csum for protocl change in push_mpls.
  - Also needed for pop_mpls?
  - Break out into a fix-patch

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/uapi/linux/openvswitch.h     |  13 +++
 net/openvswitch/actions.c            |  53 ++++++++++
 net/openvswitch/datapath.c           |  13 +--
 net/openvswitch/flow.c               |  57 ++++++----
 net/openvswitch/flow.h               |   4 +-
 net/openvswitch/flow_netlink.c       | 200 +++++++++++++++++++++++++----------
 net/openvswitch/vport-geneve.c       |   2 +-
 net/openvswitch/vport-gre.c          |   2 +-
 net/openvswitch/vport-internal_dev.c |   6 ++
 net/openvswitch/vport-netdev.c       |  19 +++-
 net/openvswitch/vport-netdev.h       |   2 +
 net/openvswitch/vport-vxlan.c        |   2 +-
 12 files changed, 277 insertions(+), 96 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index bb0d515b7654..ace0ad6229ce 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -329,6 +329,8 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
 	OVS_KEY_ATTR_CT_MARK,	/* u32 connection tracking mark */
 	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
+	OVS_KEY_ATTR_PACKET_ETHERTYPE,  /* be16 Ethernet type for packet
+					 * execution */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -699,6 +701,15 @@ enum ovs_nat_attr {
 
 #define OVS_NAT_ATTR_MAX (__OVS_NAT_ATTR_MAX - 1)
 
+/*
+ * struct ovs_action_push_eth - %OVS_ACTION_ATTR_PUSH_ETH action argument.
+ * @addresses: Source and destination MAC addresses.
+ * @eth_type: Ethernet type
+ */
+struct ovs_action_push_eth {
+	struct ovs_key_ethernet addresses;
+};
+
 /**
  * enum ovs_action_attr - Action types.
  *
@@ -756,6 +767,8 @@ enum ovs_action_attr {
 				       * The data must be zero for the unmasked
 				       * bits. */
 	OVS_ACTION_ATTR_CT,           /* Nested OVS_CT_ATTR_* . */
+	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
+	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 15f130e4c22b..5567529904fa 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -300,6 +300,51 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
+static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	/* Pop outermost VLAN tag to skb metadata unless a VLAN tag
+	 * is already present there.
+	 */
+	if ((skb->protocol == htons(ETH_P_8021Q) ||
+	     skb->protocol == htons(ETH_P_8021AD)) &&
+	    !skb_vlan_tag_present(skb)) {
+		int err = skb_vlan_accel(skb);
+		if (unlikely(err))
+			return err;
+	}
+
+	skb_pull_rcsum(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	skb->mac_len -= ETH_HLEN;
+
+	invalidate_flow_key(key);
+	return 0;
+}
+
+static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
+		    const struct ovs_action_push_eth *ethh)
+{
+	struct ethhdr *hdr;
+
+	/* Add the new Ethernet header */
+	if (skb_cow_head(skb, ETH_HLEN) < 0)
+		return -ENOMEM;
+
+	skb_push(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	skb_reset_mac_len(skb);
+
+	hdr = eth_hdr(skb);
+	ether_addr_copy(hdr->h_source, ethh->addresses.eth_src);
+	ether_addr_copy(hdr->h_dest, ethh->addresses.eth_dst);
+	hdr->h_proto = skb->protocol;
+
+	skb_postpush_rcsum(skb, hdr, ETH_HLEN);
+
+	invalidate_flow_key(key);
+	return 0;
+}
+
 static void update_ip_l4_checksum(struct sk_buff *skb, struct iphdr *nh,
 				  __be32 addr, __be32 new_addr)
 {
@@ -1088,6 +1133,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = pop_vlan(skb, key);
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_ETH:
+			err = push_eth(skb, key, nla_data(a));
+			break;
+
+		case OVS_ACTION_ATTR_POP_ETH:
+			err = pop_eth(skb, key);
+			break;
+
 		case OVS_ACTION_ATTR_RECIRC:
 			err = execute_recirc(dp, skb, key, a, rem);
 			if (nla_is_last(a, rem)) {
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 856bd8dba676..780957e78d2b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -546,7 +546,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct sw_flow_actions *sf_acts;
 	struct datapath *dp;
-	struct ethhdr *eth;
 	struct vport *input_vport;
 	u16 mru = 0;
 	int len;
@@ -567,17 +566,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 
 	nla_memcpy(__skb_put(packet, len), a[OVS_PACKET_ATTR_PACKET], len);
 
-	skb_reset_mac_header(packet);
-	eth = eth_hdr(packet);
-
-	/* Normally, setting the skb 'protocol' field would be handled by a
-	 * call to eth_type_trans(), but it assumes there's a sending
-	 * device, which we may not have. */
-	if (eth_proto_is_802_3(eth->h_proto))
-		packet->protocol = eth->h_proto;
-	else
-		packet->protocol = htons(ETH_P_802_2);
-
 	/* Set packet's mru */
 	if (a[OVS_PACKET_ATTR_MRU]) {
 		mru = nla_get_u16(a[OVS_PACKET_ATTR_MRU]);
@@ -604,6 +592,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	rcu_assign_pointer(flow->sf_acts, acts);
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
+	packet->protocol = flow->key.eth.type;
 
 	rcu_read_lock();
 	dp = get_dp_rcu(net, ovs_header->dp_ifindex);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 0ea128eeeab2..2d9777abcfc9 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -468,28 +468,31 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 	skb_reset_mac_header(skb);
 
-	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
-	 * header in the linear data area.
-	 */
-	eth = eth_hdr(skb);
-	ether_addr_copy(key->eth.src, eth->h_source);
-	ether_addr_copy(key->eth.dst, eth->h_dest);
+	/* Link layer. */
+	key->eth.tci = 0;
+	if (key->phy.is_layer3) {
+		if (skb_vlan_tag_present(skb))
+			key->eth.tci = htons(skb->vlan_tci);
+	} else {
+		eth = eth_hdr(skb);
+		ether_addr_copy(key->eth.src, eth->h_source);
+		ether_addr_copy(key->eth.dst, eth->h_dest);
 
-	__skb_pull(skb, 2 * ETH_ALEN);
-	/* We are going to push all headers that we pull, so no need to
-	 * update skb->csum here.
-	 */
+		__skb_pull(skb, 2 * ETH_ALEN);
+		/* We are going to push all headers that we pull, so no need to
+		 * update skb->csum here.
+		 */
 
-	key->eth.tci = 0;
-	if (skb_vlan_tag_present(skb))
-		key->eth.tci = htons(skb->vlan_tci);
-	else if (eth->h_proto == htons(ETH_P_8021Q))
-		if (unlikely(parse_vlan(skb, key)))
-			return -ENOMEM;
+		if (skb_vlan_tag_present(skb))
+			key->eth.tci = htons(skb->vlan_tci);
+		else if (eth->h_proto == htons(ETH_P_8021Q))
+			if (unlikely(parse_vlan(skb, key)))
+				return -ENOMEM;
 
-	key->eth.type = parse_ethertype(skb);
-	if (unlikely(key->eth.type == htons(0)))
-		return -ENOMEM;
+		key->eth.type = parse_ethertype(skb);
+		if (unlikely(key->eth.type == htons(0)))
+			return -ENOMEM;
+	}
 
 	skb_reset_network_header(skb);
 	skb_reset_mac_len(skb);
@@ -690,12 +693,16 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 {
+	key->eth.type = skb->protocol;
+
 	return key_extract(skb, key);
 }
 
 int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
+	int err;
+
 	/* Extract metadata from packet. */
 	if (tun_info) {
 		key->tun_proto = ip_tunnel_info_af(tun_info);
@@ -723,9 +730,19 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.skb_mark = skb->mark;
 	ovs_ct_fill_key(skb, key);
 	key->ovs_flow_hash = 0;
+	key->phy.is_layer3 = skb->mac_len == 0;
 	key->recirc_id = 0;
 
-	return key_extract(skb, key);
+	err = key_extract(skb, key);
+	if (err < 0)
+		return err;
+
+	if (key->phy.is_layer3)
+		key->eth.type = skb->protocol;
+	else if (tun_info && skb->protocol == htons(ETH_P_TEB))
+		skb->protocol = key->eth.type;
+
+	return err;
 }
 
 int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 03378e75a67c..5395ec0c3c13 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -62,6 +62,7 @@ struct sw_flow_key {
 		u32	priority;	/* Packet QoS priority. */
 		u32	skb_mark;	/* SKB mark. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
+		bool	is_layer3;	/* Packet has no Ethernet header */
 	} __packed phy; /* Safe when right after 'tun_key'. */
 	u8 tun_proto;			/* Protocol of encapsulating tunnel. */
 	u32 ovs_flow_hash;		/* Datapath computed hash value.  */
@@ -219,8 +220,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key);
 int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
-			 struct sk_buff *skb,
-			 struct sw_flow_key *key);
+			 struct sk_buff *skb, struct sw_flow_key *key);
 /* Extract key from packet coming from userspace. */
 int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 				   struct sk_buff *skb,
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 0bb650f4f219..1e1392c3c0ed 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -123,7 +123,7 @@ static void update_range(struct sw_flow_match *match,
 static bool match_validate(const struct sw_flow_match *match,
 			   u64 key_attrs, u64 mask_attrs, bool log)
 {
-	u64 key_expected = 1 << OVS_KEY_ATTR_ETHERNET;
+	u64 key_expected = 0;
 	u64 mask_allowed = key_attrs;  /* At most allow all key attributes */
 
 	/* The following mask attributes allowed only if they
@@ -145,6 +145,10 @@ static bool match_validate(const struct sw_flow_match *match,
 		       | (1 << OVS_KEY_ATTR_IN_PORT)
 		       | (1 << OVS_KEY_ATTR_ETHERTYPE));
 
+	/* If Ethertype is present, expect MAC addresses */
+	if (key_attrs & (1ULL << OVS_KEY_ATTR_ETHERTYPE))
+		key_expected |= 1ULL << OVS_KEY_ATTR_ETHERNET;
+
 	/* Check key attributes. */
 	if (match->key->eth.type == htons(ETH_P_ARP)
 			|| match->key->eth.type == htons(ETH_P_RARP)) {
@@ -282,7 +286,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 26);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 27);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -355,6 +359,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
 	[OVS_KEY_ATTR_CT_MARK]	 = { .len = sizeof(u32) },
 	[OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_labels) },
+	[OVS_KEY_ATTR_PACKET_ETHERTYPE] = { .len = sizeof(__be16) },
 };
 
 static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
@@ -812,6 +817,8 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				 u64 *attrs, const struct nlattr **a,
 				 bool is_mask, bool log)
 {
+	bool is_layer3 = false;
+
 	if (*attrs & (1 << OVS_KEY_ATTR_DP_HASH)) {
 		u32 hash_val = nla_get_u32(a[OVS_KEY_ATTR_DP_HASH]);
 
@@ -898,20 +905,41 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				   sizeof(*cl), is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABELS);
 	}
-	return 0;
-}
 
-static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
-				u64 attrs, const struct nlattr **a,
-				bool is_mask, bool log)
-{
-	int err;
+	/* For layer 3 packets the ethernet type is provided by by the
+	 * metadata field OVS_KEY_ATTR_PACKET_ETHERTYPE which has a
+	 * non-zero value. Otherwise the ethernet type is provided by the
+	 * packet and reflected by OVS_KEY_ATTR_PACKET_ETHERTYPE.
+	 */
+	if (*attrs & (1ULL << OVS_KEY_ATTR_PACKET_ETHERTYPE)) {
+		/* This is duplicate code from ovs_key_from_nlattrs*/
+		__be16 eth_type;
 
-	err = metadata_from_nlattrs(net, match, &attrs, a, is_mask, log);
-	if (err)
-		return err;
+		if (is_mask)
+			/* Always exact match packet EtherType */
+			eth_type = htons(0xffff);
+		else
+			eth_type = nla_get_be16(a[OVS_KEY_ATTR_PACKET_ETHERTYPE]);
+
+		if (eth_type != htons(0)) {
+			is_layer3 = true;
+			SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
+		}
+
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_PACKET_ETHERTYPE);
+	}
 
-	if (attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
+	/* Always exact match is_layer3 */
+	SW_FLOW_KEY_PUT(match, phy.is_layer3, is_mask ? true : is_layer3,
+			is_mask);
+	return is_layer3;
+}
+
+static int l2_from_nlattrs(struct net *net, struct sw_flow_match *match,
+			   u64 *attrs, const struct nlattr **a,
+			   bool is_mask, bool log)
+{
+	if (*attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
 		const struct ovs_key_ethernet *eth_key;
 
 		eth_key = nla_data(a[OVS_KEY_ATTR_ETHERNET]);
@@ -919,10 +947,10 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				eth_key->eth_src, ETH_ALEN, is_mask);
 		SW_FLOW_KEY_MEMCPY(match, eth.dst,
 				eth_key->eth_dst, ETH_ALEN, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
+		*attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
 	}
 
-	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
+	if (*attrs & (1 << OVS_KEY_ATTR_VLAN)) {
 		__be16 tci;
 
 		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
@@ -936,10 +964,10 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		}
 
 		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+		*attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
 	}
 
-	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
+	if (*attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
 		__be16 eth_type;
 
 		eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
@@ -953,11 +981,32 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		}
 
 		SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+		*attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 	} else if (!is_mask) {
 		SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
 	}
 
+	return 0;
+}
+
+static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
+				u64 attrs, const struct nlattr **a,
+				bool is_mask, bool log)
+{
+	int err;
+	bool is_layer3;
+
+	err = metadata_from_nlattrs(net, match, &attrs, a, is_mask, log);
+	if (err < 0)
+		return err;
+	is_layer3 = err != 0;
+
+	if (!is_layer3) {
+		err = l2_from_nlattrs(net, match, &attrs, a, is_mask, log);
+		if (err < 0)
+			return err;
+	}
+
 	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
 		const struct ovs_key_ipv4 *ipv4_key;
 
@@ -1407,7 +1456,11 @@ int ovs_nla_get_flow_metadata(struct net *net, const struct nlattr *attr,
 	memset(&key->ct, 0, sizeof(key->ct));
 	key->phy.in_port = DP_MAX_PORTS;
 
-	return metadata_from_nlattrs(net, &match, &attrs, a, false, log);
+	err = metadata_from_nlattrs(net, &match, &attrs, a, false, log);
+	if (err < 0)
+		return err;
+
+	return 0;
 }
 
 static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
@@ -1415,7 +1468,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 			     struct sk_buff *skb)
 {
 	struct ovs_key_ethernet *eth_key;
-	struct nlattr *nla, *encap;
+	struct nlattr *nla, *encap = NULL;
 
 	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
 		goto nla_put_failure;
@@ -1456,42 +1509,48 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (ovs_ct_put_key(output, skb))
 		goto nla_put_failure;
 
-	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
-	if (!nla)
-		goto nla_put_failure;
+	if (!swkey->phy.is_layer3) {
+		nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
+		if (!nla)
+			goto nla_put_failure;
 
-	eth_key = nla_data(nla);
-	ether_addr_copy(eth_key->eth_src, output->eth.src);
-	ether_addr_copy(eth_key->eth_dst, output->eth.dst);
+		eth_key = nla_data(nla);
+		ether_addr_copy(eth_key->eth_src, output->eth.src);
+		ether_addr_copy(eth_key->eth_dst, output->eth.dst);
 
-	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
-		__be16 eth_type;
-		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
-		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
-		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
-			goto nla_put_failure;
-		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
-		if (!swkey->eth.tci)
-			goto unencap;
-	} else
-		encap = NULL;
-
-	if (swkey->eth.type == htons(ETH_P_802_2)) {
-		/*
-		 * Ethertype 802.2 is represented in the netlink with omitted
-		 * OVS_KEY_ATTR_ETHERTYPE in the flow key attribute, and
-		 * 0xffff in the mask attribute.  Ethertype can also
-		 * be wildcarded.
-		 */
-		if (is_mask && output->eth.type)
-			if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
-						output->eth.type))
+		if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
+			__be16 eth_type;
+			eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
+			if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
+			    nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
+					 output->eth.tci))
 				goto nla_put_failure;
-		goto unencap;
-	}
+			encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+			if (!swkey->eth.tci)
+				goto unencap;
+		}
 
-	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
-		goto nla_put_failure;
+		if (swkey->eth.type == htons(ETH_P_802_2)) {
+			/*
+			 * Ethertype 802.2 is represented in the netlink
+			 * with omitted OVS_KEY_ATTR_ETHERTYPE in the flow
+			 * key attribute, and 0xffff in the mask attribute.
+			 * Ethertype can also be wildcarded.
+			 */
+			if (is_mask && output->eth.type)
+				if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
+						 output->eth.type))
+					goto nla_put_failure;
+			goto unencap;
+		}
+
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
+			goto nla_put_failure;
+	} else {
+		if (nla_put_be16(skb, OVS_KEY_ATTR_PACKET_ETHERTYPE,
+				 output->eth.type))
+			goto nla_put_failure;
+	}
 
 	if (swkey->eth.type == htons(ETH_P_IP)) {
 		struct ovs_key_ipv4 *ipv4_key;
@@ -2010,8 +2069,8 @@ static bool validate_masked(u8 *data, int len)
 
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key,
-			struct sw_flow_actions **sfa,
-			bool *skip_copy, __be16 eth_type, bool masked, bool log)
+			struct sw_flow_actions **sfa, bool *skip_copy,
+			__be16 eth_type, bool masked, bool log, bool is_layer3)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
@@ -2041,7 +2100,11 @@ static int validate_set(const struct nlattr *a,
 	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_CT_MARK:
 	case OVS_KEY_ATTR_CT_LABELS:
+		break;
+
 	case OVS_KEY_ATTR_ETHERNET:
+		if (is_layer3)
+			return -EINVAL;
 		break;
 
 	case OVS_KEY_ATTR_TUNNEL:
@@ -2208,6 +2271,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log)
 {
+	bool is_layer3 = key->phy.is_layer3;
 	const struct nlattr *a;
 	int rem, err;
 
@@ -2229,6 +2293,8 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
 			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash),
 			[OVS_ACTION_ATTR_CT] = (u32)-1,
+			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
+			[OVS_ACTION_ATTR_POP_ETH] = 0,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2269,10 +2335,14 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 		}
 
 		case OVS_ACTION_ATTR_POP_VLAN:
+			if (is_layer3)
+				return -EINVAL;
 			vlan_tci = htons(0);
 			break;
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
+			if (is_layer3)
+				return -EINVAL;
 			vlan = nla_data(a);
 			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
 				return -EINVAL;
@@ -2322,14 +2392,16 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_SET:
 			err = validate_set(a, key, sfa,
-					   &skip_copy, eth_type, false, log);
+					   &skip_copy, eth_type, false, log,
+					   is_layer3);
 			if (err)
 				return err;
 			break;
 
 		case OVS_ACTION_ATTR_SET_MASKED:
 			err = validate_set(a, key, sfa,
-					   &skip_copy, eth_type, true, log);
+					   &skip_copy, eth_type, true, log,
+					   is_layer3);
 			if (err)
 				return err;
 			break;
@@ -2349,6 +2421,22 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_POP_ETH:
+			if (is_layer3)
+				return -EINVAL;
+			if (vlan_tci & htons(VLAN_TAG_PRESENT))
+				return -EINVAL;
+			is_layer3 = true;
+			break;
+
+		case OVS_ACTION_ATTR_PUSH_ETH:
+			/* For now disallow pushing an Ethernet header if one
+			 * is already present */
+			if (!is_layer3)
+				return -EINVAL;
+			is_layer3 = false;
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 1a1fcec88695..7a06e19f5279 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -116,7 +116,7 @@ static struct vport_ops ovs_geneve_vport_ops = {
 	.create		= geneve_create,
 	.destroy	= ovs_netdev_tunnel_destroy,
 	.get_options	= geneve_get_options,
-	.send		= dev_queue_xmit,
+	.send		= ovs_netdev_send,
 };
 
 static int __init ovs_geneve_tnl_init(void)
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 7f8897f33a67..bcbc91b8b077 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -87,7 +87,7 @@ static struct vport *gre_create(const struct vport_parms *parms)
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
-	.send		= dev_queue_xmit,
+	.send		= ovs_netdev_send,
 	.destroy	= ovs_netdev_tunnel_destroy,
 };
 
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index f89b1efa88f1..484ba529c682 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -258,6 +258,12 @@ static netdev_tx_t internal_dev_recv(struct sk_buff *skb)
 	struct net_device *netdev = skb->dev;
 	struct pcpu_sw_netstats *stats;
 
+	/* Only send/receive L2 packets */
+	if (!skb->mac_len) {
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
 	if (unlikely(!(netdev->flags & IFF_UP))) {
 		kfree_skb(skb);
 		netdev->stats.rx_dropped++;
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4e3972344aa6..733e7914f6bd 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -57,8 +57,10 @@ static void netdev_port_receive(struct sk_buff *skb)
 	if (unlikely(!skb))
 		return;
 
-	skb_push(skb, ETH_HLEN);
-	skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
+	if (vport->dev->type == ARPHRD_ETHER) {
+		skb_push(skb, ETH_HLEN);
+		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
+	}
 	ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
 	return;
 error:
@@ -194,6 +196,17 @@ void ovs_netdev_tunnel_destroy(struct vport *vport)
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_tunnel_destroy);
 
+int ovs_netdev_send(struct sk_buff *skb)
+{
+	/* Only send L2 packets */
+	if (skb->mac_len)
+		return dev_queue_xmit(skb);
+
+	kfree_skb(skb);
+	return -EINVAL;
+}
+EXPORT_SYMBOL_GPL(ovs_netdev_send);
+
 /* Returns null if this device is not attached to a datapath. */
 struct vport *ovs_netdev_get_vport(struct net_device *dev)
 {
@@ -208,7 +221,7 @@ static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
-	.send		= dev_queue_xmit,
+	.send		= ovs_netdev_send,
 };
 
 int __init ovs_netdev_init(void)
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 19e29c12adcc..637b14a9963c 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -33,4 +33,6 @@ int __init ovs_netdev_init(void);
 void ovs_netdev_exit(void);
 
 void ovs_netdev_tunnel_destroy(struct vport *vport);
+
+int ovs_netdev_send(struct sk_buff *skb);
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 5eb7694348b5..13f11ad7e35a 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -153,7 +153,7 @@ static struct vport_ops ovs_vxlan_netdev_vport_ops = {
 	.create			= vxlan_create,
 	.destroy		= ovs_netdev_tunnel_destroy,
 	.get_options		= vxlan_get_options,
-	.send			= dev_queue_xmit,
+	.send			= ovs_netdev_send,
 };
 
 static int __init ovs_vxlan_tnl_init(void)
-- 
2.1.4
