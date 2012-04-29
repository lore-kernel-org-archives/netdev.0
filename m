From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/15] batman-adv: replace HZ calculations with jiffies_to_msecs()
Date: Sun, 29 Apr 2012 10:57:46 +0200
Message-ID: <1335689867-8017-15-git-send-email-ordex@autistici.org>
References: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58143 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781Ab2D2I5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 04:57:00 -0400
In-Reply-To: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_debugfs.c |    4 ++--
 net/batman-adv/originator.c  |   15 ++++++++++-----
 net/batman-adv/send.c        |    2 +-
 3 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 916380c..3b588f8 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -83,8 +83,8 @@ int debug_log(struct bat_priv *bat_priv, const char *fmt, ...)
 
 	va_start(args, fmt);
 	vscnprintf(tmp_log_buf, sizeof(tmp_log_buf), fmt, args);
-	fdebug_log(bat_priv->debug_log, "[%10lu] %s",
-		   (jiffies / HZ), tmp_log_buf);
+	fdebug_log(bat_priv->debug_log, "[%10u] %s",
+		   jiffies_to_msecs(jiffies), tmp_log_buf);
 	va_end(args);
 
 	return 0;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 936b2e6..a64536c 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -36,7 +36,8 @@ static void purge_orig(struct work_struct *work);
 static void start_purge_timer(struct bat_priv *bat_priv)
 {
 	INIT_DELAYED_WORK(&bat_priv->orig_work, purge_orig);
-	queue_delayed_work(bat_event_workqueue, &bat_priv->orig_work, 1 * HZ);
+	queue_delayed_work(bat_event_workqueue,
+			   &bat_priv->orig_work, msecs_to_jiffies(1000));
 }
 
 /* returns 1 if they are the same originator */
@@ -276,6 +277,7 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 	struct hlist_node *node, *node_tmp;
 	struct neigh_node *neigh_node;
 	bool neigh_purged = false;
+	unsigned long last_seen;
 
 	*best_neigh_node = NULL;
 
@@ -290,6 +292,8 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 		    (neigh_node->if_incoming->if_status == IF_NOT_IN_USE) ||
 		    (neigh_node->if_incoming->if_status == IF_TO_BE_REMOVED)) {
 
+			last_seen = neigh_node->last_seen;
+
 			if ((neigh_node->if_incoming->if_status ==
 								IF_INACTIVE) ||
 			    (neigh_node->if_incoming->if_status ==
@@ -302,9 +306,9 @@ static bool purge_orig_neighbors(struct bat_priv *bat_priv,
 					neigh_node->if_incoming->net_dev->name);
 			else
 				bat_dbg(DBG_BATMAN, bat_priv,
-					"neighbor timeout: originator %pM, neighbor: %pM, last_seen: %lu\n",
+					"neighbor timeout: originator %pM, neighbor: %pM, last_seen: %u\n",
 					orig_node->orig, neigh_node->addr,
-					(neigh_node->last_seen / HZ));
+					jiffies_to_msecs(last_seen));
 
 			neigh_purged = true;
 
@@ -329,8 +333,9 @@ static bool purge_orig_node(struct bat_priv *bat_priv,
 
 	if (has_timed_out(orig_node->last_seen, 2 * PURGE_TIMEOUT)) {
 		bat_dbg(DBG_BATMAN, bat_priv,
-			"Originator timeout: originator %pM, last_seen %lu\n",
-			orig_node->orig, (orig_node->last_seen / HZ));
+			"Originator timeout: originator %pM, last_seen %u\n",
+			orig_node->orig,
+			jiffies_to_msecs(orig_node->last_seen));
 		return true;
 	} else {
 		if (purge_orig_neighbors(bat_priv, orig_node,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 91eaa45..20f6e89 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -296,7 +296,7 @@ static void send_outstanding_bcast_packet(struct work_struct *work)
 	/* if we still have some more bcasts to send */
 	if (forw_packet->num_packets < 3) {
 		_add_bcast_packet_to_list(bat_priv, forw_packet,
-					  ((5 * HZ) / 1000));
+					  msecs_to_jiffies(5));
 		return;
 	}
 
-- 
1.7.9.4
