From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: make skb_set_owner_w() more robust
Date: Sun, 01 Nov 2015 15:36:55 -0800
Message-ID: <1446421015.6254.106.camel@edumazet-glaptop2.roam.corp.google.com>
References: <BN1PR0301MB07705F68B22ED84061E37337CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446249142.6254.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151101.155859.1206189858863918018.davem@davemloft.net>
	 <1446417380.6254.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446418728.6254.101.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org, kys@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36215 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbbKAXg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 18:36:57 -0500
Received: by pacfv9 with SMTP id fv9so133742319pac.3
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2015 15:36:56 -0800 (PST)
In-Reply-To: <1446418728.6254.101.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_set_owner_w() is called from various places that assume
skb->sk always point to a full blown socket (as it changes
sk->sk_wmem_alloc)

We'd like to attach skb to request sockets, and in the future
to timewait sockets as well. For these kind of pseudo sockets,
we need to take a traditional refcount and use sock_edemux()
as the destructor.

It is now time to un-inline skb_set_owner_w(), being too big.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Bisected-by: Haiyang Zhang <haiyangz@microsoft.com>
---
v2: sock_edemux() must be guarded by CONFIG_INET

 include/net/sock.h    |   17 ++---------------
 net/core/sock.c       |   22 ++++++++++++++++++++++
 net/ipv4/tcp_output.c |    4 +---
 3 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index aeed5c95f3ca..f570e75e3da9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1951,6 +1951,8 @@ static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 	}
 }
 
+void skb_set_owner_w(struct sk_buff *skb, struct sock *sk);
+
 /*
  *	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
@@ -1959,21 +1961,6 @@ static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
  *	Inlined as it's very short and called for pretty much every
  *	packet ever received.
  */
-
-static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
-{
-	skb_orphan(skb);
-	skb->sk = sk;
-	skb->destructor = sock_wfree;
-	skb_set_hash_from_sk(skb, sk);
-	/*
-	 * We used to take a refcount on sk, but following operation
-	 * is enough to guarantee sk_free() wont free this sock until
-	 * all in-flight packets are completed
-	 */
-	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
-}
-
 static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 {
 	skb_orphan(skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index 0ef30aa90132..7529eb9463be 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1656,6 +1656,28 @@ void sock_wfree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_wfree);
 
+void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
+{
+	skb_orphan(skb);
+	skb->sk = sk;
+#ifdef CONFIG_INET
+	if (unlikely(!sk_fullsock(sk))) {
+		skb->destructor = sock_edemux;
+		sock_hold(sk);
+		return;
+	}
+#endif
+	skb->destructor = sock_wfree;
+	skb_set_hash_from_sk(skb, sk);
+	/*
+	 * We used to take a refcount on sk, but following operation
+	 * is enough to guarantee sk_free() wont free this sock until
+	 * all in-flight packets are completed
+	 */
+	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+}
+EXPORT_SYMBOL(skb_set_owner_w);
+
 void skb_orphan_partial(struct sk_buff *skb)
 {
 	/* TCP stack sets skb->ooo_okay based on sk_wmem_alloc,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f4f9793eb025..cb7ca569052c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2963,9 +2963,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	skb_reserve(skb, MAX_TCP_HEADER);
 
 	if (attach_req) {
-		skb->destructor = sock_edemux;
-		sock_hold(req_to_sk(req));
-		skb->sk = req_to_sk(req);
+		skb_set_owner_w(skb, req_to_sk(req));
 	} else {
 		/* sk is a const pointer, because we want to express multiple
 		 * cpu might call us concurrently.
