From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] netfilter: ebtables: make broute table work again
Date: Fri, 24 Dec 2010 01:27:16 +0100
Message-ID: <1293150436-12092-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:46332 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752040Ab0LXAcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 19:32:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

broute table init hook sets up the "br_should_route_hook" pointer,
which then gets called from br_input.

commit a386f99025f13b32502fe5dedf223c20d7283826
(bridge: add proper RCU annotation to should_route_hook)
introduced a typedef, and then changed this to:

br_should_route_hook_t *rhook;
[..]
rhook = rcu_dereference(br_should_route_hook);
if (*rhook(skb))

problem is that "br_should_route_hook" contains the address of the function,
so calling *rhook() results in kernel panic.

Can't simply use "if (rhook(skb)", because br_should_route_hook_t *rhook
is not a function.

Signed-off-by: Florian Westphal <fw@strlen.de>
---

 include/linux/if_bridge.h |    2 +-
 net/bridge/br_input.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index f7e73c3..dd3f201 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -103,7 +103,7 @@ struct __fdb_entry {
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 
-typedef int (*br_should_route_hook_t)(struct sk_buff *skb);
+typedef int br_should_route_hook_t(struct sk_buff *skb);
 extern br_should_route_hook_t __rcu *br_should_route_hook;
 
 #endif
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 6f6d8e1..1d677bf 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -178,7 +178,7 @@ forward:
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
 		if (rhook) {
-			if ((*rhook)(skb))
+			if (rhook(skb))
 				return skb;
 			dest = eth_hdr(skb)->h_dest;
 		}
-- 
1.7.2.2

