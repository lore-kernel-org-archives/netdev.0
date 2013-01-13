From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/15] batman-adv: Initialize lockdep class keys for hashes
Date: Mon, 14 Jan 2013 09:41:13 +1000
Message-ID: <1358120480-25960-9-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49703 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755708Ab3AMXm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:42:59 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different hashes have the same class key because they get
initialised with the same one. For this reason lockdep can create
false warning when they are used recursively.

Re-initialise the key for each hash after the invocation to hash_new()
to avoid this problem.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Tested-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/originator.c        |  6 ++++++
 net/batman-adv/translation-table.c | 10 ++++++++++
 net/batman-adv/vis.c               |  6 ++++++
 3 files changed, 22 insertions(+)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8c32cf1..109081c4 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -29,6 +29,9 @@
 #include "soft-interface.h"
 #include "bridge_loop_avoidance.h"
=20
+/* hash class keys */
+static struct lock_class_key batadv_orig_hash_lock_class_key;
+
 static void batadv_purge_orig(struct work_struct *work);
=20
 static void batadv_start_purge_timer(struct batadv_priv *bat_priv)
@@ -57,6 +60,9 @@ int batadv_originator_init(struct batadv_priv *bat_pr=
iv)
 	if (!bat_priv->orig_hash)
 		goto err;
=20
+	batadv_hash_set_lock_class(bat_priv->orig_hash,
+				   &batadv_orig_hash_lock_class_key);
+
 	batadv_start_purge_timer(bat_priv);
 	return 0;
=20
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index 5f44232..c6fd0b7 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -29,6 +29,10 @@
=20
 #include <linux/crc16.h>
=20
+/* hash class keys */
+static struct lock_class_key batadv_tt_local_hash_lock_class_key;
+static struct lock_class_key batadv_tt_global_hash_lock_class_key;
+
 static void batadv_send_roam_adv(struct batadv_priv *bat_priv, uint8_t=
 *client,
 				 struct batadv_orig_node *orig_node);
 static void batadv_tt_purge(struct work_struct *work);
@@ -235,6 +239,9 @@ static int batadv_tt_local_init(struct batadv_priv =
*bat_priv)
 	if (!bat_priv->tt.local_hash)
 		return -ENOMEM;
=20
+	batadv_hash_set_lock_class(bat_priv->tt.local_hash,
+				   &batadv_tt_local_hash_lock_class_key);
+
 	return 0;
 }
=20
@@ -694,6 +701,9 @@ static int batadv_tt_global_init(struct batadv_priv=
 *bat_priv)
 	if (!bat_priv->tt.global_hash)
 		return -ENOMEM;
=20
+	batadv_hash_set_lock_class(bat_priv->tt.global_hash,
+				   &batadv_tt_global_hash_lock_class_key);
+
 	return 0;
 }
=20
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 0f65a9d..60eb9b7 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -28,6 +28,9 @@
=20
 #define BATADV_MAX_VIS_PACKET_SIZE 1000
=20
+/* hash class keys */
+static struct lock_class_key batadv_vis_hash_lock_class_key;
+
 static void batadv_start_vis_timer(struct batadv_priv *bat_priv);
=20
 /* free the info */
@@ -852,6 +855,9 @@ int batadv_vis_init(struct batadv_priv *bat_priv)
 		goto err;
 	}
=20
+	batadv_hash_set_lock_class(bat_priv->vis.hash,
+				   &batadv_vis_hash_lock_class_key);
+
 	bat_priv->vis.my_info =3D kmalloc(BATADV_MAX_VIS_PACKET_SIZE, GFP_ATO=
MIC);
 	if (!bat_priv->vis.my_info)
 		goto err;
--=20
1.8.0.2
