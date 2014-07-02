From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 1/5] netns: allocate netns ids
Date: Wed,  2 Jul 2014 13:59:02 +0200
Message-ID: <1404302346-4507-2-git-send-email-nicolas.dichtel@6wind.com>
References: <537327F1.4060603@6wind.com>
 <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53374 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaGBMIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 08:08:43 -0400
In-Reply-To: <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, netns allocates ids for all netns. Each netns has its own list
of ids, it means that the id is valid only in the current netns.

For homogeneity, an id is also allocated for the netns owner itself.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/net_namespace.h |  5 +++++
 net/core/net_namespace.c    | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 361d26077196..056d6eeee318 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -121,6 +121,8 @@ struct net {
 #endif
 	struct net_generic __rcu	*gen;
 
+	struct idr		netns_ids;
+
 	/* Note : following structs are cache line aligned */
 #ifdef CONFIG_XFRM
 	struct netns_xfrm	xfrm;
@@ -289,6 +291,9 @@ static inline struct net *read_pnet(struct net * const *pnet)
 #define __net_initconst	__initconst
 #endif
 
+int net2id(struct net *net, struct net *peer);
+struct net *get_net_from_netnsid(struct net *net, int id);
+
 struct pernet_operations {
 	struct list_head list;
 	int (*init)(struct net *net);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 85b62691f4f2..2976864cef13 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -144,6 +144,30 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
+static int net_eq_idr(int id, void *net, void *peer)
+{
+	return net_eq(net, peer) ? id : 0;
+}
+
+int net2id(struct net *net, struct net *peer)
+{
+	ASSERT_RTNL();
+	return idr_for_each(&(net)->netns_ids, net_eq_idr, (peer)) ? : -ENOENT;
+}
+
+struct net *get_net_from_netnsid(struct net *net, int id)
+{
+	struct net *peer;
+
+	rcu_read_lock();
+	peer = idr_find(&(net)->netns_ids, id);
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
@@ -158,6 +182,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	atomic_set(&net->passive, 1);
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
+	idr_init(&net->netns_ids);
 
 #ifdef NETNS_REFCNT_DEBUG
 	atomic_set(&net->use_count, 0);
@@ -253,7 +278,20 @@ struct net *copy_net_ns(unsigned long flags,
 	mutex_lock(&net_mutex);
 	rv = setup_net(net, user_ns);
 	if (rv == 0) {
+		struct net *tmp;
+
 		rtnl_lock();
+		idr_alloc_cyclic(&net->netns_ids, net, 1, 0, GFP_KERNEL);
+		for_each_net(tmp) {
+			/* Even if it fails, let's try to get ids for other
+			 * netns.
+			 */
+			idr_alloc_cyclic(&net->netns_ids, tmp, 1, 0,
+					 GFP_KERNEL);
+			idr_alloc_cyclic(&tmp->netns_ids, net, 1, 0,
+					 GFP_KERNEL);
+		}
+
 		list_add_tail_rcu(&net->list, &net_namespace_list);
 		rtnl_unlock();
 	}
@@ -288,6 +326,9 @@ static void cleanup_net(struct work_struct *work)
 	list_for_each_entry(net, &net_kill_list, cleanup_list) {
 		list_del_rcu(&net->list);
 		list_add_tail(&net->exit_list, &net_exit_list);
+		for_each_net(tmp)
+			idr_remove(&tmp->netns_ids, net2id(tmp, net));
+		idr_destroy(&net->netns_ids);
 	}
 	rtnl_unlock();
 
@@ -423,6 +464,7 @@ static int __init net_ns_init(void)
 		panic("Could not setup the initial network namespace");
 
 	rtnl_lock();
+	idr_alloc_cyclic(&init_net.netns_ids, &init_net, 1, 0, GFP_KERNEL);
 	list_add_tail_rcu(&init_net.list, &net_namespace_list);
 	rtnl_unlock();
 
-- 
1.9.0
