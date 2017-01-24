From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 3/6] tipc: fix connection refcount
	error
Date: Tue, 24 Jan 2017 13:00:45 +0100
Message-ID: <1485259248-21812-4-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Until now, the generic server framework maintains the connection
id's per subscriber in server's conn_idr. At tipc_close_conn, we
remove the connection id from the server list, but the connection is
valid until we call the refcount cleanup. Hence we have a window
where the server allocates the same connection to an new subscriber
leading to inconsistent reference count. We have another refcount
warning we grab the refcount in tipc_conn_lookup() for connections
with flag with CF_CONNECTED not set. This usually occurs at shutdown
when the we stop the topology server and withdraw TIPC_CFG_SRV
publication thereby triggering a withdraw message to subscribers.

In this commit, we:
1. remove the connection from the server list at recount cleanup.
2. grab the refcount for a connection only if CF_CONNECTED is set.

Tested-by: John Thompson <thompa.atl@gmail.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/server.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 215849ce453d..2e803601aa99 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -91,7 +91,8 @@ static void tipc_sock_release(struct tipc_conn *con);
 static void tipc_conn_kref_release(struct kref *kref)
 {
 	struct tipc_conn *con = container_of(kref, struct tipc_conn, kref);
-	struct sockaddr_tipc *saddr = con->server->saddr;
+	struct tipc_server *s = con->server;
+	struct sockaddr_tipc *saddr = s->saddr;
 	struct socket *sock = con->sock;
 	struct sock *sk;
 
@@ -106,6 +107,11 @@ static void tipc_conn_kref_release(struct kref *kref)
 		tipc_sock_release(con);
 		sock_release(sock);
 		con->sock = NULL;
+
+		spin_lock_bh(&s->idr_lock);
+		idr_remove(&s->conn_idr, con->conid);
+		s->idr_in_use--;
+		spin_unlock_bh(&s->idr_lock);
 	}
 
 	tipc_clean_outqueues(con);
@@ -128,8 +134,10 @@ static struct tipc_conn *tipc_conn_lookup(struct tipc_server *s, int conid)
 
 	spin_lock_bh(&s->idr_lock);
 	con = idr_find(&s->conn_idr, conid);
-	if (con)
+	if (con && test_bit(CF_CONNECTED, &con->flags))
 		conn_get(con);
+	else
+		con = NULL;
 	spin_unlock_bh(&s->idr_lock);
 	return con;
 }
@@ -198,15 +206,8 @@ static void tipc_sock_release(struct tipc_conn *con)
 
 static void tipc_close_conn(struct tipc_conn *con)
 {
-	struct tipc_server *s = con->server;
-
 	if (test_and_clear_bit(CF_CONNECTED, &con->flags)) {
 
-		spin_lock_bh(&s->idr_lock);
-		idr_remove(&s->conn_idr, con->conid);
-		s->idr_in_use--;
-		spin_unlock_bh(&s->idr_lock);
-
 		/* We shouldn't flush pending works as we may be in the
 		 * thread. In fact the races with pending rx/tx work structs
 		 * are harmless for us here as we have already deleted this
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
