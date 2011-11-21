From: Alexey Moiseytsev <himeraster@gmail.com>
Subject: [PATCH 1/1] AF_UNIX: Fix poll locking problem when reading from a stream socket
Date: Tue, 22 Nov 2011 03:35:25 +0400
Message-ID: <1321918525-5078-1-git-send-email-himeraster@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Moiseytsev <himeraster@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

poll() call may be locked by concurrent reading from the same stream
socket.

Signed-off-by: Alexey Moiseytsev <himeraster@gmail.com>
---
 net/unix/af_unix.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 466fbcc..b595a3d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1957,6 +1957,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
 			    (UNIXCB(skb).cred != siocb->scm->cred)) {
 				skb_queue_head(&sk->sk_receive_queue, skb);
+				sk->sk_data_ready(sk, skb->len);
 				break;
 			}
 		} else {
@@ -1974,6 +1975,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		chunk = min_t(unsigned int, skb->len, size);
 		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
+			sk->sk_data_ready(sk, skb->len);
 			if (copied == 0)
 				copied = -EFAULT;
 			break;
@@ -1991,6 +1993,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			/* put the skb back if we didn't use it up.. */
 			if (skb->len) {
 				skb_queue_head(&sk->sk_receive_queue, skb);
+				sk->sk_data_ready(sk, skb->len);
 				break;
 			}
 
@@ -2006,6 +2009,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 			/* put message back and return */
 			skb_queue_head(&sk->sk_receive_queue, skb);
+			sk->sk_data_ready(sk, skb->len);
 			break;
 		}
 	} while (size);
-- 
1.7.2.5
