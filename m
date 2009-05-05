From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Tue, 5 May 2009 23:24:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
References: <1241435206.8115.104.camel@localhost.localdomain>
 <9929d2390905051147y71f34e4bu9f63edc1e5a253a2@mail.gmail.com>
 <20090505.115819.84151021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jeffrey.t.kirsher@intel.com, hawk@comx.dk,
	netdev <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:45073 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758406AbZEEVYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 17:24:36 -0400
In-Reply-To: <20090505.115819.84151021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 May 2009, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 5 May 2009 11:47:09 -0700
>
>> NAK.  RNBC is not a counter for buffer overruns, and so should not be
>> counted as such.
>
> I'd say technically it is, it indicates that more packets arrived than
> the available receive buffers could handle.

I agree with DaveM. Technically it _is_ a buffer overflow, but in the host 
memory not the NIC. I'm sort of pushing the system into a situation where 
it cannot empty the receive buffers fast enough.

I can fairly easily provoke this situation by adding too many iptables 
rules, which (intentionally) cause high CPU load and causes ksoftirqd to 
run (I'm Oprofiling netfilter modules).


> If anything, this is the closest this device has for this kind of
> situation, and it's useful for diagnosing problems.

Its really useful for diagnosing problems, and I'm betting that this is a 
real-life situation which people is going to experience. We might as well 
help our self to more easily identify this issue when people report drop 
problems.

Notice that I'm seeing:

   rx_no_buffer_count: 136955
   rx_missed_errors: 0

Thus, the rx_missed_errors is zero, which according to the datasheet is 
the "real" fifo drop (the MPC register, Missed Packets Count) and PCI 
bandwidth problem indications.

If we really should nitpick, then:

  adapter->net_stats.rx_missed_errors = adapter->stats.mpc

Should then have been stored in the rx_fifo_errors.  Notice that 
rx_missed_errors is presented to userspace as drops (see 
net/core/dev.c:2624).

I think that both MPC and RNBC should be stored in rx_fifo_errors (and of 
cause still keeping them seperate to ethtool -S).

I'll post two patches with these changes tomorrow, for you evaluation.

Please reconsider you NAK.

Greetings,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
