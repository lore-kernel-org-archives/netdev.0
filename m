From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH ericsson v2 1/1] tipc: remove premature ESTABLISH FSM event at link synchronization
Date: Tue, 8 Aug 2017 22:18:17 +0200
Message-ID: <1502223497-3074-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:48821 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752232AbdHHUd3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 16:33:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a link between two nodes come up, both endpoints will initially
send out a STATE message to the peer, to increase the probability that
the peer endpoint also is up when the first traffic message arrives.
Thereafter, if the establishing link is the second link between two
nodes, this first "traffic" message is a TUNNEL_PROTOCOL/SYNCH message,
helping the peer to perform initial synchronization between the two
links.

However, the initial STATE message may be lost, in which case the SYNCH
message will be the first one arriving at the peer. This should also
work, as the SYNCH message itself will be used to take up the link
endpoint before  initializing synchronization.

Unfortunately the code for this case is broken. Currently, the link is
brought up through a tipc_link_fsm_evt(ESTABLISHED) when a SYNCH
arrives, whereupon __tipc_node_link_up() is called to distribute the
link slots and take the link into traffic. But, __tipc_node_link_up() is
itself starting with a test for whether the link is up, and if true,
returns without action. Clearly, the tipc_link_fsm_evt(ESTABLISHED) call
is unnecessary, since tipc_node_link_up() is itself issuing such an
event, but also harmful, since it inhibits tipc_node_link_up() to
perform the test of its tasks, and the link endpoint in question hence
is never taken into traffic.

This problem has been exposed when we set up dual links between pre-
and post-4.4 kernels, because the former ones don't send out the
initial STATE message described above.

We fix this by removing the unnecessary event call.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index aeef801..9b4dcb6 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1455,10 +1455,8 @@ static bool tipc_node_check_state(struct tipc_node *n, struct sk_buff *skb,
 	/* Initiate synch mode if applicable */
 	if ((usr == TUNNEL_PROTOCOL) && (mtyp == SYNCH_MSG) && (oseqno == 1)) {
 		syncpt = iseqno + exp_pkts - 1;
-		if (!tipc_link_is_up(l)) {
-			tipc_link_fsm_evt(l, LINK_ESTABLISH_EVT);
+		if (!tipc_link_is_up(l))
 			__tipc_node_link_up(n, bearer_id, xmitq);
-		}
 		if (n->state == SELF_UP_PEER_UP) {
 			n->sync_point = syncpt;
 			tipc_link_fsm_evt(l, LINK_SYNCH_BEGIN_EVT);
-- 
2.1.4
