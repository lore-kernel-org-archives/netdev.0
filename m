From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netns: avoid disabling irq for netns id
Date: Tue, 29 Nov 2016 17:11:29 -0500
Message-ID: <148045748887.22539.3188295553967836703.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55628 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755714AbcK2WLb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 17:11:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>

Bring back commit bc51dddf98c9 ("netns: avoid disabling irq for netns
id") now that we've fixed some audit multicast issues that caused
problems with original attempt.  Additional information, and history,
can be found in the links below:

 * https://github.com/linux-audit/audit-kernel/issues/22
 * https://github.com/linux-audit/audit-kernel/issues/23

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 net/core/net_namespace.c |   35 +++++++++++++++--------------------
 1 file changed, 15 insertions(+), 20 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b..10608dd 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -213,14 +213,13 @@ static void rtnl_net_notifyid(struct net *net, int cmd, int id);
  */
 int peernet2id_alloc(struct net *net, struct net *peer)
 {
-	unsigned long flags;
 	bool alloc;
 	int id;
 
-	spin_lock_irqsave(&net->nsid_lock, flags);
+	spin_lock_bh(&net->nsid_lock);
 	alloc = atomic_read(&peer->count) == 0 ? false : true;
 	id = __peernet2id_alloc(net, peer, &alloc);
-	spin_unlock_irqrestore(&net->nsid_lock, flags);
+	spin_unlock_bh(&net->nsid_lock);
 	if (alloc && id >= 0)
 		rtnl_net_notifyid(net, RTM_NEWNSID, id);
 	return id;
@@ -230,12 +229,11 @@ EXPORT_SYMBOL(peernet2id_alloc);
 /* This function returns, if assigned, the id of a peer netns. */
 int peernet2id(struct net *net, struct net *peer)
 {
-	unsigned long flags;
 	int id;
 
-	spin_lock_irqsave(&net->nsid_lock, flags);
+	spin_lock_bh(&net->nsid_lock);
 	id = __peernet2id(net, peer);
-	spin_unlock_irqrestore(&net->nsid_lock, flags);
+	spin_unlock_bh(&net->nsid_lock);
 	return id;
 }
 
@@ -249,18 +247,17 @@ bool peernet_has_id(struct net *net, struct net *peer)
 
 struct net *get_net_ns_by_id(struct net *net, int id)
 {
-	unsigned long flags;
 	struct net *peer;
 
 	if (id < 0)
 		return NULL;
 
 	rcu_read_lock();
-	spin_lock_irqsave(&net->nsid_lock, flags);
+	spin_lock_bh(&net->nsid_lock);
 	peer = idr_find(&net->netns_ids, id);
 	if (peer)
 		get_net(peer);
-	spin_unlock_irqrestore(&net->nsid_lock, flags);
+	spin_unlock_bh(&net->nsid_lock);
 	rcu_read_unlock();
 
 	return peer;
@@ -404,17 +401,17 @@ static void cleanup_net(struct work_struct *work)
 		for_each_net(tmp) {
 			int id;
 
-			spin_lock_irq(&tmp->nsid_lock);
+			spin_lock_bh(&tmp->nsid_lock);
 			id = __peernet2id(tmp, net);
 			if (id >= 0)
 				idr_remove(&tmp->netns_ids, id);
-			spin_unlock_irq(&tmp->nsid_lock);
+			spin_unlock_bh(&tmp->nsid_lock);
 			if (id >= 0)
 				rtnl_net_notifyid(tmp, RTM_DELNSID, id);
 		}
-		spin_lock_irq(&net->nsid_lock);
+		spin_lock_bh(&net->nsid_lock);
 		idr_destroy(&net->netns_ids);
-		spin_unlock_irq(&net->nsid_lock);
+		spin_unlock_bh(&net->nsid_lock);
 
 	}
 	rtnl_unlock();
@@ -542,7 +539,6 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
-	unsigned long flags;
 	struct net *peer;
 	int nsid, err;
 
@@ -563,15 +559,15 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (IS_ERR(peer))
 		return PTR_ERR(peer);
 
-	spin_lock_irqsave(&net->nsid_lock, flags);
+	spin_lock_bh(&net->nsid_lock);
 	if (__peernet2id(net, peer) >= 0) {
-		spin_unlock_irqrestore(&net->nsid_lock, flags);
+		spin_unlock_bh(&net->nsid_lock);
 		err = -EEXIST;
 		goto out;
 	}
 
 	err = alloc_netid(net, peer, nsid);
-	spin_unlock_irqrestore(&net->nsid_lock, flags);
+	spin_unlock_bh(&net->nsid_lock);
 	if (err >= 0) {
 		rtnl_net_notifyid(net, RTM_NEWNSID, err);
 		err = 0;
@@ -693,11 +689,10 @@ static int rtnl_net_dumpid(struct sk_buff *skb, struct netlink_callback *cb)
 		.idx = 0,
 		.s_idx = cb->args[0],
 	};
-	unsigned long flags;
 
-	spin_lock_irqsave(&net->nsid_lock, flags);
+	spin_lock_bh(&net->nsid_lock);
 	idr_for_each(&net->netns_ids, rtnl_net_dumpid_one, &net_cb);
-	spin_unlock_irqrestore(&net->nsid_lock, flags);
+	spin_unlock_bh(&net->nsid_lock);
 
 	cb->args[0] = net_cb.idx;
 	return skb->len;
