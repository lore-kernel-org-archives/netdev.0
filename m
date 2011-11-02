From: "Reuben Dowle" <Reuben.Dowle@navico.com>
Subject: RE: [PATCH] flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK
Date: Wed, 2 Nov 2011 13:25:07 +1300
Message-ID: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA5D9@exch01-aklnz.MARINE.NET.INT>
References: <70F6AAAFDC054F41B9994A9BCD3DF64E16FAA1DD@exch01-aklnz.MARINE.NET
 .INT> <4EAF21A6.702@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>
To: "Marc Kleine-Budde" <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vw-hfger.navico.com ([81.89.228.210]:1308 "EHLO
	VW-HFGER.navico.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743Ab1KBAZL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 20:25:11 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4EAF21A6.702@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Patch looks quite good. Can you please wrap the description to about 72
> chars?

Will do.

> >  	}
> >
> > @@ -670,6 +671,8 @@ static int flexcan_chip_start(struct net_device
> *dev)
> >  	int err;
> >  	u32 reg_mcr, reg_ctrl;
> >
> > +	can_free_echo_skb(dev, 0);
> 
> what about putting this to flexcan_chip_stop? Otherwise you risk a
> memleak if you do "ifconfig down; rmmod flexcan"

I originally thought this needs to be in flexcan_chip_start, so the bus off followed by restart sequence will drop the loopback packet. I investigated a bit deeper and can_flush_echo_skb is called in can_restart(). So my call of that function is not really needed. can_flush_echo_skb is also called in close_candev, which is called by the flexcan driver. So I actually think this function does not need to be called by the driver at all. What do you think?

> >
> >  	dev->netdev_ops = &flexcan_netdev_ops;
> >  	dev->irq = irq;
> > -	dev->flags |= IFF_ECHO; /* we support local echo in hardware */
> > +	
> > +	/* Driver supports local echo.
> > +	 * We support local echo in hardware, however this is not used
> because
> > +	 * hardware local echo loses the sending socket reference
> > +	 * (thus CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK socket
> options
> > +	 *  would not work)
> > +	 */
> 
> IMHO, you can skip this comment. The patch description is good enough.

Ok, I will drop the extra comments from the patch.
