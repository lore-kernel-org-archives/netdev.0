From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 2/5] netns: add genl cmd to get the id of a netns
Date: Wed,  2 Jul 2014 13:59:03 +0200
Message-ID: <1404302346-4507-3-git-send-email-nicolas.dichtel@6wind.com>
References: <537327F1.4060603@6wind.com>
 <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53375 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbaGBMIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 08:08:43 -0400
In-Reply-To: <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows a user to get an id of a peer netns. It will be usefull for
userland to be able to associate a netns file descriptor with a netns id.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/net_namespace.h |   1 +
 include/uapi/linux/Kbuild   |   1 +
 include/uapi/linux/netns.h  |  27 ++++++++++++
 net/core/net_namespace.c    | 101 ++++++++++++++++++++++++++++++++++++++++++++
 net/netlink/genetlink.c     |   4 ++
 5 files changed, 134 insertions(+)
 create mode 100644 include/uapi/linux/netns.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 056d6eeee318..3a83b3ec833c 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -293,6 +293,7 @@ static inline struct net *read_pnet(struct net * const *pnet)
 
 int net2id(struct net *net, struct net *peer);
 struct net *get_net_from_netnsid(struct net *net, int id);
+int netns_genl_register(void);
 
 struct pernet_operations {
 	struct list_head list;
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 24e9033f8b3f..5da0eef2771f 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -274,6 +274,7 @@ header-y += netfilter_decnet.h
 header-y += netfilter_ipv4.h
 header-y += netfilter_ipv6.h
 header-y += netlink.h
+header-y += netns.h
 header-y += netrom.h
 header-y += nfc.h
 header-y += nfs.h
diff --git a/include/uapi/linux/netns.h b/include/uapi/linux/netns.h
new file mode 100644
index 000000000000..2d69d183919f
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
+	NETNS_CMD_UNSPEC,
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
index 2976864cef13..20d6213c82bc 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -15,6 +15,8 @@
 #include <linux/file.h>
 #include <linux/export.h>
 #include <linux/user_namespace.h>
+#include <linux/netns.h>
+#include <net/genetlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -438,6 +440,105 @@ static struct pernet_operations __net_initdata net_ns_ops = {
 	.exit = net_ns_net_exit,
 };
 
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
+static int netns_nl_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
+			 int cmd, struct net *net, struct net *peer)
+{
+	void *hdr;
+	int id;
+
+	hdr = genlmsg_put(skb, portid, seq, &netns_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	rtnl_lock();
+	id = net2id(net, peer);
+	rtnl_unlock();
+	if (id < 0)
+		return id;
+	if (nla_put_u32(skb, NETNSA_NSINDEX, id))
+		goto nla_put_failure;
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int netns_nl_cmd_getid(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct net *peer;
+	struct sk_buff *msg;
+	int err = -ENOBUFS;
+
+	if (info->attrs[NETNSA_PID])
+		peer = get_net_ns_by_pid(nla_get_u32(info->attrs[NETNSA_PID]));
+	else if (info->attrs[NETNSA_FD])
+		peer = get_net_ns_by_fd(nla_get_u32(info->attrs[NETNSA_FD]));
+	else
+		return -EINVAL;
+
+	if (IS_ERR(peer))
+		return PTR_ERR(peer);
+
+	msg = genlmsg_new(netns_nl_get_size(), GFP_KERNEL);
+	if (!msg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	err = netns_nl_fill(msg, info->snd_portid, info->snd_seq,
+			    NLM_F_ACK, NETNS_CMD_GETID, net, peer);
+	if (err < 0)
+		goto err_out;
+
+	err = genlmsg_unicast(net, msg, info->snd_portid);
+	goto out;
+
+err_out:
+	nlmsg_free(msg);
+out:
+	put_net(peer);
+	return err;
+}
+
+static struct genl_ops netns_nl_ops[] = {
+	{
+		.cmd = NETNS_CMD_GETID,
+		.policy = netns_nl_policy,
+		.doit = netns_nl_cmd_getid,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+int netns_genl_register(void)
+{
+	return genl_register_family_with_ops(&netns_nl_family, netns_nl_ops);
+}
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 76393f2f4b22..c6f39e40c9f3 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -1029,6 +1029,10 @@ static int __init genl_init(void)
 	if (err)
 		goto problem;
 
+	err = netns_genl_register();
+	if (err < 0)
+		goto problem;
+
 	return 0;
 
 problem:
-- 
1.9.0
