From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH 7/7] can: m_can: workaround for transmit data less than
 4 bytes
Date: Wed, 5 Nov 2014 10:03:25 +0800
Message-ID: <20141105020322.GA18982@shlinux1.ap.freescale.net>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
 <1414579527-31100-7-git-send-email-b29396@freescale.com>
 <5457B1D1.6080301@pengutronix.de>
 <20141104082505.GA8060@shlinux1.ap.freescale.net>
 <54589AC8.4010106@pengutronix.de>
 <20141104092651.GC8060@shlinux1.ap.freescale.net>
 <5458AB65.7000500@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5458AB65.7000500@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2014 at 11:33:09AM +0100, Marc Kleine-Budde wrote:
> On 11/04/2014 10:27 AM, Dong Aisheng wrote:
> >>>> It should be possible to change the for loop to go always to 8, or
> >>>> simply unroll the loop:
> >>>>
> >>>> /* errata description goes here */
> >>>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));
> >>>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));
> >>>>
> >>>
> >>> Yes, i tried to fix it as follows.
> >>>
> >>> /* FIXME: we meet an IC issue that we have to write the full 8
> >>>  * bytes (whatever value for the second word) in Message RAM to
> >>>  * avoid bit error for transmit data less than 4 bytes
> >>>  */
> >>> if (cf->len <= 4) {
> >>>         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0),
> >>>                          *(u32 *)(cf->data + 0));
> >>>         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1),
> >>>                          *(u32 *)(cf->data + 4));
> >>> } else {
> >>>         for (i = 0; i < cf->len; i += 4)
> >>>                 m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
> >>>                                  *(u32 *)(cf->data + i));
> >>>
> >>> Will update the patch.
> >>
> >> Both branches of the above if are doing the same thing, I think you can
> >> replace the while if ... else ... for with this:
> >>
> > 
> > Not the same thing.
> > The later one will cover payload up to 64 bytes.
> 
> Doh! I'm not used to CAN-FD, yet :) However, I'll apply this fix before
> adding the CAN-FD support.
> 
> >> /* errata description goes here */
> >> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));
> >> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));
> >>
> >> However if writing to DATA(0) and DATA(1) once in the open() function is
> >> enough this code should stay as it is.
> > 
> > I tried put them into open() function and the quick test showed it worked.
> > 
> > Do you think it's ok to put things into open() function for this issue
> > as follows?
> > 
> > diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> > index 065e4f1..ca55988 100644
> > --- a/drivers/net/can/m_can/m_can.c
> > +++ b/drivers/net/can/m_can/m_can.c
> > @@ -901,6 +901,15 @@ static void m_can_chip_config(struct net_device *dev)
> >         /* set bittiming params */
> >         m_can_set_bittiming(dev);
> > 
> > +       /* We meet an IC issue that we have to write the full 8
> 
> At least on the *insert SoC name here*, an issue with the Message RAM
> was discovered. Sending CAN frames with dlc less than 4 bytes will lead
> to bit errors, when the first 8 bytes of the Message RAM have not been
> initialized (i.e. written to). To work around this issue, the first 8
> bytes are initialized here.
> 

Looks good.
Will do like that.

> > +        * bytes (whatever value for the second word) in Message RAM to
> > +        * avoid bit error for transmit data less than 4 bytes at the first
> > +        * time. By initializing the first 8 bytes of tx buffer before using
> > +        * it can avoid such issue.
> > +        */
> > +       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
> > +       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
> > +
> >         m_can_config_endisable(priv, false);
> >  }
> 
> Can you trigger the issue when sending CAN-FD frames with dlc > 8 && dlc
> < 64?
> 

No, i did not see the issue with dlc > 8 && dlc < 64.

Regards
Dong Aisheng
> Marc
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 


