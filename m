From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Fri, 13 Aug 2004 20:02:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BvYtU-0002tT-00@gondolin.me.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com>
Cc: netdev@oss.sgi.com, robert.olsson@data.slu.se, hadi@cyberus.ca,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20040812165954.00429e65.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@redhat.com> wrote:
>
> static __inline__ struct in_device *
> in_dev_get(const struct net_device *dev)
> {
>        struct in_device *in_dev;
> 
> -       read_lock(&inetdev_lock);
> +       rcu_read_lock();
>        in_dev = dev->ip_ptr;
>        if (in_dev)
>                atomic_inc(&in_dev->refcnt);
> -       read_unlock(&inetdev_lock);
> +       rcu_read_unlock();
>        return in_dev;
> }
> 
> @@ -157,11 +158,16 @@
> 
> extern void in_dev_finish_destroy(struct in_device *idev);
> 
> -static __inline__ void
> -in_dev_put(struct in_device *idev)
> +static inline void in_dev_rcu_destroy(struct rcu_head *head)
> +{
> +       struct in_device *idev = container_of(head, struct in_device, rcu_head);
> +       in_dev_finish_destroy(idev);
> +}
> +
> +static inline void in_dev_put(struct in_device *idev)
> {
>        if (atomic_dec_and_test(&idev->refcnt))
> -               in_dev_finish_destroy(idev);
> +               call_rcu(&idev->rcu_head, in_dev_rcu_destroy);
> }

This doesn't look right.  The only thing in_dev_get() does in
the critical section is incrementing the refcnt.

But here we're only delaying the destruction of the idev rather
than the dropping of the refcnt.  So the following race can occur
with preemption:

CPU0				CPU1
				in_dev_get
					rcu_read_lock
					in_dev = dev->ip_ptr
inetdev_destroy
	dev->ip_ptr = NULL
	in_dev_put
		--refcnt == 0
		call_rcu
					refcnt++
					rcu_read_unlock
				PREEMPT

			sched point

in_dev_rcu_destroy
				use in_dev => BUG

The obvious thing to do is to move the call_rcu into inetdev_destroy
and get it to call in_dev_put.

But we still need to make sure that nobody increments the count again
without checking in_dev->dev->ip_ptr != NULL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
