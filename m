From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 4/6] tipc: fix nametbl_lock soft
	lockup at module exit
Date: Tue, 24 Jan 2017 13:00:46 +0100
Message-ID: <1485259248-21812-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
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

Commit 333f796235a527 ("tipc: fix a race condition leading to
subscriber refcnt bug") reveals a soft lockup while acquiring
nametbl_lock.

Before commit 333f796235a527, we call tipc_conn_shutdown() from
tipc_close_conn() in the context of tipc_topsrv_stop(). In that
context, we are allowed to grab the nametbl_lock.

Commit 333f796235a527, moved tipc_conn_release (renamed from
tipc_conn_shutdown) to the connection refcount cleanup. This allows
either tipc_nametbl_withdraw() or tipc_topsrv_stop() to the cleanup.

Since tipc_exit_net() first calls tipc_topsrv_stop() and then
tipc_nametble_withdraw() increases the chances for the later to
perform the connection cleanup.

The soft lockup occurs in the call chain of tipc_nametbl_withdraw(),
when it performs the tipc_conn_kref_release() as it tries to grab
nametbl_lock again while holding it already.
tipc_nametbl_withdraw() grabs nametbl_lock
  tipc_nametbl_remove_publ()
    tipc_subscrp_report_overlap()
      tipc_subscrp_send_event()
        tipc_conn_sendmsg()
          << if (con->flags != CF_CONNECTED) we do conn_put(),
             triggering the cleanup as refcount=0. >>
          tipc_conn_kref_release
            tipc_sock_release
              tipc_conn_release
                tipc_subscrb_delete
                  tipc_subscrp_delete
                    tipc_nametbl_unsubscribe << Soft Lockup >>

The previous changes in this series fixes the race conditions fixed
by commit 333f796235a527. Hence we can now revert the commit.

Fixes: 333f796235a52727 ("tipc: fix a race condition leading to subscriber refcnt bug")
Reported-and-Tested-by: John Thompson <thompa.atl@gmail.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/server.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 2e803601aa99..826cde2c401e 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -86,7 +86,6 @@ struct outqueue_entry {
 static void tipc_recv_work(struct work_struct *work);
 static void tipc_send_work(struct work_struct *work);
 static void tipc_clean_outqueues(struct tipc_conn *con);
-static void tipc_sock_release(struct tipc_conn *con);
 
 static void tipc_conn_kref_release(struct kref *kref)
 {
@@ -104,7 +103,6 @@ static void tipc_conn_kref_release(struct kref *kref)
 		}
 		saddr->scope = -TIPC_NODE_SCOPE;
 		kernel_bind(sock, (struct sockaddr *)saddr, sizeof(*saddr));
-		tipc_sock_release(con);
 		sock_release(sock);
 		con->sock = NULL;
 
@@ -194,19 +192,15 @@ static void tipc_unregister_callbacks(struct tipc_conn *con)
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
-static void tipc_sock_release(struct tipc_conn *con)
+static void tipc_close_conn(struct tipc_conn *con)
 {
 	struct tipc_server *s = con->server;
 
-	if (con->conid)
-		s->tipc_conn_release(con->conid, con->usr_data);
-
-	tipc_unregister_callbacks(con);
-}
-
-static void tipc_close_conn(struct tipc_conn *con)
-{
 	if (test_and_clear_bit(CF_CONNECTED, &con->flags)) {
+		tipc_unregister_callbacks(con);
+
+		if (con->conid)
+			s->tipc_conn_release(con->conid, con->usr_data);
 
 		/* We shouldn't flush pending works as we may be in the
 		 * thread. In fact the races with pending rx/tx work structs
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, SlashDot.org! http://sdm.link/slashdot
