From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH 7/7] can: m_can: workaround for transmit data less than
 4 bytes
Date: Tue, 4 Nov 2014 17:27:14 +0800
Message-ID: <20141104092651.GC8060@shlinux1.ap.freescale.net>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
 <1414579527-31100-7-git-send-email-b29396@freescale.com>
 <5457B1D1.6080301@pengutronix.de>
 <20141104082505.GA8060@shlinux1.ap.freescale.net>
 <54589AC8.4010106@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54589AC8.4010106@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 04, 2014 at 10:22:16AM +0100, Marc Kleine-Budde wrote:
> On 11/04/2014 09:25 AM, Dong Aisheng wrote:
> >>> We meet an IC issue that we have to write the full 8 bytes (whatever
> >>> value for the second word) in Message RAM to avoid bit error for transmit
> >>> data less than 4 bytes.
> >>
> >> Is this a SoC or a m_can problem? Are all versions of the SoC/m_can
> >> affected? Is there a m_can version register somewhere?
> 
> > I'm still not sure it's SoC or m_can problem.
> > Our IC guys ran the simulation code and found this issue.
> > But due to some reasons, it may be very slow for they to investigate
> > and get the conclusion.
> 
> Let's hope they will find the root cause of this problem.
> 
> >>> Without the workaround, we can easily see the following errors:
> >>> root@imx6qdlsolo:~# ip link set can0 up type can bitrate 1000000
> >>> [   66.882520] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
> >>> root@imx6qdlsolo:~# cansend can0 123#112233
> >>> [   66.935640] m_can 20e8000.can can0: Bit Error Uncorrected
> >>>
> >>> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> >>> ---
> >>>  drivers/net/can/m_can/m_can.c | 11 ++++++++++-
> >>>  1 file changed, 10 insertions(+), 1 deletion(-)
> >>>
> >>> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> >>> index 219e0e3..f2d9ebe 100644
> >>> --- a/drivers/net/can/m_can/m_can.c
> >>> +++ b/drivers/net/can/m_can/m_can.c
> >>> @@ -1058,10 +1058,19 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
> >>>  	m_can_fifo_write(priv, 0, M_CAN_FIFO_ID, id);
> >>>  	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, can_len2dlc(cf->len) << 16);
> >>>  
> >>> -	for (i = 0; i < cf->len; i += 4)
> >>> +	for (i = 0; i < cf->len; i += 4) {
> >>>  		m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
> >>>  				 *(u32 *)(cf->data + i));
> >>>  
> >>> +		/* FIXME: we meet an IC issue that we have to write the full 8
> >>
> >> FIXME usually indicates that the driver needs some work here. Just
> >> describe your hardware bug, you might add a reference to an errata if
> >> available, though.
> >
> > We don't have an errata for it now.
> > Because i'm not sure this is the final workaround and also not sure if other
> > SoC vendors having the same issue, so i used FIXME here firstly.
> > Since the code is harmless, so i wish we could put it here first
> > until we find evidence no need for other SoC or only belong to specific
> > IP version.
> 
> It's better to write this in the comment than a FIXME, which is much
> harder to interpret....
> 
> >>> +		 * bytes (whatever value for the second word) in Message RAM to
> >>> +		 * avoid bit error for transmit data less than 4 bytes
> >>> +		 */
> >>> +		if (cf->len <= 4)
> >>> +			m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4 + 1),
> >>> +					 0x0);
> >>
> >> This workaround doesn't handle the dlc == 0 case, your error description
> >> isn't completely if this is a problem, too.
> 
> > You're right.
> > I just checked the dlc == 0 case also had such issue and it also needs
> > the extra 8 bytes write to avoid such issue.
> > 
> > BTW the issue only happened on the first time when you send a frame with no
> > data(dlc == 0) at the first time.
> > e.g.
> > root@imx6sxsabresd:~# ip link set can0 up type can bitrate 1000000
> > [   62.326014] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
> > root@imx6sxsabresd:~# cansend can0 123#R
> > [   69.233645] m_can 20e8000.can can0: Bit Error Uncorrected
> > [   69.239167] m_can 20e8000.can can0: Bit Error Corrected
> > 
> > If we send a frame success first (e.g. 5 bytes data), it will not fail
> > again even you send no data frame (dlc == 0) later.
> > 
> > The former failure of sending data less than 4 bytes is similar.
> > 
> > Looks like the first 8 bytes of message ram has to be initialised
> > for the first using.
> 
> What about putting
> 
> /* errata description goes here */
> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
> 
> into the open() function? Can you ask the hardware colleges if this is a
> functional workaround.
> 
> >> It should be possible to change the for loop to go always to 8, or
> >> simply unroll the loop:
> >>
> >> /* errata description goes here */
> >> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));
> >> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));
> >>
> > 
> > Yes, i tried to fix it as follows.
> > 
> > /* FIXME: we meet an IC issue that we have to write the full 8
> >  * bytes (whatever value for the second word) in Message RAM to
> >  * avoid bit error for transmit data less than 4 bytes
> >  */
> > if (cf->len <= 4) {
> >         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0),
> >                          *(u32 *)(cf->data + 0));
> >         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1),
> >                          *(u32 *)(cf->data + 4));
> > } else {
> >         for (i = 0; i < cf->len; i += 4)
> >                 m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
> >                                  *(u32 *)(cf->data + i));
> > 
> > Will update the patch.
> 
> Both branches of the above if are doing the same thing, I think you can
> replace the while if ... else ... for with this:
> 

Not the same thing.
The later one will cover payload up to 64 bytes.

> /* errata description goes here */
> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));
> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));
> 
> However if writing to DATA(0) and DATA(1) once in the open() function is
> enough this code should stay as it is.

I tried put them into open() function and the quick test showed it worked.

Do you think it's ok to put things into open() function for this issue
as follows?

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 065e4f1..ca55988 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -901,6 +901,15 @@ static void m_can_chip_config(struct net_device *dev)
        /* set bittiming params */
        m_can_set_bittiming(dev);

+       /* We meet an IC issue that we have to write the full 8
+        * bytes (whatever value for the second word) in Message RAM to
+        * avoid bit error for transmit data less than 4 bytes at the first
+        * time. By initializing the first 8 bytes of tx buffer before using
+        * it can avoid such issue.
+        */
+       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
+       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
+
        m_can_config_endisable(priv, false);
 }

Regards
Dong Aisheng

> 
> Marc
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 


