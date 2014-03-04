From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 2/6] tipc: fix connection
	refcount leak
Date: Tue, 4 Mar 2014 09:05:39 +0100
Message-ID: <1393920343-4134-3-git-send-email-erik.hugne@ericsson.com>
References: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>

When tipc_conn_sendmsg() calls tipc_conn_lookup() to query a
connection instance, its reference count value is increased if
it's found. But subsequently if it's found that the connection is
closed, the work of sending message is not queued into its server
send workqueue, and the connection reference count is not decreased.
This will cause a reference count leak. To reproduce this problem,
an application would need to open and closes topology server
connections with high intensity.

We fix this by immediately decrementing the connection reference
count if a send fails due to the connection being closed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/server.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index cee66cf..ebf6581 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -427,10 +427,12 @@ int tipc_conn_sendmsg(struct tipc_server *s, int conid,
 	list_add_tail(&e->list, &con->outqueue);
 	spin_unlock_bh(&con->outqueue_lock);
 
-	if (test_bit(CF_CONNECTED, &con->flags))
+	if (test_bit(CF_CONNECTED, &con->flags)) {
 		if (!queue_work(s->send_wq, &con->swork))
 			conn_put(con);
-
+	} else {
+		conn_put(con);
+	}
 	return 0;
 }
 
-- 
1.8.3.2


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
