From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/16] batman-adv: Receive fragmented packets and merge
Date: Sun, 13 Oct 2013 13:22:53 +0200
Message-ID: <1381663381-626-9-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:42477 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485Ab3JMLYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:24:34 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

=46ragments arriving at their destination are buffered for later merge.
Merged packets are passed to the main receive function as had they neve=
r
been fragmented.

=46ragments are forwarded without merging if the MTU of the outgoing
interface is smaller than the size of the merged packet.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/Makefile         |   1 +
 net/batman-adv/fragmentation.c  | 370 ++++++++++++++++++++++++++++++++=
++++++++
 net/batman-adv/fragmentation.h  |  47 +++++
 net/batman-adv/main.c           |   4 +
 net/batman-adv/main.h           |   9 +
 net/batman-adv/originator.c     |  14 +-
 net/batman-adv/packet.h         |  27 +++
 net/batman-adv/routing.c        |  59 +++++++
 net/batman-adv/routing.h        |   2 +
 net/batman-adv/soft-interface.c |   4 +
 net/batman-adv/types.h          |  38 +++++
 11 files changed, 574 insertions(+), 1 deletion(-)
 create mode 100644 net/batman-adv/fragmentation.c
 create mode 100644 net/batman-adv/fragmentation.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index f9b465b..4f4aabb 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -24,6 +24,7 @@ batman-adv-y +=3D bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) +=3D bridge_loop_avoidance.o
 batman-adv-y +=3D debugfs.o
 batman-adv-$(CONFIG_BATMAN_ADV_DAT) +=3D distributed-arp-table.o
+batman-adv-y +=3D fragmentation.o
 batman-adv-y +=3D gateway_client.o
 batman-adv-y +=3D gateway_common.o
 batman-adv-y +=3D hard-interface.o
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
new file mode 100644
index 0000000..c829d3c
--- /dev/null
+++ b/net/batman-adv/fragmentation.c
@@ -0,0 +1,370 @@
+/* Copyright (C) 2013 B.A.T.M.A.N. contributors:
+ *
+ * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include "main.h"
+#include "fragmentation.h"
+#include "send.h"
+#include "originator.h"
+#include "routing.h"
+#include "hard-interface.h"
+#include "soft-interface.h"
+
+
+/**
+ * batadv_frag_clear_chain - delete entries in the fragment buffer cha=
in
+ * @head: head of chain with entries.
+ *
+ * Free fragments in the passed hlist. Should be called with appropria=
te lock.
+ */
+static void batadv_frag_clear_chain(struct hlist_head *head)
+{
+	struct batadv_frag_list_entry *entry;
+	struct hlist_node *node;
+
+	hlist_for_each_entry_safe(entry, node, head, list) {
+		hlist_del(&entry->list);
+		kfree_skb(entry->skb);
+		kfree(entry);
+	}
+}
+
+/**
+ * batadv_frag_purge_orig - free fragments associated to an orig
+ * @orig_node: originator to free fragments from
+ * @check_cb: optional function to tell if an entry should be purged
+ */
+void batadv_frag_purge_orig(struct batadv_orig_node *orig_node,
+			    bool (*check_cb)(struct batadv_frag_table_entry *))
+{
+	struct batadv_frag_table_entry *chain;
+	uint8_t i;
+
+	for (i =3D 0; i < BATADV_FRAG_BUFFER_COUNT; i++) {
+		chain =3D &orig_node->fragments[i];
+		spin_lock_bh(&orig_node->fragments[i].lock);
+
+		if (!check_cb || check_cb(chain)) {
+			batadv_frag_clear_chain(&orig_node->fragments[i].head);
+			orig_node->fragments[i].size =3D 0;
+		}
+
+		spin_unlock_bh(&orig_node->fragments[i].lock);
+	}
+}
+
+/**
+ * batadv_frag_size_limit - maximum possible size of packet to be frag=
mented
+ *
+ * Returns the maximum size of payload that can be fragmented.
+ */
+static int batadv_frag_size_limit(void)
+{
+	int limit =3D BATADV_FRAG_MAX_FRAG_SIZE;
+
+	limit -=3D sizeof(struct batadv_frag_packet);
+	limit *=3D BATADV_FRAG_MAX_FRAGMENTS;
+
+	return limit;
+}
+
+/**
+ * batadv_frag_init_chain - check and prepare fragment chain for new f=
ragment
+ * @chain: chain in fragments table to init
+ * @seqno: sequence number of the received fragment
+ *
+ * Make chain ready for a fragment with sequence number "seqno". Delet=
e existing
+ * entries if they have an "old" sequence number.
+ *
+ * Caller must hold chain->lock.
+ *
+ * Returns true if chain is empty and caller can just insert the new f=
ragment
+ * without searching for the right position.
+ */
+static bool batadv_frag_init_chain(struct batadv_frag_table_entry *cha=
in,
+				   uint16_t seqno)
+{
+	if (chain->seqno =3D=3D seqno)
+		return false;
+
+	if (!hlist_empty(&chain->head))
+		batadv_frag_clear_chain(&chain->head);
+
+	chain->size =3D 0;
+	chain->seqno =3D seqno;
+
+	return true;
+}
+
+/**
+ * batadv_frag_insert_packet - insert a fragment into a fragment chain
+ * @orig_node: originator that the fragment was received from
+ * @skb: skb to insert
+ * @chain_out: list head to attach complete chains of fragments to
+ *
+ * Insert a new fragment into the reverse ordered chain in the right t=
able
+ * entry. The hash table entry is cleared if "old" fragments exist in =
it.
+ *
+ * Returns true if skb is buffered, false on error. If the chain has a=
ll the
+ * fragments needed to merge the packet, the chain is moved to the pas=
sed head
+ * to avoid locking the chain in the table.
+ */
+static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_no=
de,
+				      struct sk_buff *skb,
+				      struct hlist_head *chain_out)
+{
+	struct batadv_frag_table_entry *chain;
+	struct batadv_frag_list_entry *frag_entry_new =3D NULL, *frag_entry_c=
urr;
+	struct batadv_frag_packet *frag_packet;
+	uint8_t bucket;
+	uint16_t seqno, hdr_size =3D sizeof(struct batadv_frag_packet);
+	bool ret =3D false;
+
+	/* Linearize packet to avoid linearizing 16 packets in a row when doi=
ng
+	 * the later merge. Non-linear merge should be added to remove this
+	 * linearization.
+	 */
+	if (skb_linearize(skb) < 0)
+		goto err;
+
+	frag_packet =3D (struct batadv_frag_packet *)skb->data;
+	seqno =3D ntohs(frag_packet->seqno);
+	bucket =3D seqno % BATADV_FRAG_BUFFER_COUNT;
+
+	frag_entry_new =3D kmalloc(sizeof(*frag_entry_new), GFP_ATOMIC);
+	if (!frag_entry_new)
+		goto err;
+
+	frag_entry_new->skb =3D skb;
+	frag_entry_new->no =3D frag_packet->no;
+
+	/* Select entry in the "chain table" and delete any prior fragments
+	 * with another sequence number. batadv_frag_init_chain() returns tru=
e,
+	 * if the list is empty at return.
+	 */
+	chain =3D &orig_node->fragments[bucket];
+	spin_lock_bh(&chain->lock);
+	if (batadv_frag_init_chain(chain, seqno)) {
+		hlist_add_head(&frag_entry_new->list, &chain->head);
+		chain->size =3D skb->len - hdr_size;
+		chain->timestamp =3D jiffies;
+		ret =3D true;
+		goto out;
+	}
+
+	/* Find the position for the new fragment. */
+	hlist_for_each_entry(frag_entry_curr, &chain->head, list) {
+		/* Drop packet if fragment already exists. */
+		if (frag_entry_curr->no =3D=3D frag_entry_new->no)
+			goto err_unlock;
+
+		/* Order fragments from highest to lowest. */
+		if (frag_entry_curr->no < frag_entry_new->no) {
+			hlist_add_before(&frag_entry_new->list,
+					 &frag_entry_curr->list);
+			chain->size +=3D skb->len - hdr_size;
+			chain->timestamp =3D jiffies;
+			ret =3D true;
+			goto out;
+		}
+	}
+
+	/* Reached the end of the list, so insert after 'frag_entry_curr'. */
+	if (likely(frag_entry_curr)) {
+		hlist_add_after(&frag_entry_curr->list, &frag_entry_new->list);
+		chain->size +=3D skb->len - hdr_size;
+		chain->timestamp =3D jiffies;
+		ret =3D true;
+	}
+
+out:
+	if (chain->size > batadv_frag_size_limit() ||
+	    ntohs(frag_packet->total_size) > batadv_frag_size_limit()) {
+		/* Clear chain if total size of either the list or the packet
+		 * exceeds the maximum size of one merged packet.
+		 */
+		batadv_frag_clear_chain(&chain->head);
+		chain->size =3D 0;
+	} else if (ntohs(frag_packet->total_size) =3D=3D chain->size) {
+		/* All fragments received. Hand over chain to caller. */
+		hlist_move_list(&chain->head, chain_out);
+		chain->size =3D 0;
+	}
+
+err_unlock:
+	spin_unlock_bh(&chain->lock);
+
+err:
+	if (!ret)
+		kfree(frag_entry_new);
+
+	return ret;
+}
+
+/**
+ * batadv_frag_merge_packets - merge a chain of fragments
+ * @chain: head of chain with fragments
+ * @skb: packet with total size of skb after merging
+ *
+ * Expand the first skb in the chain and copy the content of the remai=
ning
+ * skb's into the expanded one. After doing so, clear the chain.
+ *
+ * Returns the merged skb or NULL on error.
+ */
+static struct sk_buff *
+batadv_frag_merge_packets(struct hlist_head *chain, struct sk_buff *sk=
b)
+{
+	struct batadv_frag_packet *packet;
+	struct batadv_frag_list_entry *entry;
+	struct sk_buff *skb_out =3D NULL;
+	int size, hdr_size =3D sizeof(struct batadv_frag_packet);
+
+	/* Make sure incoming skb has non-bogus data. */
+	packet =3D (struct batadv_frag_packet *)skb->data;
+	size =3D ntohs(packet->total_size);
+	if (size > batadv_frag_size_limit())
+		goto free;
+
+	/* Remove first entry, as this is the destination for the rest of the
+	 * fragments.
+	 */
+	entry =3D hlist_entry(chain->first, struct batadv_frag_list_entry, li=
st);
+	hlist_del(&entry->list);
+	skb_out =3D entry->skb;
+	kfree(entry);
+
+	/* Make room for the rest of the fragments. */
+	if (pskb_expand_head(skb_out, 0, size - skb->len, GFP_ATOMIC) < 0) {
+		kfree_skb(skb_out);
+		skb_out =3D NULL;
+		goto free;
+	}
+
+	/* Move the existing MAC header to just before the payload. (Override
+	 * the fragment header.)
+	 */
+	skb_pull_rcsum(skb_out, hdr_size);
+	memmove(skb_out->data - ETH_HLEN, skb_mac_header(skb_out), ETH_HLEN);
+	skb_set_mac_header(skb_out, -ETH_HLEN);
+	skb_reset_network_header(skb_out);
+	skb_reset_transport_header(skb_out);
+
+	/* Copy the payload of the each fragment into the last skb */
+	hlist_for_each_entry(entry, chain, list) {
+		size =3D entry->skb->len - hdr_size;
+		memcpy(skb_put(skb_out, size), entry->skb->data + hdr_size,
+		       size);
+	}
+
+free:
+	/* Locking is not needed, because 'chain' is not part of any orig. */
+	batadv_frag_clear_chain(chain);
+	return skb_out;
+}
+
+/**
+ * batadv_frag_skb_buffer - buffer fragment for later merge
+ * @skb: skb to buffer
+ * @orig_node_src: originator that the skb is received from
+ *
+ * Add fragment to buffer and merge fragments if possible.
+ *
+ * There are three possible outcomes: 1) Packet is merged: Return true=
 and
+ * set *skb to merged packet; 2) Packet is buffered: Return true and s=
et *skb
+ * to NULL; 3) Error: Return false and leave skb as is.
+ */
+bool batadv_frag_skb_buffer(struct sk_buff **skb,
+			    struct batadv_orig_node *orig_node_src)
+{
+	struct sk_buff *skb_out =3D NULL;
+	struct hlist_head head =3D HLIST_HEAD_INIT;
+	bool ret =3D false;
+
+	/* Add packet to buffer and table entry if merge is possible. */
+	if (!batadv_frag_insert_packet(orig_node_src, *skb, &head))
+		goto out_err;
+
+	/* Leave if more fragments are needed to merge. */
+	if (hlist_empty(&head))
+		goto out;
+
+	skb_out =3D batadv_frag_merge_packets(&head, *skb);
+	if (!skb_out)
+		goto out_err;
+
+out:
+	*skb =3D skb_out;
+	ret =3D true;
+out_err:
+	return ret;
+}
+
+/**
+ * batadv_frag_skb_fwd - forward fragments that would exceed MTU when =
merged
+ * @skb: skb to forward
+ * @recv_if: interface that the skb is received on
+ * @orig_node_src: originator that the skb is received from
+ *
+ * Look up the next-hop of the fragments payload and check if the merg=
ed packet
+ * will exceed the MTU towards the next-hop. If so, the fragment is fo=
rwarded
+ * without merging it.
+ *
+ * Returns true if the fragment is consumed/forwarded, false otherwise=
=2E
+ */
+bool batadv_frag_skb_fwd(struct sk_buff *skb,
+			 struct batadv_hard_iface *recv_if,
+			 struct batadv_orig_node *orig_node_src)
+{
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_orig_node *orig_node_dst =3D NULL;
+	struct batadv_neigh_node *neigh_node =3D NULL;
+	struct batadv_frag_packet *packet;
+	uint16_t total_size;
+	bool ret =3D false;
+
+	packet =3D (struct batadv_frag_packet *)skb->data;
+	orig_node_dst =3D batadv_orig_hash_find(bat_priv, packet->dest);
+	if (!orig_node_dst)
+		goto out;
+
+	neigh_node =3D batadv_find_router(bat_priv, orig_node_dst, recv_if);
+	if (!neigh_node)
+		goto out;
+
+	/* Forward the fragment, if the merged packet would be too big to
+	 * be assembled.
+	 */
+	total_size =3D ntohs(packet->total_size);
+	if (total_size > neigh_node->if_incoming->net_dev->mtu) {
+		batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_FWD);
+		batadv_add_counter(bat_priv, BATADV_CNT_FRAG_FWD_BYTES,
+				   skb->len + ETH_HLEN);
+
+		packet->header.ttl--;
+		batadv_send_skb_packet(skb, neigh_node->if_incoming,
+				       neigh_node->addr);
+		ret =3D true;
+	}
+
+out:
+	if (orig_node_dst)
+		batadv_orig_node_free_ref(orig_node_dst);
+	if (neigh_node)
+		batadv_neigh_node_free_ref(neigh_node);
+	return ret;
+}
diff --git a/net/batman-adv/fragmentation.h b/net/batman-adv/fragmentat=
ion.h
new file mode 100644
index 0000000..883a6f4
--- /dev/null
+++ b/net/batman-adv/fragmentation.h
@@ -0,0 +1,47 @@
+/* Copyright (C) 2013 B.A.T.M.A.N. contributors:
+ *
+ * Martin Hundeb=C3=B8ll <martin@hundeboll.net>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef _NET_BATMAN_ADV_FRAGMENTATION_H_
+#define _NET_BATMAN_ADV_FRAGMENTATION_H_
+
+void batadv_frag_purge_orig(struct batadv_orig_node *orig,
+			    bool (*check_cb)(struct batadv_frag_table_entry *));
+bool batadv_frag_skb_fwd(struct sk_buff *skb,
+			 struct batadv_hard_iface *recv_if,
+			 struct batadv_orig_node *orig_node_src);
+bool batadv_frag_skb_buffer(struct sk_buff **skb,
+			    struct batadv_orig_node *orig_node);
+
+/**
+ * batadv_frag_check_entry - check if a list of fragments has timed ou=
t
+ * @frags_entry: table entry to check
+ *
+ * Returns true if the frags entry has timed out, false otherwise.
+ */
+static inline bool
+batadv_frag_check_entry(struct batadv_frag_table_entry *frags_entry)
+{
+	if (!hlist_empty(&frags_entry->head) &&
+	    batadv_has_timed_out(frags_entry->timestamp, BATADV_FRAG_TIMEOUT)=
)
+		return true;
+	else
+		return false;
+}
+
+#endif /* _NET_BATMAN_ADV_FRAGMENTATION_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8822fad..ca6f134 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -40,6 +40,7 @@
 #include "hash.h"
 #include "bat_algo.h"
 #include "network-coding.h"
+#include "fragmentation.h"
=20
=20
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
@@ -399,6 +400,7 @@ static void batadv_recv_handler_init(void)
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_4addr_packet, src) !=3D 1=
0);
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_packet, dest) !=3D 4);
 	BUILD_BUG_ON(offsetof(struct batadv_unicast_tvlv_packet, dst) !=3D 4)=
;
+	BUILD_BUG_ON(offsetof(struct batadv_frag_packet, dest) !=3D 4);
 	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet, dst) !=3D 4);
 	BUILD_BUG_ON(offsetof(struct batadv_icmp_packet_rr, dst) !=3D 4);
=20
@@ -414,6 +416,8 @@ static void batadv_recv_handler_init(void)
 	batadv_rx_handler[BATADV_UNICAST_TVLV] =3D batadv_recv_unicast_tvlv;
 	/* batman icmp packet */
 	batadv_rx_handler[BATADV_ICMP] =3D batadv_recv_icmp_packet;
+	/* Fragmented packets */
+	batadv_rx_handler[BATADV_UNICAST_FRAG] =3D batadv_recv_frag_packet;
 }
=20
 int
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index e11c2ec..6a74a42 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -131,6 +131,15 @@ enum batadv_uev_type {
=20
 #define BATADV_GW_THRESHOLD	50
=20
+/* Number of fragment chains for each orig_node */
+#define BATADV_FRAG_BUFFER_COUNT 8
+/* Maximum number of fragments for one packet */
+#define BATADV_FRAG_MAX_FRAGMENTS 16
+/* Maxumim size of each fragment */
+#define BATADV_FRAG_MAX_FRAG_SIZE 1400
+/* Time to keep fragments while waiting for rest of the fragments */
+#define BATADV_FRAG_TIMEOUT 10000
+
 #define BATADV_DAT_CANDIDATE_NOT_FOUND	0
 #define BATADV_DAT_CANDIDATE_ORIG	1
=20
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 898b0ce..a591dc5 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -28,6 +28,7 @@
 #include "soft-interface.h"
 #include "bridge_loop_avoidance.h"
 #include "network-coding.h"
+#include "fragmentation.h"
=20
 /* hash class keys */
 static struct lock_class_key batadv_orig_hash_lock_class_key;
@@ -145,6 +146,8 @@ static void batadv_orig_node_free_rcu(struct rcu_he=
ad *rcu)
 	/* Free nc_nodes */
 	batadv_nc_purge_orig(orig_node->bat_priv, orig_node, NULL);
=20
+	batadv_frag_purge_orig(orig_node, NULL);
+
 	batadv_tt_global_del_orig(orig_node->bat_priv, orig_node,
 				  "originator timed out");
=20
@@ -215,7 +218,7 @@ struct batadv_orig_node *batadv_get_orig_node(struc=
t batadv_priv *bat_priv,
 					      const uint8_t *addr)
 {
 	struct batadv_orig_node *orig_node;
-	int size;
+	int size, i;
 	int hash_added;
 	unsigned long reset_time;
=20
@@ -267,6 +270,12 @@ struct batadv_orig_node *batadv_get_orig_node(stru=
ct batadv_priv *bat_priv,
 	size =3D bat_priv->num_ifaces * sizeof(uint8_t);
 	orig_node->bcast_own_sum =3D kzalloc(size, GFP_ATOMIC);
=20
+	for (i =3D 0; i < BATADV_FRAG_BUFFER_COUNT; i++) {
+		INIT_HLIST_HEAD(&orig_node->fragments[i].head);
+		spin_lock_init(&orig_node->fragments[i].lock);
+		orig_node->fragments[i].size =3D 0;
+	}
+
 	if (!orig_node->bcast_own_sum)
 		goto free_bcast_own;
=20
@@ -388,6 +397,9 @@ static void _batadv_purge_orig(struct batadv_priv *=
bat_priv)
 				batadv_orig_node_free_ref(orig_node);
 				continue;
 			}
+
+			batadv_frag_purge_orig(orig_node,
+					       batadv_frag_check_entry);
 		}
 		spin_unlock_bh(list_lock);
 	}
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 5e3b102..aa46c27 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -249,6 +249,33 @@ struct batadv_unicast_4addr_packet {
 	 */
 };
=20
+/**
+ * struct batadv_frag_packet - fragmented packet
+ * @header: common batman packet header with type, compatversion, and =
ttl
+ * @dest: final destination used when routing fragments
+ * @orig: originator of the fragment used when merging the packet
+ * @no: fragment number within this sequence
+ * @reserved: reserved byte for alignment
+ * @seqno: sequence identification
+ * @total_size: size of the merged packet
+ */
+struct batadv_frag_packet {
+	struct  batadv_header header;
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint8_t no:4;
+	uint8_t reserved:4;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint8_t reserved:4;
+	uint8_t no:4;
+#else
+#error "unknown bitfield endianess"
+#endif
+	uint8_t dest[ETH_ALEN];
+	uint8_t orig[ETH_ALEN];
+	__be16  seqno;
+	__be16  total_size;
+};
+
 struct batadv_bcast_packet {
 	struct batadv_header header;
 	uint8_t  reserved;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index fd2cdbc..a080f63 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -28,6 +28,7 @@
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
 #include "network-coding.h"
+#include "fragmentation.h"
=20
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if);
@@ -1013,6 +1014,64 @@ int batadv_recv_unicast_tvlv(struct sk_buff *skb=
,
 	return ret;
 }
=20
+/**
+ * batadv_recv_frag_packet - process received fragment
+ * @skb: the received fragment
+ * @recv_if: interface that the skb is received on
+ *
+ * This function does one of the three following things: 1) Forward fr=
agment, if
+ * the assembled packet will exceed our MTU; 2) Buffer fragment, if we=
 till
+ * lack further fragments; 3) Merge fragments, if we have all needed p=
arts.
+ *
+ * Return NET_RX_DROP if the skb is not consumed, NET_RX_SUCCESS other=
wise.
+ */
+int batadv_recv_frag_packet(struct sk_buff *skb,
+			    struct batadv_hard_iface *recv_if)
+{
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_orig_node *orig_node_src =3D NULL;
+	struct batadv_frag_packet *frag_packet;
+	int ret =3D NET_RX_DROP;
+
+	if (batadv_check_unicast_packet(bat_priv, skb,
+					sizeof(*frag_packet)) < 0)
+		goto out;
+
+	frag_packet =3D (struct batadv_frag_packet *)skb->data;
+	orig_node_src =3D batadv_orig_hash_find(bat_priv, frag_packet->orig);
+	if (!orig_node_src)
+		goto out;
+
+	/* Route the fragment if it is not for us and too big to be merged. *=
/
+	if (!batadv_is_my_mac(bat_priv, frag_packet->dest) &&
+	    batadv_frag_skb_fwd(skb, recv_if, orig_node_src)) {
+		ret =3D NET_RX_SUCCESS;
+		goto out;
+	}
+
+	batadv_inc_counter(bat_priv, BATADV_CNT_FRAG_RX);
+	batadv_add_counter(bat_priv, BATADV_CNT_FRAG_RX_BYTES, skb->len);
+
+	/* Add fragment to buffer and merge if possible. */
+	if (!batadv_frag_skb_buffer(&skb, orig_node_src))
+		goto out;
+
+	/* Deliver merged packet to the appropriate handler, if it was
+	 * merged
+	 */
+	if (skb)
+		batadv_batman_skb_recv(skb, recv_if->net_dev,
+				       &recv_if->batman_adv_ptype, NULL);
+
+	ret =3D NET_RX_SUCCESS;
+
+out:
+	if (orig_node_src)
+		batadv_orig_node_free_ref(orig_node_src);
+
+	return ret;
+}
+
 int batadv_recv_bcast_packet(struct sk_buff *skb,
 			     struct batadv_hard_iface *recv_if)
 {
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index efab583..55d637a 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -30,6 +30,8 @@ int batadv_recv_icmp_packet(struct sk_buff *skb,
 			    struct batadv_hard_iface *recv_if);
 int batadv_recv_unicast_packet(struct sk_buff *skb,
 			       struct batadv_hard_iface *recv_if);
+int batadv_recv_frag_packet(struct sk_buff *skb,
+			    struct batadv_hard_iface *iface);
 int batadv_recv_bcast_packet(struct sk_buff *skb,
 			     struct batadv_hard_iface *recv_if);
 int batadv_recv_tt_query(struct sk_buff *skb,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 504d0bb..dd189e6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -758,6 +758,10 @@ static const struct {
 	{ "mgmt_tx_bytes" },
 	{ "mgmt_rx" },
 	{ "mgmt_rx_bytes" },
+	{ "frag_rx" },
+	{ "frag_rx_bytes" },
+	{ "frag_fwd" },
+	{ "frag_fwd_bytes" },
 	{ "tt_request_tx" },
 	{ "tt_request_rx" },
 	{ "tt_response_tx" },
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 795a079..5a2cc7a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -86,6 +86,34 @@ struct batadv_hard_iface {
 };
=20
 /**
+ * struct batadv_frag_table_entry - head in the fragment buffer table
+ * @head: head of list with fragments
+ * @lock: lock to protect the list of fragments
+ * @timestamp: time (jiffie) of last received fragment
+ * @seqno: sequence number of the fragments in the list
+ * @size: accumulated size of packets in list
+ */
+struct batadv_frag_table_entry {
+	struct hlist_head head;
+	spinlock_t lock; /* protects head */
+	unsigned long timestamp;
+	uint16_t seqno;
+	uint16_t size;
+};
+
+/**
+ * struct batadv_frag_list_entry - entry in a list of fragments
+ * @list: list node information
+ * @skb: fragment
+ * @no: fragment number in the set
+ */
+struct batadv_frag_list_entry {
+	struct hlist_node list;
+	struct sk_buff *skb;
+	uint8_t no;
+};
+
+/**
  * struct batadv_orig_node - structure for orig_list maintaining nodes=
 of mesh
  * @orig: originator ethernet address
  * @primary_addr: hosts primary interface address
@@ -128,6 +156,7 @@ struct batadv_hard_iface {
  * @out_coding_list: list of nodes that can hear this orig
  * @in_coding_list_lock: protects in_coding_list
  * @out_coding_list_lock: protects out_coding_list
+ * @fragments: array with heads for fragment chains
  */
 struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
@@ -174,6 +203,7 @@ struct batadv_orig_node {
 	spinlock_t in_coding_list_lock; /* Protects in_coding_list */
 	spinlock_t out_coding_list_lock; /* Protects out_coding_list */
 #endif
+	struct batadv_frag_table_entry fragments[BATADV_FRAG_BUFFER_COUNT];
 };
=20
 /**
@@ -270,6 +300,10 @@ struct batadv_bcast_duplist_entry {
  * @BATADV_CNT_MGMT_TX_BYTES: transmitted routing protocol traffic byt=
es counter
  * @BATADV_CNT_MGMT_RX: received routing protocol traffic packet count=
er
  * @BATADV_CNT_MGMT_RX_BYTES: received routing protocol traffic bytes =
counter
+ * @BATADV_CNT_FRAG_RX: received fragment traffic packet counter
+ * @BATADV_CNT_FRAG_RX_BYTES: received fragment traffic bytes counter
+ * @BATADV_CNT_FRAG_FWD: forwarded fragment traffic packet counter
+ * @BATADV_CNT_FRAG_FWD_BYTES: forwarded fragment traffic bytes counte=
r
  * @BATADV_CNT_TT_REQUEST_TX: transmitted tt req traffic packet counte=
r
  * @BATADV_CNT_TT_REQUEST_RX: received tt req traffic packet counter
  * @BATADV_CNT_TT_RESPONSE_TX: transmitted tt resp traffic packet coun=
ter
@@ -307,6 +341,10 @@ enum batadv_counters {
 	BATADV_CNT_MGMT_TX_BYTES,
 	BATADV_CNT_MGMT_RX,
 	BATADV_CNT_MGMT_RX_BYTES,
+	BATADV_CNT_FRAG_RX,
+	BATADV_CNT_FRAG_RX_BYTES,
+	BATADV_CNT_FRAG_FWD,
+	BATADV_CNT_FRAG_FWD_BYTES,
 	BATADV_CNT_TT_REQUEST_TX,
 	BATADV_CNT_TT_REQUEST_RX,
 	BATADV_CNT_TT_RESPONSE_TX,
--=20
1.8.3.2
