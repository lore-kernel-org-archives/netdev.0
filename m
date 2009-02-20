From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/3] netns: Remove net_alive
Date: Fri, 20 Feb 2009 08:02:57 -0800
Message-ID: <m1zlghgkpa.fsf_-_@fess.ebiederm.org>
References: <m1ocwxi00a.fsf@fess.ebiederm.org>
	<m1bpsxhzqz.fsf@fess.ebiederm.org>
	<m163j5hzow.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>,
	"Denis V. Lunev" <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45845 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbZBTQCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 11:02:35 -0500
In-Reply-To: <m163j5hzow.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 20 Feb 2009 07\:53\:51 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It turns out that net_alive is unnecessary, and the original problem
that led to it being added was simply that the icmp code thought
it was a network device and wound up being unable to handle packets
while there were still packets in the network namespace.

Now that icmp and tcp have been fixed to properly register themselves
this problem is no longer present and we have a stronger guarantee
that packets will not arrive in a network namespace then that provided
by net_alive in netif_receive_skb.  So remove net_alive allowing
packet reception run a little faster.

Additionally document the strong reason why network namespace cleanup
is safe so that if something happens again someone else will have
a chance of figuring it out.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/net/net_namespace.h |   27 +++++++++++++++++----------
 net/core/dev.c              |    6 ------
 net/core/net_namespace.c    |    3 ---
 3 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 6fc13d9..ded434b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -109,11 +109,6 @@ extern struct list_head net_namespace_list;
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
 
-static inline int net_alive(struct net *net)
-{
-	return net && atomic_read(&net->count);
-}
-
 static inline struct net *get_net(struct net *net)
 {
 	atomic_inc(&net->count);
@@ -145,11 +140,6 @@ int net_eq(const struct net *net1, const struct net *net2)
 }
 #else
 
-static inline int net_alive(struct net *net)
-{
-	return 1;
-}
-
 static inline struct net *get_net(struct net *net)
 {
 	return net;
@@ -234,6 +224,23 @@ struct pernet_operations {
 	void (*exit)(struct net *net);
 };
 
+/*
+ * Use these carefully.  If you implement a network device and it
+ * needs per network namespace operations use device pernet operations,
+ * otherwise use pernet subsys operations.
+ *
+ * This is critically important.  Most of the network code cleanup
+ * runs with the assumption that dev_remove_pack has been called so no
+ * new packets will arrive during and after the cleanup functions have
+ * been called.  dev_remove_pack is not per namespace so instead the
+ * guarantee of no more packets arriving in a network namespace is
+ * provided by ensuring that all network devices and all sockets have
+ * left the network namespace before the cleanup methods are called.
+ *
+ * For the longest time the ipv4 icmp code was registered as a pernet
+ * device which caused kernel oops, and panics during network
+ * namespace cleanup.   So please don't get this wrong.
+ */
 extern int register_pernet_subsys(struct pernet_operations *);
 extern void unregister_pernet_subsys(struct pernet_operations *);
 extern int register_pernet_gen_subsys(int *id, struct pernet_operations *);
diff --git a/net/core/dev.c b/net/core/dev.c
index 5493394..fd1712d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2267,12 +2267,6 @@ int netif_receive_skb(struct sk_buff *skb)
 
 	rcu_read_lock();
 
-	/* Don't receive packets in an exiting network namespace */
-	if (!net_alive(dev_net(skb->dev))) {
-		kfree_skb(skb);
-		goto out;
-	}
-
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 55151fa..516c7b1 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -140,9 +140,6 @@ static void cleanup_net(struct work_struct *work)
 	struct pernet_operations *ops;
 	struct net *net;
 
-	/* Be very certain incoming network packets will not find us */
-	rcu_barrier();
-
 	net = container_of(work, struct net, work);
 
 	mutex_lock(&net_mutex);
-- 
1.6.1.2.350.g88cc

