From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/18] batman-adv: Drop tt queries with foreign dest
Date: Thu, 23 Aug 2012 15:10:21 +0200
Message-ID: <1345727427-20805-13-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28737 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933689Ab2HWNLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:11:00 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

When enabling promiscuous mode, tt queries for other hosts might be
received. Before this patch, "foreign" tt queries were processed like
any other query and thus forwarded to its destination again and thereby
causing a loop.

This patch adds a check to drop foreign tt queries.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c |   18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a79ded5..4961278 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -609,29 +609,17 @@ int batadv_recv_tt_query(struct sk_buff *skb, str=
uct batadv_hard_iface *recv_if)
 	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
 	struct batadv_tt_query_packet *tt_query;
 	uint16_t tt_size;
-	struct ethhdr *ethhdr;
+	int hdr_size =3D sizeof(*tt_query);
 	char tt_flag;
 	size_t packet_size;
=20
-	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb,
-				    sizeof(struct batadv_tt_query_packet))))
-		goto out;
+	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
+		return NET_RX_DROP;
=20
 	/* I could need to modify it */
 	if (skb_cow(skb, sizeof(struct batadv_tt_query_packet)) < 0)
 		goto out;
=20
-	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
-
-	/* packet with unicast indication but broadcast recipient */
-	if (is_broadcast_ether_addr(ethhdr->h_dest))
-		goto out;
-
-	/* packet with broadcast sender address */
-	if (is_broadcast_ether_addr(ethhdr->h_source))
-		goto out;
-
 	tt_query =3D (struct batadv_tt_query_packet *)skb->data;
=20
 	switch (tt_query->flags & BATADV_TT_QUERY_TYPE_MASK) {
--=20
1.7.9.4
