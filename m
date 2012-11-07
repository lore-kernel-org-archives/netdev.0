From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/12] batman-adv: Distributed ARP Table - implement local storage
Date: Wed,  7 Nov 2012 20:11:36 +0100
Message-ID: <1352315502-20324-7-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44661 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334Ab2KGTMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:35 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since batman-adv cannot inter-operate with the host ARP table, this patch
introduces a batman-adv private storage for ARP entries exchanged within DAT.
This storage will represent the node local cache in the DAT protocol.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/debugfs.c               |  15 ++
 net/batman-adv/distributed-arp-table.c | 296 +++++++++++++++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h |   4 +
 net/batman-adv/main.c                  |   7 +
 net/batman-adv/main.h                  |   1 +
 net/batman-adv/types.h                 |  23 +++
 6 files changed, 346 insertions(+)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index bd032bc..ebc5f4d 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -31,6 +31,7 @@
 #include "vis.h"
 #include "icmp_socket.h"
 #include "bridge_loop_avoidance.h"
+#include "distributed-arp-table.h"
 
 static struct dentry *batadv_debugfs;
 
@@ -280,6 +281,18 @@ static int batadv_bla_backbone_table_open(struct inode *inode,
 
 #endif
 
+/**
+ * batadv_dat_cache_open - Prepare file handler for reads from dat_chache
+ * @inode: inode which was opened
+ * @file: file handle to be initialized
+ */
+static int batadv_dat_cache_open(struct inode *inode, struct file *file)
+{
+	struct net_device *net_dev = (struct net_device *)inode->i_private;
+	return single_open(file, batadv_dat_cache_seq_print_text, net_dev);
+}
+
+
 static int batadv_transtable_local_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
@@ -319,6 +332,7 @@ static BATADV_DEBUGINFO(bla_claim_table, S_IRUGO, batadv_bla_claim_table_open);
 static BATADV_DEBUGINFO(bla_backbone_table, S_IRUGO,
 			batadv_bla_backbone_table_open);
 #endif
+static BATADV_DEBUGINFO(dat_cache, S_IRUGO, batadv_dat_cache_open);
 static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
 			batadv_transtable_local_open);
 static BATADV_DEBUGINFO(vis_data, S_IRUGO, batadv_vis_data_open);
@@ -331,6 +345,7 @@ static struct batadv_debuginfo *batadv_mesh_debuginfos[] = {
 	&batadv_debuginfo_bla_claim_table,
 	&batadv_debuginfo_bla_backbone_table,
 #endif
+	&batadv_debuginfo_dat_cache,
 	&batadv_debuginfo_transtable_local,
 	&batadv_debuginfo_vis_data,
 	NULL,
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index ce39e8a..2ef90e3 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -28,6 +28,119 @@
 #include "types.h"
 #include "unicast.h"
 
+static void batadv_dat_purge(struct work_struct *work);
+
+/**
+ * batadv_dat_start_timer - initialise the DAT periodic worker
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_dat_start_timer(struct batadv_priv *bat_priv)
+{
+	INIT_DELAYED_WORK(&bat_priv->dat.work, batadv_dat_purge);
+	queue_delayed_work(batadv_event_workqueue, &bat_priv->dat.work,
+			   msecs_to_jiffies(10000));
+}
+
+/**
+ * batadv_dat_entry_free_ref - decrements the dat_entry refcounter and possibly
+ * free it
+ * @dat_entry: the oentry to free
+ */
+static void batadv_dat_entry_free_ref(struct batadv_dat_entry *dat_entry)
+{
+	if (atomic_dec_and_test(&dat_entry->refcount))
+		kfree_rcu(dat_entry, rcu);
+}
+
+/**
+ * batadv_dat_to_purge - checks whether a dat_entry has to be purged or not
+ * @dat_entry: the entry to check
+ *
+ * Returns true if the entry has to be purged now, false otherwise
+ */
+static bool batadv_dat_to_purge(struct batadv_dat_entry *dat_entry)
+{
+	return batadv_has_timed_out(dat_entry->last_update,
+				    BATADV_DAT_ENTRY_TIMEOUT);
+}
+
+/**
+ * __batadv_dat_purge - delete entries from the DAT local storage
+ * @bat_priv: the bat priv with all the soft interface information
+ * @to_purge: function in charge to decide whether an entry has to be purged or
+ *	      not. This function takes the dat_entry as argument and has to
+ *	      returns a boolean value: true is the entry has to be deleted,
+ *	      false otherwise
+ *
+ * Loops over each entry in the DAT local storage and delete it if and only if
+ * the to_purge function passed as argument returns true
+ */
+static void __batadv_dat_purge(struct batadv_priv *bat_priv,
+			       bool (*to_purge)(struct batadv_dat_entry *))
+{
+	spinlock_t *list_lock; /* protects write access to the hash lists */
+	struct batadv_dat_entry *dat_entry;
+	struct hlist_node *node, *node_tmp;
+	struct hlist_head *head;
+	uint32_t i;
+
+	if (!bat_priv->dat.hash)
+		return;
+
+	for (i = 0; i < bat_priv->dat.hash->size; i++) {
+		head = &bat_priv->dat.hash->table[i];
+		list_lock = &bat_priv->dat.hash->list_locks[i];
+
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(dat_entry, node, node_tmp, head,
+					  hash_entry) {
+			/* if an helper function has been passed as parameter,
+			 * ask it if the entry has to be purged or not
+			 */
+			if (to_purge && !to_purge(dat_entry))
+				continue;
+
+			hlist_del_rcu(node);
+			batadv_dat_entry_free_ref(dat_entry);
+		}
+		spin_unlock_bh(list_lock);
+	}
+}
+
+/**
+ * batadv_dat_purge - periodic task that deletes old entries from the local DAT
+ * hash table
+ * @work: kernel work struct
+ */
+static void batadv_dat_purge(struct work_struct *work)
+{
+	struct delayed_work *delayed_work;
+	struct batadv_priv_dat *priv_dat;
+	struct batadv_priv *bat_priv;
+
+	delayed_work = container_of(work, struct delayed_work, work);
+	priv_dat = container_of(delayed_work, struct batadv_priv_dat, work);
+	bat_priv = container_of(priv_dat, struct batadv_priv, dat);
+
+	__batadv_dat_purge(bat_priv, batadv_dat_to_purge);
+	batadv_dat_start_timer(bat_priv);
+}
+
+/**
+ * batadv_compare_dat - comparing function used in the local DAT hash table
+ * @node: node in the local table
+ * @data2: second object to compare the node to
+ *
+ * Returns 1 if the two entry are the same, 0 otherwise
+ */
+static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
+{
+	const void *data1 = container_of(node, struct batadv_dat_entry,
+					 hash_entry);
+
+	return (memcmp(data1, data2, sizeof(__be32)) == 0 ? 1 : 0);
+}
+
 /**
  * batadv_hash_dat - compute the hash value for an IP address
  * @data: data to hash
@@ -55,6 +168,96 @@ static uint32_t batadv_hash_dat(const void *data, uint32_t size)
 }
 
 /**
+ * batadv_dat_entry_hash_find - looks for a given dat_entry in the local hash
+ * table
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ip: search key
+ *
+ * Returns the dat_entry if found, NULL otherwise
+ */
+static struct batadv_dat_entry *
+batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip)
+{
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct batadv_dat_entry *dat_entry, *dat_entry_tmp = NULL;
+	struct batadv_hashtable *hash = bat_priv->dat.hash;
+	uint32_t index;
+
+	if (!hash)
+		return NULL;
+
+	index = batadv_hash_dat(&ip, hash->size);
+	head = &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(dat_entry, node, head, hash_entry) {
+		if (dat_entry->ip != ip)
+			continue;
+
+		if (!atomic_inc_not_zero(&dat_entry->refcount))
+			continue;
+
+		dat_entry_tmp = dat_entry;
+		break;
+	}
+	rcu_read_unlock();
+
+	return dat_entry_tmp;
+}
+
+/**
+ * batadv_dat_entry_add - add a new dat entry or update it if already exists
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ip: ipv4 to add/edit
+ * @mac_addr: mac address to assign to the given ipv4
+ */
+static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
+				 uint8_t *mac_addr)
+{
+	struct batadv_dat_entry *dat_entry;
+	int hash_added;
+
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip);
+	/* if this entry is already known, just update it */
+	if (dat_entry) {
+		if (!batadv_compare_eth(dat_entry->mac_addr, mac_addr))
+			memcpy(dat_entry->mac_addr, mac_addr, ETH_ALEN);
+		dat_entry->last_update = jiffies;
+		batadv_dbg(BATADV_DBG_DAT, bat_priv,
+			   "Entry updated: %pI4 %pM\n", &dat_entry->ip,
+			   dat_entry->mac_addr);
+		goto out;
+	}
+
+	dat_entry = kmalloc(sizeof(*dat_entry), GFP_ATOMIC);
+	if (!dat_entry)
+		goto out;
+
+	dat_entry->ip = ip;
+	memcpy(dat_entry->mac_addr, mac_addr, ETH_ALEN);
+	dat_entry->last_update = jiffies;
+	atomic_set(&dat_entry->refcount, 2);
+
+	hash_added = batadv_hash_add(bat_priv->dat.hash, batadv_compare_dat,
+				     batadv_hash_dat, &dat_entry->ip,
+				     &dat_entry->hash_entry);
+
+	if (unlikely(hash_added != 0)) {
+		/* remove the reference for the hash */
+		batadv_dat_entry_free_ref(dat_entry);
+		goto out;
+	}
+
+	batadv_dbg(BATADV_DBG_DAT, bat_priv, "New entry added: %pI4 %pM\n",
+		   &dat_entry->ip, dat_entry->mac_addr);
+
+out:
+	if (dat_entry)
+		batadv_dat_entry_free_ref(dat_entry);
+}
+
+/**
  * batadv_is_orig_node_eligible - check whether a node can be a DHT candidate
  * @res: the array with the already selected candidates
  * @select: number of already selected candidates
@@ -268,3 +471,96 @@ out:
 	kfree(cand);
 	return ret;
 }
+
+/**
+ * batadv_dat_hash_free - free the local DAT hash table
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+static void batadv_dat_hash_free(struct batadv_priv *bat_priv)
+{
+	__batadv_dat_purge(bat_priv, NULL);
+
+	batadv_hash_destroy(bat_priv->dat.hash);
+
+	bat_priv->dat.hash = NULL;
+}
+
+/**
+ * batadv_dat_init - initialise the DAT internals
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+int batadv_dat_init(struct batadv_priv *bat_priv)
+{
+	if (bat_priv->dat.hash)
+		return 0;
+
+	bat_priv->dat.hash = batadv_hash_new(1024);
+
+	if (!bat_priv->dat.hash)
+		return -ENOMEM;
+
+	batadv_dat_start_timer(bat_priv);
+
+	return 0;
+}
+
+/**
+ * batadv_dat_free - free the DAT internals
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_dat_free(struct batadv_priv *bat_priv)
+{
+	cancel_delayed_work_sync(&bat_priv->dat.work);
+
+	batadv_dat_hash_free(bat_priv);
+}
+
+/**
+ * batadv_dat_cache_seq_print_text - print the local DAT hash table
+ * @seq: seq file to print on
+ * @offset: not used
+ */
+int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
+{
+	struct net_device *net_dev = (struct net_device *)seq->private;
+	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+	struct batadv_hashtable *hash = bat_priv->dat.hash;
+	struct batadv_dat_entry *dat_entry;
+	struct batadv_hard_iface *primary_if;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	unsigned long last_seen_jiffies;
+	int last_seen_msecs, last_seen_secs, last_seen_mins;
+	uint32_t i;
+
+	primary_if = batadv_seq_print_text_primary_if_get(seq);
+	if (!primary_if)
+		goto out;
+
+	seq_printf(seq, "Distributed ARP Table (%s):\n", net_dev->name);
+	seq_printf(seq, "          %-7s          %-13s %5s\n", "IPv4", "MAC",
+		   "last-seen");
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(dat_entry, node, head, hash_entry) {
+			last_seen_jiffies = jiffies - dat_entry->last_update;
+			last_seen_msecs = jiffies_to_msecs(last_seen_jiffies);
+			last_seen_mins = last_seen_msecs / 60000;
+			last_seen_msecs = last_seen_msecs % 60000;
+			last_seen_secs = last_seen_msecs / 1000;
+
+			seq_printf(seq, " * %15pI4 %14pM %6i:%02i\n",
+				   &dat_entry->ip, dat_entry->mac_addr,
+				   last_seen_mins, last_seen_secs);
+		}
+		rcu_read_unlock();
+	}
+
+out:
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+	return 0;
+}
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index ea9cbd8..1b88303 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -55,4 +55,8 @@ batadv_dat_init_own_addr(struct batadv_priv *bat_priv,
 	bat_priv->dat.addr = (batadv_dat_addr_t)addr;
 }
 
+int batadv_dat_init(struct batadv_priv *bat_priv);
+void batadv_dat_free(struct batadv_priv *bat_priv);
+int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset);
+
 #endif /* _NET_BATMAN_ADV_ARP_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index afc07a8..dc33a0c 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -29,6 +29,7 @@
 #include "hard-interface.h"
 #include "gateway_client.h"
 #include "bridge_loop_avoidance.h"
+#include "distributed-arp-table.h"
 #include "vis.h"
 #include "hash.h"
 #include "bat_algo.h"
@@ -128,6 +129,10 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	if (ret < 0)
 		goto err;
 
+	ret = batadv_dat_init(bat_priv);
+	if (ret < 0)
+		goto err;
+
 	atomic_set(&bat_priv->gw.reselect, 0);
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_ACTIVE);
 
@@ -155,6 +160,8 @@ void batadv_mesh_free(struct net_device *soft_iface)
 
 	batadv_bla_free(bat_priv);
 
+	batadv_dat_free(bat_priv);
+
 	free_percpu(bat_priv->bat_counters);
 
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_INACTIVE);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 5699f2b..25adfd2 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -44,6 +44,7 @@
 #define BATADV_TT_LOCAL_TIMEOUT 3600000 /* in milliseconds */
 #define BATADV_TT_CLIENT_ROAM_TIMEOUT 600000 /* in milliseconds */
 #define BATADV_TT_CLIENT_TEMP_TIMEOUT 600000 /* in milliseconds */
+#define BATADV_DAT_ENTRY_TIMEOUT (5*60000) /* 5 mins in milliseconds */
 /* sliding packet range of received originator messages in sequence numbers
  * (should be a multiple of our word size)
  */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b57d93b..9ed1bb2 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -249,9 +249,13 @@ struct batadv_priv_vis {
 /**
  * struct batadv_priv_dat - per mesh interface DAT private data
  * @addr: node DAT address
+ * @hash: hashtable representing the local ARP cache
+ * @work: work queue callback item for cache purging
  */
 struct batadv_priv_dat {
 	batadv_dat_addr_t addr;
+	struct batadv_hashtable *hash;
+	struct delayed_work work;
 };
 
 struct batadv_priv {
@@ -465,6 +469,25 @@ struct batadv_algo_ops {
 };
 
 /**
+ * struct batadv_dat_entry - it is a single entry of batman-adv ARP backend. It
+ * is used to stored ARP entries needed for the global DAT cache
+ * @ip: the IPv4 corresponding to this DAT/ARP entry
+ * @mac_addr: the MAC address associated to the stored IPv4
+ * @last_update: time in jiffies when this entry was refreshed last time
+ * @hash_entry: hlist node for batadv_priv_dat::hash
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
+struct batadv_dat_entry {
+	__be32 ip;
+	uint8_t mac_addr[ETH_ALEN];
+	unsigned long last_update;
+	struct hlist_node hash_entry;
+	atomic_t refcount;
+	struct rcu_head rcu;
+};
+
+/**
  * struct batadv_dat_candidate - candidate destination for DAT operations
  * @type: the type of the selected candidate. It can one of the following:
  *	  - BATADV_DAT_CANDIDATE_NOT_FOUND
-- 
1.8.0
