From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 01/16] tipc: fix bug in broadcast retransmit code
Date: Fri, 9 Jan 2015 15:26:58 +0800
Message-ID: <1420788433-17960-2-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Tero.Aho@coriant.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60065 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbAIH1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 02:27:44 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>

In commit 58dc55f25631178ee74cd27185956a8f7dcb3e32 ("tipc: use generic
SKB list APIs to manage link transmission queue") we replace all list
traversal loops with the macros skb_queue_walk() or
skb_queue_walk_safe(). While the previous loops were based on the
assumption that the list was NULL-terminated, the standard macros
stop when the iterator reaches the list head, which is non-NULL.

In the function bclink_retransmit_pkt() this macro replacement has
lead to a bug. When we receive a BCAST STATE_MSG we unconditionally
call the function bclink_retransmit_pkt(), whether there really is
anything to retransmit or not, assuming that the sequence number
comparisons will lead to the correct behavior. However, if the
transmission queue is empty, or if there are no eligible buffers in
the transmission queue, we will by mistake pass the list head pointer
to the function tipc_link_retransmit(). Since the list head is not a
valid sk_buff, this leads to a crash.

In this commit we fix this by only calling tipc_link_retransmit()
if we actually found eligible buffers in the transmission queue.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 96ceefe..a9e174f 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -220,10 +220,11 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
 	struct sk_buff *skb;
 
 	skb_queue_walk(&bcl->outqueue, skb) {
-		if (more(buf_seqno(skb), after))
+		if (more(buf_seqno(skb), after)) {
+			tipc_link_retransmit(bcl, skb, mod(to - after));
 			break;
+		}
 	}
-	tipc_link_retransmit(bcl, skb, mod(to - after));
 }
 
 /**
-- 
1.7.9.5
