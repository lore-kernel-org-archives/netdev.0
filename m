From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 10/16] batman-adv: netlink: add gateway table queries
Date: Tue, 16 Aug 2016 10:32:38 +0200
Message-ID: <1471336364-16334-11-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58606 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbcHPIdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:31 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Add BATADV_CMD_GET_GATEWAYS commands, using handlers bat_gw_dump in
batadv_algo_ops. Will always return -EOPNOTSUPP for now, as no
implementations exist yet.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 include/uapi/linux/batman_adv.h |  8 ++++++
 net/batman-adv/gateway_client.c | 59 +++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/gateway_client.h |  2 ++
 net/batman-adv/netlink.c        | 10 +++++++
 net/batman-adv/types.h          |  3 +++
 5 files changed, 82 insertions(+)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 2e2747f..a13fc09 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -88,6 +88,9 @@ enum batadv_tt_client_flags {
  * @BATADV_ATTR_NEIGH_ADDRESS: Neighbour MAC address
  * @BATADV_ATTR_TQ: TQ to neighbour
  * @BATADV_ATTR_THROUGHPUT: Estimated throughput to Neighbour
+ * @BATADV_ATTR_BANDWIDTH_UP: Reported uplink bandwidth
+ * @BATADV_ATTR_BANDWIDTH_DOWN: Reported downlink bandwidth
+ * @BATADV_ATTR_ROUTER: Gateway router MAC address
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
@@ -120,6 +123,9 @@ enum batadv_nl_attrs {
 	BATADV_ATTR_NEIGH_ADDRESS,
 	BATADV_ATTR_TQ,
 	BATADV_ATTR_THROUGHPUT,
+	BATADV_ATTR_BANDWIDTH_UP,
+	BATADV_ATTR_BANDWIDTH_DOWN,
+	BATADV_ATTR_ROUTER,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
@@ -139,6 +145,7 @@ enum batadv_nl_attrs {
  * @BATADV_CMD_GET_TRANSTABLE_GLOBAL Query list of global translations
  * @BATADV_CMD_GET_ORIGINATORS: Query list of originators
  * @BATADV_CMD_GET_NEIGHBORS: Query list of neighbours
+ * @BATADV_CMD_GET_GATEWAYS: Query list of gateways
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
@@ -153,6 +160,7 @@ enum batadv_nl_commands {
 	BATADV_CMD_GET_TRANSTABLE_GLOBAL,
 	BATADV_CMD_GET_ORIGINATORS,
 	BATADV_CMD_GET_NEIGHBORS,
+	BATADV_CMD_GET_GATEWAYS,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index a77a179..c2928c2 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -20,6 +20,7 @@
 
 #include <linux/atomic.h>
 #include <linux/byteorder/generic.h>
+#include <linux/errno.h>
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
 #include <linux/if_ether.h>
@@ -31,6 +32,7 @@
 #include <linux/kref.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/seq_file.h>
@@ -39,13 +41,17 @@
 #include <linux/spinlock.h>
 #include <linux/stddef.h>
 #include <linux/udp.h>
+#include <net/sock.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "gateway_common.h"
 #include "hard-interface.h"
 #include "log.h"
+#include "netlink.h"
 #include "originator.h"
 #include "packet.h"
 #include "routing.h"
+#include "soft-interface.h"
 #include "sysfs.h"
 #include "translation-table.h"
 
@@ -501,6 +507,59 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 }
 
 /**
+ * batadv_gw_dump - Dump gateways into a message
+ * @msg: Netlink message to dump into
+ * @cb: Control block containing additional options
+ *
+ * Return: Error code, or length of message
+ */
+int batadv_gw_dump(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	struct batadv_hard_iface *primary_if = NULL;
+	struct net *net = sock_net(cb->skb->sk);
+	struct net_device *soft_iface;
+	struct batadv_priv *bat_priv;
+	int ifindex;
+	int ret;
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
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if || primary_if->if_status != BATADV_IF_ACTIVE) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	if (!bat_priv->algo_ops->gw.dump) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
+
+	bat_priv->algo_ops->gw.dump(msg, cb, bat_priv);
+
+	ret = msg->len;
+
+out:
+	if (primary_if)
+		batadv_hardif_put(primary_if);
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	return ret;
+}
+
+/**
  * batadv_gw_dhcp_recipient_get - check if a packet is a DHCP message
  * @skb: the packet to check
  * @header_len: a pointer to the batman-adv header size
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 6b40432..859166d 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -23,6 +23,7 @@
 #include <linux/types.h>
 
 struct batadv_tvlv_gateway_data;
+struct netlink_callback;
 struct seq_file;
 struct sk_buff;
 
@@ -43,6 +44,7 @@ void batadv_gw_node_put(struct batadv_gw_node *gw_node);
 struct batadv_gw_node *
 batadv_gw_get_selected_gw_node(struct batadv_priv *bat_priv);
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_gw_dump(struct sk_buff *msg, struct netlink_callback *cb);
 bool batadv_gw_out_of_range(struct batadv_priv *bat_priv, struct sk_buff *skb);
 enum batadv_dhcp_recipient
 batadv_gw_dhcp_recipient_get(struct sk_buff *skb, unsigned int *header_len,
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 025f2ec..c68ccb03 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -38,6 +38,7 @@
 #include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
+#include "gateway_client.h"
 #include "hard-interface.h"
 #include "originator.h"
 #include "soft-interface.h"
@@ -87,6 +88,9 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_NEIGH_ADDRESS]	= { .len = ETH_ALEN },
 	[BATADV_ATTR_TQ]		= { .type = NLA_U8 },
 	[BATADV_ATTR_THROUGHPUT]	= { .type = NLA_U32 },
+	[BATADV_ATTR_BANDWIDTH_UP]	= { .type = NLA_U32 },
+	[BATADV_ATTR_BANDWIDTH_DOWN]	= { .type = NLA_U32 },
+	[BATADV_ATTR_ROUTER]		= { .len = ETH_ALEN },
 };
 
 /**
@@ -570,6 +574,12 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.dumpit = batadv_hardif_neigh_dump,
 	},
+	{
+		.cmd = BATADV_CMD_GET_GATEWAYS,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_gw_dump,
+	},
 };
 
 /**
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 968023a..b5f01a3 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1469,6 +1469,7 @@ struct batadv_algo_orig_ops {
  * @is_eligible: check if a newly discovered GW is a potential candidate for
  *  the election as best GW (optional)
  * @print: print the gateway table (optional)
+ * @dump: dump gateways to a netlink socket (optional)
  */
 struct batadv_algo_gw_ops {
 	ssize_t (*store_sel_class)(struct batadv_priv *bat_priv, char *buff,
@@ -1480,6 +1481,8 @@ struct batadv_algo_gw_ops {
 			    struct batadv_orig_node *curr_gw_orig,
 			    struct batadv_orig_node *orig_node);
 	void (*print)(struct batadv_priv *bat_priv, struct seq_file *seq);
+	void (*dump)(struct sk_buff *msg, struct netlink_callback *cb,
+		     struct batadv_priv *priv);
 };
 
 /**
-- 
2.8.1
