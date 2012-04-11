From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 08/16] batman-adv: add basic bridge loop
	avoidance code
Date: Wed, 11 Apr 2012 14:50:41 +0200
Message-ID: <1334148649-25443-9-git-send-email-ordex@autistici.org>
References: <1334148649-25443-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1334148649-25443-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

This second version of the bridge loop avoidance for batman-adv
avoids loops between the mesh and a backbone (usually a LAN).

By connecting multiple batman-adv mesh nodes to the same ethernet
segment a loop can be created when the soft-interface is bridged
into that ethernet segment. A simple visualization of the loop
involving the most common case - a LAN as ethernet segment:

node1  <-- LAN  -->  node2
  |                   |
wifi   <-- mesh -->  wifi

Packets from the LAN (e.g. ARP broadcasts) will circle forever from
node1 or node2 over the mesh back into the LAN.

With this patch, batman recognizes backbone gateways, nodes which are
part of the mesh and backbone/LAN at the same time. Each backbone
gateway "claims" clients from within the mesh to handle them
exclusively. By restricting that only responsible backbone gateways
may handle their claimed clients traffic, loops are effectively
avoided.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 Documentation/networking/batman-adv.txt |   14 +-
 net/batman-adv/Kconfig                  |    2 +-
 net/batman-adv/Makefile                 |    1 +
 net/batman-adv/bat_sysfs.c              |    2 +-
 net/batman-adv/bridge_loop_avoidance.c  | 1296 +++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h  |   37 +
 net/batman-adv/hard-interface.c         |   18 +-
 net/batman-adv/main.c                   |    6 +
 net/batman-adv/main.h                   |    6 +-
 net/batman-adv/originator.c             |    1 +
 net/batman-adv/packet.h                 |   17 +
 net/batman-adv/routing.c                |    7 +
 net/batman-adv/soft-interface.c         |   12 +
 net/batman-adv/types.h                  |   27 +
 14 files changed, 1430 insertions(+), 16 deletions(-)
 create mode 100644 net/batman-adv/bridge_loop_avoidance.c
 create mode 100644 net/batman-adv/bridge_loop_avoidance.h

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 221ad0c..9523e9e 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -67,10 +67,11 @@ To deactivate an interface you have  to  write  "none"  into  its
 All  mesh  wide  settings  can be found in batman's own interface
 folder:
 
-#  ls  /sys/class/net/bat0/mesh/
-# aggregated_ogms   fragmentation gw_sel_class   vis_mode
-# ap_isolation      gw_bandwidth  hop_penalty
-# bonding           gw_mode       orig_interval
+# ls /sys/class/net/bat0/mesh/
+# aggregated_ogms        fragmentation          hop_penalty
+# ap_isolation           gw_bandwidth           log_level
+# bonding                gw_mode                orig_interval
+# bridge_loop_avoidance  gw_sel_class           vis_mode
 
 
 There is a special folder for debugging information:
@@ -202,12 +203,13 @@ abled  during run time. Following log_levels are defined:
 1 - Enable messages related to routing / flooding / broadcasting
 2 - Enable messages related to route added / changed / deleted
 4 - Enable messages related to translation table operations
-7 - Enable all messages
+8 - Enable messages related to bridge loop avoidance
+15 - enable all messages
 
 The debug output can be changed at runtime  using  the  file
 /sys/class/net/bat0/mesh/log_level. e.g.
 
-# echo 2 > /sys/class/net/bat0/mesh/log_level
+# echo 6 > /sys/class/net/bat0/mesh/log_level
 
 will enable debug messages for when routes change.
 
diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index a04d28f..6ff977c 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -4,7 +4,7 @@
 
 config BATMAN_ADV
 	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
-	depends on NET
+	depends on NET && INET
 	select CRC16
         default n
 	help
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 4e392eb..94b67fd 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -23,6 +23,7 @@ batman-adv-y += bat_debugfs.o
 batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bat_sysfs.o
 batman-adv-y += bitarray.o
+batman-adv-y += bridge_loop_avoidance.o
 batman-adv-y += gateway_client.o
 batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 68ff759..d12757f 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -398,7 +398,7 @@ BAT_ATTR_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
 static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, show_gw_bwidth,
 		store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 7, NULL);
+BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 15, NULL);
 #endif
 
 static struct bat_attribute *mesh_attrs[] = {
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
new file mode 100644
index 0000000..f84c892
--- /dev/null
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -0,0 +1,1296 @@
+/*
+ * Copyright (C) 2011 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich
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
+ *
+ */
+
+#include "main.h"
+#include "hash.h"
+#include "hard-interface.h"
+#include "originator.h"
+#include "bridge_loop_avoidance.h"
+#include "send.h"
+
+#include <linux/etherdevice.h>
+#include <linux/crc16.h>
+#include <linux/if_arp.h>
+#include <net/arp.h>
+#include <linux/if_vlan.h>
+
+static const uint8_t claim_dest[6] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
+static const uint8_t announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
+
+static void bla_periodic_work(struct work_struct *work);
+static void bla_send_announce(struct bat_priv *bat_priv,
+			      struct backbone_gw *backbone_gw);
+
+/* return the index of the claim */
+static inline uint32_t choose_claim(const void *data, uint32_t size)
+{
+	const unsigned char *key = data;
+	uint32_t hash = 0;
+	size_t i;
+
+	for (i = 0; i < ETH_ALEN + sizeof(short); i++) {
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
+/* return the index of the backbone gateway */
+static inline uint32_t choose_backbone_gw(const void *data, uint32_t size)
+{
+	const unsigned char *key = data;
+	uint32_t hash = 0;
+	size_t i;
+
+	for (i = 0; i < ETH_ALEN + sizeof(short); i++) {
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
+
+/* compares address and vid of two backbone gws */
+static int compare_backbone_gw(const struct hlist_node *node, const void *data2)
+{
+	const void *data1 = container_of(node, struct backbone_gw,
+					 hash_entry);
+
+	return (memcmp(data1, data2, ETH_ALEN + sizeof(short)) == 0 ? 1 : 0);
+}
+
+/* compares address and vid of two claims */
+static int compare_claim(const struct hlist_node *node, const void *data2)
+{
+	const void *data1 = container_of(node, struct claim,
+					 hash_entry);
+
+	return (memcmp(data1, data2, ETH_ALEN + sizeof(short)) == 0 ? 1 : 0);
+}
+
+/* free a backbone gw */
+static void backbone_gw_free_ref(struct backbone_gw *backbone_gw)
+{
+	if (atomic_dec_and_test(&backbone_gw->refcount))
+		kfree_rcu(backbone_gw, rcu);
+}
+
+/* finally deinitialize the claim */
+static void claim_free_rcu(struct rcu_head *rcu)
+{
+	struct claim *claim;
+
+	claim = container_of(rcu, struct claim, rcu);
+
+	backbone_gw_free_ref(claim->backbone_gw);
+	kfree(claim);
+}
+
+/* free a claim, call claim_free_rcu if its the last reference */
+static void claim_free_ref(struct claim *claim)
+{
+	if (atomic_dec_and_test(&claim->refcount))
+		call_rcu(&claim->rcu, claim_free_rcu);
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @data: search data (may be local/static data)
+ *
+ * looks for a claim in the hash, and returns it if found
+ * or NULL otherwise.
+ */
+static struct claim *claim_hash_find(struct bat_priv *bat_priv,
+				     struct claim *data)
+{
+	struct hashtable_t *hash = bat_priv->claim_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct claim *claim;
+	struct claim *claim_tmp = NULL;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	index = choose_claim(data, hash->size);
+	head = &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
+		if (!compare_claim(&claim->hash_entry, data))
+			continue;
+
+		if (!atomic_inc_not_zero(&claim->refcount))
+			continue;
+
+		claim_tmp = claim;
+		break;
+	}
+	rcu_read_unlock();
+
+	return claim_tmp;
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: the address of the originator
+ * @vid: the VLAN ID
+ *
+ * looks for a claim in the hash, and returns it if found
+ * or NULL otherwise.
+ */
+static struct backbone_gw *backbone_hash_find(struct bat_priv *bat_priv,
+					      uint8_t *addr, short vid)
+{
+	struct hashtable_t *hash = bat_priv->backbone_hash;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	struct backbone_gw search_entry, *backbone_gw;
+	struct backbone_gw *backbone_gw_tmp = NULL;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	memcpy(search_entry.orig, addr, ETH_ALEN);
+	search_entry.vid = vid;
+
+	index = choose_backbone_gw(&search_entry, hash->size);
+	head = &hash->table[index];
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
+		if (!compare_backbone_gw(&backbone_gw->hash_entry,
+					 &search_entry))
+			continue;
+
+		if (!atomic_inc_not_zero(&backbone_gw->refcount))
+			continue;
+
+		backbone_gw_tmp = backbone_gw;
+		break;
+	}
+	rcu_read_unlock();
+
+	return backbone_gw_tmp;
+}
+
+/* delete all claims for a backbone */
+static void bla_del_backbone_claims(struct backbone_gw *backbone_gw)
+{
+	struct hashtable_t *hash;
+	struct hlist_node *node, *node_tmp;
+	struct hlist_head *head;
+	struct claim *claim;
+	int i;
+	spinlock_t *list_lock;	/* protects write access to the hash lists */
+
+	hash = backbone_gw->bat_priv->claim_hash;
+	if (!hash)
+		return;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
+
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(claim, node, node_tmp,
+					  head, hash_entry) {
+
+			if (claim->backbone_gw != backbone_gw)
+				continue;
+
+			claim_free_ref(claim);
+			hlist_del_rcu(node);
+		}
+		spin_unlock_bh(list_lock);
+	}
+
+	/* all claims gone, intialize CRC */
+	backbone_gw->crc = BLA_CRC_INIT;
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the mac address to be announced within the claim
+ * @vid: the VLAN ID
+ * @claimtype: the type of the claim (CLAIM, UNCLAIM, ANNOUNCE, ...)
+ *
+ * sends a claim frame according to the provided info.
+ */
+static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
+			   short vid, int claimtype)
+{
+	struct sk_buff *skb;
+	struct ethhdr *ethhdr;
+	struct hard_iface *primary_if;
+	struct net_device *soft_iface;
+	uint8_t *hw_src;
+	struct bla_claim_dst local_claim_dest;
+	uint32_t zeroip = 0;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		return;
+
+	memcpy(&local_claim_dest, claim_dest, sizeof(local_claim_dest));
+	local_claim_dest.type = claimtype;
+
+	soft_iface = primary_if->soft_iface;
+
+	skb = arp_create(ARPOP_REPLY, ETH_P_ARP,
+			 /* IP DST: 0.0.0.0 */
+			 zeroip,
+			 primary_if->soft_iface,
+			 /* IP SRC: 0.0.0.0 */
+			 zeroip,
+			 /* Ethernet DST: Broadcast */
+			 NULL,
+			 /* Ethernet SRC/HW SRC:  originator mac */
+			 primary_if->net_dev->dev_addr,
+			 /* HW DST: FF:43:05:XX:00:00
+			  * with XX   = claim type
+			  */
+			 (uint8_t *)&local_claim_dest);
+
+	if (!skb)
+		goto out;
+
+	ethhdr = (struct ethhdr *)skb->data;
+	hw_src = (uint8_t *)ethhdr +
+		 sizeof(struct ethhdr) +
+		 sizeof(struct arphdr);
+
+	/* now we pretend that the client would have sent this ... */
+	switch (claimtype) {
+	case CLAIM_TYPE_ADD:
+		/* normal claim frame
+		 * set Ethernet SRC to the clients mac
+		 */
+		memcpy(ethhdr->h_source, mac, ETH_ALEN);
+		bat_dbg(DBG_BLA, bat_priv,
+			"bla_send_claim(): CLAIM %pM on vid %d\n", mac, vid);
+		break;
+	case CLAIM_TYPE_DEL:
+		/* unclaim frame
+		 * set HW SRC to the clients mac
+		 */
+		memcpy(hw_src, mac, ETH_ALEN);
+		bat_dbg(DBG_BLA, bat_priv,
+			"bla_send_claim(): UNCLAIM %pM on vid %d\n", mac, vid);
+		break;
+	case CLAIM_TYPE_ANNOUNCE:
+		/* announcement frame
+		 * set HW SRC to the special mac containg the crc
+		 */
+		memcpy(hw_src, mac, ETH_ALEN);
+		bat_dbg(DBG_BLA, bat_priv,
+			"bla_send_claim(): ANNOUNCE of %pM on vid %d\n",
+			ethhdr->h_source, vid);
+		break;
+	case CLAIM_TYPE_REQUEST:
+		/* request frame
+		 * set HW SRC to the special mac containg the crc
+		 */
+		memcpy(hw_src, mac, ETH_ALEN);
+		memcpy(ethhdr->h_dest, mac, ETH_ALEN);
+		bat_dbg(DBG_BLA, bat_priv,
+			"bla_send_claim(): REQUEST of %pM to %pMon vid %d\n",
+			ethhdr->h_source, ethhdr->h_dest, vid);
+		break;
+
+	}
+
+	if (vid != -1)
+		skb = vlan_insert_tag(skb, vid);
+
+	skb_reset_mac_header(skb);
+	skb->protocol = eth_type_trans(skb, soft_iface);
+	bat_priv->stats.rx_packets++;
+	bat_priv->stats.rx_bytes += skb->len + sizeof(struct ethhdr);
+	soft_iface->last_rx = jiffies;
+
+	netif_rx(skb);
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the mac address of the originator
+ * @vid: the VLAN ID
+ *
+ * searches for the backbone gw or creates a new one if it could not
+ * be found.
+ */
+static struct backbone_gw *bla_get_backbone_gw(struct bat_priv *bat_priv,
+					       uint8_t *orig, short vid)
+{
+	struct backbone_gw *entry;
+	int hash_added;
+
+	entry = backbone_hash_find(bat_priv, orig, vid);
+
+	if (entry)
+		return entry;
+
+	bat_dbg(DBG_BLA, bat_priv,
+		"bla_get_backbone_gw(): not found (%pM, %d), creating new entry\n",
+		orig, vid);
+
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
+	if (!entry)
+		return NULL;
+
+	entry->vid = vid;
+	entry->lasttime = jiffies;
+	entry->crc = BLA_CRC_INIT;
+	entry->bat_priv = bat_priv;
+	atomic_set(&entry->request_sent, 0);
+	memcpy(entry->orig, orig, ETH_ALEN);
+
+	/* one for the hash, one for returning */
+	atomic_set(&entry->refcount, 2);
+
+	hash_added = hash_add(bat_priv->backbone_hash, compare_backbone_gw,
+			      choose_backbone_gw, entry, &entry->hash_entry);
+
+	if (unlikely(hash_added != 0)) {
+		/* hash failed, free the structure */
+		kfree(entry);
+		return NULL;
+	}
+
+	return entry;
+}
+
+/* update or add the own backbone gw to make sure we announce
+ * where we receive other backbone gws
+ */
+static void bla_update_own_backbone_gw(struct bat_priv *bat_priv,
+				       struct hard_iface *primary_if,
+				       short vid)
+{
+	struct backbone_gw *backbone_gw;
+
+	backbone_gw = bla_get_backbone_gw(bat_priv,
+					  primary_if->net_dev->dev_addr, vid);
+	if (unlikely(!backbone_gw))
+		return;
+
+	backbone_gw->lasttime = jiffies;
+	backbone_gw_free_ref(backbone_gw);
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @vid: the vid where the request came on
+ *
+ * Repeat all of our own claims, and finally send an ANNOUNCE frame
+ * to allow the requester another check if the CRC is correct now.
+ */
+static void bla_answer_request(struct bat_priv *bat_priv,
+			       struct hard_iface *primary_if, short vid)
+{
+	struct hlist_node *node;
+	struct hlist_head *head;
+	struct hashtable_t *hash;
+	struct claim *claim;
+	struct backbone_gw *backbone_gw;
+	int i;
+
+	bat_dbg(DBG_BLA, bat_priv,
+		"bla_answer_request(): received a claim request, send all of our own claims again\n");
+
+	backbone_gw = backbone_hash_find(bat_priv,
+					 primary_if->net_dev->dev_addr, vid);
+	if (!backbone_gw)
+		return;
+
+	hash = bat_priv->claim_hash;
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
+			/* only own claims are interesting */
+			if (claim->backbone_gw != backbone_gw)
+				continue;
+
+			bla_send_claim(bat_priv, claim->addr, claim->vid,
+				       CLAIM_TYPE_ADD);
+		}
+		rcu_read_unlock();
+	}
+
+	/* finally, send an announcement frame */
+	bla_send_announce(bat_priv, backbone_gw);
+	backbone_gw_free_ref(backbone_gw);
+}
+
+/**
+ * @backbone_gw: the backbone gateway from whom we are out of sync
+ *
+ * When the crc is wrong, ask the backbone gateway for a full table update.
+ * After the request, it will repeat all of his own claims and finally
+ * send an announcement claim with which we can check again.
+ */
+static void bla_send_request(struct backbone_gw *backbone_gw)
+{
+	/* first, remove all old entries */
+	bla_del_backbone_claims(backbone_gw);
+
+	bat_dbg(DBG_BLA, backbone_gw->bat_priv,
+		"Sending REQUEST to %pM\n",
+		backbone_gw->orig);
+
+	/* send request */
+	bla_send_claim(backbone_gw->bat_priv, backbone_gw->orig,
+		       backbone_gw->vid, CLAIM_TYPE_REQUEST);
+
+	/* no local broadcasts should be sent or received, for now. */
+	if (!atomic_read(&backbone_gw->request_sent)) {
+		atomic_inc(&backbone_gw->bat_priv->bla_num_requests);
+		atomic_set(&backbone_gw->request_sent, 1);
+	}
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @backbone_gw: our backbone gateway which should be announced
+ *
+ * This function sends an announcement. It is called from multiple
+ * places.
+ */
+static void bla_send_announce(struct bat_priv *bat_priv,
+			      struct backbone_gw *backbone_gw)
+{
+	uint8_t mac[ETH_ALEN];
+	uint16_t crc;
+
+	memcpy(mac, announce_mac, 4);
+	crc = htons(backbone_gw->crc);
+	memcpy(&mac[4], (uint8_t *)&crc, 2);
+
+	bla_send_claim(bat_priv, mac, backbone_gw->vid, CLAIM_TYPE_ANNOUNCE);
+
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @mac: the mac address of the claim
+ * @vid: the VLAN ID of the frame
+ * @backbone_gw: the backbone gateway which claims it
+ *
+ * Adds a claim in the claim hash.
+ */
+static void bla_add_claim(struct bat_priv *bat_priv, const uint8_t *mac,
+			  const short vid, struct backbone_gw *backbone_gw)
+{
+	struct claim *claim;
+	struct claim search_claim;
+	int hash_added;
+
+	memcpy(search_claim.addr, mac, ETH_ALEN);
+	search_claim.vid = vid;
+	claim = claim_hash_find(bat_priv, &search_claim);
+
+	/* create a new claim entry if it does not exist yet. */
+	if (!claim) {
+		claim = kzalloc(sizeof(*claim), GFP_ATOMIC);
+		if (!claim)
+			return;
+
+		memcpy(claim->addr, mac, ETH_ALEN);
+		claim->vid = vid;
+		claim->lasttime = jiffies;
+		claim->backbone_gw = backbone_gw;
+
+		atomic_set(&claim->refcount, 2);
+		bat_dbg(DBG_BLA, bat_priv,
+			"bla_add_claim(): adding new entry %pM, vid %d to hash ...\n",
+			mac, vid);
+		hash_added = hash_add(bat_priv->claim_hash, compare_claim,
+				      choose_claim, claim, &claim->hash_entry);
+
+		if (unlikely(hash_added != 0)) {
+			/* only local changes happened. */
+			kfree(claim);
+			return;
+		}
+	} else {
+		claim->lasttime = jiffies;
+		if (claim->backbone_gw == backbone_gw)
+			/* no need to register a new backbone */
+			goto claim_free_ref;
+
+		bat_dbg(DBG_BLA, bat_priv,
+			"bla_add_claim(): changing ownership for %pM, vid %d\n",
+			mac, vid);
+
+		claim->backbone_gw->crc ^=
+			crc16(0, claim->addr, ETH_ALEN);
+		backbone_gw_free_ref(claim->backbone_gw);
+
+	}
+	/* set (new) backbone gw */
+	atomic_inc(&backbone_gw->refcount);
+	claim->backbone_gw = backbone_gw;
+
+	backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
+	backbone_gw->lasttime = jiffies;
+
+claim_free_ref:
+	claim_free_ref(claim);
+}
+
+/* Delete a claim from the claim hash which has the
+ * given mac address and vid.
+ */
+static void bla_del_claim(struct bat_priv *bat_priv, const uint8_t *mac,
+			  const short vid)
+{
+	struct claim search_claim, *claim;
+
+	memcpy(search_claim.addr, mac, ETH_ALEN);
+	search_claim.vid = vid;
+	claim = claim_hash_find(bat_priv, &search_claim);
+	if (!claim)
+		return;
+
+	bat_dbg(DBG_BLA, bat_priv, "bla_del_claim(): %pM, vid %d\n", mac, vid);
+
+	hash_remove(bat_priv->claim_hash, compare_claim, choose_claim, claim);
+	claim_free_ref(claim); /* reference from the hash is gone */
+
+	claim->backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
+
+	/* don't need the reference from hash_find() anymore */
+	claim_free_ref(claim);
+}
+
+/* check for ANNOUNCE frame, return 1 if handled */
+static int handle_announce(struct bat_priv *bat_priv,
+			   uint8_t *an_addr, uint8_t *backbone_addr, short vid)
+{
+	struct backbone_gw *backbone_gw;
+	uint16_t crc;
+
+	if (memcmp(an_addr, announce_mac, 4) != 0)
+		return 0;
+
+	backbone_gw = bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+
+	if (unlikely(!backbone_gw))
+		return 1;
+
+
+	/* handle as ANNOUNCE frame */
+	backbone_gw->lasttime = jiffies;
+	crc = ntohs(*((uint16_t *)(&an_addr[4])));
+
+	bat_dbg(DBG_BLA, bat_priv,
+		"handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %04x\n",
+		vid, backbone_gw->orig, crc);
+
+	if (backbone_gw->crc != crc) {
+		bat_dbg(DBG_BLA, backbone_gw->bat_priv,
+			"handle_announce(): CRC FAILED for %pM/%d (my = %04x, sent = %04x)\n",
+			backbone_gw->orig, backbone_gw->vid, backbone_gw->crc,
+			crc);
+
+		bla_send_request(backbone_gw);
+	} else {
+		/* if we have sent a request and the crc was OK,
+		 * we can allow traffic again.
+		 */
+		if (atomic_read(&backbone_gw->request_sent)) {
+			atomic_dec(&backbone_gw->bat_priv->bla_num_requests);
+			atomic_set(&backbone_gw->request_sent, 0);
+		}
+	}
+
+	backbone_gw_free_ref(backbone_gw);
+	return 1;
+}
+
+/* check for REQUEST frame, return 1 if handled */
+static int handle_request(struct bat_priv *bat_priv,
+			  struct hard_iface *primary_if,
+			  uint8_t *backbone_addr,
+			  struct ethhdr *ethhdr, short vid)
+{
+	/* check for REQUEST frame */
+	if (!compare_eth(backbone_addr, ethhdr->h_dest))
+		return 0;
+
+	/* sanity check, this should not happen on a normal switch,
+	 * we ignore it in this case.
+	 */
+	if (!compare_eth(ethhdr->h_dest, primary_if->net_dev->dev_addr))
+		return 1;
+
+	bat_dbg(DBG_BLA, bat_priv,
+		"handle_request(): REQUEST vid %d (sent by %pM)...\n",
+		vid, ethhdr->h_source);
+
+	bla_answer_request(bat_priv, primary_if, vid);
+	return 1;
+}
+
+/* check for UNCLAIM frame, return 1 if handled */
+static int handle_unclaim(struct bat_priv *bat_priv,
+			  struct hard_iface *primary_if,
+			  uint8_t *backbone_addr,
+			  uint8_t *claim_addr, short vid)
+{
+	struct backbone_gw *backbone_gw;
+
+	/* unclaim in any case if it is our own */
+	if (primary_if && compare_eth(backbone_addr,
+				      primary_if->net_dev->dev_addr))
+		bla_send_claim(bat_priv, claim_addr, vid, CLAIM_TYPE_DEL);
+
+	backbone_gw = backbone_hash_find(bat_priv, backbone_addr, vid);
+
+	if (!backbone_gw)
+		return 1;
+
+	/* this must be an UNCLAIM frame */
+	bat_dbg(DBG_BLA, bat_priv,
+		"handle_unclaim(): UNCLAIM %pM on vid %d (sent by %pM)...\n",
+		claim_addr, vid, backbone_gw->orig);
+
+	bla_del_claim(bat_priv, claim_addr, vid);
+	backbone_gw_free_ref(backbone_gw);
+	return 1;
+}
+
+/* check for CLAIM frame, return 1 if handled */
+static int handle_claim(struct bat_priv *bat_priv,
+			struct hard_iface *primary_if, uint8_t *backbone_addr,
+			uint8_t *claim_addr, short vid)
+{
+	struct backbone_gw *backbone_gw;
+
+	/* register the gateway if not yet available, and add the claim. */
+
+	backbone_gw = bla_get_backbone_gw(bat_priv, backbone_addr, vid);
+
+	if (unlikely(!backbone_gw))
+		return 1;
+
+	/* this must be a CLAIM frame */
+	bla_add_claim(bat_priv, claim_addr, vid, backbone_gw);
+	if (compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
+		bla_send_claim(bat_priv, claim_addr, vid, CLAIM_TYPE_ADD);
+
+	/* TODO: we could call something like tt_local_del() here. */
+
+	backbone_gw_free_ref(backbone_gw);
+	return 1;
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the frame to be checked
+ *
+ * Check if this is a claim frame, and process it accordingly.
+ *
+ * returns 1 if it was a claim frame, otherwise return 0 to
+ * tell the callee that it can use the frame on its own.
+ */
+static int bla_process_claim(struct bat_priv *bat_priv,
+			     struct hard_iface *primary_if,
+			     struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr;
+	struct vlan_ethhdr *vhdr;
+	struct arphdr *arphdr;
+	uint8_t *hw_src, *hw_dst;
+	struct bla_claim_dst *bla_dst;
+	uint16_t proto;
+	int headlen;
+	short vid = -1;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
+		vhdr = (struct vlan_ethhdr *)ethhdr;
+		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+		proto = ntohs(vhdr->h_vlan_encapsulated_proto);
+		headlen = sizeof(*vhdr);
+	} else {
+		proto = ntohs(ethhdr->h_proto);
+		headlen = sizeof(*ethhdr);
+	}
+
+	if (proto != ETH_P_ARP)
+		return 0; /* not a claim frame */
+
+	/* this must be a ARP frame. check if it is a claim. */
+
+	if (unlikely(!pskb_may_pull(skb, headlen + arp_hdr_len(skb->dev))))
+		return 0;
+
+	/* pskb_may_pull() may have modified the pointers, get ethhdr again */
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+	arphdr = (struct arphdr *)((uint8_t *)ethhdr + headlen);
+
+	/* Check whether the ARP frame carries a valid
+	 * IP information
+	 */
+
+	if (arphdr->ar_hrd != htons(ARPHRD_ETHER))
+		return 0;
+	if (arphdr->ar_pro != htons(ETH_P_IP))
+		return 0;
+	if (arphdr->ar_hln != ETH_ALEN)
+		return 0;
+	if (arphdr->ar_pln != 4)
+		return 0;
+
+	hw_src = (uint8_t *)arphdr + sizeof(struct arphdr);
+	hw_dst = hw_src + ETH_ALEN + 4;
+	bla_dst = (struct bla_claim_dst *)hw_dst;
+
+	/* check if it is a claim frame. */
+	if (memcmp(hw_dst, claim_dest, 3) != 0)
+		return 0;
+
+	/* become a backbone gw ourselves on this vlan if not happened yet */
+	bla_update_own_backbone_gw(bat_priv, primary_if, vid);
+
+	/* check for the different types of claim frames ... */
+	switch (bla_dst->type) {
+	case CLAIM_TYPE_ADD:
+		if (handle_claim(bat_priv, primary_if, hw_src,
+				 ethhdr->h_source, vid))
+			return 1;
+		break;
+	case CLAIM_TYPE_DEL:
+		if (handle_unclaim(bat_priv, primary_if,
+				   ethhdr->h_source, hw_src, vid))
+			return 1;
+		break;
+
+	case CLAIM_TYPE_ANNOUNCE:
+		if (handle_announce(bat_priv, hw_src, ethhdr->h_source, vid))
+			return 1;
+		break;
+	case CLAIM_TYPE_REQUEST:
+		if (handle_request(bat_priv, primary_if, hw_src, ethhdr, vid))
+			return 1;
+		break;
+	}
+
+	bat_dbg(DBG_BLA, bat_priv,
+		"bla_process_claim(): ERROR - this looks like a claim frame, but is useless. eth src %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
+		ethhdr->h_source, vid, hw_src, hw_dst);
+	return 1;
+}
+
+/* Check when we last heard from other nodes, and remove them in case of
+ * a time out, or clean all backbone gws if now is set.
+ */
+static void bla_purge_backbone_gw(struct bat_priv *bat_priv, int now)
+{
+	struct backbone_gw *backbone_gw;
+	struct hlist_node *node, *node_tmp;
+	struct hlist_head *head;
+	struct hashtable_t *hash;
+	spinlock_t *list_lock;	/* protects write access to the hash lists */
+	int i;
+
+	hash = bat_priv->backbone_hash;
+	if (!hash)
+		return;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+		list_lock = &hash->list_locks[i];
+
+		spin_lock_bh(list_lock);
+		hlist_for_each_entry_safe(backbone_gw, node, node_tmp,
+					  head, hash_entry) {
+			if (now)
+				goto purge_now;
+			if (!has_timed_out(backbone_gw->lasttime,
+					   BLA_BACKBONE_TIMEOUT))
+				continue;
+
+			bat_dbg(DBG_BLA, backbone_gw->bat_priv,
+				"bla_purge_backbone_gw(): backbone gw %pM timed out\n",
+				backbone_gw->orig);
+
+purge_now:
+			/* don't wait for the pending request anymore */
+			if (atomic_read(&backbone_gw->request_sent))
+				atomic_dec(&bat_priv->bla_num_requests);
+
+			bla_del_backbone_claims(backbone_gw);
+
+			hlist_del_rcu(node);
+			backbone_gw_free_ref(backbone_gw);
+		}
+		spin_unlock_bh(list_lock);
+	}
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the selected primary interface, may be NULL if now is set
+ * @now: whether the whole hash shall be wiped now
+ *
+ * Check when we heard last time from our own claims, and remove them in case of
+ * a time out, or clean all claims if now is set
+ */
+static void bla_purge_claims(struct bat_priv *bat_priv,
+			     struct hard_iface *primary_if, int now)
+{
+	struct claim *claim;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	struct hashtable_t *hash;
+	int i;
+
+	hash = bat_priv->claim_hash;
+	if (!hash)
+		return;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(claim, node, head, hash_entry) {
+			if (now)
+				goto purge_now;
+			if (!compare_eth(claim->backbone_gw->orig,
+					 primary_if->net_dev->dev_addr))
+				continue;
+			if (!has_timed_out(claim->lasttime,
+					   BLA_CLAIM_TIMEOUT))
+				continue;
+
+			bat_dbg(DBG_BLA, bat_priv,
+				"bla_purge_claims(): %pM, vid %d, time out\n",
+				claim->addr, claim->vid);
+
+purge_now:
+			handle_unclaim(bat_priv, primary_if,
+				       claim->backbone_gw->orig,
+				       claim->addr, claim->vid);
+		}
+		rcu_read_unlock();
+	}
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @primary_if: the new selected primary_if
+ * @oldif: the old primary interface, may be NULL
+ *
+ * Update the backbone gateways when the own orig address changes.
+ *
+ */
+void bla_update_orig_address(struct bat_priv *bat_priv,
+			     struct hard_iface *primary_if,
+			     struct hard_iface *oldif)
+{
+	struct backbone_gw *backbone_gw;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	struct hashtable_t *hash;
+	int i;
+
+	if (!oldif) {
+		bla_purge_claims(bat_priv, NULL, 1);
+		bla_purge_backbone_gw(bat_priv, 1);
+		return;
+	}
+
+	hash = bat_priv->backbone_hash;
+	if (!hash)
+		return;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
+			/* own orig still holds the old value. */
+			if (!compare_eth(backbone_gw->orig,
+					 oldif->net_dev->dev_addr))
+				continue;
+
+			memcpy(backbone_gw->orig,
+			       primary_if->net_dev->dev_addr, ETH_ALEN);
+			/* send an announce frame so others will ask for our
+			 * claims and update their tables.
+			 */
+			bla_send_announce(bat_priv, backbone_gw);
+		}
+		rcu_read_unlock();
+	}
+}
+
+
+
+/* (re)start the timer */
+static void bla_start_timer(struct bat_priv *bat_priv)
+{
+	INIT_DELAYED_WORK(&bat_priv->bla_work, bla_periodic_work);
+	queue_delayed_work(bat_event_workqueue, &bat_priv->bla_work,
+			   msecs_to_jiffies(BLA_PERIOD_LENGTH));
+}
+
+/* periodic work to do:
+ *  * purge structures when they are too old
+ *  * send announcements
+ */
+static void bla_periodic_work(struct work_struct *work)
+{
+	struct delayed_work *delayed_work =
+		container_of(work, struct delayed_work, work);
+	struct bat_priv *bat_priv =
+		container_of(delayed_work, struct bat_priv, bla_work);
+	struct hlist_node *node;
+	struct hlist_head *head;
+	struct backbone_gw *backbone_gw;
+	struct hashtable_t *hash;
+	struct hard_iface *primary_if;
+	int i;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	bla_purge_claims(bat_priv, primary_if, 0);
+	bla_purge_backbone_gw(bat_priv, 0);
+
+	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
+		goto out;
+
+	hash = bat_priv->backbone_hash;
+	if (!hash)
+		goto out;
+
+	for (i = 0; i < hash->size; i++) {
+		head = &hash->table[i];
+
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(backbone_gw, node, head, hash_entry) {
+			if (!compare_eth(backbone_gw->orig,
+					 primary_if->net_dev->dev_addr))
+				continue;
+
+			backbone_gw->lasttime = jiffies;
+
+			bla_send_announce(bat_priv, backbone_gw);
+		}
+		rcu_read_unlock();
+	}
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+
+	bla_start_timer(bat_priv);
+}
+
+/* initialize all bla structures */
+int bla_init(struct bat_priv *bat_priv)
+{
+	bat_dbg(DBG_BLA, bat_priv, "bla hash registering\n");
+
+	if (bat_priv->claim_hash)
+		return 1;
+
+	bat_priv->claim_hash = hash_new(128);
+	bat_priv->backbone_hash = hash_new(32);
+
+	if (!bat_priv->claim_hash || !bat_priv->backbone_hash)
+		return -1;
+
+	bat_dbg(DBG_BLA, bat_priv, "bla hashes initialized\n");
+
+	bla_start_timer(bat_priv);
+	return 1;
+}
+
+/**
+ * @skb: the frame to be checked
+ * @orig_node: the orig_node of the frame
+ * @hdr_size: maximum length of the frame
+ *
+ * bla_is_backbone_gw inspects the skb for the VLAN ID and returns 1
+ * if the orig_node is also a gateway on the soft interface, otherwise it
+ * returns 0.
+ *
+ */
+int bla_is_backbone_gw(struct sk_buff *skb,
+		       struct orig_node *orig_node, int hdr_size)
+{
+	struct ethhdr *ethhdr;
+	struct vlan_ethhdr *vhdr;
+	struct backbone_gw *backbone_gw;
+	short vid = -1;
+
+	if (!atomic_read(&orig_node->bat_priv->bridge_loop_avoidance))
+		return 0;
+
+	/* first, find out the vid. */
+	if (!pskb_may_pull(skb, hdr_size + sizeof(struct ethhdr)))
+		return 0;
+
+	ethhdr = (struct ethhdr *)(((uint8_t *)skb->data) + hdr_size);
+
+	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
+		if (!pskb_may_pull(skb, hdr_size + sizeof(struct vlan_ethhdr)))
+			return 0;
+
+		vhdr = (struct vlan_ethhdr *)(((uint8_t *)skb->data) +
+					      hdr_size);
+		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+	}
+
+	/* see if this originator is a backbone gw for this VLAN */
+
+	backbone_gw = backbone_hash_find(orig_node->bat_priv,
+					 orig_node->orig, vid);
+	if (!backbone_gw)
+		return 0;
+
+	backbone_gw_free_ref(backbone_gw);
+	return 1;
+}
+
+/* free all bla structures (for softinterface free or module unload) */
+void bla_free(struct bat_priv *bat_priv)
+{
+	struct hard_iface *primary_if;
+
+	cancel_delayed_work_sync(&bat_priv->bla_work);
+	primary_if = primary_if_get_selected(bat_priv);
+
+	if (bat_priv->claim_hash) {
+		bla_purge_claims(bat_priv, primary_if, 1);
+		hash_destroy(bat_priv->claim_hash);
+		bat_priv->claim_hash = NULL;
+	}
+	if (bat_priv->backbone_hash) {
+		bla_purge_backbone_gw(bat_priv, 1);
+		hash_destroy(bat_priv->backbone_hash);
+		bat_priv->backbone_hash = NULL;
+	}
+	if (primary_if)
+		hardif_free_ref(primary_if);
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the frame to be checked
+ * @vid: the VLAN ID of the frame
+ *
+ * bla_rx avoidance checks if:
+ *  * we have to race for a claim
+ *  * if the frame is allowed on the LAN
+ *
+ * in these cases, the skb is further handled by this function and
+ * returns 1, otherwise it returns 0 and the caller shall further
+ * process the skb.
+ *
+ */
+int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
+{
+	struct ethhdr *ethhdr;
+	struct claim search_claim, *claim = NULL;
+	struct hard_iface *primary_if;
+	int ret;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto handled;
+
+	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
+		goto allow;
+
+
+	if (unlikely(atomic_read(&bat_priv->bla_num_requests)))
+		/* don't allow broadcasts while requests are in flight */
+		if (is_multicast_ether_addr(ethhdr->h_dest))
+			goto handled;
+
+	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
+	search_claim.vid = vid;
+	claim = claim_hash_find(bat_priv, &search_claim);
+
+	if (!claim) {
+		/* possible optimization: race for a claim */
+		/* No claim exists yet, claim it for us!
+		 */
+		handle_claim(bat_priv, primary_if,
+			     primary_if->net_dev->dev_addr,
+			     ethhdr->h_source, vid);
+		goto allow;
+	}
+
+	/* if it is our own claim ... */
+	if (compare_eth(claim->backbone_gw->orig,
+			primary_if->net_dev->dev_addr)) {
+		/* ... allow it in any case */
+		claim->lasttime = jiffies;
+		goto allow;
+	}
+
+	/* if it is a broadcast ... */
+	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+		/* ... drop it. the responsible gateway is in charge. */
+		goto handled;
+	} else {
+		/* seems the client considers us as its best gateway.
+		 * send a claim and update the claim table
+		 * immediately.
+		 */
+		handle_claim(bat_priv, primary_if,
+			     primary_if->net_dev->dev_addr,
+			     ethhdr->h_source, vid);
+		goto allow;
+	}
+allow:
+	bla_update_own_backbone_gw(bat_priv, primary_if, vid);
+	ret = 0;
+	goto out;
+
+handled:
+	kfree_skb(skb);
+	ret = 1;
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	if (claim)
+		claim_free_ref(claim);
+	return ret;
+}
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the frame to be checked
+ * @vid: the VLAN ID of the frame
+ *
+ * bla_tx checks if:
+ *  * a claim was received which has to be processed
+ *  * the frame is allowed on the mesh
+ *
+ * in these cases, the skb is further handled by this function and
+ * returns 1, otherwise it returns 0 and the caller shall further
+ * process the skb.
+ *
+ */
+int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
+{
+	struct ethhdr *ethhdr;
+	struct claim search_claim, *claim = NULL;
+	struct hard_iface *primary_if;
+	int ret = 0;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
+		goto allow;
+
+	/* in VLAN case, the mac header might not be set. */
+	skb_reset_mac_header(skb);
+
+	if (bla_process_claim(bat_priv, primary_if, skb))
+		goto handled;
+
+	ethhdr = (struct ethhdr *)skb_mac_header(skb);
+
+	if (unlikely(atomic_read(&bat_priv->bla_num_requests)))
+		/* don't allow broadcasts while requests are in flight */
+		if (is_multicast_ether_addr(ethhdr->h_dest))
+			goto handled;
+
+	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
+	search_claim.vid = vid;
+
+	claim = claim_hash_find(bat_priv, &search_claim);
+
+	/* if no claim exists, allow it. */
+	if (!claim)
+		goto allow;
+
+	/* check if we are responsible. */
+	if (compare_eth(claim->backbone_gw->orig,
+			primary_if->net_dev->dev_addr)) {
+		/* if yes, the client has roamed and we have
+		 * to unclaim it.
+		 */
+		handle_unclaim(bat_priv, primary_if,
+			       primary_if->net_dev->dev_addr,
+			       ethhdr->h_source, vid);
+		goto allow;
+	}
+
+	/* check if it is a multicast/broadcast frame */
+	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+		/* drop it. the responsible gateway has forwarded it into
+		 * the backbone network.
+		 */
+		goto handled;
+	} else {
+		/* we must allow it. at least if we are
+		 * responsible for the DESTINATION.
+		 */
+		goto allow;
+	}
+allow:
+	bla_update_own_backbone_gw(bat_priv, primary_if, vid);
+	ret = 0;
+	goto out;
+handled:
+	ret = 1;
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	if (claim)
+		claim_free_ref(claim);
+	return ret;
+}
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
new file mode 100644
index 0000000..488d778
--- /dev/null
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -0,0 +1,37 @@
+/*
+ * Copyright (C) 2011 B.A.T.M.A.N. contributors:
+ *
+ * Simon Wunderlich
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
+ *
+ */
+
+#ifndef _NET_BATMAN_ADV_BLA_H_
+#define _NET_BATMAN_ADV_BLA_H_
+
+int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
+int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
+int bla_is_backbone_gw(struct sk_buff *skb,
+		       struct orig_node *orig_node, int hdr_size);
+void bla_update_orig_address(struct bat_priv *bat_priv,
+			     struct hard_iface *primary_if,
+			     struct hard_iface *oldif);
+int bla_init(struct bat_priv *bat_priv);
+void bla_free(struct bat_priv *bat_priv);
+
+#define BLA_CRC_INIT	0
+
+#endif /* ifndef _NET_BATMAN_ADV_BLA_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 3778977..8c4b790 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -28,6 +28,7 @@
 #include "bat_sysfs.h"
 #include "originator.h"
 #include "hash.h"
+#include "bridge_loop_avoidance.h"
 
 #include <linux/if_arp.h>
 
@@ -107,7 +108,8 @@ out:
 	return hard_iface;
 }
 
-static void primary_if_update_addr(struct bat_priv *bat_priv)
+static void primary_if_update_addr(struct bat_priv *bat_priv,
+				   struct hard_iface *oldif)
 {
 	struct vis_packet *vis_packet;
 	struct hard_iface *primary_if;
@@ -122,6 +124,7 @@ static void primary_if_update_addr(struct bat_priv *bat_priv)
 	memcpy(vis_packet->sender_orig,
 	       primary_if->net_dev->dev_addr, ETH_ALEN);
 
+	bla_update_orig_address(bat_priv, primary_if, oldif);
 out:
 	if (primary_if)
 		hardif_free_ref(primary_if);
@@ -140,14 +143,15 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	curr_hard_iface = rcu_dereference_protected(bat_priv->primary_if, 1);
 	rcu_assign_pointer(bat_priv->primary_if, new_hard_iface);
 
-	if (curr_hard_iface)
-		hardif_free_ref(curr_hard_iface);
-
 	if (!new_hard_iface)
-		return;
+		goto out;
 
 	bat_priv->bat_algo_ops->bat_ogm_init_primary(new_hard_iface);
-	primary_if_update_addr(bat_priv);
+	primary_if_update_addr(bat_priv, curr_hard_iface);
+
+out:
+	if (curr_hard_iface)
+		hardif_free_ref(curr_hard_iface);
 }
 
 static bool hardif_is_iface_up(const struct hard_iface *hard_iface)
@@ -531,7 +535,7 @@ static int hard_if_event(struct notifier_block *this,
 			goto hardif_put;
 
 		if (hard_iface == primary_if)
-			primary_if_update_addr(bat_priv);
+			primary_if_update_addr(bat_priv, NULL);
 		break;
 	default:
 		break;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 94d4968..e67ca96 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -30,6 +30,7 @@
 #include "translation-table.h"
 #include "hard-interface.h"
 #include "gateway_client.h"
+#include "bridge_loop_avoidance.h"
 #include "vis.h"
 #include "hash.h"
 #include "bat_algo.h"
@@ -115,6 +116,9 @@ int mesh_init(struct net_device *soft_iface)
 	if (vis_init(bat_priv) < 1)
 		goto err;
 
+	if (bla_init(bat_priv) < 1)
+		goto err;
+
 	atomic_set(&bat_priv->gw_reselect, 0);
 	atomic_set(&bat_priv->mesh_state, MESH_ACTIVE);
 	goto end;
@@ -142,6 +146,8 @@ void mesh_free(struct net_device *soft_iface)
 
 	tt_free(bat_priv);
 
+	bla_free(bat_priv);
+
 	atomic_set(&bat_priv->mesh_state, MESH_INACTIVE);
 }
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 7a6a25f..82723b5 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -80,6 +80,9 @@
 #define MAX_AGGREGATION_BYTES 512
 #define MAX_AGGREGATION_MS 100
 
+#define BLA_PERIOD_LENGTH	10000	/* 10 seconds */
+#define BLA_BACKBONE_TIMEOUT	(BLA_PERIOD_LENGTH * 3)
+#define BLA_CLAIM_TIMEOUT	(BLA_PERIOD_LENGTH * 10)
 /* don't reset again within 30 seconds */
 #define RESET_PROTECTION_MS 30000
 #define EXPECTED_SEQNO_RANGE	65536
@@ -117,7 +120,8 @@ enum dbg_level {
 	DBG_BATMAN = 1 << 0,
 	DBG_ROUTES = 1 << 1, /* route added / changed / deleted */
 	DBG_TT	   = 1 << 2, /* translation table operations */
-	DBG_ALL    = 7
+	DBG_BLA    = 1 << 3, /* bridge loop avoidance */
+	DBG_ALL    = 15
 };
 
 /* Kernel headers */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8239081..ce49698 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -28,6 +28,7 @@
 #include "hard-interface.h"
 #include "unicast.h"
 #include "soft-interface.h"
+#include "bridge_loop_avoidance.h"
 
 static void purge_orig(struct work_struct *work);
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 45e75ed..59800e8 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -90,6 +90,23 @@ enum tt_client_flags {
 	TT_CLIENT_PENDING = 1 << 10
 };
 
+/* claim frame types for the bridge loop avoidance */
+enum bla_claimframe {
+	CLAIM_TYPE_ADD		= 0x00,
+	CLAIM_TYPE_DEL		= 0x01,
+	CLAIM_TYPE_ANNOUNCE	= 0x02,
+	CLAIM_TYPE_REQUEST	= 0x03
+};
+
+/* the destination hardware field in the ARP frame is used to
+ * transport the claim type and the group id
+ */
+struct bla_claim_dst {
+	uint8_t magic[3];	/* FF:43:05 */
+	uint8_t type;		/* bla_claimframe */
+	uint16_t group;		/* group id */
+} __packed;
+
 struct batman_header {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 71d4211..a1d8c9b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -29,6 +29,7 @@
 #include "originator.h"
 #include "vis.h"
 #include "unicast.h"
+#include "bridge_loop_avoidance.h"
 
 static int route_unicast_packet(struct sk_buff *skb,
 				struct hard_iface *recv_if);
@@ -1071,6 +1072,12 @@ int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 	/* rebroadcast packet */
 	add_bcast_packet_to_list(bat_priv, skb, 1);
 
+	/* don't hand the broadcast up if it is from an originator
+	 * from the same backbone.
+	 */
+	if (bla_is_backbone_gw(skb, orig_node, hdr_size))
+		goto out;
+
 	/* broadcast for me */
 	interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size);
 	ret = NET_RX_SUCCESS;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e56cb88..4d639b3 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -36,6 +36,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
 #include "unicast.h"
+#include "bridge_loop_avoidance.h"
 
 
 static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
@@ -152,6 +153,9 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		goto dropped;
 	}
 
+	if (bla_tx(bat_priv, skb, vid))
+		goto dropped;
+
 	/* Register the client MAC in the transtable */
 	tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
 
@@ -287,6 +291,12 @@ void interface_rx(struct net_device *soft_iface,
 	if (is_ap_isolated(bat_priv, ethhdr->h_source, ethhdr->h_dest))
 		goto dropped;
 
+	/* Let the bridge loop avoidance check the packet. If will
+	 * not handle it, we can safely push it up.
+	 */
+	if (bla_rx(bat_priv, skb, vid))
+		goto out;
+
 	netif_rx(skb);
 	goto out;
 
@@ -354,6 +364,7 @@ struct net_device *softif_create(const char *name)
 
 	atomic_set(&bat_priv->aggregated_ogms, 1);
 	atomic_set(&bat_priv->bonding, 0);
+	atomic_set(&bat_priv->bridge_loop_avoidance, 0);
 	atomic_set(&bat_priv->ap_isolation, 0);
 	atomic_set(&bat_priv->vis_mode, VIS_TYPE_CLIENT_UPDATE);
 	atomic_set(&bat_priv->gw_mode, GW_MODE_OFF);
@@ -371,6 +382,7 @@ struct net_device *softif_create(const char *name)
 	atomic_set(&bat_priv->ttvn, 0);
 	atomic_set(&bat_priv->tt_local_changes, 0);
 	atomic_set(&bat_priv->tt_ogm_append_cnt, 0);
+	atomic_set(&bat_priv->bla_num_requests, 0);
 
 	bat_priv->tt_buff = NULL;
 	bat_priv->tt_buff_len = 0;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index feac2f4..089dd44 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -148,6 +148,7 @@ struct bat_priv {
 	atomic_t bonding;		/* boolean */
 	atomic_t fragmentation;		/* boolean */
 	atomic_t ap_isolation;		/* boolean */
+	atomic_t bridge_loop_avoidance;	/* boolean */
 	atomic_t vis_mode;		/* VIS_TYPE_* */
 	atomic_t gw_mode;		/* GW_MODE_* */
 	atomic_t gw_sel_class;		/* uint */
@@ -161,6 +162,7 @@ struct bat_priv {
 	atomic_t ttvn; /* translation table version number */
 	atomic_t tt_ogm_append_cnt;
 	atomic_t tt_local_changes; /* changes registered in a OGM interval */
+	atomic_t bla_num_requests; /* number of bla requests in flight */
 	/* The tt_poss_change flag is used to detect an ongoing roaming phase.
 	 * If true, then I received a Roaming_adv and I have to inspect every
 	 * packet directed to me to check whether I am still the true
@@ -179,6 +181,8 @@ struct bat_priv {
 	struct hashtable_t *orig_hash;
 	struct hashtable_t *tt_local_hash;
 	struct hashtable_t *tt_global_hash;
+	struct hashtable_t *claim_hash;
+	struct hashtable_t *backbone_hash;
 	struct list_head tt_req_list; /* list of pending tt_requests */
 	struct list_head tt_roam_list;
 	struct hashtable_t *vis_hash;
@@ -199,6 +203,7 @@ struct bat_priv {
 	struct delayed_work tt_work;
 	struct delayed_work orig_work;
 	struct delayed_work vis_work;
+	struct delayed_work bla_work;
 	struct gw_node __rcu *curr_gw;  /* rcu protected pointer */
 	atomic_t gw_reselect;
 	struct hard_iface __rcu *primary_if;  /* rcu protected pointer */
@@ -241,6 +246,28 @@ struct tt_global_entry {
 	unsigned long roam_at; /* time at which TT_GLOBAL_ROAM was set */
 };
 
+struct backbone_gw {
+	uint8_t orig[ETH_ALEN];
+	short vid;		/* used VLAN ID */
+	struct hlist_node hash_entry;
+	struct bat_priv *bat_priv;
+	unsigned long lasttime;	/* last time we heard of this backbone gw */
+	atomic_t request_sent;
+	atomic_t refcount;
+	struct rcu_head rcu;
+	uint16_t crc;		/* crc checksum over all claims */
+};
+
+struct claim {
+	uint8_t addr[ETH_ALEN];
+	short vid;
+	struct backbone_gw *backbone_gw;
+	unsigned long lasttime;	/* last time we heard of claim (locals only) */
+	struct rcu_head rcu;
+	atomic_t refcount;
+	struct hlist_node hash_entry;
+};
+
 struct tt_change_node {
 	struct list_head list;
 	struct tt_change change;
-- 
1.7.9.4
