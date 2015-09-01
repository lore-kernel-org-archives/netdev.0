From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 19/21] net: rbridge: add rbr_multidest_fwd
Date: Tue,  1 Sep 2015 17:43:14 +0200
Message-ID: <1441122196-11662-20-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56617 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752646AbbIAPxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:41 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For multidest trill frame use multiple unicast forward to all
adjacency on the distributed tree when called while encapsulating
original frame need to be freed as it was already flooded to all
local access port for recv function when using multdestination
forward, the original frame has to be saved in order to be
decapsulated locally

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>

Conflicts:
	net/bridge/rbr.c
---
 net/bridge/rbr.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 98 insertions(+), 2 deletions(-)

diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index ab71e6b..23f3e1d 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -214,6 +214,100 @@ dest_fwd_fail:
 	kfree_skb(skb);
 }
 
+static int rbr_multidest_fwd(struct net_bridge_port *p,
+			     struct sk_buff *skb, u16 egressnick,
+			     u16 ingressnick, const u8 *saddr,
+			     u16 vid, bool free)
+{
+	struct rbr *rbr;
+	struct rbr_node *dest;
+	struct rbr_node *adj;
+	struct sk_buff *skb2;
+	u16 adjnicksaved = 0;
+	u16 adjnick;
+	bool nicksaved = false;
+	unsigned int i;
+
+	if (unlikely(!p)) {
+		pr_warn_ratelimited("rbr_multidest_fwd: port error\n");
+		goto multidest_fwd_fail;
+	}
+
+	rbr = p->br->rbr;
+	if (unlikely(!rbr))
+		goto multidest_fwd_fail;
+
+	/* Lookup the egress nick info, this is the DT root */
+	dest = rbr_find_node(rbr, egressnick);
+	if (!dest) {
+		pr_warn_ratelimited
+		    ("rbr_multidest_fwd: unable to find egress\n");
+		goto multidest_fwd_fail;
+	}
+
+	/* Send a copy to all our adjacencies on the DT root */
+	for (i = 0; i < dest->rbr_ni->adjcount; i++) {
+		/* Check for a valid adjacency node */
+		adjnick = RBR_NI_ADJNICK(dest->rbr_ni, i);
+		adj = rbr_find_node(rbr, adjnick);
+		if (!VALID_NICK(adjnick) || ingressnick == adjnick ||
+		    (!adj))
+			continue;
+		/* Do not forward back to adjacency that sent the pkt to us */
+		if ((saddr) &&
+		    (ether_addr_equal_unaligned(adj->rbr_ni->adjsnpa,
+						saddr))) {
+			rbr_node_put(adj);
+			continue;
+		}
+
+		/* save the first found adjacency to avoid coping SKB
+		 * if no other adjacency is found later no frame copy
+		 * will be made if other adjacency will be found frame
+		 * will be copied and forwarded to them if skb is needed
+		 * after rbr_multidest_fwd copy of the first skb skb
+		 * will be forced
+		 */
+		if (!nicksaved && free) {
+			adjnicksaved = adjnick;
+			nicksaved = true;
+			rbr_node_put(adj);
+			continue;
+		}
+		/* FIXME using copy instead of clone as
+		 * we are going to modify dest address
+		 */
+		skb2 = skb_copy(skb, GFP_ATOMIC);
+		if (unlikely(!skb2)) {
+			p->br->dev->stats.tx_dropped++;
+			pr_warn_ratelimited
+			    ("rbr_multidest_fwd: skb_copy failed\n");
+			goto multidest_fwd_fail;
+		}
+		rbr_fwd(p, skb2, adjnick, vid);
+		rbr_node_put(adj);
+	}
+	rbr_node_put(dest);
+
+	/* if nicksave is false it means that copy will not be forwarded
+	 * as no availeble ajacency was found in such a case frame should
+	 * be dropped
+	 */
+
+	if (nicksaved)
+		rbr_fwd(p, skb, adjnicksaved, vid);
+	else
+		kfree_skb(skb);
+
+	return 0;
+
+ multidest_fwd_fail:
+	if (likely(p && p->br))
+		p->br->dev->stats.tx_dropped++;
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
 static void rbr_encaps(struct sk_buff *skb, u16 egressnick, u16 vid)
 {
 	u16 local_nick;
@@ -272,7 +366,7 @@ static void rbr_encaps(struct sk_buff *skb, u16 egressnick, u16 vid)
 		br_flood_deliver_flags(p->br, skb2, true, TRILL_FLAG_ACCESS);
 		if (unlikely(add_header(skb, local_nick, dtnick, 1)))
 			goto encaps_drop;
-		/* TODO Multi forward */
+		rbr_multidest_fwd(p, skb, dtnick, local_nick, NULL, vid, true);
 	} else {
 		if (unlikely(add_header(skb, local_nick, egressnick, 0)))
 			goto encaps_drop;
@@ -504,7 +598,9 @@ static void rbr_recv(struct sk_buff *skb, u16 vid)
 		goto recv_drop;
 	}
 
-	/* TODO multi forwarding */
+	if (rbr_multidest_fwd(p, skb2, trh->th_egressnick, trh->th_ingressnick,
+			      eth_hdr(skb)->h_source, vid, false))
+		goto recv_drop;
 
 	/* Send de-capsulated frame locally */
 	rbr_decaps(p, skb, trhsize, vid);
-- 
2.1.4
