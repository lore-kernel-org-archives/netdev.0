From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net 1/1] tipc: avoid inheriting msg_non_seq flag when message is returned
Date: Mon, 14 Aug 2017 18:28:49 +0200
Message-ID: <1502728129-10537-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:53139 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752589AbdHNQaJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 12:30:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the function msg_reverse(), we reverse the header while trying to
reuse the original buffer whenever possible. Those rejected/returned
messages are always transmitted as unicast, but the msg_non_seq field
is not explicitly set to zero as it should be.

We have seen cases where multicast senders set the message type to
"NOT dest_droppable", meaning that a multicast message shorter than
one MTU will be returned, e.g., during receive buffer overflow, by
reusing the original buffer. This has the effect that even the
'msg_non_seq' field is inadvertently inherited by the rejected message,
although it is now sent as a unicast message. This again leads the
receiving unicast link endpoint to steer the packet toward the broadcast
link receive function, where it is dropped. The affected unicast link is
thereafter (after 100 failed retransmissions) declared 'stale' and
reset.

We fix this by unconditionally setting the 'msg_non_seq' flag to zero
for all rejected/returned messages.

Reported-by: Canh Duc Luu <canh.d.luu@dektech.com.au>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index ab30876..dcd90e6 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -513,6 +513,7 @@ bool tipc_msg_reverse(u32 own_node,  struct sk_buff **skb, int err)
 
 	/* Now reverse the concerned fields */
 	msg_set_errcode(hdr, err);
+	msg_set_non_seq(hdr, 0);
 	msg_set_origport(hdr, msg_destport(&ohdr));
 	msg_set_destport(hdr, msg_origport(&ohdr));
 	msg_set_destnode(hdr, msg_prevnode(&ohdr));
-- 
2.1.4
