From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 5/6] tipc: ignore requests when the
	connection state is not CONNECTED
Date: Tue, 24 Jan 2017 13:00:47 +0100
Message-ID: <1485259248-21812-6-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1485259248-21812-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1485259248-21812-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In tipc_conn_sendmsg(), we first queue the request to the outqueue
followed by the connection state check. If the connection is not
connected, we should not queue this message.

In this commit, we reject the messages if the connection state is
not CF_CONNECTED.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: John Thompson <thompa.atl@gmail.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/server.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 826cde2c401e..04ff441b8065 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -453,6 +453,11 @@ int tipc_conn_sendmsg(struct tipc_server *s, int conid,
 	if (!con)
 		return -EINVAL;
 
+	if (!test_bit(CF_CONNECTED, &con->flags)) {
+		conn_put(con);
+		return 0;
+	}
+
 	e = tipc_alloc_entry(data, len);
 	if (!e) {
 		conn_put(con);
@@ -466,12 +471,8 @@ int tipc_conn_sendmsg(struct tipc_server *s, int conid,
 	list_add_tail(&e->list, &con->outqueue);
 	spin_unlock_bh(&con->outqueue_lock);
 
-	if (test_bit(CF_CONNECTED, &con->flags)) {
-		if (!queue_work(s->send_wq, &con->swork))
-			conn_put(con);
-	} else {
+	if (!queue_work(s->send_wq, &con->swork))
 		conn_put(con);
-	}
 	return 0;
 }
 
@@ -495,7 +496,7 @@ static void tipc_send_to_sock(struct tipc_conn *con)
 	int ret;
 
 	spin_lock_bh(&con->outqueue_lock);
-	while (1) {
+	while (test_bit(CF_CONNECTED, &con->flags)) {
 		e = list_entry(con->outqueue.next, struct outqueue_entry,
 			       list);
 		if ((struct list_head *) e == &con->outqueue)
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
