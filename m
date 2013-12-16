From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: correctly unlink packets from deferred queue
Date: Mon, 16 Dec 2013 10:46:25 +0100
Message-ID: <1387187185-6914-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg20.ericsson.net ([193.180.251.50]:50537 "EHLO
	sessmg20.mgmt.ericsson.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752515Ab3LPJqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 04:46:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When we pull a packet from the deferred queue, the next
pointer for the current packet being processed might still
refer to deferred packets. This is incorrect, and will
lead to an oops if the last fragment have once been put on
the deferred queue, and at least one packet have been
deferred after this fragment. The result of this is that
the fragment chain linked together with the defer-queue.

We fix this by clearing the next pointer for the current
packet being processed.

[...] general protection fault: 0000
[...]
[...] ? trace_hardirqs_on+0xd/0x10
[...] tipc_link_recv_fragment+0xd1/0x1b0 [tipc]
[...] tipc_recv_msg+0x4e4/0x920 [tipc]
[...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
[...] tipc_l2_rcv_msg+0xcc/0x250 [tipc]
[...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
[...] __netif_receive_skb_core+0x80b/0xd00
[...] ? __netif_receive_skb_core+0x144/0xd00
[...] __netif_receive_skb+0x26/0x70
[...] netif_receive_skb+0x2d/0x200

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reported-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 3d73144..447e2c4 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1444,6 +1444,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		int type;
 
 		head = head->next;
+		buf->next = NULL;
 
 		/* Ensure bearer is still enabled */
 		if (unlikely(!b_ptr->active))
-- 
1.7.9.5
