From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 08 Jun 2006 11:32:39 -0400
Message-ID: <44884317.8070601@pobox.com>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608152221.GC8246@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47566 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964872AbWFHPcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:32:45 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060608152221.GC8246@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> On Thu, Jun 08, 2006 at 10:43:04AM -0400, Jeff Garzik wrote:
>> (CC'ing our newly minted tulip maintainer, Val)
> 
> Excellent!
> Has MAINTAINERS file been updated? :)

It should be updated, yes.


>> Calling free_irq() while the chip is still active is just a bad idea, 
>> because the chip could raise an interrupt, creating a 
>> screaming-interrupts situation. Consider especially the case of shared 
>> interrupts here, as a concrete example of how this won't work.
> 
> The chip IRQ gets turned off in tulip_down().
> It won't be screaming for very long.

Then you admit that you add a race.


> No one will hear it screaming and no one will care.

False.  Easy counter-example already provided:  Shared interrupts.

For some IRQ architectures, even without shared interrupts, this could 
easily trigger the kernel's screaming-irq detection code.


> Secondly, if tulip has a problem with shared IRQs, it's already there.
> We would have called free_irq() anyway - just a bit later.

Yes... AFTER we told the chip to stop DMA'ing, and delivering interrupts.

I'm frankly surprised you don't see the obvious, natural ordering.  You 
stop the hardware from wanting to deliver interrupts, before 
unregistering the irq handler.  IOW you turn out the lights, before 
leaving the room.


> In the shared IRQ case, I expect free_irq() to unlink this instance
> of the tulip interrupt handler from the CPU vector list. If that

Irrelevant -- that doesn't stop the tulip hardware from raising the irq, 
nor stop the system from attempting to deliver it [in all cases].  In 
the shared interrupt case, that means that another driver's irq handler 
will be called for an event tulip hardware raised.

	Jeff


