From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: fix a link reset issue due
	to retransmission failures
Date: Wed, 25 Mar 2015 18:09:40 +0800
Message-ID: <1427278181-29389-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
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

When a node joins a cluster while we are transmitting a fragment
stream over the broadcast link, it's missing the preceding fragments
needed to build a meaningful message. As a result, the node has to
drop it. However, as the fragment message is not acknowledged to
its sender before it's dropped, it accidentally causes link reset
of retransmission failure on the node.

Reported-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bcast.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 403aee7..7935553 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -523,11 +523,13 @@ receive:
 			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
-			tipc_buf_append(&node->bclink.reasm_buf, &buf);
-			if (unlikely(!buf && !node->bclink.reasm_buf))
-				goto unlock;
 			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
+			tipc_buf_append(&node->bclink.reasm_buf, &buf);
+			if (unlikely(!buf && !node->bclink.reasm_buf)) {
+				tipc_bclink_unlock(net);
+				goto unlock;
+			}
 			bcl->stats.recv_fragments++;
 			if (buf) {
 				bcl->stats.recv_fragmented++;
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
