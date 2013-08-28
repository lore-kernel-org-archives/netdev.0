From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 4/4] batman-adv: send GW_DEL event when the gw client mode is deselected
Date: Wed, 28 Aug 2013 13:28:11 +0200
Message-ID: <1377689291-2412-5-git-send-email-ordex@autistici.org>
References: <1377689291-2412-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:54839 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908Ab3H1Lc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 07:32:28 -0400
In-Reply-To: <1377689291-2412-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Whenever the GW client mode is deselected, a DEL event has
to be sent in order to tell userspace that the current
gateway has been lost. Send the uevent on state change only
if a gateway was currently selected.

Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/gateway_client.c | 27 +++++++++++++++++++++++++++
 net/batman-adv/gateway_client.h |  1 +
 net/batman-adv/sysfs.c          |  4 ++++
 3 files changed, 32 insertions(+)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 7614af3..1ce4b87 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -190,6 +190,33 @@ next:
 	return curr_gw;
 }
 
+/**
+ * batadv_gw_check_client_stop - check if client mode has been switched off
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * This function assumes the caller has checked that the gw state *is actually
+ * changing*. This function is not supposed to be called when there is no state
+ * change.
+ */
+void batadv_gw_check_client_stop(struct batadv_priv *bat_priv)
+{
+	struct batadv_gw_node *curr_gw;
+
+	if (atomic_read(&bat_priv->gw_mode) != BATADV_GW_MODE_CLIENT)
+		return;
+
+	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
+	if (!curr_gw)
+		return;
+
+	/* if batman-adv is switching the gw client mode off and a gateway was
+	 * already selected, send a DEL uevent
+	 */
+	batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_DEL, NULL);
+
+	batadv_gw_node_free_ref(curr_gw);
+}
+
 void batadv_gw_election(struct batadv_priv *bat_priv)
 {
 	struct batadv_gw_node *curr_gw = NULL, *next_gw = NULL;
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 1037d75..ceef4eb 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -20,6 +20,7 @@
 #ifndef _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
 #define _NET_BATMAN_ADV_GATEWAY_CLIENT_H_
 
+void batadv_gw_check_client_stop(struct batadv_priv *bat_priv);
 void batadv_gw_deselect(struct batadv_priv *bat_priv);
 void batadv_gw_election(struct batadv_priv *bat_priv);
 struct batadv_orig_node *
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 929e304..4114b96 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -385,6 +385,10 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 		    curr_gw_mode_str, buff);
 
 	batadv_gw_deselect(bat_priv);
+	/* always call batadv_gw_check_client_stop() before changing the gateway
+	 * state
+	 */
+	batadv_gw_check_client_stop(bat_priv);
 	atomic_set(&bat_priv->gw_mode, (unsigned int)gw_mode_tmp);
 	return count;
 }
-- 
1.8.1.5
