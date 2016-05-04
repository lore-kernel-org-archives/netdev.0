From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v9 net-next 3/7] openvswitch: add support to push and pop mpls for layer3 packets
Date: Wed,  4 May 2016 16:36:29 +0900
Message-ID: <1462347393-22354-4-git-send-email-simon.horman@netronome.com>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33552 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757240AbcEDHg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 03:36:58 -0400
Received: by mail-pa0-f46.google.com with SMTP id xk12so21284695pac.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 00:36:58 -0700 (PDT)
In-Reply-To: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow push and pop mpls actions to act on layer 3 packets by teaching
them not to access non-existent L2 headers of such packets.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v9
* New Patch
---
 net/openvswitch/actions.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 879185fe183f..fe885a89f501 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -160,8 +160,10 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
-	hdr = eth_hdr(skb);
-	hdr->h_proto = mpls->mpls_ethertype;
+	if (skb->mac_len) {
+		hdr = eth_hdr(skb);
+		hdr->h_proto = mpls->mpls_ethertype;
+	}
 
 	if (!skb->inner_protocol)
 		skb_set_inner_protocol(skb, skb->protocol);
@@ -174,7 +176,6 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		    const __be16 ethertype)
 {
-	struct ethhdr *hdr;
 	int err;
 
 	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
@@ -189,11 +190,16 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	__skb_pull(skb, MPLS_HLEN);
 	skb_reset_mac_header(skb);
 
-	/* skb_mpls_header() is used to locate the ethertype
-	 * field correctly in the presence of VLAN tags.
-	 */
-	hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
-	hdr->h_proto = ethertype;
+	if (skb->mac_len) {
+		/* skb_mpls_header() is used to locate the ethertype
+		 * field correctly in the presence of VLAN tags.
+		 */
+		struct ethhdr *hdr;
+
+		hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
+		BUG_ON((unsigned char *)hdr < skb_mac_header(skb));
+		hdr->h_proto = ethertype;
+	}
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
 
-- 
2.7.0.rc3.207.g0ac5344
