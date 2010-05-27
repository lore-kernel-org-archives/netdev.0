From: David Miller <davem@davemloft.net>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Wed, 26 May 2010 21:06:00 -0700 (PDT)
Message-ID: <20100526.210600.242135655.davem@davemloft.net>
References: <20100526.005634.48509140.davem@davemloft.net>
	<1274868776.2672.96.camel@edumazet-laptop>
	<20100527035617.GB28295@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53975
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821Ab0E0EFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 00:05:50 -0400
In-Reply-To: <20100527035617.GB28295@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Thu, 27 May 2010 13:56:17 +1000

> I'm somewhat confused by the two stage locking in the socket lock
> (ie sk_lock.slock and sk_lock.owned).
> 
> What state should the socket lock be in for serialising updates of
> sk_forward_alloc? In some cases we appear to update it with sk_lock.slock =
> unlocked, sk_lock.owned = 1:

If sh_lock.owned=1 the user has grabbed exclusive sleepable lock on the
socket, it does this via something approximating:

retry:
	spin_lock(&sk_lock.slock);
	was_locked = sk_lock.owned;
	if (!was_locked)
		sk_lock.owned = 1;
	spin_unlock(&sk_lock.slock);
	if (was_locked) {
		sleep_on(condition(sk_lock.owned));
		goto retry;
	}

This allows user context code to sleep with exclusive access to the
socket.

Code that cannot sleep takes the spinlock, and queues the work if the
owner field if non-zero.  Else, it keeps the spinlock held and does
the work.

In either case, socket modifications are thus done completely protected
from other contexts.


