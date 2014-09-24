From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 18/24] net: rbridge: Add encapsulation process
Date: Wed, 24 Sep 2014 17:52:14 +0200
Message-ID: <1411573940-14079-19-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:40421 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbaIXQDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:10 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add encapsulation process to detect frame type (multicast or unicast)
for known unicast frame add proper TRILL header

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
---
 net/bridge/rbridge/rbr.c | 123 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 121 insertions(+), 2 deletions(-)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 4b41d4c..488c75d 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -13,6 +13,8 @@
  */
 #include "br_private.h"
 #include "rbr_private.h"
+#include <linux/if_trill.h>
+
 static void rbr_del_all(struct rbr *rbr);
 
 static struct rbr *add_rbr(struct net_bridge *br)
@@ -130,6 +132,121 @@ static void rbr_del_all(struct rbr *rbr)
 	}
 }
 
+static bool add_header(struct sk_buff *skb, uint16_t ingressnick,
+		       uint16_t egressnick, bool multidest)
+{
+	struct trill_hdr *trh;
+	size_t trhsize;
+	u16 vlan_tci;
+	u16 trill_flags = 0;
+	trhsize = sizeof(*trh);
+	skb_push(skb, ETH_HLEN);
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+	/* fix inner VLAN */
+	if (br_vlan_get_tag(skb, &vlan_tci) == 0) {
+		skb = vlan_insert_tag(skb, skb->vlan_proto, vlan_tci);
+		if (skb == NULL) {
+			printk(KERN_ERR "add_header: vlan_insert_tag failed\n");
+			return 1;
+		}
+		skb->vlan_proto = 0;
+		skb->vlan_tci = 0;
+	}
+	if (unlikely(skb_cow_head(skb, trhsize + ETH_HLEN))) {
+		printk(KERN_ERR "add_header: cow_head failed\n");
+		return 1;
+	}
+
+	trh = (struct trill_hdr *)skb_push(skb, sizeof(*trh));
+	trill_flags = trill_set_version(trill_flags, TRILL_PROTOCOL_VERS);
+	trill_flags = trill_set_hopcount(trill_flags, TRILL_DEFAULT_HOPS);
+	trill_flags = trill_set_multidest(trill_flags, multidest ? 1 : 0);
+
+	trh->th_flags = htons(trill_flags);
+	trh->th_egressnick = egressnick;
+	trh->th_ingressnick = ingressnick;	/* self nick name */
+	skb_push(skb, ETH_HLEN);	/* make skb->mac_header point to outer mac header */
+	skb_reset_mac_header(skb);	/* instead of the inner one */
+	eth_hdr(skb)->h_proto = __constant_htons(ETH_P_TRILL);
+	/* reset skb->data pointer */
+	skb_pull(skb, ETH_HLEN);
+	skb_reset_mac_len(skb);
+	return 0;
+}
+
+static void rbr_encaps(struct sk_buff *skb, uint16_t egressnick, u16 vid)
+{
+	uint16_t local_nick;
+	uint16_t dtrNick;
+	struct rbr_node *self;
+	struct sk_buff *skb2;
+	struct rbr *rbr;
+	struct net_bridge_port *p;
+	p = br_port_get_rcu(skb->dev);
+	if (unlikely(!p)) {
+		pr_warn_ratelimited("rbr_encaps_prepare: port error\n");
+		goto encaps_drop;
+	}
+	rbr = p->br->rbr;
+
+	if (unlikely(egressnick != RBRIDGE_NICKNAME_NONE
+		     && !VALID_NICK(egressnick))) {
+		pr_warn_ratelimited
+		    ("rbr_encaps_prepare: invalid destinaton nickname\n");
+		goto encaps_drop;
+	}
+	local_nick = rbr->nick;
+	if (unlikely(!VALID_NICK(local_nick))) {
+		pr_warn_ratelimited
+		    ("rbr_encaps_prepare: invalid local nickname\n");
+		goto encaps_drop;
+	}
+	/* Daemon has not yet sent the local nickname */
+	if (unlikely((self = rbr_find_node(rbr, local_nick)) == NULL)) {
+		pr_warn_ratelimited
+		    ("rbr_encaps_prepare: waiting for nickname\n");
+		goto encaps_drop;
+	}
+
+	/* Unknown destination => multidestination frame */
+	if (egressnick == RBRIDGE_NICKNAME_NONE) {
+		if (self->rbr_ni->dtrootcount > 0)
+			dtrNick = RBR_NI_DTROOTNICK(self->rbr_ni, 0);
+		else
+			dtrNick = rbr->treeroot;
+		rbr_node_put(self);
+		if (unlikely(!VALID_NICK(dtrNick))) {
+			pr_warn_ratelimited
+			    ("rbr_encaps_prepare: dtrNick is unvalid\n");
+			goto encaps_drop;
+		}
+		if (unlikely((skb2 = skb_clone(skb, GFP_ATOMIC)) == NULL)) {
+			p->br->dev->stats.tx_dropped++;
+			pr_warn_ratelimited
+			    ("rbr_encaps_prepare: skb_clone failed\n");
+			goto encaps_drop;
+		}
+		br_flood_deliver_flags(p->br, skb2, true, TRILL_FLAG_ACCESS);
+		if (unlikely(add_header(skb, local_nick, dtrNick, 1)))
+			goto encaps_drop;
+		/* TODO Multi forward */
+	} else {
+		if (unlikely(add_header(skb, local_nick, egressnick, 0)))
+			goto encaps_drop;
+		/* TODO simple forwarding */
+	}
+	return;
+
+ encaps_drop:
+	if (likely(p && p->br))
+		p->br->dev->stats.tx_dropped++;
+	kfree_skb(skb);
+	return;
+}
+
 /* handling function hook allow handling
  * a frame upon reception called via
  * br_handle_frame_hook = rbr_handle_frame
@@ -143,6 +260,7 @@ rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
 	struct net_bridge_port *p;
 	struct sk_buff *skb = *pskb;
 	u16 vid = 0;
+	uint16_t nick;
 
 	p = br_port_get_rcu(skb->dev);
 	if (unlikely(!p))
@@ -189,7 +307,8 @@ rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
 			/* if packet is from access port and trill is enabled and dest
 			 * is not an access port or is unknown, encaps it
 			 */
-			/* TODO */
+			nick = get_nick_from_mac(p, eth_hdr(skb)->h_dest, vid);
+			rbr_encaps(skb, nick, vid);
 			return RX_HANDLER_CONSUMED;
 		}
 		if (p->trill_flag & TRILL_FLAG_TRUNK) {
@@ -205,7 +324,7 @@ rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
 			} else {
 				/* packet is destinated to localhost */
 				if (ether_addr_equal(p->br->dev->dev_addr,
-							eth_hdr(skb)->h_dest)) {
+						     eth_hdr(skb)->h_dest)) {
 					skb->pkt_type = PACKET_HOST;
 					br_handle_frame_finish(skb);
 					return RX_HANDLER_CONSUMED;
-- 
1.9.1
