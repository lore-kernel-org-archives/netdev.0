From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 4/5] tipc: ensure that first
	packets on link are sent in order
Date: Fri, 15 Apr 2016 13:33:06 -0400
Message-ID: <1460741587-13935-5-git-send-email-jon.maloy@ericsson.com>
References: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1460741587-13935-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In some link establishment scenarios we see that packet #2 may be sent
out before packet #1, forcing the receiver to demand retransmission of
the missing packet. This is harmless, but may cause confusion among
people tracing the packet flow.

Since this is extremely easy to fix, we do so by adding en extra send
call to the bearer immediately after the link has come up.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index ace178f..b00e12c 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -581,8 +581,12 @@ static void __tipc_node_link_up(struct tipc_node *n, int bearer_id,
 static void tipc_node_link_up(struct tipc_node *n, int bearer_id,
 			      struct sk_buff_head *xmitq)
 {
+	struct tipc_media_addr *maddr;
+
 	tipc_node_write_lock(n);
 	__tipc_node_link_up(n, bearer_id, xmitq);
+	maddr = &n->links[bearer_id].maddr;
+	tipc_bearer_xmit(n->net, bearer_id, xmitq, maddr);
 	tipc_node_write_unlock(n);
 }
 
-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
