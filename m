From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 1/7] net: Add support for batching network namespace cleanups
Date: Thu,  3 Dec 2009 04:29:03 -0800
Message-ID: <1259843349-3810-1-git-send-email-ebiederm@xmission.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56891 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbZLCM3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:29:18 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

- Add exit_list to struct net to support building lists of network
  namespaces to cleanup.

- Add exit_batch to pernet_operations to allow running operations only
  once during a network namespace exit.  Instead of once per network
  namespace.

- Factor opt ops_exit_list and ops_exit_free so the logic with cleanup
  up a network namespace does not need to be duplicated.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |    2 +
 net/core/net_namespace.c    |  122 +++++++++++++++++++++---------------------
 2 files changed, 63 insertions(+), 61 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 24a8c55..f307e13 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -43,6 +43,7 @@ struct net {
 #endif
 	struct list_head	list;		/* list of network namespaces */
 	struct list_head	cleanup_list;	/* namespaces on death row */
+	struct list_head	exit_list;	/* Use only net_mutex */
 
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
@@ -236,6 +237,7 @@ struct pernet_operations {
 	struct list_head list;
 	int (*init)(struct net *net);
 	void (*exit)(struct net *net);
+	void (*exit_batch)(struct list_head *net_exit_list);
 	int *id;
 	size_t size;
 };
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 9679ad2..6c7f6e0 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -70,6 +70,36 @@ static void ops_free(const struct pernet_operations *ops, struct net *net)
 	}
 }
 
+static void ops_exit_list(const struct pernet_operations *ops,
+			  struct list_head *net_exit_list)
+{
+	struct net *net;
+	if (ops->exit) {
+		list_for_each_entry(net, net_exit_list, exit_list)
+			ops->exit(net);
+	}
+	if (&ops->list == first_device) {
+		LIST_HEAD(dev_kill_list);
+		rtnl_lock();
+		list_for_each_entry(net, net_exit_list, exit_list)
+			unregister_netdevices(net, &dev_kill_list);
+		unregister_netdevice_many(&dev_kill_list);
+		rtnl_unlock();
+	}
+	if (ops->exit_batch)
+		ops->exit_batch(net_exit_list);
+}
+
+static void ops_free_list(const struct pernet_operations *ops,
+			  struct list_head *net_exit_list)
+{
+	struct net *net;
+	if (ops->size && ops->id) {
+		list_for_each_entry(net, net_exit_list, exit_list)
+			ops_free(ops, net);
+	}
+}
+
 /*
  * setup_net runs the initializers for the network namespace object.
  */
@@ -78,6 +108,7 @@ static __net_init int setup_net(struct net *net)
 	/* Must be called with net_mutex held */
 	const struct pernet_operations *ops, *saved_ops;
 	int error = 0;
+	LIST_HEAD(net_exit_list);
 
 	atomic_set(&net->count, 1);
 
@@ -97,21 +128,14 @@ out_undo:
 	/* Walk through the list backwards calling the exit functions
 	 * for the pernet modules whose init functions did not fail.
 	 */
+	list_add(&net->exit_list, &net_exit_list);
 	saved_ops = ops;
-	list_for_each_entry_continue_reverse(ops, &pernet_list, list) {
-		if (ops->exit)
-			ops->exit(net);
-		if (&ops->list == first_device) {
-			LIST_HEAD(dev_kill_list);
-			rtnl_lock();
-			unregister_netdevices(net, &dev_kill_list);
-			unregister_netdevice_many(&dev_kill_list);
-			rtnl_unlock();
-		}
-	}
+	list_for_each_entry_continue_reverse(ops, &pernet_list, list)
+		ops_exit_list(ops, &net_exit_list);
+
 	ops = saved_ops;
 	list_for_each_entry_continue_reverse(ops, &pernet_list, list)
-		ops_free(ops, net);
+		ops_free_list(ops, &net_exit_list);
 
 	rcu_barrier();
 	goto out;
@@ -207,6 +231,7 @@ static void cleanup_net(struct work_struct *work)
 	const struct pernet_operations *ops;
 	struct net *net, *tmp;
 	LIST_HEAD(net_kill_list);
+	LIST_HEAD(net_exit_list);
 
 	/* Atomically snapshot the list of namespaces to cleanup */
 	spin_lock_irq(&cleanup_list_lock);
@@ -217,8 +242,10 @@ static void cleanup_net(struct work_struct *work)
 
 	/* Don't let anyone else find us. */
 	rtnl_lock();
-	list_for_each_entry(net, &net_kill_list, cleanup_list)
+	list_for_each_entry(net, &net_kill_list, cleanup_list) {
 		list_del_rcu(&net->list);
+		list_add_tail(&net->exit_list, &net_exit_list);
+	}
 	rtnl_unlock();
 
 	/*
@@ -229,27 +256,12 @@ static void cleanup_net(struct work_struct *work)
 	synchronize_rcu();
 
 	/* Run all of the network namespace exit methods */
-	list_for_each_entry_reverse(ops, &pernet_list, list) {
-		if (ops->exit) {
-			list_for_each_entry(net, &net_kill_list, cleanup_list)
-				ops->exit(net);
-		}
-		if (&ops->list == first_device) {
-			LIST_HEAD(dev_kill_list);
-			rtnl_lock();
-			list_for_each_entry(net, &net_kill_list, cleanup_list)
-				unregister_netdevices(net, &dev_kill_list);
-			unregister_netdevice_many(&dev_kill_list);
-			rtnl_unlock();
-		}
-	}
+	list_for_each_entry_reverse(ops, &pernet_list, list)
+		ops_exit_list(ops, &net_exit_list);
+
 	/* Free the net generic variables */
-	list_for_each_entry_reverse(ops, &pernet_list, list) {
-		if (ops->size && ops->id) {
-			list_for_each_entry(net, &net_kill_list, cleanup_list)
-				ops_free(ops, net);
-		}
-	}
+	list_for_each_entry_reverse(ops, &pernet_list, list)
+		ops_free_list(ops, &net_exit_list);
 
 	mutex_unlock(&net_mutex);
 
@@ -259,8 +271,8 @@ static void cleanup_net(struct work_struct *work)
 	rcu_barrier();
 
 	/* Finally it is safe to free my network namespace structure */
-	list_for_each_entry_safe(net, tmp, &net_kill_list, cleanup_list) {
-		list_del_init(&net->cleanup_list);
+	list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
+		list_del_init(&net->exit_list);
 		net_free(net);
 	}
 }
@@ -348,8 +360,9 @@ pure_initcall(net_ns_init);
 static int __register_pernet_operations(struct list_head *list,
 					struct pernet_operations *ops)
 {
-	struct net *net, *undo_net;
+	struct net *net;
 	int error;
+	LIST_HEAD(net_exit_list);
 
 	list_add_tail(&ops->list, list);
 	if (ops->init || (ops->id && ops->size)) {
@@ -357,6 +370,7 @@ static int __register_pernet_operations(struct list_head *list,
 			error = ops_init(ops, net);
 			if (error)
 				goto out_undo;
+			list_add_tail(&net->exit_list, &net_exit_list);
 		}
 	}
 	return 0;
@@ -364,36 +378,21 @@ static int __register_pernet_operations(struct list_head *list,
 out_undo:
 	/* If I have an error cleanup all namespaces I initialized */
 	list_del(&ops->list);
-	if (ops->exit) {
-		for_each_net(undo_net) {
-			if (net_eq(undo_net, net))
-				goto undone;
-			ops->exit(undo_net);
-		}
-	}
-undone:
-	if (ops->size && ops->id) {
-		for_each_net(undo_net) {
-			if (net_eq(undo_net, net))
-				goto freed;
-			ops_free(ops, undo_net);
-		}
-	}
-freed:
+	ops_exit_list(ops, &net_exit_list);
+	ops_free_list(ops, &net_exit_list);
 	return error;
 }
 
 static void __unregister_pernet_operations(struct pernet_operations *ops)
 {
 	struct net *net;
+	LIST_HEAD(net_exit_list);
 
 	list_del(&ops->list);
-	if (ops->exit)
-		for_each_net(net)
-			ops->exit(net);
-	if (ops->id && ops->size)
-		for_each_net(net)
-			ops_free(ops, net);
+	for_each_net(net)
+		list_add_tail(&net->exit_list, &net_exit_list);
+	ops_exit_list(ops, &net_exit_list);
+	ops_free_list(ops, &net_exit_list);
 }
 
 #else
@@ -411,9 +410,10 @@ static int __register_pernet_operations(struct list_head *list,
 
 static void __unregister_pernet_operations(struct pernet_operations *ops)
 {
-	if (ops->exit)
-		ops->exit(&init_net);
-	ops_free(ops, &init_net);
+	LIST_HEAD(net_exit_list);
+	list_add(&init_net.exit_list, &net_exit_list);
+	ops_exit_list(ops, &net_exit_list);
+	ops_free_list(ops, &net_exit_list);
 }
 
 #endif /* CONFIG_NET_NS */
-- 
1.6.5.2.143.g8cc62

