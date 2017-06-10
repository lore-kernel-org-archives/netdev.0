From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] net: tipc: Fix a sleep-in-atomic bug in tipc_msg_reverse
Date: Sat, 10 Jun 2017 17:03:35 +0800
Message-ID: <1497085415-630-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: jon.maloy@ericsson.com, ying.xue@windriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:41340 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751870AbdFJJBP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 05:01:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel may sleep under a rcu read lock in tipc_msg_reverse, and the
function call path is:
tipc_l2_rcv_msg (acquire the lock by rcu_read_lock)
  tipc_rcv
    tipc_sk_rcv
      tipc_msg_reverse
        pskb_expand_head(GFP_KERNEL) --> may sleep
tipc_node_broadcast
  tipc_node_xmit_skb
    tipc_node_xmit
      tipc_sk_rcv
        tipc_msg_reverse
          pskb_expand_head(GFP_KERNEL) --> may sleep

To fix it, "GFP_KERNEL" is replaced with "GFP_ATOMIC".

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 net/tipc/msg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 312ef7d..ab30876 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -508,7 +508,7 @@ bool tipc_msg_reverse(u32 own_node,  struct sk_buff **skb, int err)
 	}
 
 	if (skb_cloned(_skb) &&
-	    pskb_expand_head(_skb, BUF_HEADROOM, BUF_TAILROOM, GFP_KERNEL))
+	    pskb_expand_head(_skb, BUF_HEADROOM, BUF_TAILROOM, GFP_ATOMIC))
 		goto exit;
 
 	/* Now reverse the concerned fields */
-- 
1.7.9.5
