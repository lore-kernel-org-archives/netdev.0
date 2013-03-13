From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 6/9] batman-adv: network coding - buffer unicast packets before forward
Date: Wed, 13 Mar 2013 23:56:36 +0100
Message-ID: <1363215399-18875-7-git-send-email-ordex@autistici.org>
References: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:20172 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934396Ab3CMW6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:58:04 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Two be able to network code two packets, one packet must be buffered
until the next is available. This is done in a "coding buffer", which i=
s
essentially a hash table with lists of packets. Each entry in the hash
table corresponds to a specific src-dst pair, which has a linked list o=
f
packets that are buffered.

This patch adds skbs to the buffer just before forwarding them. The
buffer is traversed every 10 ms, where timed skbs are removed from the
buffer and transmitted. To allow experiments with the network coding
scheme, the timeout is tunable through a file in debugfs.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/network-coding.c | 487 ++++++++++++++++++++++++++++++++=
++++++++
 net/batman-adv/network-coding.h |  10 +
 net/batman-adv/routing.c        |  18 +-
 net/batman-adv/types.h          |  49 ++++
 4 files changed, 557 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index ff4985d..2c38c54 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -20,10 +20,14 @@
 #include <linux/debugfs.h>
=20
 #include "main.h"
+#include "hash.h"
 #include "network-coding.h"
+#include "send.h"
 #include "originator.h"
 #include "hard-interface.h"
=20
+static struct lock_class_key batadv_nc_coding_hash_lock_class_key;
+
 static void batadv_nc_worker(struct work_struct *work);
=20
 /**
@@ -42,10 +46,25 @@ static void batadv_nc_start_timer(struct batadv_pri=
v *bat_priv)
  */
 int batadv_nc_init(struct batadv_priv *bat_priv)
 {
+	bat_priv->nc.timestamp_fwd_flush =3D jiffies;
+
+	if (bat_priv->nc.coding_hash)
+		return 0;
+
+	bat_priv->nc.coding_hash =3D batadv_hash_new(128);
+	if (!bat_priv->nc.coding_hash)
+		goto err;
+
+	batadv_hash_set_lock_class(bat_priv->nc.coding_hash,
+				   &batadv_nc_coding_hash_lock_class_key);
+
 	INIT_DELAYED_WORK(&bat_priv->nc.work, batadv_nc_worker);
 	batadv_nc_start_timer(bat_priv);
=20
 	return 0;
+
+err:
+	return -ENOMEM;
 }
=20
 /**
@@ -56,6 +75,7 @@ void batadv_nc_init_bat_priv(struct batadv_priv *bat_=
priv)
 {
 	atomic_set(&bat_priv->network_coding, 1);
 	bat_priv->nc.min_tq =3D 200;
+	bat_priv->nc.max_fwd_delay =3D 10;
 }
=20
 /**
@@ -96,6 +116,30 @@ static void batadv_nc_node_free_ref(struct batadv_n=
c_node *nc_node)
 }
=20
 /**
+ * batadv_nc_path_free_ref - decrements the nc path refcounter and pos=
sibly
+ * frees it
+ * @nc_path: the nc node to free
+ */
+static void batadv_nc_path_free_ref(struct batadv_nc_path *nc_path)
+{
+	if (atomic_dec_and_test(&nc_path->refcount))
+		kfree_rcu(nc_path, rcu);
+}
+
+/**
+ * batadv_nc_packet_free - frees nc packet
+ * @nc_packet: the nc packet to free
+ */
+static void batadv_nc_packet_free(struct batadv_nc_packet *nc_packet)
+{
+	if (nc_packet->skb)
+		kfree_skb(nc_packet->skb);
+
+	batadv_nc_path_free_ref(nc_packet->nc_path);
+	kfree(nc_packet);
+}
+
+/**
  * batadv_nc_to_purge_nc_node - checks whether an nc node has to be pu=
rged
  * @bat_priv: the bat priv with all the soft interface information
  * @nc_node: the nc node to check
@@ -112,6 +156,26 @@ static bool batadv_nc_to_purge_nc_node(struct bata=
dv_priv *bat_priv,
 }
=20
 /**
+ * batadv_nc_to_purge_nc_path_coding - checks whether an nc path has t=
imed out
+ * @bat_priv: the bat priv with all the soft interface information
+ * @nc_path: the nc path to check
+ *
+ * Returns true if the entry has to be purged now, false otherwise
+ */
+static bool batadv_nc_to_purge_nc_path_coding(struct batadv_priv *bat_=
priv,
+					      struct batadv_nc_path *nc_path)
+{
+	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
+		return true;
+
+	/* purge the path when no packets has been added for 10 times the
+	 * max_fwd_delay time
+	 */
+	return batadv_has_timed_out(nc_path->last_valid,
+				    bat_priv->nc.max_fwd_delay * 10);
+}
+
+/**
  * batadv_nc_purge_orig_nc_nodes - go through list of nc nodes and pur=
ge stale
  *  entries
  * @bat_priv: the bat priv with all the soft interface information
@@ -203,6 +267,262 @@ static void batadv_nc_purge_orig_hash(struct bata=
dv_priv *bat_priv)
 }
=20
 /**
+ * batadv_nc_purge_paths - traverse all nc paths part of the hash and =
remove
+ *  unused ones
+ * @bat_priv: the bat priv with all the soft interface information
+ * @hash: hash table containing the nc paths to check
+ * @to_purge: function in charge to decide whether an entry has to be =
purged or
+ *	      not. This function takes the nc node as argument and has to r=
eturn
+ *	      a boolean value: true is the entry has to be deleted, false
+ *	      otherwise
+ */
+static void batadv_nc_purge_paths(struct batadv_priv *bat_priv,
+				  struct batadv_hashtable *hash,
+				  bool (*to_purge)(struct batadv_priv *,
+						   struct batadv_nc_path *))
+{
+	struct hlist_head *head;
+	struct hlist_node *node_tmp;
+	struct batadv_nc_path *nc_path;
+	spinlock_t *lock; /* Protects lists in hash */
+	uint32_t i;
+
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+		lock =3D &hash->list_locks[i];
+
+		/* For each nc_path in this bin */
+		spin_lock_bh(lock);
+		hlist_for_each_entry_safe(nc_path, node_tmp, head, hash_entry) {
+			/* if an helper function has been passed as parameter,
+			 * ask it if the entry has to be purged or not
+			 */
+			if (to_purge && !to_purge(bat_priv, nc_path))
+				continue;
+
+			/* purging an non-empty nc_path should never happen, but
+			 * is observed under high CPU load. Delay the purging
+			 * until next iteration to allow the packet_list to be
+			 * emptied first.
+			 */
+			if (!unlikely(list_empty(&nc_path->packet_list))) {
+				net_ratelimited_function(printk,
+							 KERN_WARNING
+							 "Skipping free of non-empty nc_path (%pM -> %pM)!\n",
+							 nc_path->prev_hop,
+							 nc_path->next_hop);
+				continue;
+			}
+
+			/* nc_path is unused, so remove it */
+			batadv_dbg(BATADV_DBG_NC, bat_priv,
+				   "Remove nc_path %pM -> %pM\n",
+				   nc_path->prev_hop, nc_path->next_hop);
+			hlist_del_rcu(&nc_path->hash_entry);
+			batadv_nc_path_free_ref(nc_path);
+		}
+		spin_unlock_bh(lock);
+	}
+}
+
+/**
+ * batadv_nc_hash_key_gen - computes the nc_path hash key
+ * @key: buffer to hold the final hash key
+ * @src: source ethernet mac address going into the hash key
+ * @dst: destination ethernet mac address going into the hash key
+ */
+static void batadv_nc_hash_key_gen(struct batadv_nc_path *key, const c=
har *src,
+				   const char *dst)
+{
+	memcpy(key->prev_hop, src, sizeof(key->prev_hop));
+	memcpy(key->next_hop, dst, sizeof(key->next_hop));
+}
+
+/**
+ * batadv_nc_hash_choose - compute the hash value for an nc path
+ * @data: data to hash
+ * @size: size of the hash table
+ *
+ * Returns the selected index in the hash table for the given data.
+ */
+static uint32_t batadv_nc_hash_choose(const void *data, uint32_t size)
+{
+	const struct batadv_nc_path *nc_path =3D data;
+	uint32_t hash =3D 0;
+
+	hash =3D batadv_hash_bytes(hash, &nc_path->prev_hop,
+				 sizeof(nc_path->prev_hop));
+	hash =3D batadv_hash_bytes(hash, &nc_path->next_hop,
+				 sizeof(nc_path->next_hop));
+
+	hash +=3D (hash << 3);
+	hash ^=3D (hash >> 11);
+	hash +=3D (hash << 15);
+
+	return hash % size;
+}
+
+/**
+ * batadv_nc_hash_compare - comparing function used in the network cod=
ing hash
+ *  tables
+ * @node: node in the local table
+ * @data2: second object to compare the node to
+ *
+ * Returns 1 if the two entry are the same, 0 otherwise
+ */
+static int batadv_nc_hash_compare(const struct hlist_node *node,
+				  const void *data2)
+{
+	const struct batadv_nc_path *nc_path1, *nc_path2;
+
+	nc_path1 =3D container_of(node, struct batadv_nc_path, hash_entry);
+	nc_path2 =3D data2;
+
+	/* Return 1 if the two keys are identical */
+	if (memcmp(nc_path1->prev_hop, nc_path2->prev_hop,
+		   sizeof(nc_path1->prev_hop)) !=3D 0)
+		return 0;
+
+	if (memcmp(nc_path1->next_hop, nc_path2->next_hop,
+		   sizeof(nc_path1->next_hop)) !=3D 0)
+		return 0;
+
+	return 1;
+}
+
+/**
+ * batadv_nc_hash_find - search for an existing nc path and return it
+ * @hash: hash table containing the nc path
+ * @data: search key
+ *
+ * Returns the nc_path if found, NULL otherwise.
+ */
+static struct batadv_nc_path *
+batadv_nc_hash_find(struct batadv_hashtable *hash,
+		    void *data)
+{
+	struct hlist_head *head;
+	struct batadv_nc_path *nc_path, *nc_path_tmp =3D NULL;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	index =3D batadv_nc_hash_choose(data, hash->size);
+	head =3D &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(nc_path, head, hash_entry) {
+		if (!batadv_nc_hash_compare(&nc_path->hash_entry, data))
+			continue;
+
+		if (!atomic_inc_not_zero(&nc_path->refcount))
+			continue;
+
+		nc_path_tmp =3D nc_path;
+		break;
+	}
+	rcu_read_unlock();
+
+	return nc_path_tmp;
+}
+
+/**
+ * batadv_nc_send_packet - send non-coded packet and free nc_packet st=
ruct
+ * @nc_packet: the nc packet to send
+ */
+static void batadv_nc_send_packet(struct batadv_nc_packet *nc_packet)
+{
+	batadv_send_skb_packet(nc_packet->skb,
+			       nc_packet->neigh_node->if_incoming,
+			       nc_packet->nc_path->next_hop);
+	nc_packet->skb =3D NULL;
+	batadv_nc_packet_free(nc_packet);
+}
+
+/**
+ * batadv_nc_fwd_flush - Checks the timestamp of the given nc packet.
+ * @bat_priv: the bat priv with all the soft interface information
+ * @nc_path: the nc path the packet belongs to
+ * @nc_packet: the nc packet to be checked
+ *
+ * Checks whether the given nc packet has hit its forward timeout. If =
so, the
+ * packet is no longer delayed, immediately sent and the entry deleted=
 from the
+ * queue. Has to be called with the appropriate locks.
+ *
+ * Returns false as soon as the entry in the fifo queue has not been t=
imed out
+ * yet and true otherwise.
+ */
+static bool batadv_nc_fwd_flush(struct batadv_priv *bat_priv,
+				struct batadv_nc_path *nc_path,
+				struct batadv_nc_packet *nc_packet)
+{
+	unsigned long timeout =3D bat_priv->nc.max_fwd_delay;
+
+	/* Packets are added to tail, so the remaining packets did not time
+	 * out and we can stop processing the current queue
+	 */
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D BATADV_MESH_ACTIVE &&
+	    !batadv_has_timed_out(nc_packet->timestamp, timeout))
+		return false;
+
+	/* Send packet */
+	batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
+	batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
+			   nc_packet->skb->len + ETH_HLEN);
+	list_del(&nc_packet->list);
+	batadv_nc_send_packet(nc_packet);
+
+	return true;
+}
+
+/**
+ * batadv_nc_process_nc_paths - traverse given nc packet pool and free=
 timed out
+ *  nc packets
+ * @bat_priv: the bat priv with all the soft interface information
+ * @hash: to be processed hash table
+ * @process_fn: Function called to process given nc packet. Should ret=
urn true
+ *	        to encourage this function to proceed with the next packet.
+ *	        Otherwise the rest of the current queue is skipped.
+ */
+static void
+batadv_nc_process_nc_paths(struct batadv_priv *bat_priv,
+			   struct batadv_hashtable *hash,
+			   bool (*process_fn)(struct batadv_priv *,
+					      struct batadv_nc_path *,
+					      struct batadv_nc_packet *))
+{
+	struct hlist_head *head;
+	struct batadv_nc_packet *nc_packet, *nc_packet_tmp;
+	struct batadv_nc_path *nc_path;
+	bool ret;
+	int i;
+
+	if (!hash)
+		return;
+
+	/* Loop hash table bins */
+	for (i =3D 0; i < hash->size; i++) {
+		head =3D &hash->table[i];
+
+		/* Loop coding paths */
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(nc_path, head, hash_entry) {
+			/* Loop packets */
+			spin_lock_bh(&nc_path->packet_list_lock);
+			list_for_each_entry_safe(nc_packet, nc_packet_tmp,
+						 &nc_path->packet_list, list) {
+				ret =3D process_fn(bat_priv, nc_path, nc_packet);
+				if (!ret)
+					break;
+			}
+			spin_unlock_bh(&nc_path->packet_list_lock);
+		}
+		rcu_read_unlock();
+	}
+}
+
+/**
  * batadv_nc_worker - periodic task for house keeping related to netwo=
rk coding
  * @work: kernel work struct
  */
@@ -211,12 +531,23 @@ static void batadv_nc_worker(struct work_struct *=
work)
 	struct delayed_work *delayed_work;
 	struct batadv_priv_nc *priv_nc;
 	struct batadv_priv *bat_priv;
+	unsigned long timeout;
=20
 	delayed_work =3D container_of(work, struct delayed_work, work);
 	priv_nc =3D container_of(delayed_work, struct batadv_priv_nc, work);
 	bat_priv =3D container_of(priv_nc, struct batadv_priv, nc);
=20
 	batadv_nc_purge_orig_hash(bat_priv);
+	batadv_nc_purge_paths(bat_priv, bat_priv->nc.coding_hash,
+			      batadv_nc_to_purge_nc_path_coding);
+
+	timeout =3D bat_priv->nc.max_fwd_delay;
+
+	if (batadv_has_timed_out(bat_priv->nc.timestamp_fwd_flush, timeout)) =
{
+		batadv_nc_process_nc_paths(bat_priv, bat_priv->nc.coding_hash,
+					   batadv_nc_fwd_flush);
+		bat_priv->nc.timestamp_fwd_flush =3D jiffies;
+	}
=20
 	/* Schedule a new check */
 	batadv_nc_start_timer(bat_priv);
@@ -407,12 +738,163 @@ out:
 }
=20
 /**
+ * batadv_nc_get_path - get existing nc_path or allocate a new one
+ * @bat_priv: the bat priv with all the soft interface information
+ * @hash: hash table containing the nc path
+ * @src: ethernet source address - first half of the nc path search ke=
y
+ * @dst: ethernet destination address - second half of the nc path sea=
rch key
+ *
+ * Returns pointer to nc_path if the path was found or created, return=
s NULL
+ * on error.
+ */
+static struct batadv_nc_path *batadv_nc_get_path(struct batadv_priv *b=
at_priv,
+						 struct batadv_hashtable *hash,
+						 uint8_t *src,
+						 uint8_t *dst)
+{
+	int hash_added;
+	struct batadv_nc_path *nc_path, nc_path_key;
+
+	batadv_nc_hash_key_gen(&nc_path_key, src, dst);
+
+	/* Search for existing nc_path */
+	nc_path =3D batadv_nc_hash_find(hash, (void *)&nc_path_key);
+
+	if (nc_path) {
+		/* Set timestamp to delay removal of nc_path */
+		nc_path->last_valid =3D jiffies;
+		return nc_path;
+	}
+
+	/* No existing nc_path was found; create a new */
+	nc_path =3D kzalloc(sizeof(*nc_path), GFP_ATOMIC);
+
+	if (!nc_path)
+		return NULL;
+
+	/* Initialize nc_path */
+	INIT_LIST_HEAD(&nc_path->packet_list);
+	spin_lock_init(&nc_path->packet_list_lock);
+	atomic_set(&nc_path->refcount, 2);
+	nc_path->last_valid =3D jiffies;
+	memcpy(nc_path->next_hop, dst, ETH_ALEN);
+	memcpy(nc_path->prev_hop, src, ETH_ALEN);
+
+	batadv_dbg(BATADV_DBG_NC, bat_priv, "Adding nc_path %pM -> %pM\n",
+		   nc_path->prev_hop,
+		   nc_path->next_hop);
+
+	/* Add nc_path to hash table */
+	hash_added =3D batadv_hash_add(hash, batadv_nc_hash_compare,
+				     batadv_nc_hash_choose, &nc_path_key,
+				     &nc_path->hash_entry);
+
+	if (hash_added < 0) {
+		kfree(nc_path);
+		return NULL;
+	}
+
+	return nc_path;
+}
+
+/**
+ * batadv_nc_skb_add_to_path - buffer skb for later encoding / decodin=
g
+ * @skb: skb to add to path
+ * @nc_path: path to add skb to
+ * @neigh_node: next hop to forward packet to
+ * @packet_id: checksum to identify packet
+ *
+ * Returns true if the packet was buffered or false in case of an erro=
r.
+ */
+static bool batadv_nc_skb_add_to_path(struct sk_buff *skb,
+				      struct batadv_nc_path *nc_path,
+				      struct batadv_neigh_node *neigh_node,
+				      __be32 packet_id)
+{
+	struct batadv_nc_packet *nc_packet;
+
+	nc_packet =3D kzalloc(sizeof(*nc_packet), GFP_ATOMIC);
+	if (!nc_packet)
+		return false;
+
+	/* Initialize nc_packet */
+	nc_packet->timestamp =3D jiffies;
+	nc_packet->packet_id =3D packet_id;
+	nc_packet->skb =3D skb;
+	nc_packet->neigh_node =3D neigh_node;
+	nc_packet->nc_path =3D nc_path;
+
+	/* Add coding packet to list */
+	spin_lock_bh(&nc_path->packet_list_lock);
+	list_add_tail(&nc_packet->list, &nc_path->packet_list);
+	spin_unlock_bh(&nc_path->packet_list_lock);
+
+	return true;
+}
+
+/**
+ * batadv_nc_skb_forward - try to code a packet or add it to the codin=
g packet
+ *  buffer
+ * @skb: data skb to forward
+ * @neigh_node: next hop to forward packet to
+ * @ethhdr: pointer to the ethernet header inside the skb
+ *
+ * Returns true if the skb was consumed (encoded packet sent) or false=
 otherwise
+ */
+bool batadv_nc_skb_forward(struct sk_buff *skb,
+			   struct batadv_neigh_node *neigh_node,
+			   struct ethhdr *ethhdr)
+{
+	const struct net_device *netdev =3D neigh_node->if_incoming->soft_ifa=
ce;
+	struct batadv_priv *bat_priv =3D netdev_priv(netdev);
+	struct batadv_unicast_packet *packet;
+	struct batadv_nc_path *nc_path;
+	__be32 packet_id;
+	u8 *payload;
+
+	/* Check if network coding is enabled */
+	if (!atomic_read(&bat_priv->network_coding))
+		goto out;
+
+	/* We only handle unicast packets */
+	payload =3D skb_network_header(skb);
+	packet =3D (struct batadv_unicast_packet *)payload;
+	if (packet->header.packet_type !=3D BATADV_UNICAST)
+		goto out;
+
+	/* Find or create a nc_path for this src-dst pair */
+	nc_path =3D batadv_nc_get_path(bat_priv,
+				     bat_priv->nc.coding_hash,
+				     ethhdr->h_source,
+				     neigh_node->addr);
+
+	if (!nc_path)
+		goto out;
+
+	/* Add skb to nc_path */
+	packet_id =3D batadv_skb_crc32(skb, payload + sizeof(*packet));
+	if (!batadv_nc_skb_add_to_path(skb, nc_path, neigh_node, packet_id))
+		goto free_nc_path;
+
+	/* Packet is consumed */
+	return true;
+
+free_nc_path:
+	batadv_nc_path_free_ref(nc_path);
+out:
+	/* Packet is not consumed */
+	return false;
+}
+
+/**
  * batadv_nc_free - clean up network coding memory
  * @bat_priv: the bat priv with all the soft interface information
  */
 void batadv_nc_free(struct batadv_priv *bat_priv)
 {
 	cancel_delayed_work_sync(&bat_priv->nc.work);
+	batadv_nc_purge_paths(bat_priv, bat_priv->nc.coding_hash, NULL);
+	batadv_hash_destroy(bat_priv->nc.coding_hash);
 }
=20
 /**
@@ -488,6 +970,11 @@ int batadv_nc_init_debugfs(struct batadv_priv *bat=
_priv)
 	if (!file)
 		goto out;
=20
+	file =3D debugfs_create_u32("max_fwd_delay", S_IRUGO | S_IWUSR, nc_di=
r,
+				  &bat_priv->nc.max_fwd_delay);
+	if (!file)
+		goto out;
+
 	return 0;
=20
 out:
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-c=
oding.h
index 4c56cd9..c32602a 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -35,6 +35,9 @@ void batadv_nc_purge_orig(struct batadv_priv *bat_pri=
v,
 					   struct batadv_nc_node *));
 void batadv_nc_init_bat_priv(struct batadv_priv *bat_priv);
 void batadv_nc_init_orig(struct batadv_orig_node *orig_node);
+bool batadv_nc_skb_forward(struct sk_buff *skb,
+			   struct batadv_neigh_node *neigh_node,
+			   struct ethhdr *ethhdr);
 int batadv_nc_nodes_seq_print_text(struct seq_file *seq, void *offset)=
;
 int batadv_nc_init_debugfs(struct batadv_priv *bat_priv);
=20
@@ -79,6 +82,13 @@ static inline void batadv_nc_init_orig(struct batadv=
_orig_node *orig_node)
 	return;
 }
=20
+static inline bool batadv_nc_skb_forward(struct sk_buff *skb,
+					 struct batadv_neigh_node *neigh_node,
+					 struct ethhdr *ethhdr)
+{
+	return false;
+}
+
 static inline int batadv_nc_nodes_seq_print_text(struct seq_file *seq,
 						 void *offset)
 {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 322c97a..44fda7c 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -29,6 +29,7 @@
 #include "unicast.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
+#include "network-coding.h"
=20
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if);
@@ -860,14 +861,17 @@ static int batadv_route_unicast_packet(struct sk_=
buff *skb,
 	/* decrement ttl */
 	unicast_packet->header.ttl--;
=20
-	/* Update stats counter */
-	batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
-	batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
-			   skb->len + ETH_HLEN);
+	/* network code packet if possible */
+	if (batadv_nc_skb_forward(skb, neigh_node, ethhdr)) {
+		ret =3D NET_RX_SUCCESS;
+	} else if (batadv_send_skb_to_orig(skb, orig_node, recv_if)) {
+		ret =3D NET_RX_SUCCESS;
=20
-	/* route it */
-	if (batadv_send_skb_to_orig(skb, orig_node, recv_if))
-		ret =3D NET_RX_SUCCESS;
+		/* Update stats counter */
+		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
+		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
+				   skb->len + ETH_HLEN);
+	}
=20
 out:
 	if (neigh_node)
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 1544ab4..43caf7f 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -442,11 +442,19 @@ struct batadv_priv_dat {
  * @work: work queue callback item for cleanup
  * @debug_dir: dentry for nc subdir in batman-adv directory in debugfs
  * @min_tq: only consider neighbors for encoding if neigh_tq > min_tq
+ * @max_fwd_delay: maximum packet forward delay to allow coding of pac=
kets
+ * @timestamp_fwd_flush: timestamp of last forward packet queue flush
+ * @coding_hash: Hash table used to buffer skbs while waiting for anot=
her
+ *  incoming skb to code it with. Skbs are added to the buffer just be=
fore being
+ *  forwarded in routing.c
  */
 struct batadv_priv_nc {
 	struct delayed_work work;
 	struct dentry *debug_dir;
 	u8 min_tq;
+	u32 max_fwd_delay;
+	unsigned long timestamp_fwd_flush;
+	struct batadv_hashtable *coding_hash;
 };
=20
 /**
@@ -748,6 +756,47 @@ struct batadv_nc_node {
 };
=20
 /**
+ * struct batadv_nc_path - network coding path
+ * @hash_entry: next and prev pointer for the list handling
+ * @rcu: struct used for freeing in an RCU-safe manner
+ * @refcount: number of contexts the object is used by
+ * @packet_list: list of buffered packets for this path
+ * @packet_list_lock: access lock for packet list
+ * @next_hop: next hop (destination) of path
+ * @prev_hop: previous hop (source) of path
+ * @last_valid: timestamp for last validation of path
+ */
+struct batadv_nc_path {
+	struct hlist_node hash_entry;
+	struct rcu_head rcu;
+	atomic_t refcount;
+	struct list_head packet_list;
+	spinlock_t packet_list_lock; /* Protects packet_list */
+	uint8_t next_hop[ETH_ALEN];
+	uint8_t prev_hop[ETH_ALEN];
+	unsigned long last_valid;
+};
+
+/**
+ * struct batadv_nc_packet - network coding packet used when coding an=
d
+ *  decoding packets
+ * @list: next and prev pointer for the list handling
+ * @packet_id: crc32 checksum of skb data
+ * @timestamp: field containing the info when the packet was added to =
path
+ * @neigh_node: pointer to original next hop neighbor of skb
+ * @skb: skb which can be encoded or used for decoding
+ * @nc_path: pointer to path this nc packet is attached to
+ */
+struct batadv_nc_packet {
+	struct list_head list;
+	__be32 packet_id;
+	unsigned long timestamp;
+	struct batadv_neigh_node *neigh_node;
+	struct sk_buff *skb;
+	struct batadv_nc_path *nc_path;
+};
+
+/**
  * struct batadv_forw_packet - structure for bcast packets to be sent/=
forwarded
  * @list: list node for batadv_socket_client::queue_list
  * @send_time: execution time for delayed_work (packet sending)
--=20
1.8.1.5
