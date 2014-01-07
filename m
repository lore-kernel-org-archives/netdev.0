From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/4] tipc: remove
	'has_redundant_link' flag from STATE link protocol messages
Date: Tue,  7 Jan 2014 17:02:42 -0500
Message-ID: <1389132164-32451-3-git-send-email-jon.maloy@ericsson.com>
References: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The flag 'has_redundant_link' is defined only in RESET and ACTIVATE
protocol messages. Due to an ambiguity in the protocol specification it
is currently also transferred in STATE messages. Its value is used to
initialize a link state variable, 'permit_changeover', which is used
to inhibit futile link failover attempts when it is known that the
peer node has no working links at the moment, although the local node
may still think it has one.

The fact that 'has_redundant_link' incorrectly is read from STATE
messages has the effect that 'permit_changeover' sometimes gets a wrong
value, and permanently blocks any links from being re-established. Such
failures can only occur in in dual-link systems, and are extremely rare.
This bug seems to have always been present in the code.

Furthermore, since commit b4b5610223f17790419b03eaa962b0e3ecf930d7
("tipc: Ensure both nodes recognize loss of contact between them"),
the 'permit_changeover' field serves no purpose any more. The task of
enforcing 'lost contact' cycles at both peer endpoints is now taken
by a new mechanism, using the flags WAIT_NODE_DOWN and WAIT_PEER_DOWN
in struct tipc_node to abort unnecessary failover attempts.

We therefore remove the 'has_redundant_link' flag from STATE messages,
as well as the now redundant 'permit_changeover' variable.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   10 +---------
 net/tipc/node.h |    2 --
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index bb48b96..9fb0f6b 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -438,8 +438,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	tipc_node_link_down(l_ptr->owner, l_ptr);
 	tipc_bearer_remove_dest(l_ptr->b_ptr, l_ptr->addr);
 
-	if (was_active_link && tipc_node_active_links(l_ptr->owner) &&
-	    l_ptr->owner->permit_changeover) {
+	if (was_active_link && tipc_node_active_links(l_ptr->owner)) {
 		l_ptr->reset_checkpoint = checkpoint;
 		l_ptr->exp_msg_count = START_CHANGEOVER;
 	}
@@ -1838,8 +1837,6 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		if (tipc_own_addr > msg_prevnode(msg))
 			l_ptr->b_ptr->net_plane = msg_net_plane(msg);
 
-	l_ptr->owner->permit_changeover = msg_redundant_link(msg);
-
 	switch (msg_type(msg)) {
 
 	case RESET_MSG:
@@ -2001,11 +1998,6 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	if (!tunnel)
 		return;
 
-	if (!l_ptr->owner->permit_changeover) {
-		pr_warn("%speer did not permit changeover\n", link_co_err);
-		return;
-	}
-
 	tipc_msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
 		 ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
diff --git a/net/tipc/node.h b/net/tipc/node.h
index d4bb654..63e2e8e 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -64,7 +64,6 @@
  * @working_links: number of working links to node (both active and standby)
  * @block_setup: bit mask of conditions preventing link establishment to node
  * @link_cnt: number of links to node
- * @permit_changeover: non-zero if node has redundant links to this system
  * @signature: node instance identifier
  * @bclink: broadcast-related info
  *    @acked: sequence # of last outbound b'cast message acknowledged by node
@@ -89,7 +88,6 @@ struct tipc_node {
 	int link_cnt;
 	int working_links;
 	int block_setup;
-	int permit_changeover;
 	u32 signature;
 	struct {
 		u32 acked;
-- 
1.7.9.5


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
