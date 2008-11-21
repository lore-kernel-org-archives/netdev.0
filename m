From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: use net_eq() in INET_MATCH and INET_TW_MATCH
Date: Fri, 21 Nov 2008 23:31:25 +0100
Message-ID: <492736BD.5040508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060409040408000106060704"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34675 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbYKUWba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 17:31:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060409040408000106060704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We can avoid some useless instructions if !CONFIG_NET_NS

Because of RCU, we use INET_MATCH or INET_TW_MATCH twice 
for the found socket, so thats six instructions less per
incoming TCP packet.

Yet another tbench speedup :)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------060409040408000106060704
Content-Type: text/plain;
 name="INET_MATCH.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="INET_MATCH.patch"

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 28b3ee3..ec7ee2e 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -291,25 +291,25 @@ typedef __u64 __bitwise __addrpair;
 				   ((__force __u64)(__be32)(__saddr)));
 #endif /* __BIG_ENDIAN */
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
+	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
 	 ((*((__addrpair *)&(inet_sk(__sk)->daddr))) == (__cookie))	&&	\
 	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))	&&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #define INET_TW_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
+	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
 	 ((*((__addrpair *)&(inet_twsk(__sk)->tw_daddr))) == (__cookie)) &&	\
 	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr)
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
+	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
 	 (inet_sk(__sk)->daddr		== (__saddr))		&&	\
 	 (inet_sk(__sk)->rcv_saddr	== (__daddr))		&&	\
 	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))	&&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #define INET_TW_MATCH(__sk, __net, __hash,__cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
+	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
 	 (inet_twsk(__sk)->tw_daddr	== (__saddr))		&&	\
 	 (inet_twsk(__sk)->tw_rcv_saddr	== (__daddr))		&&	\
 	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\

--------------060409040408000106060704--
