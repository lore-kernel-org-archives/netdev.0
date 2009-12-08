From: "Herring Robert-RA7055" <ra7055@freescale.com>
Subject: RE: [RFC][PATCH 06/10] fec: fix uninitialized rx buffer usage
Date: Mon, 7 Dec 2009 21:31:49 -0700
Message-ID: <DE2504B3A515524BBE6934369EFDC0DA08C2AA19@az33exm20.fsl.freescale.net>
References: <cover.1259893118.git.amit.kucheria@canonical.com> <7a49f4c0ea2f5030068729978c2cb173a6e15857.1259893118.git.amit.kucheria@canonical.com> <20091204111346.GL15126@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "List Linux Kernel" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<valentin.longchamp@epfl.ch>, <daniel@caiaq.de>,
	<grant.likely@secretlab.ca>,
	"Nguyen Dinh-R00091" <R00091@freescale.com>
To: "Sascha Hauer" <s.hauer@pengutronix.de>,
	"Amit Kucheria" <amit.kucheria@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43054 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757123AbZLHEbr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 23:31:47 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20091204111346.GL15126@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha,

> -----Original Message-----
> From: Sascha Hauer [mailto:s.hauer@pengutronix.de] 
> Sent: Friday, December 04, 2009 5:14 AM
> To: Amit Kucheria
> Cc: List Linux Kernel; Herring Robert-RA7055; David S. 
> Miller; netdev@vger.kernel.org; 
> linux-arm-kernel@lists.infradead.org; 
> valentin.longchamp@epfl.ch; daniel@caiaq.de; 
> grant.likely@secretlab.ca; Nguyen Dinh-R00091
> Subject: Re: [RFC][PATCH 06/10] fec: fix uninitialized rx buffer usage
> 
> On Fri, Dec 04, 2009 at 04:47:06AM +0200, Amit Kucheria wrote:
> > From: Rob Herring <r.herring@freescale.com>
> > 
> > The fec driver was enabling receive buffer descriptor 
> without allocating
> > the buffers. Make sure the buffer descriptors are initialized to not
> > start receiving packets.
> > 
> > Signed-off-by: Rob Herring <r.herring@freescale.com>
> > Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org
> > ---
> >  drivers/net/fec.c |   57 
> +++++++++++++++++++++++++++--------------------------
> >  1 files changed, 29 insertions(+), 28 deletions(-)
> > 
> > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > index 16a1d58..9a8743d 100644
> > --- a/drivers/net/fec.c
> > +++ b/drivers/net/fec.c
> > @@ -1658,6 +1658,7 @@ static int fec_enet_init(struct 
> net_device *dev, int index)
> >  {
> >  	struct fec_enet_private *fep = netdev_priv(dev);
> >  	struct bufdesc *cbd_base;
> > +	struct bufdesc *bdp;
> >  	int i;
> >  
> >  	/* Allocate memory for buffer descriptors. */
> > @@ -1710,6 +1711,34 @@ static int fec_enet_init(struct 
> net_device *dev, int index)
> >  	/* Set MII speed to 2.5 MHz */
> >  	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
> >  					/ 2500000) / 2) & 0x3F) << 1;
> > +
> > +	/* Initialize the receive buffer descriptors. */
> > +	bdp = fep->rx_bd_base;
> > +	for (i = 0; i < RX_RING_SIZE; i++) {
> > +
> > +		/* Initialize the BD for every fragment in the page. */
> > +		bdp->cbd_sc = 0;
> > +		bdp++;
> > +	}
> > +
> > +	/* Set the last buffer to wrap */
> > +	bdp--;
> > +	bdp->cbd_sc |= BD_SC_WRAP;
> > +
> > +	/* ...and the same for transmit */
> > +	bdp = fep->tx_bd_base;
> > +	for (i = 0; i < TX_RING_SIZE; i++) {
> > +
> > +		/* Initialize the BD for every fragment in the page. */
> > +		bdp->cbd_sc = 0;
> > +		bdp->cbd_bufaddr = 0;
> > +		bdp++;
> > +	}
> > +
> > +	/* Set the last buffer to wrap */
> > +	bdp--;
> > +	bdp->cbd_sc |= BD_SC_WRAP;
> > +
> >  	fec_restart(dev, 0);
> 
> I do not really understand why this patch is needed. You move 
> the buffer
> initialisation from fec_restart to fec_enet_init, but fec_restart is
> called directly after the initialisation, so this shouldn't 
> change much.
> 
> I don't need this patch on my boards, so I wonder what is really going
> wrong here.

It is because open also calls fec_restart after the rx buffers are
allocated. With the code in fec_restart, it zeroes out the buffer
descriptors that have just been setup. I can't explain how it would work
for you.

Regards,
Rob

> 
> Sascha
> 
> 
> >  
> >  	/* Queue up command to detect the PHY and initialize the
> > @@ -1730,7 +1759,6 @@ static void
> >  fec_restart(struct net_device *dev, int duplex)
> >  {
> >  	struct fec_enet_private *fep = netdev_priv(dev);
> > -	struct bufdesc *bdp;
> >  	int i;
> >  
> >  	/* Whack a reset.  We should wait for this. */
> > @@ -1768,33 +1796,6 @@ fec_restart(struct net_device *dev, 
> int duplex)
> >  		}
> >  	}
> >  
> > -	/* Initialize the receive buffer descriptors. */
> > -	bdp = fep->rx_bd_base;
> > -	for (i = 0; i < RX_RING_SIZE; i++) {
> > -
> > -		/* Initialize the BD for every fragment in the page. */
> > -		bdp->cbd_sc = BD_ENET_RX_EMPTY;
> > -		bdp++;
> > -	}
> > -
> > -	/* Set the last buffer to wrap */
> > -	bdp--;
> > -	bdp->cbd_sc |= BD_SC_WRAP;
> > -
> > -	/* ...and the same for transmit */
> > -	bdp = fep->tx_bd_base;
> > -	for (i = 0; i < TX_RING_SIZE; i++) {
> > -
> > -		/* Initialize the BD for every fragment in the page. */
> > -		bdp->cbd_sc = 0;
> > -		bdp->cbd_bufaddr = 0;
> > -		bdp++;
> > -	}
> > -
> > -	/* Set the last buffer to wrap */
> > -	bdp--;
> > -	bdp->cbd_sc |= BD_SC_WRAP;
> > -
> >  	/* Enable MII mode */
> >  	if (duplex) {
> >  		/* MII enable / FD enable */
> > -- 
> > 1.6.3.3
> > 
> > 
> 
> -- 
> Pengutronix e.K.                           |                  
>            |
> Industrial Linux Solutions                 | 
> http://www.pengutronix.de/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: 
> +49-5121-206917-0    |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   
> +49-5121-206917-5555 |
> 
> 
