From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 5/6] rtnetlink: fallback to UNSPEC if current family has no doit callback
Date: Thu, 10 Aug 2017 16:53:01 +0200
Message-ID: <20170810145302.30391-6-fw@strlen.de>
References: <20170810145302.30391-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46638 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752728AbdHJOxC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 10:53:02 -0400
In-Reply-To: <20170810145302.30391-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to use PF_UNSPEC in case the requested family has no doit
callback, otherwise this now fails with EOPNOTSUPP instead of running the
unspec doit callback, as before.

Fixes: 6853dd488119 ("rtnetlink: protect handler table with rcu")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 59eda6952bc9..9e9f1419be60 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4221,6 +4221,12 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 	}
 
+	doit = READ_ONCE(handlers[type].doit);
+	if (!doit) {
+		family = PF_UNSPEC;
+		handlers = rcu_dereference(rtnl_msg_handlers[family]);
+	}
+
 	flags = READ_ONCE(handlers[type].flags);
 	if (flags & RTNL_FLAG_DOIT_UNLOCKED) {
 		refcount_inc(&rtnl_msg_handlers_ref[family]);
-- 
2.13.0
