From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] skbuff: re-add check for NULL skb->head in kfree_skb path
Date: Sun, 23 Jul 2017 19:54:47 +0200
Message-ID: <20170723175447.28431-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45066 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751410AbdGWRy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 13:54:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A null check is needed after all.  netlink skbs can have skb->head be
backed by vmalloc.  The netlink destructor vfree()s head, then sets it to
NULL.  We then panic in skb_release_data with a NULL dereference.

Re-add such a test.

Alternative would be to switch to kvfree to free skb->head memory
and remove the special handling in netlink destructor.

Reported-by: kernel test robot <fengguang.wu@intel.com>
Fixes: 06dc75ab06943 ("net: Revert "net: add function to allocate sk_buff head without data area")
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/skbuff.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 84bdfa2..c27da51 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -638,7 +638,8 @@ void skb_release_head_state(struct sk_buff *skb)
 static void skb_release_all(struct sk_buff *skb)
 {
 	skb_release_head_state(skb);
-	skb_release_data(skb);
+	if (likely(skb->head))
+		skb_release_data(skb);
 }
 
 /**
-- 
1.8.3.1
