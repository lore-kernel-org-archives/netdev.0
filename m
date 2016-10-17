From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v12 4/9] openvswitch: support MPLS push and pop for L3 packets
Date: Mon, 17 Oct 2016 15:02:40 +0200
Message-ID: <004e53f40443698cffdaf8f9839649cc4b9101cc.1476708213.git.jbenc@redhat.com>
References: <cover.1476708212.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757829AbcJQND0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 09:03:26 -0400
In-Reply-To: <cover.1476708212.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Ethernet header only if there is one.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/actions.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index dc8bb97e2258..064cbcb7b0c5 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -187,7 +187,8 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
-	update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
+	if (ovs_key_mac_proto(key) == MAC_PROTO_ETHERNET)
+		update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
 	skb->protocol = mpls->mpls_ethertype;
 
 	invalidate_flow_key(key);
@@ -197,7 +198,6 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		    const __be16 ethertype)
 {
-	struct ethhdr *hdr;
 	int err;
 
 	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
@@ -213,11 +213,15 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->mac_len);
 
-	/* mpls_hdr() is used to locate the ethertype field correctly in the
-	 * presence of VLAN tags.
-	 */
-	hdr = (struct ethhdr *)((void *)mpls_hdr(skb) - ETH_HLEN);
-	update_ethertype(skb, hdr, ethertype);
+	if (ovs_key_mac_proto(key) == MAC_PROTO_ETHERNET) {
+		struct ethhdr *hdr;
+
+		/* mpls_hdr() is used to locate the ethertype field correctly in the
+		 * presence of VLAN tags.
+		 */
+		hdr = (struct ethhdr *)((void *)mpls_hdr(skb) - ETH_HLEN);
+		update_ethertype(skb, hdr, ethertype);
+	}
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
 
-- 
1.8.3.1
