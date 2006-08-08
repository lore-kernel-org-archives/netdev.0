From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] [IPV4]: Uninline inet_lookup_listener
Date: Tue, 8 Aug 2006 18:46:14 +1000
Message-ID: <20060808084614.GA6651@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50959 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932516AbWHHIqY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 04:46:24 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[IPV4]: Uninline inet_lookup_listener

By modern standards this function is way too big to be inlined.  It's
even bigger than __inet_lookup_listener :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -271,39 +271,10 @@ static inline int inet_iif(const struct 
 	return ((struct rtable *)skb->dst)->rt_iif;
 }
 
-extern struct sock *__inet_lookup_listener(const struct hlist_head *head,
-					   const u32 daddr,
-					   const unsigned short hnum,
-					   const int dif);
-
-/* Optimize the common listener case. */
-static inline struct sock *
+extern struct sock *
 		inet_lookup_listener(struct inet_hashinfo *hashinfo,
 				     const u32 daddr,
-				     const unsigned short hnum, const int dif)
-{
-	struct sock *sk = NULL;
-	const struct hlist_head *head;
-
-	read_lock(&hashinfo->lhash_lock);
-	head = &hashinfo->listening_hash[inet_lhashfn(hnum)];
-	if (!hlist_empty(head)) {
-		const struct inet_sock *inet = inet_sk((sk = __sk_head(head)));
-
-		if (inet->num == hnum && !sk->sk_node.next &&
-		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
-		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
-		    !sk->sk_bound_dev_if)
-			goto sherry_cache;
-		sk = __inet_lookup_listener(head, daddr, hnum, dif);
-	}
-	if (sk) {
-sherry_cache:
-		sock_hold(sk);
-	}
-	read_unlock(&hashinfo->lhash_lock);
-	return sk;
-}
+				     const unsigned short hnum, const int dif);
 
 /* Socket demux engine toys. */
 #ifdef __BIG_ENDIAN
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -124,8 +124,10 @@ EXPORT_SYMBOL(inet_listen_wlock);
  * remote address for the connection. So always assume those are both
  * wildcarded during the search since they can never be otherwise.
  */
-struct sock *__inet_lookup_listener(const struct hlist_head *head, const u32 daddr,
-				    const unsigned short hnum, const int dif)
+static struct sock *__inet_lookup_listener(const struct hlist_head *head,
+					   const u32 daddr,
+					   const unsigned short hnum,
+					   const int dif)
 {
 	struct sock *result = NULL, *sk;
 	const struct hlist_node *node;
@@ -159,7 +161,34 @@ struct sock *__inet_lookup_listener(cons
 	return result;
 }
 
-EXPORT_SYMBOL_GPL(__inet_lookup_listener);
+/* Optimize the common listener case. */
+struct sock *inet_lookup_listener(struct inet_hashinfo *hashinfo,
+				  const u32 daddr, const unsigned short hnum,
+				  const int dif)
+{
+	struct sock *sk = NULL;
+	const struct hlist_head *head;
+
+	read_lock(&hashinfo->lhash_lock);
+	head = &hashinfo->listening_hash[inet_lhashfn(hnum)];
+	if (!hlist_empty(head)) {
+		const struct inet_sock *inet = inet_sk((sk = __sk_head(head)));
+
+		if (inet->num == hnum && !sk->sk_node.next &&
+		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
+		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
+		    !sk->sk_bound_dev_if)
+			goto sherry_cache;
+		sk = __inet_lookup_listener(head, daddr, hnum, dif);
+	}
+	if (sk) {
+sherry_cache:
+		sock_hold(sk);
+	}
+	read_unlock(&hashinfo->lhash_lock);
+	return sk;
+}
+EXPORT_SYMBOL_GPL(inet_lookup_listener);
 
 /* called with local bh disabled */
 static int __inet_check_established(struct inet_timewait_death_row *death_row,
