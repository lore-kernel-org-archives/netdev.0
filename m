From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 13/16] batman-adv: add B.A.T.M.A.N. Dump BLA claims via netlink
Date: Tue, 16 Aug 2016 10:32:41 +0200
Message-ID: <1471336364-16334-14-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58606 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbcHPIde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:34 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

Dump the list of bridge loop avoidance claims via the netlink socket.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven.eckelmann@open-mesh.com: add policy for attributes, fix includes, fix
soft_iface reference leak]
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
[sw@simonwunderlich.de: fix kerneldoc, fix error reporting]
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 include/uapi/linux/batman_adv.h        |  12 +++
 net/batman-adv/bridge_loop_avoidance.c | 169 +++++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h |  10 +-
 net/batman-adv/netlink.c               |  12 +++
 4 files changed, 202 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index a13fc09..96b37ab 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -91,6 +91,11 @@ enum batadv_tt_client_flags {
  * @BATADV_ATTR_BANDWIDTH_UP: Reported uplink bandwidth
  * @BATADV_ATTR_BANDWIDTH_DOWN: Reported downlink bandwidth
  * @BATADV_ATTR_ROUTER: Gateway router MAC address
+ * @BATADV_ATTR_BLA_OWN: Flag indicating own originator
+ * @BATADV_ATTR_BLA_ADDRESS: Bridge loop avoidance claim MAC address
+ * @BATADV_ATTR_BLA_VID: BLA VLAN ID
+ * @BATADV_ATTR_BLA_BACKBONE: BLA gateway originator MAC address
+ * @BATADV_ATTR_BLA_CRC: BLA CRC
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
@@ -126,6 +131,11 @@ enum batadv_nl_attrs {
 	BATADV_ATTR_BANDWIDTH_UP,
 	BATADV_ATTR_BANDWIDTH_DOWN,
 	BATADV_ATTR_ROUTER,
+	BATADV_ATTR_BLA_OWN,
+	BATADV_ATTR_BLA_ADDRESS,
+	BATADV_ATTR_BLA_VID,
+	BATADV_ATTR_BLA_BACKBONE,
+	BATADV_ATTR_BLA_CRC,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
@@ -146,6 +156,7 @@ enum batadv_nl_attrs {
  * @BATADV_CMD_GET_ORIGINATORS: Query list of originators
  * @BATADV_CMD_GET_NEIGHBORS: Query list of neighbours
  * @BATADV_CMD_GET_GATEWAYS: Query list of gateways
+ * @BATADV_CMD_GET_BLA_CLAIM: Query list of bridge loop avoidance claims
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
@@ -161,6 +172,7 @@ enum batadv_nl_commands {
 	BATADV_CMD_GET_ORIGINATORS,
 	BATADV_CMD_GET_NEIGHBORS,
 	BATADV_CMD_GET_GATEWAYS,
+	BATADV_CMD_GET_BLA_CLAIM,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index c75ef648..aafa88f 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -35,6 +35,7 @@
 #include <linux/list.h>
 #include <linux/lockdep.h>
 #include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/seq_file.h>
@@ -45,12 +46,18 @@
 #include <linux/string.h>
 #include <linux/workqueue.h>
 #include <net/arp.h>
+#include <net/genetlink.h>
+#include <net/netlink.h>
+#include <net/sock.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "hard-interface.h"
 #include "hash.h"
 #include "log.h"
+#include "netlink.h"
 #include "originator.h"
 #include "packet.h"
+#include "soft-interface.h"
 #include "sysfs.h"
 #include "translation-table.h"
 
@@ -2052,6 +2059,168 @@ out:
 }
 
 /**
+ * batadv_bla_claim_dump_entry - dump one entry of the claim table
+ * to a netlink socket
+ * @msg: buffer for the message
+ * @portid: netlink port
+ * @seq: Sequence number of netlink message
+ * @primary_if: primary interface
+ * @claim: entry to dump
+ *
+ * Return: 0 or error code.
+ */
+static int
+batadv_bla_claim_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+			    struct batadv_hard_iface *primary_if,
+			    struct batadv_bla_claim *claim)
+{
+	u8 *primary_addr = primary_if->net_dev->dev_addr;
+	u16 backbone_crc;
+	bool is_own;
+	void *hdr;
+	int ret = -EINVAL;
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI, BATADV_CMD_GET_BLA_CLAIM);
+	if (!hdr) {
+		ret = -ENOBUFS;
+		goto out;
+	}
+
+	is_own = batadv_compare_eth(claim->backbone_gw->orig,
+				    primary_addr);
+
+	spin_lock_bh(&claim->backbone_gw->crc_lock);
+	backbone_crc = claim->backbone_gw->crc;
+	spin_unlock_bh(&claim->backbone_gw->crc_lock);
+
+	if (is_own)
+		if (nla_put_flag(msg, BATADV_ATTR_BLA_OWN)) {
+			genlmsg_cancel(msg, hdr);
+			goto out;
+		}
+
+	if (nla_put(msg, BATADV_ATTR_BLA_ADDRESS, ETH_ALEN, claim->addr) ||
+	    nla_put_u16(msg, BATADV_ATTR_BLA_VID, claim->vid) ||
+	    nla_put(msg, BATADV_ATTR_BLA_BACKBONE, ETH_ALEN,
+		    claim->backbone_gw->orig) ||
+	    nla_put_u16(msg, BATADV_ATTR_BLA_CRC,
+			backbone_crc)) {
+		genlmsg_cancel(msg, hdr);
+		goto out;
+	}
+
+	genlmsg_end(msg, hdr);
+	ret = 0;
+
+out:
+	return ret;
+}
+
+/**
+ * batadv_bla_claim_dump_bucket - dump one bucket of the claim table
+ * to a netlink socket
+ * @msg: buffer for the message
+ * @portid: netlink port
+ * @seq: Sequence number of netlink message
+ * @primary_if: primary interface
+ * @head: bucket to dump
+ * @idx_skip: How many entries to skip
+ *
+ * Return: always 0.
+ */
+static int
+batadv_bla_claim_dump_bucket(struct sk_buff *msg, u32 portid, u32 seq,
+			     struct batadv_hard_iface *primary_if,
+			     struct hlist_head *head, int *idx_skip)
+{
+	struct batadv_bla_claim *claim;
+	int idx = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(claim, head, hash_entry) {
+		if (idx++ < *idx_skip)
+			continue;
+		if (batadv_bla_claim_dump_entry(msg, portid, seq,
+						primary_if, claim)) {
+			*idx_skip = idx - 1;
+			goto unlock;
+		}
+	}
+
+	*idx_skip = idx;
+unlock:
+	rcu_read_unlock();
+	return 0;
+}
+
+/**
+ * batadv_bla_claim_dump - dump claim table to a netlink socket
+ * @msg: buffer for the message
+ * @cb: callback structure containing arguments
+ *
+ * Return: message length.
+ */
+int batadv_bla_claim_dump(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	struct batadv_hard_iface *primary_if = NULL;
+	int portid = NETLINK_CB(cb->skb).portid;
+	struct net *net = sock_net(cb->skb->sk);
+	struct net_device *soft_iface;
+	struct batadv_hashtable *hash;
+	struct batadv_priv *bat_priv;
+	int bucket = cb->args[0];
+	struct hlist_head *head;
+	int idx = cb->args[1];
+	int ifindex;
+	int ret = 0;
+
+	ifindex = batadv_netlink_get_ifindex(cb->nlh,
+					     BATADV_ATTR_MESH_IFINDEX);
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
+	hash = bat_priv->bla.claim_hash;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if || primary_if->if_status != BATADV_IF_ACTIVE) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	while (bucket < hash->size) {
+		head = &hash->table[bucket];
+
+		if (batadv_bla_claim_dump_bucket(msg, portid,
+						 cb->nlh->nlmsg_seq,
+						 primary_if, head, &idx))
+			break;
+		bucket++;
+	}
+
+	cb->args[0] = bucket;
+	cb->args[1] = idx;
+
+	ret = msg->len;
+
+out:
+	if (primary_if)
+		batadv_hardif_put(primary_if);
+
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	return ret;
+}
+
+/**
  * batadv_bla_backbone_table_seq_print_text - print the backbone table in a seq
  *  file
  * @seq: seq file to print on
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 0f01dae..a80b9e9 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -23,6 +23,7 @@
 #include <linux/types.h>
 
 struct net_device;
+struct netlink_callback;
 struct seq_file;
 struct sk_buff;
 
@@ -35,6 +36,7 @@ bool batadv_bla_is_backbone_gw(struct sk_buff *skb,
 			       struct batadv_orig_node *orig_node,
 			       int hdr_size);
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_bla_claim_dump(struct sk_buff *msg, struct netlink_callback *cb);
 int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
 					     void *offset);
 bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
@@ -47,7 +49,7 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 void batadv_bla_status_update(struct net_device *net_dev);
 int batadv_bla_init(struct batadv_priv *bat_priv);
 void batadv_bla_free(struct batadv_priv *bat_priv);
-
+int batadv_bla_claim_dump(struct sk_buff *msg, struct netlink_callback *cb);
 #define BATADV_BLA_CRC_INIT	0
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
 
@@ -112,6 +114,12 @@ static inline void batadv_bla_free(struct batadv_priv *bat_priv)
 {
 }
 
+static inline int batadv_bla_claim_dump(struct sk_buff *msg,
+					struct netlink_callback *cb)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif /* ifdef CONFIG_BATMAN_ADV_BLA */
 
 #endif /* ifndef _NET_BATMAN_ADV_BLA_H_ */
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index c68ccb03..b33675c 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -38,6 +38,7 @@
 #include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
+#include "bridge_loop_avoidance.h"
 #include "gateway_client.h"
 #include "hard-interface.h"
 #include "originator.h"
@@ -91,6 +92,11 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_BANDWIDTH_UP]	= { .type = NLA_U32 },
 	[BATADV_ATTR_BANDWIDTH_DOWN]	= { .type = NLA_U32 },
 	[BATADV_ATTR_ROUTER]		= { .len = ETH_ALEN },
+	[BATADV_ATTR_BLA_OWN]		= { .type = NLA_FLAG },
+	[BATADV_ATTR_BLA_ADDRESS]	= { .len = ETH_ALEN },
+	[BATADV_ATTR_BLA_VID]		= { .type = NLA_U16 },
+	[BATADV_ATTR_BLA_BACKBONE]	= { .len = ETH_ALEN },
+	[BATADV_ATTR_BLA_CRC]		= { .type = NLA_U16 },
 };
 
 /**
@@ -580,6 +586,12 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.dumpit = batadv_gw_dump,
 	},
+	{
+		.cmd = BATADV_CMD_GET_BLA_CLAIM,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_bla_claim_dump,
+	},
 };
 
 /**
-- 
2.8.1
