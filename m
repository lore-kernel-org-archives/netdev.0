From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 21/24] net: rbridge: Add decapsulation function
Date: Wed, 24 Sep 2014 17:52:17 +0200
Message-ID: <1411573940-14079-22-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:49972 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbaIXQDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:13 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for frame destined to local RBridge (egress Rbridge == local_nick)
have de be decapsuled and forwarded to corresponding host
if frame is from type multicast a copy has to be decapsulated locally

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbridge/rbr.c | 56 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 53 insertions(+), 3 deletions(-)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 9206682..8aa5182 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -247,9 +247,59 @@ static void rbr_encaps(struct sk_buff *skb, uint16_t egressnick, u16 vid)
 	return;
 }
 
+static void rbr_decap_finish(struct sk_buff *skb, u16 vid)
+{
+	struct net_bridge *br;
+	const unsigned char *dest = eth_hdr(skb)->h_dest;
+	struct net_bridge_fdb_entry *dst;
+	struct net_device *dev = skb->dev;
+
+	br = netdev_priv(dev);
+	dst = __br_fdb_get(br, dest, vid);
+	if (likely(dst))
+		br_deliver(dst->dst, skb);
+	else
+		/* destination unknown flood on all access ports */
+		br_flood_deliver_flags(br, skb, true, TRILL_FLAG_ACCESS);
+
+}
+
+static void rbr_decaps(struct net_bridge_port *p,
+		       struct sk_buff *skb, size_t trhsize, u16 vid)
+{
+	struct trill_hdr *trh;
+	struct ethhdr *hdr;
+
+	if (unlikely(p == NULL))
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
+	/* Mark bridge as source device */
+	skb->dev = p->br->dev;
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
 static void rbr_recv(struct sk_buff *skb, u16 vid)
 {
-	uint16_t local_nick, dtrNick, adjnick, idx;;
+	uint16_t local_nick, dtrNick, adjnick, idx;
 	struct rbr *rbr;
 	uint8_t srcaddr[ETH_ALEN];
 	struct trill_hdr *trh;
@@ -329,7 +379,7 @@ static void rbr_recv(struct sk_buff *skb, u16 vid)
 			goto recv_drop;
 		}
 		if (trh->th_egressnick == local_nick) {
-			/* TODO decapsulate function */
+			rbr_decaps(p, skb, trhsize, vid);
 		} else if (likely(trill_get_hopcount(trill_flags))) {
 			br_fdb_update(p->br, p, srcaddr, vid, false);
 			/* TODO simple forwarding */
@@ -424,7 +474,7 @@ static void rbr_recv(struct sk_buff *skb, u16 vid)
 	/*
 	 * Send de-capsulated frame locally
 	 */
-	/* TODO decapsulate function */
+	rbr_decaps(p, skb, trhsize, vid);
 
 	return;
 
-- 
1.9.1
