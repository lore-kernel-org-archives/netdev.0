From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] sock: relax WARN_ON() in sock_owned_by_user()
Date: Mon, 25 Apr 2016 06:34:09 -0700
Message-ID: <1461591249.5535.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <43037.1461229555@turing-police.cc.vt.edu>
	 <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5718DA71.7050902@stressinduktion.org>
	 <20160424.143833.2292980084570149367.davem@davemloft.net>
	 <571D14F8.6070306@stressinduktion.org>
	 <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com>
	 <176911.1461527778@turing-police.cc.vt.edu>
	 <1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33364 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbcDYNeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 09:34:12 -0400
Received: by mail-pf0-f169.google.com with SMTP id 206so17508061pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 06:34:11 -0700 (PDT)
In-Reply-To: <1461531617.5535.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Valdis reported tons of stack dumps caused by WARN_ON() in
sock_owned_by_user()

This test needs to be relaxed if/when lockdep disables itself.

Note that other lockdep_sock_is_held() callers are all from
rcu_dereference_protected() sections which already are disabled
if/when lockdep has been disabled.

Fixes: fafc4e1ea1a4 ("sock: tigthen lockdep checks for sock_owned_by_user")
Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 52448baf19d7..2fdb87f176cf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1409,7 +1409,7 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 static inline bool sock_owned_by_user(const struct sock *sk)
 {
 #ifdef CONFIG_LOCKDEP
-	WARN_ON(!lockdep_sock_is_held(sk));
+	WARN_ON_ONCE(!lockdep_sock_is_held(sk) && debug_locks);
 #endif
 	return sk->sk_lock.owned;
 }
