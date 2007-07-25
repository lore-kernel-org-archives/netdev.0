From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 09:56:54 +0100
Message-ID: <20070725095654.38a10abc@oldman.hamilton.local>
References: <20070725.013154.34764933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, hadi@cyberus.ca,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48139 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753402AbXGYI5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 04:57:30 -0400
In-Reply-To: <20070725.013154.34764933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Jul 2007 01:31:54 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> We're getting there, slowly...
> 
> 1) netif_napi_init() is added, the workqueue/requeue stuff
>    as discussed is not needed so you won't see that here
> 
> 2) all cases where netif_rx_complete() are invoked in contexts
>    where cpu interrupts are known to be disabled are replaced
>    with __netif_rx_complete()
> 
> Most drivers are in good shape, although some still have very
> questionable netif_rx_complete() handling, in that racy area that
> Rusty and myself were discussing today.
> 
> My inclination is to wrap those sequences around with an IRQ
> safe spinlock to fix the race provably, and then if driver
> authors want to optimize that away with techniques like those
> that tg3, bnx2, sky2, skge et al. use, that's fine but can
> be done later.
> 
> To some extent it's mechanical work if you know what to look
> for, so any relative patches for that stuff would be much
> appreciated and I'll integrate such patches rapidly and without
> delay.
> 
> Besides that the only major issue is netpoll and I have some
> ideas on how to handle that, which I'll try to implement
> tonight and tomorrow.
> 
> Another thing that's really apparent now is all the wacky
> napi->weight values various drivers use.  Just grep for
> netif_napi_init() in the patch or a patched tree to see what
> I mean.  So much of it doesn't make any sense and I'm tempted
> to just remove the argument and make everyone use 32 or 64
> or something like that :-)  Or, default to some value across
> the board, and let drivers override that on a case by case
> basis with a BIG FAT COMMENT above the override describing
> why the different value is being used and precisely what
> tests were performed to validate that different value.
> 

The usage of NAPI on 8139cp and 8139too seems dodgy;
these drivers expect this to work:

		local_irq_save(flags);
		cpw16_f(IntrMask, cp_intr_mask);
		__netif_rx_complete(dev);
		local_irq_restore(flags);

It works on SMP only because if poll races with IRQ, 
the IRQ is not masked or cleared so the IRQ will get restarted.

Better would be to change it to:
		spin_lock_irqsave(&cp->lock, flags);
		cpw16_f(IntrMask, cp_intr_mask);
		__netif_rx_complete(dev);
		spin_unlock_irqrestore(&cp->lock, flags);

Which actually is same code on UP.
