From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Improved network performance by balancing Rx against
 other work
Date: Sun, 21 Mar 2010 21:11:24 -0700 (PDT)
Message-ID: <20100321.211124.216749316.davem@davemloft.net>
References: <87tysfu05d.wl%peterc@chubb.wattle.id.au>
	<20100321.202159.235697842.davem@davemloft.net>
	<877hp5rohj.wl%peterc@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.chubb@nicta.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750850Ab0CVELD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 00:11:03 -0400
In-Reply-To: <877hp5rohj.wl%peterc@chubb.wattle.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chubb <peter.chubb@nicta.com.au>
Date: Mon, 22 Mar 2010 15:04:24 +1100

>>>>>> "David" == David Miller <davem@davemloft.net> writes:
> 
> David> From: Peter Chubb <peter.chubb@nicta.com.au> Date: Wed, 17 Mar
> David> 2010 13:55:58 +1100
> 
>>> The general approach is to restrict the work done in the Rx-side
>>> processing to just 32 or so packets at a time then call
>>> sys_sched_yield() to allow other system processing to get a look
>>> in.  Currently, NAPI processing happens in soft IRQ context, and
>>> much of it with interrupts off.
> 
> David> This is a deficiency in the locking done by such drivers.  Many
> David> drivers lock properly and do not disable hardware interrupts
> David> during NAPI processing.  Not only is this more efficient, it
> David> also makes the driver more profilable.  For example, on cpus
> David> with only timer based profiling everything done in NAPI context
> David> can be seen.
> 
> Actually, the e1000 does not appear to disable interrupts during NAPI
> processing.

So you don't know the fundamental aspects of what you were actually
analyzing? :-)

> However, softIRQ processing is still not being preempted by a
> real-time process that wakes up.

I thought softirqs ran as threads in the -rt kernel, why doesn't
preemption work properly for those threads?

> I had a look at the Broadcom tg3, but it looks too
> hard to modify;

It's one of the best drivers in the locking area.

It doesn't take any locks at all in it's hardware interrupt handler.

It doesn't take any locks at all for RX packet processing.

And it only takes a lock for TX processing very briefly in one
specific case, when we need to wake up the TX queue because it became
full and was stopped and we need to wake it up in tg3_tx()
