From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: allow bigger skbs in unix_stream_sendmsg
Date: Fri, 09 Sep 2011 13:32:28 +0200
Message-ID: <1315567948.2294.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Andi Kleen <ak@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56200 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933364Ab1IILcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 07:32:24 -0400
Received: by wyh22 with SMTP id 22so1481311wyh.19
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2011 04:32:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix_stream_sendmsg() currently builds basic skbs, of up to 16192 bytes
(order-2 allocations) per skb.

We switch to pure order-0 allocations, with up to 16 fragments per skbs,
to lower number of context switches and lower memory pressure on high
order pages and LOWMEM (frags pages can be allocated from HIGHMEM).
We can send 64Kb in one round.

I get a 50% speedup on a AF_UNIX benchmark using 16Kb buffers.

No impact on small writes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
benchmark is hackbench, slightly modified.

 include/net/af_unix.h |    1 +
 net/unix/af_unix.c    |   40 ++++++++++++++++------------------------
 2 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 91ab5b0..9a57b4b 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -30,6 +30,7 @@ struct unix_skb_parms {
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
 #endif
+	int			offset;
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 1bd4ecf..4736af4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1575,7 +1575,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
-	int err, size;
+	int err, size, header_len;
 	struct sk_buff *skb = NULL;
 	int sent = 0;
 	struct scm_cookie tmp_scm;
@@ -1616,31 +1616,22 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		size = len-sent;
 
 		/* Keep two messages in the pipe so it schedules better */
-		if (size > ((sk->sk_sndbuf >> 1) - 64))
-			size = (sk->sk_sndbuf >> 1) - 64;
+		size = min_t(int, size, (sk->sk_sndbuf >> 1) - 64);
 
-		if (size > SKB_MAX_ALLOC)
-			size = SKB_MAX_ALLOC;
+		/* size of a full skb, using order-0 allocations */
+		size = min_t(int, size, SKB_MAX_ORDER(0,0) + MAX_SKB_FRAGS * PAGE_SIZE);
 
-		/*
-		 *	Grab a buffer
-		 */
+		header_len = min_t(int, size, SKB_MAX_ORDER(0,0));
 
-		skb = sock_alloc_send_skb(sk, size, msg->msg_flags&MSG_DONTWAIT,
-					  &err);
+		skb = sock_alloc_send_pskb(sk, header_len, size - header_len,
+					   msg->msg_flags & MSG_DONTWAIT, &err);
 
 		if (skb == NULL)
 			goto out_err;
 
-		/*
-		 *	If you pass two values to the sock_alloc_send_skb
-		 *	it tries to grab the large buffer with GFP_NOFS
-		 *	(which can fail easily), and if it fails grab the
-		 *	fallback size buffer which is under a page and will
-		 *	succeed. [Alan]
-		 */
-		size = min_t(int, size, skb_tailroom(skb));
-
+		skb_put(skb, header_len);
+		skb->data_len = size - header_len;
+		skb->len = size;
 
 		/* Only send the fds in first buffer
 		 * Last buffer can steal our references to pid/cred
@@ -1654,7 +1645,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		max_level = err + 1;
 		fds_sent = true;
 
-		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+		err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov, 0, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
@@ -1965,8 +1956,9 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			sunaddr = NULL;
 		}
 
-		chunk = min_t(unsigned int, skb->len, size);
-		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
+		chunk = min_t(unsigned int, skb->len - UNIXCB(skb).offset, size);
+		if (skb_copy_datagram_iovec(skb, UNIXCB(skb).offset,
+					    msg->msg_iov, chunk)) {
 			skb_queue_head(&sk->sk_receive_queue, skb);
 			skb = NULL;
 			if (copied == 0)
@@ -1978,13 +1970,13 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		/* Mark read part of skb as used */
 		if (!(flags & MSG_PEEK)) {
-			skb_pull(skb, chunk);
+			UNIXCB(skb).offset += chunk;
 
 			if (UNIXCB(skb).fp)
 				unix_detach_fds(siocb->scm, skb);
 
 			/* put the skb back if we didn't use it up.. */
-			if (skb->len) {
+			if (UNIXCB(skb).offset < skb->len) {
 				skb_queue_head(&sk->sk_receive_queue, skb);
 				skb = NULL;
 				break;
