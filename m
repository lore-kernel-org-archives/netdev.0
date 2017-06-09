From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/2] netns: define extack error msg for nsis cmds
Date: Fri,  9 Jun 2017 14:41:56 +0200
Message-ID: <1497012117-1344-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48391 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdFIN51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 09:57:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It helps the user to identify errors.

CC: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 42 +++++++++++++++++++++++++++++++++---------
 1 file changed, 33 insertions(+), 9 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 26bbfababff2..1f60c180e2de 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -596,6 +596,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh,
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
+	struct nlattr *nla;
 	struct net *peer;
 	int nsid, err;
 
@@ -603,23 +604,35 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh,
 			  rtnl_net_policy, extack);
 	if (err < 0)
 		return err;
-	if (!tb[NETNSA_NSID])
+	if (!tb[NETNSA_NSID]) {
+		NL_SET_ERR_MSG(extack, "nsid is missing");
 		return -EINVAL;
+	}
 	nsid = nla_get_s32(tb[NETNSA_NSID]);
 
-	if (tb[NETNSA_PID])
+	if (tb[NETNSA_PID]) {
 		peer = get_net_ns_by_pid(nla_get_u32(tb[NETNSA_PID]));
-	else if (tb[NETNSA_FD])
+		nla = tb[NETNSA_PID];
+	} else if (tb[NETNSA_FD]) {
 		peer = get_net_ns_by_fd(nla_get_u32(tb[NETNSA_FD]));
-	else
+		nla = tb[NETNSA_FD];
+	} else {
+		NL_SET_ERR_MSG(extack, "Peer netns reference is missing");
 		return -EINVAL;
-	if (IS_ERR(peer))
+	}
+	if (IS_ERR(peer)) {
+		NL_SET_BAD_ATTR(extack, nla);
+		NL_SET_ERR_MSG(extack, "Peer netns reference is invalid");
 		return PTR_ERR(peer);
+	}
 
 	spin_lock_bh(&net->nsid_lock);
 	if (__peernet2id(net, peer) >= 0) {
 		spin_unlock_bh(&net->nsid_lock);
 		err = -EEXIST;
+		NL_SET_BAD_ATTR(extack, nla);
+		NL_SET_ERR_MSG(extack,
+			       "Peer netns already has a nsid assigned");
 		goto out;
 	}
 
@@ -628,6 +641,9 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (err >= 0) {
 		rtnl_net_notifyid(net, RTM_NEWNSID, err);
 		err = 0;
+	} else if (err == -ENOSPC && nsid >= 0) {
+		NL_SET_BAD_ATTR(extack, tb[NETNSA_NSID]);
+		NL_SET_ERR_MSG(extack, "The specified nsid is already used");
 	}
 out:
 	put_net(peer);
@@ -670,6 +686,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh,
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
+	struct nlattr *nla;
 	struct sk_buff *msg;
 	struct net *peer;
 	int err, id;
@@ -678,15 +695,22 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh,
 			  rtnl_net_policy, extack);
 	if (err < 0)
 		return err;
-	if (tb[NETNSA_PID])
+	if (tb[NETNSA_PID]) {
 		peer = get_net_ns_by_pid(nla_get_u32(tb[NETNSA_PID]));
-	else if (tb[NETNSA_FD])
+		nla = tb[NETNSA_PID];
+	} else if (tb[NETNSA_FD]) {
 		peer = get_net_ns_by_fd(nla_get_u32(tb[NETNSA_FD]));
-	else
+		nla = tb[NETNSA_FD];
+	} else {
+		NL_SET_ERR_MSG(extack, "Peer netns reference is missing");
 		return -EINVAL;
+	}
 
-	if (IS_ERR(peer))
+	if (IS_ERR(peer)) {
+		NL_SET_BAD_ATTR(extack, nla);
+		NL_SET_ERR_MSG(extack, "Peer netns reference is invalid");
 		return PTR_ERR(peer);
+	}
 
 	msg = nlmsg_new(rtnl_net_get_size(), GFP_KERNEL);
 	if (!msg) {
-- 
2.8.1
