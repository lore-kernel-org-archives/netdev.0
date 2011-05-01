From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 4/4] batman-adv: Make bat_priv->primary_if an
	rcu protected pointer
Date: Sun,  1 May 2011 23:10:34 +0200
Message-ID: <1304284234-27338-5-git-send-email-sven@narfation.org>
References: <1304284234-27338-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1304284234-27338-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>

The rcu protected macros rcu_dereference() and rcu_assign_pointer()
for the bat_priv->primary_if need to be used, as well as spin/rcu locking.

Otherwise we might end up using a primary_if pointer pointing to already
freed memory.

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c    |   33 ++++++++------
 net/batman-adv/hard-interface.c    |   83 ++++++++++++++++++++++++-----------
 net/batman-adv/hard-interface.h    |   18 ++++++++
 net/batman-adv/icmp_socket.c       |   19 ++++++--
 net/batman-adv/originator.c        |   34 +++++++++------
 net/batman-adv/routing.c           |   18 +++++---
 net/batman-adv/send.c              |   17 ++++++--
 net/batman-adv/soft-interface.c    |   64 +++++++++++++++++++--------
 net/batman-adv/translation-table.c |   57 ++++++++++++++++++------
 net/batman-adv/types.h             |    2 +-
 net/batman-adv/unicast.c           |   16 +++++--
 net/batman-adv/vis.c               |   37 +++++++++++-----
 12 files changed, 280 insertions(+), 118 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index af128ef..65f3953 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -439,30 +439,32 @@ int gw_client_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
+	struct hard_iface *primary_if;
 	struct gw_node *gw_node;
 	struct hlist_node *node;
-	int gw_count = 0;
+	int gw_count = 0, ret = 0;
 
-	if (!bat_priv->primary_if) {
-
-		return seq_printf(seq, "BATMAN mesh %s disabled - please "
-				  "specify interfaces to enable it\n",
-				  net_dev->name);
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - please "
+				 "specify interfaces to enable it\n",
+				 net_dev->name);
+		goto out;
 	}
 
-	if (bat_priv->primary_if->if_status != IF_ACTIVE) {
-
-		return seq_printf(seq, "BATMAN mesh %s disabled - "
-				       "primary interface not active\n",
-				       net_dev->name);
+	if (primary_if->if_status != IF_ACTIVE) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
+				 "primary interface not active\n",
+				 net_dev->name);
+		goto out;
 	}
 
 	seq_printf(seq, "      %-12s (%s/%i) %17s [%10s]: gw_class ... "
 		   "[B.A.T.M.A.N. adv %s%s, MainIF/MAC: %s/%pM (%s)]\n",
 		   "Gateway", "#", TQ_MAX_VALUE, "Nexthop",
 		   "outgoingIF", SOURCE_VERSION, REVISION_VERSION_STR,
-		   bat_priv->primary_if->net_dev->name,
-		   bat_priv->primary_if->net_dev->dev_addr, net_dev->name);
+		   primary_if->net_dev->name,
+		   primary_if->net_dev->dev_addr, net_dev->name);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
@@ -480,7 +482,10 @@ int gw_client_seq_print_text(struct seq_file *seq, void *offset)
 	if (gw_count == 0)
 		seq_printf(seq, "No gateways in range ...\n");
 
-	return 0;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
 }
 
 int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index b3058e4..3e888f1 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -110,47 +110,60 @@ out:
 	return hard_iface;
 }
 
-static void update_primary_addr(struct bat_priv *bat_priv)
+static void primary_if_update_addr(struct bat_priv *bat_priv)
 {
 	struct vis_packet *vis_packet;
+	struct hard_iface *primary_if;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
 
 	vis_packet = (struct vis_packet *)
 				bat_priv->my_vis_info->skb_packet->data;
-	memcpy(vis_packet->vis_orig,
-	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(vis_packet->vis_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(vis_packet->sender_orig,
-	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	       primary_if->net_dev->dev_addr, ETH_ALEN);
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 }
 
-static void set_primary_if(struct bat_priv *bat_priv,
-			   struct hard_iface *hard_iface)
+static void primary_if_select(struct bat_priv *bat_priv,
+			      struct hard_iface *new_hard_iface)
 {
+	struct hard_iface *curr_hard_iface;
 	struct batman_packet *batman_packet;
-	struct hard_iface *old_if;
 
-	if (hard_iface && !atomic_inc_not_zero(&hard_iface->refcount))
-		hard_iface = NULL;
+	spin_lock_bh(&hardif_list_lock);
 
-	old_if = bat_priv->primary_if;
-	bat_priv->primary_if = hard_iface;
+	if (new_hard_iface && !atomic_inc_not_zero(&new_hard_iface->refcount))
+		new_hard_iface = NULL;
 
-	if (old_if)
-		hardif_free_ref(old_if);
+	curr_hard_iface = bat_priv->primary_if;
+	rcu_assign_pointer(bat_priv->primary_if, new_hard_iface);
 
-	if (!bat_priv->primary_if)
-		return;
+	if (curr_hard_iface)
+		hardif_free_ref(curr_hard_iface);
 
-	batman_packet = (struct batman_packet *)(hard_iface->packet_buff);
+	if (!new_hard_iface)
+		goto out;
+
+	batman_packet = (struct batman_packet *)(new_hard_iface->packet_buff);
 	batman_packet->flags = PRIMARIES_FIRST_HOP;
 	batman_packet->ttl = TTL;
 
-	update_primary_addr(bat_priv);
+	primary_if_update_addr(bat_priv);
 
 	/***
 	 * hacky trick to make sure that we send the HNA information via
 	 * our new primary interface
 	 */
 	atomic_set(&bat_priv->hna_local_changed, 1);
+
+out:
+	spin_unlock_bh(&hardif_list_lock);
 }
 
 static bool hardif_is_iface_up(struct hard_iface *hard_iface)
@@ -236,9 +249,10 @@ void update_min_mtu(struct net_device *soft_iface)
 static void hardif_activate_interface(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv;
+	struct hard_iface *primary_if = NULL;
 
 	if (hard_iface->if_status != IF_INACTIVE)
-		return;
+		goto out;
 
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
@@ -249,14 +263,18 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 	 * the first active interface becomes our primary interface or
 	 * the next active interface after the old primay interface was removed
 	 */
-	if (!bat_priv->primary_if)
-		set_primary_if(bat_priv, hard_iface);
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		primary_if_select(bat_priv, hard_iface);
 
 	bat_info(hard_iface->soft_iface, "Interface activated: %s\n",
 		 hard_iface->net_dev->name);
 
 	update_min_mtu(hard_iface->soft_iface);
-	return;
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 }
 
 static void hardif_deactivate_interface(struct hard_iface *hard_iface)
@@ -386,12 +404,13 @@ err:
 void hardif_disable_interface(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	struct hard_iface *primary_if = NULL;
 
 	if (hard_iface->if_status == IF_ACTIVE)
 		hardif_deactivate_interface(hard_iface);
 
 	if (hard_iface->if_status != IF_INACTIVE)
-		return;
+		goto out;
 
 	bat_info(hard_iface->soft_iface, "Removing interface: %s\n",
 		 hard_iface->net_dev->name);
@@ -400,11 +419,12 @@ void hardif_disable_interface(struct hard_iface *hard_iface)
 	bat_priv->num_ifaces--;
 	orig_hash_del_if(hard_iface, bat_priv->num_ifaces);
 
-	if (hard_iface == bat_priv->primary_if) {
+	primary_if = primary_if_get_selected(bat_priv);
+	if (hard_iface == primary_if) {
 		struct hard_iface *new_if;
 
 		new_if = hardif_get_active(hard_iface->soft_iface);
-		set_primary_if(bat_priv, new_if);
+		primary_if_select(bat_priv, new_if);
 
 		if (new_if)
 			hardif_free_ref(new_if);
@@ -425,6 +445,10 @@ void hardif_disable_interface(struct hard_iface *hard_iface)
 
 	hard_iface->soft_iface = NULL;
 	hardif_free_ref(hard_iface);
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 }
 
 static struct hard_iface *hardif_add_interface(struct net_device *net_dev)
@@ -514,6 +538,7 @@ static int hard_if_event(struct notifier_block *this,
 {
 	struct net_device *net_dev = (struct net_device *)ptr;
 	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);
+	struct hard_iface *primary_if = NULL;
 	struct bat_priv *bat_priv;
 
 	if (!hard_iface && event == NETDEV_REGISTER)
@@ -549,8 +574,12 @@ static int hard_if_event(struct notifier_block *this,
 		update_mac_addresses(hard_iface);
 
 		bat_priv = netdev_priv(hard_iface->soft_iface);
-		if (hard_iface == bat_priv->primary_if)
-			update_primary_addr(bat_priv);
+		primary_if = primary_if_get_selected(bat_priv);
+		if (!primary_if)
+			goto hardif_put;
+
+		if (hard_iface == primary_if)
+			primary_if_update_addr(bat_priv);
 		break;
 	default:
 		break;
@@ -559,6 +588,8 @@ static int hard_if_event(struct notifier_block *this,
 hardif_put:
 	hardif_free_ref(hard_iface);
 out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 	return NOTIFY_DONE;
 }
 
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index a9ddf36..6426599 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -45,4 +45,22 @@ static inline void hardif_free_ref(struct hard_iface *hard_iface)
 		call_rcu(&hard_iface->rcu, hardif_free_rcu);
 }
 
+static inline struct hard_iface *primary_if_get_selected(
+						struct bat_priv *bat_priv)
+{
+	struct hard_iface *hard_iface;
+
+	rcu_read_lock();
+	hard_iface = rcu_dereference(bat_priv->primary_if);
+	if (!hard_iface)
+		goto out;
+
+	if (!atomic_inc_not_zero(&hard_iface->refcount))
+		hard_iface = NULL;
+
+out:
+	rcu_read_unlock();
+	return hard_iface;
+}
+
 #endif /* _NET_BATMAN_ADV_HARD_INTERFACE_H_ */
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 49079c2..fa22ba2 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -153,6 +153,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 {
 	struct socket_client *socket_client = file->private_data;
 	struct bat_priv *bat_priv = socket_client->bat_priv;
+	struct hard_iface *primary_if = NULL;
 	struct sk_buff *skb;
 	struct icmp_packet_rr *icmp_packet;
 
@@ -167,15 +168,21 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 		return -EINVAL;
 	}
 
-	if (!bat_priv->primary_if)
-		return -EFAULT;
+	primary_if = primary_if_get_selected(bat_priv);
+
+	if (!primary_if) {
+		len = -EFAULT;
+		goto out;
+	}
 
 	if (len >= sizeof(struct icmp_packet_rr))
 		packet_len = sizeof(struct icmp_packet_rr);
 
 	skb = dev_alloc_skb(packet_len + sizeof(struct ethhdr));
-	if (!skb)
-		return -ENOMEM;
+	if (!skb) {
+		len = -ENOMEM;
+		goto out;
+	}
 
 	skb_reserve(skb, sizeof(struct ethhdr));
 	icmp_packet = (struct icmp_packet_rr *)skb_put(skb, packet_len);
@@ -233,7 +240,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 		goto dst_unreach;
 
 	memcpy(icmp_packet->orig,
-	       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	       primary_if->net_dev->dev_addr, ETH_ALEN);
 
 	if (packet_len == sizeof(struct icmp_packet_rr))
 		memcpy(icmp_packet->rr,
@@ -248,6 +255,8 @@ dst_unreach:
 free_skb:
 	kfree_skb(skb);
 out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 	if (neigh_node)
 		neigh_node_free_ref(neigh_node);
 	if (orig_node)
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 5b8fe32..ef4a9be 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -405,29 +405,34 @@ int orig_seq_print_text(struct seq_file *seq, void *offset)
 	struct hashtable_t *hash = bat_priv->orig_hash;
 	struct hlist_node *node, *node_tmp;
 	struct hlist_head *head;
+	struct hard_iface *primary_if;
 	struct orig_node *orig_node;
 	struct neigh_node *neigh_node, *neigh_node_tmp;
 	int batman_count = 0;
 	int last_seen_secs;
 	int last_seen_msecs;
-	int i;
+	int i, ret = 0;
 
-	if ((!bat_priv->primary_if) ||
-	    (bat_priv->primary_if->if_status != IF_ACTIVE)) {
-		if (!bat_priv->primary_if)
-			return seq_printf(seq, "BATMAN mesh %s disabled - "
-				     "please specify interfaces to enable it\n",
-				     net_dev->name);
+	primary_if = primary_if_get_selected(bat_priv);
 
-		return seq_printf(seq, "BATMAN mesh %s "
-				  "disabled - primary interface not active\n",
-				  net_dev->name);
+	if (!primary_if) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
+				 "please specify interfaces to enable it\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	if (primary_if->if_status != IF_ACTIVE) {
+		ret = seq_printf(seq, "BATMAN mesh %s "
+				 "disabled - primary interface not active\n",
+				 net_dev->name);
+		goto out;
 	}
 
 	seq_printf(seq, "[B.A.T.M.A.N. adv %s%s, MainIF/MAC: %s/%pM (%s)]\n",
 		   SOURCE_VERSION, REVISION_VERSION_STR,
-		   bat_priv->primary_if->net_dev->name,
-		   bat_priv->primary_if->net_dev->dev_addr, net_dev->name);
+		   primary_if->net_dev->name,
+		   primary_if->net_dev->dev_addr, net_dev->name);
 	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
 		   "Originator", "last-seen", "#", TQ_MAX_VALUE, "Nexthop",
 		   "outgoingIF", "Potential nexthops");
@@ -474,7 +479,10 @@ next:
 	if (batman_count == 0)
 		seq_printf(seq, "No batman nodes in range ...\n");
 
-	return 0;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
 }
 
 static int orig_node_add_if(struct orig_node *orig_node, int max_if_num)
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 2d77bd3..49f5715 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -904,6 +904,7 @@ int recv_bat_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 			       struct sk_buff *skb, size_t icmp_len)
 {
+	struct hard_iface *primary_if = NULL;
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *router = NULL;
 	struct icmp_packet_rr *icmp_packet;
@@ -917,7 +918,8 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 		goto out;
 	}
 
-	if (!bat_priv->primary_if)
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
 		goto out;
 
 	/* answer echo request (ping) */
@@ -937,8 +939,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	icmp_packet = (struct icmp_packet_rr *)skb->data;
 
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
-	memcpy(icmp_packet->orig,
-		bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	icmp_packet->msg_type = ECHO_REPLY;
 	icmp_packet->ttl = TTL;
 
@@ -946,6 +947,8 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 	ret = NET_RX_SUCCESS;
 
 out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 	if (router)
 		neigh_node_free_ref(router);
 	if (orig_node)
@@ -956,6 +959,7 @@ out:
 static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 				  struct sk_buff *skb)
 {
+	struct hard_iface *primary_if = NULL;
 	struct orig_node *orig_node = NULL;
 	struct neigh_node *router = NULL;
 	struct icmp_packet *icmp_packet;
@@ -971,7 +975,8 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 		goto out;
 	}
 
-	if (!bat_priv->primary_if)
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
 		goto out;
 
 	/* get routing information */
@@ -990,8 +995,7 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	icmp_packet = (struct icmp_packet *)skb->data;
 
 	memcpy(icmp_packet->dst, icmp_packet->orig, ETH_ALEN);
-	memcpy(icmp_packet->orig,
-		bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(icmp_packet->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	icmp_packet->msg_type = TTL_EXCEEDED;
 	icmp_packet->ttl = TTL;
 
@@ -999,6 +1003,8 @@ static int recv_icmp_ttl_exceeded(struct bat_priv *bat_priv,
 	ret = NET_RX_SUCCESS;
 
 out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 	if (router)
 		neigh_node_free_ref(router);
 	if (orig_node)
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 7650e2b..02b541a 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -244,6 +244,7 @@ static void rebuild_batman_packet(struct bat_priv *bat_priv,
 void schedule_own_packet(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	struct hard_iface *primary_if;
 	unsigned long send_time;
 	struct batman_packet *batman_packet;
 	int vis_server;
@@ -253,6 +254,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 		return;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
+	primary_if = primary_if_get_selected(bat_priv);
 
 	/**
 	 * the interface gets activated here to avoid race conditions between
@@ -266,7 +268,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 
 	/* if local hna has changed and interface is a primary interface */
 	if ((atomic_read(&bat_priv->hna_local_changed)) &&
-	    (hard_iface == bat_priv->primary_if))
+	    (hard_iface == primary_if))
 		rebuild_batman_packet(bat_priv, hard_iface);
 
 	/**
@@ -284,7 +286,7 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	else
 		batman_packet->flags &= ~VIS_SERVER;
 
-	if ((hard_iface == bat_priv->primary_if) &&
+	if ((hard_iface == primary_if) &&
 	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_SERVER))
 		batman_packet->gw_flags =
 				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
@@ -299,6 +301,9 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 			       hard_iface->packet_buff,
 			       hard_iface->packet_len,
 			       hard_iface, 1, send_time);
+
+	if (primary_if)
+		hardif_free_ref(primary_if);
 }
 
 void schedule_forward_packet(struct orig_node *orig_node,
@@ -403,6 +408,7 @@ static void _add_bcast_packet_to_list(struct bat_priv *bat_priv,
  * skb is freed. */
 int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb)
 {
+	struct hard_iface *primary_if = NULL;
 	struct forw_packet *forw_packet;
 	struct bcast_packet *bcast_packet;
 
@@ -411,7 +417,8 @@ int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb)
 		goto out;
 	}
 
-	if (!bat_priv->primary_if)
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
 		goto out;
 
 	forw_packet = kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
@@ -430,7 +437,7 @@ int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb)
 	skb_reset_mac_header(skb);
 
 	forw_packet->skb = skb;
-	forw_packet->if_incoming = bat_priv->primary_if;
+	forw_packet->if_incoming = primary_if;
 
 	/* how often did we send the bcast packet ? */
 	forw_packet->num_packets = 0;
@@ -443,6 +450,8 @@ packet_free:
 out_and_inc:
 	atomic_inc(&bat_priv->bcast_queue_left);
 out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 	return NETDEV_TX_BUSY;
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 58ce440..ea5e58c 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -215,13 +215,24 @@ int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 	struct net_device *net_dev = (struct net_device *)seq->private;
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct softif_neigh *softif_neigh;
+	struct hard_iface *primary_if;
 	struct hlist_node *node;
 	struct softif_neigh *curr_softif_neigh;
+	int ret = 0;
 
-	if (!bat_priv->primary_if) {
-		return seq_printf(seq, "BATMAN mesh %s disabled - "
-			       "please specify interfaces to enable it\n",
-			       net_dev->name);
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
+				 "please specify interfaces to enable it\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	if (primary_if->if_status != IF_ACTIVE) {
+		ret = seq_printf(seq, "BATMAN mesh %s "
+				 "disabled - primary interface not active\n",
+				 net_dev->name);
+		goto out;
 	}
 
 	seq_printf(seq, "Softif neighbor list (%s)\n", net_dev->name);
@@ -238,7 +249,10 @@ int softif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 	if (curr_softif_neigh)
 		softif_neigh_free_ref(curr_softif_neigh);
 
-	return 0;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
 }
 
 static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
@@ -247,7 +261,8 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 	struct bat_priv *bat_priv = netdev_priv(dev);
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct batman_packet *batman_packet;
-	struct softif_neigh *softif_neigh;
+	struct softif_neigh *softif_neigh = NULL;
+	struct hard_iface *primary_if = NULL;
 	struct softif_neigh *curr_softif_neigh = NULL;
 
 	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q)
@@ -257,28 +272,34 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 		batman_packet = (struct batman_packet *)(skb->data + ETH_HLEN);
 
 	if (batman_packet->version != COMPAT_VERSION)
-		goto err;
+		goto out;
 
 	if (batman_packet->packet_type != BAT_PACKET)
-		goto err;
+		goto out;
 
 	if (!(batman_packet->flags & PRIMARIES_FIRST_HOP))
-		goto err;
+		goto out;
 
 	if (is_my_mac(batman_packet->orig))
-		goto err;
+		goto out;
 
 	softif_neigh = softif_neigh_get(bat_priv, batman_packet->orig, vid);
-
 	if (!softif_neigh)
-		goto err;
+		goto out;
 
 	curr_softif_neigh = softif_neigh_get_selected(bat_priv);
+	if (!curr_softif_neigh)
+		goto out;
+
 	if (curr_softif_neigh == softif_neigh)
 		goto out;
 
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
 	/* we got a neighbor but its mac is 'bigger' than ours  */
-	if (memcmp(bat_priv->primary_if->net_dev->dev_addr,
+	if (memcmp(primary_if->net_dev->dev_addr,
 		   softif_neigh->addr, ETH_ALEN) < 0)
 		goto out;
 
@@ -300,7 +321,7 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 	/* close own batX device and use softif_neigh as exit node */
 	if ((!curr_softif_neigh) &&
 	    (memcmp(softif_neigh->addr,
-		    bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN) < 0)) {
+		    primary_if->net_dev->dev_addr, ETH_ALEN) < 0)) {
 		bat_dbg(DBG_ROUTES, bat_priv,
 			"Setting mesh exit point to %pM (vid: %d).\n",
 			softif_neigh->addr, softif_neigh->vid);
@@ -310,12 +331,13 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 out:
-	softif_neigh_free_ref(softif_neigh);
-err:
 	kfree_skb(skb);
+	if (softif_neigh)
+		softif_neigh_free_ref(softif_neigh);
 	if (curr_softif_neigh)
 		softif_neigh_free_ref(curr_softif_neigh);
-
+	if (primary_if)
+		hardif_free_ref(primary_if);
 	return;
 }
 
@@ -371,6 +393,7 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 {
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
+	struct hard_iface *primary_if = NULL;
 	struct bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
 	struct softif_neigh *curr_softif_neigh = NULL;
@@ -420,7 +443,8 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 
 	/* ethernet packet should be broadcasted */
 	if (do_bcast) {
-		if (!bat_priv->primary_if)
+		primary_if = primary_if_get_selected(bat_priv);
+		if (!primary_if)
 			goto dropped;
 
 		if (my_skb_head_push(skb, sizeof(struct bcast_packet)) < 0)
@@ -436,7 +460,7 @@ int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		/* hw address of first interface is the orig mac because only
 		 * this mac is known throughout the mesh */
 		memcpy(bcast_packet->orig,
-		       bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+		       primary_if->net_dev->dev_addr, ETH_ALEN);
 
 		/* set broadcast sequence number */
 		bcast_packet->seqno =
@@ -466,6 +490,8 @@ dropped_freed:
 end:
 	if (curr_softif_neigh)
 		softif_neigh_free_ref(curr_softif_neigh);
+	if (primary_if)
+		hardif_free_ref(primary_if);
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 8d15b48..f931830 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -22,6 +22,7 @@
 #include "main.h"
 #include "translation-table.h"
 #include "soft-interface.h"
+#include "hard-interface.h"
 #include "hash.h"
 #include "originator.h"
 
@@ -237,16 +238,26 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct hashtable_t *hash = bat_priv->hna_local_hash;
 	struct hna_local_entry *hna_local_entry;
+	struct hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	size_t buf_size, pos;
 	char *buff;
-	int i;
+	int i, ret = 0;
 
-	if (!bat_priv->primary_if) {
-		return seq_printf(seq, "BATMAN mesh %s disabled - "
-			       "please specify interfaces to enable it\n",
-			       net_dev->name);
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
+				 "please specify interfaces to enable it\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	if (primary_if->if_status != IF_ACTIVE) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
+				 "primary interface not active\n",
+				 net_dev->name);
+		goto out;
 	}
 
 	seq_printf(seq, "Locally retrieved addresses (from %s) "
@@ -269,7 +280,8 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 	buff = kmalloc(buf_size, GFP_ATOMIC);
 	if (!buff) {
 		spin_unlock_bh(&bat_priv->hna_lhash_lock);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out;
 	}
 
 	buff[0] = '\0';
@@ -291,7 +303,10 @@ int hna_local_seq_print_text(struct seq_file *seq, void *offset)
 
 	seq_printf(seq, "%s", buff);
 	kfree(buff);
-	return 0;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
 }
 
 static void _hna_local_del(struct hlist_node *node, void *arg)
@@ -468,16 +483,26 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	struct hashtable_t *hash = bat_priv->hna_global_hash;
 	struct hna_global_entry *hna_global_entry;
+	struct hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	size_t buf_size, pos;
 	char *buff;
-	int i;
+	int i, ret = 0;
 
-	if (!bat_priv->primary_if) {
-		return seq_printf(seq, "BATMAN mesh %s disabled - "
-				  "please specify interfaces to enable it\n",
-				  net_dev->name);
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - please "
+				 "specify interfaces to enable it\n",
+				 net_dev->name);
+		goto out;
+	}
+
+	if (primary_if->if_status != IF_ACTIVE) {
+		ret = seq_printf(seq, "BATMAN mesh %s disabled - "
+				 "primary interface not active\n",
+				 net_dev->name);
+		goto out;
 	}
 
 	seq_printf(seq, "Globally announced HNAs received via the mesh %s\n",
@@ -499,7 +524,8 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 	buff = kmalloc(buf_size, GFP_ATOMIC);
 	if (!buff) {
 		spin_unlock_bh(&bat_priv->hna_ghash_lock);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out;
 	}
 	buff[0] = '\0';
 	pos = 0;
@@ -522,7 +548,10 @@ int hna_global_seq_print_text(struct seq_file *seq, void *offset)
 
 	seq_printf(seq, "%s", buff);
 	kfree(buff);
-	return 0;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
 }
 
 static void _hna_global_del_orig(struct bat_priv *bat_priv,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 75123b1..947bafc 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -149,7 +149,6 @@ struct bat_priv {
 	struct hlist_head softif_neigh_list;
 	struct softif_neigh __rcu *softif_neigh;
 	struct debug_log *debug_log;
-	struct hard_iface *primary_if;
 	struct kobject *mesh_obj;
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
@@ -174,6 +173,7 @@ struct bat_priv {
 	struct delayed_work orig_work;
 	struct delayed_work vis_work;
 	struct gw_node __rcu *curr_gw;  /* rcu protected pointer */
+	struct hard_iface __rcu *primary_if;  /* rcu protected pointer */
 	struct vis_info *my_vis_info;
 };
 
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index d46acc8..b46cbf1 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -221,15 +221,17 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 		  struct hard_iface *hard_iface, uint8_t dstaddr[])
 {
 	struct unicast_packet tmp_uc, *unicast_packet;
+	struct hard_iface *primary_if;
 	struct sk_buff *frag_skb;
 	struct unicast_frag_packet *frag1, *frag2;
 	int uc_hdr_len = sizeof(struct unicast_packet);
 	int ucf_hdr_len = sizeof(struct unicast_frag_packet);
 	int data_len = skb->len - uc_hdr_len;
-	int large_tail = 0;
+	int large_tail = 0, ret = NET_RX_DROP;
 	uint16_t seqno;
 
-	if (!bat_priv->primary_if)
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
 		goto dropped;
 
 	frag_skb = dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
@@ -254,7 +256,7 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	frag1->version = COMPAT_VERSION;
 	frag1->packet_type = BAT_UNICAST_FRAG;
 
-	memcpy(frag1->orig, bat_priv->primary_if->net_dev->dev_addr, ETH_ALEN);
+	memcpy(frag1->orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	memcpy(frag2, frag1, sizeof(struct unicast_frag_packet));
 
 	if (data_len & 1)
@@ -269,13 +271,17 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 
 	send_skb_packet(skb, hard_iface, dstaddr);
 	send_skb_packet(frag_skb, hard_iface, dstaddr);
-	return NET_RX_SUCCESS;
+	ret = NET_RX_SUCCESS;
+	goto out;
 
 drop_frag:
 	kfree_skb(frag_skb);
 dropped:
 	kfree_skb(skb);
-	return NET_RX_DROP;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
 }
 
 int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index d4cc4f5..c8f571d 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -204,6 +204,7 @@ static ssize_t vis_data_read_entry(char *buff, struct vis_info_entry *entry,
 
 int vis_seq_print_text(struct seq_file *seq, void *offset)
 {
+	struct hard_iface *primary_if;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct vis_info *info;
@@ -215,15 +216,18 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 	HLIST_HEAD(vis_if_list);
 	struct if_list_entry *entry;
 	struct hlist_node *pos, *n;
-	int i, j;
+	int i, j, ret = 0;
 	int vis_server = atomic_read(&bat_priv->vis_mode);
 	size_t buff_pos, buf_size;
 	char *buff;
 	int compare;
 
-	if ((!bat_priv->primary_if) ||
-	    (vis_server == VIS_TYPE_CLIENT_UPDATE))
-		return 0;
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	if (vis_server == VIS_TYPE_CLIENT_UPDATE)
+		goto out;
 
 	buf_size = 1;
 	/* Estimate length */
@@ -270,7 +274,8 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 	buff = kmalloc(buf_size, GFP_ATOMIC);
 	if (!buff) {
 		spin_unlock_bh(&bat_priv->vis_hash_lock);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out;
 	}
 	buff[0] = '\0';
 	buff_pos = 0;
@@ -328,7 +333,10 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 	seq_printf(seq, "%s", buff);
 	kfree(buff);
 
-	return 0;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return ret;
 }
 
 /* add the info packet to the send list, if it was not
@@ -815,16 +823,20 @@ out:
 /* only send one vis packet. called from send_vis_packets() */
 static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
 {
+	struct hard_iface *primary_if;
 	struct vis_packet *packet;
 
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
 	packet = (struct vis_packet *)info->skb_packet->data;
 	if (packet->ttl < 2) {
 		pr_debug("Error - can't send vis packet: ttl exceeded\n");
-		return;
+		goto out;
 	}
 
-	memcpy(packet->sender_orig, bat_priv->primary_if->net_dev->dev_addr,
-	       ETH_ALEN);
+	memcpy(packet->sender_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
 	packet->ttl--;
 
 	if (is_broadcast_ether_addr(packet->target_orig))
@@ -832,6 +844,10 @@ static void send_vis_packet(struct bat_priv *bat_priv, struct vis_info *info)
 	else
 		unicast_vis_packet(bat_priv, info);
 	packet->ttl++; /* restore TTL */
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
 }
 
 /* called from timer; send (and maybe generate) vis packet. */
@@ -858,8 +874,7 @@ static void send_vis_packets(struct work_struct *work)
 		kref_get(&info->refcount);
 		spin_unlock_bh(&bat_priv->vis_hash_lock);
 
-		if (bat_priv->primary_if)
-			send_vis_packet(bat_priv, info);
+		send_vis_packet(bat_priv, info);
 
 		spin_lock_bh(&bat_priv->vis_hash_lock);
 		send_list_del(info);
-- 
1.7.4.4
