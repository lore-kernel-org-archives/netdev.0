From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 18/21] net: rbridge: add rbr_fwd
Date: Tue,  1 Sep 2015 17:43:13 +0200
Message-ID: <1441122196-11662-19-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>,
	=?UTF-8?q?Fran=C3=A7ois=20Cachereul?= <f.cachereul@alphalink.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56462 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751631AbbIAPxk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 11:53:40 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add rbridge forward function
packets arriving to rbr_fwd should be already encapsulated and correct
egress
and ingress nickname should be already assigned
rbr_fwd function will assign correct source and destination outer MAC
addresses
according to which port will send the frame and next hop to reach
the engress nickname
Nexthope to reach the egress will be found in node database

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
---
 net/bridge/rbr.c | 46 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 44 insertions(+), 2 deletions(-)

diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index c04c05a..ab71e6b 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -172,6 +172,48 @@ static bool add_header(struct sk_buff *skb, uint16=
_t ingressnick,
 	return 0;
 }
=20
+static void rbr_fwd(struct net_bridge_port *p, struct sk_buff *skb,
+		    u16 adj_nick, u16 vid)
+{
+	struct rbr_node *adj;
+	struct trill_hdr *trh;
+	struct ethhdr *outerethhdr;
+	struct net *net =3D dev_net(p->dev);
+	struct net_device *outdev;
+	struct net_bridge_port *outp;
+
+	adj =3D rbr_find_node(p->br->rbr, adj_nick);
+	if (unlikely(!adj || !adj->rbr_ni)) {
+		pr_warn_ratelimited("rbr_fwd: unable to find adjacent RBridge\n");
+		goto dest_fwd_fail;
+	}
+	outdev =3D dev_get_by_index_rcu(net, adj->rbr_ni->linkid);
+	if (!outdev) {
+		pr_warn_ratelimited("rbr_fwd: cannot find source port device for for=
wrding\n");
+		goto dest_fwd_fail;
+	}
+
+	trh =3D (struct trill_hdr *)skb->data;
+	trillhdr_dec_hopcount(trh);
+	outerethhdr =3D eth_hdr(skb);
+
+	/* change outer ether header */
+	/* bridge becomes the source_port address in outeretherhdr */
+	outp =3D br_port_get_rcu(outdev);
+	ether_addr_copy(outerethhdr->h_source, outp->dev->dev_addr);
+	/* dist port becomes dest address in outeretherhdr */
+	ether_addr_copy(outerethhdr->h_dest, adj->rbr_ni->adjsnpa);
+	rbr_node_put(adj);
+	skb->dev =3D p->br->dev;
+	br_forward(outp, skb, NULL);
+	return;
+
+dest_fwd_fail:
+	if (likely(p && p->br))
+		p->br->dev->stats.tx_dropped++;
+	kfree_skb(skb);
+}
+
 static void rbr_encaps(struct sk_buff *skb, u16 egressnick, u16 vid)
 {
 	u16 local_nick;
@@ -234,7 +276,7 @@ static void rbr_encaps(struct sk_buff *skb, u16 egr=
essnick, u16 vid)
 	} else {
 		if (unlikely(add_header(skb, local_nick, egressnick, 0)))
 			goto encaps_drop;
-		/* TODO simple forwarding */
+		rbr_fwd(p, skb, egressnick, vid);
 	}
 	return;
  encaps_drop:
@@ -373,7 +415,7 @@ static void rbr_recv(struct sk_buff *skb, u16 vid)
 		} else if (likely(trill_get_hopcount(trill_flags))) {
 			br_fdb_update(p->br, p, eth_hdr(skb)->h_source,
 				      vid, false);
-			/* TODO simple forwarding */
+			rbr_fwd(p, skb, trh->th_egressnick, vid);
 		} else {
 			pr_warn_ratelimited("rbr_recv: hop count limit reached\n");
 			goto recv_drop;
--=20
2.1.4
