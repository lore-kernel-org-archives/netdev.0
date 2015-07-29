From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix bug in broadcast synch message create function
Date: Wed, 29 Jul 2015 18:28:01 -0400
Message-ID: <1438208881-30453-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:20014 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754579AbbG2W2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:28:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit d999297c3dbbe7fdd832f7fa4ec84301e170b3e6
("tipc: reduce locking scope during packet reception") we introduced
a new function tipc_build_bcast_sync_msg(), which carries initial
synchronization data between two nodes at first contact and at
re-contact. In this function, we missed to add synchronization data,
with the effect that the broadcast link endpoints will fail to
synchronize correctly at re-contact between a running and a restarted
node. All other cases work as intended.

With this commit, we fix this bug.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b63d573..cc40aa6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -294,11 +294,14 @@ static void tipc_link_build_bcast_sync_msg(struct tipc_link *l,
 {
 	struct sk_buff *skb;
 	struct sk_buff_head list;
+	u16 last_sent;
 
 	skb = tipc_msg_create(BCAST_PROTOCOL, STATE_MSG, INT_H_SIZE,
 			      0, l->addr, link_own_addr(l), 0, 0, 0);
 	if (!skb)
 		return;
+	last_sent = tipc_bclink_get_last_sent(l->owner->net);
+	msg_set_last_bcast(buf_msg(skb), last_sent);
 	__skb_queue_head_init(&list);
 	__skb_queue_tail(&list, skb);
 	tipc_link_xmit(l, &list, xmitq);
-- 
1.9.1
