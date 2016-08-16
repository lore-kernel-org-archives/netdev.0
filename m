From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 08/16] batman-adv: add B.A.T.M.A.N. IV bat_{orig, neigh}_dump implementations
Date: Tue, 16 Aug 2016 10:32:36 +0200
Message-ID: <1471336364-16334-9-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58626 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbcHPIda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:30 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven.eckelmann@open-mesh.com: Fix function parameter alignments,
add policy for attributes, fix includes, fix algo_ops integration]
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 include/uapi/linux/batman_adv.h |   4 +
 net/batman-adv/bat_iv_ogm.c     | 366 ++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/netlink.c        |   2 +
 3 files changed, 372 insertions(+)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 3f7a415..ba2359a 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -85,6 +85,8 @@ enum batadv_tt_client_flags {
  * @BATADV_ATTR_TT_FLAGS: Translation table client flags
  * @BATADV_ATTR_FLAG_BEST: Flags indicating entry is the best
  * @BATADV_ATTR_LAST_SEEN_MSECS: Time in milliseconds since last seen
+ * @BATADV_ATTR_NEIGH_ADDRESS: Neighbour MAC address
+ * @BATADV_ATTR_TQ: TQ to neighbour
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
@@ -114,6 +116,8 @@ enum batadv_nl_attrs {
 	BATADV_ATTR_TT_FLAGS,
 	BATADV_ATTR_FLAG_BEST,
 	BATADV_ATTR_LAST_SEEN_MSECS,
+	BATADV_ATTR_NEIGH_ADDRESS,
+	BATADV_ATTR_TQ,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a40cdf2..7a8c0f6 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -35,6 +35,7 @@
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/pkt_sched.h>
 #include <linux/printk.h>
 #include <linux/random.h>
@@ -48,6 +49,9 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <net/genetlink.h>
+#include <net/netlink.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
 #include "bitarray.h"
@@ -55,6 +59,7 @@
 #include "hard-interface.h"
 #include "hash.h"
 #include "log.h"
+#include "netlink.h"
 #include "network-coding.h"
 #include "originator.h"
 #include "packet.h"
@@ -1948,6 +1953,235 @@ next:
 }
 
 /**
+ * batadv_iv_ogm_neigh_get_tq_avg - Get the TQ average for a neighbour on a
+ *  given outgoing interface.
+ * @neigh_node: Neighbour of interest
+ * @if_outgoing: Outgoing interface of interest
+ * @tq_avg: Pointer of where to store the TQ average
+ *
+ * Return: False if no average TQ available, otherwise true.
+ */
+static bool
+batadv_iv_ogm_neigh_get_tq_avg(struct batadv_neigh_node *neigh_node,
+			       struct batadv_hard_iface *if_outgoing,
+			       u8 *tq_avg)
+{
+	struct batadv_neigh_ifinfo *n_ifinfo;
+
+	n_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+	if (!n_ifinfo)
+		return false;
+
+	*tq_avg = n_ifinfo->bat_iv.tq_avg;
+	batadv_neigh_ifinfo_put(n_ifinfo);
+
+	return true;
+}
+
+/**
+ * batadv_iv_ogm_orig_dump_subentry - Dump an originator subentry into a
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
+batadv_iv_ogm_orig_dump_subentry(struct sk_buff *msg, u32 portid, u32 seq,
+				 struct batadv_priv *bat_priv,
+				 struct batadv_hard_iface *if_outgoing,
+				 struct batadv_orig_node *orig_node,
+				 struct batadv_neigh_node *neigh_node,
+				 bool best)
+{
+	void *hdr;
+	u8 tq_avg;
+	unsigned int last_seen_msecs;
+
+	last_seen_msecs = jiffies_to_msecs(jiffies - orig_node->last_seen);
+
+	if (!batadv_iv_ogm_neigh_get_tq_avg(neigh_node, if_outgoing, &tq_avg))
+		return 0;
+
+	if (if_outgoing != BATADV_IF_DEFAULT &&
+	    if_outgoing != neigh_node->if_incoming)
+		return 0;
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI, BATADV_CMD_GET_ORIGINATORS);
+	if (!hdr)
+		return -ENOBUFS;
+
+	if (nla_put(msg, BATADV_ATTR_ORIG_ADDRESS, ETH_ALEN,
+		    orig_node->orig) ||
+	    nla_put(msg, BATADV_ATTR_NEIGH_ADDRESS, ETH_ALEN,
+		    neigh_node->addr) ||
+	    nla_put_u32(msg, BATADV_ATTR_HARD_IFINDEX,
+			neigh_node->if_incoming->net_dev->ifindex) ||
+	    nla_put_u8(msg, BATADV_ATTR_TQ, tq_avg) ||
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
+ * batadv_iv_ogm_orig_dump_entry - Dump an originator entry into a message
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
+batadv_iv_ogm_orig_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+			      struct batadv_priv *bat_priv,
+			      struct batadv_hard_iface *if_outgoing,
+			      struct batadv_orig_node *orig_node, int *sub_s)
+{
+	struct batadv_neigh_node *neigh_node_best;
+	struct batadv_neigh_node *neigh_node;
+	int sub = 0;
+	bool best;
+	u8 tq_avg_best;
+
+	neigh_node_best = batadv_orig_router_get(orig_node, if_outgoing);
+	if (!neigh_node_best)
+		goto out;
+
+	if (!batadv_iv_ogm_neigh_get_tq_avg(neigh_node_best, if_outgoing,
+					    &tq_avg_best))
+		goto out;
+
+	if (tq_avg_best == 0)
+		goto out;
+
+	hlist_for_each_entry_rcu(neigh_node, &orig_node->neigh_list, list) {
+		if (sub++ < *sub_s)
+			continue;
+
+		best = (neigh_node == neigh_node_best);
+
+		if (batadv_iv_ogm_orig_dump_subentry(msg, portid, seq,
+						     bat_priv, if_outgoing,
+						     orig_node, neigh_node,
+						     best)) {
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
+ * batadv_iv_ogm_orig_dump_bucket - Dump an originator bucket into a
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
+batadv_iv_ogm_orig_dump_bucket(struct sk_buff *msg, u32 portid, u32 seq,
+			       struct batadv_priv *bat_priv,
+			       struct batadv_hard_iface *if_outgoing,
+			       struct hlist_head *head, int *idx_s, int *sub)
+{
+	struct batadv_orig_node *orig_node;
+	int idx = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
+		if (idx++ < *idx_s)
+			continue;
+
+		if (batadv_iv_ogm_orig_dump_entry(msg, portid, seq, bat_priv,
+						  if_outgoing, orig_node,
+						  sub)) {
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
+ * batadv_iv_ogm_orig_dump - Dump the originators into a message
+ * @msg: Netlink message to dump into
+ * @cb: Control block containing additional options
+ * @bat_priv: The bat priv with all the soft interface information
+ * @if_outgoing: Limit dump to entries with this outgoing interface
+ */
+static void
+batadv_iv_ogm_orig_dump(struct sk_buff *msg, struct netlink_callback *cb,
+			struct batadv_priv *bat_priv,
+			struct batadv_hard_iface *if_outgoing)
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
+		if (batadv_iv_ogm_orig_dump_bucket(msg, portid,
+						   cb->nlh->nlmsg_seq,
+						   bat_priv, if_outgoing, head,
+						   &idx, &sub))
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
+/**
  * batadv_iv_hardif_neigh_print - print a single hop neighbour node
  * @seq: neighbour table seq_file struct
  * @hardif_neigh: hardif neighbour information
@@ -2044,6 +2278,136 @@ out:
 }
 
 /**
+ * batadv_iv_ogm_neigh_dump_neigh - Dump a neighbour into a netlink message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @hardif_neigh: Neighbour to be dumped
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_iv_ogm_neigh_dump_neigh(struct sk_buff *msg, u32 portid, u32 seq,
+			       struct batadv_hardif_neigh_node *hardif_neigh)
+{
+	void *hdr;
+	unsigned int last_seen_msecs;
+
+	last_seen_msecs = jiffies_to_msecs(jiffies - hardif_neigh->last_seen);
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI, BATADV_CMD_GET_NEIGHBORS);
+	if (!hdr)
+		return -ENOBUFS;
+
+	if (nla_put(msg, BATADV_ATTR_NEIGH_ADDRESS, ETH_ALEN,
+		    hardif_neigh->addr) ||
+	    nla_put_u32(msg, BATADV_ATTR_HARD_IFINDEX,
+			hardif_neigh->if_incoming->net_dev->ifindex) ||
+	    nla_put_u32(msg, BATADV_ATTR_LAST_SEEN_MSECS,
+			last_seen_msecs))
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
+ * batadv_iv_ogm_neigh_dump_hardif - Dump the neighbours of a hard interface
+ *  into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @hard_iface: Hard interface to dump the neighbours for
+ * @idx_s: Number of entries to skip
+ *
+ * This function assumes the caller holds rcu_read_lock().
+ *
+ * Return: Error code, or 0 on success
+ */
+static int
+batadv_iv_ogm_neigh_dump_hardif(struct sk_buff *msg, u32 portid, u32 seq,
+				struct batadv_priv *bat_priv,
+				struct batadv_hard_iface *hard_iface,
+				int *idx_s)
+{
+	struct batadv_hardif_neigh_node *hardif_neigh;
+	int idx = 0;
+
+	hlist_for_each_entry_rcu(hardif_neigh,
+				 &hard_iface->neigh_list, list) {
+		if (idx++ < *idx_s)
+			continue;
+
+		if (batadv_iv_ogm_neigh_dump_neigh(msg, portid, seq,
+						   hardif_neigh)) {
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
+ * batadv_iv_ogm_neigh_dump - Dump the neighbours into a message
+ * @msg: Netlink message to dump into
+ * @cb: Control block containing additional options
+ * @bat_priv: The bat priv with all the soft interface information
+ * @single_hardif: Limit dump to this hard interfaace
+ */
+static void
+batadv_iv_ogm_neigh_dump(struct sk_buff *msg, struct netlink_callback *cb,
+			 struct batadv_priv *bat_priv,
+			 struct batadv_hard_iface *single_hardif)
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
+			if (batadv_iv_ogm_neigh_dump_hardif(msg, portid,
+							    cb->nlh->nlmsg_seq,
+							    bat_priv,
+							    single_hardif,
+							    &idx) == 0)
+				i_hardif++;
+		}
+	} else {
+		list_for_each_entry_rcu(hard_iface, &batadv_hardif_list,
+					list) {
+			if (hard_iface->soft_iface != bat_priv->soft_iface)
+				continue;
+
+			if (i_hardif++ < i_hardif_s)
+				continue;
+
+			if (batadv_iv_ogm_neigh_dump_hardif(msg, portid,
+							    cb->nlh->nlmsg_seq,
+							    bat_priv,
+							    hard_iface, &idx)) {
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
  * batadv_iv_ogm_neigh_cmp - compare the metrics of two neighbors
  * @neigh1: the first neighbor object of the comparison
  * @if_outgoing1: outgoing interface for the first neighbor
@@ -2330,9 +2694,11 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 		.cmp = batadv_iv_ogm_neigh_cmp,
 		.is_similar_or_better = batadv_iv_ogm_neigh_is_sob,
 		.print = batadv_iv_neigh_print,
+		.dump = batadv_iv_ogm_neigh_dump,
 	},
 	.orig = {
 		.print = batadv_iv_ogm_orig_print,
+		.dump = batadv_iv_ogm_orig_dump,
 		.free = batadv_iv_ogm_orig_free,
 		.add_if = batadv_iv_ogm_orig_add_if,
 		.del_if = batadv_iv_ogm_orig_del_if,
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 8469fc4..0c7940c 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -84,6 +84,8 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_TT_FLAGS]		= { .type = NLA_U32 },
 	[BATADV_ATTR_FLAG_BEST]		= { .type = NLA_FLAG },
 	[BATADV_ATTR_LAST_SEEN_MSECS]	= { .type = NLA_U32 },
+	[BATADV_ATTR_NEIGH_ADDRESS]	= { .len = ETH_ALEN },
+	[BATADV_ATTR_TQ]		= { .type = NLA_U8 },
 };
 
 /**
-- 
2.8.1
