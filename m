From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Fri, 17 Apr 2009 11:25:53 +0200
Message-ID: <20090417112553.21e1f2e5@hskinnemoen-d830>
References: <20090416112435.0b779859@surf>
	<20090417.013450.02738760.davem@davemloft.net>
	<20090417110703.781f8a0e@hskinnemoen-d830>
	<20090417.020841.21679845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	michael@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:50549 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755731AbZDQJ0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 05:26:01 -0400
In-Reply-To: <20090417.020841.21679845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
> Date: Fri, 17 Apr 2009 11:07:03 +0200
> 
> > David Miller wrote:
> >> And in response to this Haavard explained the potential deadlock
> >> (sorry I deleted that email) and suggested to use local_irq_save()
> >> 
> >> But that won't work either, because it doesn't prevent the interrupt
> >> handler from running on other cpus, it only prevents that on the
> >> local cpu.
> > 
> > The interrupt handler takes bp->lock. Isn't that sufficient to prevent
> > it from running on other cpus?
> 
> We don't necessarily hold bp->lock here, we could be called from
> the netpoll code.  Another cpu could easily hold bp->lock and be
> in the middle of the interrupt handler.

Yes, but we're about to take it. poll_controller() disables interrupts
and calls the interrupt handler, which takes the lock. That's
essentially an open-coded spin_lock_irqsave().

Now, that will obviously deadlock too if we're called from within the
interrupt handler or some other place holding bp->lock...

I guess you're right -- we just have to be careful about calling
printk() from within the driver. But it seems a lot easier to just drop
the lock before dumping an error message than it is to work around that
disable_irq() deadlock. And if you're running with verbose debugging
enabled, you probably shouldn't be using netconsole anyway.

Haavard
