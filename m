From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 26/28] batman-adv: rename batman_if struct to hard_iface
Date: Sat,  5 Mar 2011 13:28:40 +0100
Message-ID: <1299328122-21468-27-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36359 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423Ab1CEMa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:29 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/aggregation.c    |    8 +-
 net/batman-adv/aggregation.h    |    4 +-
 net/batman-adv/bat_sysfs.c      |   41 +++--
 net/batman-adv/hard-interface.c |  353 ++++++++++++++++++++-------------------
 net/batman-adv/hard-interface.h |   12 +-
 net/batman-adv/main.c           |    8 +-
 net/batman-adv/originator.c     |   28 ++--
 net/batman-adv/originator.h     |    6 +-
 net/batman-adv/routing.c        |   48 +++---
 net/batman-adv/routing.h        |   20 +-
 net/batman-adv/send.c           |  101 ++++++------
 net/batman-adv/send.h           |    8 +-
 net/batman-adv/soft-interface.c |    2 +-
 net/batman-adv/soft-interface.h |    2 +-
 net/batman-adv/types.h          |    8 +-
 net/batman-adv/unicast.c        |    8 +-
 net/batman-adv/unicast.h        |    2 +-
 net/batman-adv/vis.c            |    6 +-
 18 files changed, 335 insertions(+), 330 deletions(-)

diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
index 1997725..af45d6b 100644
--- a/net/batman-adv/aggregation.c
+++ b/net/batman-adv/aggregation.c
@@ -35,7 +35,7 @@ static bool can_aggregate_with(struct batman_packet *new_batman_packet,
 			       int packet_len,
 			       unsigned long send_time,
 			       bool directlink,
-			       struct batman_if *if_incoming,
+			       struct hard_iface *if_incoming,
 			       struct forw_packet *forw_packet)
 {
 	struct batman_packet *batman_packet =
@@ -99,7 +99,7 @@ static bool can_aggregate_with(struct batman_packet *new_batman_packet,
 /* create a new aggregated packet and add this packet to it */
 static void new_aggregated_packet(unsigned char *packet_buff, int packet_len,
 				  unsigned long send_time, bool direct_link,
-				  struct batman_if *if_incoming,
+				  struct hard_iface *if_incoming,
 				  int own_packet)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
@@ -188,7 +188,7 @@ static void aggregate(struct forw_packet *forw_packet_aggr,
 
 void add_bat_packet_to_list(struct bat_priv *bat_priv,
 			    unsigned char *packet_buff, int packet_len,
-			    struct batman_if *if_incoming, char own_packet,
+			    struct hard_iface *if_incoming, char own_packet,
 			    unsigned long send_time)
 {
 	/**
@@ -247,7 +247,7 @@ void add_bat_packet_to_list(struct bat_priv *bat_priv,
 
 /* unpack the aggregated packets and process them one by one */
 void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
-			     int packet_len, struct batman_if *if_incoming)
+			     int packet_len, struct hard_iface *if_incoming)
 {
 	struct batman_packet *batman_packet;
 	int buff_pos = 0;
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index 6ce305b..0622042 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -35,9 +35,9 @@ static inline int aggregated_packet(int buff_pos, int packet_len, int num_hna)
 
 void add_bat_packet_to_list(struct bat_priv *bat_priv,
 			    unsigned char *packet_buff, int packet_len,
-			    struct batman_if *if_incoming, char own_packet,
+			    struct hard_iface *if_incoming, char own_packet,
 			    unsigned long send_time);
 void receive_aggr_bat_packet(struct ethhdr *ethhdr, unsigned char *packet_buff,
-			     int packet_len, struct batman_if *if_incoming);
+			     int packet_len, struct hard_iface *if_incoming);
 
 #endif /* _NET_BATMAN_ADV_AGGREGATION_H_ */
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 93ae20a..e449bf6 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -441,16 +441,16 @@ static ssize_t show_mesh_iface(struct kobject *kobj, struct attribute *attr,
 			       char *buff)
 {
 	struct net_device *net_dev = kobj_to_netdev(kobj);
-	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);
 	ssize_t length;
 
-	if (!batman_if)
+	if (!hard_iface)
 		return 0;
 
-	length = sprintf(buff, "%s\n", batman_if->if_status == IF_NOT_IN_USE ?
-			 "none" : batman_if->soft_iface->name);
+	length = sprintf(buff, "%s\n", hard_iface->if_status == IF_NOT_IN_USE ?
+			 "none" : hard_iface->soft_iface->name);
 
-	hardif_free_ref(batman_if);
+	hardif_free_ref(hard_iface);
 
 	return length;
 }
@@ -459,11 +459,11 @@ static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
 				char *buff, size_t count)
 {
 	struct net_device *net_dev = kobj_to_netdev(kobj);
-	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);
 	int status_tmp = -1;
 	int ret = count;
 
-	if (!batman_if)
+	if (!hard_iface)
 		return count;
 
 	if (buff[count - 1] == '\n')
@@ -472,7 +472,7 @@ static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
 	if (strlen(buff) >= IFNAMSIZ) {
 		pr_err("Invalid parameter for 'mesh_iface' setting received: "
 		       "interface name too long '%s'\n", buff);
-		hardif_free_ref(batman_if);
+		hardif_free_ref(hard_iface);
 		return -EINVAL;
 	}
 
@@ -481,28 +481,31 @@ static ssize_t store_mesh_iface(struct kobject *kobj, struct attribute *attr,
 	else
 		status_tmp = IF_I_WANT_YOU;
 
-	if ((batman_if->if_status == status_tmp) || ((batman_if->soft_iface) &&
-	    (strncmp(batman_if->soft_iface->name, buff, IFNAMSIZ) == 0)))
+	if (hard_iface->if_status == status_tmp)
+		goto out;
+
+	if ((hard_iface->soft_iface) &&
+	    (strncmp(hard_iface->soft_iface->name, buff, IFNAMSIZ) == 0))
 		goto out;
 
 	if (status_tmp == IF_NOT_IN_USE) {
 		rtnl_lock();
-		hardif_disable_interface(batman_if);
+		hardif_disable_interface(hard_iface);
 		rtnl_unlock();
 		goto out;
 	}
 
 	/* if the interface already is in use */
-	if (batman_if->if_status != IF_NOT_IN_USE) {
+	if (hard_iface->if_status != IF_NOT_IN_USE) {
 		rtnl_lock();
-		hardif_disable_interface(batman_if);
+		hardif_disable_interface(hard_iface);
 		rtnl_unlock();
 	}
 
-	ret = hardif_enable_interface(batman_if, buff);
+	ret = hardif_enable_interface(hard_iface, buff);
 
 out:
-	hardif_free_ref(batman_if);
+	hardif_free_ref(hard_iface);
 	return ret;
 }
 
@@ -510,13 +513,13 @@ static ssize_t show_iface_status(struct kobject *kobj, struct attribute *attr,
 				 char *buff)
 {
 	struct net_device *net_dev = kobj_to_netdev(kobj);
-	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);
 	ssize_t length;
 
-	if (!batman_if)
+	if (!hard_iface)
 		return 0;
 
-	switch (batman_if->if_status) {
+	switch (hard_iface->if_status) {
 	case IF_TO_BE_REMOVED:
 		length = sprintf(buff, "disabling\n");
 		break;
@@ -535,7 +538,7 @@ static ssize_t show_iface_status(struct kobject *kobj, struct attribute *attr,
 		break;
 	}
 
-	hardif_free_ref(batman_if);
+	hardif_free_ref(hard_iface);
 
 	return length;
 }
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 4a2e6e3..95a35b6 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -42,29 +42,29 @@ static int batman_skb_recv(struct sk_buff *skb,
 
 void hardif_free_rcu(struct rcu_head *rcu)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 
-	batman_if = container_of(rcu, struct batman_if, rcu);
-	dev_put(batman_if->net_dev);
-	kfree(batman_if);
+	hard_iface = container_of(rcu, struct hard_iface, rcu);
+	dev_put(hard_iface->net_dev);
+	kfree(hard_iface);
 }
 
-struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev)
+struct hard_iface *hardif_get_by_netdev(struct net_device *net_dev)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if (batman_if->net_dev == net_dev &&
-		    atomic_inc_not_zero(&batman_if->refcount))
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->net_dev == net_dev &&
+		    atomic_inc_not_zero(&hard_iface->refcount))
 			goto out;
 	}
 
-	batman_if = NULL;
+	hard_iface = NULL;
 
 out:
 	rcu_read_unlock();
-	return batman_if;
+	return hard_iface;
 }
 
 static int is_valid_iface(struct net_device *net_dev)
@@ -94,25 +94,25 @@ static int is_valid_iface(struct net_device *net_dev)
 	return 1;
 }
 
-static struct batman_if *get_active_batman_if(struct net_device *soft_iface)
+static struct hard_iface *hardif_get_active(struct net_device *soft_iface)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if (batman_if->soft_iface != soft_iface)
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		if (batman_if->if_status == IF_ACTIVE &&
-		    atomic_inc_not_zero(&batman_if->refcount))
+		if (hard_iface->if_status == IF_ACTIVE &&
+		    atomic_inc_not_zero(&hard_iface->refcount))
 			goto out;
 	}
 
-	batman_if = NULL;
+	hard_iface = NULL;
 
 out:
 	rcu_read_unlock();
-	return batman_if;
+	return hard_iface;
 }
 
 static void update_primary_addr(struct bat_priv *bat_priv)
@@ -128,16 +128,16 @@ static void update_primary_addr(struct bat_priv *bat_priv)
 }
 
 static void set_primary_if(struct bat_priv *bat_priv,
-			   struct batman_if *batman_if)
+			   struct hard_iface *hard_iface)
 {
 	struct batman_packet *batman_packet;
-	struct batman_if *old_if;
+	struct hard_iface *old_if;
 
-	if (batman_if && !atomic_inc_not_zero(&batman_if->refcount))
-		batman_if = NULL;
+	if (hard_iface && !atomic_inc_not_zero(&hard_iface->refcount))
+		hard_iface = NULL;
 
 	old_if = bat_priv->primary_if;
-	bat_priv->primary_if = batman_if;
+	bat_priv->primary_if = hard_iface;
 
 	if (old_if)
 		hardif_free_ref(old_if);
@@ -145,7 +145,7 @@ static void set_primary_if(struct bat_priv *bat_priv,
 	if (!bat_priv->primary_if)
 		return;
 
-	batman_packet = (struct batman_packet *)(batman_if->packet_buff);
+	batman_packet = (struct batman_packet *)(hard_iface->packet_buff);
 	batman_packet->flags = PRIMARIES_FIRST_HOP;
 	batman_packet->ttl = TTL;
 
@@ -158,42 +158,42 @@ static void set_primary_if(struct bat_priv *bat_priv,
 	atomic_set(&bat_priv->hna_local_changed, 1);
 }
 
-static bool hardif_is_iface_up(struct batman_if *batman_if)
+static bool hardif_is_iface_up(struct hard_iface *hard_iface)
 {
-	if (batman_if->net_dev->flags & IFF_UP)
+	if (hard_iface->net_dev->flags & IFF_UP)
 		return true;
 
 	return false;
 }
 
-static void update_mac_addresses(struct batman_if *batman_if)
+static void update_mac_addresses(struct hard_iface *hard_iface)
 {
-	memcpy(((struct batman_packet *)(batman_if->packet_buff))->orig,
-	       batman_if->net_dev->dev_addr, ETH_ALEN);
-	memcpy(((struct batman_packet *)(batman_if->packet_buff))->prev_sender,
-	       batman_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(((struct batman_packet *)(hard_iface->packet_buff))->orig,
+	       hard_iface->net_dev->dev_addr, ETH_ALEN);
+	memcpy(((struct batman_packet *)(hard_iface->packet_buff))->prev_sender,
+	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 }
 
 static void check_known_mac_addr(struct net_device *net_dev)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if ((batman_if->if_status != IF_ACTIVE) &&
-		    (batman_if->if_status != IF_TO_BE_ACTIVATED))
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if ((hard_iface->if_status != IF_ACTIVE) &&
+		    (hard_iface->if_status != IF_TO_BE_ACTIVATED))
 			continue;
 
-		if (batman_if->net_dev == net_dev)
+		if (hard_iface->net_dev == net_dev)
 			continue;
 
-		if (!compare_eth(batman_if->net_dev->dev_addr,
-				  net_dev->dev_addr))
+		if (!compare_eth(hard_iface->net_dev->dev_addr,
+				 net_dev->dev_addr))
 			continue;
 
 		pr_warning("The newly added mac address (%pM) already exists "
 			   "on: %s\n", net_dev->dev_addr,
-			   batman_if->net_dev->name);
+			   hard_iface->net_dev->name);
 		pr_warning("It is strongly recommended to keep mac addresses "
 			   "unique to avoid problems!\n");
 	}
@@ -203,7 +203,7 @@ static void check_known_mac_addr(struct net_device *net_dev)
 int hardif_min_mtu(struct net_device *soft_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 	/* allow big frames if all devices are capable to do so
 	 * (have MTU > 1500 + BAT_HEADER_LEN) */
 	int min_mtu = ETH_DATA_LEN;
@@ -212,15 +212,15 @@ int hardif_min_mtu(struct net_device *soft_iface)
 		goto out;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if ((batman_if->if_status != IF_ACTIVE) &&
-		    (batman_if->if_status != IF_TO_BE_ACTIVATED))
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if ((hard_iface->if_status != IF_ACTIVE) &&
+		    (hard_iface->if_status != IF_TO_BE_ACTIVATED))
 			continue;
 
-		if (batman_if->soft_iface != soft_iface)
+		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		min_mtu = min_t(int, batman_if->net_dev->mtu - BAT_HEADER_LEN,
+		min_mtu = min_t(int, hard_iface->net_dev->mtu - BAT_HEADER_LEN,
 				min_mtu);
 	}
 	rcu_read_unlock();
@@ -238,80 +238,80 @@ void update_min_mtu(struct net_device *soft_iface)
 		soft_iface->mtu = min_mtu;
 }
 
-static void hardif_activate_interface(struct batman_if *batman_if)
+static void hardif_activate_interface(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv;
 
-	if (batman_if->if_status != IF_INACTIVE)
+	if (hard_iface->if_status != IF_INACTIVE)
 		return;
 
-	bat_priv = netdev_priv(batman_if->soft_iface);
+	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	update_mac_addresses(batman_if);
-	batman_if->if_status = IF_TO_BE_ACTIVATED;
+	update_mac_addresses(hard_iface);
+	hard_iface->if_status = IF_TO_BE_ACTIVATED;
 
 	/**
 	 * the first active interface becomes our primary interface or
 	 * the next active interface after the old primay interface was removed
 	 */
 	if (!bat_priv->primary_if)
-		set_primary_if(bat_priv, batman_if);
+		set_primary_if(bat_priv, hard_iface);
 
-	bat_info(batman_if->soft_iface, "Interface activated: %s\n",
-		 batman_if->net_dev->name);
+	bat_info(hard_iface->soft_iface, "Interface activated: %s\n",
+		 hard_iface->net_dev->name);
 
-	update_min_mtu(batman_if->soft_iface);
+	update_min_mtu(hard_iface->soft_iface);
 	return;
 }
 
-static void hardif_deactivate_interface(struct batman_if *batman_if)
+static void hardif_deactivate_interface(struct hard_iface *hard_iface)
 {
-	if ((batman_if->if_status != IF_ACTIVE) &&
-	    (batman_if->if_status != IF_TO_BE_ACTIVATED))
+	if ((hard_iface->if_status != IF_ACTIVE) &&
+	    (hard_iface->if_status != IF_TO_BE_ACTIVATED))
 		return;
 
-	batman_if->if_status = IF_INACTIVE;
+	hard_iface->if_status = IF_INACTIVE;
 
-	bat_info(batman_if->soft_iface, "Interface deactivated: %s\n",
-		 batman_if->net_dev->name);
+	bat_info(hard_iface->soft_iface, "Interface deactivated: %s\n",
+		 hard_iface->net_dev->name);
 
-	update_min_mtu(batman_if->soft_iface);
+	update_min_mtu(hard_iface->soft_iface);
 }
 
-int hardif_enable_interface(struct batman_if *batman_if, char *iface_name)
+int hardif_enable_interface(struct hard_iface *hard_iface, char *iface_name)
 {
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet;
 
-	if (batman_if->if_status != IF_NOT_IN_USE)
+	if (hard_iface->if_status != IF_NOT_IN_USE)
 		goto out;
 
-	if (!atomic_inc_not_zero(&batman_if->refcount))
+	if (!atomic_inc_not_zero(&hard_iface->refcount))
 		goto out;
 
-	batman_if->soft_iface = dev_get_by_name(&init_net, iface_name);
+	hard_iface->soft_iface = dev_get_by_name(&init_net, iface_name);
 
-	if (!batman_if->soft_iface) {
-		batman_if->soft_iface = softif_create(iface_name);
+	if (!hard_iface->soft_iface) {
+		hard_iface->soft_iface = softif_create(iface_name);
 
-		if (!batman_if->soft_iface)
+		if (!hard_iface->soft_iface)
 			goto err;
 
 		/* dev_get_by_name() increases the reference counter for us */
-		dev_hold(batman_if->soft_iface);
+		dev_hold(hard_iface->soft_iface);
 	}
 
-	bat_priv = netdev_priv(batman_if->soft_iface);
-	batman_if->packet_len = BAT_PACKET_LEN;
-	batman_if->packet_buff = kmalloc(batman_if->packet_len, GFP_ATOMIC);
+	bat_priv = netdev_priv(hard_iface->soft_iface);
+	hard_iface->packet_len = BAT_PACKET_LEN;
+	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
 
-	if (!batman_if->packet_buff) {
-		bat_err(batman_if->soft_iface, "Can't add interface packet "
-			"(%s): out of memory\n", batman_if->net_dev->name);
+	if (!hard_iface->packet_buff) {
+		bat_err(hard_iface->soft_iface, "Can't add interface packet "
+			"(%s): out of memory\n", hard_iface->net_dev->name);
 		goto err;
 	}
 
-	batman_packet = (struct batman_packet *)(batman_if->packet_buff);
+	batman_packet = (struct batman_packet *)(hard_iface->packet_buff);
 	batman_packet->packet_type = BAT_PACKET;
 	batman_packet->version = COMPAT_VERSION;
 	batman_packet->flags = 0;
@@ -319,107 +319,107 @@ int hardif_enable_interface(struct batman_if *batman_if, char *iface_name)
 	batman_packet->tq = TQ_MAX_VALUE;
 	batman_packet->num_hna = 0;
 
-	batman_if->if_num = bat_priv->num_ifaces;
+	hard_iface->if_num = bat_priv->num_ifaces;
 	bat_priv->num_ifaces++;
-	batman_if->if_status = IF_INACTIVE;
-	orig_hash_add_if(batman_if, bat_priv->num_ifaces);
+	hard_iface->if_status = IF_INACTIVE;
+	orig_hash_add_if(hard_iface, bat_priv->num_ifaces);
 
-	batman_if->batman_adv_ptype.type = __constant_htons(ETH_P_BATMAN);
-	batman_if->batman_adv_ptype.func = batman_skb_recv;
-	batman_if->batman_adv_ptype.dev = batman_if->net_dev;
-	dev_add_pack(&batman_if->batman_adv_ptype);
+	hard_iface->batman_adv_ptype.type = __constant_htons(ETH_P_BATMAN);
+	hard_iface->batman_adv_ptype.func = batman_skb_recv;
+	hard_iface->batman_adv_ptype.dev = hard_iface->net_dev;
+	dev_add_pack(&hard_iface->batman_adv_ptype);
 
-	atomic_set(&batman_if->seqno, 1);
-	atomic_set(&batman_if->frag_seqno, 1);
-	bat_info(batman_if->soft_iface, "Adding interface: %s\n",
-		 batman_if->net_dev->name);
+	atomic_set(&hard_iface->seqno, 1);
+	atomic_set(&hard_iface->frag_seqno, 1);
+	bat_info(hard_iface->soft_iface, "Adding interface: %s\n",
+		 hard_iface->net_dev->name);
 
-	if (atomic_read(&bat_priv->fragmentation) && batman_if->net_dev->mtu <
+	if (atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
-		bat_info(batman_if->soft_iface,
+		bat_info(hard_iface->soft_iface,
 			"The MTU of interface %s is too small (%i) to handle "
 			"the transport of batman-adv packets. Packets going "
 			"over this interface will be fragmented on layer2 "
 			"which could impact the performance. Setting the MTU "
 			"to %zi would solve the problem.\n",
-			batman_if->net_dev->name, batman_if->net_dev->mtu,
+			hard_iface->net_dev->name, hard_iface->net_dev->mtu,
 			ETH_DATA_LEN + BAT_HEADER_LEN);
 
-	if (!atomic_read(&bat_priv->fragmentation) && batman_if->net_dev->mtu <
+	if (!atomic_read(&bat_priv->fragmentation) && hard_iface->net_dev->mtu <
 		ETH_DATA_LEN + BAT_HEADER_LEN)
-		bat_info(batman_if->soft_iface,
+		bat_info(hard_iface->soft_iface,
 			"The MTU of interface %s is too small (%i) to handle "
 			"the transport of batman-adv packets. If you experience"
 			" problems getting traffic through try increasing the "
 			"MTU to %zi.\n",
-			batman_if->net_dev->name, batman_if->net_dev->mtu,
+			hard_iface->net_dev->name, hard_iface->net_dev->mtu,
 			ETH_DATA_LEN + BAT_HEADER_LEN);
 
-	if (hardif_is_iface_up(batman_if))
-		hardif_activate_interface(batman_if);
+	if (hardif_is_iface_up(hard_iface))
+		hardif_activate_interface(hard_iface);
 	else
-		bat_err(batman_if->soft_iface, "Not using interface %s "
+		bat_err(hard_iface->soft_iface, "Not using interface %s "
 			"(retrying later): interface not active\n",
-			batman_if->net_dev->name);
+			hard_iface->net_dev->name);
 
 	/* begin scheduling originator messages on that interface */
-	schedule_own_packet(batman_if);
+	schedule_own_packet(hard_iface);
 
 out:
 	return 0;
 
 err:
-	hardif_free_ref(batman_if);
+	hardif_free_ref(hard_iface);
 	return -ENOMEM;
 }
 
-void hardif_disable_interface(struct batman_if *batman_if)
+void hardif_disable_interface(struct hard_iface *hard_iface)
 {
-	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	if (batman_if->if_status == IF_ACTIVE)
-		hardif_deactivate_interface(batman_if);
+	if (hard_iface->if_status == IF_ACTIVE)
+		hardif_deactivate_interface(hard_iface);
 
-	if (batman_if->if_status != IF_INACTIVE)
+	if (hard_iface->if_status != IF_INACTIVE)
 		return;
 
-	bat_info(batman_if->soft_iface, "Removing interface: %s\n",
-		 batman_if->net_dev->name);
-	dev_remove_pack(&batman_if->batman_adv_ptype);
+	bat_info(hard_iface->soft_iface, "Removing interface: %s\n",
+		 hard_iface->net_dev->name);
+	dev_remove_pack(&hard_iface->batman_adv_ptype);
 
 	bat_priv->num_ifaces--;
-	orig_hash_del_if(batman_if, bat_priv->num_ifaces);
+	orig_hash_del_if(hard_iface, bat_priv->num_ifaces);
 
-	if (batman_if == bat_priv->primary_if) {
-		struct batman_if *new_if;
+	if (hard_iface == bat_priv->primary_if) {
+		struct hard_iface *new_if;
 
-		new_if = get_active_batman_if(batman_if->soft_iface);
+		new_if = hardif_get_active(hard_iface->soft_iface);
 		set_primary_if(bat_priv, new_if);
 
 		if (new_if)
 			hardif_free_ref(new_if);
 	}
 
-	kfree(batman_if->packet_buff);
-	batman_if->packet_buff = NULL;
-	batman_if->if_status = IF_NOT_IN_USE;
+	kfree(hard_iface->packet_buff);
+	hard_iface->packet_buff = NULL;
+	hard_iface->if_status = IF_NOT_IN_USE;
 
-	/* delete all references to this batman_if */
+	/* delete all references to this hard_iface */
 	purge_orig_ref(bat_priv);
-	purge_outstanding_packets(bat_priv, batman_if);
-	dev_put(batman_if->soft_iface);
+	purge_outstanding_packets(bat_priv, hard_iface);
+	dev_put(hard_iface->soft_iface);
 
 	/* nobody uses this interface anymore */
 	if (!bat_priv->num_ifaces)
-		softif_destroy(batman_if->soft_iface);
+		softif_destroy(hard_iface->soft_iface);
 
-	batman_if->soft_iface = NULL;
-	hardif_free_ref(batman_if);
+	hard_iface->soft_iface = NULL;
+	hardif_free_ref(hard_iface);
 }
 
-static struct batman_if *hardif_add_interface(struct net_device *net_dev)
+static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 	int ret;
 
 	ret = is_valid_iface(net_dev);
@@ -428,72 +428,73 @@ static struct batman_if *hardif_add_interface(struct net_device *net_dev)
 
 	dev_hold(net_dev);
 
-	batman_if = kmalloc(sizeof(struct batman_if), GFP_ATOMIC);
-	if (!batman_if) {
+	hard_iface = kmalloc(sizeof(struct hard_iface), GFP_ATOMIC);
+	if (!hard_iface) {
 		pr_err("Can't add interface (%s): out of memory\n",
 		       net_dev->name);
 		goto release_dev;
 	}
 
-	ret = sysfs_add_hardif(&batman_if->hardif_obj, net_dev);
+	ret = sysfs_add_hardif(&hard_iface->hardif_obj, net_dev);
 	if (ret)
 		goto free_if;
 
-	batman_if->if_num = -1;
-	batman_if->net_dev = net_dev;
-	batman_if->soft_iface = NULL;
-	batman_if->if_status = IF_NOT_IN_USE;
-	INIT_LIST_HEAD(&batman_if->list);
+	hard_iface->if_num = -1;
+	hard_iface->net_dev = net_dev;
+	hard_iface->soft_iface = NULL;
+	hard_iface->if_status = IF_NOT_IN_USE;
+	INIT_LIST_HEAD(&hard_iface->list);
 	/* extra reference for return */
-	atomic_set(&batman_if->refcount, 2);
+	atomic_set(&hard_iface->refcount, 2);
 
-	check_known_mac_addr(batman_if->net_dev);
+	check_known_mac_addr(hard_iface->net_dev);
 
 	spin_lock(&hardif_list_lock);
-	list_add_tail_rcu(&batman_if->list, &hardif_list);
+	list_add_tail_rcu(&hard_iface->list, &hardif_list);
 	spin_unlock(&hardif_list_lock);
 
-	return batman_if;
+	return hard_iface;
 
 free_if:
-	kfree(batman_if);
+	kfree(hard_iface);
 release_dev:
 	dev_put(net_dev);
 out:
 	return NULL;
 }
 
-static void hardif_remove_interface(struct batman_if *batman_if)
+static void hardif_remove_interface(struct hard_iface *hard_iface)
 {
 	/* first deactivate interface */
-	if (batman_if->if_status != IF_NOT_IN_USE)
-		hardif_disable_interface(batman_if);
+	if (hard_iface->if_status != IF_NOT_IN_USE)
+		hardif_disable_interface(hard_iface);
 
-	if (batman_if->if_status != IF_NOT_IN_USE)
+	if (hard_iface->if_status != IF_NOT_IN_USE)
 		return;
 
-	batman_if->if_status = IF_TO_BE_REMOVED;
-	sysfs_del_hardif(&batman_if->hardif_obj);
-	hardif_free_ref(batman_if);
+	hard_iface->if_status = IF_TO_BE_REMOVED;
+	sysfs_del_hardif(&hard_iface->hardif_obj);
+	hardif_free_ref(hard_iface);
 }
 
 void hardif_remove_interfaces(void)
 {
-	struct batman_if *batman_if, *batman_if_tmp;
+	struct hard_iface *hard_iface, *hard_iface_tmp;
 	struct list_head if_queue;
 
 	INIT_LIST_HEAD(&if_queue);
 
 	spin_lock(&hardif_list_lock);
-	list_for_each_entry_safe(batman_if, batman_if_tmp, &hardif_list, list) {
-		list_del_rcu(&batman_if->list);
-		list_add_tail(&batman_if->list, &if_queue);
+	list_for_each_entry_safe(hard_iface, hard_iface_tmp,
+				 &hardif_list, list) {
+		list_del_rcu(&hard_iface->list);
+		list_add_tail(&hard_iface->list, &if_queue);
 	}
 	spin_unlock(&hardif_list_lock);
 
 	rtnl_lock();
-	list_for_each_entry_safe(batman_if, batman_if_tmp, &if_queue, list) {
-		hardif_remove_interface(batman_if);
+	list_for_each_entry_safe(hard_iface, hard_iface_tmp, &if_queue, list) {
+		hardif_remove_interface(hard_iface);
 	}
 	rtnl_unlock();
 }
@@ -502,43 +503,43 @@ static int hard_if_event(struct notifier_block *this,
 			 unsigned long event, void *ptr)
 {
 	struct net_device *net_dev = (struct net_device *)ptr;
-	struct batman_if *batman_if = get_batman_if_by_netdev(net_dev);
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);
 	struct bat_priv *bat_priv;
 
-	if (!batman_if && event == NETDEV_REGISTER)
-		batman_if = hardif_add_interface(net_dev);
+	if (!hard_iface && event == NETDEV_REGISTER)
+		hard_iface = hardif_add_interface(net_dev);
 
-	if (!batman_if)
+	if (!hard_iface)
 		goto out;
 
 	switch (event) {
 	case NETDEV_UP:
-		hardif_activate_interface(batman_if);
+		hardif_activate_interface(hard_iface);
 		break;
 	case NETDEV_GOING_DOWN:
 	case NETDEV_DOWN:
-		hardif_deactivate_interface(batman_if);
+		hardif_deactivate_interface(hard_iface);
 		break;
 	case NETDEV_UNREGISTER:
 		spin_lock(&hardif_list_lock);
-		list_del_rcu(&batman_if->list);
+		list_del_rcu(&hard_iface->list);
 		spin_unlock(&hardif_list_lock);
 
-		hardif_remove_interface(batman_if);
+		hardif_remove_interface(hard_iface);
 		break;
 	case NETDEV_CHANGEMTU:
-		if (batman_if->soft_iface)
-			update_min_mtu(batman_if->soft_iface);
+		if (hard_iface->soft_iface)
+			update_min_mtu(hard_iface->soft_iface);
 		break;
 	case NETDEV_CHANGEADDR:
-		if (batman_if->if_status == IF_NOT_IN_USE)
+		if (hard_iface->if_status == IF_NOT_IN_USE)
 			goto hardif_put;
 
-		check_known_mac_addr(batman_if->net_dev);
-		update_mac_addresses(batman_if);
+		check_known_mac_addr(hard_iface->net_dev);
+		update_mac_addresses(hard_iface);
 
-		bat_priv = netdev_priv(batman_if->soft_iface);
-		if (batman_if == bat_priv->primary_if)
+		bat_priv = netdev_priv(hard_iface->soft_iface);
+		if (hard_iface == bat_priv->primary_if)
 			update_primary_addr(bat_priv);
 		break;
 	default:
@@ -546,7 +547,7 @@ static int hard_if_event(struct notifier_block *this,
 	};
 
 hardif_put:
-	hardif_free_ref(batman_if);
+	hardif_free_ref(hard_iface);
 out:
 	return NOTIFY_DONE;
 }
@@ -559,10 +560,10 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet;
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 	int ret;
 
-	batman_if = container_of(ptype, struct batman_if, batman_adv_ptype);
+	hard_iface = container_of(ptype, struct hard_iface, batman_adv_ptype);
 	skb = skb_share_check(skb, GFP_ATOMIC);
 
 	/* skb was released by skb_share_check() */
@@ -578,16 +579,16 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 				|| !skb_mac_header(skb)))
 		goto err_free;
 
-	if (!batman_if->soft_iface)
+	if (!hard_iface->soft_iface)
 		goto err_free;
 
-	bat_priv = netdev_priv(batman_if->soft_iface);
+	bat_priv = netdev_priv(hard_iface->soft_iface);
 
 	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
 		goto err_free;
 
 	/* discard frames on not active interfaces */
-	if (batman_if->if_status != IF_ACTIVE)
+	if (hard_iface->if_status != IF_ACTIVE)
 		goto err_free;
 
 	batman_packet = (struct batman_packet *)skb->data;
@@ -605,32 +606,32 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	switch (batman_packet->packet_type) {
 		/* batman originator packet */
 	case BAT_PACKET:
-		ret = recv_bat_packet(skb, batman_if);
+		ret = recv_bat_packet(skb, hard_iface);
 		break;
 
 		/* batman icmp packet */
 	case BAT_ICMP:
-		ret = recv_icmp_packet(skb, batman_if);
+		ret = recv_icmp_packet(skb, hard_iface);
 		break;
 
 		/* unicast packet */
 	case BAT_UNICAST:
-		ret = recv_unicast_packet(skb, batman_if);
+		ret = recv_unicast_packet(skb, hard_iface);
 		break;
 
 		/* fragmented unicast packet */
 	case BAT_UNICAST_FRAG:
-		ret = recv_ucast_frag_packet(skb, batman_if);
+		ret = recv_ucast_frag_packet(skb, hard_iface);
 		break;
 
 		/* broadcast packet */
 	case BAT_BCAST:
-		ret = recv_bcast_packet(skb, batman_if);
+		ret = recv_bcast_packet(skb, hard_iface);
 		break;
 
 		/* vis packet */
 	case BAT_VIS:
-		ret = recv_vis_packet(skb, batman_if);
+		ret = recv_vis_packet(skb, hard_iface);
 		break;
 	default:
 		ret = NET_RX_DROP;
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index e488b90..a9ddf36 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -31,18 +31,18 @@
 
 extern struct notifier_block hard_if_notifier;
 
-struct batman_if *get_batman_if_by_netdev(struct net_device *net_dev);
-int hardif_enable_interface(struct batman_if *batman_if, char *iface_name);
-void hardif_disable_interface(struct batman_if *batman_if);
+struct hard_iface *hardif_get_by_netdev(struct net_device *net_dev);
+int hardif_enable_interface(struct hard_iface *hard_iface, char *iface_name);
+void hardif_disable_interface(struct hard_iface *hard_iface);
 void hardif_remove_interfaces(void);
 int hardif_min_mtu(struct net_device *soft_iface);
 void update_min_mtu(struct net_device *soft_iface);
 void hardif_free_rcu(struct rcu_head *rcu);
 
-static inline void hardif_free_ref(struct batman_if *batman_if)
+static inline void hardif_free_ref(struct hard_iface *hard_iface)
 {
-	if (atomic_dec_and_test(&batman_if->refcount))
-		call_rcu(&batman_if->rcu, hardif_free_rcu);
+	if (atomic_dec_and_test(&hard_iface->refcount))
+		call_rcu(&hard_iface->rcu, hardif_free_rcu);
 }
 
 #endif /* _NET_BATMAN_ADV_HARD_INTERFACE_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 57aea9b..709b33b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -153,14 +153,14 @@ void dec_module_count(void)
 
 int is_my_mac(uint8_t *addr)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if (batman_if->if_status != IF_ACTIVE)
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->if_status != IF_ACTIVE)
 			continue;
 
-		if (compare_eth(batman_if->net_dev->dev_addr, addr)) {
+		if (compare_eth(hard_iface->net_dev->dev_addr, addr)) {
 			rcu_read_unlock();
 			return 1;
 		}
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 84ef9ae..0b91330 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -73,7 +73,7 @@ void neigh_node_free_ref(struct neigh_node *neigh_node)
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
 				   uint8_t *neigh,
-				   struct batman_if *if_incoming)
+				   struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *neigh_node;
@@ -487,9 +487,9 @@ static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
 	return 0;
 }
 
-int orig_hash_add_if(struct batman_if *batman_if, int max_if_num)
+int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num)
 {
-	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -572,13 +572,13 @@ free_own_sum:
 	return 0;
 }
 
-int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
+int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num)
 {
-	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
-	struct batman_if *batman_if_tmp;
+	struct hard_iface *hard_iface_tmp;
 	struct orig_node *orig_node;
 	int i, ret;
 
@@ -591,7 +591,7 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			spin_lock_bh(&orig_node->ogm_cnt_lock);
 			ret = orig_node_del_if(orig_node, max_if_num,
-					batman_if->if_num);
+					hard_iface->if_num);
 			spin_unlock_bh(&orig_node->ogm_cnt_lock);
 
 			if (ret == -1)
@@ -602,22 +602,22 @@ int orig_hash_del_if(struct batman_if *batman_if, int max_if_num)
 
 	/* renumber remaining batman interfaces _inside_ of orig_hash_lock */
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if_tmp, &hardif_list, list) {
-		if (batman_if_tmp->if_status == IF_NOT_IN_USE)
+	list_for_each_entry_rcu(hard_iface_tmp, &hardif_list, list) {
+		if (hard_iface_tmp->if_status == IF_NOT_IN_USE)
 			continue;
 
-		if (batman_if == batman_if_tmp)
+		if (hard_iface == hard_iface_tmp)
 			continue;
 
-		if (batman_if->soft_iface != batman_if_tmp->soft_iface)
+		if (hard_iface->soft_iface != hard_iface_tmp->soft_iface)
 			continue;
 
-		if (batman_if_tmp->if_num > batman_if->if_num)
-			batman_if_tmp->if_num--;
+		if (hard_iface_tmp->if_num > hard_iface->if_num)
+			hard_iface_tmp->if_num--;
 	}
 	rcu_read_unlock();
 
-	batman_if->if_num = -1;
+	hard_iface->if_num = -1;
 	return 0;
 
 err:
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 3d7a39d..5cc0110 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -32,11 +32,11 @@ struct orig_node *get_orig_node(struct bat_priv *bat_priv, uint8_t *addr);
 struct neigh_node *create_neighbor(struct orig_node *orig_node,
 				   struct orig_node *orig_neigh_node,
 				   uint8_t *neigh,
-				   struct batman_if *if_incoming);
+				   struct hard_iface *if_incoming);
 void neigh_node_free_ref(struct neigh_node *neigh_node);
 int orig_seq_print_text(struct seq_file *seq, void *offset);
-int orig_hash_add_if(struct batman_if *batman_if, int max_if_num);
-int orig_hash_del_if(struct batman_if *batman_if, int max_if_num);
+int orig_hash_add_if(struct hard_iface *hard_iface, int max_if_num);
+int orig_hash_del_if(struct hard_iface *hard_iface, int max_if_num);
 
 
 /* returns 1 if they are the same originator */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 21e93b3..42cb6e2 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -35,9 +35,9 @@
 #include "gateway_client.h"
 #include "unicast.h"
 
-void slide_own_bcast_window(struct batman_if *batman_if)
+void slide_own_bcast_window(struct hard_iface *hard_iface)
 {
-	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_node *node;
 	struct hlist_head *head;
@@ -52,11 +52,11 @@ void slide_own_bcast_window(struct batman_if *batman_if)
 		rcu_read_lock();
 		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
 			spin_lock_bh(&orig_node->ogm_cnt_lock);
-			word_index = batman_if->if_num * NUM_WORDS;
+			word_index = hard_iface->if_num * NUM_WORDS;
 			word = &(orig_node->bcast_own[word_index]);
 
 			bit_get_packet(bat_priv, word, 1, 0);
-			orig_node->bcast_own_sum[batman_if->if_num] =
+			orig_node->bcast_own_sum[hard_iface->if_num] =
 				bit_packet_count(word);
 			spin_unlock_bh(&orig_node->ogm_cnt_lock);
 		}
@@ -143,7 +143,7 @@ void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
 static int is_bidirectional_neigh(struct orig_node *orig_node,
 				struct orig_node *orig_neigh_node,
 				struct batman_packet *batman_packet,
-				struct batman_if *if_incoming)
+				struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node;
@@ -368,7 +368,7 @@ static void update_orig(struct bat_priv *bat_priv,
 			struct orig_node *orig_node,
 			struct ethhdr *ethhdr,
 			struct batman_packet *batman_packet,
-			struct batman_if *if_incoming,
+			struct hard_iface *if_incoming,
 			unsigned char *hna_buff, int hna_buff_len,
 			char is_duplicate)
 {
@@ -533,7 +533,7 @@ static int window_protected(struct bat_priv *bat_priv,
  */
 static char count_real_packets(struct ethhdr *ethhdr,
 			       struct batman_packet *batman_packet,
-			       struct batman_if *if_incoming)
+			       struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct orig_node *orig_node;
@@ -598,10 +598,10 @@ out:
 void receive_bat_packet(struct ethhdr *ethhdr,
 			struct batman_packet *batman_packet,
 			unsigned char *hna_buff, int hna_buff_len,
-			struct batman_if *if_incoming)
+			struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 	struct orig_node *orig_neigh_node, *orig_node;
 	char has_directlink_flag;
 	char is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
@@ -643,23 +643,23 @@ void receive_bat_packet(struct ethhdr *ethhdr,
 		has_directlink_flag);
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if (batman_if->if_status != IF_ACTIVE)
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->if_status != IF_ACTIVE)
 			continue;
 
-		if (batman_if->soft_iface != if_incoming->soft_iface)
+		if (hard_iface->soft_iface != if_incoming->soft_iface)
 			continue;
 
 		if (compare_eth(ethhdr->h_source,
-				batman_if->net_dev->dev_addr))
+				hard_iface->net_dev->dev_addr))
 			is_my_addr = 1;
 
 		if (compare_eth(batman_packet->orig,
-				batman_if->net_dev->dev_addr))
+				hard_iface->net_dev->dev_addr))
 			is_my_orig = 1;
 
 		if (compare_eth(batman_packet->prev_sender,
-				batman_if->net_dev->dev_addr))
+				hard_iface->net_dev->dev_addr))
 			is_my_oldorig = 1;
 
 		if (compare_eth(ethhdr->h_source, broadcast_addr))
@@ -828,7 +828,7 @@ out:
 	orig_node_free_ref(orig_node);
 }
 
-int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
+int recv_bat_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 {
 	struct ethhdr *ethhdr;
 
@@ -859,7 +859,7 @@ int recv_bat_packet(struct sk_buff *skb, struct batman_if *batman_if)
 	receive_aggr_bat_packet(ethhdr,
 				skb->data,
 				skb_headlen(skb),
-				batman_if);
+				hard_iface);
 
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
@@ -997,7 +997,7 @@ out:
 }
 
 
-int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if)
+int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct icmp_packet_rr *icmp_packet;
@@ -1097,7 +1097,7 @@ out:
  * refcount.*/
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
-			       struct batman_if *recv_if)
+			       struct hard_iface *recv_if)
 {
 	struct orig_node *primary_orig_node;
 	struct orig_node *router_orig;
@@ -1263,7 +1263,7 @@ static int check_unicast_packet(struct sk_buff *skb, int hdr_size)
 	return 0;
 }
 
-int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
+int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if,
 			 int hdr_size)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
@@ -1349,7 +1349,7 @@ out:
 	return ret;
 }
 
-int recv_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if)
+int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct unicast_packet *unicast_packet;
 	int hdr_size = sizeof(struct unicast_packet);
@@ -1368,7 +1368,7 @@ int recv_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if)
 	return route_unicast_packet(skb, recv_if, hdr_size);
 }
 
-int recv_ucast_frag_packet(struct sk_buff *skb, struct batman_if *recv_if)
+int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct unicast_frag_packet *unicast_packet;
@@ -1402,7 +1402,7 @@ int recv_ucast_frag_packet(struct sk_buff *skb, struct batman_if *recv_if)
 }
 
 
-int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if)
+int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct bat_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct orig_node *orig_node = NULL;
@@ -1487,7 +1487,7 @@ out:
 	return ret;
 }
 
-int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if)
+int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 {
 	struct vis_packet *vis_packet;
 	struct ethhdr *ethhdr;
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index e2a9872..5efceaf 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -22,25 +22,25 @@
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
 #define _NET_BATMAN_ADV_ROUTING_H_
 
-void slide_own_bcast_window(struct batman_if *batman_if);
+void slide_own_bcast_window(struct hard_iface *hard_iface);
 void receive_bat_packet(struct ethhdr *ethhdr,
 				struct batman_packet *batman_packet,
 				unsigned char *hna_buff, int hna_buff_len,
-				struct batman_if *if_incoming);
+				struct hard_iface *if_incoming);
 void update_routes(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		   struct neigh_node *neigh_node, unsigned char *hna_buff,
 		   int hna_buff_len);
-int route_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if,
+int route_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if,
 			 int hdr_size);
-int recv_icmp_packet(struct sk_buff *skb, struct batman_if *recv_if);
-int recv_unicast_packet(struct sk_buff *skb, struct batman_if *recv_if);
-int recv_ucast_frag_packet(struct sk_buff *skb, struct batman_if *recv_if);
-int recv_bcast_packet(struct sk_buff *skb, struct batman_if *recv_if);
-int recv_vis_packet(struct sk_buff *skb, struct batman_if *recv_if);
-int recv_bat_packet(struct sk_buff *skb, struct batman_if *recv_if);
+int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
+int recv_bat_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
 			       struct orig_node *orig_node,
-			       struct batman_if *recv_if);
+			       struct hard_iface *recv_if);
 void bonding_candidate_del(struct orig_node *orig_node,
 			   struct neigh_node *neigh_node);
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index c4f3e49..d49e54d 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -56,20 +56,20 @@ static unsigned long forward_send_time(void)
 /* send out an already prepared packet to the given address via the
  * specified batman interface */
 int send_skb_packet(struct sk_buff *skb,
-				struct batman_if *batman_if,
+				struct hard_iface *hard_iface,
 				uint8_t *dst_addr)
 {
 	struct ethhdr *ethhdr;
 
-	if (batman_if->if_status != IF_ACTIVE)
+	if (hard_iface->if_status != IF_ACTIVE)
 		goto send_skb_err;
 
-	if (unlikely(!batman_if->net_dev))
+	if (unlikely(!hard_iface->net_dev))
 		goto send_skb_err;
 
-	if (!(batman_if->net_dev->flags & IFF_UP)) {
+	if (!(hard_iface->net_dev->flags & IFF_UP)) {
 		pr_warning("Interface %s is not up - can't send packet via "
-			   "that interface!\n", batman_if->net_dev->name);
+			   "that interface!\n", hard_iface->net_dev->name);
 		goto send_skb_err;
 	}
 
@@ -80,7 +80,7 @@ int send_skb_packet(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 
 	ethhdr = (struct ethhdr *) skb_mac_header(skb);
-	memcpy(ethhdr->h_source, batman_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(ethhdr->h_source, hard_iface->net_dev->dev_addr, ETH_ALEN);
 	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
 	ethhdr->h_proto = __constant_htons(ETH_P_BATMAN);
 
@@ -88,7 +88,7 @@ int send_skb_packet(struct sk_buff *skb,
 	skb->priority = TC_PRIO_CONTROL;
 	skb->protocol = __constant_htons(ETH_P_BATMAN);
 
-	skb->dev = batman_if->net_dev;
+	skb->dev = hard_iface->net_dev;
 
 	/* dev_queue_xmit() returns a negative result on error.	 However on
 	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
@@ -102,16 +102,16 @@ send_skb_err:
 
 /* Send a packet to a given interface */
 static void send_packet_to_if(struct forw_packet *forw_packet,
-			      struct batman_if *batman_if)
+			      struct hard_iface *hard_iface)
 {
-	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	char *fwd_str;
 	uint8_t packet_num;
 	int16_t buff_pos;
 	struct batman_packet *batman_packet;
 	struct sk_buff *skb;
 
-	if (batman_if->if_status != IF_ACTIVE)
+	if (hard_iface->if_status != IF_ACTIVE)
 		return;
 
 	packet_num = 0;
@@ -126,7 +126,7 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet */
 		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
-		    (forw_packet->if_incoming == batman_if))
+		    (forw_packet->if_incoming == hard_iface))
 			batman_packet->flags |= DIRECTLINK;
 		else
 			batman_packet->flags &= ~DIRECTLINK;
@@ -142,7 +142,8 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 			batman_packet->tq, batman_packet->ttl,
 			(batman_packet->flags & DIRECTLINK ?
 			 "on" : "off"),
-			batman_if->net_dev->name, batman_if->net_dev->dev_addr);
+			hard_iface->net_dev->name,
+			hard_iface->net_dev->dev_addr);
 
 		buff_pos += sizeof(struct batman_packet) +
 			(batman_packet->num_hna * ETH_ALEN);
@@ -154,13 +155,13 @@ static void send_packet_to_if(struct forw_packet *forw_packet,
 	/* create clone because function is called more than once */
 	skb = skb_clone(forw_packet->skb, GFP_ATOMIC);
 	if (skb)
-		send_skb_packet(skb, batman_if, broadcast_addr);
+		send_skb_packet(skb, hard_iface, broadcast_addr);
 }
 
 /* send a batman packet */
 static void send_packet(struct forw_packet *forw_packet)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 	struct net_device *soft_iface;
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet =
@@ -204,17 +205,17 @@ static void send_packet(struct forw_packet *forw_packet)
 
 	/* broadcast on every interface */
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if (batman_if->soft_iface != soft_iface)
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		send_packet_to_if(forw_packet, batman_if);
+		send_packet_to_if(forw_packet, hard_iface);
 	}
 	rcu_read_unlock();
 }
 
 static void rebuild_batman_packet(struct bat_priv *bat_priv,
-				  struct batman_if *batman_if)
+				  struct hard_iface *hard_iface)
 {
 	int new_len;
 	unsigned char *new_buff;
@@ -226,7 +227,7 @@ static void rebuild_batman_packet(struct bat_priv *bat_priv,
 
 	/* keep old buffer if kmalloc should fail */
 	if (new_buff) {
-		memcpy(new_buff, batman_if->packet_buff,
+		memcpy(new_buff, hard_iface->packet_buff,
 		       sizeof(struct batman_packet));
 		batman_packet = (struct batman_packet *)new_buff;
 
@@ -234,21 +235,21 @@ static void rebuild_batman_packet(struct bat_priv *bat_priv,
 				new_buff + sizeof(struct batman_packet),
 				new_len - sizeof(struct batman_packet));
 
-		kfree(batman_if->packet_buff);
-		batman_if->packet_buff = new_buff;
-		batman_if->packet_len = new_len;
+		kfree(hard_iface->packet_buff);
+		hard_iface->packet_buff = new_buff;
+		hard_iface->packet_len = new_len;
 	}
 }
 
-void schedule_own_packet(struct batman_if *batman_if)
+void schedule_own_packet(struct hard_iface *hard_iface)
 {
-	struct bat_priv *bat_priv = netdev_priv(batman_if->soft_iface);
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	unsigned long send_time;
 	struct batman_packet *batman_packet;
 	int vis_server;
 
-	if ((batman_if->if_status == IF_NOT_IN_USE) ||
-	    (batman_if->if_status == IF_TO_BE_REMOVED))
+	if ((hard_iface->if_status == IF_NOT_IN_USE) ||
+	    (hard_iface->if_status == IF_TO_BE_REMOVED))
 		return;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
@@ -260,51 +261,51 @@ void schedule_own_packet(struct batman_if *batman_if)
 	 * outdated packets (especially uninitialized mac addresses) in the
 	 * packet queue
 	 */
-	if (batman_if->if_status == IF_TO_BE_ACTIVATED)
-		batman_if->if_status = IF_ACTIVE;
+	if (hard_iface->if_status == IF_TO_BE_ACTIVATED)
+		hard_iface->if_status = IF_ACTIVE;
 
 	/* if local hna has changed and interface is a primary interface */
 	if ((atomic_read(&bat_priv->hna_local_changed)) &&
-	    (batman_if == bat_priv->primary_if))
-		rebuild_batman_packet(bat_priv, batman_if);
+	    (hard_iface == bat_priv->primary_if))
+		rebuild_batman_packet(bat_priv, hard_iface);
 
 	/**
 	 * NOTE: packet_buff might just have been re-allocated in
 	 * rebuild_batman_packet()
 	 */
-	batman_packet = (struct batman_packet *)batman_if->packet_buff;
+	batman_packet = (struct batman_packet *)hard_iface->packet_buff;
 
 	/* change sequence number to network order */
 	batman_packet->seqno =
-		htonl((uint32_t)atomic_read(&batman_if->seqno));
+		htonl((uint32_t)atomic_read(&hard_iface->seqno));
 
 	if (vis_server == VIS_TYPE_SERVER_SYNC)
 		batman_packet->flags |= VIS_SERVER;
 	else
 		batman_packet->flags &= ~VIS_SERVER;
 
-	if ((batman_if == bat_priv->primary_if) &&
+	if ((hard_iface == bat_priv->primary_if) &&
 	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_SERVER))
 		batman_packet->gw_flags =
 				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
 	else
 		batman_packet->gw_flags = 0;
 
-	atomic_inc(&batman_if->seqno);
+	atomic_inc(&hard_iface->seqno);
 
-	slide_own_bcast_window(batman_if);
+	slide_own_bcast_window(hard_iface);
 	send_time = own_send_time(bat_priv);
 	add_bat_packet_to_list(bat_priv,
-			       batman_if->packet_buff,
-			       batman_if->packet_len,
-			       batman_if, 1, send_time);
+			       hard_iface->packet_buff,
+			       hard_iface->packet_len,
+			       hard_iface, 1, send_time);
 }
 
 void schedule_forward_packet(struct orig_node *orig_node,
 			     struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
 			     uint8_t directlink, int hna_buff_len,
-			     struct batman_if *if_incoming)
+			     struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	unsigned char in_tq, in_ttl, tq_avg = 0;
@@ -443,7 +444,7 @@ out:
 
 static void send_outstanding_bcast_packet(struct work_struct *work)
 {
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
 	struct forw_packet *forw_packet =
@@ -461,14 +462,14 @@ static void send_outstanding_bcast_packet(struct work_struct *work)
 
 	/* rebroadcast packet */
 	rcu_read_lock();
-	list_for_each_entry_rcu(batman_if, &hardif_list, list) {
-		if (batman_if->soft_iface != soft_iface)
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
 		/* send a copy of the saved skb */
 		skb1 = skb_clone(forw_packet->skb, GFP_ATOMIC);
 		if (skb1)
-			send_skb_packet(skb1, batman_if, broadcast_addr);
+			send_skb_packet(skb1, hard_iface, broadcast_addr);
 	}
 	rcu_read_unlock();
 
@@ -521,15 +522,15 @@ out:
 }
 
 void purge_outstanding_packets(struct bat_priv *bat_priv,
-			       struct batman_if *batman_if)
+			       struct hard_iface *hard_iface)
 {
 	struct forw_packet *forw_packet;
 	struct hlist_node *tmp_node, *safe_tmp_node;
 
-	if (batman_if)
+	if (hard_iface)
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"purge_outstanding_packets(): %s\n",
-			batman_if->net_dev->name);
+			hard_iface->net_dev->name);
 	else
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"purge_outstanding_packets()\n");
@@ -543,8 +544,8 @@ void purge_outstanding_packets(struct bat_priv *bat_priv,
 		 * if purge_outstanding_packets() was called with an argmument
 		 * we delete only packets belonging to the given interface
 		 */
-		if ((batman_if) &&
-		    (forw_packet->if_incoming != batman_if))
+		if ((hard_iface) &&
+		    (forw_packet->if_incoming != hard_iface))
 			continue;
 
 		spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
@@ -567,8 +568,8 @@ void purge_outstanding_packets(struct bat_priv *bat_priv,
 		 * if purge_outstanding_packets() was called with an argmument
 		 * we delete only packets belonging to the given interface
 		 */
-		if ((batman_if) &&
-		    (forw_packet->if_incoming != batman_if))
+		if ((hard_iface) &&
+		    (forw_packet->if_incoming != hard_iface))
 			continue;
 
 		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index b68c272..7b2ff19 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -23,17 +23,17 @@
 #define _NET_BATMAN_ADV_SEND_H_
 
 int send_skb_packet(struct sk_buff *skb,
-				struct batman_if *batman_if,
+				struct hard_iface *hard_iface,
 				uint8_t *dst_addr);
-void schedule_own_packet(struct batman_if *batman_if);
+void schedule_own_packet(struct hard_iface *hard_iface);
 void schedule_forward_packet(struct orig_node *orig_node,
 			     struct ethhdr *ethhdr,
 			     struct batman_packet *batman_packet,
 			     uint8_t directlink, int hna_buff_len,
-			     struct batman_if *if_outgoing);
+			     struct hard_iface *if_outgoing);
 int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb);
 void send_outstanding_bat_packet(struct work_struct *work);
 void purge_outstanding_packets(struct bat_priv *bat_priv,
-			       struct batman_if *batman_if);
+			       struct hard_iface *hard_iface);
 
 #endif /* _NET_BATMAN_ADV_SEND_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index bea2dcf..95d1c3f 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -414,7 +414,7 @@ end:
 }
 
 void interface_rx(struct net_device *soft_iface,
-		  struct sk_buff *skb, struct batman_if *recv_if,
+		  struct sk_buff *skb, struct hard_iface *recv_if,
 		  int hdr_size)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index e7b0e1a..80a3607 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -27,7 +27,7 @@ int softif_neigh_seq_print_text(struct seq_file *seq, void *offset);
 void softif_neigh_purge(struct bat_priv *bat_priv);
 int interface_tx(struct sk_buff *skb, struct net_device *soft_iface);
 void interface_rx(struct net_device *soft_iface,
-		  struct sk_buff *skb, struct batman_if *recv_if,
+		  struct sk_buff *skb, struct hard_iface *recv_if,
 		  int hdr_size);
 struct net_device *softif_create(char *name);
 void softif_destroy(struct net_device *soft_iface);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index a9bf186..83445cf 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -33,7 +33,7 @@
 	 sizeof(struct bcast_packet))))
 
 
-struct batman_if {
+struct hard_iface {
 	struct list_head list;
 	int16_t if_num;
 	char if_status;
@@ -124,7 +124,7 @@ struct neigh_node {
 	atomic_t refcount;
 	struct rcu_head rcu;
 	struct orig_node *orig_node;
-	struct batman_if *if_incoming;
+	struct hard_iface *if_incoming;
 };
 
 
@@ -148,7 +148,7 @@ struct bat_priv {
 	struct hlist_head softif_neigh_list;
 	struct softif_neigh *softif_neigh;
 	struct debug_log *debug_log;
-	struct batman_if *primary_if;
+	struct hard_iface *primary_if;
 	struct kobject *mesh_obj;
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
@@ -217,7 +217,7 @@ struct forw_packet {
 	uint32_t direct_link_flags;
 	uint8_t num_packets;
 	struct delayed_work delayed_work;
-	struct batman_if *if_incoming;
+	struct hard_iface *if_incoming;
 };
 
 /* While scanning for vis-entries of a particular vis-originator
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index b411438..7238f04 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -213,7 +213,7 @@ out:
 }
 
 int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-		  struct batman_if *batman_if, uint8_t dstaddr[])
+		  struct hard_iface *hard_iface, uint8_t dstaddr[])
 {
 	struct unicast_packet tmp_uc, *unicast_packet;
 	struct sk_buff *frag_skb;
@@ -258,12 +258,12 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	frag1->flags = UNI_FRAG_HEAD | large_tail;
 	frag2->flags = large_tail;
 
-	seqno = atomic_add_return(2, &batman_if->frag_seqno);
+	seqno = atomic_add_return(2, &hard_iface->frag_seqno);
 	frag1->seqno = htons(seqno - 1);
 	frag2->seqno = htons(seqno);
 
-	send_skb_packet(skb, batman_if, dstaddr);
-	send_skb_packet(frag_skb, batman_if, dstaddr);
+	send_skb_packet(skb, hard_iface, dstaddr);
+	send_skb_packet(frag_skb, hard_iface, dstaddr);
 	return NET_RX_SUCCESS;
 
 drop_frag:
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index 8897308..16ad7a9 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -32,7 +32,7 @@ int frag_reassemble_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 void frag_list_free(struct list_head *head);
 int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv);
 int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
-		  struct batman_if *batman_if, uint8_t dstaddr[]);
+		  struct hard_iface *hard_iface, uint8_t dstaddr[]);
 
 static inline int frag_can_reassemble(struct sk_buff *skb, int mtu)
 {
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index e8911cb..3da499b 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -730,7 +730,7 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 	struct orig_node *orig_node;
 	struct vis_packet *packet;
 	struct sk_buff *skb;
-	struct batman_if *batman_if;
+	struct hard_iface *hard_iface;
 	uint8_t dstaddr[ETH_ALEN];
 	int i;
 
@@ -755,12 +755,12 @@ static void broadcast_vis_packet(struct bat_priv *bat_priv,
 				continue;
 
 			memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
-			batman_if = orig_node->router->if_incoming;
+			hard_iface = orig_node->router->if_incoming;
 			memcpy(dstaddr, orig_node->router->addr, ETH_ALEN);
 
 			skb = skb_clone(info->skb_packet, GFP_ATOMIC);
 			if (skb)
-				send_skb_packet(skb, batman_if, dstaddr);
+				send_skb_packet(skb, hard_iface, dstaddr);
 
 		}
 		rcu_read_unlock();
-- 
1.7.2.3

