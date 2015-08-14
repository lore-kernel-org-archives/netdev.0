From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/10] batman-adv: Make TT capability changes atomic
Date: Fri, 14 Aug 2015 22:57:09 +0200
Message-ID: <1439585834-26564-6-git-send-email-antonio@meshcoding.com>
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
Received: from s1.neomailbox.net ([5.148.176.57]:44363 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbbHNU5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 16:57:36 -0400
In-Reply-To: <1439585834-26564-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

Bitwise OR/AND assignments in C aren't guaranteed to be atomic. One
OGM handler might undo the set/clear of a specific bit from another
handler run in between.

=46ix this by using the atomic set_bit()/clear_bit()/test_bit() functio=
ns.

=46ixes: e17931d1a61d ("batman-adv: introduce capability initialization=
 bitfield")
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/translation-table.c | 8 +++++---
 net/batman-adv/types.h             | 4 ++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index b482495..1573489 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -19,6 +19,7 @@
 #include "main.h"
=20
 #include <linux/atomic.h>
+#include <linux/bitops.h>
 #include <linux/bug.h>
 #include <linux/byteorder/generic.h>
 #include <linux/compiler.h>
@@ -1862,7 +1863,7 @@ void batadv_tt_global_del_orig(struct batadv_priv=
 *bat_priv,
 		}
 		spin_unlock_bh(list_lock);
 	}
-	orig_node->capa_initialized &=3D ~BATADV_ORIG_CAPA_HAS_TT;
+	clear_bit(BATADV_ORIG_CAPA_HAS_TT, &orig_node->capa_initialized);
 }
=20
 static bool batadv_tt_global_to_purge(struct batadv_tt_global_entry *t=
t_global,
@@ -2821,7 +2822,7 @@ static void _batadv_tt_update_changes(struct bata=
dv_priv *bat_priv,
 				return;
 		}
 	}
-	orig_node->capa_initialized |=3D BATADV_ORIG_CAPA_HAS_TT;
+	set_bit(BATADV_ORIG_CAPA_HAS_TT, &orig_node->capa_initialized);
 }
=20
 static void batadv_tt_fill_gtable(struct batadv_priv *bat_priv,
@@ -3321,7 +3322,8 @@ static void batadv_tt_update_orig(struct batadv_p=
riv *bat_priv,
 	bool has_tt_init;
=20
 	tt_vlan =3D (struct batadv_tvlv_tt_vlan_data *)tt_buff;
-	has_tt_init =3D orig_node->capa_initialized & BATADV_ORIG_CAPA_HAS_TT=
;
+	has_tt_init =3D test_bit(BATADV_ORIG_CAPA_HAS_TT,
+			       &orig_node->capa_initialized);
=20
 	/* orig table not initialised AND first diff is in the OGM OR the ttv=
n
 	 * increased by one -> we can apply the attached changes
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ed4aec5..6f801ef 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -274,7 +274,7 @@ struct batadv_orig_node {
 	struct hlist_node mcast_want_all_ipv6_node;
 #endif
 	unsigned long capabilities;
-	uint8_t capa_initialized;
+	unsigned long capa_initialized;
 	atomic_t last_ttvn;
 	unsigned char *tt_buff;
 	int16_t tt_buff_len;
@@ -315,7 +315,7 @@ struct batadv_orig_node {
 enum batadv_orig_capabilities {
 	BATADV_ORIG_CAPA_HAS_DAT,
 	BATADV_ORIG_CAPA_HAS_NC,
-	BATADV_ORIG_CAPA_HAS_TT =3D BIT(2),
+	BATADV_ORIG_CAPA_HAS_TT,
 	BATADV_ORIG_CAPA_HAS_MCAST =3D BIT(3),
 };
=20
--=20
2.5.0
