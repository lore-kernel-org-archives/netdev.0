From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 12/16] batman-adv: add B.A.T.M.A.N. V bat_gw_dump implementations
Date: Tue, 16 Aug 2016 10:32:40 +0200
Message-ID: <1471336364-16334-13-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58626 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbcHPIdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:33 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_v.c | 125 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 125 insertions(+)

diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 9dccfaf..9e872dc 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -897,6 +897,130 @@ static void batadv_v_gw_print(struct batadv_priv *bat_priv,
 		seq_puts(seq, "No gateways in range ...\n");
 }
 
+/**
+ * batadv_v_gw_dump_entry - Dump a gateway into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @bat_priv: The bat priv with all the soft interface information
+ * @gw_node: Gateway to be dumped
+ *
+ * Return: Error code, or 0 on success
+ */
+static int batadv_v_gw_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+				  struct batadv_priv *bat_priv,
+				  struct batadv_gw_node *gw_node)
+{
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
+	struct batadv_neigh_node *router;
+	struct batadv_gw_node *curr_gw;
+	int ret = -EINVAL;
+	void *hdr;
+
+	router = batadv_orig_router_get(gw_node->orig_node, BATADV_IF_DEFAULT);
+	if (!router)
+		goto out;
+
+	router_ifinfo = batadv_neigh_ifinfo_get(router, BATADV_IF_DEFAULT);
+	if (!router_ifinfo)
+		goto out;
+
+	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI, BATADV_CMD_GET_GATEWAYS);
+	if (!hdr) {
+		ret = -ENOBUFS;
+		goto out;
+	}
+
+	ret = -EMSGSIZE;
+
+	if (curr_gw == gw_node) {
+		if (nla_put_flag(msg, BATADV_ATTR_FLAG_BEST)) {
+			genlmsg_cancel(msg, hdr);
+			goto out;
+		}
+	}
+
+	if (nla_put(msg, BATADV_ATTR_ORIG_ADDRESS, ETH_ALEN,
+		    gw_node->orig_node->orig)) {
+		genlmsg_cancel(msg, hdr);
+		goto out;
+	}
+
+	if (nla_put_u32(msg, BATADV_ATTR_THROUGHPUT,
+			router_ifinfo->bat_v.throughput)) {
+		genlmsg_cancel(msg, hdr);
+		goto out;
+	}
+
+	if (nla_put(msg, BATADV_ATTR_ROUTER, ETH_ALEN, router->addr)) {
+		genlmsg_cancel(msg, hdr);
+		goto out;
+	}
+
+	if (nla_put_string(msg, BATADV_ATTR_HARD_IFNAME,
+			   router->if_incoming->net_dev->name)) {
+		genlmsg_cancel(msg, hdr);
+		goto out;
+	}
+
+	if (nla_put_u32(msg, BATADV_ATTR_BANDWIDTH_DOWN,
+			gw_node->bandwidth_down)) {
+		genlmsg_cancel(msg, hdr);
+		goto out;
+	}
+
+	if (nla_put_u32(msg, BATADV_ATTR_BANDWIDTH_UP, gw_node->bandwidth_up)) {
+		genlmsg_cancel(msg, hdr);
+		goto out;
+	}
+
+	genlmsg_end(msg, hdr);
+	ret = 0;
+
+out:
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_put(router_ifinfo);
+	if (router)
+		batadv_neigh_node_put(router);
+	return ret;
+}
+
+/**
+ * batadv_v_gw_dump - Dump gateways into a message
+ * @msg: Netlink message to dump into
+ * @cb: Control block containing additional options
+ * @bat_priv: The bat priv with all the soft interface information
+ */
+static void batadv_v_gw_dump(struct sk_buff *msg, struct netlink_callback *cb,
+			     struct batadv_priv *bat_priv)
+{
+	int portid = NETLINK_CB(cb->skb).portid;
+	struct batadv_gw_node *gw_node;
+	int idx_skip = cb->args[0];
+	int idx = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
+		if (idx++ < idx_skip)
+			continue;
+
+		if (batadv_v_gw_dump_entry(msg, portid, cb->nlh->nlmsg_seq,
+					   bat_priv, gw_node)) {
+			idx_skip = idx - 1;
+			goto unlock;
+		}
+	}
+
+	idx_skip = idx;
+unlock:
+	rcu_read_unlock();
+
+	cb->args[0] = idx_skip;
+}
+
 static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 	.name = "BATMAN_V",
 	.iface = {
@@ -923,6 +1047,7 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 		.get_best_gw_node = batadv_v_gw_get_best_gw_node,
 		.is_eligible = batadv_v_gw_is_eligible,
 		.print = batadv_v_gw_print,
+		.dump = batadv_v_gw_dump,
 	},
 };
 
-- 
2.8.1
