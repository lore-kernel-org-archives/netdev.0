From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 03/27] afnetns: prepare for integration into ipv4
Date: Mon, 13 Mar 2017 00:01:27 +0100
Message-ID: <20170312230151.5185-4-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47678 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935572AbdCLXB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:57 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id C4A7F20749
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:55 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 36480240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:55 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each IPv4 address has an associated afnet namespace, so it is only going
to be used by applications in the same afnet namespace.

One can open a file descriptor and pass it to the newaddr rtnetlink
functions to put an IP address into a specific afnet namespace.

Dumping the addresses also returns the appropriate afnetns inode number,
so a match with the appropriate afnet namespace can be done in user space.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/inetdevice.h   |  3 +++
 include/net/afnetns.h        |  2 ++
 include/uapi/linux/if_addr.h |  2 ++
 net/core/afnetns.c           | 26 ++++++++++++++++++++++++++
 net/ipv4/devinet.c           | 39 ++++++++++++++++++++++++++++++++++++++-
 5 files changed, 71 insertions(+), 1 deletion(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ee971f335a8b65..d5ac959e90baa1 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -141,6 +141,9 @@ struct in_ifaddr {
 	unsigned char		ifa_scope;
 	unsigned char		ifa_prefixlen;
 	__u32			ifa_flags;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct afnetns		*afnetns;
+#endif
 	char			ifa_label[IFNAMSIZ];
 
 	/* In seconds, relative to tstamp. Expiry is at tstamp + HZ * lft. */
diff --git a/include/net/afnetns.h b/include/net/afnetns.h
index d5fbb83023acd6..9039086717c356 100644
--- a/include/net/afnetns.h
+++ b/include/net/afnetns.h
@@ -19,6 +19,8 @@ int afnet_ns_init(void);
 
 struct afnetns *afnetns_new(struct net *net);
 struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old);
+struct afnetns *afnetns_get_by_fd(int fd);
+unsigned int afnetns_to_inode(struct afnetns *afnetns);
 void afnetns_free(struct afnetns *afnetns);
 
 static inline struct afnetns *afnetns_get(struct afnetns *afnetns)
diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index 4318ab1635cedf..c67703808584eb 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -32,6 +32,8 @@ enum {
 	IFA_CACHEINFO,
 	IFA_MULTICAST,
 	IFA_FLAGS,
+	IFA_AFNETNS_FD,
+	IFA_AFNETNS_INODE,
 	__IFA_MAX,
 };
 
diff --git a/net/core/afnetns.c b/net/core/afnetns.c
index 997623e4dc5078..12b823ae780796 100644
--- a/net/core/afnetns.c
+++ b/net/core/afnetns.c
@@ -2,6 +2,7 @@
 #include <net/net_namespace.h>
 #include <linux/sched.h>
 #include <linux/sched/task.h>
+#include <linux/file.h>
 #include <linux/nsproxy.h>
 #include <linux/proc_ns.h>
 
@@ -56,6 +57,31 @@ void afnetns_free(struct afnetns *afnetns)
 	kfree(afnetns);
 }
 
+struct afnetns *afnetns_get_by_fd(int fd)
+{
+	struct file *file;
+	struct ns_common *ns;
+	struct afnetns *afnetns;
+
+	file = proc_ns_fget(fd);
+	if (IS_ERR(file))
+		return ERR_CAST(file);
+
+	ns = get_proc_ns(file_inode(file));
+	if (ns->ops == &afnetns_operations)
+		afnetns = afnetns_get(ns_to_afnet(ns));
+	else
+		afnetns = ERR_PTR(-EINVAL);
+
+	fput(file);
+	return afnetns;
+}
+
+unsigned int afnetns_to_inode(struct afnetns *afnetns)
+{
+	return afnetns->ns.inum;
+}
+
 struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old)
 {
 	if (flags & CLONE_NEWNET)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cebedd545e5e28..d4a38b6e9adb79 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -99,6 +99,7 @@ static const struct nla_policy ifa_ipv4_policy[IFA_MAX+1] = {
 	[IFA_LABEL]     	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 	[IFA_CACHEINFO]		= { .len = sizeof(struct ifa_cacheinfo) },
 	[IFA_FLAGS]		= { .type = NLA_U32 },
+	[IFA_AFNETNS_FD]	= { .type = NLA_S32 },
 };
 
 #define IN4_ADDR_HSIZE_SHIFT	8
@@ -203,6 +204,9 @@ static void inet_rcu_free_ifa(struct rcu_head *head)
 	struct in_ifaddr *ifa = container_of(head, struct in_ifaddr, rcu_head);
 	if (ifa->ifa_dev)
 		in_dev_put(ifa->ifa_dev);
+#if IS_ENABLED(CONFIG_AFNETNS)
+	afnetns_put(ifa->afnetns);
+#endif
 	kfree(ifa);
 }
 
@@ -805,6 +809,26 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 	else
 		memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (tb[IFA_AFNETNS_FD]) {
+		int fd = nla_get_s32(tb[IFA_AFNETNS_FD]);
+
+		ifa->afnetns = afnetns_get_by_fd(fd);
+		if (IS_ERR(ifa->afnetns)) {
+			err = PTR_ERR(ifa->afnetns);
+			ifa->afnetns = afnetns_get(net->afnet_ns);
+			goto errout_free;
+		}
+	} else {
+		ifa->afnetns = afnetns_get(net->afnet_ns);
+	}
+#else
+	if (tb[IFA_AFNETNS_FD]) {
+		err = -EOPNOTSUPP;
+		goto errout_free;
+	}
+#endif
+
 	if (tb[IFA_CACHEINFO]) {
 		struct ifa_cacheinfo *ci;
 
@@ -1089,6 +1113,9 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			ifa->ifa_mask = inet_make_mask(32);
 		}
 		set_ifa_lifetime(ifa, INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+#if IS_ENABLED(CONFIG_AFNETNS)
+		ifa->afnetns = afnetns_get(net->afnet_ns);
+#endif
 		ret = inet_set_ifa(dev, ifa);
 		break;
 
@@ -1444,6 +1471,9 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 				in_dev_hold(in_dev);
 				ifa->ifa_dev = in_dev;
 				ifa->ifa_scope = RT_SCOPE_HOST;
+#if IS_ENABLED(CONFIG_AFNETNS)
+				ifa->afnetns = afnetns_get(dev_net(dev)->afnet_ns);
+#endif
 				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 				set_ifa_lifetime(ifa, INFINITY_LIFE_TIME,
 						 INFINITY_LIFE_TIME);
@@ -1504,7 +1534,8 @@ static size_t inet_nlmsg_size(void)
 	       + nla_total_size(4) /* IFA_BROADCAST */
 	       + nla_total_size(IFNAMSIZ) /* IFA_LABEL */
 	       + nla_total_size(4)  /* IFA_FLAGS */
-	       + nla_total_size(sizeof(struct ifa_cacheinfo)); /* IFA_CACHEINFO */
+	       + nla_total_size(sizeof(struct ifa_cacheinfo)) /* IFA_CACHEINFO */
+	       + nla_total_size(4); /* IFA_AFNETNS_INODE */
 }
 
 static inline u32 cstamp_delta(unsigned long cstamp)
@@ -1577,6 +1608,12 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 			  preferred, valid))
 		goto nla_put_failure;
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (nla_put_u32(skb, IFA_AFNETNS_INODE,
+			afnetns_to_inode(ifa->afnetns)))
+		goto nla_put_failure;
+#endif
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
-- 
2.9.3
