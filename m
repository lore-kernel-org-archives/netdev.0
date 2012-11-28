From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Tue, 27 Nov 2012 18:23:34 -0800
Message-ID: <1354069414.8918.13.camel@joe-AO722>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354037000.2116.19.camel@joe-AO722>
	 <1354051475.14302.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49096 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750763Ab2K1CXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 21:23:35 -0500
In-Reply-To: <1354051475.14302.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 13:24 -0800, Eric Dumazet wrote:
> On Tue, 2012-11-27 at 09:23 -0800, Joe Perches wrote:
> > On Tue, 2012-11-27 at 07:06 -0800, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > commit 68835aba4d9b (net: optimize INET input path further)
> > > moved some fields used for tcp/udp sockets lookup in the first cache
> > > line of struct sock_common.
> > []
> > > diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> > > index 5e11905..196ede4 100644
> > > --- a/include/linux/ipv6.h
> > > +++ b/include/linux/ipv6.h
> > > @@ -365,19 +365,21 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
> > >  #endif /* IS_ENABLED(CONFIG_IPV6) */
> > >  
> > >  #define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
> > > +	(((__sk)->sk_hash == (__hash)) &&					\
> > > +	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) &&	\
> > > +	 ((__sk)->sk_family		== AF_INET6)		&&		\
> > 
> > Perhaps these could be |'d together to avoid the test/jump
> > after each comparison by using some bit operations instead.
> > 
> > > +	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&&		\
> > > +	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&&		\
> > > +	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
> > > +	 net_eq(sock_net(__sk), (__net)))
> > 
> But it would be wrong.

OK, so it's an and not an or.  Duh.

Still, the logical tests that are likely to be in the same
cacheline could be ANDed together to avoid a test and jump.

Perhaps this:

It shrinks the object a trivial bit and could be a tiny bit
faster too.

(allyesconfig x86/32)
$ size net/ipv6/inet6_hashtables.o*
   text	   data	    bss	    dec	    hex	filename
   6277	    962	   1832	   9071	   236f	net/ipv6/inet6_hashtables.o.new
   6381	    962	   1880	   9223	   2407	net/ipv6/inet6_hashtables.o.old

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 196ede4..91870de 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -364,22 +364,24 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #define inet_v6_ipv6only(__sk)		0
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
-#define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) &&					\
-	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) &&	\
-	 ((__sk)->sk_family		== AF_INET6)		&&		\
-	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&&		\
-	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&&		\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
+#define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif) \
+	((((__sk)->sk_hash == (__hash)) &				\
+	  ((__sk)->sk_family == AF_INET6)) &&				\
+	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) && \
+	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr)) &&		\
+	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr)) &&	\
+	 (!((__sk)->sk_bound_dev_if) ||					\
+	  ((__sk)->sk_bound_dev_if == (__dif))) &&			\
 	 net_eq(sock_net(__sk), (__net)))
 
 #define INET6_TW_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif) \
-	(((__sk)->sk_hash == (__hash)) &&					\
-	 (*((__portpair *)&(inet_twsk(__sk)->tw_dport)) == (__ports))	&&	\
-	 ((__sk)->sk_family	       == PF_INET6)			&&	\
-	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr)))	&&	\
-	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr))) &&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
+	((((__sk)->sk_hash == (__hash)) &				\
+	  ((__sk)->sk_family == PF_INET6)) &&				\
+	 (*((__portpair *)&(inet_twsk(__sk)->tw_dport)) == (__ports)) && \
+	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr))) && \
+	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr))) && \
+	 (!((__sk)->sk_bound_dev_if) ||					\
+	  ((__sk)->sk_bound_dev_if == (__dif))) &&			\
 	 net_eq(sock_net(__sk), (__net)))
 
 #endif /* _IPV6_H */
