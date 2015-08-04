From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/14] batman-adv: Make DAT capability changes atomic
Date: Tue,  4 Aug 2015 18:35:24 +0200
Message-ID: <1438706134-3492-5-git-send-email-antonio__21232.2086365477$1438707393$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:13810 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780AbbHDQ4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:56:23 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

Bitwise OR/AND assignments in C aren't guaranteed to be atomic. One
OGM handler might undo the set/clear of a specific bit from another
handler run in between.

=46ix this by using the atomic set_bit()/clear_bit()/test_bit() functio=
ns.

=46ixes: 17cf0ea455f1 ("batman-adv: tvlv - add distributed arp table co=
ntainer")
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/distributed-arp-table.c | 7 ++++---
 net/batman-adv/types.h                 | 4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
index 6d0b471..1aa4e7e 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -19,6 +19,7 @@
 #include "main.h"
=20
 #include <linux/atomic.h>
+#include <linux/bitops.h>
 #include <linux/byteorder/generic.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
@@ -453,7 +454,7 @@ static bool batadv_is_orig_node_eligible(struct bat=
adv_dat_candidate *res,
 	int j;
=20
 	/* check if orig node candidate is running DAT */
-	if (!(candidate->capabilities & BATADV_ORIG_CAPA_HAS_DAT))
+	if (!(test_bit(BATADV_ORIG_CAPA_HAS_DAT, &candidate->capabilities)))
 		goto out;
=20
 	/* Check if this node has already been selected... */
@@ -713,9 +714,9 @@ static void batadv_dat_tvlv_ogm_handler_v1(struct b=
atadv_priv *bat_priv,
 					   uint16_t tvlv_value_len)
 {
 	if (flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND)
-		orig->capabilities &=3D ~BATADV_ORIG_CAPA_HAS_DAT;
+		clear_bit(BATADV_ORIG_CAPA_HAS_DAT, &orig->capabilities);
 	else
-		orig->capabilities |=3D BATADV_ORIG_CAPA_HAS_DAT;
+		set_bit(BATADV_ORIG_CAPA_HAS_DAT, &orig->capabilities);
 }
=20
 /**
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 67d6348..29fd625 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -273,7 +273,7 @@ struct batadv_orig_node {
 	struct hlist_node mcast_want_all_ipv4_node;
 	struct hlist_node mcast_want_all_ipv6_node;
 #endif
-	uint8_t capabilities;
+	unsigned long capabilities;
 	uint8_t capa_initialized;
 	atomic_t last_ttvn;
 	unsigned char *tt_buff;
@@ -313,7 +313,7 @@ struct batadv_orig_node {
  *  (=3D orig node announces a tvlv of type BATADV_TVLV_MCAST)
  */
 enum batadv_orig_capabilities {
-	BATADV_ORIG_CAPA_HAS_DAT =3D BIT(0),
+	BATADV_ORIG_CAPA_HAS_DAT,
 	BATADV_ORIG_CAPA_HAS_NC =3D BIT(1),
 	BATADV_ORIG_CAPA_HAS_TT =3D BIT(2),
 	BATADV_ORIG_CAPA_HAS_MCAST =3D BIT(3),
--=20
2.5.0
