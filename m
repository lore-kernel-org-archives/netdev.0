From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/16] batman-adv: invoke dev_get_by_index() outside of is_wifi_iface()
Date: Wed, 23 Oct 2013 18:04:59 +0200
Message-ID: <1382544303-2694-13-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:23881 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab3JWQL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:11:56 -0400
In-Reply-To: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Upcoming changes need to perform other checks on the
incoming net_device struct.

To avoid performing dev_get_by_index() for each and every
check, it is better to move it outside of is_wifi_iface()
and search the netdev object once only.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/hard-interface.c    | 33 ++++-----------------------------
 net/batman-adv/hard-interface.h    |  2 +-
 net/batman-adv/translation-table.c |  8 +++++++-
 3 files changed, 12 insertions(+), 31 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 1ba8a55..57c2a19 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -125,8 +125,11 @@ static int batadv_is_valid_iface(const struct net_device *net_dev)
  *
  * Returns true if the net device is a 802.11 wireless device, false otherwise.
  */
-static bool batadv_is_wifi_netdev(struct net_device *net_device)
+bool batadv_is_wifi_netdev(struct net_device *net_device)
 {
+	if (!net_device)
+		return false;
+
 #ifdef CONFIG_WIRELESS_EXT
 	/* pre-cfg80211 drivers have to implement WEXT, so it is possible to
 	 * check for wireless_handlers != NULL
@@ -142,34 +145,6 @@ static bool batadv_is_wifi_netdev(struct net_device *net_device)
 	return false;
 }
 
-/**
- * batadv_is_wifi_iface - check if the given interface represented by ifindex
- *  is a wifi interface
- * @ifindex: interface index to check
- *
- * Returns true if the interface represented by ifindex is a 802.11 wireless
- * device, false otherwise.
- */
-bool batadv_is_wifi_iface(int ifindex)
-{
-	struct net_device *net_device = NULL;
-	bool ret = false;
-
-	if (ifindex == BATADV_NULL_IFINDEX)
-		goto out;
-
-	net_device = dev_get_by_index(&init_net, ifindex);
-	if (!net_device)
-		goto out;
-
-	ret = batadv_is_wifi_netdev(net_device);
-
-out:
-	if (net_device)
-		dev_put(net_device);
-	return ret;
-}
-
 static struct batadv_hard_iface *
 batadv_hardif_get_active(const struct net_device *soft_iface)
 {
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 4989288..df4c8bd 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -41,6 +41,7 @@ enum batadv_hard_if_cleanup {
 
 extern struct notifier_block batadv_hard_if_notifier;
 
+bool batadv_is_wifi_netdev(struct net_device *net_device);
 struct batadv_hard_iface*
 batadv_hardif_get_by_netdev(const struct net_device *net_dev);
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
@@ -51,7 +52,6 @@ void batadv_hardif_remove_interfaces(void);
 int batadv_hardif_min_mtu(struct net_device *soft_iface);
 void batadv_update_min_mtu(struct net_device *soft_iface);
 void batadv_hardif_free_rcu(struct rcu_head *rcu);
-bool batadv_is_wifi_iface(int ifindex);
 
 static inline void
 batadv_hardif_free_ref(struct batadv_hard_iface *hard_iface)
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a3c965d..b0fe177 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -477,11 +477,15 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	struct batadv_tt_local_entry *tt_local;
 	struct batadv_tt_global_entry *tt_global;
+	struct net_device *in_dev = NULL;
 	struct hlist_head *head;
 	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added, table_size, packet_size_max;
 	bool ret = false, roamed_back = false;
 
+	if (ifindex != BATADV_NULL_IFINDEX)
+		in_dev = dev_get_by_index(&init_net, ifindex);
+
 	tt_local = batadv_tt_local_hash_find(bat_priv, addr, vid);
 	tt_global = batadv_tt_global_hash_find(bat_priv, addr, vid);
 
@@ -542,7 +546,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	 */
 	tt_local->common.flags = BATADV_TT_CLIENT_NEW;
 	tt_local->common.vid = vid;
-	if (batadv_is_wifi_iface(ifindex))
+	if (batadv_is_wifi_netdev(in_dev))
 		tt_local->common.flags |= BATADV_TT_CLIENT_WIFI;
 	atomic_set(&tt_local->common.refcount, 2);
 	tt_local->last_seen = jiffies;
@@ -595,6 +599,8 @@ check_roaming:
 	ret = true;
 
 out:
+	if (in_dev)
+		dev_put(in_dev);
 	if (tt_local)
 		batadv_tt_local_entry_free_ref(tt_local);
 	if (tt_global)
-- 
1.8.4
