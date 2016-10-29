From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] udp: do fwd memory scheduling on dequeue
Date: Sat, 29 Oct 2016 05:43:33 -0700
Message-ID: <1477745013.7065.270.camel@edumazet-glaptop3.roam.corp.google.com>
References: <95bb1b780be2e35ff04fb9e1e2c41470a0a15582.1477660091.git.pabeni@redhat.com>
         <1477674975.7065.245.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477677030.7065.250.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477729045.5306.11.camel@redhat.com>
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
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477729045.5306.11.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-10-29 at 10:17 +0200, Paolo Abeni wrote:

> Thank you for working on this. 
> 
> I just gave a very quick look (the WE has started, children are
> screaming ;-), overall the implementation seems quite similar to our
> one.
> 
> I like the additional argument to  ip_cmsg_recv_offset() instead of
> keeping skb->sk set.
> 
> If I read udp_skb_destructor() correctly, the atomic manipulation of
> both sk_rmem_alloc and udp_memory_allocated will happen under the
> receive lock. In our experiments this increment measurably the
> contention on the lock in respect to moving said the operations outside
> the lock (as done in our patch). Do you foreseen any issues with that ?
> AFAICS every in kernel UDP user of skb_recv_datagram() needs to be
> updated with both implementation.

So if you look at tcp, we do not release forward allocation at every
recvmsg(), but rather when we are under tcp memory pressure, or at timer
firing when we know the flow has been idle for a while.

You hit contention on the lock, but the root cause is that right now udp
is very conservative and also hits false sharing on
udp_memory_allocated.

So I believe this is another problem which needs a fix anyway.

No need to make a complicated patch right now, if we know that this
problem will be separately fixed, in another patch ?



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
