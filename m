From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [RFC] Re: 2.6.20->2.6.21 - networking dies after random time
Date: Thu, 9 Aug 2007 16:50:27 +0200
Message-ID: <20070809145026.GB3064@ff.dom.local>
References: <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <46B75DD4.5080709@redhat.com> <20070806190812.GD26868@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>,
	Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070806190812.GD26868@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It seems, we can start to think about some preferred solutions,
already. Here are some of my preliminary conclusions and suggestions.

The problem of timeouts with some 'older' network cards seems to hit
mainly x86_64 arch, and after diagnosing and testing (still beeing
done) it's caused by resending level type irqs.

Possible solutions:

1. Reverting the whole "do not mask interrupts by default" patch:

Seems to be the most natural, but there are some minuses: this patch
has been here for a long time and some archs/drivers could have been
changed in the meantime and depend on this; this could also remove
possible good sides of this patch for which it was aimed (mainly for
edge type irqs), so some old problems could be back.


2. Excluding all level type irqs from resending. There are 2 ways:

a) Just like this is done now in -rc2 with Thomas' patch and AFAIK
seems to work very well; the way to find the type of interrupt by
the name of a handler looks a bit 'temporary' but it's simple and
working; it could be a bit moved and under #ifdef CONFIG_, so
this could affect only choosen ones.

b) Alternatively this could be done by e.g. assigning separate
irq_chip structures for edge and level handlers, so for levels there
would be chip->retrigger == NULL; so this could be done by arches
without any need for 'global' changes. The only minus here is a few
bytes of memory more; on the other hand it looks more readable and
elastic.

3. Using HARDIRQS_SW_RESEND for level type irqs:
seems to work, but needs more testing; but if #2 is theoretically
and practically OK, why bother. This also doesn't need any global
changes.

I prefer 2b + 3: since this is very delicate measure, I think there
should be visible CONFIG_ option: at least for disabling
chip->retrigger handler if used by arch and maybe for using
_SW_RESEND instead, as well.

It looks like these changes are needed for this x86_64 only, but
in my opinion some (good?!) apics could sometimes work OK with this
level resending only "by chance": theoretically it's questionable:
since edge type irqs used for this should be resent if not acked, and
level handlers ack time depends on how long drivers do their job,
there are possible strange and hard to repeat effects, for no reason
(if these levels can really always be skipped without any problem,
like seen in testing).

Then of course it would be easier to do this 'globally' with 2a.:
skipping by default (but #ifdef) chip->retrigger namely for:
handler_fasteoi_irq and handler_level_irq and handler_simple_irq;
handle_edge_irq plus others are always tried. 

I hope, Ingo or Thomas will use something of these, or let us know
about maybe something else which should by tested for final inclusion.

Regards,
Jarek P.
