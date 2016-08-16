From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 09/16] batman-adv: add B.A.T.M.A.N. V bat_{orig, neigh}_dump implementations
Date: Tue, 16 Aug 2016 10:32:37 +0200
Message-ID: <1471336364-16334-10-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven@narfation.org>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58611 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269AbcHPIda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:30 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

Dump the algo V originators and neighbours.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven@narfation.org: Fix includes, fix algo_ops integration]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 include/uapi/linux/batman_adv.h |   2 +
 net/batman-adv/bat_v.c          | 340 ++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/netlink.c        |   1 +
 3 files changed, 343 insertions(+)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index ba2359a..2e2747f 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -87,6 +87,7 @@ enum batadv_tt_client_flags {
  * @BATADV_ATTR_LAST_SEEN_MSECS: Time in milliseconds since last seen
  * @BATADV_ATTR_NEIGH_ADDRESS: Neighbour MAC address
  * @BATADV_ATTR_TQ: TQ to neighbour
+ * @BATADV_ATTR_THROUGHPUT: Estimated throughput to Neighbour
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
@@ -118,6 +119,7 @@ enum batadv_nl_attrs {
 	BATADV_ATTR_LAST_SEEN_MSECS,
 	BATADV_ATTR_NEIGH_ADDRESS,
 	BATADV_ATTR_TQ,
+	BATADV_ATTR_THROUGHPUT,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 1d777b1..9dccfaf 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -22,17 +22,22 @@
 #include <linux/bug.h>
 #include <linux/cache.h>
 #include <linux/errno.h>
+#include <linux/if_ether.h>
 #include <linux/init.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
 #include <linux/kref.h>
 #include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/seq_file.h>
 #include <linux/stddef.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <net/genetlink.h>
+#include <net/netlink.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
 #include "bat_v_elp.h"
@@ -42,9 +47,12 @@
 #include "hard-interface.h"
 #include "hash.h"
 #include "log.h"
+#include "netlink.h"
 #include "originator.h"
 #include "packet.h"
 
+struct sk_buff;
+
 static void batadv_v_iface_activate(struct batadv_hard_iface *hard_iface)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
@@ -206,6 +214,138 @@ static void batadv_v_neigh_print(struct batadv_priv *bat_priv,
 }
 
 /**
+ * batadv_v_neigh_dump_neigh - Dump a neighbour into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @hardif_neigh: Neighbour to dump
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_v_neigh_dump_neigh(struct sk_buff *msg, u32 portid, u32 seq,
+			  struct batadv_hardif_neigh_node *hardif_neigh)
+{
+	void *hdr;
+	unsigned int last_seen_msecs;
+	u32 throughput;
+
+	last_seen_msecs = jiffies_to_msecs(jiffies - hardif_neigh->last_seen);
+	throughput = ewma_throughput_read(&hardif_neigh->bat_v.throughput);
+	throughput = throughput * 100;
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family, NLM_F_MULTI,
+			  BATADV_CMD_GET_NEIGHBORS);
+	if (!hdr)
+		return -ENOBUFS;
+
+	if (nla_put(msg, BATADV_ATTR_NEIGH_ADDRESS, ETH_ALEN,
+		    hardif_neigh->addr) ||
+	    nla_put_u32(msg, BATADV_ATTR_HARD_IFINDEX,
+			hardif_neigh->if_incoming->net_dev->ifindex) ||
+	    nla_put_u32(msg, BATADV_ATTR_LAST_SEEN_MSECS,
+			last_seen_msecs) ||
+	    nla_put_u32(msg, BATADV_ATTR_THROUGHPUT, throughput))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+ nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+/**
+ * batadv_v_neigh_dump_hardif - Dump the  neighbours of a hard interface  into
+ *  a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @hard_iface: The hard interface to be dumped
+ * @idx_s: Entries to be skipped
+ *
+ * This function assumes the caller holds rcu_read_lock().
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_v_neigh_dump_hardif(struct sk_buff *msg, u32 portid, u32 seq,
+			   struct batadv_priv *bat_priv,
+			   struct batadv_hard_iface *hard_iface,
+			   int *idx_s)
+{
+	struct batadv_hardif_neigh_node *hardif_neigh;
+	int idx = 0;
+
+	hlist_for_each_entry_rcu(hardif_neigh,
+				 &hard_iface->neigh_list, list) {
+		if (idx++ < *idx_s)
+			continue;
+
+		if (batadv_v_neigh_dump_neigh(msg, portid, seq, hardif_neigh)) {
+			*idx_s = idx - 1;
+			return -EMSGSIZE;
+		}
+	}
+
+	*idx_s = 0;
+	return 0;
+}
+
+/**
+ * batadv_v_neigh_dump - Dump the neighbours of a hard interface  into a
+ *  message
+ * @msg: Netlink message to dump into
+ * @cb: Control block containing additional options
+ * @bat_priv: The bat priv with all the soft interface information
+ * @single_hardif: Limit dumping to this hard interface
+ */
+static void
+batadv_v_neigh_dump(struct sk_buff *msg, struct netlink_callback *cb,
+		    struct batadv_priv *bat_priv,
+		    struct batadv_hard_iface *single_hardif)
+{
+	struct batadv_hard_iface *hard_iface;
+	int i_hardif = 0;
+	int i_hardif_s = cb->args[0];
+	int idx = cb->args[1];
+	int portid = NETLINK_CB(cb->skb).portid;
+
+	rcu_read_lock();
+	if (single_hardif) {
+		if (i_hardif_s == 0) {
+			if (batadv_v_neigh_dump_hardif(msg, portid,
+						       cb->nlh->nlmsg_seq,
+						       bat_priv, single_hardif,
+						       &idx) == 0)
+				i_hardif++;
+		}
+	} else {
+		list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+			if (hard_iface->soft_iface != bat_priv->soft_iface)
+				continue;
+
+			if (i_hardif++ < i_hardif_s)
+				continue;
+
+			if (batadv_v_neigh_dump_hardif(msg, portid,
+						       cb->nlh->nlmsg_seq,
+						       bat_priv, hard_iface,
+						       &idx)) {
+				i_hardif--;
+				break;
+			}
+		}
+	}
+	rcu_read_unlock();
+
+	cb->args[0] = i_hardif;
+	cb->args[1] = idx;
+}
+
+/**
  * batadv_v_orig_print - print the originator table
  * @bat_priv: the bat priv with all the soft interface information
  * @seq: debugfs table seq_file struct
@@ -272,6 +412,204 @@ next:
 		seq_puts(seq, "No batman nodes in range ...\n");
 }
 
+/**
+ * batadv_v_orig_dump_subentry - Dump an originator subentry into a
+ *  message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @if_outgoing: Limit dump to entries with this outgoing interface
+ * @orig_node: Originator to dump
+ * @neigh_node: Single hops neighbour
+ * @best: Is the best originator
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_v_orig_dump_subentry(struct sk_buff *msg, u32 portid, u32 seq,
+			    struct batadv_priv *bat_priv,
+			    struct batadv_hard_iface *if_outgoing,
+			    struct batadv_orig_node *orig_node,
+			    struct batadv_neigh_node *neigh_node,
+			    bool best)
+{
+	struct batadv_neigh_ifinfo *n_ifinfo;
+	unsigned int last_seen_msecs;
+	u32 throughput;
+	void *hdr;
+
+	n_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+	if (!n_ifinfo)
+		return 0;
+
+	throughput = n_ifinfo->bat_v.throughput * 100;
+
+	batadv_neigh_ifinfo_put(n_ifinfo);
+
+	last_seen_msecs = jiffies_to_msecs(jiffies - orig_node->last_seen);
+
+	if (if_outgoing != BATADV_IF_DEFAULT &&
+	    if_outgoing != neigh_node->if_incoming)
+		return 0;
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family, NLM_F_MULTI,
+			  BATADV_CMD_GET_ORIGINATORS);
+	if (!hdr)
+		return -ENOBUFS;
+
+	if (nla_put(msg, BATADV_ATTR_ORIG_ADDRESS, ETH_ALEN, orig_node->orig) ||
+	    nla_put(msg, BATADV_ATTR_NEIGH_ADDRESS, ETH_ALEN,
+		    neigh_node->addr) ||
+	    nla_put_u32(msg, BATADV_ATTR_HARD_IFINDEX,
+			neigh_node->if_incoming->net_dev->ifindex) ||
+	    nla_put_u32(msg, BATADV_ATTR_THROUGHPUT, throughput) ||
+	    nla_put_u32(msg, BATADV_ATTR_LAST_SEEN_MSECS,
+			last_seen_msecs))
+		goto nla_put_failure;
+
+	if (best && nla_put_flag(msg, BATADV_ATTR_FLAG_BEST))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+ nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+/**
+ * batadv_v_orig_dump_entry - Dump an originator entry into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @if_outgoing: Limit dump to entries with this outgoing interface
+ * @orig_node: Originator to dump
+ * @sub_s: Number of sub entries to skip
+ *
+ * This function assumes the caller holds rcu_read_lock().
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_v_orig_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+			 struct batadv_priv *bat_priv,
+			 struct batadv_hard_iface *if_outgoing,
+			 struct batadv_orig_node *orig_node, int *sub_s)
+{
+	struct batadv_neigh_node *neigh_node_best;
+	struct batadv_neigh_node *neigh_node;
+	int sub = 0;
+	bool best;
+
+	neigh_node_best = batadv_orig_router_get(orig_node, if_outgoing);
+	if (!neigh_node_best)
+		goto out;
+
+	hlist_for_each_entry_rcu(neigh_node, &orig_node->neigh_list, list) {
+		if (sub++ < *sub_s)
+			continue;
+
+		best = (neigh_node == neigh_node_best);
+
+		if (batadv_v_orig_dump_subentry(msg, portid, seq, bat_priv,
+						if_outgoing, orig_node,
+						neigh_node, best)) {
+			batadv_neigh_node_put(neigh_node_best);
+
+			*sub_s = sub - 1;
+			return -EMSGSIZE;
+		}
+	}
+
+ out:
+	if (neigh_node_best)
+		batadv_neigh_node_put(neigh_node_best);
+
+	*sub_s = 0;
+	return 0;
+}
+
+/**
+ * batadv_v_orig_dump_bucket - Dump an originator bucket into a
+ *  message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @if_outgoing: Limit dump to entries with this outgoing interface
+ * @head: Bucket to be dumped
+ * @idx_s: Number of entries to be skipped
+ * @sub: Number of sub entries to be skipped
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_v_orig_dump_bucket(struct sk_buff *msg, u32 portid, u32 seq,
+			  struct batadv_priv *bat_priv,
+			  struct batadv_hard_iface *if_outgoing,
+			  struct hlist_head *head, int *idx_s, int *sub)
+{
+	struct batadv_orig_node *orig_node;
+	int idx = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
+		if (idx++ < *idx_s)
+			continue;
+
+		if (batadv_v_orig_dump_entry(msg, portid, seq, bat_priv,
+					     if_outgoing, orig_node, sub)) {
+			rcu_read_unlock();
+			*idx_s = idx - 1;
+			return -EMSGSIZE;
+		}
+	}
+	rcu_read_unlock();
+
+	*idx_s = 0;
+	*sub = 0;
+	return 0;
+}
+
+/**
+ * batadv_v_orig_dump - Dump the originators into a message
+ * @msg: Netlink message to dump into
+ * @cb: Control block containing additional options
+ * @bat_priv: The bat priv with all the soft interface information
+ * @if_outgoing: Limit dump to entries with this outgoing interface
+ */
+static void
+batadv_v_orig_dump(struct sk_buff *msg, struct netlink_callback *cb,
+		   struct batadv_priv *bat_priv,
+		   struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_hashtable *hash = bat_priv->orig_hash;
+	struct hlist_head *head;
+	int bucket = cb->args[0];
+	int idx = cb->args[1];
+	int sub = cb->args[2];
+	int portid = NETLINK_CB(cb->skb).portid;
+
+	while (bucket < hash->size) {
+		head = &hash->table[bucket];
+
+		if (batadv_v_orig_dump_bucket(msg, portid,
+					      cb->nlh->nlmsg_seq,
+					      bat_priv, if_outgoing, head, &idx,
+					      &sub))
+			break;
+
+		bucket++;
+	}
+
+	cb->args[0] = bucket;
+	cb->args[1] = idx;
+	cb->args[2] = sub;
+}
+
 static int batadv_v_neigh_cmp(struct batadv_neigh_node *neigh1,
 			      struct batadv_hard_iface *if_outgoing1,
 			      struct batadv_neigh_node *neigh2,
@@ -573,9 +911,11 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 		.cmp = batadv_v_neigh_cmp,
 		.is_similar_or_better = batadv_v_neigh_is_sob,
 		.print = batadv_v_neigh_print,
+		.dump = batadv_v_neigh_dump,
 	},
 	.orig = {
 		.print = batadv_v_orig_print,
+		.dump = batadv_v_orig_dump,
 	},
 	.gw = {
 		.store_sel_class = batadv_v_store_sel_class,
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 0c7940c..025f2ec 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -86,6 +86,7 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_LAST_SEEN_MSECS]	= { .type = NLA_U32 },
 	[BATADV_ATTR_NEIGH_ADDRESS]	= { .len = ETH_ALEN },
 	[BATADV_ATTR_TQ]		= { .type = NLA_U8 },
+	[BATADV_ATTR_THROUGHPUT]	= { .type = NLA_U32 },
 };
 
 /**
-- 
2.8.1
