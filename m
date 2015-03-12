From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/7] inet: prepare sock_edemux() & sock_gen_put() for new SYN_RECV state
Date: Thu, 12 Mar 2015 14:50:14 -0700
Message-ID: <1426197016-14482-6-git-send-email-edumazet@google.com>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:33294 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725AbbCLVvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:51:09 -0400
Received: by oiba3 with SMTP id a3so1561401oib.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 14:51:08 -0700 (PDT)
In-Reply-To: <1426197016-14482-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_edemux() & sock_gen_put() should be ready to cope with request socks.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 5 +++++
 include/net/sock.h         | 2 +-
 net/core/sock.c            | 2 ++
 net/ipv4/inet_hashtables.c | 2 ++
 4 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index e255ecf8bb40..3275cf31f731 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -77,6 +77,11 @@ static inline struct request_sock *reqsk_alloc(const struct request_sock_ops *op
 	return req;
 }
 
+static inline struct request_sock *inet_reqsk(struct sock *sk)
+{
+	return (struct request_sock *)sk;
+}
+
 static inline void __reqsk_free(struct request_sock *req)
 {
 	kmem_cache_free(req->rsk_ops->slab, req);
diff --git a/include/net/sock.h b/include/net/sock.h
index 9411c3421dd3..f10832ca2e90 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1625,7 +1625,7 @@ static inline void sock_put(struct sock *sk)
 		sk_free(sk);
 }
 /* Generic version of sock_put(), dealing with all sockets
- * (TCP_TIMEWAIT, ESTABLISHED...)
+ * (TCP_TIMEWAIT, TCP_NEW_SYN_RECV, ESTABLISHED...)
  */
 void sock_gen_put(struct sock *sk);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 63d871a91b5c..4bc42efb3e40 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1668,6 +1668,8 @@ void sock_edemux(struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_TIME_WAIT)
 		inet_twsk_put(inet_twsk(sk));
+	else if (sk->sk_state == TCP_NEW_SYN_RECV)
+		reqsk_put(inet_reqsk(sk));
 	else
 		sock_put(sk);
 }
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index f6a12b97d12b..64401a2fdd33 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -262,6 +262,8 @@ void sock_gen_put(struct sock *sk)
 
 	if (sk->sk_state == TCP_TIME_WAIT)
 		inet_twsk_free(inet_twsk(sk));
+	else if (sk->sk_state == TCP_NEW_SYN_RECV)
+		reqsk_free(inet_reqsk(sk));
 	else
 		sk_free(sk);
 }
-- 
2.2.0.rc0.207.ga3a616c
