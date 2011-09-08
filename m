From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 3/7] batman-adv: move routing packet
	initialization into corresponding file
Date: Thu,  8 Sep 2011 18:40:47 +0200
Message-ID: <1315500051-1122-4-git-send-email-lindner_marek@yahoo.de>
References: <1315500051-1122-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1315500051-1122-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/bat_iv_ogm.c     |   37 +++++++++++++++++++++++++++++++++++++
 net/batman-adv/bat_ogm.h        |    3 +++
 net/batman-adv/hard-interface.c |   38 ++++++--------------------------------
 3 files changed, 46 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 6fa2d46..468bd5e 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -30,6 +30,43 @@
 #include "hard-interface.h"
 #include "send.h"
 
+void bat_ogm_init(struct hard_iface *hard_iface)
+{
+	struct batman_ogm_packet *batman_ogm_packet;
+
+	hard_iface->packet_len = BATMAN_OGM_LEN;
+	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
+
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
+	batman_ogm_packet->packet_type = BAT_OGM;
+	batman_ogm_packet->version = COMPAT_VERSION;
+	batman_ogm_packet->flags = NO_FLAGS;
+	batman_ogm_packet->ttl = 2;
+	batman_ogm_packet->tq = TQ_MAX_VALUE;
+	batman_ogm_packet->tt_num_changes = 0;
+	batman_ogm_packet->ttvn = 0;
+}
+
+void bat_ogm_init_primary(struct hard_iface *hard_iface)
+{
+	struct batman_ogm_packet *batman_ogm_packet;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
+	batman_ogm_packet->flags = PRIMARIES_FIRST_HOP;
+	batman_ogm_packet->ttl = TTL;
+}
+
+void bat_ogm_update_mac(struct hard_iface *hard_iface)
+{
+	struct batman_ogm_packet *batman_ogm_packet;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
+	memcpy(batman_ogm_packet->orig,
+	       hard_iface->net_dev->dev_addr, ETH_ALEN);
+	memcpy(batman_ogm_packet->prev_sender,
+	       hard_iface->net_dev->dev_addr, ETH_ALEN);
+}
+
 /* is there another aggregated packet here? */
 static int bat_ogm_aggr_packet(int buff_pos, int packet_len,
 			       int tt_num_changes)
diff --git a/net/batman-adv/bat_ogm.h b/net/batman-adv/bat_ogm.h
index bdd3d1e..7809b92 100644
--- a/net/batman-adv/bat_ogm.h
+++ b/net/batman-adv/bat_ogm.h
@@ -24,6 +24,9 @@
 
 #include "main.h"
 
+void bat_ogm_init(struct hard_iface *hard_iface);
+void bat_ogm_init_primary(struct hard_iface *hard_iface);
+void bat_ogm_update_mac(struct hard_iface *hard_iface);
 void bat_ogm_receive(const struct ethhdr *ethhdr, unsigned char *packet_buff,
 		     int packet_len, struct hard_iface *if_incoming);
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index cfee017..2a15582 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -28,6 +28,7 @@
 #include "bat_sysfs.h"
 #include "originator.h"
 #include "hash.h"
+#include "bat_ogm.h"
 
 #include <linux/if_arp.h>
 
@@ -131,7 +132,6 @@ static void primary_if_select(struct bat_priv *bat_priv,
 			      struct hard_iface *new_hard_iface)
 {
 	struct hard_iface *curr_hard_iface;
-	struct batman_ogm_packet *batman_ogm_packet;
 
 	ASSERT_RTNL();
 
@@ -147,11 +147,7 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	if (!new_hard_iface)
 		return;
 
-	batman_ogm_packet = (struct batman_ogm_packet *)
-						(new_hard_iface->packet_buff);
-	batman_ogm_packet->flags = PRIMARIES_FIRST_HOP;
-	batman_ogm_packet->ttl = TTL;
-
+	bat_ogm_init_primary(new_hard_iface);
 	primary_if_update_addr(bat_priv);
 }
 
@@ -163,17 +159,6 @@ static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
 	return false;
 }
 
-static void update_mac_addresses(struct hard_iface *hard_iface)
-{
-	struct batman_ogm_packet *batman_ogm_packet;
-
-	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
-	memcpy(batman_ogm_packet->orig,
-	       hard_iface->net_dev->dev_addr, ETH_ALEN);
-	memcpy(batman_ogm_packet->prev_sender,
-	       hard_iface->net_dev->dev_addr, ETH_ALEN);
-}
-
 static void check_known_mac_addr(const struct net_device *net_dev)
 {
 	const struct hard_iface *hard_iface;
@@ -248,7 +233,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	update_mac_addresses(hard_iface);
+	bat_ogm_update_mac(hard_iface);
 	hard_iface->if_status = IF_TO_BE_ACTIVATED;
 
 	/**
@@ -287,7 +272,6 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 			    const char *iface_name)
 {
 	struct bat_priv *bat_priv;
-	struct batman_ogm_packet *batman_ogm_packet;
 	struct net_device *soft_iface;
 	int ret;
 
@@ -322,8 +306,8 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 
 	hard_iface->soft_iface = soft_iface;
 	bat_priv = netdev_priv(hard_iface->soft_iface);
-	hard_iface->packet_len = BATMAN_OGM_LEN;
-	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
+
+	bat_ogm_init(hard_iface);
 
 	if (!hard_iface->packet_buff) {
 		bat_err(hard_iface->soft_iface, "Can't add interface packet "
@@ -332,16 +316,6 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 		goto err;
 	}
 
-	batman_ogm_packet = (struct batman_ogm_packet *)
-						(hard_iface->packet_buff);
-	batman_ogm_packet->packet_type = BAT_OGM;
-	batman_ogm_packet->version = COMPAT_VERSION;
-	batman_ogm_packet->flags = NO_FLAGS;
-	batman_ogm_packet->ttl = 2;
-	batman_ogm_packet->tq = TQ_MAX_VALUE;
-	batman_ogm_packet->tt_num_changes = 0;
-	batman_ogm_packet->ttvn = 0;
-
 	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
 	hard_iface->if_status = IF_INACTIVE;
@@ -556,7 +530,7 @@ static int hard_if_event(struct notifier_block *this,
 			goto hardif_put;
 
 		check_known_mac_addr(hard_iface->net_dev);
-		update_mac_addresses(hard_iface);
+		bat_ogm_update_mac(hard_iface);
 
 		bat_priv = netdev_priv(hard_iface->soft_iface);
 		primary_if = primary_if_get_selected(bat_priv);
-- 
1.7.5.4
