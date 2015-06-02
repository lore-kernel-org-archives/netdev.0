From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V10 3/4] 802.1AD: Flow handling, actions and vlan parsing
Date: Tue,  2 Jun 2015 13:50:43 -0400
Message-ID: <1433267444-26025-4-git-send-email-thomasfherbert@gmail.com>
References: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:34684 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759646AbbFBRvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 13:51:15 -0400
Received: by ykfl8 with SMTP id l8so56087094ykf.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 10:51:15 -0700 (PDT)
In-Reply-To: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad including the ability to push and pop double
tagged vlans.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 net/openvswitch/flow.c | 82 ++++++++++++++++++++++++++++++++++++++++++--------
 net/openvswitch/flow.h |  3 ++
 2 files changed, 73 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2dacc7b..9c73a2e 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -298,21 +298,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	struct qtag_prefix {
-		__be16 eth_type; /* ETH_P_8021Q */
+		__be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
 		__be16 tci;
 	};
-	struct qtag_prefix *qp;
+	struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
 
-	if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
+	struct qinqtag_prefix {
+		__be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
+		__be16 tci;
+		__be16 inner_tpid; /* ETH_P_8021Q */
+		__be16 ctci;
+	};
+
+	if (likely(skb_vlan_tag_present(skb))) {
+		key->eth.tci = htons(skb->vlan_tci);
+
+		/* Case where upstream
+		 * processing has already stripped the outer vlan tag.
+		 */
+		if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
+			if (unlikely(skb->len < sizeof(struct qtag_prefix) +
+					sizeof(__be16))) {
+				key->eth.tci = 0;
+				return 0;
+			}
+
+			if (unlikely(!pskb_may_pull(skb,
+						    sizeof(struct qtag_prefix) +
+						    sizeof(__be16)))) {
+				return -ENOMEM;
+			}
+
+			if (likely(qp->eth_type == htons(ETH_P_8021Q))) {
+				key->eth.ctci = qp->tci |
+						htons(VLAN_TAG_PRESENT);
+				__skb_pull(skb, sizeof(struct qtag_prefix));
+			}
+		}
 		return 0;
+	}
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
-					 sizeof(__be16))))
-		return -ENOMEM;
 
-	qp = (struct qtag_prefix *) skb->data;
-	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
-	__skb_pull(skb, sizeof(struct qtag_prefix));
+	if (qp->eth_type == htons(ETH_P_8021AD)) {
+		struct qinqtag_prefix *qinqp =
+					(struct qinqtag_prefix *)skb->data;
+
+		if (unlikely(skb->len < sizeof(struct qinqtag_prefix) +
+					sizeof(__be16)))
+			return 0;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct qinqtag_prefix) +
+				sizeof(__be16)))) {
+			return -ENOMEM;
+		}
+		key->eth.tci = qinqp->tci | htons(VLAN_TAG_PRESENT);
+		key->eth.ctci = qinqp->ctci | htons(VLAN_TAG_PRESENT);
+
+		__skb_pull(skb, sizeof(struct qinqtag_prefix));
+
+		return 0;
+	}
+	if (qp->eth_type == htons(ETH_P_8021Q)) {
+		if (unlikely(skb->len < sizeof(struct qtag_prefix) +
+					sizeof(__be16)))
+			return -ENOMEM;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
+				sizeof(__be16))))
+			return 0;
+		key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
+
+		__skb_pull(skb, sizeof(struct qtag_prefix));
+	}
 
 	return 0;
 }
@@ -474,9 +531,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	 */
 
 	key->eth.tci = 0;
-	if (skb_vlan_tag_present(skb))
-		key->eth.tci = htons(skb->vlan_tci);
-	else if (eth->h_proto == htons(ETH_P_8021Q))
+	key->eth.ctci = 0;
+	if ((skb_vlan_tag_present(skb)) ||
+	    (eth->h_proto == htons(ETH_P_8021Q)) ||
+	    (eth->h_proto == htons(ETH_P_8021AD)))
 		if (unlikely(parse_vlan(skb, key)))
 			return -ENOMEM;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a076e44..fa83c61 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -134,6 +134,9 @@ struct sw_flow_key {
 		u8     src[ETH_ALEN];	/* Ethernet source address. */
 		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
 		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+		__be16 ctci;		/* 0 if no CVLAN, VLAN_TAG_PRESENT set
+					 * otherwise.
+					 */
 		__be16 type;		/* Ethernet frame type. */
 	} eth;
 	union {
-- 
2.1.0
