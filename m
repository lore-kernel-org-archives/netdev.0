From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 2/5] netns: allow to dump netns with netlink
Date: Wed, 12 Dec 2012 18:17:07 +0100
Message-ID: <1355332630-4256-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, aatteka@nicira.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39193 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab2LLRxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:53:51 -0500
In-Reply-To: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the basic support of netlink for netns. The user can dump all
existing netns and get associated nsindex.
He also can get nsindex associated to a pid or fd.

To initialize genetlink family for netns, there is a problem of chicken and
eggs. genetlink init is done after init_net is created, hence when init_net is
created, we cannot call genl_register_family_with_ops(). It's why I put the
init part in genetlink module.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/net_namespace.h |   1 +
 include/uapi/linux/netns.h  |  27 ++++++++
 net/core/net_namespace.c    | 157 ++++++++++++++++++++++++++++++++++++++++++++
 net/netlink/genetlink.c     |   4 ++
 4 files changed, 189 insertions(+)
 create mode 100644 include/uapi/linux/netns.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 5db7a1b..c373f2e 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -306,6 +306,7 @@ extern int register_pernet_subsys(struct pernet_operations *);
 extern void unregister_pernet_subsys(struct pernet_operations *);
 extern int register_pernet_device(struct pernet_operations *);
 extern void unregister_pernet_device(struct pernet_operations *);
+extern int netns_genl_register(void);
 
 struct ctl_table;
 struct ctl_table_header;
diff --git a/include/uapi/linux/netns.h b/include/uapi/linux/netns.h
new file mode 100644
index 0000000..e1c1da3
--- /dev/null
+++ b/include/uapi/linux/netns.h
@@ -0,0 +1,27 @@
+#ifndef _UAPI_LINUX_NETNS_H_
+#define _UAPI_LINUX_NETNS_H_
+
+/* Generic netlink messages */
+
+#define NETNS_GENL_NAME			"netns"
+#define NETNS_GENL_VERSION		0x1
+
+/* Commands */
+enum {
+	NETNS_CMD_NOOP,
+	NETNS_CMD_GET,
+	__NETNS_CMD_MAX,
+};
+#define NETNS_CMD_MAX		(__NETNS_CMD_MAX - 1)
+
+/* Attributes */
+enum {
+	NETNSA_NONE,
+	NETNSA_NSINDEX,
+	NETNSA_PID,
+	NETNSA_FD,
+	__NETNSA_MAX,
+};
+#define NETNSA_MAX		(__NETNSA_MAX - 1)
+
+#endif /* _UAPI_LINUX_NETNS_H_ */
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index f5267e4..2ae22b0 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -14,6 +14,8 @@
 #include <linux/file.h>
 #include <linux/export.h>
 #include <linux/user_namespace.h>
+#include <linux/netns.h>
+#include <net/genetlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -397,6 +399,161 @@ struct net *get_net_ns_by_pid(pid_t pid)
 }
 EXPORT_SYMBOL_GPL(get_net_ns_by_pid);
 
+static struct genl_family netns_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= NETNS_GENL_NAME,
+	.version	= NETNS_GENL_VERSION,
+	.hdrsize	= 0,
+	.maxattr	= NETNSA_MAX,
+	.netnsok	= true,
+};
+
+static struct nla_policy netns_nl_policy[NETNSA_MAX + 1] = {
+	[NETNSA_NONE]		= { .type = NLA_UNSPEC, },
+	[NETNSA_NSINDEX]	= { .type = NLA_U32, },
+	[NETNSA_PID]		= { .type = NLA_U32 },
+	[NETNSA_FD]		= { .type = NLA_U32 },
+};
+
+static int netns_nl_get_size(void)
+{
+	return nla_total_size(sizeof(u32)) /* NETNSA_NSINDEX */
+	       ;
+}
+
+static int netns_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	void *hdr;
+	int ret = -ENOBUFS;
+
+	msg = genlmsg_new(netns_nl_get_size(), GFP_KERNEL);
+	if (!msg) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &netns_nl_family, 0, NETNS_CMD_NOOP);
+	if (!hdr) {
+		ret = -EMSGSIZE;
+		goto err_out;
+	}
+
+	genlmsg_end(msg, hdr);
+
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
+
+err_out:
+	nlmsg_free(msg);
+
+out:
+	return ret;
+}
+
+static int netns_nl_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
+			 int cmd, struct net *net)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, portid, seq, &netns_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, NETNSA_NSINDEX, net->nsindex))
+		goto nla_put_failure;
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int netns_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct sk_buff *msg;
+	int err = -ENOBUFS;
+
+	if (info->attrs[NETNSA_PID])
+		net = get_net_ns_by_pid(nla_get_u32(info->attrs[NETNSA_PID]));
+	else if (info->attrs[NETNSA_FD])
+		net = get_net_ns_by_fd(nla_get_u32(info->attrs[NETNSA_FD]));
+	else
+		get_net(net);
+
+	msg = genlmsg_new(netns_nl_get_size(), GFP_KERNEL);
+	if (!msg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	err = netns_nl_fill(msg, info->snd_portid, info->snd_seq,
+			    NLM_F_ACK, NETNS_CMD_GET, net);
+	if (err < 0)
+		goto err_out;
+
+	err = genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
+	goto out;
+
+err_out:
+	nlmsg_free(msg);
+
+out:
+	put_net(net);
+	return err;
+}
+
+static int netns_nl_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int i = 0, s_i = cb->args[0];
+	struct net *net;
+
+	rtnl_lock();
+	for_each_net(net) {
+		if (i < s_i) {
+			i++;
+			continue;
+		}
+
+		if (netns_nl_fill(skb, NETLINK_CB(cb->skb).portid,
+				  cb->nlh->nlmsg_seq, NLM_F_MULTI,
+				  NETNS_CMD_GET, net) <= 0)
+			goto out;
+
+		i++;
+	}
+
+out:
+	cb->args[0] = i;
+	rtnl_unlock();
+
+	return skb->len;
+}
+
+static struct genl_ops netns_nl_ops[] = {
+	{
+		.cmd = NETNS_CMD_NOOP,
+		.policy = netns_nl_policy,
+		.doit = netns_nl_cmd_noop,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NETNS_CMD_GET,
+		.policy = netns_nl_policy,
+		.doit = netns_nl_cmd_get,
+		.dumpit = netns_nl_cmd_dump,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+int netns_genl_register(void)
+{
+	return genl_register_family_with_ops(&netns_nl_family, netns_nl_ops,
+					     ARRAY_SIZE(netns_nl_ops));
+}
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f2aabb6..6d25ddb 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -963,6 +963,10 @@ static int __init genl_init(void)
 	if (err < 0)
 		goto problem;
 
+	err = netns_genl_register();
+	if (err < 0)
+		goto problem;
+
 	return 0;
 
 problem:
-- 
1.8.0.1
