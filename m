From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/9] tipc: enqueue arrived
	buffers in socket in separate function
Date: Thu,  5 Feb 2015 08:36:38 -0500
Message-ID: <1423143404-23322-4-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The code for enqueuing arriving buffers in the function tipc_sk_rcv()
contains long code lines and currently goes to two indentation levels.
As a cosmetic preparaton for the next commits, we break it out into
a separate function.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 46 +++++++++++++++++++++++++++++++---------------
 1 file changed, 31 insertions(+), 15 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f9cd587..1d98bfc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1765,6 +1765,35 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 }
 
 /**
+ * tipc_sk_enqueue_skb - enqueue buffer to socket or backlog queue
+ * @sk: socket
+ * @skb: pointer to message. Set to NULL if buffer is consumed.
+ * @dnode: if buffer should be forwarded/returned, send to this node
+ *
+ * Caller must hold socket lock
+ *
+ * Returns TIPC_OK (0) or -tipc error code
+ */
+static int tipc_sk_enqueue_skb(struct sock *sk, struct sk_buff **skb)
+{
+	unsigned int lim;
+	atomic_t *dcnt;
+
+	if (unlikely(!*skb))
+		return TIPC_OK;
+	if (!sock_owned_by_user(sk))
+		return filter_rcv(sk, skb);
+	dcnt = &tipc_sk(sk)->dupl_rcvcnt;
+	if (sk->sk_backlog.len)
+		atomic_set(dcnt, 0);
+	lim = rcvbuf_limit(sk, *skb) + atomic_read(dcnt);
+	if (unlikely(sk_add_backlog(sk, *skb, lim)))
+		return -TIPC_ERR_OVERLOAD;
+	*skb = NULL;
+	return TIPC_OK;
+}
+
+/**
  * tipc_sk_rcv - handle incoming message
  * @skb: buffer containing arriving message
  * Consumes buffer
@@ -1776,8 +1805,7 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	struct tipc_net *tn;
 	struct sock *sk;
 	u32 dport = msg_destport(buf_msg(skb));
-	int err = TIPC_OK;
-	uint limit;
+	int err;
 	u32 dnode;
 
 	/* Validate destination and message */
@@ -1788,20 +1816,8 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	}
 	sk = &tsk->sk;
 
-	/* Queue message */
 	spin_lock_bh(&sk->sk_lock.slock);
-
-	if (!sock_owned_by_user(sk)) {
-		err = filter_rcv(sk, &skb);
-	} else {
-		if (sk->sk_backlog.len == 0)
-			atomic_set(&tsk->dupl_rcvcnt, 0);
-		limit = rcvbuf_limit(sk, skb) + atomic_read(&tsk->dupl_rcvcnt);
-		if (likely(!sk_add_backlog(sk, skb, limit)))
-			skb = NULL;
-		else
-			err = -TIPC_ERR_OVERLOAD;
-	}
+	err = tipc_sk_enqueue_skb(sk, &skb);
 	spin_unlock_bh(&sk->sk_lock.slock);
 	sock_put(sk);
 exit:
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
