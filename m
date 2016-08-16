From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 15/16] batman-adv: add backbone table netlink support
Date: Tue, 16 Aug 2016 10:32:43 +0200
Message-ID: <1471336364-16334-16-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58666 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbcHPIdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:37 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump the list of bridge loop avoidance backbones via the netlink socket.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 include/uapi/linux/batman_adv.h        |   2 +
 net/batman-adv/bridge_loop_avoidance.c | 164 +++++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h |   7 ++
 net/batman-adv/netlink.c               |   7 ++
 4 files changed, 180 insertions(+)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 96b37ab..734fe83 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -157,6 +157,7 @@ enum batadv_nl_attrs {
  * @BATADV_CMD_GET_NEIGHBORS: Query list of neighbours
  * @BATADV_CMD_GET_GATEWAYS: Query list of gateways
  * @BATADV_CMD_GET_BLA_CLAIM: Query list of bridge loop avoidance claims
+ * @BATADV_CMD_GET_BLA_BACKBONE: Query list of bridge loop avoidance backbones
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
@@ -173,6 +174,7 @@ enum batadv_nl_commands {
 	BATADV_CMD_GET_NEIGHBORS,
 	BATADV_CMD_GET_GATEWAYS,
 	BATADV_CMD_GET_BLA_CLAIM,
+	BATADV_CMD_GET_BLA_BACKBONE,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index aafa88f..35ed1d3 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -2283,3 +2283,167 @@ out:
 		batadv_hardif_put(primary_if);
 	return 0;
 }
+
+/**
+ * batadv_bla_backbone_dump_entry - dump one entry of the backbone table
+ * to a netlink socket
+ * @msg: buffer for the message
+ * @portid: netlink port
+ * @seq: Sequence number of netlink message
+ * @primary_if: primary interface
+ * @backbone_gw: entry to dump
+ *
+ * Return: 0 or error code.
+ */
+static int
+batadv_bla_backbone_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+			       struct batadv_hard_iface *primary_if,
+			       struct batadv_bla_backbone_gw *backbone_gw)
+{
+	u8 *primary_addr = primary_if->net_dev->dev_addr;
+	u16 backbone_crc;
+	bool is_own;
+	int msecs;
+	void *hdr;
+	int ret = -EINVAL;
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI, BATADV_CMD_GET_BLA_BACKBONE);
+	if (!hdr) {
+		ret = -ENOBUFS;
+		goto out;
+	}
+
+	is_own = batadv_compare_eth(backbone_gw->orig, primary_addr);
+
+	spin_lock_bh(&backbone_gw->crc_lock);
+	backbone_crc = backbone_gw->crc;
+	spin_unlock_bh(&backbone_gw->crc_lock);
+
+	msecs = jiffies_to_msecs(jiffies - backbone_gw->lasttime);
+
+	if (is_own)
+		if (nla_put_flag(msg, BATADV_ATTR_BLA_OWN)) {
+			genlmsg_cancel(msg, hdr);
+			goto out;
+		}
+
+	if (nla_put(msg, BATADV_ATTR_BLA_BACKBONE, ETH_ALEN,
+		    backbone_gw->orig) ||
+	    nla_put_u16(msg, BATADV_ATTR_BLA_VID, backbone_gw->vid) ||
+	    nla_put_u16(msg, BATADV_ATTR_BLA_CRC,
+			backbone_crc) ||
+	    nla_put_u32(msg, BATADV_ATTR_LAST_SEEN_MSECS, msecs)) {
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
+ * batadv_bla_backbone_dump_bucket - dump one bucket of the backbone table
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
+batadv_bla_backbone_dump_bucket(struct sk_buff *msg, u32 portid, u32 seq,
+				struct batadv_hard_iface *primary_if,
+				struct hlist_head *head, int *idx_skip)
+{
+	struct batadv_bla_backbone_gw *backbone_gw;
+	int idx = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(backbone_gw, head, hash_entry) {
+		if (idx++ < *idx_skip)
+			continue;
+		if (batadv_bla_backbone_dump_entry(msg, portid, seq,
+						   primary_if, backbone_gw)) {
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
+ * batadv_bla_backbone_dump - dump backbone table to a netlink socket
+ * @msg: buffer for the message
+ * @cb: callback structure containing arguments
+ *
+ * Return: message length.
+ */
+int batadv_bla_backbone_dump(struct sk_buff *msg, struct netlink_callback *cb)
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
+	hash = bat_priv->bla.backbone_hash;
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
+		if (batadv_bla_backbone_dump_bucket(msg, portid,
+						    cb->nlh->nlmsg_seq,
+						    primary_if, head, &idx))
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
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index a80b9e9..1ae93e4 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -39,6 +39,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_bla_claim_dump(struct sk_buff *msg, struct netlink_callback *cb);
 int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq,
 					     void *offset);
+int batadv_bla_backbone_dump(struct sk_buff *msg, struct netlink_callback *cb);
 bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, u8 *orig,
 				    unsigned short vid);
 bool batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
@@ -120,6 +121,12 @@ static inline int batadv_bla_claim_dump(struct sk_buff *msg,
 	return -EOPNOTSUPP;
 }
 
+static inline int batadv_bla_backbone_dump(struct sk_buff *msg,
+					   struct netlink_callback *cb)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif /* ifdef CONFIG_BATMAN_ADV_BLA */
 
 #endif /* ifndef _NET_BATMAN_ADV_BLA_H_ */
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 464de9d..c3f6816 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -600,6 +600,13 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.dumpit = batadv_bla_claim_dump,
 	},
+	{
+		.cmd = BATADV_CMD_GET_BLA_BACKBONE,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_bla_backbone_dump,
+	},
+
 };
 
 /**
-- 
2.8.1
