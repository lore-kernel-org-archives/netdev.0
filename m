From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 1/6] tipc: allow connection
	shutdown callback to be invoked in advance
Date: Tue, 4 Mar 2014 09:05:38 +0100
Message-ID: <1393920343-4134-2-git-send-email-erik.hugne@ericsson.com>
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

Currently connection shutdown callback function is called when
connection instance is released in tipc_conn_kref_release(), and
receiving packets and sending packets are running in different
threads. Even if connection is closed by the thread of receiving
packets, its shutdown callback may not be called immediately as
the connection reference count is non-zero at that moment. So,
although the connection is shut down by the thread of receiving
packets, the thread of sending packets doesn't know it. Before
its shutdown callback is invoked to tell the sending thread its
connection has been closed, the sending thread may deliver
messages by tipc_conn_sendmsg(), this is why the following error
information appears:

"Sending subscription event failed, no memory"

To eliminate it, allow connection shutdown callback function to
be called before connection id is removed in tipc_close_conn(),
which makes the sending thread know the truth in time that its
socket is closed so that it doesn't send message to it.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c | 2 +-
 net/tipc/server.c | 8 +++-----
 net/tipc/subscr.c | 2 +-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index c301a9a..7dd2dd1 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -401,7 +401,7 @@ static void cfg_conn_msg_event(int conid, struct sockaddr_tipc *addr,
 
 		ret = tipc_conn_sendmsg(&cfgsrv, conid, addr, rep_buf->data,
 					rep_buf->len);
-		if (ret < 0)
+		if (ret == -ENOMEM)
 			pr_err("Sending cfg reply message failed, no memory\n");
 
 		kfree_skb(rep_buf);
diff --git a/net/tipc/server.c b/net/tipc/server.c
index b635ca3..cee66cf 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -87,7 +87,6 @@ static void tipc_clean_outqueues(struct tipc_conn *con);
 static void tipc_conn_kref_release(struct kref *kref)
 {
 	struct tipc_conn *con = container_of(kref, struct tipc_conn, kref);
-	struct tipc_server *s = con->server;
 
 	if (con->sock) {
 		tipc_sock_release_local(con->sock);
@@ -95,10 +94,6 @@ static void tipc_conn_kref_release(struct kref *kref)
 	}
 
 	tipc_clean_outqueues(con);
-
-	if (con->conid)
-		s->tipc_conn_shutdown(con->conid, con->usr_data);
-
 	kfree(con);
 }
 
@@ -181,6 +176,9 @@ static void tipc_close_conn(struct tipc_conn *con)
 	struct tipc_server *s = con->server;
 
 	if (test_and_clear_bit(CF_CONNECTED, &con->flags)) {
+		if (con->conid)
+			s->tipc_conn_shutdown(con->conid, con->usr_data);
+
 		spin_lock_bh(&s->idr_lock);
 		idr_remove(&s->conn_idr, con->conid);
 		s->idr_in_use--;
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 7cb0bd5..a6a6a26 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -108,7 +108,7 @@ static void subscr_send_event(struct tipc_subscription *sub, u32 found_lower,
 	sub->evt.port.node = htohl(node, sub->swap);
 	ret = tipc_conn_sendmsg(&topsrv, subscriber->conid, NULL,
 				msg_sect.iov_base, msg_sect.iov_len);
-	if (ret < 0)
+	if (ret == -ENOMEM)
 		pr_err("Sending subscription event failed, no memory\n");
 }
 
-- 
1.8.3.2


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
