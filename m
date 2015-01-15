From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5] openvswitch: Allow for any level of nesting in flow attributes
Date: Thu, 15 Jan 2015 01:10:40 +0100
Message-ID: <b0a89cdde69dedebf343cc21e7e3531416b6345b.1421280226.git.tgraf@suug.ch>
References: <cover.1421280226.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.ne, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com, nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34410 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbbAOAKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 19:10:46 -0500
In-Reply-To: <cover.1421280226.git.tgraf@suug.ch>
In-Reply-To: <cover.1421280226.git.tgraf@suug.ch>
References: <cover.1421280226.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nlattr_set() is currently hardcoded to two levels of nesting. This change
introduces struct ovs_len_tbl to define minimal length requirements plus
next level nesting tables to traverse the key attributes to arbitrary depth.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v4->v5:
 - No change
v3->v4:
 - No change. The spotted bug is unrelatd to this series and will be fixed
   in a separate patch
v2->v3:
 - No change
v1->v2:
 - New patch to allow nested Netlink attributes inside
   OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS

 net/openvswitch/flow_netlink.c | 106 ++++++++++++++++++++++-------------------
 1 file changed, 56 insertions(+), 50 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 2e8a9cd..518941c 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -50,6 +50,13 @@
 
 #include "flow_netlink.h"
 
+struct ovs_len_tbl {
+	int len;
+	const struct ovs_len_tbl *next;
+};
+
+#define OVS_ATTR_NESTED -1
+
 static void update_range(struct sw_flow_match *match,
 			 size_t offset, size_t size, bool is_mask)
 {
@@ -289,29 +296,44 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(28); /* OVS_KEY_ATTR_ND */
 }
 
+static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
+	[OVS_TUNNEL_KEY_ATTR_ID]	    = { .len = sizeof(u64) },
+	[OVS_TUNNEL_KEY_ATTR_IPV4_SRC]	    = { .len = sizeof(u32) },
+	[OVS_TUNNEL_KEY_ATTR_IPV4_DST]	    = { .len = sizeof(u32) },
+	[OVS_TUNNEL_KEY_ATTR_TOS]	    = { .len = 1 },
+	[OVS_TUNNEL_KEY_ATTR_TTL]	    = { .len = 1 },
+	[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = { .len = 0 },
+	[OVS_TUNNEL_KEY_ATTR_CSUM]	    = { .len = 0 },
+	[OVS_TUNNEL_KEY_ATTR_TP_SRC]	    = { .len = sizeof(u16) },
+	[OVS_TUNNEL_KEY_ATTR_TP_DST]	    = { .len = sizeof(u16) },
+	[OVS_TUNNEL_KEY_ATTR_OAM]	    = { .len = 0 },
+	[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS]   = { .len = OVS_ATTR_NESTED },
+};
+
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
-static const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
-	[OVS_KEY_ATTR_ENCAP] = -1,
-	[OVS_KEY_ATTR_PRIORITY] = sizeof(u32),
-	[OVS_KEY_ATTR_IN_PORT] = sizeof(u32),
-	[OVS_KEY_ATTR_SKB_MARK] = sizeof(u32),
-	[OVS_KEY_ATTR_ETHERNET] = sizeof(struct ovs_key_ethernet),
-	[OVS_KEY_ATTR_VLAN] = sizeof(__be16),
-	[OVS_KEY_ATTR_ETHERTYPE] = sizeof(__be16),
-	[OVS_KEY_ATTR_IPV4] = sizeof(struct ovs_key_ipv4),
-	[OVS_KEY_ATTR_IPV6] = sizeof(struct ovs_key_ipv6),
-	[OVS_KEY_ATTR_TCP] = sizeof(struct ovs_key_tcp),
-	[OVS_KEY_ATTR_TCP_FLAGS] = sizeof(__be16),
-	[OVS_KEY_ATTR_UDP] = sizeof(struct ovs_key_udp),
-	[OVS_KEY_ATTR_SCTP] = sizeof(struct ovs_key_sctp),
-	[OVS_KEY_ATTR_ICMP] = sizeof(struct ovs_key_icmp),
-	[OVS_KEY_ATTR_ICMPV6] = sizeof(struct ovs_key_icmpv6),
-	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
-	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
-	[OVS_KEY_ATTR_RECIRC_ID] = sizeof(u32),
-	[OVS_KEY_ATTR_DP_HASH] = sizeof(u32),
-	[OVS_KEY_ATTR_TUNNEL] = -1,
-	[OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
+static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
+	[OVS_KEY_ATTR_ENCAP]	 = { .len = OVS_ATTR_NESTED },
+	[OVS_KEY_ATTR_PRIORITY]	 = { .len = sizeof(u32) },
+	[OVS_KEY_ATTR_IN_PORT]	 = { .len = sizeof(u32) },
+	[OVS_KEY_ATTR_SKB_MARK]	 = { .len = sizeof(u32) },
+	[OVS_KEY_ATTR_ETHERNET]	 = { .len = sizeof(struct ovs_key_ethernet) },
+	[OVS_KEY_ATTR_VLAN]	 = { .len = sizeof(__be16) },
+	[OVS_KEY_ATTR_ETHERTYPE] = { .len = sizeof(__be16) },
+	[OVS_KEY_ATTR_IPV4]	 = { .len = sizeof(struct ovs_key_ipv4) },
+	[OVS_KEY_ATTR_IPV6]	 = { .len = sizeof(struct ovs_key_ipv6) },
+	[OVS_KEY_ATTR_TCP]	 = { .len = sizeof(struct ovs_key_tcp) },
+	[OVS_KEY_ATTR_TCP_FLAGS] = { .len = sizeof(__be16) },
+	[OVS_KEY_ATTR_UDP]	 = { .len = sizeof(struct ovs_key_udp) },
+	[OVS_KEY_ATTR_SCTP]	 = { .len = sizeof(struct ovs_key_sctp) },
+	[OVS_KEY_ATTR_ICMP]	 = { .len = sizeof(struct ovs_key_icmp) },
+	[OVS_KEY_ATTR_ICMPV6]	 = { .len = sizeof(struct ovs_key_icmpv6) },
+	[OVS_KEY_ATTR_ARP]	 = { .len = sizeof(struct ovs_key_arp) },
+	[OVS_KEY_ATTR_ND]	 = { .len = sizeof(struct ovs_key_nd) },
+	[OVS_KEY_ATTR_RECIRC_ID] = { .len = sizeof(u32) },
+	[OVS_KEY_ATTR_DP_HASH]	 = { .len = sizeof(u32) },
+	[OVS_KEY_ATTR_TUNNEL]	 = { .len = OVS_ATTR_NESTED,
+				     .next = ovs_tunnel_key_lens, },
+	[OVS_KEY_ATTR_MPLS]	 = { .len = sizeof(struct ovs_key_mpls) },
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -352,8 +374,8 @@ static int __parse_flow_nlattrs(const struct nlattr *attr,
 			return -EINVAL;
 		}
 
-		expected_len = ovs_key_lens[type];
-		if (nla_len(nla) != expected_len && expected_len != -1) {
+		expected_len = ovs_key_lens[type].len;
+		if (nla_len(nla) != expected_len && expected_len != OVS_ATTR_NESTED) {
 			OVS_NLERR(log, "Key %d has unexpected len %d expected %d",
 				  type, nla_len(nla), expected_len);
 			return -EINVAL;
@@ -451,30 +473,16 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		int type = nla_type(a);
 		int err;
 
-		static const u32 ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
-			[OVS_TUNNEL_KEY_ATTR_ID] = sizeof(u64),
-			[OVS_TUNNEL_KEY_ATTR_IPV4_SRC] = sizeof(u32),
-			[OVS_TUNNEL_KEY_ATTR_IPV4_DST] = sizeof(u32),
-			[OVS_TUNNEL_KEY_ATTR_TOS] = 1,
-			[OVS_TUNNEL_KEY_ATTR_TTL] = 1,
-			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
-			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
-			[OVS_TUNNEL_KEY_ATTR_TP_SRC] = sizeof(u16),
-			[OVS_TUNNEL_KEY_ATTR_TP_DST] = sizeof(u16),
-			[OVS_TUNNEL_KEY_ATTR_OAM] = 0,
-			[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS] = -1,
-		};
-
 		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
 			OVS_NLERR(log, "Tunnel attr %d out of range max %d",
 				  type, OVS_TUNNEL_KEY_ATTR_MAX);
 			return -EINVAL;
 		}
 
-		if (ovs_tunnel_key_lens[type] != nla_len(a) &&
-		    ovs_tunnel_key_lens[type] != -1) {
+		if (ovs_tunnel_key_lens[type].len != nla_len(a) &&
+		    ovs_tunnel_key_lens[type].len != OVS_ATTR_NESTED) {
 			OVS_NLERR(log, "Tunnel attr %d has unexpected len %d expected %d",
-				  type, nla_len(a), ovs_tunnel_key_lens[type]);
+				  type, nla_len(a), ovs_tunnel_key_lens[type].len);
 			return -EINVAL;
 		}
 
@@ -912,18 +920,16 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 	return 0;
 }
 
-static void nlattr_set(struct nlattr *attr, u8 val, bool is_attr_mask_key)
+static void nlattr_set(struct nlattr *attr, u8 val,
+		       const struct ovs_len_tbl *tbl)
 {
 	struct nlattr *nla;
 	int rem;
 
 	/* The nlattr stream should already have been validated */
 	nla_for_each_nested(nla, attr, rem) {
-		/* We assume that ovs_key_lens[type] == -1 means that type is a
-		 * nested attribute
-		 */
-		if (is_attr_mask_key && ovs_key_lens[nla_type(nla)] == -1)
-			nlattr_set(nla, val, false);
+		if (tbl && tbl[nla_type(nla)].len == OVS_ATTR_NESTED)
+			nlattr_set(nla, val, tbl[nla_type(nla)].next);
 		else
 			memset(nla_data(nla), val, nla_len(nla));
 	}
@@ -931,7 +937,7 @@ static void nlattr_set(struct nlattr *attr, u8 val, bool is_attr_mask_key)
 
 static void mask_set_nlattr(struct nlattr *attr, u8 val)
 {
-	nlattr_set(attr, val, true);
+	nlattr_set(attr, val, ovs_key_lens);
 }
 
 /**
@@ -1628,8 +1634,8 @@ static int validate_set(const struct nlattr *a,
 		return -EINVAL;
 
 	if (key_type > OVS_KEY_ATTR_MAX ||
-	    (ovs_key_lens[key_type] != nla_len(ovs_key) &&
-	     ovs_key_lens[key_type] != -1))
+	    (ovs_key_lens[key_type].len != nla_len(ovs_key) &&
+	     ovs_key_lens[key_type].len != OVS_ATTR_NESTED))
 		return -EINVAL;
 
 	switch (key_type) {
-- 
1.9.3
