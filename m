From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/3] tipc: don't reroute message
	fragments
Date: Sat, 26 Oct 2013 14:41:01 -0400
Message-ID: <1382812863-23571-2-git-send-email-jon.maloy@ericsson.com>
References: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

When a message fragment is received in a broadcast or unicast link,
the reception code will append the fragment payload to a big reassembly
buffer through a call to the function tipc_recv_fragm(). However, after
the return of that call, the logics goes on and passes the fragment
buffer to the function tipc_net_route_msg(), which will simply drop it.
This behavior is a remnant from the now obsolete multi-cluster
functionality, and has no relevance in the current code base.

Although currently harmless, this unnecessary call would be fatal
after applying the next patch in this series, which introduces
a completely new defragmentation algorithm. So we change the code
to eliminate the redundant call.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |    6 ++++--
 net/tipc/link.c  |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 716de1a..766a6eb 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -487,11 +487,13 @@ receive:
 			spin_lock_bh(&bc_lock);
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_fragments++;
-			if (ret > 0)
+			if (ret > 0) {
 				bcl->stats.recv_fragmented++;
+				spin_unlock_bh(&bc_lock);
+				goto receive;
+			}
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
-			tipc_net_route_msg(buf);
 		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
 			spin_lock_bh(&bc_lock);
 			bclink_accept_pkt(node, seqno);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index e8153f6..dfa29c8 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1638,7 +1638,7 @@ deliver:
 					}
 					if (ret == -1)
 						l_ptr->next_in_no--;
-					break;
+					continue;
 				case CHANGEOVER_PROTOCOL:
 					type = msg_type(msg);
 					if (link_recv_changeover_msg(&l_ptr,
-- 
1.7.9.5


------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60135991&iu=/4140/ostg.clktrk
