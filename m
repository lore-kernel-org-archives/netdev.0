From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v4 1/4] netns: add genl cmd to add and get peer netns ids
Date: Thu, 30 Oct 2014 16:25:25 +0100
Message-ID: <1414682728-4532-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>
 <1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org, akpm@linux-foundation.org,
	luto@amacapital.net, cwang@twopensource.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54241 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760211AbaJ3P1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 11:27:25 -0400
In-Reply-To: <1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, a user can define an id for a peer netns by providing a FD or a
PID. These ids are local to netns (ie valid only into one netns).

This will be useful for netlink messages when a x-netns interface is dumped.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 MAINTAINERS                 |   1 +
 include/net/net_namespace.h |   5 ++
 include/uapi/linux/Kbuild   |   1 +
 include/uapi/linux/netns.h  |  38 +++++++++
 net/core/net_namespace.c    | 195 ++++++++++++++++++++++++++++++++++++++++++++
 net/netlink/genetlink.c     |   4 +
 6 files changed, 244 insertions(+)
 create mode 100644 include/uapi/linux/netns.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 43898b1a8a2d..de7e6fcbd5c2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6382,6 +6382,7 @@ F:	include/linux/netdevice.h
 F:	include/uapi/linux/in.h
 F:	include/uapi/linux/net.h
 F:	include/uapi/linux/netdevice.h
+F:	include/uapi/linux/netns.h
 F:	tools/net/
 F:	tools/testing/selftests/net/
 F:	lib/random32.c
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index e0d64667a4b3..0f1367a71b81 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -59,6 +59,7 @@ struct net {
 	struct list_head	exit_list;	/* Use only net_mutex */
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
+	struct idr		netns_ids;
 
 	unsigned int		proc_inum;
 
@@ -289,6 +290,10 @@ static inline struct net *read_pnet(struct net * const *pnet)
 #define __net_initconst	__initconst
 #endif
 
+int peernet2id(struct net *net, struct net *peer);
+struct net *get_net_ns_by_id(struct net *net, int id);
+int netns_genl_register(void);
+
 struct pernet_operations {
 	struct list_head list;
 	int (*init)(struct net *net);
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 6cad97485bad..d7f49c69585a 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -277,6 +277,7 @@ header-y += netfilter_decnet.h
 header-y += netfilter_ipv4.h
 header-y += netfilter_ipv6.h
 header-y += netlink.h
+header-y += netns.h
 header-y += netrom.h
 header-y += nfc.h
 header-y += nfs.h
diff --git a/include/uapi/linux/netns.h b/include/uapi/linux/netns.h
new file mode 100644
index 000000000000..2edf129377de
--- /dev/null
+++ b/include/uapi/linux/netns.h
@@ -0,0 +1,38 @@
+/* Copyright (c) 2014 6WIND S.A.
+ * Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
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
+	NETNS_CMD_NEWID,
+	NETNS_CMD_GETID,
+	__NETNS_CMD_MAX,
+};
+
+#define NETNS_CMD_MAX		(__NETNS_CMD_MAX - 1)
+
+/* Attributes */
+enum {
+	NETNSA_NONE,
+#define NETNSA_NSINDEX_UNKNOWN	-1
+	NETNSA_NSID,
+	NETNSA_PID,
+	NETNSA_FD,
+	__NETNSA_MAX,
+};
+
+#define NETNSA_MAX		(__NETNSA_MAX - 1)
+
+#endif /* _UAPI_LINUX_NETNS_H_ */
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 7f155175bba8..4a5680ed42fb 100644
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
 
@@ -144,6 +146,50 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
+/* This function is used by idr_for_each(). If net is equal to peer, the
+ * function returns the id so that idr_for_each() stops. Because we cannot
+ * returns the id 0 (idr_for_each() will not stop), we return the magic value
+ * -1 for it.
+ */
+static int net_eq_idr(int id, void *net, void *peer)
+{
+	if (net_eq(net, peer))
+		return id ? : -1;
+	return 0;
+}
+
+/* returns NETNSA_NSINDEX_UNKNOWN if not found */
+int peernet2id(struct net *net, struct net *peer)
+{
+	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
+
+	ASSERT_RTNL();
+
+	/* Magic value for id 0. */
+	if (id == -1)
+		return 0;
+	if (id == 0)
+		return NETNSA_NSINDEX_UNKNOWN;
+
+	return id;
+}
+
+struct net *get_net_ns_by_id(struct net *net, int id)
+{
+	struct net *peer;
+
+	if (id < 0)
+		return NULL;
+
+	rcu_read_lock();
+	peer = idr_find(&net->netns_ids, id);
+	if (peer)
+		get_net(peer);
+	rcu_read_unlock();
+
+	return peer;
+}
+
 /*
  * setup_net runs the initializers for the network namespace object.
  */
@@ -158,6 +204,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
+	idr_init(&net->netns_ids);
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
@@ -288,6 +335,14 @@ static void cleanup_net(struct work_struct *work)
 	list_for_each_entry(net, &net_kill_list, cleanup_list) {
 		list_del_rcu(&net->list);
 		list_add_tail(&net->exit_list, &net_exit_list);
+		for_each_net(tmp) {
+			int id = peernet2id(tmp, net);
+
+			if (id >= 0)
+				idr_remove(&tmp->netns_ids, id);
+		}
+		idr_destroy(&net->netns_ids);
+
 	}
 	rtnl_unlock();
 
@@ -399,6 +454,146 @@ static struct pernet_operations __net_initdata net_ns_ops = {
 	.exit = net_ns_net_exit,
 };
 
+static struct genl_family netns_genl_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= NETNS_GENL_NAME,
+	.version	= NETNS_GENL_VERSION,
+	.hdrsize	= 0,
+	.maxattr	= NETNSA_MAX,
+	.netnsok	= true,
+};
+
+static struct nla_policy netns_nl_policy[NETNSA_MAX + 1] = {
+	[NETNSA_NONE]		= { .type = NLA_UNSPEC },
+	[NETNSA_NSID]		= { .type = NLA_S32 },
+	[NETNSA_PID]		= { .type = NLA_U32 },
+	[NETNSA_FD]		= { .type = NLA_U32 },
+};
+
+static int netns_nl_cmd_newid(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	struct net *peer;
+	int nsid, err;
+
+	if (!info->attrs[NETNSA_NSID])
+		return -EINVAL;
+	nsid = nla_get_s32(info->attrs[NETNSA_NSID]);
+	if (nsid < 0)
+		return -EINVAL;
+
+	if (info->attrs[NETNSA_PID])
+		peer = get_net_ns_by_pid(nla_get_u32(info->attrs[NETNSA_PID]));
+	else if (info->attrs[NETNSA_FD])
+		peer = get_net_ns_by_fd(nla_get_u32(info->attrs[NETNSA_FD]));
+	else
+		return -EINVAL;
+	if (IS_ERR(peer))
+		return PTR_ERR(peer);
+
+	rtnl_lock();
+	if (peernet2id(net, peer) >= 0) {
+		err = -EEXIST;
+		goto out;
+	}
+
+	err = idr_alloc(&net->netns_ids, peer, nsid, nsid + 1, GFP_KERNEL);
+	if (err >= 0)
+		err = 0;
+out:
+	rtnl_unlock();
+	put_net(peer);
+	return err;
+}
+
+static int netns_nl_get_size(void)
+{
+	return nla_total_size(sizeof(s32)) /* NETNSA_NSID */
+	       ;
+}
+
+static int netns_nl_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
+			 int cmd, struct net *net, struct net *peer)
+{
+	void *hdr;
+	int id;
+
+	hdr = genlmsg_put(skb, portid, seq, &netns_genl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	rtnl_lock();
+	id = peernet2id(net, peer);
+	rtnl_unlock();
+	if (nla_put_s32(skb, NETNSA_NSID, id))
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
+	struct sk_buff *msg;
+	int err = -ENOBUFS;
+	struct net *peer;
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
+static struct genl_ops netns_genl_ops[] = {
+	{
+		.cmd = NETNS_CMD_NEWID,
+		.policy = netns_nl_policy,
+		.doit = netns_nl_cmd_newid,
+		.flags = GENL_ADMIN_PERM,
+	},
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
+	return genl_register_family_with_ops(&netns_genl_family,
+					     netns_genl_ops);
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
2.1.0
