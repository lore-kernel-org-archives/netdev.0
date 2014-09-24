From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 22/24] net: rbridge: Add rbr_fwd
Date: Wed, 24 Sep 2014 17:52:18 +0200
Message-ID: <1411573940-14079-23-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56186 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752587AbaIXQDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:12 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add rbridge forward function
packets arriving to rbr_fwd should be already encapsulated and correct =
egress
and ingress nickname should be already assigned
rbr_fwd function will assign correct source and destination outer MAC a=
ddresses
according to which port will send the frame and next hop to reach
the engress nickname
Nexthope to reach the egress will be found in node database

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
---
 net/bridge/rbridge/rbr.c | 49 ++++++++++++++++++++++++++++++++++++++++=
++++++--
 1 file changed, 47 insertions(+), 2 deletions(-)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 8aa5182..39aa816c 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -177,6 +177,51 @@ static bool add_header(struct sk_buff *skb, uint16=
_t ingressnick,
 	return 0;
 }
=20
+static void rbr_fwd(struct net_bridge_port *p, struct sk_buff *skb,
+		    uint16_t adj_nick, u16 vid)
+{
+	struct rbr_node *adj;
+	struct trill_hdr *trh;
+	struct ethhdr *outerethhdr;
+	struct net *net =3D dev_net(p->br->dev);
+	struct net_device *outdev;
+
+	adj =3D rbr_find_node(p->br->rbr, adj_nick);
+    outdev =3D __dev_get_by_index(net, adj->rbr_ni->linkid);
+	if (!outdev) {
+		pr_warn_ratelimited("rbr_fwd: cannot find source port device for for=
wrding\n");
+		goto dest_fwd_fail;
+    }
+	if (unlikely(adj =3D=3D NULL)) {
+		pr_warn_ratelimited
+		    ("rbr_fwd: unable to find adjacent RBridge\n");
+		goto dest_fwd_fail;
+	}
+
+	trh =3D (struct trill_hdr *)skb->data;
+	trillhdr_dec_hopcount(trh);
+	outerethhdr =3D eth_hdr(skb);
+
+	/* change outer ether header */
+	/* bridge become the source_port address in outeretherhdr */
+	memcpy(outerethhdr->h_source, p->br->dev->dev_addr, ETH_ALEN);
+	/* dist port become dest address in outeretherhdr */
+	memcpy(outerethhdr->h_dest, adj->rbr_ni->adjsnpa, ETH_ALEN);
+	rbr_node_put(adj);
+	/* set Bridge as source device */
+	skb->dev =3D p->br->dev;
+	br_forward(br_port_get_rcu(outdev), skb, NULL);
+
+	return;
+
+ dest_fwd_fail:
+	if (likely(p && p->br))
+		p->br->dev->stats.tx_dropped++;
+	kfree_skb(skb);
+	return;
+}
+
+
 static void rbr_encaps(struct sk_buff *skb, uint16_t egressnick, u16 v=
id)
 {
 	uint16_t local_nick;
@@ -236,7 +281,7 @@ static void rbr_encaps(struct sk_buff *skb, uint16_=
t egressnick, u16 vid)
 	} else {
 		if (unlikely(add_header(skb, local_nick, egressnick, 0)))
 			goto encaps_drop;
-		/* TODO simple forwarding */
+		rbr_fwd(p, skb, egressnick, vid);
 	}
 	return;
=20
@@ -382,7 +427,7 @@ static void rbr_recv(struct sk_buff *skb, u16 vid)
 			rbr_decaps(p, skb, trhsize, vid);
 		} else if (likely(trill_get_hopcount(trill_flags))) {
 			br_fdb_update(p->br, p, srcaddr, vid, false);
-			/* TODO simple forwarding */
+			rbr_fwd(p, skb, trh->th_egressnick, vid);
 		} else {
 			pr_warn_ratelimited
 			    ("rbr_recv: hop count limit reached\n");
--=20
1.9.1
