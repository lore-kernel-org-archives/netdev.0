From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ROSE][AX25] af_ax25: possible circular locking
Date: Sat, 29 Dec 2007 19:14:43 -0800 (PST)
Message-ID: <20071229.191443.10947724.davem@davemloft.net>
References: <20071218135202.GA2023@ff.dom.local>
	<47755FDB.2070501@free.fr>
	<20071228214857.GA3290@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f6bvp@free.fr, ralf@linux-mips.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35322
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752160AbXL3DOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 22:14:48 -0500
In-Reply-To: <20071228214857.GA3290@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 28 Dec 2007 22:48:57 +0100

> lockdep is worried about the different order here:
> 
> #1 (rose_neigh_list_lock){-+..}:
> #3 (ax25_list_lock){-+..}:
> 
> #0 (linkfail_lock){-+..}:
> #1 (rose_neigh_list_lock){-+..}:
> 
> #3 (ax25_list_lock){-+..}:
> #0 (linkfail_lock){-+..}:
> 
> So, ax25_list_lock could be taken before and after linkfail_lock. 
> I don't know if this three-thread clutch is very probable (or
> possible at all), but it seems another bug reported by Bernard
> ("[...] system impossible to reboot with linux-2.6.24-rc5")
> could have similar source - namely ax25_list_lock held by
> ax25_kill_by_device() during ax25_disconnect(). It looks like the
> only place which calls ax25_disconnect() this way, so I guess, it
> isn't necessary.
> 
> This patch is breaking the lock for ax25_disconnect(), with some
> failsafe and debugging added to detect unforeseen problems.
> 
> 
> Reported-and-tested-by: Bernard Pidoux <f6bvp@free.fr>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

I can't apply this fix, sorry.

You can't just drop this linked list lock and expect it to stay
consistent like that.

Once you drop it, any thread of control can get in there and delete
entries from the list.

Since we know it can happen, using a WARN_ON_ONCE(1) is not
appropriate.  And if it triggers it will do the wrong thing, because
by branching back to "again" we can call ax25_disconnect() multiple
times on the same entry which isn't right.

You'll thus need to resolve this locking conflict more properly.
I know it's hard, but your current fix is worse because it adds
a new known bug.
