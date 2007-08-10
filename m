From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70
	check_irq_resend()
Date: Fri, 10 Aug 2007 10:56:11 +0200
Message-ID: <20070810085611.GA11639@elte.hu>
References: <18107.11431.838905.331157@stoffel.org> <20070809155445.GA5161@ff.dom.local> <1186733140.12828.45.camel@chaos> <20070810082346.GD1764@ff.dom.local> <20070810083050.GA4545@elte.hu> <20070810084924.GF1764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	marcin.slusarz@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070810084924.GF1764@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> > > [...] Well, there are probably (but need more testing) two other 
> > > solutions: _SW_RESEND and disabling without delay for levels 
> > > only...
> > 
> > IIRC Marcin tested software-resend and it didnt fix the hang. That 
> > strongly points in the direction of a driver bug (or a genirq bug) 
> > being made more prominent by the genirq change - not any hardware 
> > detail such as the APIC vector-retrigger sequence.
> > 
> > While we'd like to see the suspected driver bug (or any higher level 
> > genirq bug) fixed, we'll undo the effect of the genirq change 
> > (because it is causing a regression). We'll also add a separate, 
> > optional irq-debugging feature that generates high-rate interrupts 
> > on any shared irq line. (and thus artificially stresses the 
> > robustness of the driver and the genirq layer against spurious 
> > interrupts.)
> 
> Not exactly so... I've send modified version of your software-resend 
> patch, and it seems to work OK.

ah, i completely missed that! Thanks :-)

this changes the picture completely and makes the IO-APIC/local-APIC hw 
retrigger code/logic the main suspect. I think you right that it's quite 
bogus to hw-retrigger level irqs, and that could be confusing the 
IO-APIC (or the local APIC, or both).

and i think i see why my first sw-resend patch didnt do the trick:

> > -               if (!desc->chip || !desc->chip->retrigger ||
> > -                                       !desc->chip->retrigger(irq)) {
> > +               if (desc->handle_irq == handle_edge_irq) {
> > +                       if (desc->chip->retrigger)
> > +                               desc->chip->retrigger(irq);
> > +                       return;
> > +               }
> >  #ifdef CONFIG_HARDIRQS_SW_RESEND

we used the hw-resend method unconditionally, right?

	Ingo
