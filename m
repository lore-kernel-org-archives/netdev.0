From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 10/11] batman-adv: throughput meter implementation
Date: Mon,  4 Jul 2016 15:02:58 +0200
Message-ID: <1467637379-6089-11-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio.quartulli@open-mesh.com>,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58245 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbcGDNDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 09:03:16 -0400
In-Reply-To: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio.quartulli@open-mesh.com>

The throughput meter module is a simple, kernel-space replacement for
throughtput measurements tool like iperf and netperf. It is intended to
approximate TCP behaviour.

It is invoked through batctl: the protocol is connection oriented, with
cumulative acknowledgment and a dynamic-size sliding window.

The test *can* be interrupted by batctl. A receiver side timeout avoids
unlimited waitings for sender packets: after one second of inactivity, the
receiver abort the ongoing test.

Based on a prototype from Edo Monticelli <montik@autistici.org>

Signed-off-by: Antonio Quartulli <antonio.quartulli@open-mesh.com>
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 include/uapi/linux/batman_adv.h |   43 ++
 net/batman-adv/Makefile         |    1 +
 net/batman-adv/log.h            |   18 +-
 net/batman-adv/main.c           |    4 +
 net/batman-adv/main.h           |    8 +
 net/batman-adv/netlink.c        |  234 +++++-
 net/batman-adv/netlink.h        |    6 +
 net/batman-adv/packet.h         |   54 ++
 net/batman-adv/routing.c        |    8 +
 net/batman-adv/soft-interface.c |    2 +
 net/batman-adv/tp_meter.c       | 1507 +++++++++++++++++++++++++++++++++++++++
 net/batman-adv/tp_meter.h       |   34 +
 net/batman-adv/types.h          |  112 +++
 13 files changed, 2021 insertions(+), 10 deletions(-)
 create mode 100644 net/batman-adv/tp_meter.c
 create mode 100644 net/batman-adv/tp_meter.h

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index c39623c7..0fbf6fd 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -20,6 +20,8 @@
 
 #define BATADV_NL_NAME "batadv"
 
+#define BATADV_NL_MCAST_GROUP_TPMETER	"tpmeter"
+
 /**
  * enum batadv_nl_attrs - batman-adv netlink attributes
  *
@@ -32,6 +34,12 @@
  * @BATADV_ATTR_HARD_IFINDEX: index of the non-batman-adv interface
  * @BATADV_ATTR_HARD_IFNAME: name of the non-batman-adv interface
  * @BATADV_ATTR_HARD_ADDRESS: mac address of the non-batman-adv interface
+ * @BATADV_ATTR_ORIG_ADDRESS: originator mac address
+ * @BATADV_ATTR_TPMETER_RESULT: result of run (see batadv_tp_meter_status)
+ * @BATADV_ATTR_TPMETER_TEST_TIME: time (msec) the run took
+ * @BATADV_ATTR_TPMETER_BYTES: amount of acked bytes during run
+ * @BATADV_ATTR_TPMETER_COOKIE: session cookie to match tp_meter session
+ * @BATADV_ATTR_PAD: attribute used for padding for 64-bit alignment
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
@@ -46,6 +54,12 @@ enum batadv_nl_attrs {
 	BATADV_ATTR_HARD_IFINDEX,
 	BATADV_ATTR_HARD_IFNAME,
 	BATADV_ATTR_HARD_ADDRESS,
+	BATADV_ATTR_ORIG_ADDRESS,
+	BATADV_ATTR_TPMETER_RESULT,
+	BATADV_ATTR_TPMETER_TEST_TIME,
+	BATADV_ATTR_TPMETER_BYTES,
+	BATADV_ATTR_TPMETER_COOKIE,
+	BATADV_ATTR_PAD,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
@@ -57,15 +71,44 @@ enum batadv_nl_attrs {
  *
  * @BATADV_CMD_UNSPEC: unspecified command to catch errors
  * @BATADV_CMD_GET_MESH_INFO: Query basic information about batman-adv device
+ * @BATADV_CMD_TP_METER: Start a tp meter session
+ * @BATADV_CMD_TP_METER_CANCEL: Cancel a tp meter session
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
 enum batadv_nl_commands {
 	BATADV_CMD_UNSPEC,
 	BATADV_CMD_GET_MESH_INFO,
+	BATADV_CMD_TP_METER,
+	BATADV_CMD_TP_METER_CANCEL,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
 };
 
+/**
+ * enum batadv_tp_meter_reason - reason of a tp meter test run stop
+ * @BATADV_TP_REASON_COMPLETE: sender finished tp run
+ * @BATADV_TP_REASON_CANCEL: sender was stopped during run
+ * @BATADV_TP_REASON_DST_UNREACHABLE: receiver could not be reached or didn't
+ *  answer
+ * @BATADV_TP_REASON_RESEND_LIMIT: (unused) sender retry reached limit
+ * @BATADV_TP_REASON_ALREADY_ONGOING: test to or from the same node already
+ *  ongoing
+ * @BATADV_TP_REASON_MEMORY_ERROR: test was stopped due to low memory
+ * @BATADV_TP_REASON_CANT_SEND: failed to send via outgoing interface
+ * @BATADV_TP_REASON_TOO_MANY: too many ongoing sessions
+ */
+enum batadv_tp_meter_reason {
+	BATADV_TP_REASON_COMPLETE		= 3,
+	BATADV_TP_REASON_CANCEL			= 4,
+	/* error status >= 128 */
+	BATADV_TP_REASON_DST_UNREACHABLE	= 128,
+	BATADV_TP_REASON_RESEND_LIMIT		= 129,
+	BATADV_TP_REASON_ALREADY_ONGOING	= 130,
+	BATADV_TP_REASON_MEMORY_ERROR		= 131,
+	BATADV_TP_REASON_CANT_SEND		= 132,
+	BATADV_TP_REASON_TOO_MANY		= 133,
+};
+
 #endif /* _UAPI_LINUX_BATMAN_ADV_H_ */
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 7da5901..a83fc6c 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -42,5 +42,6 @@ batman-adv-y += routing.o
 batman-adv-y += send.o
 batman-adv-y += soft-interface.o
 batman-adv-y += sysfs.o
+batman-adv-y += tp_meter.o
 batman-adv-y += translation-table.o
 batman-adv-y += tvlv.o
diff --git a/net/batman-adv/log.h b/net/batman-adv/log.h
index 9948e56..e0e1a88 100644
--- a/net/batman-adv/log.h
+++ b/net/batman-adv/log.h
@@ -51,17 +51,19 @@ static inline void batadv_debug_log_cleanup(struct batadv_priv *bat_priv)
  * @BATADV_DBG_DAT: ARP snooping and DAT related messages
  * @BATADV_DBG_NC: network coding related messages
  * @BATADV_DBG_MCAST: multicast related messages
+ * @BATADV_DBG_TP_METER: throughput meter messages
  * @BATADV_DBG_ALL: the union of all the above log levels
  */
 enum batadv_dbg_level {
-	BATADV_DBG_BATMAN = BIT(0),
-	BATADV_DBG_ROUTES = BIT(1),
-	BATADV_DBG_TT	  = BIT(2),
-	BATADV_DBG_BLA    = BIT(3),
-	BATADV_DBG_DAT    = BIT(4),
-	BATADV_DBG_NC	  = BIT(5),
-	BATADV_DBG_MCAST  = BIT(6),
-	BATADV_DBG_ALL    = 127,
+	BATADV_DBG_BATMAN	= BIT(0),
+	BATADV_DBG_ROUTES	= BIT(1),
+	BATADV_DBG_TT		= BIT(2),
+	BATADV_DBG_BLA		= BIT(3),
+	BATADV_DBG_DAT		= BIT(4),
+	BATADV_DBG_NC		= BIT(5),
+	BATADV_DBG_MCAST	= BIT(6),
+	BATADV_DBG_TP_METER	= BIT(7),
+	BATADV_DBG_ALL		= 127,
 };
 
 #ifdef CONFIG_BATMAN_ADV_DEBUG
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 275604b..fe4c5e2 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -64,6 +64,7 @@
 #include "routing.h"
 #include "send.h"
 #include "soft-interface.h"
+#include "tp_meter.h"
 #include "translation-table.h"
 
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
@@ -89,6 +90,7 @@ static int __init batadv_init(void)
 	batadv_v_init();
 	batadv_iv_init();
 	batadv_nc_init();
+	batadv_tp_meter_init();
 
 	batadv_event_workqueue = create_singlethread_workqueue("bat_events");
 
@@ -142,6 +144,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->tvlv.container_list_lock);
 	spin_lock_init(&bat_priv->tvlv.handler_list_lock);
 	spin_lock_init(&bat_priv->softif_vlan_list_lock);
+	spin_lock_init(&bat_priv->tp_list_lock);
 
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
@@ -160,6 +163,7 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	INIT_HLIST_HEAD(&bat_priv->tvlv.container_list);
 	INIT_HLIST_HEAD(&bat_priv->tvlv.handler_list);
 	INIT_HLIST_HEAD(&bat_priv->softif_vlan_list);
+	INIT_HLIST_HEAD(&bat_priv->tp_list);
 
 	ret = batadv_v_mesh_init(bat_priv);
 	if (ret < 0)
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 857fb5a..06a8608 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -100,6 +100,9 @@
 #define BATADV_NUM_BCASTS_WIRELESS 3
 #define BATADV_NUM_BCASTS_MAX 3
 
+/* length of the single packet used by the TP meter */
+#define BATADV_TP_PACKET_LEN ETH_DATA_LEN
+
 /* msecs after which an ARP_REQUEST is sent in broadcast as fallback */
 #define ARP_REQ_DELAY 250
 /* numbers of originator to contact for any PUT/GET DHT operation */
@@ -131,6 +134,11 @@
 
 #define BATADV_NC_NODE_TIMEOUT 10000 /* Milliseconds */
 
+/**
+ * BATADV_TP_MAX_NUM - maximum number of simultaneously active tp sessions
+ */
+#define BATADV_TP_MAX_NUM 5
+
 enum batadv_mesh_state {
 	BATADV_MESH_INACTIVE,
 	BATADV_MESH_ACTIVE,
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 68152aa..c25bbb8 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -27,12 +27,14 @@
 #include <linux/netlink.h>
 #include <linux/printk.h>
 #include <linux/stddef.h>
+#include <linux/types.h>
 #include <net/genetlink.h>
 #include <net/netlink.h>
 #include <uapi/linux/batman_adv.h>
 
 #include "hard-interface.h"
 #include "soft-interface.h"
+#include "tp_meter.h"
 
 struct sk_buff;
 
@@ -44,6 +46,15 @@ static struct genl_family batadv_netlink_family = {
 	.maxattr = BATADV_ATTR_MAX,
 };
 
+/* multicast groups */
+enum batadv_netlink_multicast_groups {
+	BATADV_NL_MCGRP_TPMETER,
+};
+
+static struct genl_multicast_group batadv_netlink_mcgrps[] = {
+	[BATADV_NL_MCGRP_TPMETER] = { .name = BATADV_NL_MCAST_GROUP_TPMETER },
+};
+
 static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_VERSION]		= { .type = NLA_STRING },
 	[BATADV_ATTR_ALGO_NAME]		= { .type = NLA_STRING },
@@ -53,6 +64,11 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_HARD_IFINDEX]	= { .type = NLA_U32 },
 	[BATADV_ATTR_HARD_IFNAME]	= { .type = NLA_STRING },
 	[BATADV_ATTR_HARD_ADDRESS]	= { .len = ETH_ALEN },
+	[BATADV_ATTR_ORIG_ADDRESS]	= { .len = ETH_ALEN },
+	[BATADV_ATTR_TPMETER_RESULT]	= { .type = NLA_U8 },
+	[BATADV_ATTR_TPMETER_TEST_TIME]	= { .type = NLA_U32 },
+	[BATADV_ATTR_TPMETER_BYTES]	= { .type = NLA_U64 },
+	[BATADV_ATTR_TPMETER_COOKIE]	= { .type = NLA_U32 },
 };
 
 /**
@@ -163,6 +179,207 @@ batadv_netlink_get_mesh_info(struct sk_buff *skb, struct genl_info *info)
 	return genlmsg_reply(msg, info);
 }
 
+/**
+ * batadv_netlink_tp_meter_put - Fill information of started tp_meter session
+ * @msg: netlink message to be sent back
+ * @cookie: tp meter session cookie
+ *
+ *  Return: 0 on success, < 0 on error
+ */
+static int
+batadv_netlink_tp_meter_put(struct sk_buff *msg, u32 cookie)
+{
+	if (nla_put_u32(msg, BATADV_ATTR_TPMETER_COOKIE, cookie))
+		return -ENOBUFS;
+
+	return 0;
+}
+
+/**
+ * batadv_netlink_tpmeter_notify - send tp_meter result via netlink to client
+ * @bat_priv: the bat priv with all the soft interface information
+ * @dst: destination of tp_meter session
+ * @result: reason for tp meter session stop
+ * @test_time: total time ot the tp_meter session
+ * @total_bytes: bytes acked to the receiver
+ * @cookie: cookie of tp_meter session
+ *
+ * Return: 0 on success, < 0 on error
+ */
+int batadv_netlink_tpmeter_notify(struct batadv_priv *bat_priv, const u8 *dst,
+				  u8 result, u32 test_time, u64 total_bytes,
+				  u32 cookie)
+{
+	struct sk_buff *msg;
+	void *hdr;
+	int ret;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	hdr = genlmsg_put(msg, 0, 0, &batadv_netlink_family, 0,
+			  BATADV_CMD_TP_METER);
+	if (!hdr) {
+		ret = -ENOBUFS;
+		goto err_genlmsg;
+	}
+
+	if (nla_put_u32(msg, BATADV_ATTR_TPMETER_COOKIE, cookie))
+		goto nla_put_failure;
+
+	if (nla_put_u32(msg, BATADV_ATTR_TPMETER_TEST_TIME, test_time))
+		goto nla_put_failure;
+
+	if (nla_put_u64_64bit(msg, BATADV_ATTR_TPMETER_BYTES, total_bytes,
+			      BATADV_ATTR_PAD))
+		goto nla_put_failure;
+
+	if (nla_put_u8(msg, BATADV_ATTR_TPMETER_RESULT, result))
+		goto nla_put_failure;
+
+	if (nla_put(msg, BATADV_ATTR_ORIG_ADDRESS, ETH_ALEN, dst))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+
+	genlmsg_multicast_netns(&batadv_netlink_family,
+				dev_net(bat_priv->soft_iface), msg, 0,
+				BATADV_NL_MCGRP_TPMETER, GFP_KERNEL);
+
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	ret = -EMSGSIZE;
+
+err_genlmsg:
+	nlmsg_free(msg);
+	return ret;
+}
+
+/**
+ * batadv_netlink_tp_meter_start - Start a new tp_meter session
+ * @skb: received netlink message
+ * @info: receiver information
+ *
+ * Return: 0 on success, < 0 on error
+ */
+static int
+batadv_netlink_tp_meter_start(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct net_device *soft_iface;
+	struct batadv_priv *bat_priv;
+	struct sk_buff *msg = NULL;
+	u32 test_length;
+	void *msg_head;
+	int ifindex;
+	u32 cookie;
+	u8 *dst;
+	int ret;
+
+	if (!info->attrs[BATADV_ATTR_MESH_IFINDEX])
+		return -EINVAL;
+
+	if (!info->attrs[BATADV_ATTR_ORIG_ADDRESS])
+		return -EINVAL;
+
+	if (!info->attrs[BATADV_ATTR_TPMETER_TEST_TIME])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(info->attrs[BATADV_ATTR_MESH_IFINDEX]);
+	if (!ifindex)
+		return -EINVAL;
+
+	dst = nla_data(info->attrs[BATADV_ATTR_ORIG_ADDRESS]);
+
+	test_length = nla_get_u32(info->attrs[BATADV_ATTR_TPMETER_TEST_TIME]);
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
+			       BATADV_CMD_TP_METER);
+	if (!msg_head) {
+		ret = -ENOBUFS;
+		goto out;
+	}
+
+	bat_priv = netdev_priv(soft_iface);
+	batadv_tp_start(bat_priv, dst, test_length, &cookie);
+
+	ret = batadv_netlink_tp_meter_put(msg, cookie);
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
+/**
+ * batadv_netlink_tp_meter_start - Cancel a running tp_meter session
+ * @skb: received netlink message
+ * @info: receiver information
+ *
+ * Return: 0 on success, < 0 on error
+ */
+static int
+batadv_netlink_tp_meter_cancel(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct net_device *soft_iface;
+	struct batadv_priv *bat_priv;
+	int ifindex;
+	u8 *dst;
+	int ret = 0;
+
+	if (!info->attrs[BATADV_ATTR_MESH_IFINDEX])
+		return -EINVAL;
+
+	if (!info->attrs[BATADV_ATTR_ORIG_ADDRESS])
+		return -EINVAL;
+
+	ifindex = nla_get_u32(info->attrs[BATADV_ATTR_MESH_IFINDEX]);
+	if (!ifindex)
+		return -EINVAL;
+
+	dst = nla_data(info->attrs[BATADV_ATTR_ORIG_ADDRESS]);
+
+	soft_iface = dev_get_by_index(net, ifindex);
+	if (!soft_iface || !batadv_softif_is_valid(soft_iface)) {
+		ret = -ENODEV;
+		goto out;
+	}
+
+	bat_priv = netdev_priv(soft_iface);
+	batadv_tp_stop(bat_priv, dst, BATADV_TP_REASON_CANCEL);
+
+out:
+	if (soft_iface)
+		dev_put(soft_iface);
+
+	return ret;
+}
+
 static struct genl_ops batadv_netlink_ops[] = {
 	{
 		.cmd = BATADV_CMD_GET_MESH_INFO,
@@ -170,6 +387,18 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.doit = batadv_netlink_get_mesh_info,
 	},
+	{
+		.cmd = BATADV_CMD_TP_METER,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.doit = batadv_netlink_tp_meter_start,
+	},
+	{
+		.cmd = BATADV_CMD_TP_METER_CANCEL,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.doit = batadv_netlink_tp_meter_cancel,
+	},
 };
 
 /**
@@ -179,8 +408,9 @@ void __init batadv_netlink_register(void)
 {
 	int ret;
 
-	ret = genl_register_family_with_ops(&batadv_netlink_family,
-					    batadv_netlink_ops);
+	ret = genl_register_family_with_ops_groups(&batadv_netlink_family,
+						   batadv_netlink_ops,
+						   batadv_netlink_mcgrps);
 	if (ret)
 		pr_warn("unable to register netlink family");
 }
diff --git a/net/batman-adv/netlink.h b/net/batman-adv/netlink.h
index 39044cc..945653a 100644
--- a/net/batman-adv/netlink.h
+++ b/net/batman-adv/netlink.h
@@ -20,7 +20,13 @@
 
 #include "main.h"
 
+#include <linux/types.h>
+
 void batadv_netlink_register(void);
 void batadv_netlink_unregister(void);
 
+int batadv_netlink_tpmeter_notify(struct batadv_priv *bat_priv, const u8 *dst,
+				  u8 result, u32 test_time, u64 total_bytes,
+				  u32 cookie);
+
 #endif /* _NET_BATMAN_ADV_NETLINK_H_ */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 7156779..6b011ff 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -21,6 +21,8 @@
 #include <asm/byteorder.h>
 #include <linux/types.h>
 
+#define batadv_tp_is_error(n) ((u8)n > 127 ? 1 : 0)
+
 /**
  * enum batadv_packettype - types for batman-adv encapsulated packets
  * @BATADV_IV_OGM: originator messages for B.A.T.M.A.N. IV
@@ -93,6 +95,7 @@ enum batadv_icmp_packettype {
 	BATADV_ECHO_REQUEST	       = 8,
 	BATADV_TTL_EXCEEDED	       = 11,
 	BATADV_PARAMETER_PROBLEM       = 12,
+	BATADV_TP		       = 15,
 };
 
 /**
@@ -285,6 +288,16 @@ struct batadv_elp_packet {
 #define BATADV_ELP_HLEN sizeof(struct batadv_elp_packet)
 
 /**
+ * enum batadv_icmp_user_cmd_type - types for batman-adv icmp cmd modes
+ * @BATADV_TP_START: start a throughput meter run
+ * @BATADV_TP_STOP: stop a throughput meter run
+ */
+enum batadv_icmp_user_cmd_type {
+	BATADV_TP_START		= 0,
+	BATADV_TP_STOP		= 2,
+};
+
+/**
  * struct batadv_icmp_header - common members among all the ICMP packets
  * @packet_type: batman-adv packet type, part of the general header
  * @version: batman-adv protocol version, part of the genereal header
@@ -334,6 +347,47 @@ struct batadv_icmp_packet {
 	__be16 seqno;
 };
 
+/**
+ * struct batadv_icmp_tp_packet - ICMP TP Meter packet
+ * @packet_type: batman-adv packet type, part of the general header
+ * @version: batman-adv protocol version, part of the genereal header
+ * @ttl: time to live for this packet, part of the genereal header
+ * @msg_type: ICMP packet type
+ * @dst: address of the destination node
+ * @orig: address of the source node
+ * @uid: local ICMP socket identifier
+ * @subtype: TP packet subtype (see batadv_icmp_tp_subtype)
+ * @session: TP session identifier
+ * @seqno: the TP sequence number
+ * @timestamp: time when the packet has been sent. This value is filled in a
+ *  TP_MSG and echoed back in the next TP_ACK so that the sender can compute the
+ *  RTT. Since it is read only by the host which wrote it, there is no need to
+ *  store it using network order
+ */
+struct batadv_icmp_tp_packet {
+	u8  packet_type;
+	u8  version;
+	u8  ttl;
+	u8  msg_type; /* see ICMP message types above */
+	u8  dst[ETH_ALEN];
+	u8  orig[ETH_ALEN];
+	u8  uid;
+	u8  subtype;
+	u8  session[2];
+	__be32 seqno;
+	__be32 timestamp;
+};
+
+/**
+ * enum batadv_icmp_tp_subtype - ICMP TP Meter packet subtypes
+ * @BATADV_TP_MSG: Msg from sender to receiver
+ * @BATADV_TP_ACK: acknowledgment from receiver to sender
+ */
+enum batadv_icmp_tp_subtype {
+	BATADV_TP_MSG	= 0,
+	BATADV_TP_ACK,
+};
+
 #define BATADV_RR_LEN 16
 
 /**
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 76de583..7b5de40 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -46,6 +46,7 @@
 #include "packet.h"
 #include "send.h"
 #include "soft-interface.h"
+#include "tp_meter.h"
 #include "translation-table.h"
 #include "tvlv.h"
 
@@ -276,6 +277,13 @@ static int batadv_recv_my_icmp_packet(struct batadv_priv *bat_priv,
 		ret = NET_RX_SUCCESS;
 
 		break;
+	case BATADV_TP:
+		if (!pskb_may_pull(skb, sizeof(struct batadv_icmp_tp_packet)))
+			goto out;
+
+		batadv_tp_meter_recv(bat_priv, skb);
+		ret = NET_RX_SUCCESS;
+		goto out;
 	default:
 		/* drop unknown type */
 		goto out;
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index f75631e..18b6d07 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -842,6 +842,8 @@ static int batadv_softif_init_late(struct net_device *dev)
 #ifdef CONFIG_BATMAN_ADV_BLA
 	atomic_set(&bat_priv->bla.num_requests, 0);
 #endif
+	atomic_set(&bat_priv->tp_num, 0);
+
 	bat_priv->tt.last_changeset = NULL;
 	bat_priv->tt.last_changeset_len = 0;
 	bat_priv->isolation_mark = 0;
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
new file mode 100644
index 0000000..2333777
--- /dev/null
+++ b/net/batman-adv/tp_meter.c
@@ -0,0 +1,1507 @@
+/* Copyright (C) 2012-2016 B.A.T.M.A.N. contributors:
+ *
+ * Edo Monticelli, Antonio Quartulli
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
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "tp_meter.h"
+#include "main.h"
+
+#include <linux/atomic.h>
+#include <linux/bug.h>
+#include <linux/byteorder/generic.h>
+#include <linux/cache.h>
+#include <linux/compiler.h>
+#include <linux/device.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/kref.h>
+#include <linux/kthread.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/param.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/sched.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/timer.h>
+#include <linux/wait.h>
+#include <linux/workqueue.h>
+#include <uapi/linux/batman_adv.h>
+
+#include "hard-interface.h"
+#include "log.h"
+#include "netlink.h"
+#include "originator.h"
+#include "packet.h"
+#include "send.h"
+
+/**
+ * BATADV_TP_DEF_TEST_LENGTH - Default test length if not specified by the user
+ *  in milliseconds
+ */
+#define BATADV_TP_DEF_TEST_LENGTH 10000
+
+/**
+ * BATADV_TP_AWND - Advertised window by the receiver (in bytes)
+ */
+#define BATADV_TP_AWND 0x20000000
+
+/**
+ * BATADV_TP_RECV_TIMEOUT - Receiver activity timeout. If the receiver does not
+ *  get anything for such amount of milliseconds, the connection is killed
+ */
+#define BATADV_TP_RECV_TIMEOUT 1000
+
+/**
+ * BATADV_TP_MAX_RTO - Maximum sender timeout. If the sender RTO gets beyond
+ * such amound of milliseconds, the receiver is considered unreachable and the
+ * connection is killed
+ */
+#define BATADV_TP_MAX_RTO 30000
+
+/**
+ * BATADV_TP_FIRST_SEQ - First seqno of each session. The number is rather high
+ *  in order to immediately trigger a wrap around (test purposes)
+ */
+#define BATADV_TP_FIRST_SEQ ((u32)-1 - 2000)
+
+/**
+ * BATADV_TP_PLEN - length of the payload (data after the batadv_unicast header)
+ *  to simulate
+ */
+#define BATADV_TP_PLEN (BATADV_TP_PACKET_LEN - ETH_HLEN - \
+			sizeof(struct batadv_unicast_packet))
+
+static u8 batadv_tp_prerandom[4096] __read_mostly;
+
+/**
+ * batadv_tp_session_cookie - generate session cookie based on session ids
+ * @session: TP session identifier
+ * @icmp_uid: icmp pseudo uid of the tp session
+ *
+ * Return: 32 bit tp_meter session cookie
+ */
+static u32 batadv_tp_session_cookie(const u8 session[2], u8 icmp_uid)
+{
+	u32 cookie;
+
+	cookie = icmp_uid << 16;
+	cookie |= session[0] << 8;
+	cookie |= session[1];
+
+	return cookie;
+}
+
+/**
+ * batadv_tp_cwnd - compute the new cwnd size
+ * @base: base cwnd size value
+ * @increment: the value to add to base to get the new size
+ * @min: minumim cwnd value (usually MSS)
+ *
+ * Return the new cwnd size and ensures it does not exceed the Advertised
+ * Receiver Window size. It is wrap around safe.
+ * For details refer to Section 3.1 of RFC5681
+ *
+ * Return: new congestion window size in bytes
+ */
+static u32 batadv_tp_cwnd(u32 base, u32 increment, u32 min)
+{
+	u32 new_size = base + increment;
+
+	/* check for wrap-around */
+	if (new_size < base)
+		new_size = (u32)ULONG_MAX;
+
+	new_size = min_t(u32, new_size, BATADV_TP_AWND);
+
+	return max_t(u32, new_size, min);
+}
+
+/**
+ * batadv_tp_updated_cwnd - update the Congestion Windows
+ * @tp_vars: the private data of the current TP meter session
+ * @mss: maximum segment size of transmission
+ *
+ * 1) if the session is in Slow Start, the CWND has to be increased by 1
+ * MSS every unique received ACK
+ * 2) if the session is in Congestion Avoidance, the CWND has to be
+ * increased by MSS * MSS / CWND for every unique received ACK
+ */
+static void batadv_tp_update_cwnd(struct batadv_tp_vars *tp_vars, u32 mss)
+{
+	spin_lock_bh(&tp_vars->cwnd_lock);
+
+	/* slow start... */
+	if (tp_vars->cwnd <= tp_vars->ss_threshold) {
+		tp_vars->dec_cwnd = 0;
+		tp_vars->cwnd = batadv_tp_cwnd(tp_vars->cwnd, mss, mss);
+		spin_unlock_bh(&tp_vars->cwnd_lock);
+		return;
+	}
+
+	/* increment CWND at least of 1 (section 3.1 of RFC5681) */
+	tp_vars->dec_cwnd += max_t(u32, 1U << 3,
+				   ((mss * mss) << 6) / (tp_vars->cwnd << 3));
+	if (tp_vars->dec_cwnd < (mss << 3)) {
+		spin_unlock_bh(&tp_vars->cwnd_lock);
+		return;
+	}
+
+	tp_vars->cwnd = batadv_tp_cwnd(tp_vars->cwnd, mss, mss);
+	tp_vars->dec_cwnd = 0;
+
+	spin_unlock_bh(&tp_vars->cwnd_lock);
+}
+
+/**
+ * batadv_tp_update_rto - calculate new retransmission timeout
+ * @tp_vars: the private data of the current TP meter session
+ * @new_rtt: new roundtrip time in msec
+ */
+static void batadv_tp_update_rto(struct batadv_tp_vars *tp_vars,
+				 u32 new_rtt)
+{
+	long m = new_rtt;
+
+	/* RTT update
+	 * Details in Section 2.2 and 2.3 of RFC6298
+	 *
+	 * It's tricky to understand. Don't lose hair please.
+	 * Inspired by tcp_rtt_estimator() tcp_input.c
+	 */
+	if (tp_vars->srtt != 0) {
+		m -= (tp_vars->srtt >> 3); /* m is now error in rtt est */
+		tp_vars->srtt += m; /* rtt = 7/8 srtt + 1/8 new */
+		if (m < 0)
+			m = -m;
+
+		m -= (tp_vars->rttvar >> 2);
+		tp_vars->rttvar += m; /* mdev ~= 3/4 rttvar + 1/4 new */
+	} else {
+		/* first measure getting in */
+		tp_vars->srtt = m << 3;	/* take the measured time to be srtt */
+		tp_vars->rttvar = m << 1; /* new_rtt / 2 */
+	}
+
+	/* rto = srtt + 4 * rttvar.
+	 * rttvar is scaled by 4, therefore doesn't need to be multiplied
+	 */
+	tp_vars->rto = (tp_vars->srtt >> 3) + tp_vars->rttvar;
+}
+
+/**
+ * batadv_tp_batctl_notify - send client status result to client
+ * @reason: reason for tp meter session stop
+ * @dst: destination of tp_meter session
+ * @bat_priv: the bat priv with all the soft interface information
+ * @start_time: start of transmission in jiffies
+ * @total_sent: bytes acked to the receiver
+ * @cookie: cookie of tp_meter session
+ */
+static void batadv_tp_batctl_notify(enum batadv_tp_meter_reason reason,
+				    const u8 *dst, struct batadv_priv *bat_priv,
+				    unsigned long start_time, u64 total_sent,
+				    u32 cookie)
+{
+	u32 test_time;
+	u8 result;
+	u32 total_bytes;
+
+	if (!batadv_tp_is_error(reason)) {
+		result = BATADV_TP_REASON_COMPLETE;
+		test_time = jiffies_to_msecs(jiffies - start_time);
+		total_bytes = total_sent;
+	} else {
+		result = reason;
+		test_time = 0;
+		total_bytes = 0;
+	}
+
+	batadv_netlink_tpmeter_notify(bat_priv, dst, result, test_time,
+				      total_bytes, cookie);
+}
+
+/**
+ * batadv_tp_batctl_error_notify - send client error result to client
+ * @reason: reason for tp meter session stop
+ * @dst: destination of tp_meter session
+ * @bat_priv: the bat priv with all the soft interface information
+ * @cookie: cookie of tp_meter session
+ */
+static void batadv_tp_batctl_error_notify(enum batadv_tp_meter_reason reason,
+					  const u8 *dst,
+					  struct batadv_priv *bat_priv,
+					  u32 cookie)
+{
+	batadv_tp_batctl_notify(reason, dst, bat_priv, 0, 0, cookie);
+}
+
+/**
+ * batadv_tp_list_find - find a tp_vars object in the global list
+ * @bat_priv: the bat priv with all the soft interface information
+ * @dst: the other endpoint MAC address to look for
+ *
+ * Look for a tp_vars object matching dst as end_point and return it after
+ * having incremented the refcounter. Return NULL is not found
+ *
+ * Return: matching tp_vars or NULL when no tp_vars with @dst was found
+ */
+static struct batadv_tp_vars *batadv_tp_list_find(struct batadv_priv *bat_priv,
+						  const u8 *dst)
+{
+	struct batadv_tp_vars *pos, *tp_vars = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(pos, &bat_priv->tp_list, list) {
+		if (!batadv_compare_eth(pos->other_end, dst))
+			continue;
+
+		/* most of the time this function is invoked during the normal
+		 * process..it makes sens to pay more when the session is
+		 * finished and to speed the process up during the measurement
+		 */
+		if (unlikely(!kref_get_unless_zero(&pos->refcount)))
+			continue;
+
+		tp_vars = pos;
+		break;
+	}
+	rcu_read_unlock();
+
+	return tp_vars;
+}
+
+/**
+ * batadv_tp_list_find_session - find tp_vars session object in the global list
+ * @bat_priv: the bat priv with all the soft interface information
+ * @dst: the other endpoint MAC address to look for
+ * @session: session identifier
+ *
+ * Look for a tp_vars object matching dst as end_point, session as tp meter
+ * session and return it after having incremented the refcounter. Return NULL
+ * is not found
+ *
+ * Return: matching tp_vars or NULL when no tp_vars was found
+ */
+static struct batadv_tp_vars *
+batadv_tp_list_find_session(struct batadv_priv *bat_priv, const u8 *dst,
+			    const u8 *session)
+{
+	struct batadv_tp_vars *pos, *tp_vars = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(pos, &bat_priv->tp_list, list) {
+		if (!batadv_compare_eth(pos->other_end, dst))
+			continue;
+
+		if (memcmp(pos->session, session, sizeof(pos->session)) != 0)
+			continue;
+
+		/* most of the time this function is invoked during the normal
+		 * process..it makes sense to pay more when the session is
+		 * finished and to speed the process up during the measurement
+		 */
+		if (unlikely(!kref_get_unless_zero(&pos->refcount)))
+			continue;
+
+		tp_vars = pos;
+		break;
+	}
+	rcu_read_unlock();
+
+	return tp_vars;
+}
+
+/**
+ * batadv_tp_vars_release - release batadv_tp_vars from lists and queue for
+ *  free after rcu grace period
+ * @ref: kref pointer of the batadv_tp_vars
+ */
+static void batadv_tp_vars_release(struct kref *ref)
+{
+	struct batadv_tp_vars *tp_vars;
+	struct batadv_tp_unacked *un, *safe;
+
+	tp_vars = container_of(ref, struct batadv_tp_vars, refcount);
+
+	/* lock should not be needed because this object is now out of any
+	 * context!
+	 */
+	spin_lock_bh(&tp_vars->unacked_lock);
+	list_for_each_entry_safe(un, safe, &tp_vars->unacked_list, list) {
+		list_del(&un->list);
+		kfree(un);
+	}
+	spin_unlock_bh(&tp_vars->unacked_lock);
+
+	kfree_rcu(tp_vars, rcu);
+}
+
+/**
+ * batadv_tp_vars_put - decrement the batadv_tp_vars refcounter and possibly
+ *  release it
+ * @tp_vars: the private data of the current TP meter session to be free'd
+ */
+static void batadv_tp_vars_put(struct batadv_tp_vars *tp_vars)
+{
+	kref_put(&tp_vars->refcount, batadv_tp_vars_release);
+}
+
+/**
+ * batadv_tp_sender_cleanup - cleanup sender data and drop and timer
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tp_vars: the private data of the current TP meter session to cleanup
+ */
+static void batadv_tp_sender_cleanup(struct batadv_priv *bat_priv,
+				     struct batadv_tp_vars *tp_vars)
+{
+	cancel_delayed_work(&tp_vars->finish_work);
+
+	spin_lock_bh(&tp_vars->bat_priv->tp_list_lock);
+	hlist_del_rcu(&tp_vars->list);
+	spin_unlock_bh(&tp_vars->bat_priv->tp_list_lock);
+
+	/* drop list reference */
+	batadv_tp_vars_put(tp_vars);
+
+	atomic_dec(&tp_vars->bat_priv->tp_num);
+
+	/* kill the timer and remove its reference */
+	del_timer_sync(&tp_vars->timer);
+	/* the worker might have rearmed itself therefore we kill it again. Note
+	 * that if the worker should run again before invoking the following
+	 * del_timer(), it would not re-arm itself once again because the status
+	 * is OFF now
+	 */
+	del_timer(&tp_vars->timer);
+	batadv_tp_vars_put(tp_vars);
+}
+
+/**
+ * batadv_tp_sender_end - print info about ended session and inform client
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tp_vars: the private data of the current TP meter session
+ */
+static void batadv_tp_sender_end(struct batadv_priv *bat_priv,
+				 struct batadv_tp_vars *tp_vars)
+{
+	u32 session_cookie;
+
+	batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+		   "Test towards %pM finished..shutting down (reason=%d)\n",
+		   tp_vars->other_end, tp_vars->reason);
+
+	batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+		   "Last timing stats: SRTT=%ums RTTVAR=%ums RTO=%ums\n",
+		   tp_vars->srtt >> 3, tp_vars->rttvar >> 2, tp_vars->rto);
+
+	batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+		   "Final values: cwnd=%u ss_threshold=%u\n",
+		   tp_vars->cwnd, tp_vars->ss_threshold);
+
+	session_cookie = batadv_tp_session_cookie(tp_vars->session,
+						  tp_vars->icmp_uid);
+
+	batadv_tp_batctl_notify(tp_vars->reason,
+				tp_vars->other_end,
+				bat_priv,
+				tp_vars->start_time,
+				atomic64_read(&tp_vars->tot_sent),
+				session_cookie);
+}
+
+/**
+ * batadv_tp_sender_shutdown - let sender thread/timer stop gracefully
+ * @tp_vars: the private data of the current TP meter session
+ * @reason: reason for tp meter session stop
+ */
+static void batadv_tp_sender_shutdown(struct batadv_tp_vars *tp_vars,
+				      enum batadv_tp_meter_reason reason)
+{
+	if (!atomic_dec_and_test(&tp_vars->sending))
+		return;
+
+	tp_vars->reason = reason;
+}
+
+/**
+ * batadv_tp_sender_finish - stop sender session after test_length was reached
+ * @work: delayed work reference of the related tp_vars
+ */
+static void batadv_tp_sender_finish(struct work_struct *work)
+{
+	struct delayed_work *delayed_work;
+	struct batadv_tp_vars *tp_vars;
+
+	delayed_work = to_delayed_work(work);
+	tp_vars = container_of(delayed_work, struct batadv_tp_vars,
+			       finish_work);
+
+	batadv_tp_sender_shutdown(tp_vars, BATADV_TP_REASON_COMPLETE);
+}
+
+/**
+ * batadv_tp_reset_sender_timer - reschedule the sender timer
+ * @tp_vars: the private TP meter data for this session
+ *
+ * Reschedule the timer using tp_vars->rto as delay
+ */
+static void batadv_tp_reset_sender_timer(struct batadv_tp_vars *tp_vars)
+{
+	/* most of the time this function is invoked while normal packet
+	 * reception...
+	 */
+	if (unlikely(atomic_read(&tp_vars->sending) == 0))
+		/* timer ref will be dropped in batadv_tp_sender_cleanup */
+		return;
+
+	mod_timer(&tp_vars->timer, jiffies + msecs_to_jiffies(tp_vars->rto));
+}
+
+/**
+ * batadv_tp_sender_timeout - timer that fires in case of packet loss
+ * @arg: address of the related tp_vars
+ *
+ * If fired it means that there was packet loss.
+ * Switch to Slow Start, set the ss_threshold to half of the current cwnd and
+ * reset the cwnd to 3*MSS
+ */
+static void batadv_tp_sender_timeout(unsigned long arg)
+{
+	struct batadv_tp_vars *tp_vars = (struct batadv_tp_vars *)arg;
+	struct batadv_priv *bat_priv = tp_vars->bat_priv;
+
+	if (atomic_read(&tp_vars->sending) == 0)
+		return;
+
+	/* if the user waited long enough...shutdown the test */
+	if (unlikely(tp_vars->rto >= BATADV_TP_MAX_RTO)) {
+		batadv_tp_sender_shutdown(tp_vars,
+					  BATADV_TP_REASON_DST_UNREACHABLE);
+		return;
+	}
+
+	/* RTO exponential backoff
+	 * Details in Section 5.5 of RFC6298
+	 */
+	tp_vars->rto <<= 1;
+
+	spin_lock_bh(&tp_vars->cwnd_lock);
+
+	tp_vars->ss_threshold = tp_vars->cwnd >> 1;
+	if (tp_vars->ss_threshold < BATADV_TP_PLEN * 2)
+		tp_vars->ss_threshold = BATADV_TP_PLEN * 2;
+
+	batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+		   "Meter: RTO fired during test towards %pM! cwnd=%u new ss_thr=%u, resetting last_sent to %u\n",
+		   tp_vars->other_end, tp_vars->cwnd, tp_vars->ss_threshold,
+		   atomic_read(&tp_vars->last_acked));
+
+	tp_vars->cwnd = BATADV_TP_PLEN * 3;
+
+	spin_unlock_bh(&tp_vars->cwnd_lock);
+
+	/* resend the non-ACKed packets.. */
+	tp_vars->last_sent = atomic_read(&tp_vars->last_acked);
+	wake_up(&tp_vars->more_bytes);
+
+	batadv_tp_reset_sender_timer(tp_vars);
+}
+
+/**
+ * batadv_tp_fill_prerandom - Fill buffer with prefetched random bytes
+ * @tp_vars: the private TP meter data for this session
+ * @buf: Buffer to fill with bytes
+ * @nbytes: amount of pseudorandom bytes
+ */
+static void batadv_tp_fill_prerandom(struct batadv_tp_vars *tp_vars,
+				     u8 *buf, size_t nbytes)
+{
+	u32 local_offset;
+	size_t bytes_inbuf;
+	size_t to_copy;
+	size_t pos = 0;
+
+	spin_lock_bh(&tp_vars->prerandom_lock);
+	local_offset = tp_vars->prerandom_offset;
+	tp_vars->prerandom_offset += nbytes;
+	tp_vars->prerandom_offset %= sizeof(batadv_tp_prerandom);
+	spin_unlock_bh(&tp_vars->prerandom_lock);
+
+	while (nbytes) {
+		local_offset %= sizeof(batadv_tp_prerandom);
+		bytes_inbuf = sizeof(batadv_tp_prerandom) - local_offset;
+		to_copy = min(nbytes, bytes_inbuf);
+
+		memcpy(&buf[pos], &batadv_tp_prerandom[local_offset], to_copy);
+		pos += to_copy;
+		nbytes -= to_copy;
+		local_offset = 0;
+	}
+}
+
+/**
+ * batadv_tp_send_msg - send a single message
+ * @tp_vars: the private TP meter data for this session
+ * @src: source mac address
+ * @orig_node: the originator of the destination
+ * @seqno: sequence number of this packet
+ * @len: length of the entire packet
+ * @session: session identifier
+ * @uid: local ICMP "socket" index
+ * @timestamp: timestamp in jiffies which is replied in ack
+ *
+ * Create and send a single TP Meter message.
+ *
+ * Return: 0 on success, BATADV_TP_REASON_DST_UNREACHABLE if the destination is
+ * not reachable, BATADV_TP_REASON_MEMORY_ERROR if the packet couldn't be
+ * allocated
+ */
+static int batadv_tp_send_msg(struct batadv_tp_vars *tp_vars, const u8 *src,
+			      struct batadv_orig_node *orig_node,
+			      u32 seqno, size_t len, const u8 *session,
+			      int uid, u32 timestamp)
+{
+	struct batadv_icmp_tp_packet *icmp;
+	struct sk_buff *skb;
+	int r;
+	u8 *data;
+	size_t data_len;
+
+	skb = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
+	if (unlikely(!skb))
+		return BATADV_TP_REASON_MEMORY_ERROR;
+
+	skb_reserve(skb, ETH_HLEN);
+	icmp = (struct batadv_icmp_tp_packet *)skb_put(skb, sizeof(*icmp));
+
+	/* fill the icmp header */
+	ether_addr_copy(icmp->dst, orig_node->orig);
+	ether_addr_copy(icmp->orig, src);
+	icmp->version = BATADV_COMPAT_VERSION;
+	icmp->packet_type = BATADV_ICMP;
+	icmp->ttl = BATADV_TTL;
+	icmp->msg_type = BATADV_TP;
+	icmp->uid = uid;
+
+	icmp->subtype = BATADV_TP_MSG;
+	memcpy(icmp->session, session, sizeof(icmp->session));
+	icmp->seqno = htonl(seqno);
+	icmp->timestamp = htonl(timestamp);
+
+	data_len = len - sizeof(*icmp);
+	data = (u8 *)skb_put(skb, data_len);
+	batadv_tp_fill_prerandom(tp_vars, data, data_len);
+
+	r = batadv_send_skb_to_orig(skb, orig_node, NULL);
+	if (r == -1)
+		kfree_skb(skb);
+
+	if (r == NET_XMIT_SUCCESS)
+		return 0;
+
+	return BATADV_TP_REASON_CANT_SEND;
+}
+
+/**
+ * batadv_tp_recv_ack - ACK receiving function
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the buffer containing the received packet
+ *
+ * Process a received TP ACK packet
+ */
+static void batadv_tp_recv_ack(struct batadv_priv *bat_priv,
+			       const struct sk_buff *skb)
+{
+	struct batadv_hard_iface *primary_if = NULL;
+	struct batadv_orig_node *orig_node = NULL;
+	const struct batadv_icmp_tp_packet *icmp;
+	struct batadv_tp_vars *tp_vars;
+	size_t packet_len, mss;
+	u32 rtt, recv_ack, cwnd;
+	unsigned char *dev_addr;
+
+	packet_len = BATADV_TP_PLEN;
+	mss = BATADV_TP_PLEN;
+	packet_len += sizeof(struct batadv_unicast_packet);
+
+	icmp = (struct batadv_icmp_tp_packet *)skb->data;
+
+	/* find the tp_vars */
+	tp_vars = batadv_tp_list_find_session(bat_priv, icmp->orig,
+					      icmp->session);
+	if (unlikely(!tp_vars))
+		return;
+
+	if (unlikely(atomic_read(&tp_vars->sending) == 0))
+		goto out;
+
+	/* old ACK? silently drop it.. */
+	if (batadv_seq_before(ntohl(icmp->seqno),
+			      (u32)atomic_read(&tp_vars->last_acked)))
+		goto out;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (unlikely(!primary_if))
+		goto out;
+
+	orig_node = batadv_orig_hash_find(bat_priv, icmp->orig);
+	if (unlikely(!orig_node))
+		goto out;
+
+	/* update RTO with the new sampled RTT, if any */
+	rtt = jiffies_to_msecs(jiffies) - ntohl(icmp->timestamp);
+	if (icmp->timestamp && rtt)
+		batadv_tp_update_rto(tp_vars, rtt);
+
+	/* ACK for new data... reset the timer */
+	batadv_tp_reset_sender_timer(tp_vars);
+
+	recv_ack = ntohl(icmp->seqno);
+
+	/* check if this ACK is a duplicate */
+	if (atomic_read(&tp_vars->last_acked) == recv_ack) {
+		atomic_inc(&tp_vars->dup_acks);
+		if (atomic_read(&tp_vars->dup_acks) != 3)
+			goto out;
+
+		if (recv_ack >= tp_vars->recover)
+			goto out;
+
+		/* if this is the third duplicate ACK do Fast Retransmit */
+		batadv_tp_send_msg(tp_vars, primary_if->net_dev->dev_addr,
+				   orig_node, recv_ack, packet_len,
+				   icmp->session, icmp->uid,
+				   jiffies_to_msecs(jiffies));
+
+		spin_lock_bh(&tp_vars->cwnd_lock);
+
+		/* Fast Recovery */
+		tp_vars->fast_recovery = true;
+		/* Set recover to the last outstanding seqno when Fast Recovery
+		 * is entered. RFC6582, Section 3.2, step 1
+		 */
+		tp_vars->recover = tp_vars->last_sent;
+		tp_vars->ss_threshold = tp_vars->cwnd >> 1;
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Meter: Fast Recovery, (cur cwnd=%u) ss_thr=%u last_sent=%u recv_ack=%u\n",
+			   tp_vars->cwnd, tp_vars->ss_threshold,
+			   tp_vars->last_sent, recv_ack);
+		tp_vars->cwnd = batadv_tp_cwnd(tp_vars->ss_threshold, 3 * mss,
+					       mss);
+		tp_vars->dec_cwnd = 0;
+		tp_vars->last_sent = recv_ack;
+
+		spin_unlock_bh(&tp_vars->cwnd_lock);
+	} else {
+		/* count the acked data */
+		atomic64_add(recv_ack - atomic_read(&tp_vars->last_acked),
+			     &tp_vars->tot_sent);
+		/* reset the duplicate ACKs counter */
+		atomic_set(&tp_vars->dup_acks, 0);
+
+		if (tp_vars->fast_recovery) {
+			/* partial ACK */
+			if (batadv_seq_before(recv_ack, tp_vars->recover)) {
+				/* this is another hole in the window. React
+				 * immediately as specified by NewReno (see
+				 * Section 3.2 of RFC6582 for details)
+				 */
+				dev_addr = primary_if->net_dev->dev_addr;
+				batadv_tp_send_msg(tp_vars, dev_addr,
+						   orig_node, recv_ack,
+						   packet_len, icmp->session,
+						   icmp->uid,
+						   jiffies_to_msecs(jiffies));
+				tp_vars->cwnd = batadv_tp_cwnd(tp_vars->cwnd,
+							       mss, mss);
+			} else {
+				tp_vars->fast_recovery = false;
+				/* set cwnd to the value of ss_threshold at the
+				 * moment that Fast Recovery was entered.
+				 * RFC6582, Section 3.2, step 3
+				 */
+				cwnd = batadv_tp_cwnd(tp_vars->ss_threshold, 0,
+						      mss);
+				tp_vars->cwnd = cwnd;
+			}
+			goto move_twnd;
+		}
+
+		if (recv_ack - atomic_read(&tp_vars->last_acked) >= mss)
+			batadv_tp_update_cwnd(tp_vars, mss);
+move_twnd:
+		/* move the Transmit Window */
+		atomic_set(&tp_vars->last_acked, recv_ack);
+	}
+
+	wake_up(&tp_vars->more_bytes);
+out:
+	if (likely(primary_if))
+		batadv_hardif_put(primary_if);
+	if (likely(orig_node))
+		batadv_orig_node_put(orig_node);
+	if (likely(tp_vars))
+		batadv_tp_vars_put(tp_vars);
+}
+
+/**
+ * batadv_tp_avail - check if congestion window is not full
+ * @tp_vars: the private data of the current TP meter session
+ * @payload_len: size of the payload of a single message
+ *
+ * Return: true when congestion window is not full, false otherwise
+ */
+static bool batadv_tp_avail(struct batadv_tp_vars *tp_vars,
+			    size_t payload_len)
+{
+	u32 win_left, win_limit;
+
+	win_limit = atomic_read(&tp_vars->last_acked) + tp_vars->cwnd;
+	win_left = win_limit - tp_vars->last_sent;
+
+	return win_left >= payload_len;
+}
+
+/**
+ * batadv_tp_wait_available - wait until congestion window becomes free or
+ *  timeout is reached
+ * @tp_vars: the private data of the current TP meter session
+ * @plen: size of the payload of a single message
+ *
+ * Return: 0 if the condition evaluated to false after the timeout elapsed,
+ *  1 if the condition evaluated to true after the timeout elapsed, the
+ *  remaining jiffies (at least 1) if the condition evaluated to true before
+ *  the timeout elapsed, or -ERESTARTSYS if it was interrupted by a signal.
+ */
+static int batadv_tp_wait_available(struct batadv_tp_vars *tp_vars, size_t plen)
+{
+	int ret;
+
+	ret = wait_event_interruptible_timeout(tp_vars->more_bytes,
+					       batadv_tp_avail(tp_vars, plen),
+					       HZ / 10);
+
+	return ret;
+}
+
+/**
+ * batadv_tp_send - main sending thread of a tp meter session
+ * @arg: address of the related tp_vars
+ *
+ * Return: nothing, this function never returns
+ */
+static int batadv_tp_send(void *arg)
+{
+	struct batadv_tp_vars *tp_vars = arg;
+	struct batadv_priv *bat_priv = tp_vars->bat_priv;
+	struct batadv_hard_iface *primary_if = NULL;
+	struct batadv_orig_node *orig_node = NULL;
+	size_t payload_len, packet_len;
+	int err = 0;
+
+	if (unlikely(tp_vars->role != BATADV_TP_SENDER)) {
+		err = BATADV_TP_REASON_DST_UNREACHABLE;
+		tp_vars->reason = err;
+		goto out;
+	}
+
+	orig_node = batadv_orig_hash_find(bat_priv, tp_vars->other_end);
+	if (unlikely(!orig_node)) {
+		err = BATADV_TP_REASON_DST_UNREACHABLE;
+		tp_vars->reason = err;
+		goto out;
+	}
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (unlikely(!primary_if)) {
+		err = BATADV_TP_REASON_DST_UNREACHABLE;
+		goto out;
+	}
+
+	/* assume that all the hard_interfaces have a correctly
+	 * configured MTU, so use the soft_iface MTU as MSS.
+	 * This might not be true and in that case the fragmentation
+	 * should be used.
+	 * Now, try to send the packet as it is
+	 */
+	payload_len = BATADV_TP_PLEN;
+	BUILD_BUG_ON(sizeof(struct batadv_icmp_tp_packet) > BATADV_TP_PLEN);
+
+	batadv_tp_reset_sender_timer(tp_vars);
+
+	/* queue the worker in charge of terminating the test */
+	queue_delayed_work(batadv_event_workqueue, &tp_vars->finish_work,
+			   msecs_to_jiffies(tp_vars->test_length));
+
+	while (atomic_read(&tp_vars->sending) != 0) {
+		if (unlikely(!batadv_tp_avail(tp_vars, payload_len))) {
+			batadv_tp_wait_available(tp_vars, payload_len);
+			continue;
+		}
+
+		/* to emulate normal unicast traffic, add to the payload len
+		 * the size of the unicast header
+		 */
+		packet_len = payload_len + sizeof(struct batadv_unicast_packet);
+
+		err = batadv_tp_send_msg(tp_vars, primary_if->net_dev->dev_addr,
+					 orig_node, tp_vars->last_sent,
+					 packet_len,
+					 tp_vars->session, tp_vars->icmp_uid,
+					 jiffies_to_msecs(jiffies));
+
+		/* something went wrong during the preparation/transmission */
+		if (unlikely(err && err != BATADV_TP_REASON_CANT_SEND)) {
+			batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+				   "Meter: batadv_tp_send() cannot send packets (%d)\n",
+				   err);
+			/* ensure nobody else tries to stop the thread now */
+			if (atomic_dec_and_test(&tp_vars->sending))
+				tp_vars->reason = err;
+			break;
+		}
+
+		/* right-shift the TWND */
+		if (!err)
+			tp_vars->last_sent += payload_len;
+
+		cond_resched();
+	}
+
+out:
+	if (likely(primary_if))
+		batadv_hardif_put(primary_if);
+	if (likely(orig_node))
+		batadv_orig_node_put(orig_node);
+
+	batadv_tp_sender_end(bat_priv, tp_vars);
+	batadv_tp_sender_cleanup(bat_priv, tp_vars);
+
+	batadv_tp_vars_put(tp_vars);
+
+	do_exit(0);
+}
+
+/**
+ * batadv_tp_start_kthread - start new thread which manages the tp meter sender
+ * @tp_vars: the private data of the current TP meter session
+ */
+static void batadv_tp_start_kthread(struct batadv_tp_vars *tp_vars)
+{
+	struct task_struct *kthread;
+	struct batadv_priv *bat_priv = tp_vars->bat_priv;
+	u32 session_cookie;
+
+	kref_get(&tp_vars->refcount);
+	kthread = kthread_create(batadv_tp_send, tp_vars, "kbatadv_tp_meter");
+	if (IS_ERR(kthread)) {
+		session_cookie = batadv_tp_session_cookie(tp_vars->session,
+							  tp_vars->icmp_uid);
+		pr_err("batadv: cannot create tp meter kthread\n");
+		batadv_tp_batctl_error_notify(BATADV_TP_REASON_MEMORY_ERROR,
+					      tp_vars->other_end,
+					      bat_priv, session_cookie);
+
+		/* drop reserved reference for kthread */
+		batadv_tp_vars_put(tp_vars);
+
+		/* cleanup of failed tp meter variables */
+		batadv_tp_sender_cleanup(bat_priv, tp_vars);
+		return;
+	}
+
+	wake_up_process(kthread);
+}
+
+/**
+ * batadv_tp_start - start a new tp meter session
+ * @bat_priv: the bat priv with all the soft interface information
+ * @dst: the receiver MAC address
+ * @test_length: test length in milliseconds
+ * @cookie: session cookie
+ */
+void batadv_tp_start(struct batadv_priv *bat_priv, const u8 *dst,
+		     u32 test_length, u32 *cookie)
+{
+	struct batadv_tp_vars *tp_vars;
+	u8 session_id[2];
+	u8 icmp_uid;
+	u32 session_cookie;
+
+	get_random_bytes(session_id, sizeof(session_id));
+	get_random_bytes(&icmp_uid, 1);
+	session_cookie = batadv_tp_session_cookie(session_id, icmp_uid);
+	*cookie = session_cookie;
+
+	/* look for an already existing test towards this node */
+	spin_lock_bh(&bat_priv->tp_list_lock);
+	tp_vars = batadv_tp_list_find(bat_priv, dst);
+	if (tp_vars) {
+		spin_unlock_bh(&bat_priv->tp_list_lock);
+		batadv_tp_vars_put(tp_vars);
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Meter: test to or from the same node already ongoing, aborting\n");
+		batadv_tp_batctl_error_notify(BATADV_TP_REASON_ALREADY_ONGOING,
+					      dst, bat_priv, session_cookie);
+		return;
+	}
+
+	if (!atomic_add_unless(&bat_priv->tp_num, 1, BATADV_TP_MAX_NUM)) {
+		spin_unlock_bh(&bat_priv->tp_list_lock);
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Meter: too many ongoing sessions, aborting (SEND)\n");
+		batadv_tp_batctl_error_notify(BATADV_TP_REASON_TOO_MANY, dst,
+					      bat_priv, session_cookie);
+		return;
+	}
+
+	tp_vars = kmalloc(sizeof(*tp_vars), GFP_ATOMIC);
+	if (!tp_vars) {
+		spin_unlock_bh(&bat_priv->tp_list_lock);
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Meter: batadv_tp_start cannot allocate list elements\n");
+		batadv_tp_batctl_error_notify(BATADV_TP_REASON_MEMORY_ERROR,
+					      dst, bat_priv, session_cookie);
+		return;
+	}
+
+	/* initialize tp_vars */
+	ether_addr_copy(tp_vars->other_end, dst);
+	kref_init(&tp_vars->refcount);
+	tp_vars->role = BATADV_TP_SENDER;
+	atomic_set(&tp_vars->sending, 1);
+	memcpy(tp_vars->session, session_id, sizeof(session_id));
+	tp_vars->icmp_uid = icmp_uid;
+
+	tp_vars->last_sent = BATADV_TP_FIRST_SEQ;
+	atomic_set(&tp_vars->last_acked, BATADV_TP_FIRST_SEQ);
+	tp_vars->fast_recovery = false;
+	tp_vars->recover = BATADV_TP_FIRST_SEQ;
+
+	/* initialise the CWND to 3*MSS (Section 3.1 in RFC5681).
+	 * For batman-adv the MSS is the size of the payload received by the
+	 * soft_interface, hence its MTU
+	 */
+	tp_vars->cwnd = BATADV_TP_PLEN * 3;
+	/* at the beginning initialise the SS threshold to the biggest possible
+	 * window size, hence the AWND size
+	 */
+	tp_vars->ss_threshold = BATADV_TP_AWND;
+
+	/* RTO initial value is 3 seconds.
+	 * Details in Section 2.1 of RFC6298
+	 */
+	tp_vars->rto = 1000;
+	tp_vars->srtt = 0;
+	tp_vars->rttvar = 0;
+
+	atomic64_set(&tp_vars->tot_sent, 0);
+
+	kref_get(&tp_vars->refcount);
+	setup_timer(&tp_vars->timer, batadv_tp_sender_timeout,
+		    (unsigned long)tp_vars);
+
+	tp_vars->bat_priv = bat_priv;
+	tp_vars->start_time = jiffies;
+
+	init_waitqueue_head(&tp_vars->more_bytes);
+
+	spin_lock_init(&tp_vars->unacked_lock);
+	INIT_LIST_HEAD(&tp_vars->unacked_list);
+
+	spin_lock_init(&tp_vars->cwnd_lock);
+
+	tp_vars->prerandom_offset = 0;
+	spin_lock_init(&tp_vars->prerandom_lock);
+
+	kref_get(&tp_vars->refcount);
+	hlist_add_head_rcu(&tp_vars->list, &bat_priv->tp_list);
+	spin_unlock_bh(&bat_priv->tp_list_lock);
+
+	tp_vars->test_length = test_length;
+	if (!tp_vars->test_length)
+		tp_vars->test_length = BATADV_TP_DEF_TEST_LENGTH;
+
+	batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+		   "Meter: starting throughput meter towards %pM (length=%ums)\n",
+		   dst, test_length);
+
+	/* init work item for finished tp tests */
+	INIT_DELAYED_WORK(&tp_vars->finish_work, batadv_tp_sender_finish);
+
+	/* start tp kthread. This way the write() call issued from userspace can
+	 * happily return and avoid to block
+	 */
+	batadv_tp_start_kthread(tp_vars);
+
+	/* don't return reference to new tp_vars */
+	batadv_tp_vars_put(tp_vars);
+}
+
+/**
+ * batadv_tp_stop - stop currently running tp meter session
+ * @bat_priv: the bat priv with all the soft interface information
+ * @dst: the receiver MAC address
+ * @return_value: reason for tp meter session stop
+ */
+void batadv_tp_stop(struct batadv_priv *bat_priv, const u8 *dst,
+		    u8 return_value)
+{
+	struct batadv_orig_node *orig_node;
+	struct batadv_tp_vars *tp_vars;
+
+	batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+		   "Meter: stopping test towards %pM\n", dst);
+
+	orig_node = batadv_orig_hash_find(bat_priv, dst);
+	if (!orig_node)
+		return;
+
+	tp_vars = batadv_tp_list_find(bat_priv, orig_node->orig);
+	if (!tp_vars) {
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Meter: trying to interrupt an already over connection\n");
+		goto out;
+	}
+
+	batadv_tp_sender_shutdown(tp_vars, return_value);
+	batadv_tp_vars_put(tp_vars);
+out:
+	batadv_orig_node_put(orig_node);
+}
+
+/**
+ * batadv_tp_reset_receiver_timer - reset the receiver shutdown timer
+ * @tp_vars: the private data of the current TP meter session
+ *
+ * start the receiver shutdown timer or reset it if already started
+ */
+static void batadv_tp_reset_receiver_timer(struct batadv_tp_vars *tp_vars)
+{
+	mod_timer(&tp_vars->timer,
+		  jiffies + msecs_to_jiffies(BATADV_TP_RECV_TIMEOUT));
+}
+
+/**
+ * batadv_tp_receiver_shutdown - stop a tp meter receiver when timeout is
+ *  reached without received ack
+ * @arg: address of the related tp_vars
+ */
+static void batadv_tp_receiver_shutdown(unsigned long arg)
+{
+	struct batadv_tp_vars *tp_vars = (struct batadv_tp_vars *)arg;
+	struct batadv_tp_unacked *un, *safe;
+	struct batadv_priv *bat_priv;
+
+	bat_priv = tp_vars->bat_priv;
+
+	/* if there is recent activity rearm the timer */
+	if (!batadv_has_timed_out(tp_vars->last_recv_time,
+				  BATADV_TP_RECV_TIMEOUT)) {
+		/* reset the receiver shutdown timer */
+		batadv_tp_reset_receiver_timer(tp_vars);
+		return;
+	}
+
+	batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+		   "Shutting down for inactivity (more than %dms) from %pM\n",
+		   BATADV_TP_RECV_TIMEOUT, tp_vars->other_end);
+
+	spin_lock_bh(&tp_vars->bat_priv->tp_list_lock);
+	hlist_del_rcu(&tp_vars->list);
+	spin_unlock_bh(&tp_vars->bat_priv->tp_list_lock);
+
+	/* drop list reference */
+	batadv_tp_vars_put(tp_vars);
+
+	atomic_dec(&bat_priv->tp_num);
+
+	spin_lock_bh(&tp_vars->unacked_lock);
+	list_for_each_entry_safe(un, safe, &tp_vars->unacked_list, list) {
+		list_del(&un->list);
+		kfree(un);
+	}
+	spin_unlock_bh(&tp_vars->unacked_lock);
+
+	/* drop reference of timer */
+	batadv_tp_vars_put(tp_vars);
+}
+
+/**
+ * batadv_tp_send_ack - send an ACK packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @dst: the mac address of the destination originator
+ * @seq: the sequence number to ACK
+ * @timestamp: the timestamp to echo back in the ACK
+ * @session: session identifier
+ * @socket_index: local ICMP socket identifier
+ *
+ * Return: 0 on success, a positive integer representing the reason of the
+ * failure otherwise
+ */
+static int batadv_tp_send_ack(struct batadv_priv *bat_priv, const u8 *dst,
+			      u32 seq, __be32 timestamp, const u8 *session,
+			      int socket_index)
+{
+	struct batadv_hard_iface *primary_if = NULL;
+	struct batadv_orig_node *orig_node;
+	struct batadv_icmp_tp_packet *icmp;
+	struct sk_buff *skb;
+	int r, ret;
+
+	orig_node = batadv_orig_hash_find(bat_priv, dst);
+	if (unlikely(!orig_node)) {
+		ret = BATADV_TP_REASON_DST_UNREACHABLE;
+		goto out;
+	}
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (unlikely(!primary_if)) {
+		ret = BATADV_TP_REASON_DST_UNREACHABLE;
+		goto out;
+	}
+
+	skb = netdev_alloc_skb_ip_align(NULL, sizeof(*icmp) + ETH_HLEN);
+	if (unlikely(!skb)) {
+		ret = BATADV_TP_REASON_MEMORY_ERROR;
+		goto out;
+	}
+
+	skb_reserve(skb, ETH_HLEN);
+	icmp = (struct batadv_icmp_tp_packet *)skb_put(skb, sizeof(*icmp));
+	icmp->packet_type = BATADV_ICMP;
+	icmp->version = BATADV_COMPAT_VERSION;
+	icmp->ttl = BATADV_TTL;
+	icmp->msg_type = BATADV_TP;
+	ether_addr_copy(icmp->dst, orig_node->orig);
+	ether_addr_copy(icmp->orig, primary_if->net_dev->dev_addr);
+	icmp->uid = socket_index;
+
+	icmp->subtype = BATADV_TP_ACK;
+	memcpy(icmp->session, session, sizeof(icmp->session));
+	icmp->seqno = htonl(seq);
+	icmp->timestamp = timestamp;
+
+	/* send the ack */
+	r = batadv_send_skb_to_orig(skb, orig_node, NULL);
+	if (r == -1)
+		kfree_skb(skb);
+
+	if (unlikely(r < 0) || (r == NET_XMIT_DROP)) {
+		ret = BATADV_TP_REASON_DST_UNREACHABLE;
+		goto out;
+	}
+	ret = 0;
+
+out:
+	if (likely(orig_node))
+		batadv_orig_node_put(orig_node);
+	if (likely(primary_if))
+		batadv_hardif_put(primary_if);
+
+	return ret;
+}
+
+/**
+ * batadv_tp_handle_out_of_order - store an out of order packet
+ * @tp_vars: the private data of the current TP meter session
+ * @skb: the buffer containing the received packet
+ *
+ * Store the out of order packet in the unacked list for late processing. This
+ * packets are kept in this list so that they can be ACKed at once as soon as
+ * all the previous packets have been received
+ *
+ * Return: true if the packed has been successfully processed, false otherwise
+ */
+static bool batadv_tp_handle_out_of_order(struct batadv_tp_vars *tp_vars,
+					  const struct sk_buff *skb)
+{
+	const struct batadv_icmp_tp_packet *icmp;
+	struct batadv_tp_unacked *un, *new;
+	u32 payload_len;
+	bool added = false;
+
+	new = kmalloc(sizeof(*new), GFP_ATOMIC);
+	if (unlikely(!new))
+		return false;
+
+	icmp = (struct batadv_icmp_tp_packet *)skb->data;
+
+	new->seqno = ntohl(icmp->seqno);
+	payload_len = skb->len - sizeof(struct batadv_unicast_packet);
+	new->len = payload_len;
+
+	spin_lock_bh(&tp_vars->unacked_lock);
+	/* if the list is empty immediately attach this new object */
+	if (list_empty(&tp_vars->unacked_list)) {
+		list_add(&new->list, &tp_vars->unacked_list);
+		goto out;
+	}
+
+	/* otherwise loop over the list and either drop the packet because this
+	 * is a duplicate or store it at the right position.
+	 *
+	 * The iteration is done in the reverse way because it is likely that
+	 * the last received packet (the one being processed now) has a bigger
+	 * seqno than all the others already stored.
+	 */
+	list_for_each_entry_reverse(un, &tp_vars->unacked_list, list) {
+		/* check for duplicates */
+		if (new->seqno == un->seqno) {
+			if (new->len > un->len)
+				un->len = new->len;
+			kfree(new);
+			added = true;
+			break;
+		}
+
+		/* look for the right position */
+		if (batadv_seq_before(new->seqno, un->seqno))
+			continue;
+
+		/* as soon as an entry having a bigger seqno is found, the new
+		 * one is attached _after_ it. In this way the list is kept in
+		 * ascending order
+		 */
+		list_add_tail(&new->list, &un->list);
+		added = true;
+		break;
+	}
+
+	/* received packet with smallest seqno out of order; add it to front */
+	if (!added)
+		list_add(&new->list, &tp_vars->unacked_list);
+
+out:
+	spin_unlock_bh(&tp_vars->unacked_lock);
+
+	return true;
+}
+
+/**
+ * batadv_tp_ack_unordered - update number received bytes in current stream
+ *  without gaps
+ * @tp_vars: the private data of the current TP meter session
+ */
+static void batadv_tp_ack_unordered(struct batadv_tp_vars *tp_vars)
+{
+	struct batadv_tp_unacked *un, *safe;
+	u32 to_ack;
+
+	/* go through the unacked packet list and possibly ACK them as
+	 * well
+	 */
+	spin_lock_bh(&tp_vars->unacked_lock);
+	list_for_each_entry_safe(un, safe, &tp_vars->unacked_list, list) {
+		/* the list is ordered, therefore it is possible to stop as soon
+		 * there is a gap between the last acked seqno and the seqno of
+		 * the packet under inspection
+		 */
+		if (batadv_seq_before(tp_vars->last_recv, un->seqno))
+			break;
+
+		to_ack = un->seqno + un->len - tp_vars->last_recv;
+
+		if (batadv_seq_before(tp_vars->last_recv, un->seqno + un->len))
+			tp_vars->last_recv += to_ack;
+
+		list_del(&un->list);
+		kfree(un);
+	}
+	spin_unlock_bh(&tp_vars->unacked_lock);
+}
+
+/**
+ * batadv_tp_init_recv - return matching or create new receiver tp_vars
+ * @bat_priv: the bat priv with all the soft interface information
+ * @icmp: received icmp tp msg
+ *
+ * Return: corresponding tp_vars or NULL on errors
+ */
+static struct batadv_tp_vars *
+batadv_tp_init_recv(struct batadv_priv *bat_priv,
+		    const struct batadv_icmp_tp_packet *icmp)
+{
+	struct batadv_tp_vars *tp_vars;
+
+	spin_lock_bh(&bat_priv->tp_list_lock);
+	tp_vars = batadv_tp_list_find_session(bat_priv, icmp->orig,
+					      icmp->session);
+	if (tp_vars)
+		goto out_unlock;
+
+	if (!atomic_add_unless(&bat_priv->tp_num, 1, BATADV_TP_MAX_NUM)) {
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Meter: too many ongoing sessions, aborting (RECV)\n");
+		goto out_unlock;
+	}
+
+	tp_vars = kmalloc(sizeof(*tp_vars), GFP_ATOMIC);
+	if (!tp_vars)
+		goto out_unlock;
+
+	ether_addr_copy(tp_vars->other_end, icmp->orig);
+	tp_vars->role = BATADV_TP_RECEIVER;
+	memcpy(tp_vars->session, icmp->session, sizeof(tp_vars->session));
+	tp_vars->last_recv = BATADV_TP_FIRST_SEQ;
+	tp_vars->bat_priv = bat_priv;
+	kref_init(&tp_vars->refcount);
+
+	spin_lock_init(&tp_vars->unacked_lock);
+	INIT_LIST_HEAD(&tp_vars->unacked_list);
+
+	kref_get(&tp_vars->refcount);
+	hlist_add_head_rcu(&tp_vars->list, &bat_priv->tp_list);
+
+	kref_get(&tp_vars->refcount);
+	setup_timer(&tp_vars->timer, batadv_tp_receiver_shutdown,
+		    (unsigned long)tp_vars);
+
+	batadv_tp_reset_receiver_timer(tp_vars);
+
+out_unlock:
+	spin_unlock_bh(&bat_priv->tp_list_lock);
+
+	return tp_vars;
+}
+
+/**
+ * batadv_tp_recv_msg - process a single data message
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the buffer containing the received packet
+ *
+ * Process a received TP MSG packet
+ */
+static void batadv_tp_recv_msg(struct batadv_priv *bat_priv,
+			       const struct sk_buff *skb)
+{
+	const struct batadv_icmp_tp_packet *icmp;
+	struct batadv_tp_vars *tp_vars;
+	size_t packet_size;
+	u32 seqno;
+
+	icmp = (struct batadv_icmp_tp_packet *)skb->data;
+
+	seqno = ntohl(icmp->seqno);
+	/* check if this is the first seqno. This means that if the
+	 * first packet is lost, the tp meter does not work anymore!
+	 */
+	if (seqno == BATADV_TP_FIRST_SEQ) {
+		tp_vars = batadv_tp_init_recv(bat_priv, icmp);
+		if (!tp_vars) {
+			batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+				   "Meter: seqno != BATADV_TP_FIRST_SEQ cannot initiate connection\n");
+			goto out;
+		}
+	} else {
+		tp_vars = batadv_tp_list_find_session(bat_priv, icmp->orig,
+						      icmp->session);
+		if (!tp_vars) {
+			batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+				   "Unexpected packet from %pM!\n",
+				   icmp->orig);
+			goto out;
+		}
+	}
+
+	if (unlikely(tp_vars->role != BATADV_TP_RECEIVER)) {
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Meter: dropping packet: not expected (role=%u)\n",
+			   tp_vars->role);
+		goto out;
+	}
+
+	tp_vars->last_recv_time = jiffies;
+
+	/* if the packet is a duplicate, it may be the case that an ACK has been
+	 * lost. Resend the ACK
+	 */
+	if (batadv_seq_before(seqno, tp_vars->last_recv))
+		goto send_ack;
+
+	/* if the packet is out of order enqueue it */
+	if (ntohl(icmp->seqno) != tp_vars->last_recv) {
+		/* exit immediately (and do not send any ACK) if the packet has
+		 * not been enqueued correctly
+		 */
+		if (!batadv_tp_handle_out_of_order(tp_vars, skb))
+			goto out;
+
+		/* send a duplicate ACK */
+		goto send_ack;
+	}
+
+	/* if everything was fine count the ACKed bytes */
+	packet_size = skb->len - sizeof(struct batadv_unicast_packet);
+	tp_vars->last_recv += packet_size;
+
+	/* check if this ordered message filled a gap.... */
+	batadv_tp_ack_unordered(tp_vars);
+
+send_ack:
+	/* send the ACK. If the received packet was out of order, the ACK that
+	 * is going to be sent is a duplicate (the sender will count them and
+	 * possibly enter Fast Retransmit as soon as it has reached 3)
+	 */
+	batadv_tp_send_ack(bat_priv, icmp->orig, tp_vars->last_recv,
+			   icmp->timestamp, icmp->session, icmp->uid);
+out:
+	if (likely(tp_vars))
+		batadv_tp_vars_put(tp_vars);
+}
+
+/**
+ * batadv_tp_meter_recv - main TP Meter receiving function
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the buffer containing the received packet
+ */
+void batadv_tp_meter_recv(struct batadv_priv *bat_priv, struct sk_buff *skb)
+{
+	struct batadv_icmp_tp_packet *icmp;
+
+	icmp = (struct batadv_icmp_tp_packet *)skb->data;
+
+	switch (icmp->subtype) {
+	case BATADV_TP_MSG:
+		batadv_tp_recv_msg(bat_priv, skb);
+		break;
+	case BATADV_TP_ACK:
+		batadv_tp_recv_ack(bat_priv, skb);
+		break;
+	default:
+		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
+			   "Received unknown TP Metric packet type %u\n",
+			   icmp->subtype);
+	}
+	consume_skb(skb);
+}
+
+/**
+ * batadv_tp_meter_init - initialize global tp_meter structures
+ */
+void batadv_tp_meter_init(void)
+{
+	get_random_bytes(batadv_tp_prerandom, sizeof(batadv_tp_prerandom));
+}
diff --git a/net/batman-adv/tp_meter.h b/net/batman-adv/tp_meter.h
new file mode 100644
index 0000000..ba922c4
--- /dev/null
+++ b/net/batman-adv/tp_meter.h
@@ -0,0 +1,34 @@
+/* Copyright (C) 2012-2016 B.A.T.M.A.N. contributors:
+ *
+ * Edo Monticelli, Antonio Quartulli
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
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef _NET_BATMAN_ADV_TP_METER_H_
+#define _NET_BATMAN_ADV_TP_METER_H_
+
+#include "main.h"
+
+#include <linux/types.h>
+
+struct sk_buff;
+
+void batadv_tp_meter_init(void);
+void batadv_tp_start(struct batadv_priv *bat_priv, const u8 *dst,
+		     u32 test_length, u32 *cookie);
+void batadv_tp_stop(struct batadv_priv *bat_priv, const u8 *dst,
+		    u8 return_value);
+void batadv_tp_meter_recv(struct batadv_priv *bat_priv, struct sk_buff *skb);
+
+#endif /* _NET_BATMAN_ADV_TP_METER_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ab863a5..a331e3a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -33,6 +33,7 @@
 #include <linux/types.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "packet.h"
 
@@ -833,6 +834,111 @@ struct batadv_priv_nc {
 };
 
 /**
+ * struct batadv_tp_unacked - unacked packet meta-information
+ * @seqno: seqno of the unacked packet
+ * @len: length of the packet
+ * @list: list node for batadv_tp_vars::unacked_list
+ *
+ * This struct is supposed to represent a buffer unacked packet. However, since
+ * the purpose of the TP meter is to count the traffic only, there is no need to
+ * store the entire sk_buff, the starting offset and the length are enough
+ */
+struct batadv_tp_unacked {
+	u32 seqno;
+	u16 len;
+	struct list_head list;
+};
+
+/**
+ * enum batadv_tp_meter_role - Modus in tp meter session
+ * @BATADV_TP_RECEIVER: Initialized as receiver
+ * @BATADV_TP_SENDER: Initialized as sender
+ */
+enum batadv_tp_meter_role {
+	BATADV_TP_RECEIVER,
+	BATADV_TP_SENDER
+};
+
+/**
+ * struct batadv_tp_vars - tp meter private variables per session
+ * @list: list node for bat_priv::tp_list
+ * @timer: timer for ack (receiver) and retry (sender)
+ * @bat_priv: pointer to the mesh object
+ * @start_time: start time in jiffies
+ * @other_end: mac address of remote
+ * @role: receiver/sender modi
+ * @sending: sending binary semaphore: 1 if sending, 0 is not
+ * @reason: reason for a stopped session
+ * @finish_work: work item for the finishing procedure
+ * @test_length: test length in milliseconds
+ * @session: TP session identifier
+ * @icmp_uid: local ICMP "socket" index
+ * @dec_cwnd: decimal part of the cwnd used during linear growth
+ * @cwnd: current size of the congestion window
+ * @cwnd_lock: lock do protect @cwnd & @dec_cwnd
+ * @ss_threshold: Slow Start threshold. Once cwnd exceeds this value the
+ *  connection switches to the Congestion Avoidance state
+ * @last_acked: last acked byte
+ * @last_sent: last sent byte, not yet acked
+ * @tot_sent: amount of data sent/ACKed so far
+ * @dup_acks: duplicate ACKs counter
+ * @fast_recovery: true if in Fast Recovery mode
+ * @recover: last sent seqno when entering Fast Recovery
+ * @rto: sender timeout
+ * @srtt: smoothed RTT scaled by 2^3
+ * @rttvar: RTT variation scaled by 2^2
+ * @more_bytes: waiting queue anchor when waiting for more ack/retry timeout
+ * @prerandom_offset: offset inside the prerandom buffer
+ * @prerandom_lock: spinlock protecting access to prerandom_offset
+ * @last_recv: last in-order received packet
+ * @unacked_list: list of unacked packets (meta-info only)
+ * @unacked_lock: protect unacked_list
+ * @last_recv_time: time time (jiffies) a msg was received
+ * @refcount: number of context where the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
+struct batadv_tp_vars {
+	struct hlist_node list;
+	struct timer_list timer;
+	struct batadv_priv *bat_priv;
+	unsigned long start_time;
+	u8 other_end[ETH_ALEN];
+	enum batadv_tp_meter_role role;
+	atomic_t sending;
+	enum batadv_tp_meter_reason reason;
+	struct delayed_work finish_work;
+	u32 test_length;
+	u8 session[2];
+	u8 icmp_uid;
+
+	/* sender variables */
+	u16 dec_cwnd;
+	u32 cwnd;
+	spinlock_t cwnd_lock; /* Protects cwnd & dec_cwnd */
+	u32 ss_threshold;
+	atomic_t last_acked;
+	u32 last_sent;
+	atomic64_t tot_sent;
+	atomic_t dup_acks;
+	bool fast_recovery;
+	u32 recover;
+	u32 rto;
+	u32 srtt;
+	u32 rttvar;
+	wait_queue_head_t more_bytes;
+	u32 prerandom_offset;
+	spinlock_t prerandom_lock; /* Protects prerandom_offset */
+
+	/* receiver variables */
+	u32 last_recv;
+	struct list_head unacked_list;
+	spinlock_t unacked_lock; /* Protects unacked_list */
+	unsigned long last_recv_time;
+	struct kref refcount;
+	struct rcu_head rcu;
+};
+
+/**
  * struct batadv_softif_vlan - per VLAN attributes set
  * @bat_priv: pointer to the mesh object
  * @vid: VLAN identifier
@@ -900,9 +1006,12 @@ struct batadv_priv_bat_v {
  * @debug_dir: dentry for debugfs batman-adv subdirectory
  * @forw_bat_list: list of aggregated OGMs that will be forwarded
  * @forw_bcast_list: list of broadcast packets that will be rebroadcasted
+ * @tp_list: list of tp sessions
+ * @tp_num: number of currently active tp sessions
  * @orig_hash: hash table containing mesh participants (orig nodes)
  * @forw_bat_list_lock: lock protecting forw_bat_list
  * @forw_bcast_list_lock: lock protecting forw_bcast_list
+ * @tp_list_lock: spinlock protecting @tp_list
  * @orig_work: work queue callback item for orig node purging
  * @cleanup_work: work queue callback item for soft-interface deinit
  * @primary_if: one of the hard-interfaces assigned to this mesh interface
@@ -956,9 +1065,12 @@ struct batadv_priv {
 	struct dentry *debug_dir;
 	struct hlist_head forw_bat_list;
 	struct hlist_head forw_bcast_list;
+	struct hlist_head tp_list;
 	struct batadv_hashtable *orig_hash;
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects forw_bcast_list */
+	spinlock_t tp_list_lock; /* protects tp_list */
+	atomic_t tp_num;
 	struct delayed_work orig_work;
 	struct work_struct cleanup_work;
 	struct batadv_hard_iface __rcu *primary_if;  /* rcu protected pointer */
-- 
2.8.1
