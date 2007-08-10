From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70 check_irq_resend()
Date: Fri, 10 Aug 2007 10:49:24 +0200
Message-ID: <20070810084924.GF1764@ff.dom.local>
References: <18107.11431.838905.331157@stoffel.org> <20070809155445.GA5161@ff.dom.local> <1186733140.12828.45.camel@chaos> <20070810082346.GD1764@ff.dom.local> <20070810083050.GA4545@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	marcin.slusarz@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070810083050.GA4545@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 10:30:50AM +0200, Ingo Molnar wrote:
> 
> * Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > > Hmm. This solution is still just pampering over the real problem. 
> > > The delayed disable just re-sends level interrupts unnecessarily. I 
> > > have a fix (needs some testing) for this, which I send out tomorrow, 
> > > when I'm really back from vacation.
> > > 
> > > But suppressing the resend is not fixing the driver problem. The 
> > > problem can show up with spurious interrupts and with interrupts on 
> > > a shared PCI interrupt line at any time. It just might take weeks 
> > > instead of minutes.
> > 
> > Doesn't it look like a little change of mind? [...]
> 
> what change of mind do you mean exactly?
> 
> > [...] Well, there are probably (but need more testing) two other 
> > solutions: _SW_RESEND and disabling without delay for levels only...
> 
> IIRC Marcin tested software-resend and it didnt fix the hang. That 
> strongly points in the direction of a driver bug (or a genirq bug) being 
> made more prominent by the genirq change - not any hardware detail such 
> as the APIC vector-retrigger sequence.
> 
> While we'd like to see the suspected driver bug (or any higher level 
> genirq bug) fixed, we'll undo the effect of the genirq change (because 
> it is causing a regression). We'll also add a separate, optional 
> irq-debugging feature that generates high-rate interrupts on any shared 
> irq line. (and thus artificially stresses the robustness of the driver 
> and the genirq layer against spurious interrupts.)

Not exactly so... I've send modified version of your software-resend
patch, and it seems to work OK.

Jarek P.

>From marcin.slusarz@gmail.com Wed Aug  8 13:20:02 2007
From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
...
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
...
2007/8/7, Jarek Poplawski <jarkao2@o2.pl>:
> So, the let's try this idea yet: modified Ingo's "x86: activate
> HARDIRQS_SW_RESEND" patch.
> (Don't forget about make oldconfig before make.)
> For testing only.
>
> Cheers,
> Jarek P.
>
> PS: alas there was not even time for "compile checking"...
>
> ---
>
> diff -Nurp 2.6.22.1-/arch/i386/Kconfig 2.6.22.1/arch/i386/Kconfig
> --- 2.6.22.1-/arch/i386/Kconfig 2007-07-09 01:32:17.000000000 +0200
> +++ 2.6.22.1/arch/i386/Kconfig  2007-08-07 13:13:03.000000000 +0200
> @@ -1252,6 +1252,10 @@ config GENERIC_PENDING_IRQ
>         depends on GENERIC_HARDIRQS && SMP
>         default y
>
> +config HARDIRQS_SW_RESEND
> +       bool
> +       default y
> +
>  config X86_SMP
>         bool
>         depends on SMP && !X86_VOYAGER
> diff -Nurp 2.6.22.1-/arch/x86_64/Kconfig 2.6.22.1/arch/x86_64/Kconfig
> --- 2.6.22.1-/arch/x86_64/Kconfig       2007-07-09 01:32:17.000000000 +0200
> +++ 2.6.22.1/arch/x86_64/Kconfig        2007-08-07 13:13:03.000000000 +0200
> @@ -690,6 +690,10 @@ config GENERIC_PENDING_IRQ
>         depends on GENERIC_HARDIRQS && SMP
>         default y
>
> +config HARDIRQS_SW_RESEND
> +       bool
> +       default y
> +
>  menu "Power management options"
>
>  source kernel/power/Kconfig
> diff -Nurp 2.6.22.1-/kernel/irq/manage.c 2.6.22.1/kernel/irq/manage.c
> --- 2.6.22.1-/kernel/irq/manage.c       2007-07-09 01:32:17.000000000 +0200
> +++ 2.6.22.1/kernel/irq/manage.c        2007-08-07 13:13:03.000000000 +0200
> @@ -169,6 +169,14 @@ void enable_irq(unsigned int irq)
>                 desc->depth--;
>         }
>         spin_unlock_irqrestore(&desc->lock, flags);
> +#ifdef CONFIG_HARDIRQS_SW_RESEND
> +       /*
> +        * Do a bh disable/enable pair to trigger any pending
> +        * irq resend logic:
> +        */
> +       local_bh_disable();
> +       local_bh_enable();
> +#endif
>  }
>  EXPORT_SYMBOL(enable_irq);
>
> diff -Nurp 2.6.22.1-/kernel/irq/resend.c 2.6.22.1/kernel/irq/resend.c
> --- 2.6.22.1-/kernel/irq/resend.c       2007-07-09 01:32:17.000000000 +0200
> +++ 2.6.22.1/kernel/irq/resend.c        2007-08-07 13:57:54.000000000 +0200
> @@ -62,16 +62,24 @@ void check_irq_resend(struct irq_desc *d
>          */
>         desc->chip->enable(irq);
>
> +       /*
> +        * Temporary hack to figure out more about the problem, which
> +        * is causing the ancient network cards to die.
> +        */
> +
>         if ((status & (IRQ_PENDING | IRQ_REPLAY)) == IRQ_PENDING) {
>                 desc->status = (status & ~IRQ_PENDING) | IRQ_REPLAY;
>
> -               if (!desc->chip || !desc->chip->retrigger ||
> -                                       !desc->chip->retrigger(irq)) {
> +               if (desc->handle_irq == handle_edge_irq) {
> +                       if (desc->chip->retrigger)
> +                               desc->chip->retrigger(irq);
> +                       return;
> +               }
>  #ifdef CONFIG_HARDIRQS_SW_RESEND
> -                       /* Set it pending and activate the softirq: */
> -                       set_bit(irq, irqs_resend);
> -                       tasklet_schedule(&resend_tasklet);
> +               WARN_ON_ONCE(1);
> +               /* Set it pending and activate the softirq: */
> +               set_bit(irq, irqs_resend);
> +               tasklet_schedule(&resend_tasklet);
>  #endif
> -               }
>         }
>  }
>
Works fine with:
WARNING: at kernel/irq/resend.c:79 check_irq_resend()

Call Trace:
 [<ffffffff8025e660>] check_irq_resend+0xc0/0xd0
 [<ffffffff8025e1cd>] enable_irq+0xed/0xf0
 [<ffffffff8807f21d>] :8390:ei_start_xmit+0x14d/0x30c
 [<ffffffff8024d055>] lock_release_non_nested+0xe5/0x190
 [<ffffffff80539b78>] __qdisc_run+0x98/0x1f0
 [<ffffffff80539b8e>] __qdisc_run+0xae/0x1f0
 [<ffffffff8052b65e>] dev_hard_start_xmit+0x26e/0x2d0
 [<ffffffff80539ba0>] __qdisc_run+0xc0/0x1f0
 [<ffffffff8052dc2f>] dev_queue_xmit+0x24f/0x310
 [<ffffffff805337a7>] neigh_resolve_output+0xe7/0x290
 [<ffffffff8054f5c0>] dst_output+0x0/0x10
 [<ffffffff80552aff>] ip_output+0x19f/0x340
 [<ffffffff80551f77>] ip_queue_xmit+0x217/0x430
 [<ffffffff80563b2a>] tcp_transmit_skb+0x40a/0x7c0
 [<ffffffff805657bb>] __tcp_push_pending_frames+0x11b/0x940
 [<ffffffff8055972a>] tcp_sendmsg+0x87a/0xc80
 [<ffffffff80577735>] inet_sendmsg+0x45/0x80
 [<ffffffff8051e2d4>] sock_aio_write+0x104/0x120
 [<ffffffff80285fc1>] do_sync_write+0xf1/0x130
 [<ffffffff80243290>] autoremove_wake_function+0x0/0x40
 [<ffffffff802868e9>] vfs_write+0x159/0x170
 [<ffffffff80286ef0>] sys_write+0x50/0x90
 [<ffffffff802097fe>] system_call+0x7e/0x83


