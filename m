From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 net-next 1/2] tcp: replace smp_mb__after_atomic() with smp_mb() in tcp_poll()
Date: Wed, 22 Jun 2016 11:32:50 -0400
Message-ID: <ac8b2dae8215afe2027e1a581f712a435bd91d06.1466608332.git.jbaron@akamai.com>
References: <cover.1466608332.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:21857 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691AbcFVPfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 11:35:17 -0400
In-Reply-To: <cover.1466608332.git.jbaron@akamai.com>
In-Reply-To: <cover.1466608332.git.jbaron@akamai.com>
References: <cover.1466608332.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

sock_reset_flag() maps to __clear_bit() not the atomic version clear_bit(),
hence we need an smp_mb() there, smp_mb__after_atomic() is not sufficient.

Fixes: 3c7151275c0c ("tcp: add memory barriers to write space paths")
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 94d4aff97523..3ba526ecdeb9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4987,7 +4987,7 @@ static void tcp_check_space(struct sock *sk)
 	if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
 		sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);
 		/* pairs with tcp_poll() */
-		smp_mb__after_atomic();
+		smp_mb();
 		if (sk->sk_socket &&
 		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
 			tcp_new_space(sk);
-- 
2.6.1
