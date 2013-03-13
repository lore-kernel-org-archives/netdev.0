From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 8/9] batman-adv: network coding - save overheard and tx packets for decoding
Date: Wed, 13 Mar 2013 23:56:38 +0100
Message-ID: <1363215399-18875-9-git-send-email-ordex@autistici.org>
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
Received: from contumacia.investici.org ([178.255.144.35]:20323 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934401Ab3CMW6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:58:07 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

To be able to decode a network coded packet, a node must already know
one of the two coded packets. This is done by buffering skbs before
transmission and buffering packets sniffed with promiscuous mode from
other hosts.

Packets are kept in a buffer similar to the one with forward-skbs: A
hash table, where each entry, which corresponds to a src-dst pair, has =
a
linked list packets.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/network-coding.c | 208 ++++++++++++++++++++++++++++++++=
+++++++-
 net/batman-adv/network-coding.h |  18 ++++
 net/batman-adv/routing.c        |  13 ++-
 net/batman-adv/send.c           |   5 +
 net/batman-adv/soft-interface.c |   1 +
 net/batman-adv/types.h          |  11 +++
 6 files changed, 253 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index fce2846..3d2ed2f 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -27,6 +27,7 @@
 #include "hard-interface.h"
=20
 static struct lock_class_key batadv_nc_coding_hash_lock_class_key;
+static struct lock_class_key batadv_nc_decoding_hash_lock_class_key;
=20
 static void batadv_nc_worker(struct work_struct *work);
=20
@@ -47,8 +48,9 @@ static void batadv_nc_start_timer(struct batadv_priv =
*bat_priv)
 int batadv_nc_init(struct batadv_priv *bat_priv)
 {
 	bat_priv->nc.timestamp_fwd_flush =3D jiffies;
+	bat_priv->nc.timestamp_sniffed_purge =3D jiffies;
=20
-	if (bat_priv->nc.coding_hash)
+	if (bat_priv->nc.coding_hash || bat_priv->nc.decoding_hash)
 		return 0;
=20
 	bat_priv->nc.coding_hash =3D batadv_hash_new(128);
@@ -58,6 +60,13 @@ int batadv_nc_init(struct batadv_priv *bat_priv)
 	batadv_hash_set_lock_class(bat_priv->nc.coding_hash,
 				   &batadv_nc_coding_hash_lock_class_key);
=20
+	bat_priv->nc.decoding_hash =3D batadv_hash_new(128);
+	if (!bat_priv->nc.decoding_hash)
+		goto err;
+
+	batadv_hash_set_lock_class(bat_priv->nc.coding_hash,
+				   &batadv_nc_decoding_hash_lock_class_key);
+
 	INIT_DELAYED_WORK(&bat_priv->nc.work, batadv_nc_worker);
 	batadv_nc_start_timer(bat_priv);
=20
@@ -76,6 +85,7 @@ void batadv_nc_init_bat_priv(struct batadv_priv *bat_=
priv)
 	atomic_set(&bat_priv->network_coding, 1);
 	bat_priv->nc.min_tq =3D 200;
 	bat_priv->nc.max_fwd_delay =3D 10;
+	bat_priv->nc.max_buffer_time =3D 200;
 }
=20
 /**
@@ -176,6 +186,26 @@ static bool batadv_nc_to_purge_nc_path_coding(stru=
ct batadv_priv *bat_priv,
 }
=20
 /**
+ * batadv_nc_to_purge_nc_path_decoding - checks whether an nc path has=
 timed out
+ * @bat_priv: the bat priv with all the soft interface information
+ * @nc_path: the nc path to check
+ *
+ * Returns true if the entry has to be purged now, false otherwise
+ */
+static bool batadv_nc_to_purge_nc_path_decoding(struct batadv_priv *ba=
t_priv,
+						struct batadv_nc_path *nc_path)
+{
+	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
+		return true;
+
+	/* purge the path when no packets has been added for 10 times the
+	 * max_buffer time
+	 */
+	return batadv_has_timed_out(nc_path->last_valid,
+				    bat_priv->nc.max_buffer_time*10);
+}
+
+/**
  * batadv_nc_purge_orig_nc_nodes - go through list of nc nodes and pur=
ge stale
  *  entries
  * @bat_priv: the bat priv with all the soft interface information
@@ -441,6 +471,43 @@ static void batadv_nc_send_packet(struct batadv_nc=
_packet *nc_packet)
 }
=20
 /**
+ * batadv_nc_sniffed_purge - Checks timestamp of given sniffed nc_pack=
et.
+ * @bat_priv: the bat priv with all the soft interface information
+ * @nc_path: the nc path the packet belongs to
+ * @nc_packet: the nc packet to be checked
+ *
+ * Checks whether the given sniffed (overheard) nc_packet has hit its =
buffering
+ * timeout. If so, the packet is no longer kept and the entry deleted =
from the
+ * queue. Has to be called with the appropriate locks.
+ *
+ * Returns false as soon as the entry in the fifo queue has not been t=
imed out
+ * yet and true otherwise.
+ */
+static bool batadv_nc_sniffed_purge(struct batadv_priv *bat_priv,
+				    struct batadv_nc_path *nc_path,
+				    struct batadv_nc_packet *nc_packet)
+{
+	unsigned long timeout =3D bat_priv->nc.max_buffer_time;
+	bool res =3D false;
+
+	/* Packets are added to tail, so the remaining packets did not time
+	 * out and we can stop processing the current queue
+	 */
+	if (atomic_read(&bat_priv->mesh_state) =3D=3D BATADV_MESH_ACTIVE &&
+	    !batadv_has_timed_out(nc_packet->timestamp, timeout))
+		goto out;
+
+	/* purge nc packet */
+	list_del(&nc_packet->list);
+	batadv_nc_packet_free(nc_packet);
+
+	res =3D true;
+
+out:
+	return res;
+}
+
+/**
  * batadv_nc_fwd_flush - Checks the timestamp of the given nc packet.
  * @bat_priv: the bat priv with all the soft interface information
  * @nc_path: the nc path the packet belongs to
@@ -540,6 +607,8 @@ static void batadv_nc_worker(struct work_struct *wo=
rk)
 	batadv_nc_purge_orig_hash(bat_priv);
 	batadv_nc_purge_paths(bat_priv, bat_priv->nc.coding_hash,
 			      batadv_nc_to_purge_nc_path_coding);
+	batadv_nc_purge_paths(bat_priv, bat_priv->nc.decoding_hash,
+			      batadv_nc_to_purge_nc_path_decoding);
=20
 	timeout =3D bat_priv->nc.max_fwd_delay;
=20
@@ -549,6 +618,13 @@ static void batadv_nc_worker(struct work_struct *w=
ork)
 		bat_priv->nc.timestamp_fwd_flush =3D jiffies;
 	}
=20
+	if (batadv_has_timed_out(bat_priv->nc.timestamp_sniffed_purge,
+				 bat_priv->nc.max_buffer_time)) {
+		batadv_nc_process_nc_paths(bat_priv, bat_priv->nc.decoding_hash,
+					   batadv_nc_sniffed_purge);
+		bat_priv->nc.timestamp_sniffed_purge =3D jiffies;
+	}
+
 	/* Schedule a new check */
 	batadv_nc_start_timer(bat_priv);
 }
@@ -1143,6 +1219,41 @@ batadv_nc_skb_src_search(struct batadv_priv *bat=
_priv,
 }
=20
 /**
+ * batadv_nc_skb_store_before_coding - set the ethernet src and dst of=
 the
+ *  unicast skb before it is stored for use in later decoding
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: data skb to store
+ * @eth_dst_new: new destination mac address of skb
+ */
+static void batadv_nc_skb_store_before_coding(struct batadv_priv *bat_=
priv,
+					      struct sk_buff *skb,
+					      uint8_t *eth_dst_new)
+{
+	struct ethhdr *ethhdr;
+
+	/* Copy skb header to change the mac header */
+	skb =3D pskb_copy(skb, GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	/* Set the mac header as if we actually sent the packet uncoded */
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+	memcpy(ethhdr->h_source, ethhdr->h_dest, ETH_ALEN);
+	memcpy(ethhdr->h_dest, eth_dst_new, ETH_ALEN);
+
+	/* Set data pointer to MAC header to mimic packets from our tx path *=
/
+	skb_push(skb, ETH_HLEN);
+
+	/* Add the packet to the decoding packet pool */
+	batadv_nc_skb_store_for_decoding(bat_priv, skb);
+
+	/* batadv_nc_skb_store_for_decoding() clones the skb, so we must free
+	 * our ref
+	 */
+	kfree_skb(skb);
+}
+
+/**
  * batadv_nc_skb_dst_search - Loops through list of neighboring nodes =
to dst.
  * @skb: data skb to forward
  * @neigh_node: next hop to forward packet to
@@ -1181,6 +1292,12 @@ static bool batadv_nc_skb_dst_search(struct sk_b=
uff *skb,
 	if (!nc_packet)
 		return false;
=20
+	/* Save packets for later decoding */
+	batadv_nc_skb_store_before_coding(bat_priv, skb,
+					  neigh_node->addr);
+	batadv_nc_skb_store_before_coding(bat_priv, nc_packet->skb,
+					  nc_packet->neigh_node->addr);
+
 	/* Code and send packets */
 	if (batadv_nc_code_packets(bat_priv, skb, ethhdr, nc_packet,
 				   neigh_node))
@@ -1288,14 +1405,98 @@ out:
 }
=20
 /**
+ * batadv_nc_skb_store_for_decoding - save a clone of the skb which ca=
n be used
+ *  when decoding coded packets
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: data skb to store
+ */
+void batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb)
+{
+	struct batadv_unicast_packet *packet;
+	struct batadv_nc_path *nc_path;
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+	__be32 packet_id;
+	u8 *payload;
+
+	/* Check if network coding is enabled */
+	if (!atomic_read(&bat_priv->network_coding))
+		goto out;
+
+	/* Check for supported packet type */
+	payload =3D skb_network_header(skb);
+	packet =3D (struct batadv_unicast_packet *)payload;
+	if (packet->header.packet_type !=3D BATADV_UNICAST)
+		goto out;
+
+	/* Find existing nc_path or create a new */
+	nc_path =3D batadv_nc_get_path(bat_priv,
+				     bat_priv->nc.decoding_hash,
+				     ethhdr->h_source,
+				     ethhdr->h_dest);
+
+	if (!nc_path)
+		goto out;
+
+	/* Clone skb and adjust skb->data to point at batman header */
+	skb =3D skb_clone(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		goto free_nc_path;
+
+	if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
+		goto free_skb;
+
+	if (unlikely(!skb_pull_rcsum(skb, ETH_HLEN)))
+		goto free_skb;
+
+	/* Add skb to nc_path */
+	packet_id =3D batadv_skb_crc32(skb, payload + sizeof(*packet));
+	if (!batadv_nc_skb_add_to_path(skb, nc_path, NULL, packet_id))
+		goto free_skb;
+
+	batadv_inc_counter(bat_priv, BATADV_CNT_NC_BUFFER);
+	return;
+
+free_skb:
+	kfree_skb(skb);
+free_nc_path:
+	batadv_nc_path_free_ref(nc_path);
+out:
+	return;
+}
+
+/**
+ * batadv_nc_skb_store_sniffed_unicast - check if a received unicast p=
acket
+ *  should be saved in the decoding buffer and, if so, store it there
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: unicast skb to store
+ */
+void batadv_nc_skb_store_sniffed_unicast(struct batadv_priv *bat_priv,
+					 struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	if (batadv_is_my_mac(ethhdr->h_dest))
+		return;
+
+	/* Set data pointer to MAC header to mimic packets from our tx path *=
/
+	skb_push(skb, ETH_HLEN);
+
+	batadv_nc_skb_store_for_decoding(bat_priv, skb);
+}
+
+/**
  * batadv_nc_free - clean up network coding memory
  * @bat_priv: the bat priv with all the soft interface information
  */
 void batadv_nc_free(struct batadv_priv *bat_priv)
 {
 	cancel_delayed_work_sync(&bat_priv->nc.work);
+
 	batadv_nc_purge_paths(bat_priv, bat_priv->nc.coding_hash, NULL);
 	batadv_hash_destroy(bat_priv->nc.coding_hash);
+	batadv_nc_purge_paths(bat_priv, bat_priv->nc.decoding_hash, NULL);
+	batadv_hash_destroy(bat_priv->nc.decoding_hash);
 }
=20
 /**
@@ -1376,6 +1577,11 @@ int batadv_nc_init_debugfs(struct batadv_priv *b=
at_priv)
 	if (!file)
 		goto out;
=20
+	file =3D debugfs_create_u32("max_buffer_time", S_IRUGO | S_IWUSR, nc_=
dir,
+				  &bat_priv->nc.max_buffer_time);
+	if (!file)
+		goto out;
+
 	return 0;
=20
 out:
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-c=
oding.h
index c32602a..4fa6d0c 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -38,6 +38,10 @@ void batadv_nc_init_orig(struct batadv_orig_node *or=
ig_node);
 bool batadv_nc_skb_forward(struct sk_buff *skb,
 			   struct batadv_neigh_node *neigh_node,
 			   struct ethhdr *ethhdr);
+void batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb);
+void batadv_nc_skb_store_sniffed_unicast(struct batadv_priv *bat_priv,
+					 struct sk_buff *skb);
 int batadv_nc_nodes_seq_print_text(struct seq_file *seq, void *offset)=
;
 int batadv_nc_init_debugfs(struct batadv_priv *bat_priv);
=20
@@ -89,6 +93,20 @@ static inline bool batadv_nc_skb_forward(struct sk_b=
uff *skb,
 	return false;
 }
=20
+static inline void
+batadv_nc_skb_store_for_decoding(struct batadv_priv *bat_priv,
+				 struct sk_buff *skb)
+{
+	return;
+}
+
+static inline void
+batadv_nc_skb_store_sniffed_unicast(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb)
+{
+	return;
+}
+
 static inline int batadv_nc_nodes_seq_print_text(struct seq_file *seq,
 						 void *offset)
 {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 44fda7c..8f88967 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1047,7 +1047,7 @@ int batadv_recv_unicast_packet(struct sk_buff *sk=
b,
 	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
 	uint8_t *orig_addr;
 	struct batadv_orig_node *orig_node =3D NULL;
-	int hdr_size =3D sizeof(*unicast_packet);
+	int check, hdr_size =3D sizeof(*unicast_packet);
 	bool is4addr;
=20
 	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
@@ -1058,7 +1058,16 @@ int batadv_recv_unicast_packet(struct sk_buff *s=
kb,
 	if (is4addr)
 		hdr_size =3D sizeof(*unicast_4addr_packet);
=20
-	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
+	/* function returns -EREMOTE for promiscuous packets */
+	check =3D batadv_check_unicast_packet(skb, hdr_size);
+
+	/* Even though the packet is not for us, we might save it to use for
+	 * decoding a later received coded packet
+	 */
+	if (check =3D=3D -EREMOTE)
+		batadv_nc_skb_store_sniffed_unicast(bat_priv, skb);
+
+	if (check < 0)
 		return NET_RX_DROP;
=20
 	if (!batadv_check_unicast_ttvn(bat_priv, skb))
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index a67cffd..263cfd1 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -27,6 +27,7 @@
 #include "vis.h"
 #include "gateway_common.h"
 #include "originator.h"
+#include "network-coding.h"
=20
 #include <linux/if_ether.h>
=20
@@ -39,6 +40,7 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
 			   const uint8_t *dst_addr)
 {
+	struct batadv_priv *bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	struct ethhdr *ethhdr;
=20
 	if (hard_iface->if_status !=3D BATADV_IF_ACTIVE)
@@ -70,6 +72,9 @@ int batadv_send_skb_packet(struct sk_buff *skb,
=20
 	skb->dev =3D hard_iface->net_dev;
=20
+	/* Save a clone of the skb to use when decoding coded packets */
+	batadv_nc_skb_store_for_decoding(bat_priv, skb);
+
 	/* dev_queue_xmit() returns a negative result on error.	 However on
 	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
 	 * (which is > 0). This will not be treated as an error.
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 7e463c3..75204ec 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -670,6 +670,7 @@ static const struct {
 	{ "nc_code_bytes" },
 	{ "nc_recode" },
 	{ "nc_recode_bytes" },
+	{ "nc_buffer" },
 #endif
 };
=20
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 42d7438..5f3640d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -279,6 +279,7 @@ struct batadv_bcast_duplist_entry {
  * @BATADV_CNT_NC_CODE_BYTES: transmitted nc-combined traffic bytes co=
unter
  * @BATADV_CNT_NC_RECODE: transmitted nc-recombined traffic packet cou=
nter
  * @BATADV_CNT_NC_RECODE_BYTES: transmitted nc-recombined traffic byte=
s counter
+ * @BATADV_CNT_NC_BUFFER: counter for packets buffered for later nc de=
coding
  * @BATADV_CNT_NUM: number of traffic counters
  */
 enum batadv_counters {
@@ -311,6 +312,7 @@ enum batadv_counters {
 	BATADV_CNT_NC_CODE_BYTES,
 	BATADV_CNT_NC_RECODE,
 	BATADV_CNT_NC_RECODE_BYTES,
+	BATADV_CNT_NC_BUFFER,
 #endif
 	BATADV_CNT_NUM,
 };
@@ -453,18 +455,27 @@ struct batadv_priv_dat {
  * @debug_dir: dentry for nc subdir in batman-adv directory in debugfs
  * @min_tq: only consider neighbors for encoding if neigh_tq > min_tq
  * @max_fwd_delay: maximum packet forward delay to allow coding of pac=
kets
+ * @max_buffer_time: buffer time for sniffed packets used to decoding
  * @timestamp_fwd_flush: timestamp of last forward packet queue flush
+ * @timestamp_sniffed_purge: timestamp of last sniffed packet queue pu=
rge
  * @coding_hash: Hash table used to buffer skbs while waiting for anot=
her
  *  incoming skb to code it with. Skbs are added to the buffer just be=
fore being
  *  forwarded in routing.c
+ * @decoding_hash: Hash table used to buffer skbs that might be needed=
 to decode
+ *  a received coded skb. The buffer is used for 1) skbs arriving on t=
he
+ *  soft-interface; 2) skbs overheard on the hard-interface; and 3) sk=
bs
+ *  forwarded by batman-adv.
  */
 struct batadv_priv_nc {
 	struct delayed_work work;
 	struct dentry *debug_dir;
 	u8 min_tq;
 	u32 max_fwd_delay;
+	u32 max_buffer_time;
 	unsigned long timestamp_fwd_flush;
+	unsigned long timestamp_sniffed_purge;
 	struct batadv_hashtable *coding_hash;
+	struct batadv_hashtable *decoding_hash;
 };
=20
 /**
--=20
1.8.1.5
