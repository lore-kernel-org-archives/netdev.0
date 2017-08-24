From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/3] tipc: perform skb_linearize() before parsing the inner header
Date: Thu, 24 Aug 2017 16:31:22 +0200
Message-ID: <1503585084-14079-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1503585084-14079-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
        <jon.maloy@ericsson.com>, <maloy@donjonn.com>,
        <ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:50702 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdHXOcD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 10:32:03 -0400
In-Reply-To: <1503585084-14079-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tipc_rcv(), we linearize only the header and usually the packets
are consumed as the nodes permit direct reception. However, if the
skb contains tunnelled message due to fail over or synchronization
we parse it in tipc_node_check_state() without performing
linearization. This will cause link disturbances if the skb was
non linear.

In this commit, we perform linearization for the above messages.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 9b4dcb6a16b5..b113a52f8914 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1557,6 +1557,8 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b)
 
 	/* Check/update node state before receiving */
 	if (unlikely(skb)) {
+		if (unlikely(skb_linearize(skb)))
+			goto discard;
 		tipc_node_write_lock(n);
 		if (tipc_node_check_state(n, skb, bearer_id, &xmitq)) {
 			if (le->link) {
-- 
2.1.4
