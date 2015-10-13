From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: eliminate risk of
	stalled link synchronization
Date: Tue, 13 Oct 2015 11:59:14 -0400
Message-ID: <1444751954-32339-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In commit 6e498158a827 ("tipc: move link synch and failover to link aggregation level")
we introduced a new mechanism for performing link failover and
synchronization. We have now detected a bug in this mechanism.

During link synchronization we use the arrival of any packet on
the tunnel link to trig a check for whether it has reached the
synchronization point or not. This has turned out to be too
permissive, since it may cause an arriving non-last SYNCH packet to
end the synch state, just to see the next SYNCH packet initiate a
new synch state with a new, higher synch point. This is not fatal,
but should be avoided, because it may significantly extend the
synchronization period, while at the same time we are not allowed
to send NACKs if packets are lost. In the worst case, a low-traffic
user may see its traffic stall until a LINK_PROTOCOL state message
trigs the link to leave synchronization state.

At the same time, LINK_PROTOCOL packets which happen to have a (non-
valid) sequence number lower than the tunnel link's rcv_nxt value will
be consistently dropped, and will never be able to resolve the situation
described above.

We fix this by exempting LINK_PROTOCOL packets from the sequence number
check, as they should be. We also reduce (but don't completely
eliminate) the risk of entering multiple synchronization states by only
allowing the (logically) first SYNCH packet to initiate a synchronization
state. This works independently of actual packet arrival order.

Fixes: commit 6e498158a827 ("tipc: move link synch and failover to link aggregation level")

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/node.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 703875f..2c32a83 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1116,7 +1116,7 @@ static bool tipc_node_check_state(struct tipc_node *n, struct sk_buff *skb,
 	}
 
 	/* Ignore duplicate packets */
-	if (less(oseqno, rcv_nxt))
+	if ((usr != LINK_PROTOCOL) && less(oseqno, rcv_nxt))
 		return true;
 
 	/* Initiate or update failover mode if applicable */
@@ -1146,8 +1146,8 @@ static bool tipc_node_check_state(struct tipc_node *n, struct sk_buff *skb,
 	if (!pl || !tipc_link_is_up(pl))
 		return true;
 
-	/* Initiate or update synch mode if applicable */
-	if ((usr == TUNNEL_PROTOCOL) && (mtyp == SYNCH_MSG)) {
+	/* Initiate synch mode if applicable */
+	if ((usr == TUNNEL_PROTOCOL) && (mtyp == SYNCH_MSG) && (oseqno == 1)) {
 		syncpt = iseqno + exp_pkts - 1;
 		if (!tipc_link_is_up(l)) {
 			tipc_link_fsm_evt(l, LINK_ESTABLISH_EVT);
-- 
1.9.1


------------------------------------------------------------------------------
