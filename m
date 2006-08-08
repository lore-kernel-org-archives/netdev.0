From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] [IPV4]: Use network-order dport for all visible inet_lookup_*
Date: Tue, 8 Aug 2006 21:11:40 +1000
Message-ID: <20060808111140.GA15028@gondor.apana.org.au>
References: <20060808084614.GA6651@gondor.apana.org.au> <20060808084729.GA8085@gondor.apana.org.au> <20060808.022443.62664150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49170 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964832AbWHHLLt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 07:11:49 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.022443.62664150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 02:24:43AM -0700, David Miller wrote:
> 
> This isn't so nice because we will now byte-swap the port twice when
> we try looking up a listening socket.  Once for the established lookup
> and once for the listening hash lookup.
> 
> It should be easy to do the byte-swap once at a higher level right?

Good point.  This patch eliminates the double swap for __inet_lookup.

[IPV4]: Use network-order dport for all visible inet_lookup_*

Right now most inet_lookup_* functions take a host-order hnum instead
of a network-order dport because that's how it is represented internally.

This means that users of these functions have to be careful about using
the right byte-order.  To add more confusion, inet_lookup takes a
network-order dport unlike all other functions.

So this patch changes all visible inet_lookup functions to take a dport
and move all dport->hnum conversion inside them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
e27e3b120697dfcf46a840291de318123e9b78f4
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index bd513f3..b4491c9 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -271,10 +271,16 @@ static inline int inet_iif(const struct 
 	return ((struct rtable *)skb->dst)->rt_iif;
 }
 
-extern struct sock *
-		inet_lookup_listener(struct inet_hashinfo *hashinfo,
-				     const u32 daddr,
-				     const unsigned short hnum, const int dif);
+extern struct sock *__inet_lookup_listener(struct inet_hashinfo *hashinfo,
+					   const u32 daddr,
+					   const unsigned short hnum,
+					   const int dif);
+
+static inline struct sock *inet_lookup_listener(struct inet_hashinfo *hashinfo,
+						u32 daddr, u16 dport, int dif)
+{
+	return __inet_lookup_listener(hashinfo, daddr, ntohs(dport), dif);
+}
 
 /* Socket demux engine toys. */
 #ifdef __BIG_ENDIAN
@@ -362,14 +368,25 @@ hit:
 	goto out;
 }
 
+static inline struct sock *
+	inet_lookup_established(struct inet_hashinfo *hashinfo,
+				const u32 saddr, const u16 sport,
+				const u32 daddr, const u16 dport,
+				const int dif)
+{
+	return __inet_lookup_established(hashinfo, saddr, sport, daddr,
+					 ntohs(dport), dif);
+}
+
 static inline struct sock *__inet_lookup(struct inet_hashinfo *hashinfo,
 					 const u32 saddr, const u16 sport,
-					 const u32 daddr, const u16 hnum,
+					 const u32 daddr, const u16 dport,
 					 const int dif)
 {
+	u16 hnum = ntohs(dport);
 	struct sock *sk = __inet_lookup_established(hashinfo, saddr, sport, daddr,
 						    hnum, dif);
-	return sk ? : inet_lookup_listener(hashinfo, daddr, hnum, dif);
+	return sk ? : __inet_lookup_listener(hashinfo, daddr, hnum, dif);
 }
 
 static inline struct sock *inet_lookup(struct inet_hashinfo *hashinfo,
@@ -380,7 +397,7 @@ static inline struct sock *inet_lookup(s
 	struct sock *sk;
 
 	local_bh_disable();
-	sk = __inet_lookup(hashinfo, saddr, sport, daddr, ntohs(dport), dif);
+	sk = __inet_lookup(hashinfo, saddr, sport, daddr, dport, dif);
 	local_bh_enable();
 
 	return sk;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 7f56f7e..58c3275 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -605,10 +605,10 @@ static struct sock *dccp_v4_hnd_req(stru
 	if (req != NULL)
 		return dccp_check_req(sk, skb, req, prev);
 
-	nsk = __inet_lookup_established(&dccp_hashinfo,
-					iph->saddr, dh->dccph_sport,
-					iph->daddr, ntohs(dh->dccph_dport),
-					inet_iif(skb));
+	nsk = inet_lookup_established(&dccp_hashinfo,
+				      iph->saddr, dh->dccph_sport,
+				      iph->daddr, dh->dccph_dport,
+				      inet_iif(skb));
 	if (nsk != NULL) {
 		if (nsk->sk_state != DCCP_TIME_WAIT) {
 			bh_lock_sock(nsk);
@@ -921,7 +921,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 	 * 	Look up flow ID in table and get corresponding socket */
 	sk = __inet_lookup(&dccp_hashinfo,
 			   skb->nh.iph->saddr, dh->dccph_sport,
-			   skb->nh.iph->daddr, ntohs(dh->dccph_dport),
+			   skb->nh.iph->daddr, dh->dccph_dport,
 			   inet_iif(skb));
 
 	/* 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index bfc3906..fb296c9 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -124,10 +124,10 @@ EXPORT_SYMBOL(inet_listen_wlock);
  * remote address for the connection. So always assume those are both
  * wildcarded during the search since they can never be otherwise.
  */
-static struct sock *__inet_lookup_listener(const struct hlist_head *head,
-					   const u32 daddr,
-					   const unsigned short hnum,
-					   const int dif)
+static struct sock *inet_lookup_listener_slow(const struct hlist_head *head,
+					      const u32 daddr,
+					      const unsigned short hnum,
+					      const int dif)
 {
 	struct sock *result = NULL, *sk;
 	const struct hlist_node *node;
@@ -162,9 +162,9 @@ static struct sock *__inet_lookup_listen
 }
 
 /* Optimize the common listener case. */
-struct sock *inet_lookup_listener(struct inet_hashinfo *hashinfo,
-				  const u32 daddr, const unsigned short hnum,
-				  const int dif)
+struct sock *__inet_lookup_listener(struct inet_hashinfo *hashinfo,
+				    const u32 daddr, const unsigned short hnum,
+				    const int dif)
 {
 	struct sock *sk = NULL;
 	const struct hlist_head *head;
@@ -179,7 +179,7 @@ struct sock *inet_lookup_listener(struct
 		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
 		    !sk->sk_bound_dev_if)
 			goto sherry_cache;
-		sk = __inet_lookup_listener(head, daddr, hnum, dif);
+		sk = inet_lookup_listener_slow(head, daddr, hnum, dif);
 	}
 	if (sk) {
 sherry_cache:
@@ -188,7 +188,7 @@ sherry_cache:
 	read_unlock(&hashinfo->lhash_lock);
 	return sk;
 }
-EXPORT_SYMBOL_GPL(inet_lookup_listener);
+EXPORT_SYMBOL_GPL(__inet_lookup_listener);
 
 /* called with local bh disabled */
 static int __inet_check_established(struct inet_timewait_death_row *death_row,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4b04c3e..ba3e2a7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -948,9 +948,9 @@ static struct sock *tcp_v4_hnd_req(struc
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
 
-	nsk = __inet_lookup_established(&tcp_hashinfo, skb->nh.iph->saddr,
-					th->source, skb->nh.iph->daddr,
-					ntohs(th->dest), inet_iif(skb));
+	nsk = inet_lookup_established(&tcp_hashinfo, skb->nh.iph->saddr,
+				      th->source, skb->nh.iph->daddr,
+				      th->dest, inet_iif(skb));
 
 	if (nsk) {
 		if (nsk->sk_state != TCP_TIME_WAIT) {
@@ -1087,7 +1087,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
 	sk = __inet_lookup(&tcp_hashinfo, skb->nh.iph->saddr, th->source,
-			   skb->nh.iph->daddr, ntohs(th->dest),
+			   skb->nh.iph->daddr, th->dest,
 			   inet_iif(skb));
 
 	if (!sk)
@@ -1165,7 +1165,7 @@ do_time_wait:
 	case TCP_TW_SYN: {
 		struct sock *sk2 = inet_lookup_listener(&tcp_hashinfo,
 							skb->nh.iph->daddr,
-							ntohs(th->dest),
+							th->dest,
 							inet_iif(skb));
 		if (sk2) {
 			inet_twsk_deschedule((struct inet_timewait_sock *)sk,
