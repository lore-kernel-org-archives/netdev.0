From: Joe Stringer <joestringer@nicira.com>
Subject: [RFC net-next 2/4] openvswitch: Move MASKED* macros to datapath.h.
Date: Sat, 14 Feb 2015 00:13:51 -0800
Message-ID: <1423901633-53789-3-git-send-email-joestringer@nicira.com>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Justin Pettit <jpettit@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:37369 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753853AbbBNIOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 03:14:03 -0500
Received: by mail-ie0-f169.google.com with SMTP id rp18so9235932iec.1
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 00:14:02 -0800 (PST)
In-Reply-To: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow the ovs-conntrack code to reuse these macros.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/actions.c  |   52 +++++++++++++++++++++-----------------------
 net/openvswitch/datapath.h |    4 ++++
 2 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b491c1c..ed3cb56 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -185,10 +185,6 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
-/* 'KEY' must not have any bits set outside of the 'MASK' */
-#define MASKED(OLD, KEY, MASK) ((KEY) | ((OLD) & ~(MASK)))
-#define SET_MASKED(OLD, KEY, MASK) ((OLD) = MASKED(OLD, KEY, MASK))
-
 static int set_mpls(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		    const __be32 *mpls_lse, const __be32 *mask)
 {
@@ -201,7 +197,7 @@ static int set_mpls(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		return err;
 
 	stack = (__be32 *)skb_mpls_header(skb);
-	lse = MASKED(*stack, *mpls_lse, *mask);
+	lse = OVS_MASKED(*stack, *mpls_lse, *mask);
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		__be32 diff[] = { ~(*stack), lse };
 
@@ -244,9 +240,9 @@ static void ether_addr_copy_masked(u8 *dst_, const u8 *src_, const u8 *mask_)
 	const u16 *src = (const u16 *)src_;
 	const u16 *mask = (const u16 *)mask_;
 
-	SET_MASKED(dst[0], src[0], mask[0]);
-	SET_MASKED(dst[1], src[1], mask[1]);
-	SET_MASKED(dst[2], src[2], mask[2]);
+	OVS_SET_MASKED(dst[0], src[0], mask[0]);
+	OVS_SET_MASKED(dst[1], src[1], mask[1]);
+	OVS_SET_MASKED(dst[2], src[2], mask[2]);
 }
 
 static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
@@ -330,10 +326,10 @@ static void update_ipv6_checksum(struct sk_buff *skb, u8 l4_proto,
 static void mask_ipv6_addr(const __be32 old[4], const __be32 addr[4],
 			   const __be32 mask[4], __be32 masked[4])
 {
-	masked[0] = MASKED(old[0], addr[0], mask[0]);
-	masked[1] = MASKED(old[1], addr[1], mask[1]);
-	masked[2] = MASKED(old[2], addr[2], mask[2]);
-	masked[3] = MASKED(old[3], addr[3], mask[3]);
+	masked[0] = OVS_MASKED(old[0], addr[0], mask[0]);
+	masked[1] = OVS_MASKED(old[1], addr[1], mask[1]);
+	masked[2] = OVS_MASKED(old[2], addr[2], mask[2]);
+	masked[3] = OVS_MASKED(old[3], addr[3], mask[3]);
 }
 
 static void set_ipv6_addr(struct sk_buff *skb, u8 l4_proto,
@@ -350,15 +346,15 @@ static void set_ipv6_addr(struct sk_buff *skb, u8 l4_proto,
 static void set_ipv6_fl(struct ipv6hdr *nh, u32 fl, u32 mask)
 {
 	/* Bits 21-24 are always unmasked, so this retains their values. */
-	SET_MASKED(nh->flow_lbl[0], (u8)(fl >> 16), (u8)(mask >> 16));
-	SET_MASKED(nh->flow_lbl[1], (u8)(fl >> 8), (u8)(mask >> 8));
-	SET_MASKED(nh->flow_lbl[2], (u8)fl, (u8)mask);
+	OVS_SET_MASKED(nh->flow_lbl[0], (u8)(fl >> 16), (u8)(mask >> 16));
+	OVS_SET_MASKED(nh->flow_lbl[1], (u8)(fl >> 8), (u8)(mask >> 8));
+	OVS_SET_MASKED(nh->flow_lbl[2], (u8)fl, (u8)mask);
 }
 
 static void set_ip_ttl(struct sk_buff *skb, struct iphdr *nh, u8 new_ttl,
 		       u8 mask)
 {
-	new_ttl = MASKED(nh->ttl, new_ttl, mask);
+	new_ttl = OVS_MASKED(nh->ttl, new_ttl, mask);
 
 	csum_replace2(&nh->check, htons(nh->ttl << 8), htons(new_ttl << 8));
 	nh->ttl = new_ttl;
@@ -384,7 +380,7 @@ static int set_ipv4(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	 * makes sense to check if the value actually changed.
 	 */
 	if (mask->ipv4_src) {
-		new_addr = MASKED(nh->saddr, key->ipv4_src, mask->ipv4_src);
+		new_addr = OVS_MASKED(nh->saddr, key->ipv4_src, mask->ipv4_src);
 
 		if (unlikely(new_addr != nh->saddr)) {
 			set_ip_addr(skb, nh, &nh->saddr, new_addr);
@@ -392,7 +388,7 @@ static int set_ipv4(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		}
 	}
 	if (mask->ipv4_dst) {
-		new_addr = MASKED(nh->daddr, key->ipv4_dst, mask->ipv4_dst);
+		new_addr = OVS_MASKED(nh->daddr, key->ipv4_dst, mask->ipv4_dst);
 
 		if (unlikely(new_addr != nh->daddr)) {
 			set_ip_addr(skb, nh, &nh->daddr, new_addr);
@@ -480,7 +476,8 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		    *(__be32 *)nh & htonl(IPV6_FLOWINFO_FLOWLABEL);
 	}
 	if (mask->ipv6_hlimit) {
-		SET_MASKED(nh->hop_limit, key->ipv6_hlimit, mask->ipv6_hlimit);
+		OVS_SET_MASKED(nh->hop_limit, key->ipv6_hlimit,
+			       mask->ipv6_hlimit);
 		flow_key->ip.ttl = nh->hop_limit;
 	}
 	return 0;
@@ -509,8 +506,8 @@ static int set_udp(struct sk_buff *skb, struct sw_flow_key *flow_key,
 
 	uh = udp_hdr(skb);
 	/* Either of the masks is non-zero, so do not bother checking them. */
-	src = MASKED(uh->source, key->udp_src, mask->udp_src);
-	dst = MASKED(uh->dest, key->udp_dst, mask->udp_dst);
+	src = OVS_MASKED(uh->source, key->udp_src, mask->udp_src);
+	dst = OVS_MASKED(uh->dest, key->udp_dst, mask->udp_dst);
 
 	if (uh->check && skb->ip_summed != CHECKSUM_PARTIAL) {
 		if (likely(src != uh->source)) {
@@ -550,12 +547,12 @@ static int set_tcp(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		return err;
 
 	th = tcp_hdr(skb);
-	src = MASKED(th->source, key->tcp_src, mask->tcp_src);
+	src = OVS_MASKED(th->source, key->tcp_src, mask->tcp_src);
 	if (likely(src != th->source)) {
 		set_tp_port(skb, &th->source, src, &th->check);
 		flow_key->tp.src = src;
 	}
-	dst = MASKED(th->dest, key->tcp_dst, mask->tcp_dst);
+	dst = OVS_MASKED(th->dest, key->tcp_dst, mask->tcp_dst);
 	if (likely(dst != th->dest)) {
 		set_tp_port(skb, &th->dest, dst, &th->check);
 		flow_key->tp.dst = dst;
@@ -582,8 +579,8 @@ static int set_sctp(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	old_csum = sh->checksum;
 	old_correct_csum = sctp_compute_cksum(skb, sctphoff);
 
-	sh->source = MASKED(sh->source, key->sctp_src, mask->sctp_src);
-	sh->dest = MASKED(sh->dest, key->sctp_dst, mask->sctp_dst);
+	sh->source = OVS_MASKED(sh->source, key->sctp_src, mask->sctp_src);
+	sh->dest = OVS_MASKED(sh->dest, key->sctp_dst, mask->sctp_dst);
 
 	new_csum = sctp_compute_cksum(skb, sctphoff);
 
@@ -744,12 +741,13 @@ static int execute_masked_set_action(struct sk_buff *skb,
 
 	switch (nla_type(a)) {
 	case OVS_KEY_ATTR_PRIORITY:
-		SET_MASKED(skb->priority, nla_get_u32(a), *get_mask(a, u32 *));
+		OVS_SET_MASKED(skb->priority, nla_get_u32(a),
+			       *get_mask(a, u32 *));
 		flow_key->phy.priority = skb->priority;
 		break;
 
 	case OVS_KEY_ATTR_SKB_MARK:
-		SET_MASKED(skb->mark, nla_get_u32(a), *get_mask(a, u32 *));
+		OVS_SET_MASKED(skb->mark, nla_get_u32(a), *get_mask(a, u32 *));
 		flow_key->phy.skb_mark = skb->mark;
 		break;
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 3ece945..9661a01 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -199,6 +199,10 @@ void ovs_dp_notify_wq(struct work_struct *work);
 int action_fifos_init(void);
 void action_fifos_exit(void);
 
+/* 'KEY' must not have any bits set outside of the 'MASK' */
+#define OVS_MASKED(OLD, KEY, MASK) ((KEY) | ((OLD) & ~(MASK)))
+#define OVS_SET_MASKED(OLD, KEY, MASK) ((OLD) = OVS_MASKED(OLD, KEY, MASK))
+
 #define OVS_NLERR(logging_allowed, fmt, ...)			\
 do {								\
 	if (logging_allowed && net_ratelimit())			\
-- 
1.7.10.4
