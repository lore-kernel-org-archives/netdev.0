From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/2] batman-adv: Fix broadcast packet CRC calculation
Date: Thu, 18 Oct 2012 21:24:54 +0200
Message-ID: <1350588295-22587-2-git-send-email-ordex@autistici.org>
References: <1350588295-22587-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:61143 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab2JRTZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:25:41 -0400
In-Reply-To: <1350588295-22587-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

So far the crc16 checksum for a batman-adv broadcast data packet, recei=
ved
on a batman-adv hard interface, was calculated over zero bytes of its
content leading to many incoming broadcast data packets wrongly being
dropped (60-80% packet loss).

This patch fixes this issue by calculating the crc16 over the actual,
complete broadcast payload.

The issue is a regression introduced by
("batman-adv: add broadcast duplicate check").

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 8 ++++----
 net/batman-adv/routing.c               | 8 +++++++-
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index 0a9084a..eebab20 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1210,8 +1210,8 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 /**
  * batadv_bla_check_bcast_duplist
  * @bat_priv: the bat priv with all the soft interface information
- * @bcast_packet: originator mac address
- * @hdr_size: maximum length of the frame
+ * @bcast_packet: encapsulated broadcast frame plus batman header
+ * @bcast_packet_len: length of encapsulated broadcast frame plus batm=
an header
  *
  * check if it is on our broadcast list. Another gateway might
  * have sent the same packet because it is connected to the same backb=
one,
@@ -1224,14 +1224,14 @@ int batadv_bla_init(struct batadv_priv *bat_pri=
v)
  */
 int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 				   struct batadv_bcast_packet *bcast_packet,
-				   int hdr_size)
+				   int bcast_packet_len)
 {
 	int i, length, curr;
 	uint8_t *content;
 	uint16_t crc;
 	struct batadv_bcast_duplist_entry *entry;
=20
-	length =3D hdr_size - sizeof(*bcast_packet);
+	length =3D bcast_packet_len - sizeof(*bcast_packet);
 	content =3D (uint8_t *)bcast_packet;
 	content +=3D sizeof(*bcast_packet);
=20
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 939fc01..376b4cc 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1124,8 +1124,14 @@ int batadv_recv_bcast_packet(struct sk_buff *skb=
,
=20
 	spin_unlock_bh(&orig_node->bcast_seqno_lock);
=20
+	/* keep skb linear for crc calculation */
+	if (skb_linearize(skb) < 0)
+		goto out;
+
+	bcast_packet =3D (struct batadv_bcast_packet *)skb->data;
+
 	/* check whether this has been sent by another originator before */
-	if (batadv_bla_check_bcast_duplist(bat_priv, bcast_packet, hdr_size))
+	if (batadv_bla_check_bcast_duplist(bat_priv, bcast_packet, skb->len))
 		goto out;
=20
 	/* rebroadcast packet */
--=20
1.7.12.3
