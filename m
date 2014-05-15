From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 2/4] batman-adv: fix reference counting imbalance while sending fragment
Date: Thu, 15 May 2014 20:50:50 +0200
Message-ID: <1400179852-4064-3-git-send-email-antonio@meshcoding.com>
References: <1400179852-4064-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:31462 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbaEOSxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:53:11 -0400
In-Reply-To: <1400179852-4064-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <antonio@open-mesh.com>

In the new fragmentation code the batadv_frag_send_packet()
function obtains a reference to the primary_if, but it does
not release it upon return.

This reference imbalance prevents the primary_if (and then
the related netdevice) to be properly released on shut down.

=46ix this by releasing the primary_if in batadv_frag_send_packet().

Introduced by ee75ed88879af88558818a5c6609d85f60ff0df4
("batman-adv: Fragment and send skbs larger than mtu")

Cc: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
---
 net/batman-adv/fragmentation.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index bcc4bea..f14e54a 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -418,12 +418,13 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 			     struct batadv_neigh_node *neigh_node)
 {
 	struct batadv_priv *bat_priv;
-	struct batadv_hard_iface *primary_if;
+	struct batadv_hard_iface *primary_if =3D NULL;
 	struct batadv_frag_packet frag_header;
 	struct sk_buff *skb_fragment;
 	unsigned mtu =3D neigh_node->if_incoming->net_dev->mtu;
 	unsigned header_size =3D sizeof(frag_header);
 	unsigned max_fragment_size, max_packet_size;
+	bool ret =3D false;
=20
 	/* To avoid merge and refragmentation at next-hops we never send
 	 * fragments larger than BATADV_FRAG_MAX_FRAG_SIZE
@@ -483,7 +484,11 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 			   skb->len + ETH_HLEN);
 	batadv_send_skb_packet(skb, neigh_node->if_incoming, neigh_node->addr=
);
=20
-	return true;
+	ret =3D true;
+
 out_err:
-	return false;
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+
+	return ret;
 }
--=20
1.8.5.5
