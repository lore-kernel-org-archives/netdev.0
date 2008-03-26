From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] de2104x: remove BUG_ON() when changing media type
Date: Wed, 26 Mar 2008 09:59:57 -0600
Message-ID: <20080326155957.GA24944@colo.lackof.org>
References: <200801262158.12016.linux@rainbow-software.org> <47C30051.3020909@pobox.com> <20080324024514.GB474@colo.lackof.org> <200803250002.21718.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:59828 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426AbYCZQAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 12:00:09 -0400
Content-Disposition: inline
In-Reply-To: <200803250002.21718.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2008 at 12:02:19AM +0100, Ondrej Zary wrote:
....
> > Jeff,
> > The above patch was applied and fixes the 'panic' part of the problme.
> > Can you take a look at this patch to fix the "chip is still running"
> > part of this bug?
> 
> I'll test it but I doubt that it fixes the problem. IIRC, I tried something 
> like that.

Thanks (in advance) for testing!

This patch fixed the same symptom for tulip driver many years ago.
It's been validated already and should be applied to de2104x driver too.

If it doesn't fix the problem, that just means something else
is going wrong as well.

> Even tried resetting the chip multiple times when this problem 
> appears but everything failed.

Can you print the last value from dr32(MacStatus)?
(just append the output to the "stopping DMA" printk)

If resetting the chip isn't working, my guess is the PCI bus is
out to lunch. Getting ~0 back on the MMIO read would be evidence
of that. But resetting the chip isn't trivial and all sorts of
things could go wrong with that.

thanks,
grant

> 
> 
> >
> > BTW, I inherited a bug report for the same symptom:
> >     http://bugzilla.kernel.org/show_bug.cgi?id=3156
> >
> > thanks,
> > grant
> >
> > Signed-off-by: Grant Grundler
> >
> > --- linux-2.6.23/drivers/net/tulip/de2104x.c	2007-10-09 13:31:38.000000000
> > -0700 +++ linux-2.6.23/drivers/net/tulip/de2104x.c-ggg	2007-11-02
> > 23:24:46.000000000 -0700 @@ -842,7 +842,7 @@
> >  static void de_stop_rxtx (struct de_private *de)
> >  {
> >  	u32 macmode;
> > -	unsigned int work = 1000;
> > +	unsigned int i = 1300/100;
> >
> >  	macmode = dr32(MacMode);
> >  	if (macmode & RxTx) {
> > @@ -850,10 +850,14 @@
> >  		dr32(MacMode);
> >  	}
> >
> > -	while (--work > 0) {
> > +	/* wait until in-flight frame completes.
> > +	 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
> > +	 * Typically expect this loop to end in < 50 us on 100BT.
> > +	 */
> > +	while (--i) {
> >  		if (!de_is_running(de))
> >  			return;
> > -		cpu_relax();
> > +		udelay(100);
> >  	}
> >
> >  	printk(KERN_WARNING "%s: timeout expired stopping DMA\n", de->dev->name);
> 
> 
> 
> -- 
> Ondrej Zary
