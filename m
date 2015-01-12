From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 3/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Mon, 12 Jan 2015 07:07:41 -0500
Message-ID: <20150112120741.GC9213@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150111200544.GA8855@linux>
 <20150111201116.GB8855@linux>
 <20150111201519.GC8855@linux>
 <20150111203612.GA8999@linux>
 <54B3B37C.7090002@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B3B37C.7090002@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Mon, Jan 12, 2015 at 12:43:56PM +0100, Marc Kleine-Budde wrote:
> On 01/11/2015 09:36 PM, Ahmed S. Darwish wrote:
[...]
> > diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> > index 0eb870b..da47d17 100644
> > --- a/drivers/net/can/usb/kvaser_usb.c
> > +++ b/drivers/net/can/usb/kvaser_usb.c
> > @@ -6,10 +6,12 @@
> >   * Parts of this driver are based on the following:
> >   *  - Kvaser linux leaf driver (version 4.78)
> >   *  - CAN driver for esd CAN-USB/2
> > + *  - Kvaser linux usbcanII driver (version 5.3)
> >   *
> >   * Copyright (C) 2002-2006 KVASER AB, Sweden. All rights reserved.
> >   * Copyright (C) 2010 Matthias Fuchs <matthias.fuchs@esd.eu>, esd gmbh
> >   * Copyright (C) 2012 Olivier Sobrie <olivier@sobrie.be>
> > + * Copyright (C) 2015 Valeo Corporation
> >   */
> >  
> >  #include <linux/completion.h>
> > @@ -21,6 +23,15 @@
> >  #include <linux/can/dev.h>
> >  #include <linux/can/error.h>
> >  
> > +/* Kvaser USB CAN dongles are divided into two major families:
> > + * - Leaf: Based on Renesas M32C, running firmware labeled as 'filo'
> > + * - UsbcanII: Based on Renesas M16C, running firmware labeled as 'helios'
> > + */
> > +enum kvaser_usb_family {
> > +	KVASER_LEAF,
> > +	KVASER_USBCAN,
> > +};
> 
> Nitpick: please move after the #defines
> 

Will do.

[...]
> > @@ -616,53 +810,24 @@ static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
> >  }
> >  
> >  static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> > -				const struct kvaser_msg *msg)
> > +				struct kvaser_error_summary *es)
> 
> Can you make "struct kvaser_error_summary *es" const?
> 

Sure.

[...]
> > +/* For USBCAN, report error to userspace iff the channels's errors counter
> > + * has increased, or we're the only channel seeing a bus error state.
> > + */
> > +static void kvaser_usbcan_conditionally_rx_error(const struct kvaser_usb *dev,
> > +						 struct kvaser_error_summary *es)
> 
> const struct kvaser_error_summary *es?
>

Ditto.

[...]
> > +
> > +		/* The USBCAN firmware does not support more than 2 channels.
> 
> Does USBCAN support always 2 channels or are there models with 1
> channels, too. I'd rephrase ..."does support up to 2 channels."
> 

Yup, that will be more accurate.

[...]
> > +
> > +	switch (dev->family) {
> > +	case KVASER_LEAF:
> > +		rx_msg = msg->u.leaf.rx_can.msg;
> > +		break;
> > +	case KVASER_USBCAN:
> > +		rx_msg = msg->u.usbcan.rx_can.msg;
> > +		break;
> > +	default:
> > +		dev_err(dev->udev->dev.parent,
> > +			"Invalid device family (%d)\n", dev->family);
> >  		return;
> 
> should not happen.
> 

Yes, but otherwise I get GCC warnings of 'rx_msg' possibly
being unused. I can add __maybe_unused to rx_msg of course,
but such annotation may hide possible errors in the future.

> > +	switch (dev->family) {
> > +	case KVASER_LEAF:
> > +		msg_tx_can_flags = &msg->u.tx_can.leaf.flags;
> > +		break;
> > +	case KVASER_USBCAN:
> > +		msg_tx_can_flags = &msg->u.tx_can.usbcan.flags;
> > +		break;
> > +	default:
> > +		dev_err(dev->udev->dev.parent,
> > +			"Invalid device family (%d)\n", dev->family);
> > +		goto releasebuf;
> should not happen, please remove

Like the 'rx_msg' case above.

Thanks,
Darwish
