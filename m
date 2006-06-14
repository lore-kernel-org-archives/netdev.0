From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Tue, 13 Jun 2006 22:44:12 -0600
Message-ID: <20060614044412.GA30552@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:55523 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S932166AbWFNEoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 00:44:15 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <448F5952.1060201@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 13, 2006 at 08:33:22PM -0400, Jeff Garzik wrote:
> Grant Grundler wrote:
> >o tulip_stop_rxtx() has to be called _after_ free_irq().
> >  ie. v2 patch didn't fix the original race condition
> >  and when under test, dies about as fast as the original code.
> 
> You made the race window smaller, but it's still there.  The chip's DMA 
> engines should be stopped before you unregister the interrupt handler.

Switching the order to be:
        tulip_stop_rxtx(tp);            /* Stop DMA */
        free_irq (dev->irq, dev);       /* no more races after this */

still leaves us open to IRQs being delivered _after_ we've stopped DMA.
That in turn allows the interrupt handler to re-enable DMA again.

Or are you worried about a masked, pending interrupt causing
problems when the driver is re-opened or resumed?
If firmware left the device in a that state at boot time wouldn't
the driver be required to handle it?

thanks,
grant



> 
> 	Jeff
> 
> 
