From: Kulikov Vasiliy <segooon@gmail.com>
Subject: Re: [PATCH] at1700: fix double free_irq
Date: Fri, 9 Jul 2010 21:48:09 +0400
Message-ID: <20100709174809.GA5228@albatros>
References: <1278678686-7215-1-git-send-email-segooon@gmail.com>
 <20100709165817.GN19184@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52179 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab0GIRsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 13:48:36 -0400
Content-Disposition: inline
In-Reply-To: <20100709165817.GN19184@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 09, 2010 at 18:58 +0200, Dan Carpenter wrote:
> On Fri, Jul 09, 2010 at 04:31:26PM +0400, Kulikov Vasiliy wrote:
> > free_irq() is called both in net_close() and cleanup_card().  Since it
> > is requested in at1700_probe1(), leave free_irq() only in cleanup_card()
> > for balance.
> > 
> 
> Are you sure? I would think that we should make the free_irq() in
> cleanup_card() conditional instead.
See balanced functions: net_open() & net_close(), at1700_probe1() &
cleanup_card(). request_irq() is in probe, so it must not be
freed on 'ifconfig down'. E.g.

modprobe at1700 <== request_irq()
ifconfig eth0 up
ifconfig eth0 down <== first free_irq()
ifconfig eth0 up   <== no request_irq() here!
ifconfig eth0 down <== second free_irq()
rmmod at1700 <== third free_irq()

> 
> > Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
> > ---
> >  drivers/net/at1700.c |    4 +---
> >  1 files changed, 1 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
> > index 93185f5..8987689 100644
> > --- a/drivers/net/at1700.c
> > +++ b/drivers/net/at1700.c
> > @@ -811,10 +811,8 @@ static int net_close(struct net_device *dev)
> >  	/* No statistic counters on the chip to update. */
> >  
> >  	/* Disable the IRQ on boards of fmv18x where it is feasible. */
>         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> It seems like this comment should be updated?

Maybe yes, but I don't know what these damn IO requests mean.
Sure, it's better to request IRQ in xxx_open(), but as it is already
done in probe() I leave it here.

If it is a bug then I do nothing with it, but if it is not then I'll
create a bug.

> 
> > -	if (lp->jumpered) {
> > +	if (lp->jumpered)
> >  		outb(0x00, ioaddr + IOCONFIG1);
> > -		free_irq(dev->irq, dev);
> > -	}
> 
> regards,
> dan carpenter
