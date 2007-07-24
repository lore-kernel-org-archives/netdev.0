From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Tue, 24 Jul 2007 12:26:05 +0200
Message-ID: <20070724102605.GC2049@ff.dom.local>
References: <20070722.000507.26966710.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, okir@lst.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:42676 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763406AbXGXKQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 06:16:55 -0400
Content-Disposition: inline
In-Reply-To: <20070722.000507.26966710.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22-07-2007 09:05, David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Thu, 19 Jul 2007 17:27:47 +0100
> 
>> Please revisit the requirements that netconsole needs and redesign
>> it from scratch.  The existing code is causing too much breakage.
>>
>> Can it be done without breaking the semantics of network devices, or
>> should we rewrite the driver interface to take have a different
>> interface like netdev_sync_send_skb() that is slow, synchronous and
>> non-interrupt (ie polls for completion).  Of course, then people
>> will complain that netconsole traffic slows the machine down.  for
>> completion.
> 
> I couldn't agree more.
> 
> Since netpoll runs outside of all of the normal netdevice locking
> rules, only the people using netpoll hit all the bugs.  That means
> most of us do not test out these code path, which is bad.
> 
> So, if anything, a more integrated implementation is essential.
> 

But, IMHO, until this will be done some simpler measures could
do be done to make poll_napi less dangerous (as a matter of fact
I wonder why oopses observed & diagnosed by Olaf are so rare).

Current locking with netpoll_poll_lock is mainly misleading.
It seems somebody who planned napi didn't even think such helpers
as poll_napi are possible on other cpus and somebody doing netpoll
didn't want to show this all per cpu data needs full locking anyway.
But since it's like this there is no reason to invent a wheel again
and "normal" locking should be done: so global (not per device)
spin_lock (#ifdef CONFIG_NETPOLL only) held during all net_rx_action
and spin_trylock similarly in poll_napi (with STATE_RX_SCHED
re-checking) should be minimum needed here.

Regards,
Jarek P.
