From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Thu, 24 Jul 2008 02:20:40 -0700 (PDT)
Message-ID: <20080724.022040.23129457.davem@davemloft.net>
References: <20080723114914.GF4561@ff.dom.local>
	<20080723.131607.79681752.davem@davemloft.net>
	<1216890648.7257.258.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216890648.7257.258.camel@twins>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date: Thu, 24 Jul 2008 11:10:48 +0200

> Ok, then how about something like this, the idea is to wrap the per tx
> lock with a read lock of the device and let the netif_tx_lock() be the
> write side, therefore excluding all device locks, but not incure the
> cacheline bouncing on the read side by using per-cpu counters like rcu
> does.
> 
> This of course requires that netif_tx_lock() is rare, otherwise stuff
> will go bounce anyway...
> 
> Probably missed a few details,.. but I think the below ought to show the
> idea...

Thanks for the effort, but I don't think we can seriously consider
this.

This lock is taken for every packet transmitted by the system, adding
another memory reference (the RCU deref) and a counter bump is just
not something we can just add to placate lockdep.  We going through
all of this effort to seperate the TX locking into individual
queues, it would be silly to go back and make it more expensive.

I have other ideas which I've expanded upon in other emails.  They
involve creating a netif_tx_freeze() interface and getting the drivers
to start using it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
