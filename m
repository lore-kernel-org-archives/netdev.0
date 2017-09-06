From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] netlink: access nlk groups safely in netlink bind and getname
Date: Wed,  6 Sep 2017 11:53:29 +0800
Message-ID: <cfb5c05d158b278beb2f1441c67a068a8bb27d44.1504670009.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34445 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdIFDxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 23:53:37 -0400
Received: by mail-pg0-f66.google.com with SMTP id v82so2280719pgb.1
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 20:53:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now there is no lock protecting nlk ngroups/groups' accessing in
netlink bind and getname. It's safe from nlk groups' setting in
netlink_release, but not from netlink_realloc_groups called by
netlink_setsockopt.

netlink_lock_table is needed in both netlink bind and getname when
accessing nlk groups.

Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/netlink/af_netlink.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 94a61e6..3278077 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -955,7 +955,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	struct net *net = sock_net(sk);
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
-	int err;
+	int err = 0;
 	long unsigned int groups = nladdr->nl_groups;
 	bool bound;
 
@@ -983,6 +983,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return -EINVAL;
 	}
 
+	netlink_lock_table();
 	if (nlk->netlink_bind && groups) {
 		int group;
 
@@ -993,7 +994,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			if (!err)
 				continue;
 			netlink_undo_bind(group, groups, sk);
-			return err;
+			goto unlock;
 		}
 	}
 
@@ -1006,12 +1007,13 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			netlink_autobind(sock);
 		if (err) {
 			netlink_undo_bind(nlk->ngroups, groups, sk);
-			return err;
+			goto unlock;
 		}
 	}
 
 	if (!groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
-		return 0;
+		goto unlock;
+	netlink_unlock_table();
 
 	netlink_table_grab();
 	netlink_update_subscriptions(sk, nlk->subscriptions +
@@ -1022,6 +1024,10 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	netlink_table_ungrab();
 
 	return 0;
+
+unlock:
+	netlink_unlock_table();
+	return err;
 }
 
 static int netlink_connect(struct socket *sock, struct sockaddr *addr,
@@ -1079,7 +1085,9 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 		nladdr->nl_groups = netlink_group_mask(nlk->dst_group);
 	} else {
 		nladdr->nl_pid = nlk->portid;
+		netlink_lock_table();
 		nladdr->nl_groups = nlk->groups ? nlk->groups[0] : 0;
+		netlink_unlock_table();
 	}
 	return 0;
 }
-- 
2.1.0
