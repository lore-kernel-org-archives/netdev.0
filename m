From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 3/3] openvswitch: use mpls_hdr
Date: Fri, 30 Sep 2016 19:08:07 +0200
Message-ID: <672d97cf2e761276a9390b72265606bb5cbb6bb6.1475255100.git.jbenc@redhat.com>
References: <cover.1475255100.git.jbenc@redhat.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35374 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933039AbcI3RJG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 13:09:06 -0400
In-Reply-To: <cover.1475255100.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_mpls_header is equivalent to mpls_hdr now. Use the existing helper
instead.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: using the existing mpls_hdr instead of skb_network_header
---
 include/net/mpls.h        | 12 ------------
 net/openvswitch/actions.c | 24 ++++++++++++------------
 2 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/include/net/mpls.h b/include/net/mpls.h
index 3ebbc0bb57ff..1dbc669b770e 100644
--- a/include/net/mpls.h
+++ b/include/net/mpls.h
@@ -33,16 +33,4 @@ static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
 {
 	return (struct mpls_shim_hdr *)skb_network_header(skb);
 }
-
-/*
- * For non-MPLS skbs this will correspond to the network header.
- * For MPLS skbs it will be before the network_header as the MPLS
- * label stack lies between the end of the mac header and the network
- * header. That is, for MPLS skbs the end of the mac header
- * is the top of the MPLS label stack.
- */
-static inline unsigned char *skb_mpls_header(struct sk_buff *skb)
-{
-	return skb_mac_header(skb) + skb->mac_len;
-}
 #endif
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 863e992dfbc0..4e03f64709bc 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -160,7 +160,7 @@ static void update_ethertype(struct sk_buff *skb, struct ethhdr *hdr,
 static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_mpls *mpls)
 {
-	__be32 *new_mpls_lse;
+	struct mpls_shim_hdr *new_mpls_lse;
 
 	/* Networking stack do not allow simultaneous Tunnel and MPLS GSO. */
 	if (skb->encapsulation)
@@ -180,8 +180,8 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->mac_len);
 
-	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
-	*new_mpls_lse = mpls->mpls_lse;
+	new_mpls_lse = mpls_hdr(skb);
+	new_mpls_lse->label_stack_entry = mpls->mpls_lse;
 
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
@@ -202,7 +202,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	if (unlikely(err))
 		return err;
 
-	skb_postpull_rcsum(skb, skb_mpls_header(skb), MPLS_HLEN);
+	skb_postpull_rcsum(skb, mpls_hdr(skb), MPLS_HLEN);
 
 	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
 		skb->mac_len);
@@ -211,10 +211,10 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->mac_len);
 
-	/* skb_mpls_header() is used to locate the ethertype
-	 * field correctly in the presence of VLAN tags.
+	/* mpls_hdr() is used to locate the ethertype field correctly in the
+	 * presence of VLAN tags.
 	 */
-	hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
+	hdr = (struct ethhdr *)((void *)mpls_hdr(skb) - ETH_HLEN);
 	update_ethertype(skb, hdr, ethertype);
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
@@ -226,7 +226,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 static int set_mpls(struct sk_buff *skb, struct sw_flow_key *flow_key,
 		    const __be32 *mpls_lse, const __be32 *mask)
 {
-	__be32 *stack;
+	struct mpls_shim_hdr *stack;
 	__be32 lse;
 	int err;
 
@@ -234,16 +234,16 @@ static int set_mpls(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	if (unlikely(err))
 		return err;
 
-	stack = (__be32 *)skb_mpls_header(skb);
-	lse = OVS_MASKED(*stack, *mpls_lse, *mask);
+	stack = mpls_hdr(skb);
+	lse = OVS_MASKED(stack->label_stack_entry, *mpls_lse, *mask);
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		__be32 diff[] = { ~(*stack), lse };
+		__be32 diff[] = { ~(stack->label_stack_entry), lse };
 
 		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
 					  ~skb->csum);
 	}
 
-	*stack = lse;
+	stack->label_stack_entry = lse;
 	flow_key->mpls.top_lse = lse;
 	return 0;
 }
-- 
1.8.3.1
