From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 net-next 3/7] rtnetlink: add reference counting to prevent module unload while dump is in progress
Date: Wed,  9 Aug 2017 20:41:49 +0200
Message-ID: <20170809184153.16700-4-fw@strlen.de>
References: <20170809184153.16700-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41864 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751944AbdHISlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 14:41:50 -0400
In-Reply-To: <20170809184153.16700-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't see what prevents rmmod (unregister_all is called) while a dump
is active.

Even if we'd add rtnl lock/unlock pair to unregister_all (as done here),
thats not enough either as rtnl_lock is released right before the dump
process starts.

So this adds a refcount:
 * acquire rtnl mutex
 * bump refcount
 * release mutex
 * start the dump

... and make unregister_all remove the callbacks (no new dumps possible)
and then wait until refcount is 0.

Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 No changes since v1.
 net/core/rtnetlink.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 67607c540c03..c45a7c5e3232 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -127,6 +127,7 @@ EXPORT_SYMBOL(lockdep_rtnl_is_held);
 #endif /* #ifdef CONFIG_PROVE_LOCKING */
 
 static struct rtnl_link *rtnl_msg_handlers[RTNL_FAMILY_MAX + 1];
+static refcount_t rtnl_msg_handlers_ref[RTNL_FAMILY_MAX + 1];
 
 static inline int rtm_msgindex(int msgtype)
 {
@@ -272,10 +273,18 @@ EXPORT_SYMBOL_GPL(rtnl_unregister);
  */
 void rtnl_unregister_all(int protocol)
 {
+	struct rtnl_link *handlers;
+
 	BUG_ON(protocol < 0 || protocol > RTNL_FAMILY_MAX);
 
-	kfree(rtnl_msg_handlers[protocol]);
+	rtnl_lock();
+	handlers = rtnl_msg_handlers[protocol];
 	rtnl_msg_handlers[protocol] = NULL;
+	rtnl_unlock();
+
+	while (refcount_read(&rtnl_msg_handlers_ref[protocol]) > 0)
+		schedule();
+	kfree(handlers);
 }
 EXPORT_SYMBOL_GPL(rtnl_unregister_all);
 
@@ -4173,6 +4182,8 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		if (dumpit == NULL)
 			return -EOPNOTSUPP;
 
+		refcount_inc(&rtnl_msg_handlers_ref[family]);
+
 		if (type == RTM_GETLINK)
 			min_dump_alloc = rtnl_calcit(skb, nlh);
 
@@ -4186,6 +4197,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 			err = netlink_dump_start(rtnl, skb, nlh, &c);
 		}
 		rtnl_lock();
+		refcount_dec(&rtnl_msg_handlers_ref[family]);
 		return err;
 	}
 
-- 
2.13.0
