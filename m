From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.24-git] net/enc28j60: low power mode
Date: Wed, 06 Feb 2008 10:19:12 -0800
Message-ID: <20080206181912.6E2E08E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
 <47A9EA42.3080800@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lanconelli.claudio@eptar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.sbc.mail.mud.yahoo.com ([68.142.198.210]:29737 "HELO
	smtp111.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751099AbYBFSTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 13:19:18 -0500
In-Reply-To: <47A9EA42.3080800@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Keep enc28j60 chips in low-power mode when they're not in use.
> > At typically 120 mA, these chips run hot even when idle.  Low
> > power mode cuts that power usage by a factor of around 100.
>
> Good idea, but with your patch applied, after some ifconfig down - 
> ifconfig up cycle, the
> enc28j60 is left in an unknown state and it doesn' Rx/Tx anything.

The driver seemed to already have some goofage there:

  # ifconfig eth1 up
  net eth1: link down
  net eth1: link down
  net eth1: normal mode
  net eth1: multicast mode
  net eth1: multicast mode
  #

I'd normally expect it not to go down when told to go up, and
then only to do the multicast thing once ...


> In such cases If I dump the counters with ifconfig I got rx error 
> counter > 0 and the RX and TX packets counters are freezed.
> Actually I don't know what causes the freeze, it needs investigation. 
> The cause can be the rx error condition or the power down/up commands.
> May be receiving packets while it's going to wakeup causes problems.

The enc28j60_setlink() was odd too.  It insists the link be down
before changing duplex, then brings the link up ... so I had to
put it down again to maintain the "lowpower if not up" invariant.

But the way it brings the link up is to enc28j60_hw_init(), which
it also does when bringing the link up.  So there's no need to
bring the link up when changing duplex ...


> > +/*
> > + * Low power mode shrinks power consumption about 100x, so we'd like
> > + * the chip to be in that mode whenever it's inactive.
> > + */
> > +static void enc28j60_lowpower(struct enc28j60_net *priv, bool is_low)
> > +{
> > +	int	tmp;
> > +
> > +	dev_dbg(&priv->spi->dev, "%s power...\n", is_low ? "low" : "high");
>
> use
> if(netif_msg_drv(priv)) ...
> Doing so we can switch on/off messages runtime using ethtool.

OK, although there's still a role for "-DDEBUG" compile-time
mesage removal.


> printk(...  instead of dev_dbg(), please.

Actually, I had to resist sending a patch converting this driver
to stop abusing printk in all those locations it should have been
using dev_*() messaging instead.

And to use the dev_*() messaging correctly ... the above shouldn't
have said "net eth1", but either "eth1:" or "enc28j60 spi1.0".

The general policy in the kernel is to avoid using printk for driver
messaging.  Couple messages to the hardware, so that when there are
two instances it's easy to tell which chip is affected.  That happens
for free with the "driver and device" prefix of the dev_*() messages.
	
In absense of interface renaming, network devices sometimes use "eth1"
style message prefixes ... after a previous message coupling that to
the particular hardware.

This driver also abuses __FUNCTION__ (general policy:  don't use it)
and underuses the "-DDEBUG" compile-time string removal.


> > +
> > +	mutex_lock(&priv->lock);
> > +	if (is_low) {
> > +		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
> > +		for (;;) {
> > +			tmp = nolock_regb_read(priv, ESTAT);
> > +			if (!(tmp & ESTAT_RXBUSY))
> > +				break;
> > +		}
> >   
> Avoid infinite waiting loops, please.
> Look at enc28j60_phy_read() for example.

Then there should be a single routine for all such busy-wait loops,
so each such usage doesn't need to be open-coded.  Less space, and
more obviously correct.  I'll add one and make phy_read() use it too.


> > +		for (;;) {
> > +			tmp = nolock_regb_read(priv, ECON1);
> > +			if (!(tmp & ECON1_TXRTS))
> > +				break;
> > +		}
> >   
> idem
> > +		/* ECON2_VRPS was set during initialization */
> > +		nolock_reg_bfset(priv, ECON2, ECON2_PWRSV);
> > +	} else {
> > +		nolock_reg_bfclr(priv, ECON2, ECON2_PWRSV);
> > +		for (;;) {
> > +			tmp = nolock_regb_read(priv, ESTAT);
> > +			if (tmp & ESTAT_CLKRDY)
> > +				break;
> > +		}
> >   
> idem
>
