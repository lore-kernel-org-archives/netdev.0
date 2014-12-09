From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 17/25] switch tcp_sock->ucopy from iovec (ucopy.iov) to msghdr (ucopy.msg)
Date: Tue,  9 Dec 2014 22:50:30 +0000
Message-ID: <1418165438-2205-17-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/tcp.h  | 2 +-
 net/ipv4/tcp.c       | 2 +-
 net/ipv4/tcp_input.c | 7 +++----
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f566b85..5d9cc9c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -162,7 +162,7 @@ struct tcp_sock {
 	struct {
 		struct sk_buff_head	prequeue;
 		struct task_struct	*task;
-		struct iovec		*iov;
+		struct msghdr		*msg;
 		int			memory;
 		int			len;
 	} ucopy;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dc13a36..4a96f37 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1729,7 +1729,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			if (!user_recv && !(flags & (MSG_TRUNC | MSG_PEEK))) {
 				user_recv = current;
 				tp->ucopy.task = user_recv;
-				tp->ucopy.iov = msg->msg_iov;
+				tp->ucopy.msg = msg;
 			}
 
 			tp->ucopy.len = len;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 69de1a1..075ab4d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4421,7 +4421,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 			__set_current_state(TASK_RUNNING);
 
 			local_bh_enable();
-			if (!skb_copy_datagram_iovec(skb, 0, tp->ucopy.iov, chunk)) {
+			if (!skb_copy_datagram_msg(skb, 0, tp->ucopy.msg, chunk)) {
 				tp->ucopy.len -= chunk;
 				tp->copied_seq += chunk;
 				eaten = (chunk == skb->len);
@@ -4941,10 +4941,9 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 
 	local_bh_enable();
 	if (skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_iovec(skb, hlen, tp->ucopy.iov, chunk);
+		err = skb_copy_datagram_msg(skb, hlen, tp->ucopy.msg, chunk);
 	else
-		err = skb_copy_and_csum_datagram_iovec(skb, hlen,
-						       tp->ucopy.iov);
+		err = skb_copy_and_csum_datagram_msg(skb, hlen, tp->ucopy.msg);
 
 	if (!err) {
 		tp->ucopy.len -= chunk;
-- 
2.1.3
