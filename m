From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/13] batman-adv: a delayed_work has to be initialised once
Date: Sat, 19 Jan 2013 21:27:47 +0800
Message-ID: <1358602079-24024-2-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:57501 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab3ASN3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:29:31 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A delayed_work struct does not need to be initialized each
every time before being enqueued. Therefore the
INIT_DELAYED_WORK() macro should be used during the
initialization process only.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 18 ++++++------------
 net/batman-adv/main.h                  |  2 ++
 net/batman-adv/originator.c            | 17 ++++++++---------
 net/batman-adv/send.c                  |  5 +++--
 net/batman-adv/translation-table.c     | 14 +++++---------
 net/batman-adv/vis.c                   | 20 ++++++++------------
 6 files changed, 32 insertions(+), 44 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 5e834c1..bb5fbd6 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1100,16 +1100,6 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 	}
 }
 
-
-
-/* (re)start the timer */
-static void batadv_bla_start_timer(struct batadv_priv *bat_priv)
-{
-	INIT_DELAYED_WORK(&bat_priv->bla.work, batadv_bla_periodic_work);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla.work,
-			   msecs_to_jiffies(BATADV_BLA_PERIOD_LENGTH));
-}
-
 /* periodic work to do:
  *  * purge structures when they are too old
  *  * send announcements
@@ -1180,7 +1170,8 @@ out:
 	if (primary_if)
 		batadv_hardif_free_ref(primary_if);
 
-	batadv_bla_start_timer(bat_priv);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla.work,
+			   msecs_to_jiffies(BATADV_BLA_PERIOD_LENGTH));
 }
 
 /* The hash for claim and backbone hash receive the same key because they
@@ -1238,7 +1229,10 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 
 	batadv_dbg(BATADV_DBG_BLA, bat_priv, "bla hashes initialized\n");
 
-	batadv_bla_start_timer(bat_priv);
+	INIT_DELAYED_WORK(&bat_priv->bla.work, batadv_bla_periodic_work);
+
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->bla.work,
+			   msecs_to_jiffies(BATADV_BLA_PERIOD_LENGTH));
 	return 0;
 }
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index d04b209..af73d60 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -44,6 +44,8 @@
 #define BATADV_TT_LOCAL_TIMEOUT 600000 /* in milliseconds */
 #define BATADV_TT_CLIENT_ROAM_TIMEOUT 600000 /* in milliseconds */
 #define BATADV_TT_CLIENT_TEMP_TIMEOUT 600000 /* in milliseconds */
+#define BATADV_TT_WORK_PERIOD 5000 /* 5 seconds */
+#define BATADV_ORIG_WORK_PERIOD 1000 /* 1 second */
 #define BATADV_DAT_ENTRY_TIMEOUT (5*60000) /* 5 mins in milliseconds */
 /* sliding packet range of received originator messages in sequence numbers
  * (should be a multiple of our word size)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index fa88b2b..92a55fd 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -34,13 +34,6 @@ static struct lock_class_key batadv_orig_hash_lock_class_key;
 
 static void batadv_purge_orig(struct work_struct *work);
 
-static void batadv_start_purge_timer(struct batadv_priv *bat_priv)
-{
-	INIT_DELAYED_WORK(&bat_priv->orig_work, batadv_purge_orig);
-	queue_delayed_work(batadv_event_workqueue,
-			   &bat_priv->orig_work, msecs_to_jiffies(1000));
-}
-
 /* returns 1 if they are the same originator */
 static int batadv_compare_orig(const struct hlist_node *node, const void *data2)
 {
@@ -63,7 +56,11 @@ int batadv_originator_init(struct batadv_priv *bat_priv)
 	batadv_hash_set_lock_class(bat_priv->orig_hash,
 				   &batadv_orig_hash_lock_class_key);
 
-	batadv_start_purge_timer(bat_priv);
+	INIT_DELAYED_WORK(&bat_priv->orig_work, batadv_purge_orig);
+	queue_delayed_work(batadv_event_workqueue,
+			   &bat_priv->orig_work,
+			   msecs_to_jiffies(BATADV_ORIG_WORK_PERIOD));
+
 	return 0;
 
 err:
@@ -396,7 +393,9 @@ static void batadv_purge_orig(struct work_struct *work)
 	delayed_work = container_of(work, struct delayed_work, work);
 	bat_priv = container_of(delayed_work, struct batadv_priv, orig_work);
 	_batadv_purge_orig(bat_priv);
-	batadv_start_purge_timer(bat_priv);
+	queue_delayed_work(batadv_event_workqueue,
+			   &bat_priv->orig_work,
+			   msecs_to_jiffies(BATADV_ORIG_WORK_PERIOD));
 }
 
 void batadv_purge_orig_ref(struct batadv_priv *bat_priv)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 89810ce..0b6f65b 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -155,8 +155,6 @@ _batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
 
 	/* start timer for this packet */
-	INIT_DELAYED_WORK(&forw_packet->delayed_work,
-			  batadv_send_outstanding_bcast_packet);
 	queue_delayed_work(batadv_event_workqueue, &forw_packet->delayed_work,
 			   send_time);
 }
@@ -210,6 +208,9 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	/* how often did we send the bcast packet ? */
 	forw_packet->num_packets = 0;
 
+	INIT_DELAYED_WORK(&forw_packet->delayed_work,
+			  batadv_send_outstanding_bcast_packet);
+
 	_batadv_add_bcast_packet_to_list(bat_priv, forw_packet, delay);
 	return NETDEV_TX_OK;
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d4b27b6..877acd1 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -52,13 +52,6 @@ static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
 	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
 }
 
-static void batadv_tt_start_timer(struct batadv_priv *bat_priv)
-{
-	INIT_DELAYED_WORK(&bat_priv->tt.work, batadv_tt_purge);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
-			   msecs_to_jiffies(5000));
-}
-
 static struct batadv_tt_common_entry *
 batadv_tt_hash_find(struct batadv_hashtable *hash, const void *data)
 {
@@ -2136,7 +2129,9 @@ int batadv_tt_init(struct batadv_priv *bat_priv)
 	if (ret < 0)
 		return ret;
 
-	batadv_tt_start_timer(bat_priv);
+	INIT_DELAYED_WORK(&bat_priv->tt.work, batadv_tt_purge);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
+			   msecs_to_jiffies(BATADV_TT_WORK_PERIOD));
 
 	return 1;
 }
@@ -2286,7 +2281,8 @@ static void batadv_tt_purge(struct work_struct *work)
 	batadv_tt_req_purge(bat_priv);
 	batadv_tt_roam_purge(bat_priv);
 
-	batadv_tt_start_timer(bat_priv);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->tt.work,
+			   msecs_to_jiffies(BATADV_TT_WORK_PERIOD));
 }
 
 void batadv_tt_free(struct batadv_priv *bat_priv)
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 60eb9b7..51e2bf0 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -31,8 +31,6 @@
 /* hash class keys */
 static struct lock_class_key batadv_vis_hash_lock_class_key;
 
-static void batadv_start_vis_timer(struct batadv_priv *bat_priv);
-
 /* free the info */
 static void batadv_free_info(struct kref *ref)
 {
@@ -830,7 +828,9 @@ static void batadv_send_vis_packets(struct work_struct *work)
 		kref_put(&info->refcount, batadv_free_info);
 	}
 	spin_unlock_bh(&bat_priv->vis.hash_lock);
-	batadv_start_vis_timer(bat_priv);
+
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis.work,
+			   msecs_to_jiffies(BATADV_VIS_INTERVAL));
 }
 
 /* init the vis server. this may only be called when if_list is already
@@ -900,7 +900,11 @@ int batadv_vis_init(struct batadv_priv *bat_priv)
 	}
 
 	spin_unlock_bh(&bat_priv->vis.hash_lock);
-	batadv_start_vis_timer(bat_priv);
+
+	INIT_DELAYED_WORK(&bat_priv->vis.work, batadv_send_vis_packets);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis.work,
+			   msecs_to_jiffies(BATADV_VIS_INTERVAL));
+
 	return 0;
 
 free_info:
@@ -937,11 +941,3 @@ void batadv_vis_quit(struct batadv_priv *bat_priv)
 	bat_priv->vis.my_info = NULL;
 	spin_unlock_bh(&bat_priv->vis.hash_lock);
 }
-
-/* schedule packets for (re)transmission */
-static void batadv_start_vis_timer(struct batadv_priv *bat_priv)
-{
-	INIT_DELAYED_WORK(&bat_priv->vis.work, batadv_send_vis_packets);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis.work,
-			   msecs_to_jiffies(BATADV_VIS_INTERVAL));
-}
-- 
1.8.0.2
