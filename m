From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 15:30:35 -0700
Message-ID: <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426027533.11398.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.175345.836846566788322568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:42940 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbCKWai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 18:30:38 -0400
Received: by obbnt9 with SMTP id nt9so12263791obb.9
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 15:30:37 -0700 (PDT)
In-Reply-To: <20150311.175345.836846566788322568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 17:53 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 10 Mar 2015 15:45:33 -0700
> 
> > diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> > index 14d02ea905b6..a097ae38b639 100644
> > --- a/net/ipv4/inet_connection_sock.c
> > +++ b/net/ipv4/inet_connection_sock.c
> > @@ -678,7 +678,8 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
> >  		newsk->sk_write_space = sk_stream_write_space;
> >  
> >  		newsk->sk_mark = inet_rsk(req)->ir_mark;
> > -
> > +		atomic64_cmpxchg(&newsk->sk_cookie, 0,
> > +				 atomic64_read(&inet_rsk(req)->ir_cookie));
> >  		newicsk->icsk_retransmits = 0;
> >  		newicsk->icsk_backoff	  = 0;
> >  		newicsk->icsk_probes_out  = 0;
> 
> I think you have to be more careful here.
> 
> sk_clone_lock() is not going to zero out sk_cookie for you, it only
> does so if the priority has __GFP_ZERO in it and some callsites use
> just plain GFP_ATOMIC.
> 
> Therefore, you can't just assume sk_cookie is zero.
> 
> Just use atomic64_set() here, you have exclusive access to this piece
> of memory at this point in time, and you'll save an unnecessary atomic
> operation as well.

Note that sk_clone_lock() really does the clear for us :

net/core/sock.c:1541:		atomic64_set(&newsk->sk_cookie, 0);

atomic_cmpxchg() is needed here in case a concurrent dumper already
caught the new socket.

I thought of adding a 'u64 cookie' parameter to sk_clone(), but it
probably can be done in a followup patch, not sure it is worth the
complexity.

This would avoid the atomic64_cmpxchg(), but we also simply can avoid
this atomic64_cmpxchg() if inet_rsk(req)->ir_cookie is 0, as it is
probably 0 anyway.

I can send a v2 with :

u64 cookie = atomic64_read(&inet_rsk(req)->ir_cookie);
if (cookie)
	atomic64_cmpxchg(&newsk->sk_cookie, 0, cooke);

Thanks !
