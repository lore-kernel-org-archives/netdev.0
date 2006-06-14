From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Wed, 14 Jun 2006 12:14:19 -0600
Message-ID: <20060614181419.GA10365@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:3469 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S932103AbWFNSOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 14:14:22 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44902554.7010703@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2006 at 11:03:48AM -0400, Jeff Garzik wrote:
> Grant Grundler wrote:
> >Switching the order to be:
> >        tulip_stop_rxtx(tp);            /* Stop DMA */
> >        free_irq (dev->irq, dev);       /* no more races after this */
> >
> >still leaves us open to IRQs being delivered _after_ we've stopped DMA.
> 
> Correct.  And that is the preferred, natural, logical, obvious order:
> 
> 1) Turn things off.
> 2) Wait for activity to cease.

Patch v3 does this in two stages:
1) turn off tulip interrupts
2) free_irq() calls syncronize_irq() to handle pending IRQs

then calls tulip_stop_rxtx() which:
1) tells tulip to stop DMA
2) poll until DMA completes

After this we can free remaining resources.

> >That in turn allows the interrupt handler to re-enable DMA again.
> 
> Then that would be a problem to solve...  Some interrupt handlers will 
> test netif_running() or a driver-specific shutting-down flag, 
> specifically to avoid such behaviors.

I'm not keen on adding more code to tulip_interrupt() routine
for something that rarely happens (compared to IRQs) and is handled
outside the interrupt routine.  I'm pretty sure stopping interrupts
before stopping DMA is sufficient.
Can you show an example where it doesn't work?

This is important since I'm going to propose a new Documentation/pci.txt
based on this experience.

thanks,
grant
