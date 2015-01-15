From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v5 1/4] netns: add rtnl cmd to add and get peer netns ids
Date: Thu, 15 Jan 2015 15:11:15 +0100
Message-ID: <1421331078-21622-2-git-send-email-nicolas.dichtel@6wind.com>
References: <87wq7g831b.fsf@x220.int.ebiederm.org>
 <1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org, akpm@linux-foundation.org,
	luto@amacapital.net, cwang@twopensource.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49116 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbbAOOLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 09:11:44 -0500
In-Reply-To: <1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, a user can define an id for a peer netns by providing a FD or a
PID. These ids are local to the netns where it is added (ie valid only into this
netns).

The main function (ie the one exported to other module), peernet2id(), allows to
get the id of a peer netns. If no id has been assigned by the user, this
function allocates one.

These ids will be used in netlink messages to point to a peer netns, for example
in case of a x-netns interface.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 MAINTAINERS                        |   1 +
 include/net/net_namespace.h        |   4 +
 include/uapi/linux/Kbuild          |   1 +
 include/uapi/linux/net_namespace.h |  23 ++++
 include/uapi/linux/rtnetlink.h     |   5 +
 net/core/net_namespace.c           | 210 +++++++++++++++++++++++++++++++++++++
 6 files changed, 244 insertions(+)
 create mode 100644 include/uapi/linux/net_namespace.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 9de900572633..9b91d9f0257e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6578,6 +6578,7 @@ F:	include/linux/netdevice.h
 F:	include/uapi/linux/in.h
 F:	include/uapi/linux/net.h
 F:	include/uapi/linux/netdevice.h
+F:	include/uapi/linux/net_namespace.h
 F:	tools/net/
 F:	tools/testing/selftests/net/
 F:	lib/random32.c
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2e8756b8c775..36faf4990c4b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -60,6 +60,7 @@ struct net {
 	struct list_head	exit_list;	/* Use only net_mutex */
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
+	struct idr		netns_ids;
 
 	struct ns_common	ns;
 
@@ -290,6 +291,9 @@ static inline struct net *read_pnet(struct net * const *pnet)
 #define __net_initconst	__initconst
 #endif
 
+int peernet2id(struct net *net, struct net *peer);
+struct net *get_net_ns_by_id(struct net *net, int id);
+
 struct pernet_operations {
 	struct list_head list;
 	int (*init)(struct net *net);
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 00b100023c47..14b7b6e44c77 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -283,6 +283,7 @@ header-y += net.h
 header-y += netlink_diag.h
 header-y += netlink.h
 header-y += netrom.h
+header-y += net_namespace.h
 header-y += net_tstamp.h
 header-y += nfc.h
 header-y += nfs2.h
diff --git a/include/uapi/linux/net_namespace.h b/include/uapi/linux/net_namespace.h
new file mode 100644
index 000000000000..778cd2c3ebf4
--- /dev/null
+++ b/include/uapi/linux/net_namespace.h
@@ -0,0 +1,23 @@
+/* Copyright (c) 2015 6WIND S.A.
+ * Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+#ifndef _UAPI_LINUX_NET_NAMESPACE_H_
+#define _UAPI_LINUX_NET_NAMESPACE_H_
+
+/* Attributes of RTM_NEWNSID/RTM_GETNSID messages */
+enum {
+	NETNSA_NONE,
+#define NETNSA_NSID_NOT_ASSIGNED -1
+	NETNSA_NSID,
+	NETNSA_PID,
+	NETNSA_FD,
+	__NETNSA_MAX,
+};
+
+#define NETNSA_MAX		(__NETNSA_MAX - 1)
+
+#endif /* _UAPI_LINUX_NET_NAMESPACE_H_ */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index a1d18593f41e..5cc5d66bf519 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -132,6 +132,11 @@ enum {
 	RTM_GETMDB = 86,
 #define RTM_GETMDB RTM_GETMDB
 
+	RTM_NEWNSID = 88,
+#define RTM_NEWNSID RTM_NEWNSID
+	RTM_GETNSID = 90,
+#define RTM_GETNSID RTM_GETNSID
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index ce780c722e48..edf089dd792a 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -15,6 +15,10 @@
 #include <linux/file.h>
 #include <linux/export.h>
 #include <linux/user_namespace.h>
+#include <linux/net_namespace.h>
+#include <linux/rtnetlink.h>
+#include <net/sock.h>
+#include <net/netlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -144,6 +148,77 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
+static int alloc_netid(struct net *net, struct net *peer, int reqid)
+{
+	int min = 0, max = 0;
+
+	ASSERT_RTNL();
+
+	if (reqid >= 0) {
+		min = reqid;
+		max = reqid + 1;
+	}
+
+	return idr_alloc(&net->netns_ids, peer, min, max, GFP_KERNEL);
+}
+
+/* This function is used by idr_for_each(). If net is equal to peer, the
+ * function returns the id so that idr_for_each() stops. Because we cannot
+ * returns the id 0 (idr_for_each() will not stop), we return the magic value
+ * NET_ID_ZERO (-1) for it.
+ */
+#define NET_ID_ZERO -1
+static int net_eq_idr(int id, void *net, void *peer)
+{
+	if (net_eq(net, peer))
+		return id ? : NET_ID_ZERO;
+	return 0;
+}
+
+static int __peernet2id(struct net *net, struct net *peer, bool alloc)
+{
+	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
+
+	ASSERT_RTNL();
+
+	/* Magic value for id 0. */
+	if (id == NET_ID_ZERO)
+		return 0;
+	if (id > 0)
+		return id;
+
+	if (alloc)
+		return alloc_netid(net, peer, -1);
+
+	return -ENOENT;
+}
+
+/* This function returns the id of a peer netns. If no id is assigned, one will
+ * be allocated and returned.
+ */
+int peernet2id(struct net *net, struct net *peer)
+{
+	int id = __peernet2id(net, peer, true);
+
+	return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
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
@@ -158,6 +233,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
+	idr_init(&net->netns_ids);
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
@@ -288,6 +364,14 @@ static void cleanup_net(struct work_struct *work)
 	list_for_each_entry(net, &net_kill_list, cleanup_list) {
 		list_del_rcu(&net->list);
 		list_add_tail(&net->exit_list, &net_exit_list);
+		for_each_net(tmp) {
+			int id = __peernet2id(tmp, net, false);
+
+			if (id >= 0)
+				idr_remove(&tmp->netns_ids, id);
+		}
+		idr_destroy(&net->netns_ids);
+
 	}
 	rtnl_unlock();
 
@@ -402,6 +486,129 @@ static struct pernet_operations __net_initdata net_ns_ops = {
 	.exit = net_ns_net_exit,
 };
 
+static struct nla_policy rtnl_net_policy[NETNSA_MAX + 1] = {
+	[NETNSA_NONE]		= { .type = NLA_UNSPEC },
+	[NETNSA_NSID]		= { .type = NLA_S32 },
+	[NETNSA_PID]		= { .type = NLA_U32 },
+	[NETNSA_FD]		= { .type = NLA_U32 },
+};
+
+static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nlattr *tb[NETNSA_MAX + 1];
+	struct net *peer;
+	int nsid, err;
+
+	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
+			  rtnl_net_policy);
+	if (err < 0)
+		return err;
+	if (!tb[NETNSA_NSID])
+		return -EINVAL;
+	nsid = nla_get_s32(tb[NETNSA_NSID]);
+
+	if (tb[NETNSA_PID])
+		peer = get_net_ns_by_pid(nla_get_u32(tb[NETNSA_PID]));
+	else if (tb[NETNSA_FD])
+		peer = get_net_ns_by_fd(nla_get_u32(tb[NETNSA_FD]));
+	else
+		return -EINVAL;
+	if (IS_ERR(peer))
+		return PTR_ERR(peer);
+
+	if (__peernet2id(net, peer, false) >= 0) {
+		err = -EEXIST;
+		goto out;
+	}
+
+	err = alloc_netid(net, peer, nsid);
+	if (err > 0)
+		err = 0;
+out:
+	put_net(peer);
+	return err;
+}
+
+static int rtnl_net_get_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct rtgenmsg))
+	       + nla_total_size(sizeof(s32)) /* NETNSA_NSID */
+	       ;
+}
+
+static int rtnl_net_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
+			 int cmd, struct net *net, struct net *peer)
+{
+	struct nlmsghdr *nlh;
+	struct rtgenmsg *rth;
+	int id;
+
+	ASSERT_RTNL();
+
+	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rth), flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	rth = nlmsg_data(nlh);
+	rth->rtgen_family = AF_UNSPEC;
+
+	id = __peernet2id(net, peer, false);
+	if  (id < 0)
+		id = NETNSA_NSID_NOT_ASSIGNED;
+	if (nla_put_s32(skb, NETNSA_NSID, id))
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
+{
+	struct net *net = sock_net(skb->sk);
+	struct nlattr *tb[NETNSA_MAX + 1];
+	struct sk_buff *msg;
+	int err = -ENOBUFS;
+	struct net *peer;
+
+	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
+			  rtnl_net_policy);
+	if (err < 0)
+		return err;
+	if (tb[NETNSA_PID])
+		peer = get_net_ns_by_pid(nla_get_u32(tb[NETNSA_PID]));
+	else if (tb[NETNSA_FD])
+		peer = get_net_ns_by_fd(nla_get_u32(tb[NETNSA_FD]));
+	else
+		return -EINVAL;
+
+	if (IS_ERR(peer))
+		return PTR_ERR(peer);
+
+	msg = nlmsg_new(rtnl_net_get_size(), GFP_KERNEL);
+	if (!msg) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	err = rtnl_net_fill(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
+			    RTM_GETNSID, net, peer);
+	if (err < 0)
+		goto err_out;
+
+	err = rtnl_unicast(msg, net, NETLINK_CB(skb).portid);
+	goto out;
+
+err_out:
+	nlmsg_free(msg);
+out:
+	put_net(peer);
+	return err;
+}
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
@@ -435,6 +642,9 @@ static int __init net_ns_init(void)
 
 	register_pernet_subsys(&net_ns_ops);
 
+	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, NULL, NULL);
+
 	return 0;
 }
 
-- 
2.2.2
