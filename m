From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix bug in socket reception function
Date: Sun,  8 Feb 2015 11:10:50 -0500
Message-ID: <1423411850-2594-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.biz.mail.bf1.yahoo.com ([98.139.221.60]:47190 "EHLO
	smtp101.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752218AbbBHQL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 11:11:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit c637c1035534867b85b78b453c38c495b58e2c5a ("tipc: resolve race
problem at unicast message reception") we introduced a time limit
for how long the function tipc_sk_eneque() would be allowed to execute
its loop. Unfortunately, the test for when this limit is passed was put
in the wrong place, resulting in a lost message when the test is true.

We fix this by moving the test to before we dequeue the next buffer
from the input queue.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6666680..4a98d15 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1802,12 +1802,11 @@ static int tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
 	unsigned long time_limit = jiffies + 2;
 
 	while (skb_queue_len(inputq)) {
+		if (unlikely(time_after_eq(jiffies, time_limit)))
+			return TIPC_OK;
 		skb = tipc_skb_dequeue(inputq, dport);
 		if (unlikely(!skb))
 			return TIPC_OK;
-		/* Return if softirq window exhausted */
-		if (unlikely(time_after_eq(jiffies, time_limit)))
-			return TIPC_OK;
 		if (!sock_owned_by_user(sk)) {
 			err = filter_rcv(sk, &skb);
 			if (likely(!skb))
-- 
1.9.1
