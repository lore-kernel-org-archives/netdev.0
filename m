From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next v2] tcp: ensure epoll edge trigger wakeup when write queue is empty
Date: Wed, 20 May 2015 15:52:53 +0000 (GMT)
Message-ID: <20150520155253.86202203D@prod-mail-relay06.akamai.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:39073 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932112AbbETPwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:52:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

We currently rely on the setting of SOCK_NOSPACE in the write()
path to ensure that we wake up any epoll edge trigger waiters when
acks return to free space in the write queue. However, if we fail
to allocate even a single skb in the write queue, we could end up
waiting indefinitely.

Fix this by explicitly issuing a wakeup when we detect the condition
of an empty write queue and a return value of -EAGAIN. This allows
userspace to re-try as we expect this to be a temporary failure.

I've tested this approach by artificially making
sk_stream_alloc_skb() return NULL periodically. In that case,
epoll edge trigger waiters will hang indefinitely in epoll_wait()
without this patch.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
v2:
- ensure it compiles :)

 net/ipv4/tcp.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c724195..6247c24 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -997,6 +997,9 @@ do_error:
 	if (copied)
 		goto out;
 out_err:
+	/* make sure we wake any epoll edge trigger waiter */
+	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 && err == -EAGAIN))
+		sk->sk_write_space(sk);
 	return sk_stream_error(sk, flags, err);
 }
 
@@ -1285,6 +1288,9 @@ do_error:
 		goto out;
 out_err:
 	err = sk_stream_error(sk, flags, err);
+	/* make sure we wake any epoll edge trigger waiter */
+	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 && err == -EAGAIN))
+		sk->sk_write_space(sk);
 	release_sock(sk);
 	return err;
 }
-- 
1.8.2.rc2
