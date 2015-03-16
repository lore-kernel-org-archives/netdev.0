From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/5] inet: factorize sock_edemux()/sock_gen_put() code
Date: Sun, 15 Mar 2015 21:12:15 -0700
Message-ID: <1426479136-15645-5-git-send-email-edumazet@google.com>
References: <1426479136-15645-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:34430 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbbCPEMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:12:44 -0400
Received: by igqa13 with SMTP id a13so2419644igq.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 21:12:43 -0700 (PDT)
In-Reply-To: <1426479136-15645-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_edemux() is not used in fast path, and should
really call sock_gen_put() to save some code.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c            | 15 ---------------
 net/ipv4/inet_hashtables.c |  6 ++++++
 2 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 4bc42efb3e40..a950b54248da 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1661,21 +1661,6 @@ void sock_efree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_efree);
 
-#ifdef CONFIG_INET
-void sock_edemux(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	if (sk->sk_state == TCP_TIME_WAIT)
-		inet_twsk_put(inet_twsk(sk));
-	else if (sk->sk_state == TCP_NEW_SYN_RECV)
-		reqsk_put(inet_reqsk(sk));
-	else
-		sock_put(sk);
-}
-EXPORT_SYMBOL(sock_edemux);
-#endif
-
 kuid_t sock_i_uid(struct sock *sk)
 {
 	kuid_t uid;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 64401a2fdd33..c28bca4cc15b 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -269,6 +269,12 @@ void sock_gen_put(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sock_gen_put);
 
+void sock_edemux(struct sk_buff *skb)
+{
+	sock_gen_put(skb->sk);
+}
+EXPORT_SYMBOL(sock_edemux);
+
 struct sock *__inet_lookup_established(struct net *net,
 				  struct inet_hashinfo *hashinfo,
 				  const __be32 saddr, const __be16 sport,
-- 
2.2.0.rc0.207.ga3a616c
