From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/2] Add an id to struct net
Date: Thu, 28 Feb 2008 18:49:38 +0300
Message-ID: <47C6D812.9060909@openvz.org>
References: <47C6D743.1050802@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38383 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758995AbYB1Pty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 10:49:54 -0500
In-Reply-To: <47C6D743.1050802@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required to implement the /proc/net symlink, but can later 
be used to enhance networking hash functions - objects like sockets,
fragments, twbuckets, etc should better be stored in different hash
chains when they live in different namespaces.

Id generation is done via ida to handle the id overflowing.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 28738b7..8aedfd6 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -26,6 +26,7 @@ struct net {
 	atomic_t		use_count;	/* To track references we
 						 * destroy on demand
 						 */
+	int			id;
 	struct list_head	list;		/* list of network namespaces */
 	struct work_struct	work;		/* work struct for freeing */
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 7b66083..31b018a 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -6,6 +6,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <net/net_namespace.h>
+#include <linux/idr.h>
 
 /*
  *	Our network namespace constructor/destructor lists
@@ -20,6 +21,8 @@ LIST_HEAD(net_namespace_list);
 struct net init_net;
 EXPORT_SYMBOL(init_net);
 
+static struct ida net_ns_ids;
+
 /*
  * setup_net runs the initializers for the network namespace object.
  */
@@ -31,8 +34,17 @@ static __net_init int setup_net(struct net *net)
 
 	atomic_set(&net->count, 1);
 	atomic_set(&net->use_count, 0);
+retry:
+	error = ida_get_new(&net_ns_ids, &net->id);
+	if (error) {
+		if (error == -EAGAIN) {
+			ida_pre_get(&net_ns_ids, GFP_KERNEL);
+			goto retry;
+		}
+
+		goto out;
+	}
 
-	error = 0;
 	list_for_each_entry(ops, &pernet_list, list) {
 		if (ops->init) {
 			error = ops->init(net);
@@ -53,6 +65,8 @@ out_undo:
 	}
 
 	rcu_barrier();
+
+	ida_remove(&net_ns_ids, net->id);
 	goto out;
 }
 
@@ -142,6 +156,7 @@ static void cleanup_net(struct work_struct *work)
 	 */
 	rcu_barrier();
 
+	ida_remove(&net_ns_ids, net->id);
 	/* Finally it is safe to free my network namespace structure */
 	net_free(net);
 }
@@ -179,6 +194,8 @@ static int __init net_ns_init(void)
 		panic("Could not create netns workq");
 #endif
 
+	ida_init(&net_ns_ids);
+
 	mutex_lock(&net_mutex);
 	err = setup_net(&init_net);
 
