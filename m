From: <erik.hugne@ericsson.com>
Subject: [PATCH v2] tipc: don't reject messages if reversal fails
Date: Fri, 10 Apr 2015 13:58:18 +0200
Message-ID: <1428667098-9504-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <richard.alpe@ericsson.com>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:56603 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755605AbbDJMCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 08:02:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When we fail to deliver a message to a socket, it is subject to
message reversal. If the call to tipc_msg_reverse fails, we are
passing dnode uninitialized to tipc_link_xmit_skb which causes the
packet to either be dropped, or sent out to a random link. In the
worst case this leads to a link reset.
We fix this by only transmitting the message if reversal succeded.
Also, the redundant check for 'err' is removed, because if the message
was not consumed, it will always be set.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
v2: err check fix according to comments from Billie Alsup

 net/tipc/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ee90d74..d215f73 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1701,7 +1701,7 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 			atomic_add(truesize, dcnt);
 		return 0;
 	}
-	if (!err || tipc_msg_reverse(tsk_own_node(tsk), skb, &dnode, -err))
+	if (tipc_msg_reverse(tsk_own_node(tsk), skb, &dnode, -err))
 		tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
 	return 0;
 }
-- 
2.1.4
