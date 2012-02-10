From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] datagram: Extend the datagram queue MSG_PEEK-ing
Date: Fri, 10 Feb 2012 17:54:10 +0400
Message-ID: <4F352182.6060601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27228 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754180Ab2BJNyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 08:54:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're working on the checkpoint-restore project. To checkpoint a unix socket
we need to read its skb queue. Analogous task for TCP sockets Tejun proposed
to solve with parasite + recvmsg + MSG_PEEK. That's nice, but doesn't work
for unix sockets, because for them MSG_PEEK always peeks a single skb from the 
head of the queue.

I propose to extend the MSG_PEEK functionality with two more flags that peek
either next not picked skb in queue or pick the last picked one. The latter
ability is required to make it possible to re-read a message if MSG_TRUNC
was reported on it.

These two flags can be used for unix stream sockets, since making the MSG_PEEK
just report all data that fits the buffer length is bad -- we may have scms
in queue thus turning stream socket into dgram one.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/socket.h |    3 ++
 net/core/datagram.c    |   52 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index d0e77f6..ab3aa19 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -266,6 +266,9 @@ struct ucred {
 #define MSG_MORE	0x8000	/* Sender will send more */
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 
+#define MSG_PEEK_MORE	0x20000
+#define MSG_PEEK_AGAIN	0x40000
+
 #define MSG_EOF         MSG_FIN
 
 #define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exit for file
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 68bbf9f..c330e40 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -157,6 +157,40 @@ out_noerr:
  *	quite explicitly by POSIX 1003.1g, don't change them without having
  *	the standard around please.
  */
+
+/*
+ * Peek the last skb marked as peeked
+ */
+
+static struct sk_buff *skb_peek_again(struct sk_buff_head *queue)
+{
+	struct sk_buff *skb, *prev = NULL;
+
+	skb_queue_walk(queue, skb) {
+		if (skb->peeked)
+			prev = skb;
+		else
+			break;
+	}
+
+	return prev;
+}
+
+/*
+ * Peek the first not peeked skb
+ */
+
+static struct sk_buff *skb_peek_more(struct sk_buff_head *queue)
+{
+	struct sk_buff *skb;
+
+	skb_queue_walk(queue, skb)
+		if (!skb->peeked)
+			return skb;
+
+	return NULL;
+}
+
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 				    int *peeked, int *err)
 {
@@ -180,18 +214,28 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 		 * However, this function was correct in any case. 8)
 		 */
 		unsigned long cpu_flags;
-
-		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
-		skb = skb_peek(&sk->sk_receive_queue);
+		struct sk_buff_head *queue = &sk->sk_receive_queue;
+
+		spin_lock_irqsave(&queue->lock, cpu_flags);
+		if (flags & MSG_PEEK) {
+			if (flags & MSG_PEEK_MORE)
+				skb = skb_peek_more(queue);
+			else if (flags & MSG_PEEK_AGAIN)
+				skb = skb_peek_again(queue);
+			else
+				skb = skb_peek(queue);
+		} else
+			skb = skb_peek(queue);
+	
 		if (skb) {
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
 				skb->peeked = 1;
 				atomic_inc(&skb->users);
 			} else
-				__skb_unlink(skb, &sk->sk_receive_queue);
+				__skb_unlink(skb, queue);
 		}
-		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
+		spin_unlock_irqrestore(&queue->lock, cpu_flags);
 
 		if (skb)
 			return skb;
-- 
1.5.5.6
