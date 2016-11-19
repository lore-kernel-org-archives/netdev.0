From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 3/8] batman-adv: Cache the type of wifi device for each hardif
Date: Sat, 19 Nov 2016 14:35:23 +0100
Message-ID: <20161119133528.1379-4-sw@simonwunderlich.de>
References: <20161119133528.1379-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven.eckelmann@open-mesh.com>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49960 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752752AbcKSNfd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:35:33 -0500
In-Reply-To: <20161119133528.1379-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@open-mesh.com>

batman-adv is requiring the type of wifi device in different contexts. Some
of them can take the rtnl semaphore and some of them already have the
semaphore taken. But even others don't allow that the semaphore will be
taken.

The data has to be retrieved when the hardif is added to batman-adv because
some of the wifi information for an hardif will only be available with rtnl
lock. It can then be cached in the batadv_hard_iface and the functions
is_wifi_netdev and is_cfg80211_netdev can just compare the correct bits
without imposing extra locking requirements.

Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c        |  2 +-
 net/batman-adv/bat_v_elp.c         |  8 ++--
 net/batman-adv/hard-interface.c    | 82 +++++++++++++++++++++++++++++++-------
 net/batman-adv/hard-interface.h    |  5 +--
 net/batman-adv/translation-table.c | 10 ++++-
 net/batman-adv/types.h             | 13 ++++++
 6 files changed, 95 insertions(+), 25 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index bd39247..36d8818 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1272,7 +1272,7 @@ static bool batadv_iv_ogm_calc_tq(struct batadv_orig_node *orig_node,
 	 */
 	tq_iface_penalty = BATADV_TQ_MAX_VALUE;
 	if (if_outgoing && (if_incoming == if_outgoing) &&
-	    batadv_is_wifi_netdev(if_outgoing->net_dev))
+	    batadv_is_wifi_hardif(if_outgoing))
 		tq_iface_penalty = batadv_hop_penalty(BATADV_TQ_MAX_VALUE,
 						      bat_priv);
 
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index e601def..0d78689 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -89,8 +89,8 @@ static u32 batadv_v_elp_get_throughput(struct batadv_hardif_neigh_node *neigh)
 	/* if this is a wireless device, then ask its throughput through
 	 * cfg80211 API
 	 */
-	if (batadv_is_wifi_netdev(hard_iface->net_dev)) {
-		if (!batadv_is_cfg80211_netdev(hard_iface->net_dev))
+	if (batadv_is_wifi_hardif(hard_iface)) {
+		if (!batadv_is_cfg80211_hardif(hard_iface))
 			/* unsupported WiFi driver version */
 			goto default_throughput;
 
@@ -186,7 +186,7 @@ batadv_v_elp_wifi_neigh_probe(struct batadv_hardif_neigh_node *neigh)
 	int elp_skb_len;
 
 	/* this probing routine is for Wifi neighbours only */
-	if (!batadv_is_wifi_netdev(hard_iface->net_dev))
+	if (!batadv_is_wifi_hardif(hard_iface))
 		return true;
 
 	/* probe the neighbor only if no unicast packets have been sent
@@ -351,7 +351,7 @@ int batadv_v_elp_iface_enable(struct batadv_hard_iface *hard_iface)
 	/* warn the user (again) if there is no throughput data is available */
 	hard_iface->bat_v.flags &= ~BATADV_WARNING_DEFAULT;
 
-	if (batadv_is_wifi_netdev(hard_iface->net_dev))
+	if (batadv_is_wifi_hardif(hard_iface))
 		hard_iface->bat_v.flags &= ~BATADV_FULL_DUPLEX;
 
 	INIT_DELAYED_WORK(&hard_iface->bat_v.elp_wq,
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index c3fbc1b..57e8912 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -202,6 +202,30 @@ static bool batadv_is_valid_iface(const struct net_device *net_dev)
 }
 
 /**
+ * batadv_is_wext_netdev - check if the given net_device struct is a
+ *  wext wifi interface
+ * @net_device: the device to check
+ *
+ * Return: true if the net device is a wext wireless device, false
+ *  otherwise.
+ */
+static bool batadv_is_wext_netdev(struct net_device *net_device)
+{
+	if (!net_device)
+		return false;
+
+#ifdef CONFIG_WIRELESS_EXT
+	/* pre-cfg80211 drivers have to implement WEXT, so it is possible to
+	 * check for wireless_handlers != NULL
+	 */
+	if (net_device->wireless_handlers)
+		return true;
+#endif
+
+	return false;
+}
+
+/**
  * batadv_is_cfg80211_netdev - check if the given net_device struct is a
  *  cfg80211 wifi interface
  * @net_device: the device to check
@@ -209,7 +233,7 @@ static bool batadv_is_valid_iface(const struct net_device *net_dev)
  * Return: true if the net device is a cfg80211 wireless device, false
  *  otherwise.
  */
-bool batadv_is_cfg80211_netdev(struct net_device *net_device)
+static bool batadv_is_cfg80211_netdev(struct net_device *net_device)
 {
 	if (!net_device)
 		return false;
@@ -222,26 +246,53 @@ bool batadv_is_cfg80211_netdev(struct net_device *net_device)
 }
 
 /**
- * batadv_is_wifi_netdev - check if the given net_device struct is a wifi
- *  interface
+ * batadv_wifi_flags_evaluate - calculate wifi flags for net_device
  * @net_device: the device to check
  *
+ * Return: batadv_hard_iface_wifi_flags flags of the device
+ */
+static u32 batadv_wifi_flags_evaluate(struct net_device *net_device)
+{
+	u32 wifi_flags = 0;
+
+	if (batadv_is_wext_netdev(net_device))
+		wifi_flags |= BATADV_HARDIF_WIFI_WEXT_DIRECT;
+
+	if (batadv_is_cfg80211_netdev(net_device))
+		wifi_flags |= BATADV_HARDIF_WIFI_CFG80211_DIRECT;
+
+	return wifi_flags;
+}
+
+/**
+ * batadv_is_cfg80211_hardif - check if the given hardif is a cfg80211 wifi
+ *  interface
+ * @hard_iface: the device to check
+ *
+ * Return: true if the net device is a cfg80211 wireless device, false
+ *  otherwise.
+ */
+bool batadv_is_cfg80211_hardif(struct batadv_hard_iface *hard_iface)
+{
+	u32 allowed_flags = 0;
+
+	allowed_flags |= BATADV_HARDIF_WIFI_CFG80211_DIRECT;
+
+	return !!(hard_iface->wifi_flags & allowed_flags);
+}
+
+/**
+ * batadv_is_wifi_hardif - check if the given hardif is a wifi interface
+ * @hard_iface: the device to check
+ *
  * Return: true if the net device is a 802.11 wireless device, false otherwise.
  */
-bool batadv_is_wifi_netdev(struct net_device *net_device)
+bool batadv_is_wifi_hardif(struct batadv_hard_iface *hard_iface)
 {
-	if (!net_device)
+	if (!hard_iface)
 		return false;
 
-#ifdef CONFIG_WIRELESS_EXT
-	/* pre-cfg80211 drivers have to implement WEXT, so it is possible to
-	 * check for wireless_handlers != NULL
-	 */
-	if (net_device->wireless_handlers)
-		return true;
-#endif
-
-	return batadv_is_cfg80211_netdev(net_device);
+	return hard_iface->wifi_flags != 0;
 }
 
 /**
@@ -765,7 +816,8 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 	kref_init(&hard_iface->refcount);
 
 	hard_iface->num_bcasts = BATADV_NUM_BCASTS_DEFAULT;
-	if (batadv_is_wifi_netdev(net_dev))
+	hard_iface->wifi_flags = batadv_wifi_flags_evaluate(net_dev);
+	if (batadv_is_wifi_hardif(hard_iface))
 		hard_iface->num_bcasts = BATADV_NUM_BCASTS_WIRELESS;
 
 	batadv_v_hardif_init(hard_iface);
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 7f9acab..7281dd2 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -65,9 +65,8 @@ enum batadv_hard_if_cleanup {
 
 extern struct notifier_block batadv_hard_if_notifier;
 
-bool batadv_is_cfg80211_netdev(struct net_device *net_device);
-bool batadv_is_wifi_netdev(struct net_device *net_device);
-bool batadv_is_wifi_iface(int ifindex);
+bool batadv_is_cfg80211_hardif(struct batadv_hard_iface *hard_iface);
+bool batadv_is_wifi_hardif(struct batadv_hard_iface *hard_iface);
 struct batadv_hard_iface*
 batadv_hardif_get_by_netdev(const struct net_device *net_dev);
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 3cae8f4f..447f949 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -646,6 +646,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	struct net *net = dev_net(soft_iface);
 	struct batadv_softif_vlan *vlan;
 	struct net_device *in_dev = NULL;
+	struct batadv_hard_iface *in_hardif = NULL;
 	struct hlist_head *head;
 	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added, table_size, packet_size_max;
@@ -657,6 +658,9 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	if (ifindex != BATADV_NULL_IFINDEX)
 		in_dev = dev_get_by_index(net, ifindex);
 
+	if (in_dev)
+		in_hardif = batadv_hardif_get_by_netdev(in_dev);
+
 	tt_local = batadv_tt_local_hash_find(bat_priv, addr, vid);
 
 	if (!is_multicast_ether_addr(addr))
@@ -730,7 +734,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	 */
 	tt_local->common.flags = BATADV_TT_CLIENT_NEW;
 	tt_local->common.vid = vid;
-	if (batadv_is_wifi_netdev(in_dev))
+	if (batadv_is_wifi_hardif(in_hardif))
 		tt_local->common.flags |= BATADV_TT_CLIENT_WIFI;
 	kref_init(&tt_local->common.refcount);
 	tt_local->last_seen = jiffies;
@@ -790,7 +794,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 	 */
 	remote_flags = tt_local->common.flags & BATADV_TT_REMOTE_MASK;
 
-	if (batadv_is_wifi_netdev(in_dev))
+	if (batadv_is_wifi_hardif(in_hardif))
 		tt_local->common.flags |= BATADV_TT_CLIENT_WIFI;
 	else
 		tt_local->common.flags &= ~BATADV_TT_CLIENT_WIFI;
@@ -814,6 +818,8 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const u8 *addr,
 
 	ret = true;
 out:
+	if (in_hardif)
+		batadv_hardif_put(in_hardif);
 	if (in_dev)
 		dev_put(in_dev);
 	if (tt_local)
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 98ebac0..1bcce32 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -119,11 +119,23 @@ struct batadv_hard_iface_bat_v {
 };
 
 /**
+ * enum batadv_hard_iface_wifi_flags - Flags describing the wifi configuration
+ *  of a batadv_hard_iface
+ * @BATADV_HARDIF_WIFI_WEXT_DIRECT: it is a wext wifi device
+ * @BATADV_HARDIF_WIFI_CFG80211_DIRECT: it is a cfg80211 wifi device
+ */
+enum batadv_hard_iface_wifi_flags {
+	BATADV_HARDIF_WIFI_WEXT_DIRECT = BIT(0),
+	BATADV_HARDIF_WIFI_CFG80211_DIRECT = BIT(1),
+};
+
+/**
  * struct batadv_hard_iface - network device known to batman-adv
  * @list: list node for batadv_hardif_list
  * @if_num: identificator of the interface
  * @if_status: status of the interface for batman-adv
  * @num_bcasts: number of payload re-broadcasts on this interface (ARQ)
+ * @wifi_flags: flags whether this is (directly or indirectly) a wifi interface
  * @net_dev: pointer to the net_device
  * @hardif_obj: kobject of the per interface sysfs "mesh" directory
  * @refcount: number of contexts the object is used
@@ -142,6 +154,7 @@ struct batadv_hard_iface {
 	s16 if_num;
 	char if_status;
 	u8 num_bcasts;
+	u32 wifi_flags;
 	struct net_device *net_dev;
 	struct kobject *hardif_obj;
 	struct kref refcount;
-- 
2.10.2
