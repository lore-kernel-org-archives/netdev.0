From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Wed, 14 Jun 2006 15:51:37 -0400
Message-ID: <449068C9.1010304@pobox.com>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20428 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932184AbWFNTvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 15:51:48 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060614181419.GA10365@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> On Wed, Jun 14, 2006 at 11:03:48AM -0400, Jeff Garzik wrote:
>> Grant Grundler wrote:
>>> Switching the order to be:
>>>        tulip_stop_rxtx(tp);            /* Stop DMA */
>>>        free_irq (dev->irq, dev);       /* no more races after this */
>>>
>>> still leaves us open to IRQs being delivered _after_ we've stopped DMA.
>> Correct.  And that is the preferred, natural, logical, obvious order:
>>
>> 1) Turn things off.
>> 2) Wait for activity to cease.
> 
> Patch v3 does this in two stages:
> 1) turn off tulip interrupts
> 2) free_irq() calls syncronize_irq() to handle pending IRQs
> 
> then calls tulip_stop_rxtx() which:
> 1) tells tulip to stop DMA
> 2) poll until DMA completes
> 
> After this we can free remaining resources.

You need to turn off the thing that generates work (DMA engine), before 
turning off the thing that reaps work (irq handler).


>>> That in turn allows the interrupt handler to re-enable DMA again.
>> Then that would be a problem to solve...  Some interrupt handlers will 
>> test netif_running() or a driver-specific shutting-down flag, 
>> specifically to avoid such behaviors.
> 
> I'm not keen on adding more code to tulip_interrupt() routine
> for something that rarely happens (compared to IRQs) and is handled
> outside the interrupt routine.  I'm pretty sure stopping interrupts
> before stopping DMA is sufficient.
> Can you show an example where it doesn't work?

It should be completely obvious that the chip is still generating 
work...  You don't want to leave the hardware in a position where it has 
unacknowledged events.

	Jeff


