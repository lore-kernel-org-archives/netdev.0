From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 22 Jun 2006 23:00:29 -0600
Message-ID: <20060623050029.GB23383@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <20060622004339.GO19196@goober>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:32657 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S932310AbWFWFAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 01:00:32 -0400
To: Valerie Henson <val_henson@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <20060622004339.GO19196@goober>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ sorry, for the record I'm not trimming Val's comments - mine are much below]

On Wed, Jun 21, 2006 at 05:43:40PM -0700, Valerie Henson wrote:
...
> Hi folks,
> 
> The quick summary of my thoughts on this patch is that it isn't the
> ideal patch, but it works and it's well-tested.  Doing my preferred
> fix (adding a shutdown flag) would be invasive and take many weeks to
> reach the level of stability of Grant's patch.  So I'm taking this
> patch but adding a comment describing my preferred fix.
> 
> Here's the long version.  The obvious ordering of bringing up the card
> is:
> 
> request_irq()
> setup DMA resources
> enable interrupts
> start DMA engine

The problem here is request_irq() enables interrupts.
SO the third step happens as part of the first step.

And if an IRQ happens to be pending, it will blow up.
But since we reset the chip at init time, that should
never happen.

> 
> And the obvious ordering of shutting it down is:
> 
> stop DMA engine
> disable interrupts
> remove DMA resources
> free_irq()

This attempts to be symetrical with the init sequence and 
I like that approach where possible. It's not symetrical
in practice because the interrupt code restarts DMA.
(which is what you've noted below)

> The problem with the above shutdown order is that we can receive an
> interrupt in between stopping DMA and disabling interrupts, and the
> tulip irq handler will reenable DMA =><= Boom!  The solution I prefer
> is to make the irq handler aware of whether we are shutting down or
> not, and not reenable DMA in that case.

While I believe this will work too, I don't advocate this approach
because I don't like to add code to interrupt handlers unless
it's the _only_ way to fix a problem. 

>   However, it is a non-trivial
> patch to get right, and I would rather have the bug fixed short-term
> with the ordering Grant uses:
> 
> disable interrupts
> free_irq()
> stop rxtx
> remove DMA resources
> 
> Make sense to everyone?  I'll redo the patch with the comment and get
> Grant's sign-off.

Yes. I'm ok with anything similar to what you posted above:

    Signed-off-by: Grant Grundler <grundler@parisc-linux.org>


And Val, thanks for accepting the patch and taking the time to
explain where you want to go next with the code in this case.
I'll be happy to setup remote access to my test environment when
you are ready to test that next step.

thanks,
grant

> 
> -VAL
