From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: fix a lockdep rcu warning in
 __sk_dst_set()
Date: Tue, 27 Apr 2010 08:40:43 +0200
Message-ID: <1272350443.4861.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:48625 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab0D0Gkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 02:40:49 -0400
Received: by bwz19 with SMTP id 19so158535bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 23:40:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__sk_dst_set() might be called while no state can be integrated in a
rcu_dereference_check() condition.

So use rcu_dereference_raw() to shutup lockdep warnings (if
CONFIG_PROVE_RCU is set)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/net/sock.h b/include/net/sock.h
index 86a8ca1..94dbdbc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1236,8 +1236,11 @@ __sk_dst_set(struct sock *sk, struct dst_entry *dst)
 	struct dst_entry *old_dst;
 
 	sk_tx_queue_clear(sk);
-	old_dst = rcu_dereference_check(sk->sk_dst_cache,
-					lockdep_is_held(&sk->sk_dst_lock));
+	/*
+	 * This can be called while sk is owned by the caller only,
+	 * with no state that can be checked in a rcu_dereference_check() cond
+	 */
+	old_dst = rcu_dereference_raw(sk->sk_dst_cache);
 	rcu_assign_pointer(sk->sk_dst_cache, dst);
 	dst_release(old_dst);
 }


