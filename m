From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] [IPV4]: Use network-order dport for all visible inet_lookup_*
Date: Tue, 8 Aug 2006 18:47:29 +1000
Message-ID: <20060808084729.GA8085@gondor.apana.org.au>
References: <20060808084614.GA6651@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52495 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932453AbWHHIre
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 04:47:34 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060808084614.GA6651@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

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
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -274,7 +274,7 @@ static inline int inet_iif(const struct 
 extern struct sock *
 		inet_lookup_listener(struct inet_hashinfo *hashinfo,
 				     const u32 daddr,
-				     const unsigned short hnum, const int dif);
+				     const u16 dport, const int dif);
 
 /* Socket demux engine toys. */
 #ifdef __BIG_ENDIAN
@@ -328,10 +328,11 @@ extern struct sock *
 static inline struct sock *
 	__inet_lookup_established(struct inet_hashinfo *hashinfo,
 				  const u32 saddr, const u16 sport,
-				  const u32 daddr, const u16 hnum,
+				  const u32 daddr, const u16 dport,
 				  const int dif)
 {
 	INET_ADDR_COOKIE(acookie, saddr, daddr)
+	u16 hnum = ntohs(dport);
 	const __u32 ports = INET_COMBINED_PORTS(sport, hnum);
 	struct sock *sk;
 	const struct hlist_node *node;
@@ -364,12 +365,12 @@ hit:
 
 static inline struct sock *__inet_lookup(struct inet_hashinfo *hashinfo,
 					 const u32 saddr, const u16 sport,
-					 const u32 daddr, const u16 hnum,
+					 const u32 daddr, const u16 dport,
 					 const int dif)
 {
 	struct sock *sk = __inet_lookup_established(hashinfo, saddr, sport, daddr,
-						    hnum, dif);
-	return sk ? : inet_lookup_listener(hashinfo, daddr, hnum, dif);
+						    dport, dif);
+	return sk ? : inet_lookup_listener(hashinfo, daddr, dport, dif);
 }
 
 static inline struct sock *inet_lookup(struct inet_hashinfo *hashinfo,
@@ -380,7 +381,7 @@ static inline struct sock *inet_lookup(s
 	struct sock *sk;
 
 	local_bh_disable();
-	sk = __inet_lookup(hashinfo, saddr, sport, daddr, ntohs(dport), dif);
+	sk = __inet_lookup(hashinfo, saddr, sport, daddr, dport, dif);
 	local_bh_enable();
 
 	return sk;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -607,7 +607,7 @@ static struct sock *dccp_v4_hnd_req(stru
 
 	nsk = __inet_lookup_established(&dccp_hashinfo,
 					iph->saddr, dh->dccph_sport,
-					iph->daddr, ntohs(dh->dccph_dport),
+					iph->daddr, dh->dccph_dport,
 					inet_iif(skb));
 	if (nsk != NULL) {
 		if (nsk->sk_state != DCCP_TIME_WAIT) {
@@ -921,7 +921,7 @@ static int dccp_v4_rcv(struct sk_buff *s
 	 * 	Look up flow ID in table and get corresponding socket */
 	sk = __inet_lookup(&dccp_hashinfo,
 			   skb->nh.iph->saddr, dh->dccph_sport,
-			   skb->nh.iph->daddr, ntohs(dh->dccph_dport),
+			   skb->nh.iph->daddr, dh->dccph_dport,
 			   inet_iif(skb));
 
 	/* 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -163,11 +163,12 @@ static struct sock *__inet_lookup_listen
 
 /* Optimize the common listener case. */
 struct sock *inet_lookup_listener(struct inet_hashinfo *hashinfo,
-				  const u32 daddr, const unsigned short hnum,
+				  const u32 daddr, const u16 dport,
 				  const int dif)
 {
 	struct sock *sk = NULL;
 	const struct hlist_head *head;
+	u16 hnum = ntohs(dport);
 
 	read_lock(&hashinfo->lhash_lock);
 	head = &hashinfo->listening_hash[inet_lhashfn(hnum)];
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -950,7 +950,7 @@ static struct sock *tcp_v4_hnd_req(struc
 
 	nsk = __inet_lookup_established(&tcp_hashinfo, skb->nh.iph->saddr,
 					th->source, skb->nh.iph->daddr,
-					ntohs(th->dest), inet_iif(skb));
+					th->dest, inet_iif(skb));
 
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
