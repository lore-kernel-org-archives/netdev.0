From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 07/16] batman-adv: netlink: add originator and neighbor table queries
Date: Tue, 16 Aug 2016 10:32:35 +0200
Message-ID: <1471336364-16334-8-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven@narfation.org>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58618 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbcHPId2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:28 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

Add BATADV_CMD_GET_ORIGINATORS and BATADV_CMD_GET_NEIGHBORS commands,
using handlers bat_orig_dump and bat_neigh_dump in batadv_algo_ops. Will
always return -EOPNOTSUPP for now, as no implementations exist yet.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven@narfation.org: Rewrite based on new algo_ops structures]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 include/uapi/linux/batman_adv.h |   4 +
 net/batman-adv/netlink.c        |  13 ++++
 net/batman-adv/originator.c     | 160 ++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/originator.h     |   4 +
 net/batman-adv/types.h          |   9 +++
 5 files changed, 190 insertions(+)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 1168d05..3f7a415 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -131,6 +131,8 @@ enum batadv_nl_attrs {
  * @BATADV_CMD_GET_HARDIFS: Query list of hard interfaces
  * @BATADV_CMD_GET_TRANSTABLE_LOCAL: Query list of local translations
  * @BATADV_CMD_GET_TRANSTABLE_GLOBAL Query list of global translations
+ * @BATADV_CMD_GET_ORIGINATORS: Query list of originators
+ * @BATADV_CMD_GET_NEIGHBORS: Query list of neighbours
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
@@ -143,6 +145,8 @@ enum batadv_nl_commands {
 	BATADV_CMD_GET_HARDIFS,
 	BATADV_CMD_GET_TRANSTABLE_LOCAL,
 	BATADV_CMD_GET_TRANSTABLE_GLOBAL,
+	BATADV_CMD_GET_ORIGINATORS,
+	BATADV_CMD_GET_NEIGHBORS,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 0c0d20b..8469fc4 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -39,6 +39,7 @@
 
 #include "bat_algo.h"
 #include "hard-interface.h"
+#include "originator.h"
 #include "soft-interface.h"
 #include "tp_meter.h"
 #include "translation-table.h"
@@ -554,6 +555,18 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.dumpit = batadv_tt_global_dump,
 	},
+	{
+		.cmd = BATADV_CMD_GET_ORIGINATORS,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_orig_dump,
+	},
+	{
+		.cmd = BATADV_CMD_GET_NEIGHBORS,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_hardif_neigh_dump,
+	},
 };
 
 /**
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 3940b5d..95c8555 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -28,11 +28,15 @@
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <linux/seq_file.h>
+#include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
+#include <net/sock.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
 #include "distributed-arp-table.h"
@@ -42,8 +46,10 @@
 #include "hash.h"
 #include "log.h"
 #include "multicast.h"
+#include "netlink.h"
 #include "network-coding.h"
 #include "routing.h"
+#include "soft-interface.h"
 #include "translation-table.h"
 
 /* hash class keys */
@@ -721,6 +727,83 @@ int batadv_hardif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 }
 
 /**
+ * batadv_hardif_neigh_dump - Dump to netlink the neighbor infos for a specific
+ *  outgoing interface
+ * @msg: message to dump into
+ * @cb: parameters for the dump
+ *
+ * Return: 0 or error value
+ */
+int batadv_hardif_neigh_dump(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(cb->skb->sk);
+	struct net_device *soft_iface;
+	struct net_device *hard_iface = NULL;
+	struct batadv_hard_iface *hardif = BATADV_IF_DEFAULT;
+	struct batadv_priv *bat_priv;
+	struct batadv_hard_iface *primary_if = NULL;
+	int ret;
+	int ifindex, hard_ifindex;
+
+	ifindex = batadv_netlink_get_ifindex(cb->nlh, BATADV_ATTR_MESH_IFINDEX);
+	if (!ifindex)
+		return -EINVAL;
+
+	soft_iface = dev_get_by_index(net, ifindex);
+	if (!soft_iface || !batadv_softif_is_valid(soft_iface)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	bat_priv = netdev_priv(soft_iface);
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if || primary_if->if_status != BATADV_IF_ACTIVE) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	hard_ifindex = batadv_netlink_get_ifindex(cb->nlh,
+						  BATADV_ATTR_HARD_IFINDEX);
+	if (hard_ifindex) {
+		hard_iface = dev_get_by_index(net, hard_ifindex);
+		if (hard_iface)
+			hardif = batadv_hardif_get_by_netdev(hard_iface);
+
+		if (!hardif) {
+			ret = -ENODEV;
+			goto out;
+		}
+
+		if (hardif->soft_iface != soft_iface) {
+			ret = -ENOENT;
+			goto out;
+		}
+	}
+
+	if (!bat_priv->algo_ops->neigh.dump) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
+
+	bat_priv->algo_ops->neigh.dump(msg, cb, bat_priv, hardif);
+
+	ret = msg->len;
+
+ out:
+	if (hardif)
+		batadv_hardif_put(hardif);
+	if (hard_iface)
+		dev_put(hard_iface);
+	if (primary_if)
+		batadv_hardif_put(primary_if);
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	return ret;
+}
+
+/**
  * batadv_orig_ifinfo_release - release orig_ifinfo from lists and queue for
  *  free after rcu grace period
  * @ref: kref pointer of the orig_ifinfo
@@ -1330,6 +1413,83 @@ out:
 	return 0;
 }
 
+/**
+ * batadv_orig_dump - Dump to netlink the originator infos for a specific
+ *  outgoing interface
+ * @msg: message to dump into
+ * @cb: parameters for the dump
+ *
+ * Return: 0 or error value
+ */
+int batadv_orig_dump(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(cb->skb->sk);
+	struct net_device *soft_iface;
+	struct net_device *hard_iface = NULL;
+	struct batadv_hard_iface *hardif = BATADV_IF_DEFAULT;
+	struct batadv_priv *bat_priv;
+	struct batadv_hard_iface *primary_if = NULL;
+	int ret;
+	int ifindex, hard_ifindex;
+
+	ifindex = batadv_netlink_get_ifindex(cb->nlh, BATADV_ATTR_MESH_IFINDEX);
+	if (!ifindex)
+		return -EINVAL;
+
+	soft_iface = dev_get_by_index(net, ifindex);
+	if (!soft_iface || !batadv_softif_is_valid(soft_iface)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	bat_priv = netdev_priv(soft_iface);
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if || primary_if->if_status != BATADV_IF_ACTIVE) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	hard_ifindex = batadv_netlink_get_ifindex(cb->nlh,
+						  BATADV_ATTR_HARD_IFINDEX);
+	if (hard_ifindex) {
+		hard_iface = dev_get_by_index(net, hard_ifindex);
+		if (hard_iface)
+			hardif = batadv_hardif_get_by_netdev(hard_iface);
+
+		if (!hardif) {
+			ret = -ENODEV;
+			goto out;
+		}
+
+		if (hardif->soft_iface != soft_iface) {
+			ret = -ENOENT;
+			goto out;
+		}
+	}
+
+	if (!bat_priv->algo_ops->orig.dump) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
+
+	bat_priv->algo_ops->orig.dump(msg, cb, bat_priv, hardif);
+
+	ret = msg->len;
+
+ out:
+	if (hardif)
+		batadv_hardif_put(hardif);
+	if (hard_iface)
+		dev_put(hard_iface);
+	if (primary_if)
+		batadv_hardif_put(primary_if);
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	return ret;
+}
+
 int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num)
 {
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index 566306b..ebc5618 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -31,7 +31,9 @@
 
 #include "hash.h"
 
+struct netlink_callback;
 struct seq_file;
+struct sk_buff;
 
 bool batadv_compare_orig(const struct hlist_node *node, const void *data2);
 int batadv_originator_init(struct batadv_priv *bat_priv);
@@ -61,6 +63,7 @@ batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
 			struct batadv_hard_iface *if_outgoing);
 void batadv_neigh_ifinfo_put(struct batadv_neigh_ifinfo *neigh_ifinfo);
 
+int batadv_hardif_neigh_dump(struct sk_buff *msg, struct netlink_callback *cb);
 int batadv_hardif_neigh_seq_print_text(struct seq_file *seq, void *offset);
 
 struct batadv_orig_ifinfo *
@@ -72,6 +75,7 @@ batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
 void batadv_orig_ifinfo_put(struct batadv_orig_ifinfo *orig_ifinfo);
 
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_orig_dump(struct sk_buff *msg, struct netlink_callback *cb);
 int batadv_orig_hardif_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_orig_hash_add_if(struct batadv_hard_iface *hard_iface,
 			    int max_if_num);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 72806a3..968023a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -28,6 +28,7 @@
 #include <linux/if_ether.h>
 #include <linux/kref.h>
 #include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/sched.h> /* for linux/wait.h */
 #include <linux/spinlock.h>
 #include <linux/types.h>
@@ -1418,6 +1419,7 @@ struct batadv_algo_iface_ops {
  * @is_similar_or_better: check if neigh1 is equally similar or better than
  *  neigh2 for their respective outgoing interface from the metric prospective
  * @print: print the single hop neighbor list (optional)
+ * @dump: dump neighbors to a netlink socket (optional)
  */
 struct batadv_algo_neigh_ops {
 	void (*hardif_init)(struct batadv_hardif_neigh_node *neigh);
@@ -1430,6 +1432,9 @@ struct batadv_algo_neigh_ops {
 				     struct batadv_neigh_node *neigh2,
 				     struct batadv_hard_iface *if_outgoing2);
 	void (*print)(struct batadv_priv *priv, struct seq_file *seq);
+	void (*dump)(struct sk_buff *msg, struct netlink_callback *cb,
+		     struct batadv_priv *priv,
+		     struct batadv_hard_iface *hard_iface);
 };
 
 /**
@@ -1441,6 +1446,7 @@ struct batadv_algo_neigh_ops {
  * @del_if: ask the routing algorithm to apply the needed changes to the
  *  orig_node due to an hard-interface being removed from the mesh (optional)
  * @print: print the originator table (optional)
+ * @dump: dump originators to a netlink socket (optional)
  */
 struct batadv_algo_orig_ops {
 	void (*free)(struct batadv_orig_node *orig_node);
@@ -1449,6 +1455,9 @@ struct batadv_algo_orig_ops {
 		      int del_if_num);
 	void (*print)(struct batadv_priv *priv, struct seq_file *seq,
 		      struct batadv_hard_iface *hard_iface);
+	void (*dump)(struct sk_buff *msg, struct netlink_callback *cb,
+		     struct batadv_priv *priv,
+		     struct batadv_hard_iface *hard_iface);
 };
 
 /**
-- 
2.8.1
