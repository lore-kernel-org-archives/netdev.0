From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 08/11] batman-adv: add netlink command to query generic mesh information files
Date: Mon,  4 Jul 2016 15:02:56 +0200
Message-ID: <1467637379-6089-9-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58236 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777AbcGDNDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:03:14 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

BATADV_CMD_GET_MESH_INFO is used to query basic information about a
batman-adv softif (name, index and MAC address for both the softif and
the primary hardif; routing algorithm; batman-adv version).

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven.eckelmann@open-mesh.com: Reduce the number of changes to
BATADV_CMD_GET_MESH_INFO, add missing kerneldoc, add policy for attributes]
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 include/uapi/linux/batman_adv.h |  18 ++++++
 net/batman-adv/netlink.c        | 137 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 155 insertions(+)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 79f7972..c39623c7 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -24,12 +24,28 @@
  * enum batadv_nl_attrs - batman-adv netlink attributes
  *
  * @BATADV_ATTR_UNSPEC: unspecified attribute to catch errors
+ * @BATADV_ATTR_VERSION: batman-adv version string
+ * @BATADV_ATTR_ALGO_NAME: name of routing algorithm
+ * @BATADV_ATTR_MESH_IFINDEX: index of the batman-adv interface
+ * @BATADV_ATTR_MESH_IFNAME: name of the batman-adv interface
+ * @BATADV_ATTR_MESH_ADDRESS: mac address of the batman-adv interface
+ * @BATADV_ATTR_HARD_IFINDEX: index of the non-batman-adv interface
+ * @BATADV_ATTR_HARD_IFNAME: name of the non-batman-adv interface
+ * @BATADV_ATTR_HARD_ADDRESS: mac address of the non-batman-adv interface
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
  */
 enum batadv_nl_attrs {
 	BATADV_ATTR_UNSPEC,
+	BATADV_ATTR_VERSION,
+	BATADV_ATTR_ALGO_NAME,
+	BATADV_ATTR_MESH_IFINDEX,
+	BATADV_ATTR_MESH_IFNAME,
+	BATADV_ATTR_MESH_ADDRESS,
+	BATADV_ATTR_HARD_IFINDEX,
+	BATADV_ATTR_HARD_IFNAME,
+	BATADV_ATTR_HARD_ADDRESS,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
@@ -40,11 +56,13 @@ enum batadv_nl_attrs {
  * enum batadv_nl_commands - supported batman-adv netlink commands
  *
  * @BATADV_CMD_UNSPEC: unspecified command to catch errors
+ * @BATADV_CMD_GET_MESH_INFO: Query basic information about batman-adv device
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
 enum batadv_nl_commands {
 	BATADV_CMD_UNSPEC,
+	BATADV_CMD_GET_MESH_INFO,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 9e4c865..68152aa 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -18,12 +18,24 @@
 #include "netlink.h"
 #include "main.h"
 
+#include <linux/errno.h>
+#include <linux/fs.h>
 #include <linux/genetlink.h>
+#include <linux/if_ether.h>
 #include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/netlink.h>
 #include <linux/printk.h>
+#include <linux/stddef.h>
 #include <net/genetlink.h>
+#include <net/netlink.h>
 #include <uapi/linux/batman_adv.h>
 
+#include "hard-interface.h"
+#include "soft-interface.h"
+
+struct sk_buff;
+
 static struct genl_family batadv_netlink_family = {
 	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
@@ -32,7 +44,132 @@ static struct genl_family batadv_netlink_family = {
 	.maxattr = BATADV_ATTR_MAX,
 };
 
+static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
+	[BATADV_ATTR_VERSION]		= { .type = NLA_STRING },
+	[BATADV_ATTR_ALGO_NAME]		= { .type = NLA_STRING },
+	[BATADV_ATTR_MESH_IFINDEX]	= { .type = NLA_U32 },
+	[BATADV_ATTR_MESH_IFNAME]	= { .type = NLA_STRING },
+	[BATADV_ATTR_MESH_ADDRESS]	= { .len = ETH_ALEN },
+	[BATADV_ATTR_HARD_IFINDEX]	= { .type = NLA_U32 },
+	[BATADV_ATTR_HARD_IFNAME]	= { .type = NLA_STRING },
+	[BATADV_ATTR_HARD_ADDRESS]	= { .len = ETH_ALEN },
+};
+
+/**
+ * batadv_netlink_mesh_info_put - fill in generic information about mesh
+ *  interface
+ * @msg: netlink message to be sent back
+ * @soft_iface: interface for which the data should be taken
+ *
+ * Return: 0 on success, < 0 on error
+ */
+static int
+batadv_netlink_mesh_info_put(struct sk_buff *msg, struct net_device *soft_iface)
+{
+	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
+	struct batadv_hard_iface *primary_if = NULL;
+	struct net_device *hard_iface;
+	int ret = -ENOBUFS;
+
+	if (nla_put_string(msg, BATADV_ATTR_VERSION, BATADV_SOURCE_VERSION) ||
+	    nla_put_string(msg, BATADV_ATTR_ALGO_NAME,
+			   bat_priv->bat_algo_ops->name) ||
+	    nla_put_u32(msg, BATADV_ATTR_MESH_IFINDEX, soft_iface->ifindex) ||
+	    nla_put_string(msg, BATADV_ATTR_MESH_IFNAME, soft_iface->name) ||
+	    nla_put(msg, BATADV_ATTR_MESH_ADDRESS, ETH_ALEN,
+		    soft_iface->dev_addr))
+		goto out;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (primary_if && primary_if->if_status == BATADV_IF_ACTIVE) {
+		hard_iface = primary_if->net_dev;
+
+		if (nla_put_u32(msg, BATADV_ATTR_HARD_IFINDEX,
+				hard_iface->ifindex) ||
+		    nla_put_string(msg, BATADV_ATTR_HARD_IFNAME,
+				   hard_iface->name) ||
+		    nla_put(msg, BATADV_ATTR_HARD_ADDRESS, ETH_ALEN,
+			    hard_iface->dev_addr))
+			goto out;
+	}
+
+	ret = 0;
+
+ out:
+	if (primary_if)
+		batadv_hardif_put(primary_if);
+
+	return ret;
+}
+
+/**
+ * batadv_netlink_get_mesh_info - handle incoming BATADV_CMD_GET_MESH_INFO
+ *  netlink request
+ * @skb: received netlink message
+ * @info: receiver information
+ *
+ * Return: 0 on success, < 0 on error
+ */
+static int
+batadv_netlink_get_mesh_info(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct net_device *soft_iface;
+	struct sk_buff *msg = NULL;
+	void *msg_head;
+	int ifindex;
+	int ret;
+
+	if (!info->attrs[BATADV_ATTR_MESH_IFINDEX])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(info->attrs[BATADV_ATTR_MESH_IFINDEX]);
+	if (!ifindex)
+		return -EINVAL;
+
+	soft_iface = dev_get_by_index(net, ifindex);
+	if (!soft_iface || !batadv_softif_is_valid(soft_iface)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	msg_head = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			       &batadv_netlink_family, 0,
+			       BATADV_CMD_GET_MESH_INFO);
+	if (!msg_head) {
+		ret = -ENOBUFS;
+		goto out;
+	}
+
+	ret = batadv_netlink_mesh_info_put(msg, soft_iface);
+
+ out:
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	if (ret) {
+		if (msg)
+			nlmsg_free(msg);
+		return ret;
+	}
+
+	genlmsg_end(msg, msg_head);
+	return genlmsg_reply(msg, info);
+}
+
 static struct genl_ops batadv_netlink_ops[] = {
+	{
+		.cmd = BATADV_CMD_GET_MESH_INFO,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.doit = batadv_netlink_get_mesh_info,
+	},
 };
 
 /**
-- 
2.8.1
