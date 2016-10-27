From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 04/16] tipc: rename struct
	tipc_skb_cb member handle to bytes_read
Date: Thu, 27 Oct 2016 16:22:25 +0200
Message-ID: <1477578157-13256-5-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we rename handle to bytes_read indicating the
purpose of the member.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/msg.h    |  2 +-
 net/tipc/socket.c | 18 ++++++++++--------
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index c3832cdf2278..a2aa01b442ef 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -95,7 +95,7 @@ struct plist;
 #define TIPC_MEDIA_INFO_OFFSET	5
 
 struct tipc_skb_cb {
-	void *handle;
+	u32 bytes_read;
 	struct sk_buff *tail;
 	bool validated;
 	bool wakeup_pending;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 82aec2eb8497..6e3774a7c831 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -465,7 +465,7 @@ static int tipc_release(struct socket *sock)
 		skb = __skb_dequeue(&sk->sk_receive_queue);
 		if (skb == NULL)
 			break;
-		if (TIPC_SKB_CB(skb)->handle != NULL)
+		if (TIPC_SKB_CB(skb)->bytes_read)
 			kfree_skb(skb);
 		else {
 			if ((sock->state == SS_CONNECTING) ||
@@ -1435,7 +1435,7 @@ static int tipc_recv_stream(struct socket *sock, struct msghdr *m,
 	struct tipc_msg *msg;
 	long timeo;
 	unsigned int sz;
-	int sz_to_copy, target, needed;
+	int target;
 	int sz_copied = 0;
 	u32 err;
 	int res = 0, hlen;
@@ -1483,11 +1483,13 @@ static int tipc_recv_stream(struct socket *sock, struct msghdr *m,
 
 	/* Capture message data (if valid) & compute return value (always) */
 	if (!err) {
-		u32 offset = (u32)(unsigned long)(TIPC_SKB_CB(buf)->handle);
+		u32 offset = (u32)(TIPC_SKB_CB(buf)->bytes_read);
+		u32 needed;
+		int sz_to_copy;
 
 		sz -= offset;
 		needed = (buf_len - sz_copied);
-		sz_to_copy = (sz <= needed) ? sz : needed;
+		sz_to_copy = min(sz, needed);
 
 		res = skb_copy_datagram_msg(buf, hlen + offset, m, sz_to_copy);
 		if (res)
@@ -1497,8 +1499,8 @@ static int tipc_recv_stream(struct socket *sock, struct msghdr *m,
 
 		if (sz_to_copy < sz) {
 			if (!(flags & MSG_PEEK))
-				TIPC_SKB_CB(buf)->handle =
-				(void *)(unsigned long)(offset + sz_to_copy);
+				TIPC_SKB_CB(buf)->bytes_read =
+					offset + sz_to_copy;
 			goto exit;
 		}
 	} else {
@@ -1742,7 +1744,7 @@ static bool filter_rcv(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/* Enqueue message */
-	TIPC_SKB_CB(skb)->handle = NULL;
+	TIPC_SKB_CB(skb)->bytes_read = 0;
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	skb_set_owner_r(skb, sk);
 
@@ -2177,7 +2179,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 		/* Disconnect and send a 'FIN+' or 'FIN-' message to peer */
 		skb = __skb_dequeue(&sk->sk_receive_queue);
 		if (skb) {
-			if (TIPC_SKB_CB(skb)->handle != NULL) {
+			if (TIPC_SKB_CB(skb)->bytes_read) {
 				kfree_skb(skb);
 				goto restart;
 			}
-- 
2.1.4


------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
