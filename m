From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] af_unix: fix EPOLLET regression for stream sockets
Date: Sun, 29 Jan 2012 03:11:03 +0100
Message-ID: <1327803063.2805.14.camel@edumazet-laptop>
References: <CAKDKvuzH14AZjDG3WSdrf5VtmiUgG0Y+EaC83qqSd0VFKzyitg@mail.gmail.com>
	 <1327686822.3159.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Moiseytsev <himeraster@gmail.com>
To: Nick Mathewson <nickm@freehaven.net>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327686822.3159.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 0884d7aa24 (AF_UNIX: Fix poll blocking problem when reading from
a stream socket) added a regression for epoll() in Edge Triggered mode
(EPOLLET)

Appropriate fix is to use skb_peek()/skb_unlink() instead of
skb_dequeue(), and only call skb_unlink() when skb is fully consumed.

This remove the need to requeue a partial skb into sk_receive_queue head
and the extra sk->sk_data_ready() calls that added the regression.

This is safe because once skb is given to sk_receive_queue, it is not
modified by a writer, and readers are serialized by u->readlock mutex.

This also reduce number of spinlock acquisition for small reads or
MSG_PEEK users so should improve overall performance.

Reported-by: Nick Mathewson <nickm@freehaven.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexey Moiseytsev <himeraster@gmail.com>
---
 net/unix/af_unix.c |   21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index aad8fb6..afc2ae4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1918,7 +1918,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		struct sk_buff *skb;
 
 		unix_state_lock(sk);
-		skb = skb_dequeue(&sk->sk_receive_queue);
+		skb = skb_peek(&sk->sk_receive_queue);
 		if (skb == NULL) {
 			unix_sk(sk)->recursion_level = 0;
 			if (copied >= target)
@@ -1958,11 +1958,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		if (check_creds) {
 			/* Never glue messages from different writers */
 			if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
-			    (UNIXCB(skb).cred != siocb->scm->cred)) {
-				skb_queue_head(&sk->sk_receive_queue, skb);
-				sk->sk_data_ready(sk, skb->len);
+			    (UNIXCB(skb).cred != siocb->scm->cred))
 				break;
-			}
 		} else {
 			/* Copy credentials */
 			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
@@ -1977,8 +1974,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		chunk = min_t(unsigned int, skb->len, size);
 		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
-			skb_queue_head(&sk->sk_receive_queue, skb);
-			sk->sk_data_ready(sk, skb->len);
 			if (copied == 0)
 				copied = -EFAULT;
 			break;
@@ -1993,13 +1988,10 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			if (UNIXCB(skb).fp)
 				unix_detach_fds(siocb->scm, skb);
 
-			/* put the skb back if we didn't use it up.. */
-			if (skb->len) {
-				skb_queue_head(&sk->sk_receive_queue, skb);
-				sk->sk_data_ready(sk, skb->len);
+			if (skb->len)
 				break;
-			}
-
+			
+			skb_unlink(skb, &sk->sk_receive_queue);
 			consume_skb(skb);
 
 			if (siocb->scm->fp)
@@ -2010,9 +2002,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			if (UNIXCB(skb).fp)
 				siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
 
-			/* put message back and return */
-			skb_queue_head(&sk->sk_receive_queue, skb);
-			sk->sk_data_ready(sk, skb->len);
 			break;
 		}
 	} while (size);
