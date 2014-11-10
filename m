From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/6] openvswitch: Optimize recirc action.
Date: Sun,  9 Nov 2014 19:59:14 -0800
Message-ID: <1415591954-1622-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:42677 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752088AbaKJD7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:59:17 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so7396368pab.38
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:59:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS need to flow key for flow lookup in recic action. OVS
does key extract in recic action. Most of cases we could
use OVS_CB packet key directly and can avoid packet flow key
extract. SET action we can update flow-key along with packet
to keep it consistent. But there are some action like MPLS
pop which forces OVS to do flow-extract. In such cases we
can mark flow key as invalid so that subsequent recirc
action can do full flow extract.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Jarno Rajahalme <jrajahalme@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/actions.c | 151 ++++++++++++++++++++++++++++++++--------------
 1 file changed, 106 insertions(+), 45 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ceb618c..d4c2f73 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -109,6 +109,16 @@ static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
 	return da;
 }
 
+static void invalidate_flow_key(struct sw_flow_key *key)
+{
+	key->eth.type = htons(0);
+}
+
+static bool is_flow_key_valid(const struct sw_flow_key *key)
+{
+	return !!key->eth.type;
+}
+
 static int make_writable(struct sk_buff *skb, int write_len)
 {
 	if (!pskb_may_pull(skb, write_len))
@@ -120,7 +130,7 @@ static int make_writable(struct sk_buff *skb, int write_len)
 	return pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 }
 
-static int push_mpls(struct sk_buff *skb,
+static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_mpls *mpls)
 {
 	__be32 *new_mpls_lse;
@@ -151,10 +161,12 @@ static int push_mpls(struct sk_buff *skb,
 	skb_set_inner_protocol(skb, skb->protocol);
 	skb->protocol = mpls->mpls_ethertype;
 
+	invalidate_flow_key(key);
 	return 0;
 }
 
-static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
+static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
+		    const __be16 ethertype)
 {
 	struct ethhdr *hdr;
 	int err;
@@ -181,10 +193,13 @@ static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
 	hdr->h_proto = ethertype;
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
+
+	invalidate_flow_key(key);
 	return 0;
 }
 
-static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
+static int set_mpls(struct sk_buff *skb, struct sw_flow_key *key,
+		    const __be32 *mpls_lse)
 {
 	__be32 *stack;
 	int err;
@@ -196,13 +211,12 @@ static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
 	stack = (__be32 *)skb_mpls_header(skb);
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		__be32 diff[] = { ~(*stack), *mpls_lse };
-
 		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
 					  ~skb->csum);
 	}
 
 	*stack = *mpls_lse;
-
+	key->mpls.top_lse = *mpls_lse;
 	return 0;
 }
 
@@ -237,7 +251,7 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 	return 0;
 }
 
-static int pop_vlan(struct sk_buff *skb)
+static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	__be16 tci;
 	int err;
@@ -255,9 +269,12 @@ static int pop_vlan(struct sk_buff *skb)
 	}
 	/* move next vlan tag to hw accel tag */
 	if (likely(skb->protocol != htons(ETH_P_8021Q) ||
-		   skb->len < VLAN_ETH_HLEN))
+		   skb->len < VLAN_ETH_HLEN)) {
+		key->eth.tci = 0;
 		return 0;
+	}
 
+	invalidate_flow_key(key);
 	err = __pop_vlan_tci(skb, &tci);
 	if (unlikely(err))
 		return err;
@@ -266,7 +283,8 @@ static int pop_vlan(struct sk_buff *skb)
 	return 0;
 }
 
-static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
+static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
+		     const struct ovs_action_push_vlan *vlan)
 {
 	if (unlikely(vlan_tx_tag_present(skb))) {
 		u16 current_tag;
@@ -283,12 +301,15 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
 					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
 
+		invalidate_flow_key(key);
+	} else {
+		key->eth.tci = vlan->vlan_tci;
 	}
 	__vlan_hwaccel_put_tag(skb, vlan->vlan_tpid, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 	return 0;
 }
 
-static int set_eth_addr(struct sk_buff *skb,
+static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *key,
 			const struct ovs_key_ethernet *eth_key)
 {
 	int err;
@@ -303,11 +324,13 @@ static int set_eth_addr(struct sk_buff *skb,
 
 	ovs_skb_postpush_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
 
+	ether_addr_copy(key->eth.src, eth_key->eth_src);
+	ether_addr_copy(key->eth.dst, eth_key->eth_dst);
 	return 0;
 }
 
 static void set_ip_addr(struct sk_buff *skb, struct iphdr *nh,
-				__be32 *addr, __be32 new_addr)
+			__be32 *addr, __be32 new_addr)
 {
 	int transport_len = skb->len - skb_transport_offset(skb);
 
@@ -386,7 +409,8 @@ static void set_ip_ttl(struct sk_buff *skb, struct iphdr *nh, u8 new_ttl)
 	nh->ttl = new_ttl;
 }
 
-static int set_ipv4(struct sk_buff *skb, const struct ovs_key_ipv4 *ipv4_key)
+static int set_ipv4(struct sk_buff *skb, struct sw_flow_key *key,
+		    const struct ovs_key_ipv4 *ipv4_key)
 {
 	struct iphdr *nh;
 	int err;
@@ -398,22 +422,31 @@ static int set_ipv4(struct sk_buff *skb, const struct ovs_key_ipv4 *ipv4_key)
 
 	nh = ip_hdr(skb);
 
-	if (ipv4_key->ipv4_src != nh->saddr)
+	if (ipv4_key->ipv4_src != nh->saddr) {
 		set_ip_addr(skb, nh, &nh->saddr, ipv4_key->ipv4_src);
+		key->ipv4.addr.src = ipv4_key->ipv4_src;
+	}
 
-	if (ipv4_key->ipv4_dst != nh->daddr)
+	if (ipv4_key->ipv4_dst != nh->daddr) {
 		set_ip_addr(skb, nh, &nh->daddr, ipv4_key->ipv4_dst);
+		key->ipv4.addr.dst = ipv4_key->ipv4_dst;
+	}
 
-	if (ipv4_key->ipv4_tos != nh->tos)
+	if (ipv4_key->ipv4_tos != nh->tos) {
 		ipv4_change_dsfield(nh, 0, ipv4_key->ipv4_tos);
+		key->ip.tos = nh->tos;
+	}
 
-	if (ipv4_key->ipv4_ttl != nh->ttl)
+	if (ipv4_key->ipv4_ttl != nh->ttl) {
 		set_ip_ttl(skb, nh, ipv4_key->ipv4_ttl);
+		key->ip.ttl = ipv4_key->ipv4_ttl;
+	}
 
 	return 0;
 }
 
-static int set_ipv6(struct sk_buff *skb, const struct ovs_key_ipv6 *ipv6_key)
+static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *key,
+		    const struct ovs_key_ipv6 *ipv6_key)
 {
 	struct ipv6hdr *nh;
 	int err;
@@ -429,9 +462,12 @@ static int set_ipv6(struct sk_buff *skb, const struct ovs_key_ipv6 *ipv6_key)
 	saddr = (__be32 *)&nh->saddr;
 	daddr = (__be32 *)&nh->daddr;
 
-	if (memcmp(ipv6_key->ipv6_src, saddr, sizeof(ipv6_key->ipv6_src)))
+	if (memcmp(ipv6_key->ipv6_src, saddr, sizeof(ipv6_key->ipv6_src))) {
 		set_ipv6_addr(skb, ipv6_key->ipv6_proto, saddr,
 			      ipv6_key->ipv6_src, true);
+		memcpy(&key->ipv6.addr.src, ipv6_key->ipv6_src,
+		       sizeof(ipv6_key->ipv6_src));
+	}
 
 	if (memcmp(ipv6_key->ipv6_dst, daddr, sizeof(ipv6_key->ipv6_dst))) {
 		unsigned int offset = 0;
@@ -445,12 +481,18 @@ static int set_ipv6(struct sk_buff *skb, const struct ovs_key_ipv6 *ipv6_key)
 
 		set_ipv6_addr(skb, ipv6_key->ipv6_proto, daddr,
 			      ipv6_key->ipv6_dst, recalc_csum);
+		memcpy(&key->ipv6.addr.dst, ipv6_key->ipv6_dst,
+		       sizeof(ipv6_key->ipv6_dst));
 	}
 
 	set_ipv6_tc(nh, ipv6_key->ipv6_tclass);
+	key->ip.tos = ipv6_get_dsfield(nh);
+
 	set_ipv6_fl(nh, ntohl(ipv6_key->ipv6_label));
-	nh->hop_limit = ipv6_key->ipv6_hlimit;
+	key->ipv6.label = *(__be32 *)nh & htonl(IPV6_FLOWINFO_FLOWLABEL);
 
+	nh->hop_limit = ipv6_key->ipv6_hlimit;
+	key->ip.ttl = ipv6_key->ipv6_hlimit;
 	return 0;
 }
 
@@ -478,7 +520,8 @@ static void set_udp_port(struct sk_buff *skb, __be16 *port, __be16 new_port)
 	}
 }
 
-static int set_udp(struct sk_buff *skb, const struct ovs_key_udp *udp_port_key)
+static int set_udp(struct sk_buff *skb, struct sw_flow_key *key,
+		   const struct ovs_key_udp *udp_port_key)
 {
 	struct udphdr *uh;
 	int err;
@@ -489,16 +532,21 @@ static int set_udp(struct sk_buff *skb, const struct ovs_key_udp *udp_port_key)
 		return err;
 
 	uh = udp_hdr(skb);
-	if (udp_port_key->udp_src != uh->source)
+	if (udp_port_key->udp_src != uh->source) {
 		set_udp_port(skb, &uh->source, udp_port_key->udp_src);
+		key->tp.src = udp_port_key->udp_src;
+	}
 
-	if (udp_port_key->udp_dst != uh->dest)
+	if (udp_port_key->udp_dst != uh->dest) {
 		set_udp_port(skb, &uh->dest, udp_port_key->udp_dst);
+		key->tp.dst = udp_port_key->udp_dst;
+	}
 
 	return 0;
 }
 
-static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
+static int set_tcp(struct sk_buff *skb, struct sw_flow_key *key,
+		   const struct ovs_key_tcp *tcp_port_key)
 {
 	struct tcphdr *th;
 	int err;
@@ -509,17 +557,21 @@ static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
 		return err;
 
 	th = tcp_hdr(skb);
-	if (tcp_port_key->tcp_src != th->source)
+	if (tcp_port_key->tcp_src != th->source) {
 		set_tp_port(skb, &th->source, tcp_port_key->tcp_src, &th->check);
+		key->tp.src = tcp_port_key->tcp_src;
+	}
 
-	if (tcp_port_key->tcp_dst != th->dest)
+	if (tcp_port_key->tcp_dst != th->dest) {
 		set_tp_port(skb, &th->dest, tcp_port_key->tcp_dst, &th->check);
+		key->tp.dst = tcp_port_key->tcp_dst;
+	}
 
 	return 0;
 }
 
-static int set_sctp(struct sk_buff *skb,
-		     const struct ovs_key_sctp *sctp_port_key)
+static int set_sctp(struct sk_buff *skb, struct sw_flow_key *key,
+		    const struct ovs_key_sctp *sctp_port_key)
 {
 	struct sctphdr *sh;
 	int err;
@@ -546,6 +598,8 @@ static int set_sctp(struct sk_buff *skb,
 		sh->checksum = old_csum ^ old_correct_csum ^ new_csum;
 
 		skb_clear_hash(skb);
+		key->tp.src = sctp_port_key->sctp_src;
+		key->tp.dst = sctp_port_key->sctp_dst;
 	}
 
 	return 0;
@@ -675,18 +729,20 @@ static void execute_hash(struct sk_buff *skb, struct sw_flow_key *key,
 	key->ovs_flow_hash = hash;
 }
 
-static int execute_set_action(struct sk_buff *skb,
-				 const struct nlattr *nested_attr)
+static int execute_set_action(struct sk_buff *skb, struct sw_flow_key *key,
+			      const struct nlattr *nested_attr)
 {
 	int err = 0;
 
 	switch (nla_type(nested_attr)) {
 	case OVS_KEY_ATTR_PRIORITY:
 		skb->priority = nla_get_u32(nested_attr);
+		key->phy.priority = skb->priority;
 		break;
 
 	case OVS_KEY_ATTR_SKB_MARK:
 		skb->mark = nla_get_u32(nested_attr);
+		key->phy.skb_mark = skb->mark;
 		break;
 
 	case OVS_KEY_ATTR_TUNNEL_INFO:
@@ -694,31 +750,31 @@ static int execute_set_action(struct sk_buff *skb,
 		break;
 
 	case OVS_KEY_ATTR_ETHERNET:
-		err = set_eth_addr(skb, nla_data(nested_attr));
+		err = set_eth_addr(skb, key, nla_data(nested_attr));
 		break;
 
 	case OVS_KEY_ATTR_IPV4:
-		err = set_ipv4(skb, nla_data(nested_attr));
+		err = set_ipv4(skb, key, nla_data(nested_attr));
 		break;
 
 	case OVS_KEY_ATTR_IPV6:
-		err = set_ipv6(skb, nla_data(nested_attr));
+		err = set_ipv6(skb, key, nla_data(nested_attr));
 		break;
 
 	case OVS_KEY_ATTR_TCP:
-		err = set_tcp(skb, nla_data(nested_attr));
+		err = set_tcp(skb, key, nla_data(nested_attr));
 		break;
 
 	case OVS_KEY_ATTR_UDP:
-		err = set_udp(skb, nla_data(nested_attr));
+		err = set_udp(skb, key, nla_data(nested_attr));
 		break;
 
 	case OVS_KEY_ATTR_SCTP:
-		err = set_sctp(skb, nla_data(nested_attr));
+		err = set_sctp(skb, key, nla_data(nested_attr));
 		break;
 
 	case OVS_KEY_ATTR_MPLS:
-		err = set_mpls(skb, nla_data(nested_attr));
+		err = set_mpls(skb, key, nla_data(nested_attr));
 		break;
 	}
 
@@ -730,11 +786,15 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 			  const struct nlattr *a, int rem)
 {
 	struct deferred_action *da;
-	int err;
 
-	err = ovs_flow_key_update(skb, key);
-	if (err)
-		return err;
+	if (!is_flow_key_valid(key)) {
+		int err;
+
+		err = ovs_flow_key_update(skb, key);
+		if (err)
+			return err;
+	}
+	BUG_ON(!is_flow_key_valid(key));
 
 	if (!nla_is_last(a, rem)) {
 		/* Recirc action is the not the last action
@@ -771,7 +831,8 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	/* Every output action needs a separate clone of 'skb', but the common
 	 * case is just a single output action, so that doing a clone and
 	 * then freeing the original skbuff is wasteful.  So the following code
-	 * is slightly obscure just to avoid that. */
+	 * is slightly obscure just to avoid that.
+	 */
 	int prev_port = -1;
 	const struct nlattr *a;
 	int rem;
@@ -803,21 +864,21 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_PUSH_MPLS:
-			err = push_mpls(skb, nla_data(a));
+			err = push_mpls(skb, key, nla_data(a));
 			break;
 
 		case OVS_ACTION_ATTR_POP_MPLS:
-			err = pop_mpls(skb, nla_get_be16(a));
+			err = pop_mpls(skb, key, nla_get_be16(a));
 			break;
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
-			err = push_vlan(skb, nla_data(a));
+			err = push_vlan(skb, key, nla_data(a));
 			if (unlikely(err)) /* skb already freed. */
 				return err;
 			break;
 
 		case OVS_ACTION_ATTR_POP_VLAN:
-			err = pop_vlan(skb);
+			err = pop_vlan(skb, key);
 			break;
 
 		case OVS_ACTION_ATTR_RECIRC:
@@ -832,7 +893,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_SET:
-			err = execute_set_action(skb, nla_data(a));
+			err = execute_set_action(skb, key, nla_data(a));
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-- 
1.9.3
