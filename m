From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/4] netns: notify netns id events
Date: Wed,  1 Apr 2015 14:49:48 +0200
Message-ID: <1427892589-4266-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55540 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbbDAMuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:50:08 -0400
In-Reply-To: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, netns ids that are created and deleted are advertised into the
group RTNLGRP_NSID.

Because callers of rtnl_net_notifyid() already know the id of the peer, there is
no need to call __peernet2id() in rtnl_net_fill().

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/rtnetlink.h |  4 ++++
 net/core/net_namespace.c       | 52 +++++++++++++++++++++++++++++++++++-------
 2 files changed, 48 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index bea910f924dd..974db03f7b1a 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -134,6 +134,8 @@ enum {
 
 	RTM_NEWNSID = 88,
 #define RTM_NEWNSID RTM_NEWNSID
+	RTM_DELNSID = 89,
+#define RTM_DELNSID RTM_DELNSID
 	RTM_GETNSID = 90,
 #define RTM_GETNSID RTM_GETNSID
 
@@ -635,6 +637,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_MDB		RTNLGRP_MDB
 	RTNLGRP_MPLS_ROUTE,
 #define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
+	RTNLGRP_NSID,
+#define RTNLGRP_NSID		RTNLGRP_NSID
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6c770be87f1f..bfe44c328ec2 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -148,9 +148,11 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
+static void rtnl_net_notifyid(struct net *net, struct net *peer, int cmd,
+			      int id);
 static int alloc_netid(struct net *net, struct net *peer, int reqid)
 {
-	int min = 0, max = 0;
+	int min = 0, max = 0, id;
 
 	ASSERT_RTNL();
 
@@ -159,7 +161,11 @@ static int alloc_netid(struct net *net, struct net *peer, int reqid)
 		max = reqid + 1;
 	}
 
-	return idr_alloc(&net->netns_ids, peer, min, max, GFP_KERNEL);
+	id = idr_alloc(&net->netns_ids, peer, min, max, GFP_KERNEL);
+	if (id >= 0)
+		rtnl_net_notifyid(net, peer, RTM_NEWNSID, id);
+
+	return id;
 }
 
 /* This function is used by idr_for_each(). If net is equal to peer, the
@@ -389,8 +395,10 @@ static void cleanup_net(struct work_struct *work)
 		for_each_net(peer) {
 			int id = __peernet2id(peer, net, false);
 
-			if (id >= 0)
+			if (id >= 0) {
+				rtnl_net_notifyid(peer, net, RTM_DELNSID, id);
 				idr_remove(&peer->netns_ids, id);
+			}
 		}
 		idr_destroy(&net->netns_ids);
 
@@ -535,7 +543,8 @@ static int rtnl_net_get_size(void)
 }
 
 static int rtnl_net_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
-			 int cmd, struct net *net, struct net *peer)
+			 int cmd, struct net *net, struct net *peer,
+			 int nsid)
 {
 	struct nlmsghdr *nlh;
 	struct rtgenmsg *rth;
@@ -550,9 +559,13 @@ static int rtnl_net_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
 	rth = nlmsg_data(nlh);
 	rth->rtgen_family = AF_UNSPEC;
 
-	id = __peernet2id(net, peer, false);
-	if  (id < 0)
-		id = NETNSA_NSID_NOT_ASSIGNED;
+	if (nsid >= 0) {
+		id = nsid;
+	} else {
+		id = __peernet2id(net, peer, false);
+		if  (id < 0)
+			id = NETNSA_NSID_NOT_ASSIGNED;
+	}
 	if (nla_put_s32(skb, NETNSA_NSID, id))
 		goto nla_put_failure;
 
@@ -593,7 +606,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	err = rtnl_net_fill(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
-			    RTM_GETNSID, net, peer);
+			    RTM_GETNSID, net, peer, -1);
 	if (err < 0)
 		goto err_out;
 
@@ -607,6 +620,29 @@ out:
 	return err;
 }
 
+static void rtnl_net_notifyid(struct net *net, struct net *peer, int cmd,
+			      int id)
+{
+	struct sk_buff *msg;
+	int err = -ENOMEM;
+
+	msg = nlmsg_new(rtnl_net_get_size(), GFP_KERNEL);
+	if (!msg)
+		goto out;
+
+	err = rtnl_net_fill(msg, 0, 0, 0, cmd, net, peer, id);
+	if (err < 0)
+		goto err_out;
+
+	rtnl_notify(msg, net, 0, RTNLGRP_NSID, NULL, 0);
+	return;
+
+err_out:
+	nlmsg_free(msg);
+out:
+	rtnl_set_sk_err(net, RTNLGRP_NSID, err);
+}
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
-- 
2.2.2
