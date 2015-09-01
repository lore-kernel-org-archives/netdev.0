From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 17/21] net: rbridge: add receive function
Date: Tue,  1 Sep 2015 17:43:12 +0200
Message-ID: <1441122196-11662-18-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56783 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752961AbbIAPxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:43 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add receiving function
process unicast frames in receiving function
multicast frame are not handled from the moment

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbr.c | 233 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 232 insertions(+), 1 deletion(-)

diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index 8081b20..c04c05a 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -243,6 +243,237 @@ static void rbr_encaps(struct sk_buff *skb, u16 egressnick, u16 vid)
 	kfree_skb(skb);
 }
 
+static void rbr_decap_finish(struct sk_buff *skb, u16 vid)
+{
+	struct net_bridge *br;
+	struct net_bridge_port *p;
+	const unsigned char *dest = eth_hdr(skb)->h_dest;
+	struct net_bridge_fdb_entry *dst;
+
+	p = br_port_get_rcu(skb->dev);
+	br = p->br;
+	dst = __br_fdb_get(br, dest, vid);
+	if (likely(dst))
+		br_deliver(dst->dst, skb);
+	else
+		/* destination unknown flood on all access ports */
+		br_flood_deliver_flags(br, skb, true, TRILL_FLAG_ACCESS);
+}
+
+static void rbr_decaps(struct net_bridge_port *p,
+		       struct sk_buff *skb, size_t trhsize, u16 vid)
+{
+	struct trill_hdr *trh;
+	struct ethhdr *hdr;
+
+	if (unlikely(!p))
+		goto rbr_decaps_drop;
+	trh = (struct trill_hdr *)skb->data;
+	if (trhsize >= sizeof(*trh))
+		skb_pull(skb, sizeof(*trh));
+	else
+		goto rbr_decaps_drop;
+	trhsize -= sizeof(*trh);
+	skb_reset_mac_header(skb);	/* instead of the inner one */
+	skb->protocol = eth_hdr(skb)->h_proto;
+	hdr = (struct ethhdr *)skb->data;
+	skb_pull(skb, ETH_HLEN);
+	skb_reset_network_header(skb);
+	if (skb->encapsulation)
+		skb->encapsulation = 0;
+	br_fdb_update_nick(p->br, p, hdr->h_source, vid, false,
+			   trh->th_ingressnick);
+	rbr_decap_finish(skb, vid);
+	return;
+ rbr_decaps_drop:
+	if (likely(p && p->br))
+		p->br->dev->stats.rx_dropped++;
+	kfree_skb(skb);
+}
+
+static void rbr_recv(struct sk_buff *skb, u16 vid)
+{
+	u16 local_nick, dtnick, adjnick, idx;
+	struct rbr *rbr;
+	struct trill_hdr *trh;
+	size_t trhsize;
+	struct net_bridge_port *p;
+	u16 trill_flags;
+	struct sk_buff *skb2;
+	struct rbr_node *dest = NULL;
+	struct rbr_node *source_node = NULL;
+	struct rbr_node *adj = NULL;
+
+	p = br_port_get_rcu(skb->dev);
+	if (unlikely(!p)) {
+		pr_warn_ratelimited("rbr_recv: port error\n");
+		goto recv_drop;
+	}
+	rbr = p->br->rbr;
+	/* For trill frame the outer mac destination must correspond
+	 * to localhost address, if not frame must be discarded
+	 * such scenario is possible when switch flood frames on all ports
+	 * if frame are not discarded they will loop until reaching the
+	 * hop_count limit
+	 */
+	if (memcmp(p->dev->dev_addr, eth_hdr(skb)->h_dest, ETH_ALEN))
+		goto recv_drop;
+	trh = (struct trill_hdr *)skb->data;
+	trill_flags = ntohs(trh->th_flags);
+	trhsize = sizeof(*trh) + trill_get_optslen(trill_flags);
+	if (unlikely(skb->len < trhsize + ETH_HLEN)) {
+		pr_warn_ratelimited
+		    ("rbr_recv: sk_buff len is less then minimal len\n");
+		goto recv_drop;
+	}
+	/* seems to be a valid TRILL frame,
+	 * check if TRILL header can be pulled
+	 * before proceeding
+	 */
+	if (unlikely(!pskb_may_pull(skb, trhsize + ETH_HLEN)))
+		goto recv_drop;
+
+	/* WARNING SKB structure may be changed by pskb_may_pull
+	 * reassign trh pointer before continuing any further
+	 */
+	trh = (struct trill_hdr *)skb->data;
+
+	if (!skb->encapsulation) {
+		skb_pull(skb, trhsize + ETH_HLEN);
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+		skb_push(skb, trhsize + ETH_HLEN);
+	}
+	if (unlikely(!VALID_NICK(trh->th_ingressnick) ||
+		     !VALID_NICK(trh->th_egressnick))) {
+		pr_warn_ratelimited("rbr_recv: invalid nickname\n");
+		goto recv_drop;
+	}
+	if (unlikely(trill_get_version(trill_flags) != TRILL_PROTOCOL_VERS)) {
+		pr_warn_ratelimited("rbr_recv: not the same trill version\n");
+		goto recv_drop;
+	}
+	local_nick = rbr->nick;
+	dtnick = rbr->treeroot;
+	if (unlikely(trh->th_ingressnick == local_nick)) {
+		pr_warn_ratelimited
+		    ("rbr_recv:looping back frame check your config\n");
+		goto recv_drop;
+	}
+
+	if (!trill_get_multidest(trill_flags)) {
+		/* ntohs not needed as the 2 are in the same bit form */
+		if (trh->th_egressnick == trh->th_ingressnick) {
+			pr_warn_ratelimited
+			    ("rbr_recv: egressnick == ingressnick\n");
+			goto recv_drop;
+		}
+		if (trh->th_egressnick == local_nick) {
+			rbr_decaps(p, skb, trhsize, vid);
+		} else if (likely(trill_get_hopcount(trill_flags))) {
+			br_fdb_update(p->br, p, eth_hdr(skb)->h_source,
+				      vid, false);
+			/* TODO simple forwarding */
+		} else {
+			pr_warn_ratelimited("rbr_recv: hop count limit reached\n");
+			goto recv_drop;
+		}
+		return;
+	}
+
+	/* Multi-destination frame:
+	 * Check if received multi-destination frame from an
+	 * adjacency in the distribution tree rooted at egress nick
+	 * indicated in the frame header
+	 */
+	dest = rbr_find_node(rbr, trh->th_egressnick);
+	if (unlikely(!dest)) {
+		pr_warn_ratelimited
+		    ("rbr_recv: mulicast  with unknown destination\n");
+		goto recv_drop;
+	}
+	for (idx = 0; idx < dest->rbr_ni->adjcount; idx++) {
+		adjnick = RBR_NI_ADJNICK(dest->rbr_ni, idx);
+		adj = rbr_find_node(rbr, adjnick);
+		if (unlikely(!adj || !adj->rbr_ni))
+			continue;
+		if (memcmp(adj->rbr_ni->adjsnpa, eth_hdr(skb)->h_source,
+			   ETH_ALEN) == 0) {
+			rbr_node_put(adj);
+			break;
+		}
+		rbr_node_put(adj);
+	}
+
+	if (unlikely(idx >= dest->rbr_ni->adjcount)) {
+		pr_warn_ratelimited("rbr_recv: multicast unknown mac source\n");
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
+	if (unlikely(!source_node)) {
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
+		    trh->th_egressnick != dtnick) {
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
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+	if (unlikely(!skb2)) {
+		p->br->dev->stats.tx_dropped++;
+		pr_warn_ratelimited("rbr_recv: multicast skb_clone failed\n");
+		goto recv_drop;
+	}
+
+	/* TODO multi forwarding */
+
+	/* Send de-capsulated frame locally */
+	rbr_decaps(p, skb, trhsize, vid);
+
+	return;
+ recv_drop:
+	if (likely(p && p->br))
+		p->br->dev->stats.rx_dropped++;
+	kfree_skb(skb);
+}
+
 /* handling function hook allow handling
  * a frame upon reception called via
  * br_handle_frame_hook = rbr_handle_frame
@@ -310,7 +541,7 @@ rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
 			 * if destined to access port
 			 * or trill forward to next hop
 			 */
-			/* TODO */
+			rbr_recv(skb, vid);
 			return RX_HANDLER_CONSUMED;
 		}
 		/* packet is destinated to localhost */
-- 
2.1.4
