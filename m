From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix node reference count bug
Date: Wed,  2 Dec 2015 15:19:37 -0500
Message-ID: <1449087577-7252-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.bf1.yahoo.com ([98.139.221.61]:40779 "EHLO
	smtp102.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751273AbbLBUTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:19:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5405ff6e15f40f2f ("tipc: convert node lock to rwlock")
introduced a bug to the node reference counter handling. When a
message is successfully sent in the function tipc_node_xmit(),
we return directly after releasing the node lock, instead of
continuing and decrementing the node reference counter as we
should do.

This commit fixes this bug.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 3f7a4ed..fa97d96 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1189,20 +1189,19 @@ int tipc_node_xmit(struct net *net, struct sk_buff_head *list,
 			spin_unlock_bh(&le->lock);
 		}
 		tipc_node_read_unlock(n);
-		if (likely(!skb_queue_empty(&xmitq))) {
+		if (likely(!rc))
 			tipc_bearer_xmit(net, bearer_id, &xmitq, &le->maddr);
-			return 0;
-		}
-		if (unlikely(rc == -ENOBUFS))
+		else if (rc == -ENOBUFS)
 			tipc_node_link_down(n, bearer_id, false);
 		tipc_node_put(n);
 		return rc;
 	}
 
-	if (unlikely(!in_own_node(net, dnode)))
-		return rc;
-	tipc_sk_rcv(net, list);
-	return 0;
+	if (likely(in_own_node(net, dnode))) {
+		tipc_sk_rcv(net, list);
+		return 0;
+	}
+	return rc;
 }
 
 /* tipc_node_xmit_skb(): send single buffer to destination
-- 
1.9.1
