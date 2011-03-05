From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 25/28] batman-adv: rename global if_list to hardif_list
Date: Sat,  5 Mar 2011 13:28:39 +0100
Message-ID: <1299328122-21468-26-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36355 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398Ab1CEMaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:21 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Batman-adv works with "hard interfaces" as well as "soft interfaces".
The new name should better make clear which kind of interfaces this
list stores.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c |   28 ++++++++++++++--------------
 net/batman-adv/main.c           |    6 +++---
 net/batman-adv/main.h           |    2 +-
 net/batman-adv/originator.c     |    2 +-
 net/batman-adv/routing.c        |    2 +-
 net/batman-adv/send.c           |    4 ++--
 6 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index de9bd36..4a2e6e3 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -31,8 +31,8 @@
 
 #include <linux/if_arp.h>
 
-/* protect update critical side of if_list - but not the content */
-static DEFINE_SPINLOCK(if_list_lock);
+/* protect update critical side of hardif_list - but not the content */
+static DEFINE_SPINLOCK(hardif_list_lock);
 
 
 static int batman_skb_recv(struct sk_buff *skb,
@@ -54,7 +54,7 @@ struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev)
 	struct batman_if *batman_if;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if (batman_if->net_dev == net_dev &&
 		    atomic_inc_not_zero(&batman_if->refcount))
 			goto out;
@@ -99,7 +99,7 @@ static struct batman_if *get_active_batman_if(struct net_device *soft_iface)
 	struct batman_if *batman_if;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if (batman_if->soft_iface != soft_iface)
 			continue;
 
@@ -179,7 +179,7 @@ static void check_known_mac_addr(struct net_device *net_dev)
 	struct batman_if *batman_if;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if ((batman_if->if_status != IF_ACTIVE) &&
 		    (batman_if->if_status != IF_TO_BE_ACTIVATED))
 			continue;
@@ -212,7 +212,7 @@ int hardif_min_mtu(struct net_device *soft_iface)
 		goto out;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if ((batman_if->if_status != IF_ACTIVE) &&
 		    (batman_if->if_status != IF_TO_BE_ACTIVATED))
 			continue;
@@ -449,9 +449,9 @@ static struct batman_if *hardif_add_interface(struct net_device *net_dev)
 
 	check_known_mac_addr(batman_if->net_dev);
 
-	spin_lock(&if_list_lock);
-	list_add_tail_rcu(&batman_if->list, &if_list);
-	spin_unlock(&if_list_lock);
+	spin_lock(&hardif_list_lock);
+	list_add_tail_rcu(&batman_if->list, &hardif_list);
+	spin_unlock(&hardif_list_lock);
 
 	return batman_if;
 
@@ -484,12 +484,12 @@ void hardif_remove_interfaces(void)
 
 	INIT_LIST_HEAD(&if_queue);
 
-	spin_lock(&if_list_lock);
-	list_for_each_entry_safe(batman_if, batman_if_tmp, &if_list, list) {
+	spin_lock(&hardif_list_lock);
+	list_for_each_entry_safe(batman_if, batman_if_tmp, &hardif_list, list) {
 		list_del_rcu(&batman_if->list);
 		list_add_tail(&batman_if->list, &if_queue);
 	}
-	spin_unlock(&if_list_lock);
+	spin_unlock(&hardif_list_lock);
 
 	rtnl_lock();
 	list_for_each_entry_safe(batman_if, batman_if_tmp, &if_queue, list) {
@@ -520,9 +520,9 @@ static int hard_if_event(struct notifier_block *this,
 		hardif_deactivate_interface(batman_if);
 		break;
 	case NETDEV_UNREGISTER:
-		spin_lock(&if_list_lock);
+		spin_lock(&hardif_list_lock);
 		list_del_rcu(&batman_if->list);
-		spin_unlock(&if_list_lock);
+		spin_unlock(&hardif_list_lock);
 
 		hardif_remove_interface(batman_if);
 		break;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 09c21f2..57aea9b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -33,7 +33,7 @@
 #include "vis.h"
 #include "hash.h"
 
-struct list_head if_list;
+struct list_head hardif_list;
 
 unsigned char broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
@@ -41,7 +41,7 @@ struct workqueue_struct *bat_event_workqueue;
 
 static int __init batman_init(void)
 {
-	INIT_LIST_HEAD(&if_list);
+	INIT_LIST_HEAD(&hardif_list);
 
 	/* the name should not be longer than 10 chars - see
 	 * http://lwn.net/Articles/23634/ */
@@ -156,7 +156,7 @@ int is_my_mac(uint8_t *addr)
 	struct batman_if *batman_if;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if (batman_if->if_status != IF_ACTIVE)
 			continue;
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 06b5b99..dc24869 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -122,7 +122,7 @@
 #define REVISION_VERSION_STR " "REVISION_VERSION
 #endif
 
-extern struct list_head if_list;
+extern struct list_head hardif_list;
 
 extern unsigned char broadcast_addr[];
 extern struct workqueue_struct *bat_event_workqueue;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index a8d0262..84ef9ae 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -602,7 +602,7 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 
 	/* renumber remaining batman interfaces _inside_ of orig_hash_lock */
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if_tmp, &if_list, list) {
+	list_for_each_entry_rcu(batman_if_tmp, &hardif_list, list) {
 		if (batman_if_tmp->if_status == IF_NOT_IN_USE)
 			continue;
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 3cfa2c7..21e93b3 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -643,7 +643,7 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		has_directlink_flag);
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if (batman_if->if_status != IF_ACTIVE)
 			continue;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index f0232ad..c4f3e49 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -204,7 +204,7 @@ static void send_packet(struct forw_packet *forw_packet)
 
 	/* broadcast on every interface */
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if (batman_if->soft_iface != soft_iface)
 			continue;
 
@@ -461,7 +461,7 @@ static void send_outstanding_bcast_packet(struct work_struct *work)
 
 	/* rebroadcast packet */
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &if_list, list) {
+	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
 		if (batman_if->soft_iface != soft_iface)
 			continue;
 
-- 
1.7.2.3

