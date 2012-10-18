From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/2] batman-adv: Fix potential broadcast BLA-duplicate-check race condition
Date: Thu, 18 Oct 2012 21:24:55 +0200
Message-ID: <1350588295-22587-3-git-send-email-ordex@autistici.org>
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
Received: from contumacia.investici.org ([178.255.144.35]:61209 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab2JRTZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:25:43 -0400
In-Reply-To: <1350588295-22587-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

Threads in the bottom half of batadv_bla_check_bcast_duplist() might
otherwise for instance overwrite variables which other threads might
be using/reading at the same time in the top half, potentially
leading to messing up the bcast_duplist, possibly resulting in false
bridge loop avoidance duplicate check decisions.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c | 19 ++++++++++++++-----
 net/batman-adv/types.h                 |  2 ++
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/br=
idge_loop_avoidance.c
index eebab20..fd8d5af 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1167,6 +1167,8 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 	uint16_t crc;
 	unsigned long entrytime;
=20
+	spin_lock_init(&bat_priv->bla.bcast_duplist_lock);
+
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla hash registering\n");
=20
 	/* setting claim destination address */
@@ -1226,7 +1228,7 @@ int batadv_bla_check_bcast_duplist(struct batadv_=
priv *bat_priv,
 				   struct batadv_bcast_packet *bcast_packet,
 				   int bcast_packet_len)
 {
-	int i, length, curr;
+	int i, length, curr, ret =3D 0;
 	uint8_t *content;
 	uint16_t crc;
 	struct batadv_bcast_duplist_entry *entry;
@@ -1238,6 +1240,8 @@ int batadv_bla_check_bcast_duplist(struct batadv_=
priv *bat_priv,
 	/* calculate the crc ... */
 	crc =3D crc16(0, content, length);
=20
+	spin_lock_bh(&bat_priv->bla.bcast_duplist_lock);
+
 	for (i =3D 0; i < BATADV_DUPLIST_SIZE; i++) {
 		curr =3D (bat_priv->bla.bcast_duplist_curr + i);
 		curr %=3D BATADV_DUPLIST_SIZE;
@@ -1259,9 +1263,12 @@ int batadv_bla_check_bcast_duplist(struct batadv=
_priv *bat_priv,
 		/* this entry seems to match: same crc, not too old,
 		 * and from another gw. therefore return 1 to forbid it.
 		 */
-		return 1;
+		ret =3D 1;
+		goto out;
 	}
-	/* not found, add a new entry (overwrite the oldest entry) */
+	/* not found, add a new entry (overwrite the oldest entry)
+	 * and allow it, its the first occurence.
+	 */
 	curr =3D (bat_priv->bla.bcast_duplist_curr + BATADV_DUPLIST_SIZE - 1)=
;
 	curr %=3D BATADV_DUPLIST_SIZE;
 	entry =3D &bat_priv->bla.bcast_duplist[curr];
@@ -1270,8 +1277,10 @@ int batadv_bla_check_bcast_duplist(struct batadv=
_priv *bat_priv,
 	memcpy(entry->orig, bcast_packet->orig, ETH_ALEN);
 	bat_priv->bla.bcast_duplist_curr =3D curr;
=20
-	/* allow it, its the first occurence. */
-	return 0;
+out:
+	spin_unlock_bh(&bat_priv->bla.bcast_duplist_lock);
+
+	return ret;
 }
=20
=20
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 2ed82ca..ac1e07a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -205,6 +205,8 @@ struct batadv_priv_bla {
 	struct batadv_hashtable *backbone_hash;
 	struct batadv_bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
 	int bcast_duplist_curr;
+	/* protects bcast_duplist and bcast_duplist_curr */
+	spinlock_t bcast_duplist_lock;
 	struct batadv_bla_claim_dst claim_dest;
 	struct delayed_work work;
 };
--=20
1.7.12.3
