From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use proper lockdep annotation in
 __sk_dst_set()
Date: Mon, 06 Mar 2017 11:23:55 -0800
Message-ID: <1488828235.9415.390.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33571 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754003AbdCFTvP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 14:51:15 -0500
Received: by mail-pg0-f67.google.com with SMTP id 77so7882775pgc.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 11:49:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__sk_dst_set() must be called while we own the socket.

We can get proper lockdep coverage using lockdep_sock_is_held()
and rcu_dereference_protected()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5e5997654db6454f82179cc35c4bc22e89d0c06f..6db7693b9e61854abaa461706f2678c6d429b73f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1780,11 +1780,8 @@ __sk_dst_set(struct sock *sk, struct dst_entry *dst)
 
 	sk_tx_queue_clear(sk);
 	sk->sk_dst_pending_confirm = 0;
-	/*
-	 * This can be called while sk is owned by the caller only,
-	 * with no state that can be checked in a rcu_dereference_check() cond
-	 */
-	old_dst = rcu_dereference_raw(sk->sk_dst_cache);
+	old_dst = rcu_dereference_protected(sk->sk_dst_cache,
+					    lockdep_sock_is_held(sk));
 	rcu_assign_pointer(sk->sk_dst_cache, dst);
 	dst_release(old_dst);
 }
