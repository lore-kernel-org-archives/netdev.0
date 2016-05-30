From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net v2] openvswitch: update checksum in {push,pop}_mpls
Date: Mon, 30 May 2016 14:04:25 +0900
Message-ID: <1464584665-8512-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
	Pravin Shelar <pshelar@nicira.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36418 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbcE3FEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:04:32 -0400
Received: by mail-pa0-f43.google.com with SMTP id eu11so49384203pad.3
        for <netdev@vger.kernel.org>; Sun, 29 May 2016 22:04:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of CHECKSUM_COMPLETE the skb checksum should be updated in
{push,pop}_mpls() as they the type in the ethernet header.

As suggested by Pravin Shelar.

Cc: Pravin Shelar <pshelar@nicira.com>
Fixes: 25cd9ba0abc0 ("openvswitch: Add basic MPLS support to kernel")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v2
* Use helper to reduce duplicated code.
---
 net/openvswitch/actions.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 879185fe183f..9a3eb7a0ebf4 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -137,11 +137,23 @@ static bool is_flow_key_valid(const struct sw_flow_key *key)
 	return !!key->eth.type;
 }
 
+static void update_ethertype(struct sk_buff *skb, struct ethhdr *hdr,
+			     __be16 ethertype)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		__be16 diff[] = { ~(hdr->h_proto), ethertype };
+
+		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
+					~skb->csum);
+	}
+
+	hdr->h_proto = ethertype;
+}
+
 static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_mpls *mpls)
 {
 	__be32 *new_mpls_lse;
-	struct ethhdr *hdr;
 
 	/* Networking stack do not allow simultaneous Tunnel and MPLS GSO. */
 	if (skb->encapsulation)
@@ -160,9 +172,7 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
-	hdr = eth_hdr(skb);
-	hdr->h_proto = mpls->mpls_ethertype;
-
+	update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
 	if (!skb->inner_protocol)
 		skb_set_inner_protocol(skb, skb->protocol);
 	skb->protocol = mpls->mpls_ethertype;
@@ -193,7 +203,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	 * field correctly in the presence of VLAN tags.
 	 */
 	hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
-	hdr->h_proto = ethertype;
+	update_ethertype(skb, hdr, ethertype);
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
 
-- 
2.1.4
