From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 19/24] net: rbridge: Add receive function
Date: Wed, 24 Sep 2014 17:52:15 +0200
Message-ID: <1411573940-14079-20-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:58291 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794AbaIXQDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:12 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add receiving function
process unicast frames in receiving function
multicast frame are not handled from the moment

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbridge/rbr.c | 105 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 104 insertions(+), 1 deletion(-)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 488c75d..29ef0f7 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -247,6 +247,109 @@ static void rbr_encaps(struct sk_buff *skb, uint16_t egressnick, u16 vid)
 	return;
 }
 
+static void rbr_recv(struct sk_buff *skb, u16 vid)
+{
+	uint16_t local_nick, dtrNick, adjnick, idx;;
+	struct rbr *rbr;
+	uint8_t srcaddr[ETH_ALEN];
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
+	} else {
+		rbr = p->br->rbr;
+	}
+	/* For trill frame the outer mac destination must correspond to localhost
+	 * address, if not frame must be discarded
+	 * such scenario is possible when switch flood frames on all ports
+	 * if frame are not discarded they will loop until reaching the
+	 * hop_count limit
+	 */
+	if (!memcmp(p->dev->dev_addr, eth_hdr(skb)->h_dest, ETH_ALEN) == 0)
+		goto recv_drop;
+	memcpy(srcaddr, eth_hdr(skb)->h_source, ETH_ALEN);
+	trh = (struct trill_hdr *)skb->data;
+	trill_flags = ntohs(trh->th_flags);
+	trhsize = sizeof(*trh) + trill_get_optslen(trill_flags);
+	if (unlikely(skb->len < trhsize + ETH_HLEN)) {
+		pr_warn_ratelimited
+		    ("rbr_recv: sk_buff len is less then minimal len\n");
+		goto recv_drop;
+	}
+	/*
+	 * seems to be a valid TRILL frame,
+	 * check if TRILL header can be pulled
+	 * before proceeding
+	 */
+	if (unlikely(!pskb_may_pull(skb, trhsize + ETH_HLEN)))
+		goto recv_drop;
+	/*
+	 * WARNING SKB structure may be changed by pskb_may_pull
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
+	dtrNick = rbr->treeroot;
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
+			/* TODO decapsulate function */
+		} else if (likely(trill_get_hopcount(trill_flags))) {
+			br_fdb_update(p->br, p, srcaddr, vid, false);
+			/* TODO simple forwarding */
+		} else {
+			pr_warn_ratelimited
+			    ("rbr_recv: hop count limit reached\n");
+			goto recv_drop;
+		}
+		return;
+	}
+
+	return;
+
+ recv_drop:
+	if (likely(p && p->br))
+		p->br->dev->stats.rx_dropped++;
+	kfree_skb(skb);
+	return;
+}
+
 /* handling function hook allow handling
  * a frame upon reception called via
  * br_handle_frame_hook = rbr_handle_frame
@@ -319,7 +422,7 @@ rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
 				 * Packet is from trunk port, decapsulate if destined to access port
 				 * or trill forward to next hop
 				 */
-				/* TODO */
+				rbr_recv(skb, vid);
 				return RX_HANDLER_CONSUMED;
 			} else {
 				/* packet is destinated to localhost */
-- 
1.9.1
