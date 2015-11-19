From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/8] tipc: small cleanup of
	function tipc_node_check_state()
Date: Thu, 19 Nov 2015 14:30:41 -0500
Message-ID: <1447961447-13025-4-git-send-email-jon.maloy@ericsson.com>
References: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function tipc_node_check_state() contains the core logics
for handling link synchronization and failover. For this reason,
it is important to keep it as comprehensible as possible.

In this commit, we make three small cleanups.

1) If the node is in state SELF_DOWN_PEER_LEAVING and the received
   packet confirms that the peer has lost contact, there will be no
   further action in this function. To make this clearer, we return
   from the function directly after the state change.

2) Since commit 0f8b8e28fb3241f9fd ("tipc: eliminate risk of stalled
   link synchronization") only the logically first TUNNEL_PROTO/SYNCH
   packet can alter the link state and set the synch point,
   independently of arrival order. Hence, there is not any longer any
   need to adjust the synch value in case such packets arrive in
   disorder. We remove this adjustment.

3) It is the intention that any message arriving on any of the links
   may trig a check for and possible termination of a node SYNCH state.
   A redundant and unnoticed check for tipc_link_is_synching() obviously
   beats this purpose, with the effect that only packets arriving on the
   synching link may currently end the synch state. We remove this check.
   This change will further shorten the synchronization period between
   parallel links.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 20cddec..7756804 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1187,6 +1187,7 @@ static bool tipc_node_check_state(struct tipc_node *n, struct sk_buff *skb,
 		if (msg_peer_node_is_up(hdr))
 			return false;
 		tipc_node_fsm_evt(n, PEER_LOST_CONTACT_EVT);
+		return true;
 	}
 
 	/* Ignore duplicate packets */
@@ -1232,12 +1233,10 @@ static bool tipc_node_check_state(struct tipc_node *n, struct sk_buff *skb,
 			tipc_link_fsm_evt(l, LINK_SYNCH_BEGIN_EVT);
 			tipc_node_fsm_evt(n, NODE_SYNCH_BEGIN_EVT);
 		}
-		if (less(syncpt, n->sync_point))
-			n->sync_point = syncpt;
 	}
 
 	/* Open tunnel link when parallel link reaches synch point */
-	if ((n->state == NODE_SYNCHING) && tipc_link_is_synching(l)) {
+	if (n->state == NODE_SYNCHING) {
 		if (tipc_link_is_synching(l)) {
 			tnl = l;
 		} else {
-- 
1.9.1


------------------------------------------------------------------------------
