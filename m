From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] udp: implement memory accounting helpers
Date: Thu, 22 Sep 2016 18:14:24 +0200
Message-ID: <1474560864.4845.78.camel@redhat.com>
References: <cover.1474477902.git.pabeni@redhat.com>
         <93ccb49b7f037461ef436a50b907185744b093d8.1474477902.git.pabeni@redhat.com>
         <1474500682.23058.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <1474540415.4845.69.camel@redhat.com>
         <589839b3-5930-2527-b0a3-315be254a175@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <589839b3-5930-2527-b0a3-315be254a175-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-22 at 16:21 +0100, Edward Cree wrote:
> On 22/09/16 11:33, Paolo Abeni wrote:
> > Hi Eric,
> >
> > On Wed, 2016-09-21 at 16:31 -0700, Eric Dumazet wrote:
> >> Also does inet_diag properly give the forward_alloc to user ?
> >>
> >> $ ss -mua
> >> State      Recv-Q Send-Q Local Address:Port                 Peer Addres
> >> s:Port
> >> UNCONN     51584  0          *:52460      *:*                    
> >> 	 skmem:(r51584,rb327680,t0,tb327680,f1664,w0,o0,bl0,d575)
> > Thank you very much for reviewing this! 
> >
> > My bad, there is still a race which leads to temporary negative values
> > of fwd. I feel the fix is trivial but it needs some investigation.
> >
> >> Couldn't we instead use an union of an atomic_t and int for
> >> sk->sk_forward_alloc ?
> > That was our first attempt, but we had some issue on mem scheduling; if
> > we use:
> >
> >    if (atomic_sub_return(size, &sk->sk_forward_alloc_atomic) < 0) {
> >         // fwd alloc
> >    }
> >
> > that leads to inescapable, temporary, negative value for
> > sk->sk_forward_alloc.
> >
> > Another option would be:
> >
> > again:
> >         fwd = atomic_read(&sk->sk_forward_alloc_atomic);
> >         if (fwd > size) {
> > 		if (atomic_cmpxchg(&sk->sk_forward_alloc_atomic, fwd, fwd - size) != fwd)
> > 			goto again;
> >         } else 
> >             // fwd alloc
> >
> > which would be bad under high contention.
> Apologies if I'm misunderstanding the problem, but couldn't you have two
> atomic_t fields, 'internal' and 'external' forward_alloc.  Then
>     if (atomic_sub_return(size, &sk->sk_forward_alloc_internal) < 0) {
>         atomic_sub(size, &sk->sk_forward_alloc);
>         // fwd alloc
>     } else {
>         atomic_add(size, &sk->sk_forward_alloc_internal);
>     }
> or something like that.  Then sk->sk_forward_alloc never sees a negative
> value, and is always >= sk->sk_forward_alloc_internal.  Of course places
> that go the other way would have to add to sk->sk_forward_alloc first,
> before adding to sk->sk_forward_alloc_internal, to maintain that invariant.

I think that the idea behind using atomic ops directly on
sk_forward_alloc is to avoid adding other fields to the udp_socket. 

If we can add some fields to the udp_sock structure, the schema proposed
in this patch should fit better (modulo bugs ;-), always requiring a
single atomic operation at memory reclaiming time and at memory
allocation time.

Paolo

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
