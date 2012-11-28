From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Wed, 28 Nov 2012 03:12:31 +0000
Message-ID: <1354072351.2701.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354037000.2116.19.camel@joe-AO722>
	 <1354051475.14302.42.camel@edumazet-glaptop>
	 <1354069414.8918.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33619 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab2K1DMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 22:12:34 -0500
In-Reply-To: <1354069414.8918.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 18:23 -0800, Joe Perches wrote:
> On Tue, 2012-11-27 at 13:24 -0800, Eric Dumazet wrote:
> > On Tue, 2012-11-27 at 09:23 -0800, Joe Perches wrote:
> > > On Tue, 2012-11-27 at 07:06 -0800, Eric Dumazet wrote:
> > > > From: Eric Dumazet <edumazet@google.com>
> > > > 
> > > > commit 68835aba4d9b (net: optimize INET input path further)
> > > > moved some fields used for tcp/udp sockets lookup in the first cache
> > > > line of struct sock_common.
> > > []
> > > > diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> > > > index 5e11905..196ede4 100644
> > > > --- a/include/linux/ipv6.h
> > > > +++ b/include/linux/ipv6.h
> > > > @@ -365,19 +365,21 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
> > > >  #endif /* IS_ENABLED(CONFIG_IPV6) */
> > > >  
> > > >  #define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
> > > > +	(((__sk)->sk_hash == (__hash)) &&					\
> > > > +	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) &&	\
> > > > +	 ((__sk)->sk_family		== AF_INET6)		&&		\
> > > 
> > > Perhaps these could be |'d together to avoid the test/jump
> > > after each comparison by using some bit operations instead.
> > > 
> > > > +	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&&		\
> > > > +	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&&		\
> > > > +	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
> > > > +	 net_eq(sock_net(__sk), (__net)))
> > > 
> > But it would be wrong.
> 
> OK, so it's an and not an or.  Duh.
[...]

The way to combine these sorts of comparisons is along the lines of:

(((left->a ^ right->a) |
  (left->b ^ right->b) |
  ...) == 0)

But when there are big-endian types involved, sparse is likely to
complain about combining them.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
