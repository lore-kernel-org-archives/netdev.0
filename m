From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 09:46:36 +0200
Message-ID: <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com>
References: <1185322771.4175.102.camel@chaos>
	 <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos>
	 <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local>
	 <20070726091254.GA8063@elte.hu>
	 <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
	 <20070731132037.GC1046@ff.dom.local>
	 <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com>
	 <20070806070300.GA4509@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070806070300.GA4509@elte.hu>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/6, Ingo Molnar <mingo@elte.hu>:
> (..)
> please try Jarek's second patch too - there was a missing unmask.
>
>         Ingo
>
> -------------->
> Subject: genirq: fix simple and fasteoi irq handlers
> From: Jarek Poplawski <jarkao2@o2.pl>
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
> --- 2.6.23-rc1-/kernel/irq/chip.c       2007-07-09 01:32:17.000000000 +0200
> +++ 2.6.23-rc1/kernel/irq/chip.c        2007-08-05 21:49:46.000000000 +0200
> @@ -295,12 +295,11 @@ handle_simple_irq(unsigned int irq, stru
>
>         spin_lock(&desc->lock);
>
> -       if (unlikely(desc->status & IRQ_INPROGRESS))
> -               goto out_unlock;
>         kstat_cpu(cpu).irqs[irq]++;
>
>         action = desc->action;
> -       if (unlikely(!action || (desc->status & IRQ_DISABLED))) {
> +       if (unlikely(!action || (desc->status & (IRQ_INPROGRESS |
> +                                                IRQ_DISABLED)))) {
>                 if (desc->chip->mask)
>                         desc->chip->mask(irq);
>                 desc->status &= ~(IRQ_REPLAY | IRQ_WAITING);
> @@ -318,6 +317,8 @@ handle_simple_irq(unsigned int irq, stru
>
>         spin_lock(&desc->lock);
>         desc->status &= ~IRQ_INPROGRESS;
> +       if (!(desc->status & IRQ_DISABLED) && desc->chip->unmask)
> +               desc->chip->unmask(irq);
>  out_unlock:
>         spin_unlock(&desc->lock);
>  }
> @@ -392,18 +393,16 @@ handle_fasteoi_irq(unsigned int irq, str
>
>         spin_lock(&desc->lock);
>
> -       if (unlikely(desc->status & IRQ_INPROGRESS))
> -               goto out;
> -
>         desc->status &= ~(IRQ_REPLAY | IRQ_WAITING);
>         kstat_cpu(cpu).irqs[irq]++;
>
>         /*
> -        * If its disabled or no action available
> +        * If it's running, disabled or no action available
>          * then mask it and get out of here:
>          */
>         action = desc->action;
> -       if (unlikely(!action || (desc->status & IRQ_DISABLED))) {
> +       if (unlikely(!action || (desc->status & (IRQ_INPROGRESS |
> +                                                IRQ_DISABLED)))) {
>                 desc->status |= IRQ_PENDING;
>                 if (desc->chip->mask)
>                         desc->chip->mask(irq);
> @@ -420,6 +419,8 @@ handle_fasteoi_irq(unsigned int irq, str
>
>         spin_lock(&desc->lock);
>         desc->status &= ~IRQ_INPROGRESS;
> +       if (!(desc->status & IRQ_DISABLED) && desc->chip->unmask)
> +               desc->chip->unmask(irq);
>  out:
>         desc->chip->eoi(irq);
>
>
Network card still locks up (tested on 2.6.22.1). I had to upload more
data than usual (~350 MB vs ~1-100 MB) to trigger that bug but it
might be a coincidence...

Marcin
