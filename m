From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/2] openvswitch: remove skb_mpls_header
Date: Thu, 29 Sep 2016 21:19:48 +0200
Message-ID: <e32cd7d5d03b4cb86a872e76730aa29a2f7d9e38.1475176437.git.jbenc@redhat.com>
References: <cover.1475176437.git.jbenc@redhat.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49352 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754801AbcI2TUL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 15:20:11 -0400
In-Reply-To: <cover.1475176437.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_mpls_header is equivalent to skb_network_header now. There's no reason
to keep it.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/mpls.h        | 11 -----------
 net/openvswitch/actions.c | 10 +++++-----
 2 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/include/net/mpls.h b/include/net/mpls.h
index 5b3b5addfb08..fde22d0b0ec1 100644
--- a/include/net/mpls.h
+++ b/include/net/mpls.h
@@ -25,15 +25,4 @@ static inline bool eth_p_mpls(__be16 eth_type)
 		eth_type == htons(ETH_P_MPLS_MC);
 }
 
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
index 863e992dfbc0..bf4211f5c974 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -180,7 +180,7 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->mac_len);
 
-	new_mpls_lse = (__be32 *)skb_mpls_header(skb);
+	new_mpls_lse = (__be32 *)skb_network_header(skb);
 	*new_mpls_lse = mpls->mpls_lse;
 
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
@@ -202,7 +202,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	if (unlikely(err))
 		return err;
 
-	skb_postpull_rcsum(skb, skb_mpls_header(skb), MPLS_HLEN);
+	skb_postpull_rcsum(skb, skb_network_header(skb), MPLS_HLEN);
 
 	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
 		skb->mac_len);
@@ -211,10 +211,10 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->mac_len);
 
-	/* skb_mpls_header() is used to locate the ethertype
+	/* skb_network_header() is used to locate the ethertype
 	 * field correctly in the presence of VLAN tags.
 	 */
-	hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
+	hdr = (struct ethhdr *)(skb_network_header(skb) - ETH_HLEN);
 	update_ethertype(skb, hdr, ethertype);
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
@@ -234,7 +234,7 @@ static int set_mpls(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	if (unlikely(err))
 		return err;
 
-	stack = (__be32 *)skb_mpls_header(skb);
+	stack = (__be32 *)skb_network_header(skb);
 	lse = OVS_MASKED(*stack, *mpls_lse, *mask);
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		__be32 diff[] = { ~(*stack), lse };
-- 
1.8.3.1
