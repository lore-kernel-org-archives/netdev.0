From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V8 12/13] ptp: Added a clock driver for the IXP46x.
Date: Fri, 7 Jan 2011 18:07:52 +0100
Message-ID: <20110107170752.GB8666@riccoc20.at.omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <8151196c018776704df34748f333bdb159497d0b.1293820862.git.richard.cochran@omicron.at>
 <m3ei8plpa0.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m3ei8plpa0.fsf-gTjgKJgtlHj77SC2UrCW1FMQynFLKtET@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Krzysztof,

Thanks for your review. I have some responses, below.

But before that, I have a big favor to ask you. Can you please look at
the TODO in my patch and give me a hint? I don't know how to relate
the port instance (NPE A,B,C) to the two time stamping channels.

On Thu, Jan 06, 2011 at 10:01:59PM +0100, Krzysztof Halasa wrote:
> Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> > +	u32 SrcUUIDHi;  /* 0x5C Sequence Identifier/Source UUID0 High */
> 
> I don't like these XxxYyyZzz either :-(

Okay, I'll change that.

> > +static void do_tx_timestamp(struct port *port, struct sk_buff *skb)
> > +{
> > +#ifdef __ARMEB__
...
> > +#endif
> > +}
> 
> And what if we're little-endian?

It is a NOOP in that case.

> Why does it depend on BE?

The time stamp code clones the skb, but the LE version frees the skb
too early. Perhaps we can move that dev_kfree_skb(skb) in the LE case
to be the last statement in eth_xmit(). What do you think?

> 
> > @@ -1171,6 +1357,11 @@ static int __devinit eth_init_one(struct platform_device *pdev)
> >  	char phy_id[MII_BUS_ID_SIZE + 3];
> >  	int err;
> >  
> > +	if (ptp_filter_init(ptp_filter, ARRAY_SIZE(ptp_filter))) {
> > +		pr_err("ixp4xx_eth: bad ptp filter\n");
> > +		return -EINVAL;
> > +	}
> > +
> >  	if (!(dev = alloc_etherdev(sizeof(struct port))))
> >  		return -ENOMEM;
> 
> Shouldn't it depend on CPU type?

It won't hurt to init the BPF unconditionally. The important bits are
checked with cpu_is_ixp46x().

> BTW which CPU is required? IXP46x (455/460/465)? Does it work on 43x?

IIRC, it does not work on 43x.

I don't know about 455 and 460, but I can find out...

> > +	if (NO_IRQ == irq)
> > +		return NO_IRQ;
> 
> Don't like these either :-(

Do you mean, you don't like the constant on the left hand side?

Is that prohibited by CodingStyle or similar?

I got into the habit of writing it that way to prevent a typo like:

	if (irq = NO_IRQ)

> Not showstoppers but...
> 
> Also I don't like the ixp_read/ixp_write() trivial macros. Why not
> simply call __raw_readl() and __raw_writel()?

Well, I have had the experience back in 2.4 days of having my drivers
ruined by the changing IO macros in the kernel. The wrappers are
supposed to help if that ever happens again. Seeing *two* leading
underscores in the macro names certainly makes me nervous.

Thanks again,

Richard
