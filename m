From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 5/6] netns: use a spin_lock to protect nsid management
Date: Wed,  6 May 2015 11:58:07 +0200
Message-ID: <1430906288-5108-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42324 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbEFJ6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:58:18 -0400
In-Reply-To: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch, nsid were protected by the rtnl lock. The goal of this
patch is to be able to find a nsid without needing to hold the rtnl lock.

The next patch will introduce a netlink socket option to listen to all
netns that have a nsid assigned into the netns where the socket is opened.
Thus, it's important to call rtnl_net_notifyid() outside the spinlock, to
avoid a recursive lock (nsid are notified via rtnl). This was the main
reason of the previous patch.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 58 ++++++++++++++++++++++++++++++++++++------------
 1 file changed, 44 insertions(+), 14 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index cc4b84c944be..0b4cb3d63449 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -28,6 +28,7 @@
 static LIST_HEAD(pernet_list);
 static struct list_head *first_device = &pernet_list;
 DEFINE_MUTEX(net_mutex);
+static DEFINE_SPINLOCK(nsid_lock);
 
 LIST_HEAD(net_namespace_list);
 EXPORT_SYMBOL_GPL(net_namespace_list);
@@ -147,18 +148,17 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
+/* should be called with nsid_lock held */
 static int alloc_netid(struct net *net, struct net *peer, int reqid)
 {
 	int min = 0, max = 0;
 
-	ASSERT_RTNL();
-
 	if (reqid >= 0) {
 		min = reqid;
 		max = reqid + 1;
 	}
 
-	return idr_alloc(&net->netns_ids, peer, min, max, GFP_KERNEL);
+	return idr_alloc(&net->netns_ids, peer, min, max, GFP_ATOMIC);
 }
 
 /* This function is used by idr_for_each(). If net is equal to peer, the
@@ -174,13 +174,15 @@ static int net_eq_idr(int id, void *net, void *peer)
 	return 0;
 }
 
+/* Should be called with nsid_lock held. If a new id is assigned, the bool alloc
+ * is set to true, thus the caller knows that the new id must be notified via
+ * rtnl.
+ */
 static int __peernet2id(struct net *net, struct net *peer, bool *alloc)
 {
 	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
 	bool alloc_it = *alloc;
 
-	ASSERT_RTNL();
-
 	*alloc = false;
 
 	/* Magic value for id 0. */
@@ -204,27 +206,47 @@ static void rtnl_net_notifyid(struct net *net, int cmd, int id);
  */
 int peernet2id_alloc(struct net *net, struct net *peer)
 {
-	bool alloc = atomic_read(&peer->count) == 0 ? false : true;
+	unsigned long flags;
+	bool alloc;
 	int id;
 
+	spin_lock_irqsave(&nsid_lock, flags);
+	alloc = atomic_read(&peer->count) == 0 ? false : true;
 	id = __peernet2id(net, peer, &alloc);
+	spin_unlock_irqrestore(&nsid_lock, flags);
 	if (alloc && id >= 0)
 		rtnl_net_notifyid(net, RTM_NEWNSID, id);
 	return id;
 }
 EXPORT_SYMBOL(peernet2id_alloc);
 
+/* This function returns, if assigned, the id of a peer netns. */
+static int peernet2id(struct net *net, struct net *peer)
+{
+	unsigned long flags;
+	bool no = false;
+	int id;
+
+	spin_lock_irqsave(&nsid_lock, flags);
+	id = __peernet2id(net, peer, &no);
+	spin_unlock_irqrestore(&nsid_lock, flags);
+	return id;
+}
+
 struct net *get_net_ns_by_id(struct net *net, int id)
 {
+	unsigned long flags;
 	struct net *peer;
 
 	if (id < 0)
 		return NULL;
 
 	rcu_read_lock();
+	spin_lock_irqsave(&nsid_lock, flags);
 	peer = idr_find(&net->netns_ids, id);
 	if (peer)
 		get_net(peer);
+	spin_unlock_irqrestore(&nsid_lock, flags);
 	rcu_read_unlock();
 
 	return peer;
@@ -366,14 +388,19 @@ static void cleanup_net(struct work_struct *work)
 		list_add_tail(&net->exit_list, &net_exit_list);
 		for_each_net(tmp) {
 			bool no = false;
-			int id = __peernet2id(tmp, net, &no);
+			int id;
 
-			if (id >= 0) {
-				rtnl_net_notifyid(tmp, RTM_DELNSID, id);
+			spin_lock_irq(&nsid_lock);
+			id = __peernet2id(tmp, net, &no);
+			if (id >= 0)
 				idr_remove(&tmp->netns_ids, id);
-			}
+			spin_unlock_irq(&nsid_lock);
+			if (id >= 0)
+				rtnl_net_notifyid(tmp, RTM_DELNSID, id);
 		}
+		spin_lock_irq(&nsid_lock);
 		idr_destroy(&net->netns_ids);
+		spin_unlock_irq(&nsid_lock);
 
 	}
 	rtnl_unlock();
@@ -501,6 +528,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
+	unsigned long flags;
 	bool no = false;
 	struct net *peer;
 	int nsid, err;
@@ -522,12 +550,14 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (IS_ERR(peer))
 		return PTR_ERR(peer);
 
+	spin_lock_irqsave(&nsid_lock, flags);
 	if (__peernet2id(net, peer, &no) >= 0) {
 		err = -EEXIST;
 		goto out;
 	}
 
 	err = alloc_netid(net, peer, nsid);
+	spin_unlock_irqrestore(&nsid_lock, flags);
 	if (err >= 0) {
 		rtnl_net_notifyid(net, RTM_NEWNSID, err);
 		err = 0;
@@ -574,7 +604,6 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[NETNSA_MAX + 1];
 	struct sk_buff *msg;
 	struct net *peer;
-	bool no = false;
 	int err, id;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
@@ -597,7 +626,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto out;
 	}
 
-	id = __peernet2id(net, peer, &no);
+	id = peernet2id(net, peer);
 	err = rtnl_net_fill(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
 			    RTM_GETNSID, net, id);
 	if (err < 0)
@@ -650,10 +679,11 @@ static int rtnl_net_dumpid(struct sk_buff *skb, struct netlink_callback *cb)
 		.idx = 0,
 		.s_idx = cb->args[0],
 	};
+	unsigned long flags;
 
-	ASSERT_RTNL();
-
+	spin_lock_irqsave(&nsid_lock, flags);
 	idr_for_each(&net->netns_ids, rtnl_net_dumpid_one, &net_cb);
+	spin_unlock_irqrestore(&nsid_lock, flags);
 
 	cb->args[0] = net_cb.idx;
 	return skb->len;
-- 
2.2.2
