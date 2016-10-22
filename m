From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netns: revert "netns: avoid disabling irq for netns id"
Date: Fri, 21 Oct 2016 21:49:14 -0400
Message-ID: <147710095406.17836.12069093425270216381.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Elad Raz <e@eladraz.com>,
        Stephen Smalley <sds@tycho.nsa.gov>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755550AbcJVBtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 21:49:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>

This reverts commit bc51dddf98c9 ("netns: avoid disabling irq for
netns id") as it was found to cause problems with systems running
SELinux/audit, see the mailing list thread below:

 * http://marc.info/?t=147694653900002&r=1&w=2

Eventually we should be able to reintroduce this code once we have
rewritten the audit multicast code to queue messages much the same
way we do for unicast messages.  A tracking issue for this can be
found below:

 * https://github.com/linux-audit/audit-kernel/issues/23

Reported-by: Stephen Smalley <sds@tycho.nsa.gov>
Reported-by: Elad Raz <e@eladraz.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 net/core/net_namespace.c |   35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 989434f..f61c0e0 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -215,13 +215,14 @@ static void rtnl_net_notifyid(struct net *net, int cmd, int id);
  */
 int peernet2id_alloc(struct net *net, struct net *peer)
 {
+	unsigned long flags;
 	bool alloc;
 	int id;
 
-	spin_lock_bh(&net->nsid_lock);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	alloc = atomic_read(&peer->count) == 0 ? false : true;
 	id = __peernet2id_alloc(net, peer, &alloc);
-	spin_unlock_bh(&net->nsid_lock);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	if (alloc && id >= 0)
 		rtnl_net_notifyid(net, RTM_NEWNSID, id);
 	return id;
@@ -230,11 +231,12 @@ int peernet2id_alloc(struct net *net, struct net *peer)
 /* This function returns, if assigned, the id of a peer netns. */
 int peernet2id(struct net *net, struct net *peer)
 {
+	unsigned long flags;
 	int id;
 
-	spin_lock_bh(&net->nsid_lock);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	id = __peernet2id(net, peer);
-	spin_unlock_bh(&net->nsid_lock);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	return id;
 }
 EXPORT_SYMBOL(peernet2id);
@@ -249,17 +251,18 @@ bool peernet_has_id(struct net *net, struct net *peer)
 
 struct net *get_net_ns_by_id(struct net *net, int id)
 {
+	unsigned long flags;
 	struct net *peer;
 
 	if (id < 0)
 		return NULL;
 
 	rcu_read_lock();
-	spin_lock_bh(&net->nsid_lock);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	peer = idr_find(&net->netns_ids, id);
 	if (peer)
 		get_net(peer);
-	spin_unlock_bh(&net->nsid_lock);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	rcu_read_unlock();
 
 	return peer;
@@ -422,17 +425,17 @@ static void cleanup_net(struct work_struct *work)
 		for_each_net(tmp) {
 			int id;
 
-			spin_lock_bh(&tmp->nsid_lock);
+			spin_lock_irq(&tmp->nsid_lock);
 			id = __peernet2id(tmp, net);
 			if (id >= 0)
 				idr_remove(&tmp->netns_ids, id);
-			spin_unlock_bh(&tmp->nsid_lock);
+			spin_unlock_irq(&tmp->nsid_lock);
 			if (id >= 0)
 				rtnl_net_notifyid(tmp, RTM_DELNSID, id);
 		}
-		spin_lock_bh(&net->nsid_lock);
+		spin_lock_irq(&net->nsid_lock);
 		idr_destroy(&net->netns_ids);
-		spin_unlock_bh(&net->nsid_lock);
+		spin_unlock_irq(&net->nsid_lock);
 
 	}
 	rtnl_unlock();
@@ -561,6 +564,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
+	unsigned long flags;
 	struct net *peer;
 	int nsid, err;
 
@@ -581,15 +585,15 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (IS_ERR(peer))
 		return PTR_ERR(peer);
 
-	spin_lock_bh(&net->nsid_lock);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	if (__peernet2id(net, peer) >= 0) {
-		spin_unlock_bh(&net->nsid_lock);
+		spin_unlock_irqrestore(&net->nsid_lock, flags);
 		err = -EEXIST;
 		goto out;
 	}
 
 	err = alloc_netid(net, peer, nsid);
-	spin_unlock_bh(&net->nsid_lock);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 	if (err >= 0) {
 		rtnl_net_notifyid(net, RTM_NEWNSID, err);
 		err = 0;
@@ -711,10 +715,11 @@ static int rtnl_net_dumpid(struct sk_buff *skb, struct netlink_callback *cb)
 		.idx = 0,
 		.s_idx = cb->args[0],
 	};
+	unsigned long flags;
 
-	spin_lock_bh(&net->nsid_lock);
+	spin_lock_irqsave(&net->nsid_lock, flags);
 	idr_for_each(&net->netns_ids, rtnl_net_dumpid_one, &net_cb);
-	spin_unlock_bh(&net->nsid_lock);
+	spin_unlock_irqrestore(&net->nsid_lock, flags);
 
 	cb->args[0] = net_cb.idx;
 	return skb->len;
