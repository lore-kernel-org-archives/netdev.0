From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH] [TCP]: remove dead code in init_sequence
Date: Fri, 10 Nov 2006 12:04:31 +0000
Message-ID: <200611101204.31644@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:3572 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1946522AbWKJMEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 07:04:51 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This removes two redundancies:

1) The test (skb->protocol == htons(ETH_P_IPV6) in tcp_v6_init_sequence()
   is always true, due to
	* tcp_v6_conn_request() is the only function calling this one
	* tcp_v6_conn_request() redirects all skb's with ETH_P_IP protocol to
	  tcp_v4_conn_request() [ cf. top of tcp_v6_conn_request()]

2) The first argument, `struct sock *sk' of tcp_v{4,6}_init_sequence() is 
   never used.

Patch has been tested.


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv6/tcp_ipv6.c |   19 ++++++-------------
 2 files changed, 8 insertions(+), 15 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5fbf965..2eb5884 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -111,7 +111,7 @@ void tcp_unhash(struct sock *sk)
 	inet_unhash(&tcp_hashinfo, sk);
 }
 
-static inline __u32 tcp_v4_init_sequence(struct sock *sk, struct sk_buff *skb)
+static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(skb->nh.iph->daddr,
 					  skb->nh.iph->saddr,
@@ -859,7 +859,7 @@ #endif
 			goto drop_and_free;
 		}
 
-		isn = tcp_v4_init_sequence(sk, skb);
+		isn = tcp_v4_init_sequence(skb);
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 06b536b..9a8e690 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -106,19 +106,12 @@ static __inline__ u16 tcp_v6_check(struc
 	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_TCP, base);
 }
 
-static __u32 tcp_v6_init_sequence(struct sock *sk, struct sk_buff *skb)
+static __u32 tcp_v6_init_sequence(struct sk_buff *skb)
 {
-	if (skb->protocol == htons(ETH_P_IPV6)) {
-		return secure_tcpv6_sequence_number(skb->nh.ipv6h->daddr.s6_addr32,
-						    skb->nh.ipv6h->saddr.s6_addr32,
-						    skb->h.th->dest,
-						    skb->h.th->source);
-	} else {
-		return secure_tcp_sequence_number(skb->nh.iph->daddr,
-						  skb->nh.iph->saddr,
-						  skb->h.th->dest,
-						  skb->h.th->source);
-	}
+	return secure_tcpv6_sequence_number(skb->nh.ipv6h->daddr.s6_addr32,
+					    skb->nh.ipv6h->saddr.s6_addr32,
+					    skb->h.th->dest,
+					    skb->h.th->source);
 }
 
 static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr, 
@@ -822,7 +815,7 @@ static int tcp_v6_conn_request(struct so
 		treq->iif = inet6_iif(skb);
 
 	if (isn == 0) 
-		isn = tcp_v6_init_sequence(sk,skb);
+		isn = tcp_v6_init_sequence(skb);
 
 	tcp_rsk(req)->snt_isn = isn;
 
