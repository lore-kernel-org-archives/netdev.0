From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 03/16] batman-adv: netlink: add routing_algo query
Date: Tue, 16 Aug 2016 10:32:31 +0200
Message-ID: <1471336364-16334-4-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sven Eckelmann <sven.eckelmann@open-mesh.com>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:58583 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbcHPIdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 04:33:25 -0400
In-Reply-To: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

BATADV_CMD_GET_ROUTING_ALGOS is used to get the list of supported routing
algorithms.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[sven.eckelmann@open-mesh.com: Reduce the number of changes to
BATADV_CMD_GET_ROUTING_ALGOS, fix includes]
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 include/uapi/linux/batman_adv.h |  2 ++
 net/batman-adv/bat_algo.c       | 68 +++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/bat_algo.h       |  3 ++
 net/batman-adv/netlink.c        |  9 +++++-
 net/batman-adv/netlink.h        |  3 ++
 5 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 0fbf6fd..7afce44 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -73,6 +73,7 @@ enum batadv_nl_attrs {
  * @BATADV_CMD_GET_MESH_INFO: Query basic information about batman-adv device
  * @BATADV_CMD_TP_METER: Start a tp meter session
  * @BATADV_CMD_TP_METER_CANCEL: Cancel a tp meter session
+ * @BATADV_CMD_GET_ROUTING_ALGOS: Query the list of routing algorithms.
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
@@ -81,6 +82,7 @@ enum batadv_nl_commands {
 	BATADV_CMD_GET_MESH_INFO,
 	BATADV_CMD_TP_METER,
 	BATADV_CMD_TP_METER_CANCEL,
+	BATADV_CMD_GET_ROUTING_ALGOS,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/bat_algo.c b/net/batman-adv/bat_algo.c
index 81dbbf5..f2cc50d3 100644
--- a/net/batman-adv/bat_algo.c
+++ b/net/batman-adv/bat_algo.c
@@ -20,12 +20,18 @@
 #include <linux/errno.h>
 #include <linux/list.h>
 #include <linux/moduleparam.h>
+#include <linux/netlink.h>
 #include <linux/printk.h>
 #include <linux/seq_file.h>
+#include <linux/skbuff.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
+#include <net/genetlink.h>
+#include <net/netlink.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
+#include "netlink.h"
 
 char batadv_routing_algo[20] = "BATMAN_IV";
 static struct hlist_head batadv_algo_list;
@@ -138,3 +144,65 @@ static struct kparam_string batadv_param_string_ra = {
 
 module_param_cb(routing_algo, &batadv_param_ops_ra, &batadv_param_string_ra,
 		0644);
+
+/**
+ * batadv_algo_dump_entry - fill in information about one supported routing
+ *  algorithm
+ * @msg: netlink message to be sent back
+ * @portid: Port to reply to
+ * @seq: Sequence number of message
+ * @bat_algo_ops: Algorithm to be dumped
+ *
+ * Return: Error number, or 0 on success
+ */
+static int batadv_algo_dump_entry(struct sk_buff *msg, u32 portid, u32 seq,
+				  struct batadv_algo_ops *bat_algo_ops)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family,
+			  NLM_F_MULTI, BATADV_CMD_GET_ROUTING_ALGOS);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (nla_put_string(msg, BATADV_ATTR_ALGO_NAME, bat_algo_ops->name))
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
+ * batadv_algo_dump - fill in information about supported routing
+ *  algorithms
+ * @msg: netlink message to be sent back
+ * @cb: Parameters to the netlink request
+ *
+ * Return: Length of reply message.
+ */
+int batadv_algo_dump(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	int portid = NETLINK_CB(cb->skb).portid;
+	struct batadv_algo_ops *bat_algo_ops;
+	int skip = cb->args[0];
+	int i = 0;
+
+	hlist_for_each_entry(bat_algo_ops, &batadv_algo_list, list) {
+		if (i++ < skip)
+			continue;
+
+		if (batadv_algo_dump_entry(msg, portid, cb->nlh->nlmsg_seq,
+					   bat_algo_ops)) {
+			i--;
+			break;
+		}
+	}
+
+	cb->args[0] = i;
+
+	return msg->len;
+}
diff --git a/net/batman-adv/bat_algo.h b/net/batman-adv/bat_algo.h
index 860d773..3b5b69c 100644
--- a/net/batman-adv/bat_algo.h
+++ b/net/batman-adv/bat_algo.h
@@ -22,7 +22,9 @@
 
 #include <linux/types.h>
 
+struct netlink_callback;
 struct seq_file;
+struct sk_buff;
 
 extern char batadv_routing_algo[];
 extern struct list_head batadv_hardif_list;
@@ -31,5 +33,6 @@ void batadv_algo_init(void);
 int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
+int batadv_algo_dump(struct sk_buff *msg, struct netlink_callback *cb);
 
 #endif /* _NET_BATMAN_ADV_BAT_ALGO_H_ */
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 231f8ea..19fb265 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -32,13 +32,14 @@
 #include <net/netlink.h>
 #include <uapi/linux/batman_adv.h>
 
+#include "bat_algo.h"
 #include "hard-interface.h"
 #include "soft-interface.h"
 #include "tp_meter.h"
 
 struct sk_buff;
 
-static struct genl_family batadv_netlink_family = {
+struct genl_family batadv_netlink_family = {
 	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
 	.name = BATADV_NL_NAME,
@@ -399,6 +400,12 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.doit = batadv_netlink_tp_meter_cancel,
 	},
+	{
+		.cmd = BATADV_CMD_GET_ROUTING_ALGOS,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_algo_dump,
+	},
 };
 
 /**
diff --git a/net/batman-adv/netlink.h b/net/batman-adv/netlink.h
index 945653a..b399f49 100644
--- a/net/batman-adv/netlink.h
+++ b/net/batman-adv/netlink.h
@@ -21,6 +21,7 @@
 #include "main.h"
 
 #include <linux/types.h>
+#include <net/genetlink.h>
 
 void batadv_netlink_register(void);
 void batadv_netlink_unregister(void);
@@ -29,4 +30,6 @@ int batadv_netlink_tpmeter_notify(struct batadv_priv *bat_priv, const u8 *dst,
 				  u8 result, u32 test_time, u64 total_bytes,
 				  u32 cookie);
 
+extern struct genl_family batadv_netlink_family;
+
 #endif /* _NET_BATMAN_ADV_NETLINK_H_ */
-- 
2.8.1
