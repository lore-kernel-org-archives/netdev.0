From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 30 Jul 2007 10:49:25 +0200
Message-ID: <20070730084925.GA12695@elte.hu>
References: <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org> <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com> <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Marcin =C5=9Alusarz <marcin.slusarz@gmail.com> wrote:

> > Subject: x86: activate HARDIRQS_SW_RESEND
> > From: Ingo Molnar <mingo@elte.hu>
> >
> > activate the software-triggered IRQ-resend logic.

> This patch didn't help (tested on 2.6.22.1) - ne2k_pci timed out.

ok. This makes it more likely that the driver itself (or the card) gets=
=20
confused by the resend.

does the patch below fix those timeouts? It tests the theory whether an=
y=20
POST latency could expose this problem.

	Ingo

Index: linux/drivers/net/lib8390.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.orig/drivers/net/lib8390.c
+++ linux/drivers/net/lib8390.c
@@ -375,6 +375,8 @@ static int ei_start_xmit(struct sk_buff=20
 	/* Turn 8390 interrupts back on. */
 	ei_local->irqlock =3D 0;
 	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
+	/* force POST: */
+	ei_inb_p(e8390_base + EN0_IMR);
=20
 	spin_unlock(&ei_local->page_lock);
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
