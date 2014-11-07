From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gro: add a per device gro flush timer
Date: Thu, 06 Nov 2014 22:36:03 -0500 (EST)
Message-ID: <20141106.223603.678182467467024928.davem@davemloft.net>
References: <1415235320.13896.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141106.162516.1083429539800319166.davem@davemloft.net>
	<1415311880.13896.85.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbaKGDgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 22:36:05 -0500
In-Reply-To: <1415311880.13896.85.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Nov 2014 14:11:20 -0800

> My goal was to not change any driver, doing a generic change.
> 
> Drivers call napi_complete() in their rx napi handler without giving us
> the 'work_done' value which tells us if a packet was processed.
> 
> So I added a counter that is increased for every packet given to GRO
> engine (napi_rx_count), so that napi_complete() has a clue if a packet
> was received in _this_ NAPI run.
> 
> If at least one packet was received (and we still have packets in
> gro_list) -> We ream the 'timer'
> If not, we flush packets in GRO engine.
> 
> In order to avoid this state, I would have to add a new method, like
> napi_complete_done(napi, work_done), and change drivers. I am not sure
> its worth the effort ?

I think for such a critical path in the kernel it's worth it to avoid
these increments for every packet, just to compute a value that's
sitting in a register already in the driver's poll routine.

Eric, you've been trimming cpu IRQ disables from these exact code
paths, you should know better than me :-)

I'm willing to do some of the monkey work of converting as many
drivers as can be trivially done if you want.  Almost all of the
ones I looked at have the work_done variable right there at the
napi_complete() call site.

The rest can stay unconverted and not get access to this new facility.
