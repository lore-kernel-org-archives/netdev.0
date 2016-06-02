From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v10 3/5] openvswitch: add support to push and pop mpls for layer3 packets
Date: Thu,  2 Jun 2016 15:24:44 +0900
Message-ID: <1464848686-7656-4-git-send-email-simon.horman@netronome.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33210 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbcFBGZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 02:25:03 -0400
Received: by mail-pa0-f45.google.com with SMTP id um11so3274415pab.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 23:25:02 -0700 (PDT)
In-Reply-To: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow push and pop mpls actions to act on layer 3 packets by teaching
them not to access non-existent L2 headers of such packets.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v10
* Limit scope of hdr in {push,pop}_mpls()

v9
* New Patch
---
 net/openvswitch/actions.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 9a3eb7a0ebf4..15f130e4c22b 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -172,7 +172,8 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 
 	skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
 
-	update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
+	if (skb->mac_len)
+		update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
 	if (!skb->inner_protocol)
 		skb_set_inner_protocol(skb, skb->protocol);
 	skb->protocol = mpls->mpls_ethertype;
@@ -184,7 +185,6 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		    const __be16 ethertype)
 {
-	struct ethhdr *hdr;
 	int err;
 
 	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
@@ -199,11 +199,16 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	__skb_pull(skb, MPLS_HLEN);
 	skb_reset_mac_header(skb);
 
-	/* skb_mpls_header() is used to locate the ethertype
-	 * field correctly in the presence of VLAN tags.
-	 */
-	hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
-	update_ethertype(skb, hdr, ethertype);
+	if (skb->mac_len) {
+		struct ethhdr *hdr;
+
+		/* skb_mpls_header() is used to locate the ethertype
+		 * field correctly in the presence of VLAN tags.
+		 */
+		hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
+		update_ethertype(skb, hdr, ethertype);
+	}
+
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
 
-- 
2.1.4
