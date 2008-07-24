From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Thu, 24 Jul 2008 11:10:48 +0200
Message-ID: <1216890648.7257.258.camel@twins>
References: <1216810696.7257.175.camel@twins>
	 <20080723113519.GE4561@ff.dom.local> <20080723114914.GF4561@ff.dom.local>
	 <20080723.131607.79681752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Paul E McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080723.131607.79681752.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2008-07-23 at 13:16 -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 23 Jul 2008 11:49:14 +0000
> 
> > On Wed, Jul 23, 2008 at 11:35:19AM +0000, Jarek Poplawski wrote:
> > > On Wed, Jul 23, 2008 at 12:58:16PM +0200, Peter Zijlstra wrote:
> > ...
> > > > When I look at the mac802.11 code in ieee80211_tx_pending() it looks
> > > > like it can do with just one lock at a time, instead of all - but I
> > > > might be missing some obvious details.
> > > > 
> > > > So I guess my question is, is netif_tx_lock() here to stay, or is the
> > > > right fix to convert all those drivers to use __netif_tx_lock() which
> > > > locks only a single queue?
> > > > 
> > > 
> > > It's a new thing mainly for new hardware/drivers, and just after
> > > conversion (older drivers effectively use __netif_tx_lock()), so it'll
> > > probably stay for some time until something better is found. David,
> > > will tell the rest, I hope.
> > 
> > ...And, of course, these new drivers should also lock a single queue
> > where possible.
> 
> It isn't going away.
> 
> There will always be a need for a "stop all the TX queues" operation.

Ok, then how about something like this, the idea is to wrap the per tx
lock with a read lock of the device and let the netif_tx_lock() be the
write side, therefore excluding all device locks, but not incure the
cacheline bouncing on the read side by using per-cpu counters like rcu
does.

This of course requires that netif_tx_lock() is rare, otherwise stuff
will go bounce anyway...

Probably missed a few details,.. but I think the below ought to show the
idea...

struct tx_lock {
	int busy;
	spinlock_t lock;
	unsigned long *counters;
};


int tx_lock_init(struct tx_lock *txl)
{
	txl->busy = 0;
	spin_lock_init(&txl->lock);
	txl->counters = alloc_percpu(unsigned long);

	if (!txl->counters)
		return -ENOMEM;

	return 0;
}

void __netif_tx_lock(struct netdev_queue *txq, cpu)
{
	struct net_device *dev = txq->dev;

	if (rcu_dereference(dev->tx_lock.busy)) {
		spin_lock(&dev->tx_lock.lock);
		(*percpu_ptr(dev->tx_lock.counters, cpu))++;
		spin_unlock(&dev->tx_lock.lock);
	} else
		(*percpu_ptr(dev->tx_lock.counters, cpu))++;

	spin_lock(&txq->_xmit_lock);
	txq->xmit_lock_owner = cpu;
}

void __netif_tx_unlock(struct netdev_queue *txq)
{
	struct net_device *dev = txq->dev;

	(*percpu_ptr(dev->tx_lock.counters, txq->xmit_lock_owner))--;
	txq->xmit_lock_owner = -1;
	spin_unlock(&txq->xmit_lock);
}

unsigned long tx_lock_read_counters(struct tx_lock *txl)
{
	int i;
	unsigned long counter = 0;

	/* can use online - the inc/dec are matched per cpu */
	for_each_online_cpu(i)
		counter += *percpu_ptr(txl->counters, i);

	return counter;
}

void netif_tx_lock(struct net_device *dev)
{
	spin_lock(&dev->tx_lock.lock);
	rcu_assign_pointer(dev->tx_lock.busy, 1);

	while (tx_lock_read_counters(&dev->tx_lock)
		cpu_relax();
}

void netif_tx_unlock(struct net_device *dev)
{
	rcu_assign_pointer(dev->tx_lock.busy, 0);
	smp_wmb(); /* because rcu_assign_pointer is broken */
	spin_unlock(&dev->tx_lock.lock);
}

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
