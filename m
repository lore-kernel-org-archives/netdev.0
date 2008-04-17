From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][INET]: Uninline the __inet_inherit_port call.
Date: Thu, 17 Apr 2008 20:02:06 +0400
Message-ID: <4807747E.3020109@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44426 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120AbYDQQDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 12:03:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This deblats ~200 bytes when ipv6 and dccp are 'y'.

Besides, this will ease compilation issues for patches
I'm working on to make inet hash tables more scalable 
wrt net namespaces.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/inet_hashtables.h |   14 +-------------
 net/ipv4/inet_hashtables.c    |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5ec91d8..735b926 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -221,19 +221,7 @@ static inline int inet_sk_listen_hashfn(const struct sock *sk)
 }
 
 /* Caller must disable local BH processing. */
-static inline void __inet_inherit_port(struct sock *sk, struct sock *child)
-{
-	struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
-	const int bhash = inet_bhashfn(inet_sk(child)->num, table->bhash_size);
-	struct inet_bind_hashbucket *head = &table->bhash[bhash];
-	struct inet_bind_bucket *tb;
-
-	spin_lock(&head->lock);
-	tb = inet_csk(sk)->icsk_bind_hash;
-	sk_add_bind_node(child, &tb->owners);
-	inet_csk(child)->icsk_bind_hash = tb;
-	spin_unlock(&head->lock);
-}
+extern void __inet_inherit_port(struct sock *sk, struct sock *child);
 
 extern void inet_put_port(struct sock *sk);
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 1612184..2023d37 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -92,6 +92,22 @@ void inet_put_port(struct sock *sk)
 
 EXPORT_SYMBOL(inet_put_port);
 
+void __inet_inherit_port(struct sock *sk, struct sock *child)
+{
+	struct inet_hashinfo *table = sk->sk_prot->h.hashinfo;
+	const int bhash = inet_bhashfn(inet_sk(child)->num, table->bhash_size);
+	struct inet_bind_hashbucket *head = &table->bhash[bhash];
+	struct inet_bind_bucket *tb;
+
+	spin_lock(&head->lock);
+	tb = inet_csk(sk)->icsk_bind_hash;
+	sk_add_bind_node(child, &tb->owners);
+	inet_csk(child)->icsk_bind_hash = tb;
+	spin_unlock(&head->lock);
+}
+
+EXPORT_SYMBOL_GPL(__inet_inherit_port);
+
 /*
  * This lock without WQ_FLAG_EXCLUSIVE is good on UP and it can be very bad on SMP.
  * Look, when several writers sleep and reader wakes them up, all but one
-- 
1.5.3.4

