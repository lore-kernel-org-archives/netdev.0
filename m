From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Fri, 01 Aug 2008 00:00:05 -0700 (PDT)
Message-ID: <20080801.000005.102314582.davem@davemloft.net>
References: <20080727203757.GA2527@ami.dom.local>
	<20080731.052932.110299354.davem@davemloft.net>
	<20080801064810.GA4435@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-BkyiQQGWkgE@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080801064810.GA4435-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 1 Aug 2008 06:48:10 +0000

> On Thu, Jul 31, 2008 at 05:29:32AM -0700, David Miller wrote:
> > +		/* No need to grab the _xmit_lock here.  If the
> > +		 * queue is not stopped for another reason, we
> > +		 * force a schedule.
> > +		 */
> > +		clear_bit(__QUEUE_STATE_FROZEN, &txq->state);
> 
> The comments in asm-x86/bitops.h to set_bit/clear_bit are rather queer
> about reordering on non x86: isn't eg. smp_mb_before_clear_bit()
> useful  here?

It doesn't matter, we need no synchronization here at all.

We unconditionally perform a __netif_schedule(), and that
will run the TX queue on the local cpu.  We will take the
_xmit_lock at least once time if in fact the queue was not
stopped before the first froze it.

> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 63d6bcd..69320a5 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4200,6 +4200,7 @@ static void netdev_init_queues(struct net_device *dev)
> >  {
> >  	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
> >  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> > +	spin_lock_init(&dev->tx_global_lock);
> 
> This will probably need some lockdep annotations similar to
> _xmit_lock.

I highly doubt it.  It will never be taken nested with another
device's instance.

It is only ->hard_start_xmit() leading to another ->hard_start_xmit()
where this can currently happen, but tx_global_lock will not be used
in such paths.

> > @@ -135,7 +135,8 @@ static inline int qdisc_restart(struct Qdisc *q)
> >  	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> >  
> >  	HARD_TX_LOCK(dev, txq, smp_processor_id());
> > -	if (!netif_subqueue_stopped(dev, skb))
> > +	if (!netif_tx_queue_stopped(txq) &&
> > +	    !netif_tx_queue_frozen(txq))
> >  		ret = dev_hard_start_xmit(skb, dev, txq);
> >  	HARD_TX_UNLOCK(dev, txq);
> 
> This thing is the most doubtful to me: before this patch callers would
> wait on this lock. Now they take the lock without problems, check the
> flags, and let to take this lock again, doing some re-queing in the
> meantime.
>
> So, it seems HARD_TX_LOCK should rather do some busy looping now with
> a trylock, and re-checking the _FROZEN flag. Maybe even this should
> be done in __netif_tx_lock(). On the other hand, this shouldn't block
> too much the owner of tx_global_lock() with taking such a lock.

'ret' will be NETDEV_TX_BUSY in such a case (finding the queue
frozen), which will cause the while() loop in __qdisc_run() to
terminate.

The freezer will unconditionally schedule a new __qdisc_run()
when it unfreezes the queue.

Sure it's possible for some cpus to bang in and out of there
a few times, but that's completely harmless.  And it can only
happen a few times since this freeze state is only held across
a critical section.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
