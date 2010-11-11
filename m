From: David Miller <davem@davemloft.net>
Subject: [PATCH] dlm: Handle application limited situations properly.
Date: Wed, 10 Nov 2010 21:56:39 -0800 (PST)
Message-ID: <20101110.215639.189706684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: teigland@redhat.com, cluster-devel@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ccaulfie@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In the normal regime where an application uses non-blocking I/O
writes on a socket, they will handle -EAGAIN and use poll() to
wait for send space.

They don't actually sleep on the socket I/O write.

But kernel level RPC layers that do socket I/O operations directly
and key off of -EAGAIN on the write() to "try again later" don't
use poll(), they instead have their own sleeping mechanism and
rely upon ->sk_write_space() to trigger the wakeup.

So they do effectively sleep on the write(), but this mechanism
alone does not let the socket layers know what's going on.

Therefore they must emulate what would have happened, otherwise
TCP cannot possibly see that the connection is application window
size limited.

Handle this, therefore, like SUNRPC by setting SOCK_NOSPACE and
bumping the ->sk_write_count as needed when we hit the send buffer
limits.

This should make TCP send buffer size auto-tuning and the
->sk_write_space() callback invocations actually happen.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 37a34c2..77720f8 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -108,6 +108,7 @@ struct connection {
 #define CF_INIT_PENDING 4
 #define CF_IS_OTHERCON 5
 #define CF_CLOSE 6
+#define CF_APP_LIMITED 7
 	struct list_head writequeue;  /* List of outgoing writequeue_entries */
 	spinlock_t writequeue_lock;
 	int (*rx_action) (struct connection *);	/* What to do when active */
@@ -295,7 +296,17 @@ static void lowcomms_write_space(struct sock *sk)
 {
 	struct connection *con = sock2con(sk);
 
-	if (con && !test_and_set_bit(CF_WRITE_PENDING, &con->flags))
+	if (!con)
+		return;
+
+	clear_bit(SOCK_NOSPACE, &con->sock->flags);
+
+	if (test_and_clear_bit(CF_APP_LIMITED, &con->flags)) {
+		con->sock->sk->sk_write_pending--;
+		clear_bit(SOCK_ASYNC_NOSPACE, &con->sock->flags);
+	}
+
+	if (!test_and_set_bit(CF_WRITE_PENDING, &con->flags))
 		queue_work(send_workqueue, &con->swork);
 }
 
@@ -1319,6 +1330,15 @@ static void send_to_sock(struct connection *con)
 			ret = kernel_sendpage(con->sock, e->page, offset, len,
 					      msg_flags);
 			if (ret == -EAGAIN || ret == 0) {
+				if (ret == -EAGAIN &&
+				    test_bit(SOCK_ASYNC_NOSPACE, &con->sock->flags) &&
+				    !test_and_set_bit(CF_APP_LIMITED, &con->flags)) {
+					/* Notify TCP that we're limited by the
+					 * application window size.
+					 */
+					set_bit(SOCK_NOSPACE, &con->sock->flags);
+					con->sock->sk->sk_write_pending++;
+				}
 				cond_resched();
 				goto out;
 			}
