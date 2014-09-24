From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 20/24] net: rbridge: Add multicast recv handling
Date: Wed, 24 Sep 2014 17:52:16 +0200
Message-ID: <1411573940-14079-21-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:51701 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbaIXQDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:12 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in receiving function: add multicast frame processing

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbridge/rbr.c | 85 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 29ef0f7..9206682 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -340,6 +340,91 @@ static void rbr_recv(struct sk_buff *skb, u16 vid)
 		}
 		return;
 	}
+	/* Multi-destination frame:
+	 * Check if received  multi-destination frame from an
+	 * adjacency in the distribution tree rooted at egress nick
+	 * indicated in the frame header
+	 */
+	dest = rbr_find_node(rbr, trh->th_egressnick);
+	if (unlikely(dest == NULL)) {
+		pr_warn_ratelimited
+		    ("rbr_recv: mulicast  with unknown destination\n");
+		goto recv_drop;
+	}
+	for (idx = 0; idx < dest->rbr_ni->adjcount; idx++) {
+		adjnick = RBR_NI_ADJNICK(dest->rbr_ni, idx);
+		adj = rbr_find_node(rbr, adjnick);
+		if (adj == NULL)
+			continue;
+		if (memcmp(adj->rbr_ni->adjsnpa, srcaddr, ETH_ALEN) == 0) {
+			rbr_node_put(adj);
+			break;
+		}
+		rbr_node_put(adj);
+	}
+
+	if (unlikely(idx >= dest->rbr_ni->adjcount)) {
+		pr_warn_ratelimited("rbr_recv: multicast unknow mac source\n");
+		rbr_node_put(dest);
+		goto recv_drop;
+	}
+
+	/* Reverse path forwarding check.
+	 * Check if the ingress RBridge  that has forwarded
+	 * the frame advertised the use of the distribution tree specified
+	 * in the egress nick
+	 */
+	source_node = rbr_find_node(rbr, trh->th_ingressnick);
+	if (unlikely(source_node == NULL)) {
+		pr_warn_ratelimited
+		    ("rbr_recv: reverse path forwarding check failed\n");
+		rbr_node_put(dest);
+		goto recv_drop;
+	}
+	for (idx = 0; idx < source_node->rbr_ni->dtrootcount; idx++) {
+		if (RBR_NI_DTROOTNICK(source_node->rbr_ni, idx) ==
+		    trh->th_egressnick)
+			break;
+	}
+
+	if (idx >= source_node->rbr_ni->dtrootcount) {
+		/* Allow receipt of forwarded frame with the highest
+		 * tree root RBridge as the egress RBridge when the
+		 * ingress RBridge has not advertised the use of any
+		 * distribution trees.
+		 */
+		if (source_node->rbr_ni->dtrootcount != 0 ||
+		    trh->th_egressnick != dtrNick) {
+			rbr_node_put(source_node);
+			rbr_node_put(dest);
+			goto recv_drop;
+		}
+	}
+
+	/* Check hop count before doing any forwarding */
+	if (unlikely(trill_get_hopcount(trill_flags) == 0)) {
+		pr_warn_ratelimited
+		    ("rbr_recv: multicast hop count limit reached\n");
+		rbr_node_put(dest);
+		goto recv_drop;
+	}
+	/* Forward frame using the distribution tree specified by egress nick */
+	rbr_node_put(source_node);
+	rbr_node_put(dest);
+
+	/* skb2 will be multi forwarded and skb will be locally decaps */
+	if (unlikely((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL)) {
+		p->br->dev->stats.tx_dropped++;
+		pr_warn_ratelimited("rbr_recv: multicast skb_clone failed\n");
+		goto recv_drop;
+	}
+
+	/* TODO multi forwarding  */
+
+	/*
+	 * Send de-capsulated frame locally
+	 */
+	/* TODO decapsulate function */
 
 	return;
 
-- 
1.9.1
