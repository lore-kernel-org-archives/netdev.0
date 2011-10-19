From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:35:48 +0200
Message-ID: <1319031348.1286.4.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4)  <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319029794.4424.37.camel@jlt3.sipsolutions.net>
	 <1319030740.8416.14.camel@edumazet-laptop>
	 (sfid-20111019_152616_037809_8B36A3CC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:46080 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab1JSNfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:35:52 -0400
In-Reply-To: <1319030740.8416.14.camel@edumazet-laptop> (sfid-20111019_152616_037809_8B36A3CC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 15:25 +0200, Eric Dumazet wrote:

> > Given the complexity of all this, I'm not sure we shouldn't do something
> > like this, but I have no idea what the cost would be:
> > 
> > --- wireless-testing.orig/include/net/sock.h	2011-10-18 22:28:41.000000000 +0200
> > +++ wireless-testing/include/net/sock.h	2011-10-19 15:08:45.000000000 +0200
> > @@ -434,7 +434,10 @@ static __inline__ int __sk_del_node_init
> >  
> >  static inline void sock_hold(struct sock *sk)
> >  {
> > -	atomic_inc(&sk->sk_refcnt);
> > +	if (atomic_inc_return(&sk->sk_refcnt) == 1) {
> > +		/* was zero -- we must've gotten an sk_wmem_alloc reference */
> > +		atomic_inc(&sk->sk_wmem_alloc);
> > +	}
> >  }
> >  
> 
> Hmm, it will be difficult to handle two atomics without adding races,

Where do you see a race? If you do sock_hold() while you have a 'proper
sk_refcnt reference', this does nothing but increase sk_refcnt. If you
do sock_hold() while you have an 'sk_wmem_alloc reference', this will
actually increase sk_wmem_alloc by 1; then when the original
'sk_wmem_alloc reference' you had when calling sock_hold() is released,
sk_wmem_alloc will still have 1 matching a non-zero sk_refcnt.


> and add quite expensive atomic_inc_return() on some arches.

Yes I was afraid of that.

> I would just change the skb tx cloning to take a normal reference on
> sk_wmem_alloc
> 
> 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
> instead of
> 	sock_hold(sk);

Even with that fixed I'm not really convinced of it all -- need to
really really really make sure that no skb->sk that was owned by a TX
skb is ever passed to sock_hold(). Can we really guarantee that?

johannes
