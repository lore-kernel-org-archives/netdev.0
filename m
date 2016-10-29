From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] udp: do fwd memory scheduling on dequeue
Date: Sat, 29 Oct 2016 10:17:25 +0200
Message-ID: <1477729045.5306.11.camel@redhat.com>
References: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
         <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477677030.7065.250.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477677030.7065.250.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-28 at 10:50 -0700, Eric Dumazet wrote:
> On Fri, 2016-10-28 at 10:16 -0700, Eric Dumazet wrote:
> > Nice !
> > 
> > I was working on this as well and my implementation was somewhat
> > different.
> 
> This is my WIP
> 
> Note this can be split in two parts.
> 
> 1) One adding struct sock *sk param to ip_cmsg_recv_offset()
>  
>    This was because I left skb->sk NULL for skbs stored in receive
> queue.
>    You chose instead to set skb->sk, which is unusual (check
> skb_orphan() BUG_ON())
> 
> 2) Udp changes.
> 
> Tell me what you think, thanks again !

Thank you for working on this. 

I just gave a very quick look (the WE has started, children are
screaming ;-), overall the implementation seems quite similar to our
one.

I like the additional argument to  ip_cmsg_recv_offset() instead of
keeping skb->sk set.

If I read udp_skb_destructor() correctly, the atomic manipulation of
both sk_rmem_alloc and udp_memory_allocated will happen under the
receive lock. In our experiments this increment measurably the
contention on the lock in respect to moving said the operations outside
the lock (as done in our patch). Do you foreseen any issues with that ?
AFAICS every in kernel UDP user of skb_recv_datagram() needs to be
updated with both implementation.

Cheers,

Paolo

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
