From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: Top kernel oopses/warnings for the week of May 16th 2008
Date: Sun, 18 May 2008 20:23:03 -0600
Message-ID: <4830E487.1080502@shaw.ca>
References: <fa.d+EaKQa5MirlzoI/uZKGy3xe0h0@ifi.uio.no>
 <fa.TM0B9DZ+uvPYd9hbDhfuRgtReEk@ifi.uio.no>
 <fa.aEHVuArwNEvL0BbdjUyZdMtgx5s@ifi.uio.no>
 <fa.Td5KtiJWRKP94D9KrvGd+GkHdW0@ifi.uio.no>
 <fa.wtWnOZVeQ06/16BVE5ml7FVHP+c@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Robert Hancock <hancockr@shaw.ca>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jens Axboe <jens.axboe@oracle.com>
To: Andrea Arcangeli <andrea@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:19034 "EHLO
	pd2mo2so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbYESCZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 22:25:09 -0400
In-reply-to: <fa.wtWnOZVeQ06/16BVE5ml7FVHP+c@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrea Arcangeli wrote:
> On Sat, May 17, 2008 at 07:57:26AM -0700, Arjan van de Ven wrote:
>> Andrea Arcangeli wrote:
>>> The reason I touched that code, is that a change introduced during
>>> 2.6.25-rc initialized the isa dma pool even if not necessary and that
>>> broke the reserved-ram patch that requires no __GFP_DMA
>>> allocations. There was no crash in 2.6.24 based kernels, the
>>> regression started in 2.6.25-rc.
>> I'd not really call "breaks external patch" a regression ;)
> 
> The external patch only allowed me to notice the regression when
> nobody else noticed it. For mainline the regression was to put ram
> into the bounce buffer pool even if no dma could ever require the
> bounce buffering. There's no point to initialize the pool when total
> ram < highest dma address. That is the regression. My patch turned the
> regression from a waste of ram, to a kernel crash at boot. That's the
> only relation between the reserved-ram patch this bug.
> 
> I assume Robert has a similar issue with some debugging code checking
> for GFP_KERNEL allocations inside atomic context or similar, I assume
> his driver has a bug and calls that function in the wrong context. But
> if this didn't happen in 2.4.24, it means such bug has nothing to do
> with the bug in blk-settings.c. It's just that such a bug or the
> reserved-ram patches are required to notice the regression in
> blk-settings.c.

Well, it's not really documented what the locking semantics are supposed 
to be for blk_queue_bounce_limit. Based on the implementation, though, 
it's OK to call it under spin_lock_irqsave (it only sets some variables) 
unless you hit the case where dma is set to 1 and we do 
init_emergency_isa_pool. That's the problem, that case should not be hit 
with a DMA mask of 32-bit, but with Yang Shi's change to blk-settings.c, 
now we are.

The code in that function seems rather hackish, actually. It seems like 
a lot of those assumptions it's making should be in 
architecture-specific code..

