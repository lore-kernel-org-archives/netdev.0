From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] netns: call ops_free right after ops_exit
Date: Sun, 25 Apr 2010 11:26:01 +0200
Message-ID: <20100425092600.GB2866@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367Ab0DYJ0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Apr 2010 05:26:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need to iterate this twice. We can free net generic variables right
after exit is called.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index bd8c471..16217bc 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -82,7 +82,7 @@ static void ops_free_list(const struct pernet_operations *ops,
 static __net_init int setup_net(struct net *net)
 {
 	/* Must be called with net_mutex held */
-	const struct pernet_operations *ops, *saved_ops;
+	const struct pernet_operations *ops;
 	int error = 0;
 	LIST_HEAD(net_exit_list);
 
@@ -105,13 +105,10 @@ out_undo:
 	 * for the pernet modules whose init functions did not fail.
 	 */
 	list_add(&net->exit_list, &net_exit_list);
-	saved_ops = ops;
-	list_for_each_entry_continue_reverse(ops, &pernet_list, list)
+	list_for_each_entry_continue_reverse(ops, &pernet_list, list) {
 		ops_exit_list(ops, &net_exit_list);
-
-	ops = saved_ops;
-	list_for_each_entry_continue_reverse(ops, &pernet_list, list)
 		ops_free_list(ops, &net_exit_list);
+	}
 
 	rcu_barrier();
 	goto out;
@@ -231,13 +228,14 @@ static void cleanup_net(struct work_struct *work)
 	 */
 	synchronize_rcu();
 
-	/* Run all of the network namespace exit methods */
-	list_for_each_entry_reverse(ops, &pernet_list, list)
+	/*
+	 * Run all of the network namespace exit methods and free
+	 * the net generic variables
+	 */
+	list_for_each_entry_reverse(ops, &pernet_list, list) {
 		ops_exit_list(ops, &net_exit_list);
-
-	/* Free the net generic variables */
-	list_for_each_entry_reverse(ops, &pernet_list, list)
 		ops_free_list(ops, &net_exit_list);
+	}
 
 	mutex_unlock(&net_mutex);
 
