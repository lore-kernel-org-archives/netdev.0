From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Fwd: [RFT] NAPI for 8139too]
Date: Mon, 20 Oct 2003 08:41:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020084147.3bb5b25c.shemminger@osdl.org>
References: <3F9070B6.9090306@pobox.com>
	<873cdqbt6z.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <873cdqbt6z.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2003 21:56:20 +0900
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> wrote:

> Hi,
> 
> I also working for it (patches attached). So I have several comment.
> 
> Jeff Garzik <jgarzik@pobox.com> writes:
> 
> > +	dev->weight = 16;
> 
> just question: Is there basis for believing that this value is
> rightness?  Although I use 64, I don't have a reason for having chosen
> it at all.

I chose 16 only because that was in the sample NAPI documentation,
but it probably doesn't matter a lot unless you have multiple NIC's using
NAPI in the same machine, which is not common since this chipset seems to be used
mostly in cheap boxes.

> 
> >  	dev->stop = rtl8139_close;
> >  	dev->get_stats = rtl8139_get_stats;
> >  	dev->set_multicast_list = rtl8139_set_rx_mode;
> > @@ -1879,24 +1877,28 @@
> >  #endif
> >  }
> >  
> > -static void rtl8139_rx_interrupt (struct net_device *dev,
> > -				  struct rtl8139_private *tp, void *ioaddr)
> > +/*
> > + * NAPI poll routine.
> > + */
> > +static int rtl8139_poll(struct net_device *dev, int *budget)
> >  {
> > +	struct rtl8139_private *tp = dev->priv;
> > +	void *ioaddr = tp->mmio_addr;
> >  	unsigned char *rx_ring;
> >  	u16 cur_rx;
> > +	int rx, status;
> > +	unsigned long flags;
> >  
> > -	assert (dev != NULL);
> > -	assert (tp != NULL);
> > -	assert (ioaddr != NULL);
> > -
> > +	spin_lock_irqsave(&tp->lock, flags);
> 
> I don't think lock of interrupt related path needed here. And this
> thinks that it has a bad influence on TX path.
> 
> Instead of it, I think we need synchronize with ->tx_timeout because
> ->tx_timeout touch IntrMask.

Locking in this version is more conservative than necessary, will think about
how to do it better.


> > + rescan:
> >  	rx_ring = tp->rx_ring;
> >  	cur_rx = tp->cur_rx;
> > -
> [...]
> >  			RTL_W16_F (IntrStatus, RxAckBits);
> > +
> > +		if (++rx >= dev->quota)
> 
> Shouldn't we use "min(dev->quota, *budget)" for this limit? Users can
> change "budget" via sysctl.

Once again, this not what the documentation, or some other drivers do.

> 
> > +	/* If received interrupt, then disable furthur interrupts
> > +	 * and enable NAPI polling.
> > +	 */
> > +	if (netif_running (dev) && (status & RxAckBits)) {
> > +		/* disable more receive interrupts */
> > +		RTL_W16 (IntrMask, rtl8139_intr_mask & ~RxAckBits);
> > +		netif_rx_schedule(dev);
> > +	}
> 
> This style have problem on shutdowning interface path. Please see
> 8139too-napi-stop-fix.patch.
> 
> Thanks.
> -- 
> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
> 
> 
