From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] netns: make nsid_lock per net
Date: Fri, 15 May 2015 14:47:32 -0700
Message-ID: <1431726452-13111-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33089 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934172AbbEOVrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:47:39 -0400
Received: by pdbqa5 with SMTP id qa5so29326427pdb.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 14:47:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The spinlock is used to protect netns_ids which is per net,
so there is no need to use a global spinlock.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/net_namespace.h |  1 +
 net/core/net_namespace.c    | 32 ++++++++++++++++----------------
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3f850ac..72eb237 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -58,6 +58,7 @@ struct net {
 	struct list_head	exit_list;	/* Use only net_mutex */
 
 	struct user_namespace   *user_ns;	/* Owning user namespace */
+	spinlock_t		nsid_lock;
 	struct idr		netns_ids;
 
 	struct ns_common	ns;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index d2f42da..2c2eb1b 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -28,7 +28,6 @@
 static LIST_HEAD(pernet_list);
 static struct list_head *first_device = &pernet_list;
 DEFINE_MUTEX(net_mutex);
-static DEFINE_SPINLOCK(nsid_lock);
 
 LIST_HEAD(net_namespace_list);
 EXPORT_SYMBOL_GPL(net_namespace_list);
@@ -218,10 +217,10 @@ int peernet2id_alloc(struct net *net, struct net *peer)
 	bool alloc;
 	int id;
 
-	spin_lock_irqsave(&nsid_lock, flags);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	alloc = atomic_read(&peer->count) == 0 ? false : true;
 	id = __peernet2id_alloc(net, peer, &alloc);
-	spin_unlock_irqrestore(&nsid_lock, flags);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	if (alloc && id >= 0)
 		rtnl_net_notifyid(net, RTM_NEWNSID, id);
 	return id;
@@ -234,9 +233,9 @@ int peernet2id(struct net *net, struct net *peer)
 	unsigned long flags;
 	int id;
 
-	spin_lock_irqsave(&nsid_lock, flags);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	id = __peernet2id(net, peer);
-	spin_unlock_irqrestore(&nsid_lock, flags);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	return id;
 }
 
@@ -257,11 +256,11 @@ struct net *get_net_ns_by_id(struct net *net, int id)
 		return NULL;
 
 	rcu_read_lock();
-	spin_lock_irqsave(&nsid_lock, flags);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	peer = idr_find(&net->netns_ids, id);
 	if (peer)
 		get_net(peer);
-	spin_unlock_irqrestore(&nsid_lock, flags);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	rcu_read_unlock();
 
 	return peer;
@@ -282,6 +281,7 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	net->dev_base_seq = 1;
 	net->user_ns = user_ns;
 	idr_init(&net->netns_ids);
+	spin_lock_init(&net->nsid_lock);
 
 	list_for_each_entry(ops, &pernet_list, list) {
 		error = ops_init(ops, net);
@@ -404,17 +404,17 @@ static void cleanup_net(struct work_struct *work)
 		for_each_net(tmp) {
 			int id;
 
-			spin_lock_irq(&nsid_lock);
+			spin_lock_irq(&tmp->nsid_lock);
 			id = __peernet2id(tmp, net);
 			if (id >= 0)
 				idr_remove(&tmp->netns_ids, id);
-			spin_unlock_irq(&nsid_lock);
+			spin_unlock_irq(&tmp->nsid_lock);
 			if (id >= 0)
 				rtnl_net_notifyid(tmp, RTM_DELNSID, id);
 		}
-		spin_lock_irq(&nsid_lock);
+		spin_lock_irq(&net->nsid_lock);
 		idr_destroy(&net->netns_ids);
-		spin_unlock_irq(&nsid_lock);
+		spin_unlock_irq(&net->nsid_lock);
 
 	}
 	rtnl_unlock();
@@ -563,15 +563,15 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (IS_ERR(peer))
 		return PTR_ERR(peer);
 
-	spin_lock_irqsave(&nsid_lock, flags);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	if (__peernet2id(net, peer) >= 0) {
-		spin_unlock_irqrestore(&nsid_lock, flags);
+		spin_unlock_irqrestore(&net->nsid_lock, flags);
 		err = -EEXIST;
 		goto out;
 	}
 
 	err = alloc_netid(net, peer, nsid);
-	spin_unlock_irqrestore(&nsid_lock, flags);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	if (err >= 0) {
 		rtnl_net_notifyid(net, RTM_NEWNSID, err);
 		err = 0;
@@ -695,9 +695,9 @@ static int rtnl_net_dumpid(struct sk_buff *skb, struct netlink_callback *cb)
 	};
 	unsigned long flags;
 
-	spin_lock_irqsave(&nsid_lock, flags);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	idr_for_each(&net->netns_ids, rtnl_net_dumpid_one, &net_cb);
-	spin_unlock_irqrestore(&nsid_lock, flags);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 
 	cb->args[0] = net_cb.idx;
 	return skb->len;
-- 
1.8.3.1
