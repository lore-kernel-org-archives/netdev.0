From: Markus Pargmann <mpa@pengutronix.de>
Subject: Re: [PATCH] can: c_can: Speed up rx_poll function
Date: Mon, 28 Oct 2013 19:28:18 +0100
Message-ID: <20131028182818.GB20839@pengutronix.de>
References: <1382979582-10352-1-git-send-email-mpa@pengutronix.de>
 <1382980336.30941.40.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: Joe Perches <joe@perches.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382980336.30941.40.camel@joe-AO722>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 28, 2013 at 10:12:16AM -0700, Joe Perches wrote:
> On Mon, 2013-10-28 at 17:59 +0100, Markus Pargmann wrote:
> > This patch speeds up the rx_poll function by reducing the number of
> > register reads.
> 
> trivial notes:
> 
> > diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
> []
> > @@ -259,6 +259,12 @@ static u32 c_can_read_reg32(struct c_can_priv *priv, enum reg index)
> > +u16 c_can_read_reg16(struct c_can_priv *priv, enum reg index)
> > +{
> > +	u16 val = priv->read_reg(priv, index);
> > +	return val;
> > +}
> 
> This function doesn't seem useful at all.
> It's not exported and it's not static.

Oh right, should be static.

> 
> Why not use an in-place priv->read_reg(priv, index)?

No reason for that. Especially with a u16 as mentioned below, it is
clear enough that we have a 16bit value, so I will change it.

> 
> > +
> >  static void c_can_enable_all_interrupts(struct c_can_priv *priv,
> >  						int enable)
> >  {
> > @@ -798,17 +804,21 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
> >  	u32 num_rx_pkts = 0;
> >  	unsigned int msg_obj, msg_ctrl_save;
> >  	struct c_can_priv *priv = netdev_priv(dev);
> > -	u32 val = c_can_read_reg32(priv, C_CAN_INTPND1_REG);
> > +	unsigned long val = c_can_read_reg16(priv, C_CAN_INTPND1_REG);
> 
> Probably better as a u16 as detailed below.
> 
> > +	/*
> > +	 * It is faster to read only one 16bit register. This is only possible
> > +	 * for a maximum number of 16 objects.
> > +	 */
> > +	BUILD_BUG_ON_MSG(C_CAN_MSG_OBJ_RX_LAST > 16,
> > +			"Implementation does not support more message objects than 16");
> > +
> > +	while (quota > 0 && (val = c_can_read_reg16(priv, C_CAN_INTPND1_REG))) {
> > +		msg_obj = 0;
> > +		while ((msg_obj = find_next_bit(&val, 16, msg_obj)) < 16 &&
> 
> Using ffs instead of find_next_bit would be more standard
> and probably faster too.

I wasn't aware of that. I will change it

Thanks,

Markus Pargmann

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
