From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 2/4] batman-adv: remove unnecessary logspam
Date: Tue,  5 Aug 2014 09:36:26 +0200
Message-ID: <1407224188-28626-3-git-send-email-antonio@meshcoding.com>
References: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Andr=C3=A9=20Gaul?= <gaul@web-yard.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:32413 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202AbaHEHhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:37:18 -0400
In-Reply-To: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andr=C3=A9 Gaul <gaul@web-yard.de>

This patch removes unnecessary logspam which resulted from superfluous
calls to net_ratelimit(). With the supplied patch, net_ratelimit() is
called after the loglevel has been checked.

Signed-off-by: Andr=C3=A9 Gaul <gaul@web-yard.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/main.h    | 20 ++++++++++++++------
 net/batman-adv/routing.c | 18 +++++++++---------
 2 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 118b990..257840e 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -238,21 +238,29 @@ enum batadv_dbg_level {
 int batadv_debug_log(struct batadv_priv *bat_priv, const char *fmt, ..=
=2E)
 __printf(2, 3);
=20
-#define batadv_dbg(type, bat_priv, fmt, arg...)			\
+/* possibly ratelimited debug output */
+#define _batadv_dbg(type, bat_priv, ratelimited, fmt, arg...)	\
 	do {							\
-		if (atomic_read(&bat_priv->log_level) & type)	\
+		if (atomic_read(&bat_priv->log_level) & type && \
+		    (!ratelimited || net_ratelimit()))		\
 			batadv_debug_log(bat_priv, fmt, ## arg);\
 	}							\
 	while (0)
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
-__printf(3, 4)
-static inline void batadv_dbg(int type __always_unused,
-			      struct batadv_priv *bat_priv __always_unused,
-			      const char *fmt __always_unused, ...)
+__printf(4, 5)
+static inline void _batadv_dbg(int type __always_unused,
+			       struct batadv_priv *bat_priv __always_unused,
+			       int ratelimited __always_unused,
+			       const char *fmt __always_unused, ...)
 {
 }
 #endif
=20
+#define batadv_dbg(type, bat_priv, arg...) \
+	_batadv_dbg(type, bat_priv, 0, ## arg)
+#define batadv_dbg_ratelimited(type, bat_priv, arg...) \
+	_batadv_dbg(type, bat_priv, 1, ## arg)
+
 #define batadv_info(net_dev, fmt, arg...)				\
 	do {								\
 		struct net_device *_netdev =3D (net_dev);                 \
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 3514153..35f76f2 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -706,11 +706,11 @@ static int batadv_check_unicast_ttvn(struct batad=
v_priv *bat_priv,
 	if (batadv_tt_local_client_is_roaming(bat_priv, ethhdr->h_dest, vid))=
 {
 		if (batadv_reroute_unicast_packet(bat_priv, unicast_packet,
 						  ethhdr->h_dest, vid))
-			net_ratelimited_function(batadv_dbg, BATADV_DBG_TT,
-						 bat_priv,
-						 "Rerouting unicast packet to %pM (dst=3D%pM): Local Roaming\n",
-						 unicast_packet->dest,
-						 ethhdr->h_dest);
+			batadv_dbg_ratelimited(BATADV_DBG_TT,
+					       bat_priv,
+					       "Rerouting unicast packet to %pM (dst=3D%pM): Local Roamin=
g\n",
+					       unicast_packet->dest,
+					       ethhdr->h_dest);
 		/* at this point the mesh destination should have been
 		 * substituted with the originator address found in the global
 		 * table. If not, let the packet go untouched anyway because
@@ -752,10 +752,10 @@ static int batadv_check_unicast_ttvn(struct batad=
v_priv *bat_priv,
 	 */
 	if (batadv_reroute_unicast_packet(bat_priv, unicast_packet,
 					  ethhdr->h_dest, vid)) {
-		net_ratelimited_function(batadv_dbg, BATADV_DBG_TT, bat_priv,
-					 "Rerouting unicast packet to %pM (dst=3D%pM): TTVN mismatch old_=
ttvn=3D%u new_ttvn=3D%u\n",
-					 unicast_packet->dest, ethhdr->h_dest,
-					 old_ttvn, curr_ttvn);
+		batadv_dbg_ratelimited(BATADV_DBG_TT, bat_priv,
+				       "Rerouting unicast packet to %pM (dst=3D%pM): TTVN mismatch=
 old_ttvn=3D%u new_ttvn=3D%u\n",
+				       unicast_packet->dest, ethhdr->h_dest,
+				       old_ttvn, curr_ttvn);
 		return 1;
 	}
=20
--=20
1.8.5.5
