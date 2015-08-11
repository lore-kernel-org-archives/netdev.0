From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 2/6] dlm: fix race while closing connections
Date: Tue, 11 Aug 2015 19:22:21 -0300
Message-ID: <743f99754d27595fa5322d72d524c507314676e2.1439330654.git.marcelo.leitner@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, tan.hu@zte.com.cn
To: cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932928AbbHKWWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 18:22:43 -0400
In-Reply-To: <cover.1439330654.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a connection have issues DLM may need to close it.  Therefore we
should also cancel pending workqueues for such connection at that time,
and not just when dlm is not willing to use this connection anymore.

Also, if we don't clear CF_CONNECT_PENDING flag, the error handling
routines won't be able to re-connect as lowcomms_connect_sock() will
check for it.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/dlm/lowcomms.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index bc04f5e3af7ac5fe107a7a26555777364de8bc15..749deb3b69b2932fb18e7ae70c06e4ced15bd9b6 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -514,17 +514,24 @@ static void make_sockaddr(struct sockaddr_storage *saddr, uint16_t port,
 }
 
 /* Close a remote connection and tidy up */
-static void close_connection(struct connection *con, bool and_other)
+static void close_connection(struct connection *con, bool and_other,
+			     bool tx, bool rx)
 {
-	mutex_lock(&con->sock_mutex);
+	clear_bit(CF_CONNECT_PENDING, &con->flags);
+	clear_bit(CF_WRITE_PENDING, &con->flags);
+	if (tx && cancel_work_sync(&con->swork))
+		log_print("canceled swork for node %d", con->nodeid);
+	if (rx && cancel_work_sync(&con->rwork))
+		log_print("canceled rwork for node %d", con->nodeid);
 
+	mutex_lock(&con->sock_mutex);
 	if (con->sock) {
 		sock_release(con->sock);
 		con->sock = NULL;
 	}
 	if (con->othercon && and_other) {
 		/* Will only re-enter once. */
-		close_connection(con->othercon, false);
+		close_connection(con->othercon, false, true, true);
 	}
 	if (con->rx_page) {
 		__free_page(con->rx_page);
@@ -902,7 +909,7 @@ out_resched:
 out_close:
 	mutex_unlock(&con->sock_mutex);
 	if (ret != -EAGAIN) {
-		close_connection(con, false);
+		close_connection(con, false, true, false);
 		/* Reconnect when there is something to send */
 	}
 	/* Don't return success if we really got EOF */
@@ -1622,7 +1629,7 @@ out:
 
 send_error:
 	mutex_unlock(&con->sock_mutex);
-	close_connection(con, false);
+	close_connection(con, false, false, true);
 	lowcomms_connect_sock(con);
 	return;
 
@@ -1654,15 +1661,9 @@ int dlm_lowcomms_close(int nodeid)
 	log_print("closing connection to node %d", nodeid);
 	con = nodeid2con(nodeid, 0);
 	if (con) {
-		clear_bit(CF_CONNECT_PENDING, &con->flags);
-		clear_bit(CF_WRITE_PENDING, &con->flags);
 		set_bit(CF_CLOSE, &con->flags);
-		if (cancel_work_sync(&con->swork))
-			log_print("canceled swork for node %d", nodeid);
-		if (cancel_work_sync(&con->rwork))
-			log_print("canceled rwork for node %d", nodeid);
+		close_connection(con, true, true, true);
 		clean_one_writequeue(con);
-		close_connection(con, true);
 	}
 
 	spin_lock(&dlm_node_addrs_spin);
@@ -1745,7 +1746,7 @@ static void stop_conn(struct connection *con)
 
 static void free_conn(struct connection *con)
 {
-	close_connection(con, true);
+	close_connection(con, true, true, true);
 	if (con->othercon)
 		kmem_cache_free(con_cache, con->othercon);
 	hlist_del(&con->list);
@@ -1816,7 +1817,7 @@ fail_unlisten:
 	dlm_allow_conn = 0;
 	con = nodeid2con(0,0);
 	if (con) {
-		close_connection(con, false);
+		close_connection(con, false, true, true);
 		kmem_cache_free(con_cache, con);
 	}
 fail_destroy:
-- 
2.4.3
