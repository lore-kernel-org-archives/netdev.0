From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 6/6] tipc: fix cleanup at module
	unload
Date: Tue, 24 Jan 2017 13:00:48 +0100
Message-ID: <1485259248-21812-7-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

In tipc_server_stop(), we iterate over the connections with limiting
factor as server's idr_in_use. We ignore the fact that this variable
is decremented in tipc_close_conn(), leading to premature exit.

In this commit, we iterate until the we have no connections left.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: John Thompson <thompa.atl@gmail.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/server.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 04ff441b8065..3cd6402e812c 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -619,14 +619,12 @@ int tipc_server_start(struct tipc_server *s)
 void tipc_server_stop(struct tipc_server *s)
 {
 	struct tipc_conn *con;
-	int total = 0;
 	int id;
 
 	spin_lock_bh(&s->idr_lock);
-	for (id = 0; total < s->idr_in_use; id++) {
+	for (id = 0; s->idr_in_use; id++) {
 		con = idr_find(&s->conn_idr, id);
 		if (con) {
-			total++;
 			spin_unlock_bh(&s->idr_lock);
 			tipc_close_conn(con);
 			spin_lock_bh(&s->idr_lock);
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
