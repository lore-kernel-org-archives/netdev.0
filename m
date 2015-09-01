From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 16/21] net: rbridge: add encapsulation process
Date: Tue,  1 Sep 2015 17:43:11 +0200
Message-ID: <1441122196-11662-17-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:34655 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752724AbbIAPxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:42 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add encapsulation process to detect frame type (multicast or unicast)
for known unicast frame add proper TRILL header

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
---
 net/bridge/rbr.c | 124 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 123 insertions(+), 1 deletion(-)

diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index fdff167..8081b20 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -14,6 +14,8 @@
 #include "br_private.h"
 #include "rbr_private.h"
 #include <linux/netfilter_bridge.h>
+#include <net/if_trill.h>
+
 static void rbr_del_all(struct rbr *rbr);
 
 static struct rbr *add_rbr(struct net_bridge *br)
@@ -123,6 +125,124 @@ static void rbr_del_all(struct rbr *rbr)
 	}
 }
 
+static bool add_header(struct sk_buff *skb, uint16_t ingressnick,
+		       u16 egressnick, bool multidest)
+{
+	struct trill_hdr *trh;
+	size_t trhsize;
+	u16 vlan_tci;
+	u16 trill_flags = 0;
+
+	trhsize = sizeof(*trh);
+	skb_push(skb, ETH_HLEN);
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+	/* fix inner VLAN */
+	if (br_vlan_get_tag(skb, &vlan_tci) == 0) {
+		skb = vlan_insert_tag(skb, skb->vlan_proto, vlan_tci);
+		if (!skb) {
+			pr_err("add_header: vlan_insert_tag failed\n");
+			return 1;
+		}
+		skb->vlan_proto = 0;
+		skb->vlan_tci = 0;
+	}
+	if (unlikely(skb_cow_head(skb, trhsize + ETH_HLEN))) {
+		pr_err("add_header: cow_head failed\n");
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
+	/* make skb->mac_header point to outer mac header */
+	skb_push(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);	/* instead of the inner one */
+	eth_hdr(skb)->h_proto = htons(ETH_P_TRILL);
+	/* reset skb->data pointer */
+	skb_pull(skb, ETH_HLEN);
+	skb_reset_mac_len(skb);
+	return 0;
+}
+
+static void rbr_encaps(struct sk_buff *skb, u16 egressnick, u16 vid)
+{
+	u16 local_nick;
+	u16 dtnick;
+	struct rbr_node *self;
+	struct sk_buff *skb2;
+	struct rbr *rbr;
+	struct net_bridge_port *p;
+
+	p = br_port_get_rcu(skb->dev);
+	if (unlikely(!p)) {
+		pr_warn_ratelimited("rbr_encaps_prepare: port error\n");
+		goto encaps_drop;
+	}
+	rbr = p->br->rbr;
+
+	if (unlikely(egressnick != RBRIDGE_NICKNAME_NONE &&
+		     !VALID_NICK(egressnick))) {
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
+	self = rbr_find_node(rbr, local_nick);
+	if (unlikely(!self)) {
+		pr_warn_ratelimited
+		    ("rbr_encaps_prepare: waiting for nickname\n");
+		goto encaps_drop;
+	}
+
+	/* Unknown destination => multidestination frame */
+	if (egressnick == RBRIDGE_NICKNAME_NONE) {
+		if (self->rbr_ni->dtrootcount > 0)
+			dtnick = RBR_NI_DTROOTNICK(self->rbr_ni, 0);
+		else
+			dtnick = rbr->treeroot;
+		rbr_node_put(self);
+		if (unlikely(!VALID_NICK(dtnick))) {
+			pr_warn_ratelimited
+			    ("rbr_encaps_prepare: dtnick is unvalid\n");
+			goto encaps_drop;
+		}
+		skb2 = skb_clone(skb, GFP_ATOMIC);
+		if (unlikely(!skb2)) {
+			p->br->dev->stats.tx_dropped++;
+			pr_warn_ratelimited
+			    ("rbr_encaps_prepare: skb_clone failed\n");
+			goto encaps_drop;
+		}
+		br_flood_deliver_flags(p->br, skb2, true, TRILL_FLAG_ACCESS);
+		if (unlikely(add_header(skb, local_nick, dtnick, 1)))
+			goto encaps_drop;
+		/* TODO Multi forward */
+	} else {
+		if (unlikely(add_header(skb, local_nick, egressnick, 0)))
+			goto encaps_drop;
+		/* TODO simple forwarding */
+	}
+	return;
+ encaps_drop:
+	if (likely(p && p->br))
+		p->br->dev->stats.tx_dropped++;
+	kfree_skb(skb);
+}
+
 /* handling function hook allow handling
  * a frame upon reception called via
  * br_handle_frame_hook = rbr_handle_frame
@@ -136,6 +256,7 @@ rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
 	struct net_bridge_port *p;
 	struct sk_buff *skb = *pskb;
 	u16 vid = 0;
+	u16 nick;
 
 	p = br_port_get_rcu(skb->dev);
 	br = p->br;
@@ -178,7 +299,8 @@ rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
 		/* if packet is from access port and trill is enabled and dest
 		 * is not an access port or is unknown, encaps it
 		 */
-		/* TODO */
+		nick = get_nick_from_mac(p, eth_hdr(skb)->h_dest, vid);
+		rbr_encaps(skb, nick, vid);
 		return RX_HANDLER_CONSUMED;
 	}
 	if (p->trill_flag & TRILL_FLAG_TRUNK) {
-- 
2.1.4
