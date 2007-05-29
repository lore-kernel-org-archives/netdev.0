From: "Gary Zambrano" <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Tue, 29 May 2007 14:05:41 -0700
Message-ID: <1180472741.17711.19.camel@dhcp-10-12-136-115.broadcom.com>
References: <20070525172431.60affaca@freepuppy>
 <200705281655.15105.mb@bu3sch.de>
 <1180448075.17146.12.camel@dhcp-10-12-136-115.broadcom.com>
 <200705292245.22940.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Maximilian Engelhardt" <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Stephen Hemminger" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	"Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705292245.22940.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-29 at 22:45 +0200, Michael Buesch wrote:
> On Tuesday 29 May 2007 16:14:35 Gary Zambrano wrote:
> > On Mon, 2007-05-28 at 16:55 +0200, Michael Buesch wrote:
> > > On Monday 28 May 2007 16:12:12 Maximilian Engelhardt wrote:
> > > > On Monday 28 May 2007, Michael Buesch wrote:
> > > > > Can you also test the following patch?
> > > > > I think there's a bug in b44 that is doesn't properly discard
> > > > > shared IRQs, so it might possibly generate a NAPI storm, dunno.
> > > > > Worth a try.
> > > > >
> > > > > Index: linux-2.6.22-rc3/drivers/net/b44.c
> > > > > ===================================================================
> > > > > --- linux-2.6.22-rc3.orig/drivers/net/b44.c	2007-05-27 23:01:44.000000000
> > > > > +0200 +++ linux-2.6.22-rc3/drivers/net/b44.c	2007-05-28 12:48:27.000000000
> > > > > +0200 @@ -911,6 +911,8 @@ static irqreturn_t b44_interrupt(int irq
> > > > >  	spin_lock(&bp->lock);
> > > > >
> > > > >  	istat = br32(bp, B44_ISTAT);
> > > > > +	if (istat == 0xFFFFFFFF)
> > > > > +		goto out; /* Shared IRQ not for us */
> > > > >  	imask = br32(bp, B44_IMASK);
> > > > >
> > > > >  	/* The interrupt mask register controls which interrupt bits
> > > > > @@ -942,6 +944,7 @@ irq_ack:
> > > > >  		bw32(bp, B44_ISTAT, istat);
> > > > >  		br32(bp, B44_ISTAT);
> > > > >  	}
> > > > > +out:
> > > > >  	spin_unlock(&bp->lock);
> > > > >  	return IRQ_RETVAL(handled);
> > > > >  }
> > > > 
> > > > I did try this patch on a affected kernel, but I didn't notice any big 
> > > > difference. Perhaps the kernel is a bit less slow during the test, but It's 
> > > > hard to tell.
> > > 
> > > Ok, but anyway. I think this is a bug and needs to be fixed this way. Gary?
> > > 
> > 
> > Thanks Michael.
> > No, I don't think this is a bug and it does not need to be fixed.
> 
> Are you sure? I'm not so sure, because
> 1) On bcm43xx the reverse engineers told us that the card
>    returns 0xFFFFFFFF for no-irq-pending. Since b44 and bcm43xx
>    are very similiar in IRQ and DMA I just thought it would
>    be the case there, too. Just guessing.
The b44 interrupt status reg returns a value of 0 if no interrupts are
pending. The b44 uses a mask to determine which bits (events) can
generate device interrupts on the system. If the masked interrupt status
register bits are not asserted, then the b44 will return to the system
with handled = 0. 
So, I think the way the b44 interrupt code is written should be ok and
not a bug. 


> 2) PCMCIA cards usually return all-ones if you try to read a
>    register of a card that's been removed. So it's good
>    practice to check for this and bail out early in the IRQ
>    path. Do PCMCIA cards (PC-card, not neccessarily a real
>    16bit PCMCIA card) for b44 exist?

I do not know of any pccard application of the b44. As far as I know
b44s live on motherboards and in the wireless soc.

Thanks,
Gary
