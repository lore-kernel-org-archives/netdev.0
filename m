From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 1/2] batman-adv: Add missing hardif_free_ref in forw_packet_free
Date: Sun, 15 May 2011 00:16:33 +0200
Message-ID: <1305411394-28807-2-git-send-email-sven@narfation.org>
References: <1305411394-28807-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45200 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755132Ab1ENWQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 18:16:48 -0400
In-Reply-To: <1305411394-28807-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add_bcast_packet_to_list increases the refcount for if_incoming but the
reference count is never decreased. The reference count must be
increased for all kinds of forwarded packets which have the primary
interface stored and forw_packet_free must decrease them. Also
purge_outstanding_packets has to invoke forw_packet_free when a work
item was really cancelled.

This regression was introduced in
32ae9b221e788413ce68feaae2ca39e406211a0a.

Reported-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/aggregation.c |   14 +++++++++++---
 net/batman-adv/send.c        |   17 +++++++++++++++--
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index 9b94590..a8c3203 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -23,6 +23,7 @@
 #include "aggregation.h"
 #include "send.h"
 #include "routing.h"
+#include "hard-interface.h"
 
 /* calculate the size of the tt information for a given packet */
 static int tt_len(struct batman_packet *batman_packet)
@@ -105,12 +106,15 @@ static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
 	struct forw_packet *forw_packet_aggr;
 	unsigned char *skb_buff;
 
+	if (!atomic_inc_not_zero(&if_incoming->refcount))
+		return;
+
 	/* own packet should always be scheduled */
 	if (!own_packet) {
 		if (!atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
 			bat_dbg(DBG_BATMAN, bat_priv,
 				"batman packet queue full\n");
-			return;
+			goto out;
 		}
 	}
 
@@ -118,7 +122,7 @@ static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
 	if (!forw_packet_aggr) {
 		if (!own_packet)
 			atomic_inc(&bat_priv->batman_queue_left);
-		return;
+		goto out;
 	}
 
 	if ((atomic_read(&bat_priv->aggregated_ogms)) &&
@@ -133,7 +137,7 @@ static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
 		if (!own_packet)
 			atomic_inc(&bat_priv->batman_queue_left);
 		kfree(forw_packet_aggr);
-		return;
+		goto out;
 	}
 	skb_reserve(forw_packet_aggr->skb, sizeof(struct ethhdr));
 
@@ -164,6 +168,10 @@ static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
 	queue_delayed_work(bat_event_workqueue,
 			   &forw_packet_aggr->delayed_work,
 			   send_time - jiffies);
+
+	return;
+out:
+	hardif_free_ref(if_incoming);
 }
 
 /* aggregate a new packet into the existing aggregation */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index f30d0c6..76daa46 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -377,6 +377,8 @@ static void forw_packet_free(struct forw_packet *forw_packet)
 {
 	if (forw_packet->skb)
 		kfree_skb(forw_packet->skb);
+	if (forw_packet->if_incoming)
+		hardif_free_ref(forw_packet->if_incoming);
 	kfree(forw_packet);
 }
 
@@ -539,6 +541,7 @@ void purge_outstanding_packets(struct bat_priv *bat_priv,
 {
 	struct forw_packet *forw_packet;
 	struct hlist_node *tmp_node, *safe_tmp_node;
+	bool pending;
 
 	if (hard_iface)
 		bat_dbg(DBG_BATMAN, bat_priv,
@@ -567,8 +570,13 @@ void purge_outstanding_packets(struct bat_priv *bat_priv,
 		 * send_outstanding_bcast_packet() will lock the list to
 		 * delete the item from the list
 		 */
-		cancel_delayed_work_sync(&forw_packet->delayed_work);
+		pending = cancel_delayed_work_sync(&forw_packet->delayed_work);
 		spin_lock_bh(&bat_priv->forw_bcast_list_lock);
+
+		if (pending) {
+			hlist_del(&forw_packet->list);
+			forw_packet_free(forw_packet);
+		}
 	}
 	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
 
@@ -591,8 +599,13 @@ void purge_outstanding_packets(struct bat_priv *bat_priv,
 		 * send_outstanding_bat_packet() will lock the list to
 		 * delete the item from the list
 		 */
-		cancel_delayed_work_sync(&forw_packet->delayed_work);
+		pending = cancel_delayed_work_sync(&forw_packet->delayed_work);
 		spin_lock_bh(&bat_priv->forw_bat_list_lock);
+
+		if (pending) {
+			hlist_del(&forw_packet->list);
+			forw_packet_free(forw_packet);
+		}
 	}
 	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 }
-- 
1.7.5.1

