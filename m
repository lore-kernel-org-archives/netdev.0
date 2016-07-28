From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Thu, 28 Jul 2016 14:21:16 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1607281414040.19896@nanos>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com> <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com> <1469655487.2232.49.camel@intel.com> <1469684635.9389.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160728101958.GA26846@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	intel-wired-lan@lists.osuosl.org,
	Ye Xiaolong <xiaolong.ye@intel.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:48937 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757367AbcG1MXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 08:23:32 -0400
In-Reply-To: <20160728101958.GA26846@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jul 2016, Sabrina Dubroca wrote:
> 2016-07-28, 07:43:55 +0200, Eric Dumazet wrote:
> > I would prefer having a definitive advice from Thomas Gleixner and/or
> > others if disable_irq() is forbidden from IRQ path.

Yes it is. Before we added threaded interrupt handlers it was not an issue,
but with (possibly) threaded interrupts it's an absolute no-no.

> > As I said, about all netpoll() methods in net drivers use disable_irq()
> > so a lot of patches would be needed.
> > 
> > disable_irq() should then test this condition earlier, so that we can
> > detect potential bug, even if the IRQ is not (yet) threaded.
> 
> The idea when this first came up was to skip the sleeping part of
> disable_irq():
> 
> http://marc.info/?l=linux-netdev&m=142314159626052
> 
> This fell off my todolist and I didn't send the conversion patches,
> which would basically look like this:
>
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 41f32c0b341e..b022691e680b 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -6713,20 +6713,20 @@ static irqreturn_t e1000_intr_msix(int __always_unused irq, void *data)
>  
>  		vector = 0;
>  		msix_irq = adapter->msix_entries[vector].vector;
> -		disable_irq(msix_irq);
> -		e1000_intr_msix_rx(msix_irq, netdev);
> +		if (disable_hardirq(msix_irq))
> +			e1000_intr_msix_rx(msix_irq, netdev);
>  		enable_irq(msix_irq);

That'll work nicely even when one of the affected interrupts is threaded.

Thanks,

	tglx
