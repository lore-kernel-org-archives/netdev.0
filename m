From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/6] rtnetlink: do not use RTM_GETLINK directly
Date: Thu, 10 Aug 2017 16:52:58 +0200
Message-ID: <20170810145302.30391-3-fw@strlen.de>
References: <20170810145302.30391-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46626 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752612AbdHJOww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 10:52:52 -0400
In-Reply-To: <20170810145302.30391-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace sends RTM_GETLINK type, but the kernel substracts
RTM_BASE from this, i.e. 'type' doesn't contain RTM_GETLINK
anymore but instead RTM_GETLINK - RTM_BASE.

This caused the calcit callback to not be invoked when it
should have been (and vice versa).

While at it, also fix a off-by one when checking family index. vs
handler array size.

Fixes: e1fa6d216dd ("rtnetlink: call rtnl_calcit directly")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a5bc5bd0dc12..a9b5ebc1af21 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4167,7 +4167,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (kind != 2 && !netlink_net_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (family > ARRAY_SIZE(rtnl_msg_handlers))
+	if (family >= ARRAY_SIZE(rtnl_msg_handlers))
 		family = PF_UNSPEC;
 
 	rcu_read_lock();
@@ -4196,7 +4196,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 		refcount_inc(&rtnl_msg_handlers_ref[family]);
 
-		if (type == RTM_GETLINK)
+		if (type == RTM_GETLINK - RTM_BASE)
 			min_dump_alloc = rtnl_calcit(skb, nlh);
 
 		rcu_read_unlock();
-- 
2.13.0
