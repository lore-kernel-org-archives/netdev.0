From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 8 Aug 2007 13:42:43 +0200
Message-ID: <20070808114243.GC2426@ff.dom.local>
References: <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com> <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com> <20070807095246.GB3223@ff.dom.local> <20070807121339.GA3946@ff.dom.local> <4bacf17f0708080409t116b5c84ye60dff7da51d0fdf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0708080409t116b5c84ye60dff7da51d0fdf@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Read below please:

On Wed, Aug 08, 2007 at 01:09:36PM +0200, Marcin =A6lusarz wrote:
> 2007/8/7, Jarek Poplawski <jarkao2@o2.pl>:
> > So, the let's try this idea yet: modified Ingo's "x86: activate
> > HARDIRQS_SW_RESEND" patch.
> > (Don't forget about make oldconfig before make.)
> > For testing only.
> >
> > Cheers,
> > Jarek P.
> >
> > PS: alas there was not even time for "compile checking"...
> >
> > ---
> >
> > diff -Nurp 2.6.22.1-/arch/i386/Kconfig 2.6.22.1/arch/i386/Kconfig
> > --- 2.6.22.1-/arch/i386/Kconfig 2007-07-09 01:32:17.000000000 +0200
> > +++ 2.6.22.1/arch/i386/Kconfig  2007-08-07 13:13:03.000000000 +0200
> > @@ -1252,6 +1252,10 @@ config GENERIC_PENDING_IRQ
> >         depends on GENERIC_HARDIRQS && SMP
> >         default y
> >
> > +config HARDIRQS_SW_RESEND
> > +       bool
> > +       default y
> > +
> >  config X86_SMP
> >         bool
> >         depends on SMP && !X86_VOYAGER
> > diff -Nurp 2.6.22.1-/arch/x86_64/Kconfig 2.6.22.1/arch/x86_64/Kconf=
ig
> > --- 2.6.22.1-/arch/x86_64/Kconfig       2007-07-09 01:32:17.0000000=
00 +0200
> > +++ 2.6.22.1/arch/x86_64/Kconfig        2007-08-07 13:13:03.0000000=
00 +0200
> > @@ -690,6 +690,10 @@ config GENERIC_PENDING_IRQ
> >         depends on GENERIC_HARDIRQS && SMP
> >         default y
> >
> > +config HARDIRQS_SW_RESEND
> > +       bool
> > +       default y
> > +
> >  menu "Power management options"
> >
> >  source kernel/power/Kconfig
> > diff -Nurp 2.6.22.1-/kernel/irq/manage.c 2.6.22.1/kernel/irq/manage=
=2Ec
> > --- 2.6.22.1-/kernel/irq/manage.c       2007-07-09 01:32:17.0000000=
00 +0200
> > +++ 2.6.22.1/kernel/irq/manage.c        2007-08-07 13:13:03.0000000=
00 +0200
> > @@ -169,6 +169,14 @@ void enable_irq(unsigned int irq)
> >                 desc->depth--;
> >         }
> >         spin_unlock_irqrestore(&desc->lock, flags);
> > +#ifdef CONFIG_HARDIRQS_SW_RESEND
> > +       /*
> > +        * Do a bh disable/enable pair to trigger any pending
> > +        * irq resend logic:
> > +        */
> > +       local_bh_disable();
> > +       local_bh_enable();
> > +#endif
> >  }
> >  EXPORT_SYMBOL(enable_irq);
> >
> > diff -Nurp 2.6.22.1-/kernel/irq/resend.c 2.6.22.1/kernel/irq/resend=
=2Ec
> > --- 2.6.22.1-/kernel/irq/resend.c       2007-07-09 01:32:17.0000000=
00 +0200
> > +++ 2.6.22.1/kernel/irq/resend.c        2007-08-07 13:57:54.0000000=
00 +0200
> > @@ -62,16 +62,24 @@ void check_irq_resend(struct irq_desc *d
> >          */
> >         desc->chip->enable(irq);
> >
> > +       /*
> > +        * Temporary hack to figure out more about the problem, whi=
ch
> > +        * is causing the ancient network cards to die.
> > +        */
> > +
> >         if ((status & (IRQ_PENDING | IRQ_REPLAY)) =3D=3D IRQ_PENDIN=
G) {
> >                 desc->status =3D (status & ~IRQ_PENDING) | IRQ_REPL=
AY;
> >
> > -               if (!desc->chip || !desc->chip->retrigger ||
> > -                                       !desc->chip->retrigger(irq)=
) {
> > +               if (desc->handle_irq =3D=3D handle_edge_irq) {
> > +                       if (desc->chip->retrigger)
> > +                               desc->chip->retrigger(irq);
> > +                       return;
> > +               }
> >  #ifdef CONFIG_HARDIRQS_SW_RESEND
> > -                       /* Set it pending and activate the softirq:=
 */
> > -                       set_bit(irq, irqs_resend);
> > -                       tasklet_schedule(&resend_tasklet);
> > +               WARN_ON_ONCE(1);
> > +               /* Set it pending and activate the softirq: */
> > +               set_bit(irq, irqs_resend);
> > +               tasklet_schedule(&resend_tasklet);
> >  #endif
> > -               }
> >         }
> >  }
> >
> Works fine with:

Very nice! It would be about time this kernel should start behave...

> WARNING: at kernel/irq/resend.c:79 check_irq_resend()
>=20
> Call Trace:
>  [<ffffffff8025e660>] check_irq_resend+0xc0/0xd0
>  [<ffffffff8025e1cd>] enable_irq+0xed/0xf0
>  [<ffffffff8807f21d>] :8390:ei_start_xmit+0x14d/0x30c
>  [<ffffffff8024d055>] lock_release_non_nested+0xe5/0x190
>  [<ffffffff80539b78>] __qdisc_run+0x98/0x1f0
>  [<ffffffff80539b8e>] __qdisc_run+0xae/0x1f0
>  [<ffffffff8052b65e>] dev_hard_start_xmit+0x26e/0x2d0
>  [<ffffffff80539ba0>] __qdisc_run+0xc0/0x1f0
>  [<ffffffff8052dc2f>] dev_queue_xmit+0x24f/0x310
>  [<ffffffff805337a7>] neigh_resolve_output+0xe7/0x290
>  [<ffffffff8054f5c0>] dst_output+0x0/0x10
>  [<ffffffff80552aff>] ip_output+0x19f/0x340
>  [<ffffffff80551f77>] ip_queue_xmit+0x217/0x430
>  [<ffffffff80563b2a>] tcp_transmit_skb+0x40a/0x7c0
>  [<ffffffff805657bb>] __tcp_push_pending_frames+0x11b/0x940
>  [<ffffffff8055972a>] tcp_sendmsg+0x87a/0xc80
>  [<ffffffff80577735>] inet_sendmsg+0x45/0x80
>  [<ffffffff8051e2d4>] sock_aio_write+0x104/0x120
>  [<ffffffff80285fc1>] do_sync_write+0xf1/0x130
>  [<ffffffff80243290>] autoremove_wake_function+0x0/0x40
>  [<ffffffff802868e9>] vfs_write+0x159/0x170
>  [<ffffffff80286ef0>] sys_write+0x50/0x90
>  [<ffffffff802097fe>] system_call+0x7e/0x83
>=20

So, it looks like x86_64 io_apic's IPI code was unused too long...
I hope it's a piece of cake for Ingo now...

Thanks very much Marcin!

If it's possible for you and Jean-Baptiste, try this today patch
with -rc2, and maybe once more this one patch (-rc1 or older).

Regards,
Jarek P.=20

