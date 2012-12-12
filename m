From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 4/5] netns: advertise netns activity with netlink
Date: Wed, 12 Dec 2012 18:17:09 +0100
Message-ID: <1355332630-4256-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, aatteka@nicira.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39201 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884Ab2LLRxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:53:51 -0500
In-Reply-To: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Goal of this patch is to send netlink messages when netns are crated/deleted.
This is useful for daemon that wants to manage all netns with only one running
instance.
Note that until that netns_nl_event_mcgrp group is not registered, we cannot
send event.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/netns.h |  4 ++++
 net/core/net_namespace.c   | 38 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netns.h b/include/uapi/linux/netns.h
index e1c1da3..e14d90b 100644
--- a/include/uapi/linux/netns.h
+++ b/include/uapi/linux/netns.h
@@ -6,10 +6,14 @@
 #define NETNS_GENL_NAME			"netns"
 #define NETNS_GENL_VERSION		0x1
 
+#define NETNS_GENL_MCAST_EVENT_NAME	"events"
+
 /* Commands */
 enum {
 	NETNS_CMD_NOOP,
 	NETNS_CMD_GET,
+	NETNS_CMD_NEW,
+	NETNS_CMD_DEL,
 	__NETNS_CMD_MAX,
 };
 #define NETNS_CMD_MAX		(__NETNS_CMD_MAX - 1)
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 18fc62f..da92ecb 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -40,6 +40,8 @@ EXPORT_SYMBOL(init_net);
 
 static unsigned int max_gen_ptrs = INITIAL_NET_GEN_PTRS;
 
+static int netns_nl_event(struct net *net, int cmd);
+
 static struct net_generic *net_alloc_generic(void)
 {
 	struct net_generic *ng;
@@ -179,6 +181,7 @@ again:
 		if (error < 0)
 			goto out_undo;
 	}
+	netns_nl_event(net, NETNS_CMD_NEW);
 out:
 	return error;
 
@@ -311,6 +314,7 @@ static void cleanup_net(struct work_struct *work)
 	synchronize_rcu();
 
 	list_for_each_entry(net, &net_exit_list, exit_list) {
+		netns_nl_event(net, NETNS_CMD_DEL);
 		/* Free the index */
 		ida_remove(&net_namespace_ids, net->nsindex);
 	}
@@ -413,6 +417,10 @@ struct net *get_net_ns_by_nsindex(int nsindex)
 }
 EXPORT_SYMBOL_GPL(get_net_ns_by_nsindex);
 
+static struct genl_multicast_group netns_nl_event_mcgrp = {
+	.name = NETNS_GENL_MCAST_EVENT_NAME,
+};
+
 static struct genl_family netns_nl_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= NETNS_GENL_NAME,
@@ -562,10 +570,38 @@ static struct genl_ops netns_nl_ops[] = {
 	},
 };
 
+static int netns_nl_event(struct net *net, int cmd)
+{
+	struct sk_buff *msg;
+	int err = -ENOBUFS;
+
+	/* Check that gennl infra is ready */
+	if (!netns_nl_event_mcgrp.id)
+		return -ENOENT;
+
+	msg = genlmsg_new(netns_nl_get_size(), GFP_ATOMIC);
+	if (!msg)
+		return -ENOMEM;
+
+	err = netns_nl_fill(msg, 0, 0, 0, cmd, net);
+	if (err < 0) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_multicast(msg, 0, netns_nl_event_mcgrp.id, GFP_ATOMIC);
+}
+
 int netns_genl_register(void)
 {
-	return genl_register_family_with_ops(&netns_nl_family, netns_nl_ops,
+	int err;
+
+	err =  genl_register_family_with_ops(&netns_nl_family, netns_nl_ops,
 					     ARRAY_SIZE(netns_nl_ops));
+	if (err < 0)
+		return err;
+
+	return genl_register_mc_group(&netns_nl_family, &netns_nl_event_mcgrp);
 }
 
 static int __init net_ns_init(void)
-- 
1.8.0.1
