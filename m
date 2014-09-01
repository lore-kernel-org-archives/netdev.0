From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Sun, 31 Aug 2014 21:28:16 -0400
Message-ID: <1409534896-372-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:59848 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaIAB2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 21:28:19 -0400
Received: by mail-oi0-f73.google.com with SMTP id u20so890229oif.2
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 18:28:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a socket error is pending, send()/recv() must abort their normal
operation and return the error. An error means having non-zero
sk->sk_err or having non-empty sk->sk_error_queue.

Currently, the behavior for the second is inconsistent depending on
whether an error has previously been dequeued. In all cases,
recv()/send() test sk->sk_err. This is not modified on enqueue onto
the error queue, so may be 0. It is modified on dequeue, however, to
match the queued skb's errno. I observed the following when two errors
were queued:

  ret = poll(pollfd, 1, -1);
  assert(ret == 1);
  assert(pollfd.revents == POLLERR);

  ret = recv(fd, buf, size, MSG_NONBLOCK);
  assert(ret == -1 && errno == EAGAIN);		/* <-- A */

  ret = recv(fd, buf, size, MSG_ERRQUEUE);
  assert(ret > 0);

  ret = recv(fd, buf, size, MSG_NONBLOCK);
  assert(ret == -1 && errno == ENOMSG);		/* <-- B */

  ret = recv(fd, buf, size, MSG_ERRQUEUE);
  assert(ret > 0);

The recv call in B returns the error code embedded in
SKB_EXT_ERR(skb), in this case ENOMSG, because I am working with
timestamps. The recv call in A should have returned the
same.

Implement this behavior. This may surprise existing applications.

Also make the wake-up signal when data is ready on the error queue
consistent between enqueue and dequeue: use sk_error_report in both
cases.

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

This approach leaves one issue:
The states of sk->sk_err and sk->sk_error_queue are related, but only
loosely. Error queue enqueue, dequeue and other code may overwrite
sk->sk_err unconditionally. For one, sock_error will reset
sk->sk_err to 0 even if sk->sk_error_queue is not empty. If socket
calls should abort on all errors, then should be change to test
sk_error_queue.qlen. But, doing so requires taking a lock in a busy
data path.
---
 net/core/skbuff.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 163b673..f7a280b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3485,8 +3485,11 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 	skb_dst_force(skb);
 
 	skb_queue_tail(&sk->sk_error_queue, skb);
+	sk->sk_err = SKB_EXT_ERR(skb)->ee.ee_errno;
+
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk);
+		sk->sk_error_report(sk);
+
 	return 0;
 }
 EXPORT_SYMBOL(sock_queue_err_skb);
-- 
2.1.0.rc2.206.gedb03e5
