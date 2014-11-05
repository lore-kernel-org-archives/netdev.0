From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH V2 2/4] can: m_can: workaround for transmit data less
 than 4 bytes
Date: Wed, 5 Nov 2014 18:33:53 +0800
Message-ID: <20141105103349.GA4007@shlinux1.ap.freescale.net>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
 <1415174326-6623-2-git-send-email-b29396@freescale.com>
 <5459F94C.1030506@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5459F94C.1030506@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 05, 2014 at 11:17:48AM +0100, Marc Kleine-Budde wrote:
> On 11/05/2014 08:58 AM, Dong Aisheng wrote:
> > At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with
> 
> Can you add the imx mask revision, too and the exact m_can version (is
> available).
> 

What do you mean imx mask revision?

By reading the Core Release Register (CREL), it seems the exact m_can
version is 3.0.1. (CREL = 30130506).

So what about changing to as follows?
"At least on the i.MX6SX with M_CAN IP version 3.0.1 (CREL = 30130506),
an issue with"

Regards
Dong Aisheng

> > the Message RAM was discovered. Sending CAN frames with dlc less
> > than 4 bytes will lead to bit errors, when the first 8 bytes of
> > the Message RAM have not been initialized (i.e. written to).
> > To work around this issue, the first 8 bytes are initialized in open()
> > function.
> > 
> > Without the workaround, we can easily see the following errors:
> > root@imx6qdlsolo:~# ip link set can0 up type can bitrate 1000000
> > [   66.882520] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
> > root@imx6qdlsolo:~# cansend can0 123#112233
> > [   66.935640] m_can 20e8000.can can0: Bit Error Uncorrected
> > 
> > Signed-off-by: Dong Aisheng <b29396@freescale.com>
> > ---
> > ChangeLog since v1:
> >  * initialize the first 8 bytes of Tx Buffer of Message RAM in open()
> >    to workaround the issue
> > ---
> >  drivers/net/can/m_can/m_can.c | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> > index 664fe30..f47c200 100644
> > --- a/drivers/net/can/m_can/m_can.c
> > +++ b/drivers/net/can/m_can/m_can.c
> > @@ -902,6 +902,15 @@ static void m_can_chip_config(struct net_device *dev)
> >  	/* set bittiming params */
> >  	m_can_set_bittiming(dev);
> >  
> > +	/* At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with
> > +	 * the Message RAM was discovered. Sending CAN frames with dlc less
> > +	 * than 4 bytes will lead to bit errors, when the first 8 bytes of
> > +	 * the Message RAM have not been initialized (i.e. written to).
> > +	 * To work around this issue, the first 8 bytes are initialized here.
> > +	 */
> > +	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
> > +	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
> > +
> >  	m_can_config_endisable(priv, false);
> >  }
> >  
> > 
> 
> Marc
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 


