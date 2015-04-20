From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH] tcp: add memory barriers to write space paths
Date: Mon, 20 Apr 2015 20:05:07 +0000 (GMT)
Message-ID: <20150420200507.21414203F@prod-mail-relay06.akamai.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:52915 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbbDTUFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 16:05:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that we either see that the buffer has write space
in tcp_poll() or that we perform a wakeup from the input
side. Did not run into any actual problem here, but thought
that we should make things explicit.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/ipv4/tcp.c       | 4 +++-
 net/ipv4/tcp_input.c | 2 ++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 094a682..726341e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -520,8 +520,10 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 				/* Race breaker. If space is freed after
 				 * wspace test but before the flags are set,
-				 * IO signal will be lost.
+				 * IO signal will be lost. Memory barrier
+				 * pairs with the input side.
 				 */
+				smp_mb__after_atomic();
 				if (sk_stream_is_writeable(sk))
 					mask |= POLLOUT | POLLWRNORM;
 			}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 031cf72..63b3d4e9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4847,6 +4847,8 @@ static void tcp_check_space(struct sock *sk)
 {
 	if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
 		sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);
+		/* pairs with tcp_poll() */
+		smp_mb__after_atomic();
 		if (sk->sk_socket &&
 		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
 			tcp_new_space(sk);
-- 
1.8.2.rc2
