From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Thu, 24 Jul 2008 09:00:23 +0200
Message-ID: <1216882823.7257.229.camel@twins>
References: <1216806614.7257.152.camel@twins>
	 <20080723101352.GD4561@ff.dom.local> <1216810696.7257.175.camel@twins>
	 <20080723.131441.200166513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080723.131441.200166513.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2008-07-23 at 13:14 -0700, David Miller wrote:
> From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Date: Wed, 23 Jul 2008 12:58:16 +0200
> 
> > So I guess my question is, is netif_tx_lock() here to stay, or is the
> > right fix to convert all those drivers to use __netif_tx_lock() which
> > locks only a single queue?
> 
> It's staying.
> 
> It's trying to block all potential calls into the ->hard_start_xmit()
> method of the driver, and the only reliable way to do that is to take
> all the TX queue locks.  And in one form or another, we're going to
> have this "grab/release all the TX queue locks" construct.
> 
> I find it interesting that this cannot be simply described to lockdep
> :-)

If you think its OK to take USHORT_MAX locks at once, I'm afraid we'll
have to agree to disagree :-/

Thing is, lockdep wants to be able to describe the locking hierarchy
with classes, and each class needs to be in static storage for various
reasons.

So if you make a locking hierarchy that is USHORT_MAX deep, you need at
least that amount of static classes.

Also, you'll run into the fact that lockdep will only track like 48 held
locks, after that it self terminates.

I'm aware of only 2 sites in the kernel that break this limit. The
down-side of stretching this limit is that deep lock chains come with
costs (esp so on -rt), so I'm not particularly eager to grow this - it
might give the impresssion its a good idea to have very long lock
chains.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
