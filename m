From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Sun, 17 Mar 2013 08:53:10 +0100
Message-ID: <20130317075310.GG24041@order.stressinduktion.org>
References: <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6> <1362494795.15793.113.camel@edumazet-glaptop> <alpine.DEB.2.02.1303061631290.6723@dflat> <1362663990.15793.208.camel@edumazet-glaptop> <alpine.DEB.2.02.1303141359080.16308@dflat> <1363301786.29475.40.camel@edumazet-glaptop> <alpine.DEB.2.02.1303141610490.16308@dflat> <1363303174.29475.46.camel@edumazet-glaptop> <1363455366.29475.66.camel@edumazet-glaptop> <20130317063948.GF24041@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	dormando <dormando@rydia.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39810 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782Ab3CQHxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 03:53:11 -0400
Content-Disposition: inline
In-Reply-To: <20130317063948.GF24041@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 17, 2013 at 07:39:48AM +0100, Hannes Frederic Sowa wrote:
> On Sat, Mar 16, 2013 at 10:36:06AM -0700, Eric Dumazet wrote:
> > On Fri, 2013-03-15 at 00:19 +0100, Eric Dumazet wrote:
> > 
> > > Thanks thats really useful, we might miss to increment socket refcount
> > > in a timer setup.
> > > 
> > 
> > Hmm, please add following debugging patch as well
> > 
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 14f6e9d..fe7c8a6 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -530,7 +530,9 @@ static inline void sock_hold(struct sock *sk)
> >   */
> >  static inline void __sock_put(struct sock *sk)
> >  {
> > -	atomic_dec(&sk->sk_refcnt);
> > +	int newref = atomic_dec_return(&sk->sk_refcnt);
> > +
> > +	BUG_ON(newref <= 0);
> >  }
> 
> Couldn't it also be a free from sock_wfree where the wmem accounting went
> wrong? It does not care about reference counts there.

nvm, it had to be in the stacktrace then.
