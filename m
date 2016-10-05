From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 2/3] openvswitch: remove unreachable code in vlan parsing
Date: Wed,  5 Oct 2016 15:07:27 +0200
Message-ID: <3b310a67f5a708da69ee3cf617e6cedd52f85842.1475672569.git.jbenc@redhat.com>
References: <cover.1475672568.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31088 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932205AbcJENHo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 09:07:44 -0400
In-Reply-To: <cover.1475672568.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when the first vlan tag is always in skb->vlan_tci, drop code that
assumed it might not be the case.

This patch also removes the wrong likely() statement around
skb_vlan_tag_present introduced by 018c1dda5ff1 ("openvswitch: 802.1AD Flow
handling, actions, vlan parsing, netlink attributes"). This code is called
whenever flow key is being extracted from the packet, the packet may be as
likely vlan tagged as not.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/flow.c | 28 ++++++++--------------------
 1 file changed, 8 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c8c82e109c68..d88c0a55b783 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -308,9 +308,7 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 
 /**
  * Parse vlan tag from vlan header.
- * Returns ERROR on memory error.
- * Returns 0 if it encounters a non-vlan or incomplete packet.
- * Returns 1 after successfully parsing vlan tag.
+ * Returns ERROR on memory error, 0 otherwise.
  */
 static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *key_vh)
 {
@@ -331,34 +329,24 @@ static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *key_vh)
 	key_vh->tpid = vh->tpid;
 
 	__skb_pull(skb, sizeof(struct vlan_head));
-	return 1;
+	return 0;
 }
 
 static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 {
-	int res;
-
 	key->eth.vlan.tci = 0;
 	key->eth.vlan.tpid = 0;
 	key->eth.cvlan.tci = 0;
 	key->eth.cvlan.tpid = 0;
 
-	if (likely(skb_vlan_tag_present(skb))) {
-		key->eth.vlan.tci = htons(skb->vlan_tci);
-		key->eth.vlan.tpid = skb->vlan_proto;
-	} else {
-		/* Parse outer vlan tag in the non-accelerated case. */
-		res = parse_vlan_tag(skb, &key->eth.vlan);
-		if (res <= 0)
-			return res;
-	}
+	if (!skb_vlan_tag_present(skb))
+		return 0;
 
-	/* Parse inner vlan tag. */
-	res = parse_vlan_tag(skb, &key->eth.cvlan);
-	if (res <= 0)
-		return res;
+	key->eth.vlan.tci = htons(skb->vlan_tci);
+	key->eth.vlan.tpid = skb->vlan_proto;
 
-	return 0;
+	/* Parse inner vlan tag. */
+	return parse_vlan_tag(skb, &key->eth.cvlan);
 }
 
 static __be16 parse_ethertype(struct sk_buff *skb)
-- 
1.8.3.1
