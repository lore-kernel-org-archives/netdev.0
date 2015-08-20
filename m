From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/3] tipc: eliminate risk of premature link setup during failover
Date: Thu, 20 Aug 2015 02:12:54 -0400
Message-ID: <1440051176-32672-2-git-send-email-jon.maloy@ericsson.com>
References: <1440051176-32672-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:44748 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752287AbbHTGNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 02:13:35 -0400
In-Reply-To: <1440051176-32672-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a link goes down, and there is still a working link towards its
destination node, a failover is initiated, and the failed link is not
allowed to re-establish until that procedure is finished. To ensure
this, the concerned link endpoints are set to state LINK_FAILINGOVER,
and the node endpoints to NODE_FAILINGOVER during the failover period.

However, if the link reset is due to a disabled bearer, the corres-
ponding link endpoint is deleted, and only the node endpoint knows
about the ongoing failover. Now, if the disabled bearer is re-enabled
during the failover period, the discovery mechanism may create a new
link endpoint that is ready to be established, despite that this is not
permitted. This situation may cause both the ongoing failover and any
subsequent link synchronization to fail.

In this commit, we ensure that a newly created link goes directly to
state LINK_FAILINGOVER if the corresponding node state is
NODE_FAILINGOVER. This eliminates the problem described above.

Furthermore, we tighten the criteria for which packets are allowed
to end a failover state in the function tipc_node_check_state().
By checking that the receiving link is up and running, instead of just
checking that it is not in failover mode, we eliminate the risk that
protocol packets from the re-created link may cause the failover to
be prematurely terminated.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 7c19164..004834b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -565,6 +565,8 @@ void tipc_node_check_dest(struct net *net, u32 onode,
 			goto exit;
 		}
 		tipc_link_reset(l);
+		if (n->state == NODE_FAILINGOVER)
+			tipc_link_fsm_evt(l, LINK_FAILOVER_BEGIN_EVT);
 		le->link = l;
 		n->link_cnt++;
 		tipc_node_calculate_timer(n, l);
@@ -1129,7 +1131,7 @@ static bool tipc_node_check_state(struct tipc_node *n, struct sk_buff *skb,
 	}
 
 	/* Open parallel link when tunnel link reaches synch point */
-	if ((n->state == NODE_FAILINGOVER) && !tipc_link_is_failingover(l)) {
+	if ((n->state == NODE_FAILINGOVER) && tipc_link_is_up(l)) {
 		if (!more(rcv_nxt, n->sync_point))
 			return true;
 		tipc_node_fsm_evt(n, NODE_FAILOVER_END_EVT);
-- 
1.9.1
