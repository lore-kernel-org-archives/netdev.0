From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/7] rtnetlink: call rtnl_calcit directly
Date: Tue,  8 Aug 2017 18:02:30 +0200
Message-ID: <20170808160236.28562-2-fw@strlen.de>
References: <20170808160236.28562-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35526 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752104AbdHHQCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:02:21 -0400
In-Reply-To: <20170808160236.28562-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is only a single place in the kernel that regisers the "calcit"
callback (to determine min allocation for dumps).

This is in rtnetlink.c for PF_UNSPEC RTM_GETLINK.
The function that checks for calcit presence at run time will first check
the requested family (which will always fail for !PF_UNSPEC as no callsite
registers this), then falls back to checking PF_UNSPEC.

Therefore we can just check if type is RTM_GETLINK and then do a direct
call.  Because of fallback to PF_UNSPEC all RTM_GETLINK types used this
regardless of family.

This has the advantage that we don't need to allocate space for
the function pointer for all the other families.

A followup patch will drop the calcit function pointer from the
rtnl_link callback structure.

Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/rtnetlink.c | 29 ++++-------------------------
 1 file changed, 4 insertions(+), 25 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9201e3621351..8c9d34deea7d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -62,7 +62,6 @@
 struct rtnl_link {
 	rtnl_doit_func		doit;
 	rtnl_dumpit_func	dumpit;
-	rtnl_calcit_func 	calcit;
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
@@ -173,21 +172,6 @@ static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
 	return tab[msgindex].dumpit;
 }
 
-static rtnl_calcit_func rtnl_get_calcit(int protocol, int msgindex)
-{
-	struct rtnl_link *tab;
-
-	if (protocol <= RTNL_FAMILY_MAX)
-		tab = rtnl_msg_handlers[protocol];
-	else
-		tab = NULL;
-
-	if (tab == NULL || tab[msgindex].calcit == NULL)
-		tab = rtnl_msg_handlers[PF_UNSPEC];
-
-	return tab[msgindex].calcit;
-}
-
 /**
  * __rtnl_register - Register a rtnetlink message type
  * @protocol: Protocol family or PF_UNSPEC
@@ -231,9 +215,6 @@ int __rtnl_register(int protocol, int msgtype,
 	if (dumpit)
 		tab[msgindex].dumpit = dumpit;
 
-	if (calcit)
-		tab[msgindex].calcit = calcit;
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__rtnl_register);
@@ -277,7 +258,6 @@ int rtnl_unregister(int protocol, int msgtype)
 
 	rtnl_msg_handlers[protocol][msgindex].doit = NULL;
 	rtnl_msg_handlers[protocol][msgindex].dumpit = NULL;
-	rtnl_msg_handlers[protocol][msgindex].calcit = NULL;
 
 	return 0;
 }
@@ -4187,15 +4167,14 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
 		struct sock *rtnl;
 		rtnl_dumpit_func dumpit;
-		rtnl_calcit_func calcit;
 		u16 min_dump_alloc = 0;
 
 		dumpit = rtnl_get_dumpit(family, type);
 		if (dumpit == NULL)
 			return -EOPNOTSUPP;
-		calcit = rtnl_get_calcit(family, type);
-		if (calcit)
-			min_dump_alloc = calcit(skb, nlh);
+
+		if (type == RTM_GETLINK)
+			min_dump_alloc = rtnl_calcit(skb, nlh);
 
 		__rtnl_unlock();
 		rtnl = net->rtnl;
@@ -4300,7 +4279,7 @@ void __init rtnetlink_init(void)
 	register_netdevice_notifier(&rtnetlink_dev_notifier);
 
 	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink,
-		      rtnl_dump_ifinfo, rtnl_calcit);
+		      rtnl_dump_ifinfo, NULL);
 	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL, NULL);
-- 
2.13.0
