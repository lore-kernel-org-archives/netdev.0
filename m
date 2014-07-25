From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 2/8] userns: make each net (net_ns) belong to a user_ns
Date: Fri, 25 Jul 2014 16:22:23 +0800
Message-ID: <1406276549-6616-3-git-send-email-wangyufen@huawei.com>
References: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:38721 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177AbaGYI2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:28:43 -0400
In-Reply-To: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

The user namespace which creates a new network namespace owns that
namespace and all resources created in it.  This way we can target
capability checks for privileged operations against network resources to
the user_ns which created the network namespace in which the resource
lives.  Privilege to the user namespace which owns the network
namespace, or any parent user namespace thereof, provides the same
privilege to the network resource.

This patch is reworked from a version originally by
Serge E. Hallyn <serge.hallyn@canonical.com>

Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 include/net/net_namespace.h |  9 +++++++--
 kernel/nsproxy.c            |  2 +-
 net/core/net_namespace.c    | 15 +++++++++++----
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index ee547c1..9594ef9 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -22,6 +22,7 @@
 #endif
 #include <net/netns/xfrm.h>
 
+struct user_namespace;
 struct proc_dir_entry;
 struct net_device;
 struct sock;
@@ -52,6 +53,8 @@ struct net {
 	struct list_head	cleanup_list;	/* namespaces on death row */
 	struct list_head	exit_list;	/* Use only net_mutex */
 
+	struct user_namespace   *user_ns;       /* Owning user namespace */
+
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
 
@@ -110,10 +113,12 @@ struct net {
 extern struct net init_net;
 
 #ifdef CONFIG_NET
-extern struct net *copy_net_ns(unsigned long flags, struct net *net_ns);
+extern struct net *copy_net_ns(unsigned long flags,
+			       struct user_namespace *user_ns, struct net *old_net);
 
 #else /* CONFIG_NET */
-static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
+static inline struct net *copy_net_ns(unsigned long flags,
+				      struct user_namespace *user_ns, struct net *old_net)
 {
 	/* There is nothing to copy so this is a noop */
 	return net_ns;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b576f7f..7e1c3de 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -90,7 +90,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_pid;
 	}
 
-	new_nsp->net_ns = copy_net_ns(flags, tsk->nsproxy->net_ns);
+	new_nsp->net_ns = copy_net_ns(flags, task_cred_xxx(tsk, user_ns), tsk->nsproxy->net_ns);
 	if (IS_ERR(new_nsp->net_ns)) {
 		err = PTR_ERR(new_nsp->net_ns);
 		goto out_net;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index dd00b71..31cc840 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -11,6 +11,7 @@
 #include <linux/proc_fs.h>
 #include <linux/file.h>
 #include <linux/export.h>
+#include <linux/user_namespace.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -143,7 +144,7 @@ static void ops_free_list(const struct pernet_operations *ops,
 /*
  * setup_net runs the initializers for the network namespace object.
  */
-static __net_init int setup_net(struct net *net)
+static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 {
 	/* Must be called with net_mutex held */
 	const struct pernet_operations *ops, *saved_ops;
@@ -153,6 +154,7 @@ static __net_init int setup_net(struct net *net)
 	atomic_set(&net->count, 1);
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
+	net->user_ns = user_ns;
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
@@ -230,7 +232,8 @@ void net_drop_ns(void *p)
 		net_free(ns);
 }
 
-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
+struct net *copy_net_ns(unsigned long flags,
+			struct user_namespace *user_ns, struct net *old_net)
 {
 	struct net *net;
 	int rv;
@@ -241,8 +244,11 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 	net = net_alloc();
 	if (!net)
 		return ERR_PTR(-ENOMEM);
+
+	get_user_ns(user_ns);
+
 	mutex_lock(&net_mutex);
-	rv = setup_net(net);
+	rv = setup_net(net, user_ns);
 	if (rv == 0) {
 		rtnl_lock();
 		list_add_tail_rcu(&net->list, &net_namespace_list);
@@ -250,6 +256,7 @@ struct net *copy_net_ns(unsigned long flags, struct net *old_net)
 	}
 	mutex_unlock(&net_mutex);
 	if (rv < 0) {
+		put_user_ns(user_ns);
 		net_drop_ns(net);
 		return ERR_PTR(rv);
 	}
@@ -400,7 +407,7 @@ static int __init net_ns_init(void)
 	rcu_assign_pointer(init_net.gen, ng);
 
 	mutex_lock(&net_mutex);
-	if (setup_net(&init_net))
+	if (setup_net(&init_net, &init_user_ns))
 		panic("Could not setup the initial network namespace");
 
 	rtnl_lock();
-- 
1.8.0
