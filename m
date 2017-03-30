From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] sock: avoid dirtying sk_stamp, if possible
Date: Thu, 30 Mar 2017 16:23:49 +0200
Message-ID: <1490883829.2616.18.camel@redhat.com>
References: <f29d595f4a72d77730447be2a7c5f243fad47751.1490875313.git.pabeni@redhat.com>
         <1490881940.24891.66.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58208 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933107AbdC3OXv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 10:23:51 -0400
In-Reply-To: <1490881940.24891.66.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 06:52 -0700, Eric Dumazet wrote:
> On Thu, 2017-03-30 at 14:03 +0200, Paolo Abeni wrote:
> > sock_recv_ts_and_drops() unconditionally set sk->sk_stamp for
> > every packet, even if the SOCK_TIMESTAMP flag is not set in the
> > related socket.
> > If selinux is enabled, this cause a cache miss for every packet
> > since sk->sk_stamp and sk->sk_security share the same cacheline.
> > With this change sk_stamp is set only if the SOCK_TIMESTAMP
> > flag is set, and is cleared for the first packet, so that the user
> > perceived behavior is unchanged.
> > 
> > This gives up to 5% speed-up under udp-flood with small packets.
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  include/net/sock.h | 5 ++++-
> >  net/core/sock.c    | 2 +-
> >  2 files changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index cb241a0..8e53158 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -2239,6 +2239,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
> >  void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> >  			      struct sk_buff *skb);
> >  
> > +#define SK_DEFAULT_STAMP (-1L * NSEC_PER_SEC)
> >  static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> >  					  struct sk_buff *skb)
> >  {
> > @@ -2249,8 +2250,10 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> >  
> >  	if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
> >  		__sock_recv_ts_and_drops(msg, sk, skb);
> > -	else
> > +	else if (unlikely(sk->sk_flags & SOCK_TIMESTAMP))
> >  		sk->sk_stamp = skb->tstamp;
> > +	else if (unlikely(sk->sk_stamp == SK_DEFAULT_STAMP))
> > +		sk->sk_stamp = 0;
> >  }
> >  
> 
> This looks very nice, but why using 0 here instead of skb->tstamp ?

Thank you for reviewing this.

The network stack can already mark sk->sk_stamp with 0, if the
'netstamp_needed' static key is false when the packet is received.

'0' is used as a special value by sock_get_timestamp(), providing to
the caller the current ktime. 

This way the kernel is able to detect if no packets have been received
and to provide a somewhat valid timestamp for the last packet received 
before that the SOCK_TIMESTAMP flag was enabled; the assumption is that
the ioctl() follows closely the read call.

This should be the same behavior the user space already observes if net
timestamping is disabled when the SOCK_TIMESTAMP flag is set.

> This might give some regression on applications reading their first
> socket timestamp in some contexts.
> 
> What about 
> 
> if (sk->sk_flags & FLAGS_TS_OR_DROPS || sk->sk_tsflags & TSFLAGS_ANY)
> 	__sock_recv_ts_and_drops(msg, sk, skb);
> else if (unlikely(sk->sk_flags & SOCK_TIMESTAMP ||
>                   sk->sk_stamp == SK_DEFAULT_STAMP))
> 	sk->sk_stamp = skb->tstamp;

That way, if the net timestamp is enable, we will record the timestamp
of the first packet received by the socket (it can be far away in the
past).
I think is just a different kind of approximation.

Cheers,

Paolo
