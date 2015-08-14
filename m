From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/10] batman-adv: Make MCAST capability changes atomic
Date: Fri, 14 Aug 2015 22:57:10 +0200
Message-ID: <1439585834-26564-7-git-send-email-antonio__44759.4056874097$1439585913$gmane$org@meshcoding.com>
References: <1439585834-26564-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:37664 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbbHNU5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 16:57:39 -0400
In-Reply-To: <1439585834-26564-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

Bitwise OR/AND assignments in C aren't guaranteed to be atomic. One
OGM handler might undo the set/clear of a specific bit from another
handler run in between.

=46ix this by using the atomic set_bit()/clear_bit()/test_bit() functio=
ns.

=46ixes: 60432d756cf0 ("batman-adv: Announce new capability via multica=
st TVLV")
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/multicast.c | 18 ++++++++++--------
 net/batman-adv/types.h     |  2 +-
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 7aa480b..8f1ec21 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -19,6 +19,7 @@
 #include "main.h"
=20
 #include <linux/atomic.h>
+#include <linux/bitops.h>
 #include <linux/byteorder/generic.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
@@ -697,29 +698,30 @@ static void batadv_mcast_tvlv_ogm_handler_v1(stru=
ct batadv_priv *bat_priv,
 	uint8_t mcast_flags =3D BATADV_NO_FLAGS;
 	bool orig_initialized;
=20
-	orig_initialized =3D orig->capa_initialized & BATADV_ORIG_CAPA_HAS_MC=
AST;
+	orig_initialized =3D test_bit(BATADV_ORIG_CAPA_HAS_MCAST,
+				    &orig->capa_initialized);
=20
 	/* If mcast support is turned on decrease the disabled mcast node
 	 * counter only if we had increased it for this node before. If this
 	 * is a completely new orig_node no need to decrease the counter.
 	 */
 	if (orig_mcast_enabled &&
-	    !(orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST)) {
+	    !test_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capabilities)) {
 		if (orig_initialized)
 			atomic_dec(&bat_priv->mcast.num_disabled);
-		orig->capabilities |=3D BATADV_ORIG_CAPA_HAS_MCAST;
+		set_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capabilities);
 	/* If mcast support is being switched off or if this is an initial
 	 * OGM without mcast support then increase the disabled mcast
 	 * node counter.
 	 */
 	} else if (!orig_mcast_enabled &&
-		   (orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST ||
+		   (test_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capabilities) ||
 		    !orig_initialized)) {
 		atomic_inc(&bat_priv->mcast.num_disabled);
-		orig->capabilities &=3D ~BATADV_ORIG_CAPA_HAS_MCAST;
+		clear_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capabilities);
 	}
=20
-	orig->capa_initialized |=3D BATADV_ORIG_CAPA_HAS_MCAST;
+	set_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capa_initialized);
=20
 	if (orig_mcast_enabled && tvlv_value &&
 	    (tvlv_value_len >=3D sizeof(mcast_flags)))
@@ -763,8 +765,8 @@ void batadv_mcast_purge_orig(struct batadv_orig_nod=
e *orig)
 {
 	struct batadv_priv *bat_priv =3D orig->bat_priv;
=20
-	if (!(orig->capabilities & BATADV_ORIG_CAPA_HAS_MCAST) &&
-	    orig->capa_initialized & BATADV_ORIG_CAPA_HAS_MCAST)
+	if (!test_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capabilities) &&
+	    test_bit(BATADV_ORIG_CAPA_HAS_MCAST, &orig->capa_initialized))
 		atomic_dec(&bat_priv->mcast.num_disabled);
=20
 	batadv_mcast_want_unsnoop_update(bat_priv, orig, BATADV_NO_FLAGS);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 6f801ef..1eeed18 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -316,7 +316,7 @@ enum batadv_orig_capabilities {
 	BATADV_ORIG_CAPA_HAS_DAT,
 	BATADV_ORIG_CAPA_HAS_NC,
 	BATADV_ORIG_CAPA_HAS_TT,
-	BATADV_ORIG_CAPA_HAS_MCAST =3D BIT(3),
+	BATADV_ORIG_CAPA_HAS_MCAST,
 };
=20
 /**
--=20
2.5.0
