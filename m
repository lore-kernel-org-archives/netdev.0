From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH][be2net] remove napi in the tx path and do
 tx completion processing in interrupt context
Date: Wed, 20 May 2009 17:25:07 -0700 (PDT)
Message-ID: <20090520.172507.88716464.davem@davemloft.net>
References: <20090519121056.GB26870@serverengines.com>
	<20090519.151334.87370735.davem@davemloft.net>
	<4A13CC98.60506@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajitk@serverengines.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754209AbZEUAZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 20:25:09 -0400
In-Reply-To: <4A13CC98.60506@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 20 May 2009 11:25:44 +0200

> When a lot of network trafic is handled by one device, we enter in a
> ksofirqd/napi mode, where one cpu is almost dedicated in handling
> both TX completions and RX completions, while other cpus
> run application code (and some parts of TCP/UDP stack )
> 
> Thats really expensive because of many cache line ping pongs occurring.
>
> In that case, it would make sense to transfert most part of the TX
> completion work to the other cpus (cpus that order the xmits
> actually). skb freeing of course, and sock_wfree() callbacks...

Yes and that kind of idea can be combined with the SW multiqueue
efforts such as those patches posted by google the other week.

> So maybe some NIC device drivers could let their ndo_start_xmit()
> do some cleanup work of previously sent skbs. If correctly done,
> we could lower number of cache line ping pongs.

That's another idea.  However the ordering necessary to do this
correctly on some chips might make the cost of it prohibitive.  For
example, it might only be safe to check the consumer pointer value
DMA's by a device into the status block after an IRQ is received
unless some expensive synchronization (f.e. a register read) is
performed first.

> There is also a minor latency problem with current schem : Taking
> care of TX completion takes some time and delay RX handling,
> increasing latencies of incoming trafic.

One thing that one must understand is that deferring any SKB freeing
increases the size of the working set of memory that the CPU has
to access.  Buffer reuse is absolutely essential to keep the working
set of unfree'd data under control.

This working set bloating effect is also, unfortunately, a hallmark of
RCU.  Especially before we had softint based RCU available.
