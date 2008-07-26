From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Sat, 26 Jul 2008 15:18:38 +0200
Message-ID: <20080726131838.GA2873@ami.dom.local>
References: <20080725193416.GB3107@ami.dom.local> <1217014575.4758.7.camel@johannes.berg> <20080725200137.GC3107@ami.dom.local> <20080726.021846.236624483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-BkyiQQGWkgE@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080726.021846.236624483.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 26, 2008 at 02:18:46AM -0700, David Miller wrote:
...
> I think there might be an easier way, but we may have
> to modify the state bits a little.
> 
> Every call into ->hard_start_xmit() is made like this:
> 
> 1. lock TX queue
> 2. check TX queue stopped
> 3. call ->hard_start_xmit() if not stopped
> 
> This means that we can in fact do something like:
> 
> 	unsigned int i;
> 
> 	for (i = 0; i < dev->num_tx_queues; i++) {
> 		struct netdev_queue *txq;
> 
> 		txq = netdev_get_tx_queue(dev, i);
> 		spin_lock_bh(&txq->_xmit_lock);
> 		netif_tx_freeze_queue(txq);
> 		spin_unlock_bh(&txq->_xmit_lock);
> 	}
> 
> netif_tx_freeze_queue() just sets a new bit we add.
> 
> Then we go to the ->hard_start_xmit() call sites and check this new
> "frozen" bit as well as the existing "stopped" bit.
> 
> When we unfreeze each queue later, we see if it is stopped, and if not
> we schedule it's qdisc for packet processing.

I guess some additional synchronization will be added yet to prevent
parallel freeze and especially unfreeze.

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
