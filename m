From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 2/2] tipc: fix socket flow control
	accounting error at tipc_recv_stream
Date: Mon, 24 Apr 2017 15:00:43 +0200
Message-ID: <1493038843-30621-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1493038843-30621-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1493038843-30621-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Until now in tipc_recv_stream(), we update the received
unacknowledged bytes based on a stack variable and not based on the
actual message size.
If the user buffer passed at tipc_recv_stream() is smaller than the
received skb, the size variable in stack differs from the actual
message size in the skb. This leads to a flow control accounting
error causing permanent congestion.

In this commit, we fix this accounting error by always using the
size of the incoming message.

Fixes: 10724cc7bb78 ("tipc: redesign connection-level flow control")
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b28e94f1c739..566906795c8c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1484,7 +1484,7 @@ static int tipc_recv_stream(struct socket *sock, struct msghdr *m,
 	if (unlikely(flags & MSG_PEEK))
 		goto exit;
 
-	tsk->rcv_unacked += tsk_inc(tsk, hlen + sz);
+	tsk->rcv_unacked += tsk_inc(tsk, hlen + msg_data_sz(msg));
 	if (unlikely(tsk->rcv_unacked >= (tsk->rcv_win / 4)))
 		tipc_sk_send_ack(tsk);
 	tsk_advance_rx_queue(sk);
-- 
2.1.4


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
