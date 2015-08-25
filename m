From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/15] batman-adv: Annotate deleting functions with external lock via lockdep
Date: Tue, 25 Aug 2015 13:02:36 +0200
Message-ID: <1440500559-28368-13-git-send-email-antonio__1274.03072915531$1440501806$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:37383 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbbHYLXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:23:12 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Functions which use (h)list_del* are requiring correct locking when they
operate on global lists. Most of the time the search in the list and the
delete are done in the same function. All other cases should have it
visible that they require a special lock to avoid race conditions.

Lockdep asserts can be used to check these problem during runtime when the
lockdep functionality is enabled.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c              | 11 ++++++++---
 net/batman-adv/multicast.c         | 13 +++++++++++--
 net/batman-adv/network-coding.c    |  4 ++++
 net/batman-adv/translation-table.c |  2 ++
 4 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d277ba7..50fc07b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -30,6 +30,7 @@
 #include <linux/ipv6.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
+#include <linux/lockdep.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
@@ -737,13 +738,17 @@ static u16 batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
 /**
  * batadv_tvlv_container_remove - remove tvlv container from the tvlv container
  *  list
+ * @bat_priv: the bat priv with all the soft interface information
  * @tvlv: the to be removed tvlv container
  *
  * Has to be called with the appropriate locks being acquired
  * (tvlv.container_list_lock).
  */
-static void batadv_tvlv_container_remove(struct batadv_tvlv_container *tvlv)
+static void batadv_tvlv_container_remove(struct batadv_priv *bat_priv,
+					 struct batadv_tvlv_container *tvlv)
 {
+	lockdep_assert_held(&bat_priv->tvlv.handler_list_lock);
+
 	if (!tvlv)
 		return;
 
@@ -768,7 +773,7 @@ void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
 	tvlv = batadv_tvlv_container_get(bat_priv, type, version);
-	batadv_tvlv_container_remove(tvlv);
+	batadv_tvlv_container_remove(bat_priv, tvlv);
 	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
 }
 
@@ -807,7 +812,7 @@ void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
 
 	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
 	tvlv_old = batadv_tvlv_container_get(bat_priv, type, version);
-	batadv_tvlv_container_remove(tvlv_old);
+	batadv_tvlv_container_remove(bat_priv, tvlv_old);
 	hlist_add_head(&tvlv_new->list, &bat_priv->tvlv.container_list);
 	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
 }
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 2593f0f..410f34c 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -31,6 +31,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/list.h>
+#include <linux/lockdep.h>
 #include <linux/netdevice.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
@@ -103,15 +104,19 @@ static bool batadv_mcast_mla_is_duplicate(u8 *mcast_addr,
 
 /**
  * batadv_mcast_mla_list_free - free a list of multicast addresses
+ * @bat_priv: the bat priv with all the soft interface information
  * @mcast_list: the list to free
  *
  * Removes and frees all items in the given mcast_list.
  */
-static void batadv_mcast_mla_list_free(struct hlist_head *mcast_list)
+static void batadv_mcast_mla_list_free(struct batadv_priv *bat_priv,
+				       struct hlist_head *mcast_list)
 {
 	struct batadv_hw_addr *mcast_entry;
 	struct hlist_node *tmp;
 
+	lockdep_assert_held(&bat_priv->tt.commit_lock);
+
 	hlist_for_each_entry_safe(mcast_entry, tmp, mcast_list, list) {
 		hlist_del(&mcast_entry->list);
 		kfree(mcast_entry);
@@ -134,6 +139,8 @@ static void batadv_mcast_mla_tt_retract(struct batadv_priv *bat_priv,
 	struct batadv_hw_addr *mcast_entry;
 	struct hlist_node *tmp;
 
+	lockdep_assert_held(&bat_priv->tt.commit_lock);
+
 	hlist_for_each_entry_safe(mcast_entry, tmp, &bat_priv->mcast.mla_list,
 				  list) {
 		if (mcast_list &&
@@ -164,6 +171,8 @@ static void batadv_mcast_mla_tt_add(struct batadv_priv *bat_priv,
 	struct batadv_hw_addr *mcast_entry;
 	struct hlist_node *tmp;
 
+	lockdep_assert_held(&bat_priv->tt.commit_lock);
+
 	if (!mcast_list)
 		return;
 
@@ -268,7 +277,7 @@ update:
 	batadv_mcast_mla_tt_add(bat_priv, &mcast_list);
 
 out:
-	batadv_mcast_mla_list_free(&mcast_list);
+	batadv_mcast_mla_list_free(bat_priv, &mcast_list);
 }
 
 /**
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index ccfe5d8..f5276be 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -586,6 +586,8 @@ static bool batadv_nc_sniffed_purge(struct batadv_priv *bat_priv,
 	unsigned long timeout = bat_priv->nc.max_buffer_time;
 	bool res = false;
 
+	lockdep_assert_held(&nc_path->packet_list_lock);
+
 	/* Packets are added to tail, so the remaining packets did not time
 	 * out and we can stop processing the current queue
 	 */
@@ -622,6 +624,8 @@ static bool batadv_nc_fwd_flush(struct batadv_priv *bat_priv,
 {
 	unsigned long timeout = bat_priv->nc.max_fwd_delay;
 
+	lockdep_assert_held(&nc_path->packet_list_lock);
+
 	/* Packets are added to tail, so the remaining packets did not time
 	 * out and we can stop processing the current queue
 	 */
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 734b456..79cee7b 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1672,6 +1672,8 @@ static void
 _batadv_tt_global_del_orig_entry(struct batadv_tt_global_entry *tt_global_entry,
 				 struct batadv_tt_orig_list_entry *orig_entry)
 {
+	lockdep_assert_held(&tt_global_entry->list_lock);
+
 	batadv_tt_global_size_dec(orig_entry->orig_node,
 				  tt_global_entry->common.vid);
 	atomic_dec(&tt_global_entry->orig_list_count);
-- 
2.5.0
