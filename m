From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/2] openvswitch: remove nonreachable code in vlan parsing
Date: Tue,  4 Oct 2016 14:30:01 +0200
Message-ID: <cfc3e476bc30c1e15506e80955bf43563de3c16c.1475583870.git.jbenc@redhat.com>
References: <cover.1475583870.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57084 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753298AbcJDMaR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 08:30:17 -0400
In-Reply-To: <cover.1475583870.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It can never happen that there's a vlan tag in the packet but not in
skb->vlan_tci. This is ensured in __netif_receive_skb_core and honored by
skb_vlan_push and skb_vlan_pop. The code dealing with such case is a dead
code.

Moreover, the likely() statement around skb_vlan_tag_present is bogus. This
code is called whenever flow key is being extracted from the packet. The
packet may be as likely vlan tagged as not.

Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
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
