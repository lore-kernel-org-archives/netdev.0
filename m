From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 1/5] netns: allocate an unique id to identify a netns
Date: Wed, 12 Dec 2012 18:24:37 +0100
Message-ID: <1355333081-4018-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1355333081-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, aatteka@nicira.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39146 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab2LLR0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:26:33 -0500
In-Reply-To: <1355333081-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simply adds a field nsindex, which will contain a unique index.
The goal is to prepare the monitoring of netns activities with rtnelink and to
ease netns management by userland apps.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/net_namespace.h |  1 +
 net/core/net_namespace.c    | 16 ++++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index c5a43f5..5db7a1b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -55,6 +55,7 @@ struct net {
 	struct list_head	exit_list;	/* Use only net_mutex */
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
+	int			nsindex;	/* index to identify this ns */
 
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6456439..f5267e4 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -27,6 +27,7 @@ static DEFINE_MUTEX(net_mutex);
 
 LIST_HEAD(net_namespace_list);
 EXPORT_SYMBOL_GPL(net_namespace_list);
+static DEFINE_IDA(net_namespace_ids);
 
 struct net init_net = {
 	.dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
@@ -157,6 +158,15 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
+again:
+	error = ida_get_new_above(&net_namespace_ids, 1, &net->nsindex);
+	if (error < 0) {
+		if (error == -EAGAIN) {
+			ida_pre_get(&net_namespace_ids, GFP_KERNEL);
+			goto again;
+		}
+		return error;
+	}
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
@@ -171,6 +181,7 @@ out:
 	return error;
 
 out_undo:
+	ida_remove(&net_namespace_ids, net->nsindex);
 	/* Walk through the list backwards calling the exit functions
 	 * for the pernet modules whose init functions did not fail.
 	 */
@@ -297,6 +308,11 @@ static void cleanup_net(struct work_struct *work)
 	 */
 	synchronize_rcu();
 
+	list_for_each_entry(net, &net_exit_list, exit_list) {
+		/* Free the index */
+		ida_remove(&net_namespace_ids, net->nsindex);
+	}
+
 	/* Run all of the network namespace exit methods */
 	list_for_each_entry_reverse(ops, &pernet_list, list)
 		ops_exit_list(ops, &net_exit_list);
-- 
1.8.0.1
