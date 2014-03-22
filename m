From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/16] batman-adv: introduce capability initialization bitfield
Date: Sat, 22 Mar 2014 09:56:09 +0100
Message-ID: <1395478576-10999-10-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:29656 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbaCVI44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:56 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

The new bitfield allows us to keep track whether capability subsets of
an originator have gone through their initialization phase yet.

The translation table is the only user right now, but a new one will be
added soon.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c        |  1 -
 net/batman-adv/translation-table.c | 12 +++++++-----
 net/batman-adv/types.h             |  7 ++++---
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 9f2da37..24a9300 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -664,7 +664,6 @@ struct batadv_orig_node *batadv_orig_node_new(struc=
t batadv_priv *bat_priv,
 	/* extra reference for return */
 	atomic_set(&orig_node->refcount, 2);
=20
-	orig_node->tt_initialised =3D false;
 	orig_node->bat_priv =3D bat_priv;
 	ether_addr_copy(orig_node->orig, addr);
 	batadv_dat_init_orig_node_addr(orig_node);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 4082d05..f641dfe 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1774,7 +1774,7 @@ void batadv_tt_global_del_orig(struct batadv_priv=
 *bat_priv,
 		}
 		spin_unlock_bh(list_lock);
 	}
-	orig_node->tt_initialised =3D false;
+	orig_node->capa_initialized &=3D ~BATADV_ORIG_CAPA_HAS_TT;
 }
=20
 static bool batadv_tt_global_to_purge(struct batadv_tt_global_entry *t=
t_global,
@@ -2734,7 +2734,7 @@ static void _batadv_tt_update_changes(struct bata=
dv_priv *bat_priv,
 				return;
 		}
 	}
-	orig_node->tt_initialised =3D true;
+	orig_node->capa_initialized |=3D BATADV_ORIG_CAPA_HAS_TT;
 }
=20
 static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
@@ -3224,13 +3224,15 @@ static void batadv_tt_update_orig(struct batadv=
_priv *bat_priv,
 	uint8_t orig_ttvn =3D (uint8_t)atomic_read(&orig_node->last_ttvn);
 	struct batadv_tvlv_tt_vlan_data *tt_vlan;
 	bool full_table =3D true;
+	bool has_tt_init;
=20
 	tt_vlan =3D (struct batadv_tvlv_tt_vlan_data *)tt_buff;
+	has_tt_init =3D orig_node->capa_initialized & BATADV_ORIG_CAPA_HAS_TT=
;
+
 	/* orig table not initialised AND first diff is in the OGM OR the ttv=
n
 	 * increased by one -> we can apply the attached changes
 	 */
-	if ((!orig_node->tt_initialised && ttvn =3D=3D 1) ||
-	    ttvn - orig_ttvn =3D=3D 1) {
+	if ((!has_tt_init && ttvn =3D=3D 1) || ttvn - orig_ttvn =3D=3D 1) {
 		/* the OGM could not contain the changes due to their size or
 		 * because they have already been sent BATADV_TT_OGM_APPEND_MAX
 		 * times.
@@ -3270,7 +3272,7 @@ static void batadv_tt_update_orig(struct batadv_p=
riv *bat_priv,
 		/* if we missed more than one change or our tables are not
 		 * in sync anymore -> request fresh tt data
 		 */
-		if (!orig_node->tt_initialised || ttvn !=3D orig_ttvn ||
+		if (!has_tt_init || ttvn !=3D orig_ttvn ||
 		    !batadv_tt_global_check_crc(orig_node, tt_vlan,
 						tt_num_vlan)) {
 request_table:
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d553264..b46117c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -205,13 +205,12 @@ struct batadv_orig_bat_iv {
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @capabilities: announced capabilities of this originator
+ * @capa_initialized: bitfield to remember whether a capability was in=
itialized
  * @last_ttvn: last seen translation table version number
  * @tt_buff: last tt changeset this node received from the orig node
  * @tt_buff_len: length of the last tt changeset this node received fr=
om the
  *  orig node
  * @tt_buff_lock: lock that protects tt_buff and tt_buff_len
- * @tt_initialised: bool keeping track of whether or not this node hav=
e received
- *  any translation table information from the orig node yet
  * @tt_lock: prevents from updating the table while reading it. Table =
update is
  *  made up by two operations (data structure update and metdata -CRC/=
TTVN-
  *  recalculation) and they have to be executed atomically in order to=
 avoid
@@ -248,11 +247,11 @@ struct batadv_orig_node {
 	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
 	uint8_t capabilities;
+	uint8_t capa_initialized;
 	atomic_t last_ttvn;
 	unsigned char *tt_buff;
 	int16_t tt_buff_len;
 	spinlock_t tt_buff_lock; /* protects tt_buff & tt_buff_len */
-	bool tt_initialised;
 	/* prevents from changing the table while reading it */
 	spinlock_t tt_lock;
 	DECLARE_BITMAP(bcast_bits, BATADV_TQ_LOCAL_WINDOW_SIZE);
@@ -282,10 +281,12 @@ struct batadv_orig_node {
  * enum batadv_orig_capabilities - orig node capabilities
  * @BATADV_ORIG_CAPA_HAS_DAT: orig node has distributed arp table enab=
led
  * @BATADV_ORIG_CAPA_HAS_NC: orig node has network coding enabled
+ * @BATADV_ORIG_CAPA_HAS_TT: orig node has tt capability
  */
 enum batadv_orig_capabilities {
 	BATADV_ORIG_CAPA_HAS_DAT =3D BIT(0),
 	BATADV_ORIG_CAPA_HAS_NC =3D BIT(1),
+	BATADV_ORIG_CAPA_HAS_TT =3D BIT(2),
 };
=20
 /**
--=20
1.8.3.2
