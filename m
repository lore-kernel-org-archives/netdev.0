From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/12] batman-adv: Distributed ARP Table - create DHT helper functions
Date: Wed,  7 Nov 2012 20:11:35 +0100
Message-ID: <1352315502-20324-6-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44643 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324Ab2KGTMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:34 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add all the relevant functions in order to manage a Distributed Hash Table over
the B.A.T.M.A.N.-adv network. It will later be used to store several ARP entries
and implement DAT (Distributed ARP Table)

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/Makefile                |   1 +
 net/batman-adv/distributed-arp-table.c | 270 +++++++++++++++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h |  58 +++++++
 net/batman-adv/hard-interface.c        |   3 +
 net/batman-adv/main.h                  |   6 +
 net/batman-adv/originator.c            |   2 +
 net/batman-adv/types.h                 |  30 ++++
 net/batman-adv/unicast.c               |   8 +-
 net/batman-adv/unicast.h               |   4 +
 9 files changed, 378 insertions(+), 4 deletions(-)
 create mode 100644 net/batman-adv/distributed-arp-table.c
 create mode 100644 net/batman-adv/distributed-arp-table.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 8676d2b..7604159 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -23,6 +23,7 @@ batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
 batman-adv-y += debugfs.o
+batman-adv-y += distributed-arp-table.o
 batman-adv-y += gateway_client.o
 batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
new file mode 100644
index 0000000..ce39e8a
--- /dev/null
+++ b/net/batman-adv/distributed-arp-table.c
@@ -0,0 +1,270 @@
+/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+ *
+ * Antonio Quartulli
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
+#include <linux/if_ether.h>
+#include <linux/if_arp.h>
+
+#include "main.h"
+#include "distributed-arp-table.h"
+#include "hard-interface.h"
+#include "originator.h"
+#include "send.h"
+#include "types.h"
+#include "unicast.h"
+
+/**
+ * batadv_hash_dat - compute the hash value for an IP address
+ * @data: data to hash
+ * @size: size of the hash table
+ *
+ * Returns the selected index in the hash table for the given data
+ */
+static uint32_t batadv_hash_dat(const void *data, uint32_t size)
+{
+	const unsigned char *key = data;
+	uint32_t hash = 0;
+	size_t i;
+
+	for (i = 0; i < 4; i++) {
+		hash += key[i];
+		hash += (hash << 10);
+		hash ^= (hash >> 6);
+	}
+
+	hash += (hash << 3);
+	hash ^= (hash >> 11);
+	hash += (hash << 15);
+
+	return hash % size;
+}
+
+/**
+ * batadv_is_orig_node_eligible - check whether a node can be a DHT candidate
+ * @res: the array with the already selected candidates
+ * @select: number of already selected candidates
+ * @tmp_max: address of the currently evaluated node
+ * @max: current round max address
+ * @last_max: address of the last selected candidate
+ * @candidate: orig_node under evaluation
+ * @max_orig_node: last selected candidate
+ *
+ * Returns true if the node has been elected as next candidate or false othrwise
+ */
+static bool batadv_is_orig_node_eligible(struct batadv_dat_candidate *res,
+					 int select, batadv_dat_addr_t tmp_max,
+					 batadv_dat_addr_t max,
+					 batadv_dat_addr_t last_max,
+					 struct batadv_orig_node *candidate,
+					 struct batadv_orig_node *max_orig_node)
+{
+	bool ret = false;
+	int j;
+
+	/* Check if this node has already been selected... */
+	for (j = 0; j < select; j++)
+		if (res[j].orig_node == candidate)
+			break;
+	/* ..and possibly skip it */
+	if (j < select)
+		goto out;
+	/* sanity check: has it already been selected? This should not happen */
+	if (tmp_max > last_max)
+		goto out;
+	/* check if during this iteration an originator with a closer dht
+	 * address has already been found
+	 */
+	if (tmp_max < max)
+		goto out;
+	/* this is an hash collision with the temporary selected node. Choose
+	 * the one with the lowest address
+	 */
+	if ((tmp_max == max) &&
+	    (batadv_compare_eth(candidate->orig, max_orig_node->orig) > 0))
+		goto out;
+
+	ret = true;
+out:
+	return ret;
+}
+
+/**
+ * batadv_choose_next_candidate - select the next DHT candidate
+ * @bat_priv: the bat priv with all the soft interface information
+ * @cands: candidates array
+ * @select: number of candidates already present in the array
+ * @ip_key: key to look up in the DHT
+ * @last_max: pointer where the address of the selected candidate will be saved
+ */
+static void batadv_choose_next_candidate(struct batadv_priv *bat_priv,
+					 struct batadv_dat_candidate *cands,
+					 int select, batadv_dat_addr_t ip_key,
+					 batadv_dat_addr_t *last_max)
+{
+	batadv_dat_addr_t max = 0, tmp_max = 0;
+	struct batadv_orig_node *orig_node, *max_orig_node = NULL;
+	struct batadv_hashtable *hash = bat_priv->orig_hash;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	int i;
+
+	/* if no node is eligible as candidate, leave the candidate type as
+	 * NOT_FOUND
+	 */
+	cands[select].type = BATADV_DAT_CANDIDATE_NOT_FOUND;
+
+	/* iterate over the originator list and find the node with closest
+	 * dat_address which has not been selected yet
+	 */
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(orig_node, node, head, hash_entry) {
+			/* the dht space is a ring and addresses are unsigned */
+			tmp_max = BATADV_DAT_ADDR_MAX - orig_node->dat_addr +
+				  ip_key;
+
+			if (!batadv_is_orig_node_eligible(cands, select,
+							  tmp_max, max,
+							  *last_max, orig_node,
+							  max_orig_node))
+				continue;
+
+			if (!atomic_inc_not_zero(&orig_node->refcount))
+				continue;
+
+			max = tmp_max;
+			if (max_orig_node)
+				batadv_orig_node_free_ref(max_orig_node);
+			max_orig_node = orig_node;
+		}
+		rcu_read_unlock();
+	}
+	if (max_orig_node) {
+		cands[select].type = BATADV_DAT_CANDIDATE_ORIG;
+		cands[select].orig_node = max_orig_node;
+		batadv_dbg(BATADV_DBG_DAT, bat_priv,
+			   "dat_select_candidates() %d: selected %pM addr=%u dist=%u\n",
+			   select, max_orig_node->orig, max_orig_node->dat_addr,
+			   max);
+	}
+	*last_max = max;
+}
+
+/**
+ * batadv_dat_select_candidates - selects the nodes which the DHT message has to
+ * be sent to
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ip_dst: ipv4 to look up in the DHT
+ *
+ * An originator O is selected if and only if its DHT_ID value is one of three
+ * closest values (from the LEFT, with wrap around if needed) then the hash
+ * value of the key. ip_dst is the key.
+ *
+ * Returns the candidate array of size BATADV_DAT_CANDIDATE_NUM
+ */
+static struct batadv_dat_candidate *
+batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
+{
+	int select;
+	batadv_dat_addr_t last_max = BATADV_DAT_ADDR_MAX, ip_key;
+	struct batadv_dat_candidate *res;
+
+	if (!bat_priv->orig_hash)
+		return NULL;
+
+	res = kmalloc(BATADV_DAT_CANDIDATES_NUM * sizeof(*res), GFP_ATOMIC);
+	if (!res)
+		return NULL;
+
+	ip_key = (batadv_dat_addr_t)batadv_hash_dat(&ip_dst,
+						    BATADV_DAT_ADDR_MAX);
+
+	batadv_dbg(BATADV_DBG_DAT, bat_priv,
+		   "dat_select_candidates(): IP=%pI4 hash(IP)=%u\n", &ip_dst,
+		   ip_key);
+
+	for (select = 0; select < BATADV_DAT_CANDIDATES_NUM; select++)
+		batadv_choose_next_candidate(bat_priv, res, select, ip_key,
+					     &last_max);
+
+	return res;
+}
+
+/**
+ * batadv_dat_send_data - send a payload to the selected candidates
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: payload to send
+ * @ip: the DHT key
+ * @packet_subtype: unicast4addr packet subtype to use
+ *
+ * In this function the skb is copied by means of pskb_copy() and is sent as
+ * unicast packet to each of the selected candidates
+ *
+ * Returns true if the packet is sent to at least one candidate, false otherwise
+ */
+static bool batadv_dat_send_data(struct batadv_priv *bat_priv,
+				 struct sk_buff *skb, __be32 ip,
+				 int packet_subtype)
+{
+	int i;
+	bool ret = false;
+	int send_status;
+	struct batadv_neigh_node *neigh_node = NULL;
+	struct sk_buff *tmp_skb;
+	struct batadv_dat_candidate *cand;
+
+	cand = batadv_dat_select_candidates(bat_priv, ip);
+	if (!cand)
+		goto out;
+
+	batadv_dbg(BATADV_DBG_DAT, bat_priv, "DHT_SEND for %pI4\n", &ip);
+
+	for (i = 0; i < BATADV_DAT_CANDIDATES_NUM; i++) {
+		if (cand[i].type == BATADV_DAT_CANDIDATE_NOT_FOUND)
+			continue;
+
+		neigh_node = batadv_orig_node_get_router(cand[i].orig_node);
+		if (!neigh_node)
+			goto free_orig;
+
+		tmp_skb = pskb_copy(skb, GFP_ATOMIC);
+		if (!batadv_unicast_4addr_prepare_skb(bat_priv, tmp_skb,
+						      cand[i].orig_node,
+						      packet_subtype)) {
+			kfree_skb(tmp_skb);
+			goto free_neigh;
+		}
+
+		send_status = batadv_send_skb_packet(tmp_skb,
+						     neigh_node->if_incoming,
+						     neigh_node->addr);
+		if (send_status == NET_XMIT_SUCCESS)
+			/* packet sent to a candidate: return true */
+			ret = true;
+free_neigh:
+		batadv_neigh_node_free_ref(neigh_node);
+free_orig:
+		batadv_orig_node_free_ref(cand[i].orig_node);
+	}
+
+out:
+	kfree(cand);
+	return ret;
+}
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
new file mode 100644
index 0000000..ea9cbd8
--- /dev/null
+++ b/net/batman-adv/distributed-arp-table.h
@@ -0,0 +1,58 @@
+/* Copyright (C) 2011-2012 B.A.T.M.A.N. contributors:
+ *
+ * Antonio Quartulli
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
+#ifndef _NET_BATMAN_ADV_ARP_H_
+#define _NET_BATMAN_ADV_ARP_H_
+
+#include "types.h"
+#include "originator.h"
+
+#define BATADV_DAT_ADDR_MAX ((batadv_dat_addr_t)~(batadv_dat_addr_t)0)
+
+/**
+ * batadv_dat_init_orig_node_addr - assign a DAT address to the orig_node
+ * @orig_node: the node to assign the DAT address to
+ */
+static inline void
+batadv_dat_init_orig_node_addr(struct batadv_orig_node *orig_node)
+{
+	uint32_t addr;
+
+	addr = batadv_choose_orig(orig_node->orig, BATADV_DAT_ADDR_MAX);
+	orig_node->dat_addr = (batadv_dat_addr_t)addr;
+}
+
+/**
+ * batadv_dat_init_own_addr - assign a DAT address to the node itself
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: a pointer to the primary interface
+ */
+static inline void
+batadv_dat_init_own_addr(struct batadv_priv *bat_priv,
+			 struct batadv_hard_iface *primary_if)
+{
+	uint32_t addr;
+
+	addr = batadv_choose_orig(primary_if->net_dev->dev_addr,
+				  BATADV_DAT_ADDR_MAX);
+
+	bat_priv->dat.addr = (batadv_dat_addr_t)addr;
+}
+
+#endif /* _NET_BATMAN_ADV_ARP_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index fab9e41..6b7a5d3 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -18,6 +18,7 @@
  */
 
 #include "main.h"
+#include "distributed-arp-table.h"
 #include "hard-interface.h"
 #include "soft-interface.h"
 #include "send.h"
@@ -109,6 +110,8 @@ static void batadv_primary_if_update_addr(struct batadv_priv *bat_priv,
 	if (!primary_if)
 		goto out;
 
+	batadv_dat_init_own_addr(bat_priv, primary_if);
+
 	skb = bat_priv->vis.my_info->skb_packet;
 	vis_packet = (struct batadv_vis_packet *)skb->data;
 	memcpy(vis_packet->vis_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index c08724a..5699f2b 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -73,6 +73,9 @@
 
 #define BATADV_LOG_BUF_LEN 8192	  /* has to be a power of 2 */
 
+/* numbers of originator to contact for any PUT/GET DHT operation */
+#define BATADV_DAT_CANDIDATES_NUM 3
+
 #define BATADV_VIS_INTERVAL 5000	/* 5 seconds */
 
 /* how much worse secondary interfaces may be to be considered as bonding
@@ -117,6 +120,9 @@ enum batadv_uev_type {
 
 #define BATADV_GW_THRESHOLD	50
 
+#define BATADV_DAT_CANDIDATE_NOT_FOUND	0
+#define BATADV_DAT_CANDIDATE_ORIG	1
+
 /* Debug Messages */
 #ifdef pr_fmt
 #undef pr_fmt
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index d9c14b8..84930a4 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -18,6 +18,7 @@
  */
 
 #include "main.h"
+#include "distributed-arp-table.h"
 #include "originator.h"
 #include "hash.h"
 #include "translation-table.h"
@@ -223,6 +224,7 @@ struct batadv_orig_node *batadv_get_orig_node(struct batadv_priv *bat_priv,
 	orig_node->tt_poss_change = false;
 	orig_node->bat_priv = bat_priv;
 	memcpy(orig_node->orig, addr, ETH_ALEN);
+	batadv_dat_init_orig_node_addr(orig_node);
 	orig_node->router = NULL;
 	orig_node->tt_crc = 0;
 	atomic_set(&orig_node->last_ttvn, 0);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index faaebd6..b57d93b 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -28,6 +28,13 @@
 	(ETH_HLEN + max(sizeof(struct batadv_unicast_packet), \
 			sizeof(struct batadv_bcast_packet)))
 
+/* batadv_dat_addr_t is the type used for all DHT addresses. If it is changed,
+ * BATADV_DAT_ADDR_MAX is changed as well.
+ *
+ * *Please be careful: batadv_dat_addr_t must be UNSIGNED*
+ */
+#define batadv_dat_addr_t uint16_t
+
 /**
  * struct batadv_hard_iface_bat_iv - per hard interface B.A.T.M.A.N. IV data
  * @ogm_buff: buffer holding the OGM packet
@@ -73,6 +80,7 @@ struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
 	uint8_t primary_addr[ETH_ALEN];
 	struct batadv_neigh_node __rcu *router; /* rcu protected pointer */
+	batadv_dat_addr_t dat_addr;
 	unsigned long *bcast_own;
 	uint8_t *bcast_own_sum;
 	unsigned long last_seen;
@@ -238,6 +246,14 @@ struct batadv_priv_vis {
 	struct batadv_vis_info *my_info;
 };
 
+/**
+ * struct batadv_priv_dat - per mesh interface DAT private data
+ * @addr: node DAT address
+ */
+struct batadv_priv_dat {
+	batadv_dat_addr_t addr;
+};
+
 struct batadv_priv {
 	atomic_t mesh_state;
 	struct net_device_stats stats;
@@ -275,6 +291,7 @@ struct batadv_priv {
 	struct batadv_priv_gw gw;
 	struct batadv_priv_tt tt;
 	struct batadv_priv_vis vis;
+	struct batadv_priv_dat dat;
 };
 
 struct batadv_socket_client {
@@ -447,4 +464,17 @@ struct batadv_algo_ops {
 	void (*bat_ogm_emit)(struct batadv_forw_packet *forw_packet);
 };
 
+/**
+ * struct batadv_dat_candidate - candidate destination for DAT operations
+ * @type: the type of the selected candidate. It can one of the following:
+ *	  - BATADV_DAT_CANDIDATE_NOT_FOUND
+ *	  - BATADV_DAT_CANDIDATE_ORIG
+ * @orig_node: if type is BATADV_DAT_CANDIDATE_ORIG this field points to the
+ *	       corresponding originator node structure
+ */
+struct batadv_dat_candidate {
+	int type;
+	struct batadv_orig_node *orig_node;
+};
+
 #endif /* _NET_BATMAN_ADV_TYPES_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index c0d318b..c9a1f65 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -347,10 +347,10 @@ static bool batadv_unicast_prepare_skb(struct sk_buff *skb,
  *
  * Returns false if the payload could not be encapsulated or true otherwise
  */
-static bool batadv_unicast_4addr_prepare_skb(struct batadv_priv *bat_priv,
-					     struct sk_buff *skb,
-					     struct batadv_orig_node *orig,
-					     int packet_subtype)
+bool batadv_unicast_4addr_prepare_skb(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb,
+				      struct batadv_orig_node *orig,
+				      int packet_subtype)
 {
 	struct batadv_hard_iface *primary_if;
 	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
diff --git a/net/batman-adv/unicast.h b/net/batman-adv/unicast.h
index a88ed29..61abba5 100644
--- a/net/batman-adv/unicast.h
+++ b/net/batman-adv/unicast.h
@@ -32,6 +32,10 @@ void batadv_frag_list_free(struct list_head *head);
 int batadv_frag_send_skb(struct sk_buff *skb, struct batadv_priv *bat_priv,
 			 struct batadv_hard_iface *hard_iface,
 			 const uint8_t dstaddr[]);
+bool batadv_unicast_4addr_prepare_skb(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb,
+				      struct batadv_orig_node *orig_node,
+				      int packet_subtype);
 int batadv_unicast_generic_send_skb(struct batadv_priv *bat_priv,
 				    struct sk_buff *skb, int packet_type,
 				    int packet_subtype);
-- 
1.8.0
