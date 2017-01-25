From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net] tcp: correct memory barrier usage in tcp_check_space()
Date: Tue, 24 Jan 2017 21:49:41 -0500
Message-ID: <1485312581-13041-1-git-send-email-jbaron@akamai.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        Oleg Nesterov <oleg@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:46900 "EHLO
        prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751224AbdAYCyQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 21:54:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

sock_reset_flag() maps to __clear_bit() not the atomic version clear_bit().
Thus, we need smp_mb(), smp_mb__after_atomic() is not sufficient.

Fixes: 3c7151275c0c ("tcp: add memory barriers to write space paths")
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bfa165cc455a..1e22ae4a5b38 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5028,7 +5028,7 @@ static void tcp_check_space(struct sock *sk)
 	if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
 		sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);
 		/* pairs with tcp_poll() */
-		smp_mb__after_atomic();
+		smp_mb();
 		if (sk->sk_socket &&
 		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
 			tcp_new_space(sk);
-- 
2.6.1
