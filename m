From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/6] rtnetlink: use rcu_dereference_raw to silence rcu splat
Date: Thu, 10 Aug 2017 16:52:57 +0200
Message-ID: <20170810145302.30391-2-fw@strlen.de>
References: <20170810145302.30391-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46622 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752091AbdHJOwt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 10:52:49 -0400
In-Reply-To: <20170810145302.30391-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ido reports a rcu splat in __rtnl_register.
The splat is correct; as rtnl_register doesn't grab any logs
and doesn't use rcu locks either.  It has always been like this.
handler families are not registered in parallel so there are no
races wrt. the kmalloc ordering.

The only reason to use rcu_dereference in the first place was to
avoid sparse from complaining about this.

Thus this switches to _raw() to not have rcu checks here.

The alternative is to add rtnl locking to register/unregister,
however, I don't see a compelling reason to do so as this has been
lockless for the past twenty years or so.

Fixes: 6853dd4881 ("rtnetlink: protect handler table with rcu")
Reported-by: Ido Schimmel <idosch@idosch.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index dd4e50dfa248..a5bc5bd0dc12 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -172,7 +172,7 @@ int __rtnl_register(int protocol, int msgtype,
 	BUG_ON(protocol < 0 || protocol > RTNL_FAMILY_MAX);
 	msgindex = rtm_msgindex(msgtype);
 
-	tab = rcu_dereference(rtnl_msg_handlers[protocol]);
+	tab = rcu_dereference_raw(rtnl_msg_handlers[protocol]);
 	if (tab == NULL) {
 		tab = kcalloc(RTM_NR_MSGTYPES, sizeof(*tab), GFP_KERNEL);
 		if (tab == NULL)
-- 
2.13.0
