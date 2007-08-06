From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon,  6 Aug 2007 22:42:15 +0200
Message-ID: <JMDDIG$C8916D611655799A77AD19198F8EDA75@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "cebbert" <cebbert@redhat.com>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"jarkao2" <jarkao2@o2.pl>, "tglx" <tglx@linutronix.de>,
	"torvalds" <torvalds@linux-foundation.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>,
	"akpm" <akpm@linux-foundation.org>,
	"alan" <alan@lxorguk.ukuu.org.uk>
To: "mingo" <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mmm, bad news, after 4 hours of intensive network stressing, one of the 2 3com card failed with the latest fedora kernel.

Aug  6 22:31:09 loki kernel: NETDEV WATCHDOG: eth2: transmit timed out
Aug  6 22:31:09 loki kernel: eth2: transmit timed out, tx_status 00 status e601.
Aug  6 22:31:09 loki kernel:   diagnostics: net 0ccc media 8880 dma 0000003a fifo 8000
Aug  6 22:31:09 loki kernel: eth2: Interrupt posted but not delivered -- IRQ blocked by another device?
Aug  6 22:31:09 loki kernel:   Flags; bus-master 1, dirty 26085000(8) current 26085000(8)
Aug  6 22:31:09 loki kernel:   Transmit list 00000000 vs. ffff81007c807700.

Stressing eth2 by copying large files on a samba on share and eth0 by downloading big files on the internet.

Jb

> 
> * Chuck Ebbert <cebbert@redhat.com> wrote:
> 
> > Before, they would print:
> > 
> > eth0: transmit timed out, tx_status 00 status e601.
> >   diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
> > eth0: Interrupt posted but not delivered -- IRQ blocked by another device?
> >   Flags; bus-master 1, dirty 295757(13) current 295757(13)
> >   Transmit list 00000000 vs. f7150a20.
> >   0: @f7150200  length 80000070 status 0c010070
> >   1: @f71502a0  length 80000070 status 0c010070
> >   2: @f7150340  length 8000005c status 0c01005c
> > 
> > Now they just work, apparently...
> 
> could you please try the patch below? If this doesnt do the trick then i 
> guess we need to revert that change.
> 
> 	Ingo
> 
> ------------>
> (take 2)
> 
> Subject: genirq: fix simple and fasteoi irq handlers
> 
> After the "genirq: do not mask interrupts by default" patch interrupts
> should be disabled not immediately upon request, but after they happen.
> But, handle_simple_irq() and handle_fasteoi_irq() can skip this once or
> more if an irq is just serviced (IRQ_INPROGRESS), possibly disrupting a
> driver's work.
> 
> The main reason of problems here, pointing the broken patch and making
> the first patch which can fix this was done by Marcin Slusarz.
> Additional test patches of Thomas Gleixner and Ingo Molnar tested by
> Marcin Slusarz helped to narrow possible reasons even more. Thanks.
> 
> PS: this patch fixes only one evident error here, but there could be
> more places affected by above-mentioned change in irq handling.
> 
> PS 2:
> After rethinking, IMHO, there are two most probable scenarios here:
> 
> 1. After hw resend there could be a conflict between retriggered
> edge type irq and the next level type one: e.g. if this level type
> irq (io_apic is enabled then) is triggered while retriggered irq is
> serviced (IRQ_INPROGRESS) there is goto out with eoi, and probably
> the next such levels are triggered and looping, so probably kind of
> flood in io_apic until this retriggered edge service has ended. 
> 2. There is something wrong with ioapic_retrigger_irq (less probable
> because this should be probably seen with 'normal' edge retriggers,
> but on the other hand, they could be less common).
> 
> So, if there is #1, this fixed patch should work.
> 
> But, since level types don't need this retriggers too much I think
> this "don't mask interrupts by default" idea should be rethinked:
> is there enough gain to risk such hard to diagnose errors?
>   
> So, IMHO, there should be at least possibility to turn this off for
> level types in config (it should be a visible option, so people could
> find & try this before writing for help or changing a network card).
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> ---
> 
> diff -Nurp 2.6.23-rc1-/kernel/irq/chip.c 2.6.23-rc1/kernel/irq/chip.c
> --- 2.6.23-rc1-/kernel/irq/chip.c	2007-07-09 01:32:17.000000000 +0200
> +++ 2.6.23-rc1/kernel/irq/chip.c	2007-08-05 21:49:46.000000000 +0200
> @@ -295,12 +295,11 @@ handle_simple_irq(unsigned int irq, stru
>  
>  	spin_lock(&desc->lock);
>  
> -	if (unlikely(desc->status & IRQ_INPROGRESS))
> -		goto out_unlock;
>  	kstat_cpu(cpu).irqs[irq]++;
>  
>  	action = desc->action;
> -	if (unlikely(!action || (desc->status & IRQ_DISABLED))) {
> +	if (unlikely(!action || (desc->status & (IRQ_INPROGRESS |
> +						 IRQ_DISABLED)))) {
>  		if (desc->chip->mask)
>  			desc->chip->mask(irq);
>  		desc->status &= ~(IRQ_REPLAY | IRQ_WAITING);
> @@ -318,6 +317,8 @@ handle_simple_irq(unsigned int irq, stru
>  
>  	spin_lock(&desc->lock);
>  	desc->status &= ~IRQ_INPROGRESS;
> +	if (!(desc->status & IRQ_DISABLED) && desc->chip->unmask)
> +		desc->chip->unmask(irq);
>  out_unlock:
>  	spin_unlock(&desc->lock);
>  }
> @@ -392,18 +393,16 @@ handle_fasteoi_irq(unsigned int irq, str
>  
>  	spin_lock(&desc->lock);
>  
> -	if (unlikely(desc->status & IRQ_INPROGRESS))
> -		goto out;
> -
>  	desc->status &= ~(IRQ_REPLAY | IRQ_WAITING);
>  	kstat_cpu(cpu).irqs[irq]++;
>  
>  	/*
> -	 * If its disabled or no action available
> +	 * If it's running, disabled or no action available
>  	 * then mask it and get out of here:
>  	 */
>  	action = desc->action;
> -	if (unlikely(!action || (desc->status & IRQ_DISABLED))) {
> +	if (unlikely(!action || (desc->status & (IRQ_INPROGRESS |
> +						 IRQ_DISABLED)))) {
>  		desc->status |= IRQ_PENDING;
>  		if (desc->chip->mask)
>  			desc->chip->mask(irq);
> @@ -420,6 +419,8 @@ handle_fasteoi_irq(unsigned int irq, str
>  
>  	spin_lock(&desc->lock);
>  	desc->status &= ~IRQ_INPROGRESS;
> +	if (!(desc->status & IRQ_DISABLED) && desc->chip->unmask)
> +		desc->chip->unmask(irq);
>  out:
>  	desc->chip->eoi(irq);
>  
> 

