From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH net-next] tcp: suppress too verbose messages in tcp_send_ack()
Date: Wed, 25 Nov 2015 22:17:45 -0500
Message-ID: <f7t7fl51mau.fsf@aconole.bos.csb>
References: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<f7t7fl5g2ao.fsf@aconole.bos.csb>
	<1448490758.24696.53.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448490937.24696.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908AbbKZDRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 22:17:48 -0500
In-Reply-To: <1448490937.24696.55.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 25 Nov 2015 14:35:37 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2015-11-25 at 14:32 -0800, Eric Dumazet wrote:
>> On Wed, 2015-11-25 at 17:08 -0500, Aaron Conole wrote:
>> 
>> > > diff --git a/include/net/sock.h b/include/net/sock.h
>> > > index 7f89e4ba18d1..ead514332ae8 100644
>> > > --- a/include/net/sock.h
>> > > +++ b/include/net/sock.h
>> > > @@ -776,7 +776,7 @@ static inline int sk_memalloc_socks(void)
>> > >  
>> > >  static inline gfp_t sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
>> > >  {
>> > > -	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
>> > > +	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
>> > >  }
>> > >  
>> > 
>> > Sorry if I'm missing something obvious here, but with a name like
>> > sk_gfp_atomic, would it make sense to keep the GFP_ATOMIC mask as well?
>> > Otherwise, what is the _atomic is saying?
>> 
>> Not sure what you suggest.
>> 
>> Are you suggesting I remove GFP_ATOMIC from all callers ?

That's an option, and one that looks pretty clean.

>> I am fine with this, but looks more invasive, and who knows, maybe one
>> caller might want to not use GFP_ATOMIC one day (like : do not attempt
>> to use reserves)

Probably that would call for a different more primitive version of this
API (sk_gfp_or_memalloc() as you suggest below). Then this could be
written in terms of that

static inline sk_gfp_or_memalloc(const struct sock *sk, gfp_t gfp_mask)
{
	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
}

static inline sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
{
	return sk_gfp_or_memalloc(sk, gfp_mask | GFP_ATOMIC);
}

Not sure if it's "too much API".

>> This sk_gfp_atomic() helper has a misleading name, since all it wanted
>> was to conditionally OR a caller provided flag (mostly GFP_ATOMIC one)
>> with __GFP_MEMALLOC for some special sockets.
>> 
>> Should have been sk_gfp_or_memalloc() or something...
>> 
>
> BTW original commit changelog was clear and matches my expectations :
>
> commit 99a1dec70d5acbd8c6b3928cdebb4a2d1da676c8
> Author: Mel Gorman <mgorman@suse.de>
> Date:   Tue Jul 31 16:44:14 2012 -0700
>
>     net: introduce sk_gfp_atomic() to allow addition of GFP flags
> depending on the individual socket
>     
>     Introduce sk_gfp_atomic(), this function allows to inject sock specific
>     flags to each sock related allocation.  It is only used on allocation
>     paths that may be required for writing pages back to network storage.

Cool. If you think my suggestion is too much for this set, that's
fine. I understand not wanting to be too intrusive.

Thanks,
Aaron
