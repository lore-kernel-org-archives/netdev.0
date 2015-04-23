From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 2/3] tipc: fix random link reset problem
Date: Thu, 23 Apr 2015 09:37:39 -0400
Message-ID: <1429796260-14178-3-git-send-email-jon.maloy@ericsson.com>
References: <1429796260-14178-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:24027 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933920AbbDWNiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 09:38:21 -0400
In-Reply-To: <1429796260-14178-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

In the function tipc_sk_rcv(), the stack variable 'err'
is only initialized to TIPC_ERR_NO_PORT for the first
iteration over the link input queue. If a chain of messages
are received from a link, failure to lookup the socket for
any but the first message will cause the message to bounce back
out on a random link.
We fix this by properly initializing err.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ee90d74..9074b5c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1764,13 +1764,14 @@ static int tipc_sk_enqueue(struct sk_buff_head *inputq, struct sock *sk,
 int tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq)
 {
 	u32 dnode, dport = 0;
-	int err = -TIPC_ERR_NO_PORT;
+	int err;
 	struct sk_buff *skb;
 	struct tipc_sock *tsk;
 	struct tipc_net *tn;
 	struct sock *sk;
 
 	while (skb_queue_len(inputq)) {
+		err = -TIPC_ERR_NO_PORT;
 		skb = NULL;
 		dport = tipc_skb_peek_port(inputq, dport);
 		tsk = tipc_sk_lookup(net, dport);
-- 
1.9.1
