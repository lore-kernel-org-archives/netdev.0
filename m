From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/6] netns: notify new nsid outside __peernet2id()
Date: Wed,  6 May 2015 11:58:06 +0200
Message-ID: <1430906288-5108-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:42317 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbbEFJ6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:58:16 -0400
In-Reply-To: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no functional change with this patch. It will ease the refactoring
of the locking system that protects nsids and the support of the netlink
socket option NETLINK_LISTEN_ALL_NSID.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 37 +++++++++++++++++++++++--------------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 9c806ac569f9..cc4b84c944be 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -147,10 +147,9 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
-static void rtnl_net_notifyid(struct net *net, int cmd, int id);
 static int alloc_netid(struct net *net, struct net *peer, int reqid)
 {
-	int min = 0, max = 0, id;
+	int min = 0, max = 0;
 
 	ASSERT_RTNL();
 
@@ -159,11 +158,7 @@ static int alloc_netid(struct net *net, struct net *peer, int reqid)
 		max = reqid + 1;
 	}
 
-	id = idr_alloc(&net->netns_ids, peer, min, max, GFP_KERNEL);
-	if (id >= 0)
-		rtnl_net_notifyid(net, RTM_NEWNSID, id);
-
-	return id;
+	return idr_alloc(&net->netns_ids, peer, min, max, GFP_KERNEL);
 }
 
 /* This function is used by idr_for_each(). If net is equal to peer, the
@@ -179,34 +174,43 @@ static int net_eq_idr(int id, void *net, void *peer)
 	return 0;
 }
 
-static int __peernet2id(struct net *net, struct net *peer, bool alloc)
+static int __peernet2id(struct net *net, struct net *peer, bool *alloc)
 {
 	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
+	bool alloc_it = *alloc;
 
 	ASSERT_RTNL();
 
+	*alloc = false;
+
 	/* Magic value for id 0. */
 	if (id == NET_ID_ZERO)
 		return 0;
 	if (id > 0)
 		return id;
 
-	if (alloc) {
+	if (alloc_it) {
 		id = alloc_netid(net, peer, -1);
+		*alloc = true;
 		return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
 	}
 
 	return NETNSA_NSID_NOT_ASSIGNED;
 }
 
+static void rtnl_net_notifyid(struct net *net, int cmd, int id);
 /* This function returns the id of a peer netns. If no id is assigned, one will
  * be allocated and returned.
  */
 int peernet2id_alloc(struct net *net, struct net *peer)
 {
 	bool alloc = atomic_read(&peer->count) == 0 ? false : true;
+	int id;
 
-	return __peernet2id(net, peer, alloc);
+	id = __peernet2id(net, peer, &alloc);
+	if (alloc && id >= 0)
+		rtnl_net_notifyid(net, RTM_NEWNSID, id);
+	return id;
 }
 EXPORT_SYMBOL(peernet2id_alloc);
 
@@ -361,7 +365,8 @@ static void cleanup_net(struct work_struct *work)
 		list_del_rcu(&net->list);
 		list_add_tail(&net->exit_list, &net_exit_list);
 		for_each_net(tmp) {
-			int id = __peernet2id(tmp, net, false);
+			bool no = false;
+			int id = __peernet2id(tmp, net, &no);
 
 			if (id >= 0) {
 				rtnl_net_notifyid(tmp, RTM_DELNSID, id);
@@ -496,6 +501,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
+	bool no = false;
 	struct net *peer;
 	int nsid, err;
 
@@ -516,14 +522,16 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (IS_ERR(peer))
 		return PTR_ERR(peer);
 
-	if (__peernet2id(net, peer, false) >= 0) {
+	if (__peernet2id(net, peer, &no) >= 0) {
 		err = -EEXIST;
 		goto out;
 	}
 
 	err = alloc_netid(net, peer, nsid);
-	if (err > 0)
+	if (err >= 0) {
+		rtnl_net_notifyid(net, RTM_NEWNSID, err);
 		err = 0;
+	}
 out:
 	put_net(peer);
 	return err;
@@ -566,6 +574,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[NETNSA_MAX + 1];
 	struct sk_buff *msg;
 	struct net *peer;
+	bool no = false;
 	int err, id;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
@@ -588,7 +597,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto out;
 	}
 
-	id = __peernet2id(net, peer, false);
+	id = __peernet2id(net, peer, &no);
 	err = rtnl_net_fill(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
 			    RTM_GETNSID, net, id);
 	if (err < 0)
-- 
2.2.2
