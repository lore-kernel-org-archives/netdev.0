From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 net-next 4/7] rtnetlink: small rtnl lock pushdown
Date: Wed,  9 Aug 2017 20:41:50 +0200
Message-ID: <20170809184153.16700-5-fw@strlen.de>
References: <20170809184153.16700-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41866 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751944AbdHISlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 14:41:53 -0400
In-Reply-To: <20170809184153.16700-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

instead of rtnl lock/unload at the top level, push it down
to the called function.

This is just an intermediate step, next commit switches protection
of the rtnl_link ops table to rcu, in which case (for dumps) the
rtnl lock is acquired only by the netlink dumper infrastructure
(current lock/unlock/dump/lock/unlock rtnl sequence becomes
 rcu lock/rcu unlock/dump).

Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 No changes since v1.
 net/core/rtnetlink.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c45a7c5e3232..be01d8e48661 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4178,9 +4178,11 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		rtnl_dumpit_func dumpit;
 		u16 min_dump_alloc = 0;
 
+		rtnl_lock();
+
 		dumpit = rtnl_get_dumpit(family, type);
 		if (dumpit == NULL)
-			return -EOPNOTSUPP;
+			goto err_unlock;
 
 		refcount_inc(&rtnl_msg_handlers_ref[family]);
 
@@ -4196,23 +4198,28 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 			};
 			err = netlink_dump_start(rtnl, skb, nlh, &c);
 		}
-		rtnl_lock();
 		refcount_dec(&rtnl_msg_handlers_ref[family]);
 		return err;
 	}
 
+	rtnl_lock();
 	doit = rtnl_get_doit(family, type);
 	if (doit == NULL)
-		return -EOPNOTSUPP;
+		goto err_unlock;
 
-	return doit(skb, nlh, extack);
+	err = doit(skb, nlh, extack);
+	rtnl_unlock();
+
+	return err;
+
+err_unlock:
+	rtnl_unlock();
+	return -EOPNOTSUPP;
 }
 
 static void rtnetlink_rcv(struct sk_buff *skb)
 {
-	rtnl_lock();
 	netlink_rcv_skb(skb, &rtnetlink_rcv_msg);
-	rtnl_unlock();
 }
 
 static int rtnetlink_bind(struct net *net, int group)
-- 
2.13.0
