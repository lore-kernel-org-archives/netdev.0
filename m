From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 30 Jul 2007 09:29:38 +0200
Message-ID: <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
References: <20070724080534.GC18740@elte.hu>
	 <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
	 <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos>
	 <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com>
	 <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos>
	 <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local>
	 <20070726091254.GA8063@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Ingo Molnar" <mingo@elte.hu>, "Jarek Poplawski" <jarkao2@o2.pl>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Jean-Baptiste Vignaud" <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:59560 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762012AbXG3H3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 03:29:39 -0400
Received: by rv-out-0910.google.com with SMTP id k20so347421rvb
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 00:29:38 -0700 (PDT)
In-Reply-To: <20070726091254.GA8063@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/7/26, Ingo Molnar <mingo@elte.hu>:
> (..)
> yeah - i meant to cover both arches but forgot about x86_64 - updated
> patch attached below.
>
>         Ingo
>
> ----------------->
> Subject: x86: activate HARDIRQS_SW_RESEND
> From: Ingo Molnar <mingo@elte.hu>
>
> activate the software-triggered IRQ-resend logic.
>
> it appears some chipsets/cpus do not handle local-APIC driven IRQ
> resends all that well, so always use the soft mechanism to trigger
> the execution of pending interrupts.
>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  arch/i386/Kconfig   |    4 ++++
>  arch/x86_64/Kconfig |    4 ++++
>  kernel/irq/manage.c |    8 ++++++++
>  3 files changed, 16 insertions(+)
>
> Index: linux-rt-rebase.q/arch/i386/Kconfig
> ===================================================================
> --- linux-rt-rebase.q.orig/arch/i386/Kconfig
> +++ linux-rt-rebase.q/arch/i386/Kconfig
> @@ -1284,6 +1284,10 @@ config GENERIC_PENDING_IRQ
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
> Index: linux-rt-rebase.q/arch/x86_64/Kconfig
> ===================================================================
> --- linux-rt-rebase.q.orig/arch/x86_64/Kconfig
> +++ linux-rt-rebase.q/arch/x86_64/Kconfig
> @@ -721,6 +721,10 @@ config GENERIC_PENDING_IRQ
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
> Index: linux-rt-rebase.q/kernel/irq/manage.c
> ===================================================================
> --- linux-rt-rebase.q.orig/kernel/irq/manage.c
> +++ linux-rt-rebase.q/kernel/irq/manage.c
> @@ -175,6 +175,14 @@ void enable_irq(unsigned int irq)
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

This patch didn't help (tested on 2.6.22.1) - ne2k_pci timed out.

ps: I retested all patches posted in this thread on top of 2.6.22.1
and behavior from 2.6.21.3 didn't changed. My next tests will be on
2.6.22.x only.

Regards,
Marcin Slusarz
