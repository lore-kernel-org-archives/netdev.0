From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 09/15] batman-adv: refactoring API: find generalized name for bat_ogm_update_mac callback
Date: Fri, 11 May 2012 14:21:26 +0200
Message-ID: <1336738892-7401-10-git-send-email-ordex@autistici.org>
References: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58511 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758115Ab2EKMZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 08:25:23 -0400
In-Reply-To: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c     |   24 ++++++++++++------------
 net/batman-adv/hard-interface.c |    4 ++--
 net/batman-adv/main.c           |    2 +-
 net/batman-adv/types.h          |    6 ++++--
 4 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 37e368d..9074e74 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -93,6 +93,17 @@ static void bat_iv_ogm_iface_disable(struct hard_iface *hard_iface)
 	hard_iface->packet_buff = NULL;
 }
 
+static void bat_iv_ogm_iface_update_mac(struct hard_iface *hard_iface)
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
 static void bat_iv_ogm_primary_iface_set(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
@@ -102,17 +113,6 @@ static void bat_iv_ogm_primary_iface_set(struct hard_iface *hard_iface)
 	batman_ogm_packet->header.ttl = TTL;
 }
 
-static void bat_iv_ogm_update_mac(struct hard_iface *hard_iface)
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
 /* when do we schedule our own ogm to be sent */
 static unsigned long bat_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
 {
@@ -1236,8 +1236,8 @@ static struct bat_algo_ops batman_iv __read_mostly = {
 	.name = "BATMAN IV",
 	.bat_iface_enable = bat_iv_ogm_iface_enable,
 	.bat_iface_disable = bat_iv_ogm_iface_disable,
+	.bat_iface_update_mac = bat_iv_ogm_iface_update_mac,
 	.bat_primary_iface_set = bat_iv_ogm_primary_iface_set,
-	.bat_ogm_update_mac = bat_iv_ogm_update_mac,
 	.bat_ogm_schedule = bat_iv_ogm_schedule,
 	.bat_ogm_emit = bat_iv_ogm_emit,
 };
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 95f869c..0b84bb1 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -228,7 +228,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	bat_priv->bat_algo_ops->bat_ogm_update_mac(hard_iface);
+	bat_priv->bat_algo_ops->bat_iface_update_mac(hard_iface);
 	hard_iface->if_status = IF_TO_BE_ACTIVATED;
 
 	/**
@@ -524,7 +524,7 @@ static int hard_if_event(struct notifier_block *this,
 		check_known_mac_addr(hard_iface->net_dev);
 
 		bat_priv = netdev_priv(hard_iface->soft_iface);
-		bat_priv->bat_algo_ops->bat_ogm_update_mac(hard_iface);
+		bat_priv->bat_algo_ops->bat_iface_update_mac(hard_iface);
 
 		primary_if = primary_if_get_selected(bat_priv);
 		if (!primary_if)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index f80c447..083a299 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -329,8 +329,8 @@ int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
 	/* all algorithms must implement all ops (for now) */
 	if (!bat_algo_ops->bat_iface_enable ||
 	    !bat_algo_ops->bat_iface_disable ||
+	    !bat_algo_ops->bat_iface_update_mac ||
 	    !bat_algo_ops->bat_primary_iface_set ||
-	    !bat_algo_ops->bat_ogm_update_mac ||
 	    !bat_algo_ops->bat_ogm_schedule ||
 	    !bat_algo_ops->bat_ogm_emit) {
 		pr_info("Routing algo '%s' does not implement required ops\n",
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9fa8b73..66a3750 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -381,10 +381,12 @@ struct bat_algo_ops {
 	int (*bat_iface_enable)(struct hard_iface *hard_iface);
 	/* de-init routing info when hard-interface is disabled */
 	void (*bat_iface_disable)(struct hard_iface *hard_iface);
+	/* (re-)init mac addresses of the protocol information
+	 * belonging to this hard-interface
+	 */
+	void (*bat_iface_update_mac)(struct hard_iface *hard_iface);
 	/* called when primary interface is selected / changed */
 	void (*bat_primary_iface_set)(struct hard_iface *hard_iface);
-	/* init mac addresses of the OGM belonging to this hard-interface */
-	void (*bat_ogm_update_mac)(struct hard_iface *hard_iface);
 	/* prepare a new outgoing OGM for the send queue */
 	void (*bat_ogm_schedule)(struct hard_iface *hard_iface,
 				 int tt_num_changes);
-- 
1.7.9.4
