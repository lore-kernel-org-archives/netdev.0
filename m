From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 25 Jul 2007 09:23:45 +0200
Message-ID: <20070725072345.GA1843@ff.dom.local>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com> <20070629150759.GC2771@ff.dom.local> <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com> <20070724080534.GC18740@elte.hu> <20070724094202.GA11610@elte.hu> <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org> <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcin ??lusarz <marcin.slusarz@gmail.com>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:37749 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759788AbXGYHOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 03:14:33 -0400
Content-Disposition: inline
In-Reply-To: <1185322771.4175.102.camel@chaos>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 25, 2007 at 02:19:31AM +0200, Thomas Gleixner wrote:
> On Tue, 2007-07-24 at 22:04 +0200, Ingo Molnar wrote:
> > Marcin, could you try the patch below too? [without having any other 
> > patch applied.] It basically turns the critical section into an irqs-off 
> > critical section and thus checks whether your problem is related to that 
> > particular area of code.
> > 
> 
> I read back on this thread and I think the problem is somewhere else:

So do I. Of course, I certainly miss most of the details, but I can't
imagine how this yesterday Ingo's patch couldn't work - unless
Marcin's test wasn't long enough...

IMHO, the main problem is that such delicate things shouldn't be
changed this way. If current ideas work for Marcin they will probably
break other boxes. Very similar symptoms were reported before Ingo's
patch too, so it looks like this place is very fragile. If such
things could happen:

(from: arch/i386/kernel/io_apic.c)
> static void ack_ioapic_quirk_irq(unsigned int irq)
> ...
> /*
>  * It appears there is an erratum which affects at least version 0x11
>  * of I/O APIC (that's the 82093AA and cores integrated into various
>  * chipsets).  Under certain conditions a level-triggered interrupt is
>  * erroneously delivered as edge-triggered one but the respective IRR
>  * bit gets set nevertheless.  As a result the I/O unit expects an EOI
>  * message but it will never arrive and further interrupts are blocked
>  * from the source.  The exact reason is so far unknown, but the
>  * phenomenon was observed when two consecutive interrupt requests
>  * from a given source get delivered to the same CPU and the source is
>  * temporarily disabled in between.
...

there is no reason to think this is all.

I can also see this comment in arch/x86_64/kernel/io_apic.c:

> static void setup_IO_APIC_irq(int apic, int pin, unsigned int irq,
>                               int trigger, int polarity)
...
>        /* Mask level triggered irqs.
>         * Use IRQ_DELAYED_DISABLE for edge triggered irqs.
>         */

It seems somebody have seen a difference, probably after testing,
but it wasn't respected.

I also presume ne2k/lib8390.c solution could be a result of "real
life", and I don't think Marcin's tests can be enough here. 

So, my point is that such places first of all need some documented
knobs in config or elsewere, which make it possible for users to
easily go back to previous method (i.e. from 2.6.21 to 2.6.20 here).

Regards,
Jarek P.
