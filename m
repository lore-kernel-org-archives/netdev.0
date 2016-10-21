From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v5 2/3] udp: implement memory accounting helpers
Date: Fri, 21 Oct 2016 13:43:41 +0200
Message-ID: <1477050221.4606.6.camel@redhat.com>
References: <cover.1476979679.git.pabeni@redhat.com>
         <d932905c2581df9415449216eceeed1566290e3e.1476979679.git.pabeni@redhat.com>
         <1476997834.7065.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476997834.7065.35.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-10-20 at 14:10 -0700, Eric Dumazet wrote:
> On Thu, 2016-10-20 at 22:31 +0200, Paolo Abeni wrote:
> 
> > +
> > +int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
> > +{
> > +	struct sk_buff_head *list = &sk->sk_receive_queue;
> > +	int rmem, delta, amt, err = -ENOMEM;
> > +	int size = skb->truesize;
> > +
> > +	/* try to avoid the costly atomic add/sub pair when the receive
> > +	 * queue is full; always allow at least a packet
> > +	 */
> > +	rmem = atomic_read(&sk->sk_rmem_alloc);
> > +	if (rmem && (rmem + size > sk->sk_rcvbuf))
> > +		goto drop;
> > +
> > +	/* we drop only if the receive buf is full and the receive
> > +	 * queue contains some other skb
> > +	 */
> > +	rmem = atomic_add_return(size, &sk->sk_rmem_alloc);
> > +	if ((rmem > sk->sk_rcvbuf) && (rmem > size))
> > +		goto uncharge_drop;
> > +
> > +	skb_orphan(skb);
> 
> Minor point :
> 
> UDP should already have orphaned skbs ? (it uses skb_steal_sock())

You are right, the skb_orphan() call is redundant. 

I'll send the v6 soon.

Thank you,

Paolo


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
