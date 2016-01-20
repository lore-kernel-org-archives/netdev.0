From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH V3 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 15:41:53 +0100
Message-ID: <201601201541.53246.marex@denx.de>
References: <569F944A.4090201@pengutronix.de> <1453300419-5716-1-git-send-email-marex@denx.de> <569F9C37.60007@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: "Marc Kleine-Budde" <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54503 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261AbcATOl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 09:41:56 -0500
In-Reply-To: <569F9C37.60007@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 20, 2016 at 03:39:51 PM, Marc Kleine-Budde wrote:
> On 01/20/2016 03:33 PM, Marek Vasut wrote:
> > The patch adds support for IFI CAN/FD controller [1]. This driver
> > currently supports sending and receiving both standard CAN and new
> > CAN/FD frames. Both ISO and BOSCH variant of CAN/FD is supported.
> > 
> > [1] http://www.ifi-pld.de/IP/CANFD/canfd.html
> > 
> > Signed-off-by: Marek Vasut <marex@denx.de>
> > Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> > Cc: Mark Rutland <mark.rutland@arm.com>
> > Cc: Oliver Hartkopp <socketcan@hartkopp.net>
> > Cc: Wolfgang Grandegger <wg@grandegger.com>
> > ---
> > V2: - Move request_irq()/free_irq() into
> > ifi_canfd_open()/ifi_canfd_close()
> > 
> >       just like other drivers do it to prevent crash when reloading
> >       module.
> >     
> >     - Fix Woverflow complains on x86_64 and itanium, exactly the same way
> >     
> >       as in commit dec23dca5a9ca4b9eb2fb66926f567889028b904 .
> > 
> > V3: - Hopefully fix all problems with BIT(31) by adding more u32 casts.
> > 
> >     - Drop struct device from struct ifi_canfd_priv .
> > 
> > NOTE: The driver is surprisingly similar to m_can, but the register
> > 
> >       layout of the IFI core is completely different, so it's clear
> >       that those are two different IP cores.
> > 
> > ---

[...]

Hi,

> > +static irqreturn_t ifi_canfd_isr(int irq, void *dev_id)
> > +{
> > +	struct net_device *ndev = (struct net_device *)dev_id;
> > +	struct ifi_canfd_priv *priv = netdev_priv(ndev);
> > +	struct net_device_stats *stats = &ndev->stats;
> > +	const u32 rx_irq_mask = IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY |
> > +				IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY_PER;
> > +	const u32 tx_irq_mask = IFI_CANFD_INTERRUPT_TXFIFO_EMPTY |
> > +				IFI_CANFD_INTERRUPT_TXFIFO_REMOVE;
> > +	const u32 clr_irq_mask = (u32)(~(IFI_CANFD_INTERRUPT_SET_IRQ |
> > +					 IFI_CANFD_INTERRUPT_ERROR_WARNING));
> 
> I've squashed:
> >> -       const u32 clr_irq_mask = (u32)(~(IFI_CANFD_INTERRUPT_SET_IRQ |
> >> -                                       
> >> IFI_CANFD_INTERRUPT_ERROR_WARNING)); +       const u32 clr_irq_mask =
> >> ~(IFI_CANFD_INTERRUPT_SET_IRQ | +                                 
> >> IFI_CANFD_INTERRUPT_ERROR_WARNING);
> 
> and the driver compiles without warnings.

It doesn't , try with x86_64_defconfig, it will complain with -Woverflow
on gcc 4.9 or newer. That's what the kernel robot complained about in V1
of the patch too.

I'd be happy to be proven wrong though.
