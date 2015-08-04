From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 05/14] batman-adv: Make NC capability changes atomic
Date: Tue,  4 Aug 2015 18:35:25 +0200
Message-ID: <1438706134-3492-6-git-send-email-antonio__34650.7885064513$1438707314$gmane$org@meshcoding.com>
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
Received: from s1.neomailbox.net ([5.148.176.57]:33218 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbbHDQyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:54:52 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

Bitwise OR/AND assignments in C aren't guaranteed to be atomic. One
OGM handler might undo the set/clear of a specific bit from another
handler run in between.

=46ix this by using the atomic set_bit()/clear_bit()/test_bit() functio=
ns.

=46ixes: 3f4841ffb336 ("batman-adv: tvlv - add network coding container=
")
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/network-coding.c | 7 ++++---
 net/batman-adv/types.h          | 2 +-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index f0a50f3..cfdc80d 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -19,6 +19,7 @@
 #include "main.h"
=20
 #include <linux/atomic.h>
+#include <linux/bitops.h>
 #include <linux/byteorder/generic.h>
 #include <linux/compiler.h>
 #include <linux/debugfs.h>
@@ -134,9 +135,9 @@ static void batadv_nc_tvlv_ogm_handler_v1(struct ba=
tadv_priv *bat_priv,
 					  uint16_t tvlv_value_len)
 {
 	if (flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND)
-		orig->capabilities &=3D ~BATADV_ORIG_CAPA_HAS_NC;
+		clear_bit(BATADV_ORIG_CAPA_HAS_NC, &orig->capabilities);
 	else
-		orig->capabilities |=3D BATADV_ORIG_CAPA_HAS_NC;
+		set_bit(BATADV_ORIG_CAPA_HAS_NC, &orig->capabilities);
 }
=20
 /**
@@ -894,7 +895,7 @@ void batadv_nc_update_nc_node(struct batadv_priv *b=
at_priv,
 		goto out;
=20
 	/* check if orig node is network coding enabled */
-	if (!(orig_node->capabilities & BATADV_ORIG_CAPA_HAS_NC))
+	if (!(test_bit(BATADV_ORIG_CAPA_HAS_NC, &orig_node->capabilities)))
 		goto out;
=20
 	/* accept ogms from 'good' neighbors and single hop neighbors */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 29fd625..ed4aec5 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -314,7 +314,7 @@ struct batadv_orig_node {
  */
 enum batadv_orig_capabilities {
 	BATADV_ORIG_CAPA_HAS_DAT,
-	BATADV_ORIG_CAPA_HAS_NC =3D BIT(1),
+	BATADV_ORIG_CAPA_HAS_NC,
 	BATADV_ORIG_CAPA_HAS_TT =3D BIT(2),
 	BATADV_ORIG_CAPA_HAS_MCAST =3D BIT(3),
 };
--=20
2.5.0
