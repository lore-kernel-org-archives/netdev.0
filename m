From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: [PATCH v3] net: openvswitch: Support masked set actions.
Date: Thu,  5 Feb 2015 13:40:49 -0800
Message-ID: <1423172449-3654-1-git-send-email-jrajahalme@nicira.com>
Cc: jrajahalme@nicira.com
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:37205 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751190AbbBEVdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 16:33:51 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so12506932pab.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 13:33:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS userspace already probes the openvswitch kernel module for
OVS_ACTION_ATTR_SET_MASKED support.  This patch adds the kernel module
implementation of masked set actions.

The existing set action sets many fields at once.  When only a subset
of the IP header fields, for example, should be modified, all the IP
fields need to be exact matched so that the other field values can be
copied to the set action.  A masked set action allows modification of
an arbitrary subset of the supported header bits without requiring the
rest to be matched.

Masked set action is now supported for all writeable key types, except
for the tunnel key.  The set tunnel action is an exception as any
input tunnel info is cleared before action processing starts, so there
is no tunnel info to mask.

The kernel module converts all (non-tunnel) set actions to masked set
actions.  This makes action processing more uniform, and results in
less branching and duplicating the action processing code.  When
returning actions to userspace, the fully masked set actions are
converted back to normal set actions.  We use a kernel internal action
code to be able to tell the userspace provided and converted masked
set actions apart.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
v3: Clean up code and remove flow key transport port checks from
    validate_set(), as suggested by Jesse Gross.

 include/uapi/linux/openvswitch.h |   22 ++-
 net/openvswitch/actions.c        |  373 ++++++++++++++++++++++++--------------
 net/openvswitch/flow_netlink.c   |  161 ++++++++++++----
 3 files changed, 383 insertions(+), 173 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 7a8785a..bbd49a0 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -599,6 +599,12 @@ struct ovs_action_hash {
  * @OVS_ACTION_ATTR_SET: Replaces the contents of an existing header.  The
  * single nested %OVS_KEY_ATTR_* attribute specifies a header to modify and its
  * value.
+ * @OVS_ACTION_ATTR_SET_MASKED: Replaces the contents of an existing header.  A
+ * nested %OVS_KEY_ATTR_* attribute specifies a header to modify, its value,
+ * and a mask.  For every bit set in the mask, the corresponding bit value
+ * is copied from the value to the packet header field, rest of the bits are
+ * left unchanged.  The non-masked value bits must be passed in as zeroes.
+ * Masking is not supported for the %OVS_KEY_ATTR_TUNNEL attribute.
  * @OVS_ACTION_ATTR_PUSH_VLAN: Push a new outermost 802.1Q header onto the
  * packet.
  * @OVS_ACTION_ATTR_POP_VLAN: Pop the outermost 802.1Q header off the packet.
@@ -617,6 +623,9 @@ struct ovs_action_hash {
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
  * type may not be changed.
+ *
+ * @OVS_ACTION_ATTR_SET_TO_MASKED: Kernel internal masked set action translated
+ * from the @OVS_ACTION_ATTR_SET.
  */
 
 enum ovs_action_attr {
@@ -631,8 +640,19 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_HASH,	      /* struct ovs_action_hash. */
 	OVS_ACTION_ATTR_PUSH_MPLS,    /* struct ovs_action_push_mpls. */
 	OVS_ACTION_ATTR_POP_MPLS,     /* __be16 ethertype. */
+	OVS_ACTION_ATTR_SET_MASKED,   /* One nested OVS_KEY_ATTR_* including
+				       * data immediately followed by a mask.
+				       * The data must be zero for the unmasked
+				       * bits. */
+
+	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
+				       * from userspace. */
 
-	__OVS_ACTION_ATTR_MAX
+#ifdef __KERNEL__
+	OVS_ACTION_ATTR_SET_TO_MASKED, /* Kernel module internal masked
+					* set action converted from
+					* OVS_ACTION_ATTR_SET. */
+#endif
 };
 
 #define OVS_ACTION_ATTR_MAX (__OVS_ACTION_ATTR_MAX - 1)
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b4cffe6..b491c1c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -185,10 +185,15 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
-static int set_mpls(struct sk_buff *skb, struct sw_flow_key *key,
-		    const __be32 *mpls_lse)
+/* 'KEY' must not have any bits set outside of the 'MASK' */
+#define MASKED(OLD, KEY, MASK) ((KEY) | ((OLD) & ~(MASK)))
+#define SET_MASKED(OLD, KEY, MASK) ((OLD) = MASKED(OLD, KEY, MASK))
+
+static int set_mpls(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		    const __be32 *mpls_lse, const __be32 *mask)
 {
 	__be32 *stack;
+	__be32 lse;
 	int err;
 
 	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
@@ -196,14 +201,16 @@ static int set_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		return err;
 
 	stack = (__be32 *)skb_mpls_header(skb);
+	lse = MASKED(*stack, *mpls_lse, *mask);
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		__be32 diff[] = { ~(*stack), *mpls_lse };
+		__be32 diff[] = { ~(*stack), lse };
+
 		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
 					  ~skb->csum);
 	}
 
-	*stack = *mpls_lse;
-	key->mpls.top_lse = *mpls_lse;
+	*stack = lse;
+	flow_key->mpls.top_lse = lse;
 	return 0;
 }
 
@@ -230,23 +237,39 @@ static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 			     ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 }
 
-static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *key,
-			const struct ovs_key_ethernet *eth_key)
+/* 'src' is already properly masked. */
+static void ether_addr_copy_masked(u8 *dst_, const u8 *src_, const u8 *mask_)
+{
+	u16 *dst = (u16 *)dst_;
+	const u16 *src = (const u16 *)src_;
+	const u16 *mask = (const u16 *)mask_;
+
+	SET_MASKED(dst[0], src[0], mask[0]);
+	SET_MASKED(dst[1], src[1], mask[1]);
+	SET_MASKED(dst[2], src[2], mask[2]);
+}
+
+static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
+			const struct ovs_key_ethernet *key,
+			const struct ovs_key_ethernet *mask)
 {
 	int err;
+
 	err = skb_ensure_writable(skb, ETH_HLEN);
 	if (unlikely(err))
 		return err;
 
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
 
-	ether_addr_copy(eth_hdr(skb)->h_source, eth_key->eth_src);
-	ether_addr_copy(eth_hdr(skb)->h_dest, eth_key->eth_dst);
+	ether_addr_copy_masked(eth_hdr(skb)->h_source, key->eth_src,
+			       mask->eth_src);
+	ether_addr_copy_masked(eth_hdr(skb)->h_dest, key->eth_dst,
+			       mask->eth_dst);
 
 	ovs_skb_postpush_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
 
-	ether_addr_copy(key->eth.src, eth_key->eth_src);
-	ether_addr_copy(key->eth.dst, eth_key->eth_dst);
+	ether_addr_copy(flow_key->eth.src, eth_hdr(skb)->h_source);
+	ether_addr_copy(flow_key->eth.dst, eth_hdr(skb)->h_dest);
 	return 0;
 }
 
@@ -304,6 +327,15 @@ static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
 	}
 }
 
+static void mask_ipv6_addr(const __be32 old[4], const __be32 addr[4],
+			   const __be32 mask[4], __be32 masked[4])
+{
+	masked[0] = MASKED(old[0], addr[0], mask[0]);
+	masked[1] = MASKED(old[1], addr[1], mask[1]);
+	masked[2] = MASKED(old[2], addr[2], mask[2]);
+	masked[3] = MASKED(old[3], addr[3], mask[3]);
+}
+
 static void set_ipv6_addr(struct sk_buff *skb, u8 l4_proto,
 			  __be32 addr[4], const __be32 new_addr[4],
 			  bool recalculate_csum)
@@ -315,29 +347,29 @@ static void set_ipv6_addr(struct sk_buff *skb, u8 l4_proto,
 	memcpy(addr, new_addr, sizeof(__be32[4]));
 }
 
-static void set_ipv6_tc(struct ipv6hdr *nh, u8 tc)
+static void set_ipv6_fl(struct ipv6hdr *nh, u32 fl, u32 mask)
 {
-	nh->priority = tc >> 4;
-	nh->flow_lbl[0] = (nh->flow_lbl[0] & 0x0F) | ((tc & 0x0F) << 4);
+	/* Bits 21-24 are always unmasked, so this retains their values. */
+	SET_MASKED(nh->flow_lbl[0], (u8)(fl >> 16), (u8)(mask >> 16));
+	SET_MASKED(nh->flow_lbl[1], (u8)(fl >> 8), (u8)(mask >> 8));
+	SET_MASKED(nh->flow_lbl[2], (u8)fl, (u8)mask);
 }
 
-static void set_ipv6_fl(struct ipv6hdr *nh, u32 fl)
+static void set_ip_ttl(struct sk_buff *skb, struct iphdr *nh, u8 new_ttl,
+		       u8 mask)
 {
-	nh->flow_lbl[0] = (nh->flow_lbl[0] & 0xF0) | (fl & 0x000F0000) >> 16;
-	nh->flow_lbl[1] = (fl & 0x0000FF00) >> 8;
-	nh->flow_lbl[2] = fl & 0x000000FF;
-}
+	new_ttl = MASKED(nh->ttl, new_ttl, mask);
 
-static void set_ip_ttl(struct sk_buff *skb, struct iphdr *nh, u8 new_ttl)
-{
 	csum_replace2(&nh->check, htons(nh->ttl << 8), htons(new_ttl << 8));
 	nh->ttl = new_ttl;
 }
 
-static int set_ipv4(struct sk_buff *skb, struct sw_flow_key *key,
-		    const struct ovs_key_ipv4 *ipv4_key)
+static int set_ipv4(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		    const struct ovs_key_ipv4 *key,
+		    const struct ovs_key_ipv4 *mask)
 {
 	struct iphdr *nh;
+	__be32 new_addr;
 	int err;
 
 	err = skb_ensure_writable(skb, skb_network_offset(skb) +
@@ -347,36 +379,49 @@ static int set_ipv4(struct sk_buff *skb, struct sw_flow_key *key,
 
 	nh = ip_hdr(skb);
 
-	if (ipv4_key->ipv4_src != nh->saddr) {
-		set_ip_addr(skb, nh, &nh->saddr, ipv4_key->ipv4_src);
-		key->ipv4.addr.src = ipv4_key->ipv4_src;
-	}
+	/* Setting an IP addresses is typically only a side effect of
+	 * matching on them in the current userspace implementation, so it
+	 * makes sense to check if the value actually changed.
+	 */
+	if (mask->ipv4_src) {
+		new_addr = MASKED(nh->saddr, key->ipv4_src, mask->ipv4_src);
 
-	if (ipv4_key->ipv4_dst != nh->daddr) {
-		set_ip_addr(skb, nh, &nh->daddr, ipv4_key->ipv4_dst);
-		key->ipv4.addr.dst = ipv4_key->ipv4_dst;
+		if (unlikely(new_addr != nh->saddr)) {
+			set_ip_addr(skb, nh, &nh->saddr, new_addr);
+			flow_key->ipv4.addr.src = new_addr;
+		}
 	}
+	if (mask->ipv4_dst) {
+		new_addr = MASKED(nh->daddr, key->ipv4_dst, mask->ipv4_dst);
 
-	if (ipv4_key->ipv4_tos != nh->tos) {
-		ipv4_change_dsfield(nh, 0, ipv4_key->ipv4_tos);
-		key->ip.tos = nh->tos;
+		if (unlikely(new_addr != nh->daddr)) {
+			set_ip_addr(skb, nh, &nh->daddr, new_addr);
+			flow_key->ipv4.addr.dst = new_addr;
+		}
 	}
-
-	if (ipv4_key->ipv4_ttl != nh->ttl) {
-		set_ip_ttl(skb, nh, ipv4_key->ipv4_ttl);
-		key->ip.ttl = ipv4_key->ipv4_ttl;
+	if (mask->ipv4_tos) {
+		ipv4_change_dsfield(nh, ~mask->ipv4_tos, key->ipv4_tos);
+		flow_key->ip.tos = nh->tos;
+	}
+	if (mask->ipv4_ttl) {
+		set_ip_ttl(skb, nh, key->ipv4_ttl, mask->ipv4_ttl);
+		flow_key->ip.ttl = nh->ttl;
 	}
 
 	return 0;
 }
 
-static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *key,
-		    const struct ovs_key_ipv6 *ipv6_key)
+static bool is_ipv6_mask_nonzero(const __be32 addr[4])
+{
+	return !!(addr[0] | addr[1] | addr[2] | addr[3]);
+}
+
+static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		    const struct ovs_key_ipv6 *key,
+		    const struct ovs_key_ipv6 *mask)
 {
 	struct ipv6hdr *nh;
 	int err;
-	__be32 *saddr;
-	__be32 *daddr;
 
 	err = skb_ensure_writable(skb, skb_network_offset(skb) +
 				  sizeof(struct ipv6hdr));
@@ -384,71 +429,77 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *key,
 		return err;
 
 	nh = ipv6_hdr(skb);
-	saddr = (__be32 *)&nh->saddr;
-	daddr = (__be32 *)&nh->daddr;
-
-	if (memcmp(ipv6_key->ipv6_src, saddr, sizeof(ipv6_key->ipv6_src))) {
-		set_ipv6_addr(skb, ipv6_key->ipv6_proto, saddr,
-			      ipv6_key->ipv6_src, true);
-		memcpy(&key->ipv6.addr.src, ipv6_key->ipv6_src,
-		       sizeof(ipv6_key->ipv6_src));
-	}
 
-	if (memcmp(ipv6_key->ipv6_dst, daddr, sizeof(ipv6_key->ipv6_dst))) {
+	/* Setting an IP addresses is typically only a side effect of
+	 * matching on them in the current userspace implementation, so it
+	 * makes sense to check if the value actually changed.
+	 */
+	if (is_ipv6_mask_nonzero(mask->ipv6_src)) {
+		__be32 *saddr = (__be32 *)&nh->saddr;
+		__be32 masked[4];
+
+		mask_ipv6_addr(saddr, key->ipv6_src, mask->ipv6_src, masked);
+
+		if (unlikely(memcmp(saddr, masked, sizeof(masked)))) {
+			set_ipv6_addr(skb, key->ipv6_proto, saddr, masked,
+				      true);
+			memcpy(&flow_key->ipv6.addr.src, masked,
+			       sizeof(flow_key->ipv6.addr.src));
+		}
+	}
+	if (is_ipv6_mask_nonzero(mask->ipv6_dst)) {
 		unsigned int offset = 0;
 		int flags = IP6_FH_F_SKIP_RH;
 		bool recalc_csum = true;
-
-		if (ipv6_ext_hdr(nh->nexthdr))
-			recalc_csum = ipv6_find_hdr(skb, &offset,
-						    NEXTHDR_ROUTING, NULL,
-						    &flags) != NEXTHDR_ROUTING;
-
-		set_ipv6_addr(skb, ipv6_key->ipv6_proto, daddr,
-			      ipv6_key->ipv6_dst, recalc_csum);
-		memcpy(&key->ipv6.addr.dst, ipv6_key->ipv6_dst,
-		       sizeof(ipv6_key->ipv6_dst));
+		__be32 *daddr = (__be32 *)&nh->daddr;
+		__be32 masked[4];
+
+		mask_ipv6_addr(daddr, key->ipv6_dst, mask->ipv6_dst, masked);
+
+		if (unlikely(memcmp(daddr, masked, sizeof(masked)))) {
+			if (ipv6_ext_hdr(nh->nexthdr))
+				recalc_csum = (ipv6_find_hdr(skb, &offset,
+							     NEXTHDR_ROUTING,
+							     NULL, &flags)
+					       != NEXTHDR_ROUTING);
+
+			set_ipv6_addr(skb, key->ipv6_proto, daddr, masked,
+				      recalc_csum);
+			memcpy(&flow_key->ipv6.addr.dst, masked,
+			       sizeof(flow_key->ipv6.addr.dst));
+		}
+	}
+	if (mask->ipv6_tclass) {
+		ipv6_change_dsfield(nh, ~mask->ipv6_tclass, key->ipv6_tclass);
+		flow_key->ip.tos = ipv6_get_dsfield(nh);
+	}
+	if (mask->ipv6_label) {
+		set_ipv6_fl(nh, ntohl(key->ipv6_label),
+			    ntohl(mask->ipv6_label));
+		flow_key->ipv6.label =
+		    *(__be32 *)nh & htonl(IPV6_FLOWINFO_FLOWLABEL);
+	}
+	if (mask->ipv6_hlimit) {
+		SET_MASKED(nh->hop_limit, key->ipv6_hlimit, mask->ipv6_hlimit);
+		flow_key->ip.ttl = nh->hop_limit;
 	}
-
-	set_ipv6_tc(nh, ipv6_key->ipv6_tclass);
-	key->ip.tos = ipv6_get_dsfield(nh);
-
-	set_ipv6_fl(nh, ntohl(ipv6_key->ipv6_label));
-	key->ipv6.label = *(__be32 *)nh & htonl(IPV6_FLOWINFO_FLOWLABEL);
-
-	nh->hop_limit = ipv6_key->ipv6_hlimit;
-	key->ip.ttl = ipv6_key->ipv6_hlimit;
 	return 0;
 }
 
 /* Must follow skb_ensure_writable() since that can move the skb data. */
 static void set_tp_port(struct sk_buff *skb, __be16 *port,
-			 __be16 new_port, __sum16 *check)
+			__be16 new_port, __sum16 *check)
 {
 	inet_proto_csum_replace2(check, skb, *port, new_port, 0);
 	*port = new_port;
-	skb_clear_hash(skb);
-}
-
-static void set_udp_port(struct sk_buff *skb, __be16 *port, __be16 new_port)
-{
-	struct udphdr *uh = udp_hdr(skb);
-
-	if (uh->check && skb->ip_summed != CHECKSUM_PARTIAL) {
-		set_tp_port(skb, port, new_port, &uh->check);
-
-		if (!uh->check)
-			uh->check = CSUM_MANGLED_0;
-	} else {
-		*port = new_port;
-		skb_clear_hash(skb);
-	}
 }
 
-static int set_udp(struct sk_buff *skb, struct sw_flow_key *key,
-		   const struct ovs_key_udp *udp_port_key)
+static int set_udp(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		   const struct ovs_key_udp *key,
+		   const struct ovs_key_udp *mask)
 {
 	struct udphdr *uh;
+	__be16 src, dst;
 	int err;
 
 	err = skb_ensure_writable(skb, skb_transport_offset(skb) +
@@ -457,23 +508,40 @@ static int set_udp(struct sk_buff *skb, struct sw_flow_key *key,
 		return err;
 
 	uh = udp_hdr(skb);
-	if (udp_port_key->udp_src != uh->source) {
-		set_udp_port(skb, &uh->source, udp_port_key->udp_src);
-		key->tp.src = udp_port_key->udp_src;
-	}
+	/* Either of the masks is non-zero, so do not bother checking them. */
+	src = MASKED(uh->source, key->udp_src, mask->udp_src);
+	dst = MASKED(uh->dest, key->udp_dst, mask->udp_dst);
 
-	if (udp_port_key->udp_dst != uh->dest) {
-		set_udp_port(skb, &uh->dest, udp_port_key->udp_dst);
-		key->tp.dst = udp_port_key->udp_dst;
+	if (uh->check && skb->ip_summed != CHECKSUM_PARTIAL) {
+		if (likely(src != uh->source)) {
+			set_tp_port(skb, &uh->source, src, &uh->check);
+			flow_key->tp.src = src;
+		}
+		if (likely(dst != uh->dest)) {
+			set_tp_port(skb, &uh->dest, dst, &uh->check);
+			flow_key->tp.dst = dst;
+		}
+
+		if (unlikely(!uh->check))
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		uh->source = src;
+		uh->dest = dst;
+		flow_key->tp.src = src;
+		flow_key->tp.dst = dst;
 	}
 
+	skb_clear_hash(skb);
+
 	return 0;
 }
 
-static int set_tcp(struct sk_buff *skb, struct sw_flow_key *key,
-		   const struct ovs_key_tcp *tcp_port_key)
+static int set_tcp(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		   const struct ovs_key_tcp *key,
+		   const struct ovs_key_tcp *mask)
 {
 	struct tcphdr *th;
+	__be16 src, dst;
 	int err;
 
 	err = skb_ensure_writable(skb, skb_transport_offset(skb) +
@@ -482,50 +550,49 @@ static int set_tcp(struct sk_buff *skb, struct sw_flow_key *key,
 		return err;
 
 	th = tcp_hdr(skb);
-	if (tcp_port_key->tcp_src != th->source) {
-		set_tp_port(skb, &th->source, tcp_port_key->tcp_src, &th->check);
-		key->tp.src = tcp_port_key->tcp_src;
+	src = MASKED(th->source, key->tcp_src, mask->tcp_src);
+	if (likely(src != th->source)) {
+		set_tp_port(skb, &th->source, src, &th->check);
+		flow_key->tp.src = src;
 	}
-
-	if (tcp_port_key->tcp_dst != th->dest) {
-		set_tp_port(skb, &th->dest, tcp_port_key->tcp_dst, &th->check);
-		key->tp.dst = tcp_port_key->tcp_dst;
+	dst = MASKED(th->dest, key->tcp_dst, mask->tcp_dst);
+	if (likely(dst != th->dest)) {
+		set_tp_port(skb, &th->dest, dst, &th->check);
+		flow_key->tp.dst = dst;
 	}
+	skb_clear_hash(skb);
 
 	return 0;
 }
 
-static int set_sctp(struct sk_buff *skb, struct sw_flow_key *key,
-		    const struct ovs_key_sctp *sctp_port_key)
+static int set_sctp(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		    const struct ovs_key_sctp *key,
+		    const struct ovs_key_sctp *mask)
 {
+	unsigned int sctphoff = skb_transport_offset(skb);
 	struct sctphdr *sh;
+	__le32 old_correct_csum, new_csum, old_csum;
 	int err;
-	unsigned int sctphoff = skb_transport_offset(skb);
 
 	err = skb_ensure_writable(skb, sctphoff + sizeof(struct sctphdr));
 	if (unlikely(err))
 		return err;
 
 	sh = sctp_hdr(skb);
-	if (sctp_port_key->sctp_src != sh->source ||
-	    sctp_port_key->sctp_dst != sh->dest) {
-		__le32 old_correct_csum, new_csum, old_csum;
+	old_csum = sh->checksum;
+	old_correct_csum = sctp_compute_cksum(skb, sctphoff);
 
-		old_csum = sh->checksum;
-		old_correct_csum = sctp_compute_cksum(skb, sctphoff);
+	sh->source = MASKED(sh->source, key->sctp_src, mask->sctp_src);
+	sh->dest = MASKED(sh->dest, key->sctp_dst, mask->sctp_dst);
 
-		sh->source = sctp_port_key->sctp_src;
-		sh->dest = sctp_port_key->sctp_dst;
+	new_csum = sctp_compute_cksum(skb, sctphoff);
 
-		new_csum = sctp_compute_cksum(skb, sctphoff);
+	/* Carry any checksum errors through. */
+	sh->checksum = old_csum ^ old_correct_csum ^ new_csum;
 
-		/* Carry any checksum errors through. */
-		sh->checksum = old_csum ^ old_correct_csum ^ new_csum;
-
-		skb_clear_hash(skb);
-		key->tp.src = sctp_port_key->sctp_src;
-		key->tp.dst = sctp_port_key->sctp_dst;
-	}
+	skb_clear_hash(skb);
+	flow_key->tp.src = sh->source;
+	flow_key->tp.dst = sh->dest;
 
 	return 0;
 }
@@ -653,52 +720,77 @@ static void execute_hash(struct sk_buff *skb, struct sw_flow_key *key,
 	key->ovs_flow_hash = hash;
 }
 
-static int execute_set_action(struct sk_buff *skb, struct sw_flow_key *key,
-			      const struct nlattr *nested_attr)
+static int execute_set_action(struct sk_buff *skb,
+			      struct sw_flow_key *flow_key,
+			      const struct nlattr *a)
+{
+	/* Only tunnel set execution is supported without a mask. */
+	if (nla_type(a) == OVS_KEY_ATTR_TUNNEL_INFO) {
+		OVS_CB(skb)->egress_tun_info = nla_data(a);
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+/* Mask is at the midpoint of the data. */
+#define get_mask(a, type) ((const type)nla_data(a) + 1)
+
+static int execute_masked_set_action(struct sk_buff *skb,
+				     struct sw_flow_key *flow_key,
+				     const struct nlattr *a)
 {
 	int err = 0;
 
-	switch (nla_type(nested_attr)) {
+	switch (nla_type(a)) {
 	case OVS_KEY_ATTR_PRIORITY:
-		skb->priority = nla_get_u32(nested_attr);
-		key->phy.priority = skb->priority;
+		SET_MASKED(skb->priority, nla_get_u32(a), *get_mask(a, u32 *));
+		flow_key->phy.priority = skb->priority;
 		break;
 
 	case OVS_KEY_ATTR_SKB_MARK:
-		skb->mark = nla_get_u32(nested_attr);
-		key->phy.skb_mark = skb->mark;
+		SET_MASKED(skb->mark, nla_get_u32(a), *get_mask(a, u32 *));
+		flow_key->phy.skb_mark = skb->mark;
 		break;
 
 	case OVS_KEY_ATTR_TUNNEL_INFO:
-		OVS_CB(skb)->egress_tun_info = nla_data(nested_attr);
+		/* Masked data not supported for tunnel. */
+		err = -EINVAL;
 		break;
 
 	case OVS_KEY_ATTR_ETHERNET:
-		err = set_eth_addr(skb, key, nla_data(nested_attr));
+		err = set_eth_addr(skb, flow_key, nla_data(a),
+				   get_mask(a, struct ovs_key_ethernet *));
 		break;
 
 	case OVS_KEY_ATTR_IPV4:
-		err = set_ipv4(skb, key, nla_data(nested_attr));
+		err = set_ipv4(skb, flow_key, nla_data(a),
+			       get_mask(a, struct ovs_key_ipv4 *));
 		break;
 
 	case OVS_KEY_ATTR_IPV6:
-		err = set_ipv6(skb, key, nla_data(nested_attr));
+		err = set_ipv6(skb, flow_key, nla_data(a),
+			       get_mask(a, struct ovs_key_ipv6 *));
 		break;
 
 	case OVS_KEY_ATTR_TCP:
-		err = set_tcp(skb, key, nla_data(nested_attr));
+		err = set_tcp(skb, flow_key, nla_data(a),
+			      get_mask(a, struct ovs_key_tcp *));
 		break;
 
 	case OVS_KEY_ATTR_UDP:
-		err = set_udp(skb, key, nla_data(nested_attr));
+		err = set_udp(skb, flow_key, nla_data(a),
+			      get_mask(a, struct ovs_key_udp *));
 		break;
 
 	case OVS_KEY_ATTR_SCTP:
-		err = set_sctp(skb, key, nla_data(nested_attr));
+		err = set_sctp(skb, flow_key, nla_data(a),
+			       get_mask(a, struct ovs_key_sctp *));
 		break;
 
 	case OVS_KEY_ATTR_MPLS:
-		err = set_mpls(skb, key, nla_data(nested_attr));
+		err = set_mpls(skb, flow_key, nla_data(a), get_mask(a,
+								    __be32 *));
 		break;
 	}
 
@@ -818,6 +910,11 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = execute_set_action(skb, key, nla_data(a));
 			break;
 
+		case OVS_ACTION_ATTR_SET_MASKED:
+		case OVS_ACTION_ATTR_SET_TO_MASKED:
+			err = execute_masked_set_action(skb, key, nla_data(a));
+			break;
+
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, key, a);
 			break;
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 8b9a612..993281e 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1695,16 +1695,6 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	return 0;
 }
 
-static int validate_tp_port(const struct sw_flow_key *flow_key,
-			    __be16 eth_type)
-{
-	if ((eth_type == htons(ETH_P_IP) || eth_type == htons(ETH_P_IPV6)) &&
-	    (flow_key->tp.src || flow_key->tp.dst))
-		return 0;
-
-	return -EINVAL;
-}
-
 void ovs_match_init(struct sw_flow_match *match,
 		    struct sw_flow_key *key,
 		    struct sw_flow_mask *mask)
@@ -1805,23 +1795,45 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	return err;
 }
 
+/* Return false if there are any non-masked bits set.
+ * Mask follows data immediately, before any netlink padding.
+ */
+static bool validate_masked(u8 *data, int len)
+{
+	u8 *mask = data + len;
+
+	while (len--)
+		if (*data++ & ~*mask++)
+			return false;
+
+	return true;
+}
+
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key,
 			struct sw_flow_actions **sfa,
-			bool *set_tun, __be16 eth_type, bool log)
+			bool *skip_copy, __be16 eth_type, bool masked, bool log)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
+	size_t key_len;
 
 	/* There can be only one key in a action */
 	if (nla_total_size(nla_len(ovs_key)) != nla_len(a))
 		return -EINVAL;
 
+	key_len = nla_len(ovs_key);
+	if (masked)
+		key_len /= 2;
+
 	if (key_type > OVS_KEY_ATTR_MAX ||
-	    (ovs_key_lens[key_type].len != nla_len(ovs_key) &&
+	    (ovs_key_lens[key_type].len != key_len &&
 	     ovs_key_lens[key_type].len != OVS_ATTR_NESTED))
 		return -EINVAL;
 
+	if (masked && !validate_masked(nla_data(ovs_key), key_len))
+		return -EINVAL;
+
 	switch (key_type) {
 	const struct ovs_key_ipv4 *ipv4_key;
 	const struct ovs_key_ipv6 *ipv6_key;
@@ -1836,7 +1848,10 @@ static int validate_set(const struct nlattr *a,
 		if (eth_p_mpls(eth_type))
 			return -EINVAL;
 
-		*set_tun = true;
+		if (masked)
+			return -EINVAL; /* Masked tunnel set not supported. */
+
+		*skip_copy = true;
 		err = validate_and_copy_set_tun(a, sfa, log);
 		if (err)
 			return err;
@@ -1846,48 +1861,66 @@ static int validate_set(const struct nlattr *a,
 		if (eth_type != htons(ETH_P_IP))
 			return -EINVAL;
 
-		if (!flow_key->ip.proto)
-			return -EINVAL;
-
 		ipv4_key = nla_data(ovs_key);
-		if (ipv4_key->ipv4_proto != flow_key->ip.proto)
-			return -EINVAL;
 
-		if (ipv4_key->ipv4_frag != flow_key->ip.frag)
-			return -EINVAL;
+		if (masked) {
+			const struct ovs_key_ipv4 *mask = ipv4_key + 1;
 
+			/* Non-writeable fields. */
+			if (mask->ipv4_proto || mask->ipv4_frag)
+				return -EINVAL;
+		} else {
+			if (ipv4_key->ipv4_proto != flow_key->ip.proto)
+				return -EINVAL;
+
+			if (ipv4_key->ipv4_frag != flow_key->ip.frag)
+				return -EINVAL;
+		}
 		break;
 
 	case OVS_KEY_ATTR_IPV6:
 		if (eth_type != htons(ETH_P_IPV6))
 			return -EINVAL;
 
-		if (!flow_key->ip.proto)
-			return -EINVAL;
-
 		ipv6_key = nla_data(ovs_key);
-		if (ipv6_key->ipv6_proto != flow_key->ip.proto)
-			return -EINVAL;
 
-		if (ipv6_key->ipv6_frag != flow_key->ip.frag)
-			return -EINVAL;
+		if (masked) {
+			const struct ovs_key_ipv6 *mask = ipv6_key + 1;
+
+			/* Non-writeable fields. */
+			if (mask->ipv6_proto || mask->ipv6_frag)
+				return -EINVAL;
+
+			/* Invalid bits in the flow label mask? */
+			if (ntohl(mask->ipv6_label) & 0xFFF00000)
+				return -EINVAL;
+		} else {
+			if (ipv6_key->ipv6_proto != flow_key->ip.proto)
+				return -EINVAL;
 
+			if (ipv6_key->ipv6_frag != flow_key->ip.frag)
+				return -EINVAL;
+		}
 		if (ntohl(ipv6_key->ipv6_label) & 0xFFF00000)
 			return -EINVAL;
 
 		break;
 
 	case OVS_KEY_ATTR_TCP:
-		if (flow_key->ip.proto != IPPROTO_TCP)
+		if ((eth_type != htons(ETH_P_IP) &&
+		     eth_type != htons(ETH_P_IPV6)) ||
+		    flow_key->ip.proto != IPPROTO_TCP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key, eth_type);
+		break;
 
 	case OVS_KEY_ATTR_UDP:
-		if (flow_key->ip.proto != IPPROTO_UDP)
+		if ((eth_type != htons(ETH_P_IP) &&
+		     eth_type != htons(ETH_P_IPV6)) ||
+		    flow_key->ip.proto != IPPROTO_UDP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key, eth_type);
+		break;
 
 	case OVS_KEY_ATTR_MPLS:
 		if (!eth_p_mpls(eth_type))
@@ -1895,15 +1928,45 @@ static int validate_set(const struct nlattr *a,
 		break;
 
 	case OVS_KEY_ATTR_SCTP:
-		if (flow_key->ip.proto != IPPROTO_SCTP)
+		if ((eth_type != htons(ETH_P_IP) &&
+		     eth_type != htons(ETH_P_IPV6)) ||
+		    flow_key->ip.proto != IPPROTO_SCTP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key, eth_type);
+		break;
 
 	default:
 		return -EINVAL;
 	}
 
+	/* Convert non-masked non-tunnel set actions to masked set actions. */
+	if (!masked && key_type != OVS_KEY_ATTR_TUNNEL) {
+		int start, len = key_len * 2;
+		struct nlattr *at;
+
+		*skip_copy = true;
+
+		start = add_nested_action_start(sfa,
+						OVS_ACTION_ATTR_SET_TO_MASKED,
+						log);
+		if (start < 0)
+			return start;
+
+		at = __add_action(sfa, key_type, NULL, len, log);
+		if (IS_ERR(at))
+			return PTR_ERR(at);
+
+		memcpy(nla_data(at), nla_data(ovs_key), key_len); /* Key. */
+		memset(nla_data(at) + key_len, 0xff, key_len);    /* Mask. */
+		/* Clear non-writeable bits from otherwise writeable fields. */
+		if (key_type == OVS_KEY_ATTR_IPV6) {
+			struct ovs_key_ipv6 *mask = nla_data(at) + key_len;
+
+			mask->ipv6_label &= htonl(0x000FFFFF);
+		}
+		add_nested_action_end(*sfa, start);
+	}
+
 	return 0;
 }
 
@@ -1965,6 +2028,7 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
+			[OVS_ACTION_ATTR_SET_MASKED] = (u32)-1,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
 			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash)
 		};
@@ -2060,7 +2124,14 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_SET:
 			err = validate_set(a, key, sfa,
-					   &skip_copy, eth_type, log);
+					   &skip_copy, eth_type, false, log);
+			if (err)
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_SET_MASKED:
+			err = validate_set(a, key, sfa,
+					   &skip_copy, eth_type, true, log);
 			if (err)
 				return err;
 			break;
@@ -2090,6 +2161,7 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 	return 0;
 }
 
+/* 'key' must be the masked key. */
 int ovs_nla_copy_actions(const struct nlattr *attr,
 			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa, bool log)
@@ -2177,6 +2249,21 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 	return 0;
 }
 
+static int masked_set_action_to_set_action_attr(const struct nlattr *a,
+						struct sk_buff *skb)
+{
+	const struct nlattr *ovs_key = nla_data(a);
+	size_t key_len = nla_len(ovs_key) / 2;
+
+	/* Revert the conversion we did from a non-masked set action to
+	 * masked set action.
+	 */
+	if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a) - key_len, ovs_key))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 int ovs_nla_put_actions(const struct nlattr *attr, int len, struct sk_buff *skb)
 {
 	const struct nlattr *a;
@@ -2192,6 +2279,12 @@ int ovs_nla_put_actions(const struct nlattr *attr, int len, struct sk_buff *skb)
 				return err;
 			break;
 
+		case OVS_ACTION_ATTR_SET_TO_MASKED:
+			err = masked_set_action_to_set_action_attr(a, skb);
+			if (err)
+				return err;
+			break;
+
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample_action_to_attr(a, skb);
 			if (err)
-- 
1.7.10.4
