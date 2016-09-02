From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Thu,  1 Sep 2016 21:53:45 -0700
Message-ID: <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33584 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbcIBEyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 00:54:54 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so5065233pac.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 21:53:57 -0700 (PDT)
In-Reply-To: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We never read or change netns id in hardirq context,
the only place we read netns id in softirq context
is in vxlan_xmit(). So, it should be enough to just
disable BH.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/net_namespace.c | 35 +++++++++++++++--------------------
 1 file changed, 15 insertions(+), 20 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index f3fa435..42bdda0 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -215,14 +215,13 @@ static void rtnl_net_notifyid(struct net *net, int cmd, int id);
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
@@ -231,12 +230,11 @@ int peernet2id_alloc(struct net *net, struct net *peer)
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
 EXPORT_SYMBOL(peernet2id);
@@ -251,18 +249,17 @@ bool peernet_has_id(struct net *net, struct net *peer)
 
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
@@ -406,17 +403,17 @@ static void cleanup_net(struct work_struct *work)
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
@@ -544,7 +541,6 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
-	unsigned long flags;
 	struct net *peer;
 	int nsid, err;
 
@@ -565,15 +561,15 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
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
@@ -695,11 +691,10 @@ static int rtnl_net_dumpid(struct sk_buff *skb, struct netlink_callback *cb)
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
-- 
2.1.0
