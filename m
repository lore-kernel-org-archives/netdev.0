From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] [RFC] introduce cx82310_eth: Conexant CX82310-based ADSL router USB ethernet driver
Date: Sat, 4 Sep 2010 13:57:23 +0200
Message-ID: <201009041357.26215.linux@rainbow-software.org>
References: <201009032317.14954.linux@rainbow-software.org> <4C81735E.3030903@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C81735E.3030903@simon.arlott.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 04 September 2010 00:14:54 Simon Arlott wrote:
> On 03/09/10 22:17, Ondrej Zary wrote:
> > Hello,
> > this patch introduces cx82310_eth driver - driver for USB ethernet port
> > of ADSL routers based on Conexant CX82310 chips. Such routers usually
> > have ethernet port(s) too which are bridged together with the USB
> > ethernet port, allowing the USB-connected machine to communicate to the
> > network (and also internet through the ADSL, of course).
> >
> > This is my first driver, so please check thoroughly. As there's no
> > protocol documentation, it was done with usbsnoop dumps from Windows
> > driver, some parts (the commands) inspired by cxacru driver and also
> > other usbnet drivers. The driver passed my testing - some real work and
> > also pings sized from 0 to 65507 B.
>
> Try http://isic.sourceforge.net/, you can send a flood of junk traffic
> through the device and check what happens. Be careful what else you have
> on the network as they may not handle it well.

Thanks, looks like a good testing tool. Too bad it does not work when compiled 
by hand (maybe that's why it was removed from Debian).
The ping test revealed some RX bugs before so I hope that there are no more.

> > The only problem I found is the ifconfig error counter. When I return 0
> > (or 1 but empty skb) from rx_fixup(), usbnet increases the error counter
> > although it's not an error condition (because packets can cross URB
> > boundaries). Maybe the usbnet should be fixed to allow rx_fixup() to
> > return empty skbs (or some other value, e.g. 2)?
> >
> > The USB ID of my device is 0x0572:0xcb01 which conflicts with some ADSL
> > modems using cxacru driver (they probably use the same chipset but
> > simpler firmware). The modems seem to use bDeviceClass 0 and iProduct
> > "ADSL USB MODEM", my router uses bDeviceClass 255 and iProduct "USB NET
> > CARD". The driver matches only devices with class 255 and checks for the
> > iProduct string during init. The cxacru driver should be modified to
> > ignore these devices.
>
> You can include the cxacru change as part of your patch; I'll test it.

A patch will follow in next e-mail.

> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> >
> > --- /dev/null	2010-09-03 21:17:56.916000000 +0200
> > +++ linux-2.6.35-rc3/drivers/net/usb/cx82310_eth.c	2010-09-03
> > 23:09:16.000000000 +0200 @@ -0,0 +1,350 @@
> > +/*
> > + * Driver for USB ethernet port of Conexant CX82310-based ADSL routers
> > + * Copyright (C) 2010 by Ondrej Zary
> > + * some parts inspired by the cxacru driver
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License as published by
> > + * the Free Software Foundation; either version 2 of the License, or
> > + * (at your option) any later version.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + *
> > + * You should have received a copy of the GNU General Public License
> > + * along with this program; if not, write to the Free Software
> > + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 
> > USA + */
> > +
> > +#include <linux/module.h>
> > +#include <linux/init.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/etherdevice.h>
> > +#include <linux/ethtool.h>
> > +#include <linux/workqueue.h>
> > +#include <linux/mii.h>
> > +#include <linux/usb.h>
> > +#include <linux/usb/usbnet.h>
> > +
> > +enum cx82310_cmd {
> > +	CMD_START		= 0x84,	/* no effect? */
> > +	CMD_STOP		= 0x85,	/* no effect? */
> > +	CMD_GET_STATUS		= 0x90,	/* returns nothing? */
> > +	CMD_GET_MAC_ADDR	= 0x91,	/* read MAC address */
> > +	CMD_GET_LINK_STATUS	= 0x92,	/* not useful, link is always up */
> > +	CMD_ETHERNET_MODE	= 0x99,	/* unknown, needed during init */
> > +};
> > +
> > +enum cx82310_status {
> > +	STATUS_UNDEFINED,
> > +	STATUS_SUCCESS,
> > +	STATUS_ERROR,
> > +	STATUS_UNSUPPORTED,
> > +	STATUS_UNIMPLEMENTED,
> > +	STATUS_PARAMETER_ERROR,
> > +	STATUS_DBG_LOOPBACK,
> > +};
> > +
> > +#define CMD_PACKET_SIZE	64
> > +/* first command after power on can take around 8 seconds */
> > +#define CMD_TIMEOUT	15000
> > +#define CMD_REPLY_RETRY 5
> > +
> > +#define CX82310_MTU	1514
> > +#define CMD_EP		0x01
> > +
> > +/*
> > + * execute control command
> > + *  - optionally send some data (command parameters)
> > + *  - optionally wait for the reply
> > + *  - optionally read some data from the reply
> > + */
> > +static int cx82310_cmd(struct usbnet *dev, enum cx82310_cmd cmd, bool
> > reply, +		       u8 *wdata, int wlen, u8 *rdata, int rlen)
> > +{
> > +	int actual_len, retries, ret;
> > +	struct usb_device *udev = dev->udev;
> > +	u8 *buf = kzalloc(CMD_PACKET_SIZE, GFP_KERNEL);
> > +
> > +	if (!buf)
> > +		return -ENOMEM;
> > +
> > +	/* create command packet */
> > +	buf[0] = cmd;
> > +	if (wdata)
> > +		memcpy(buf + 4, wdata, min_t(int, wlen, CMD_PACKET_SIZE - 4));
> > +
> > +	/* send command packet */
> > +	ret = usb_bulk_msg(udev, usb_sndbulkpipe(udev, CMD_EP), buf,
> > +			   CMD_PACKET_SIZE, &actual_len, CMD_TIMEOUT);
>
> From your previous lsusb output this is an interrupt endpoint, although
> usb_bulk_msg will auto-detect the type.

There's also usb_interrupt_msg() function but it calls usb_bulk_msg() directly 
so it probably does not matter...
Otherwise, I already found out that sending interrupt URBs to bulk endpoints 
is a very bad idea (when programming Nexio support for usbtouchscreen). Alan 
Stern then created a patch that checks for this.

> > +	if (ret < 0) {
> > +		dev_err(&dev->udev->dev, "send command %#x: error %d\n",
> > +			cmd, ret);
> > +		goto end;
> > +	}
> > +
> > +	if (reply) {
> > +		/* wait for reply, retry if it's empty */
> > +		for (retries = 0; retries < CMD_REPLY_RETRY; retries++) {
> > +			ret = usb_bulk_msg(udev, usb_rcvbulkpipe(udev, CMD_EP),
> > +					   buf, CMD_PACKET_SIZE, &actual_len,
> > +					   CMD_TIMEOUT);
> > +			if (ret < 0) {
> > +				dev_err(&dev->udev->dev,
> > +					"reply receive error %d\n", ret);
> > +				goto end;
> > +			}
> > +			if (actual_len > 0)
> > +				break;
> > +		}
> > +		if (actual_len == 0) {
> > +			dev_err(&dev->udev->dev, "no reply to command %#x\n",
> > +				cmd);
> > +			ret = -EIO;
> > +			goto end;
> > +		}
> > +		if (buf[0] != cmd) {
> > +			dev_err(&dev->udev->dev,
> > +				"got reply to command %#x, expected: %#x\n",
> > +				buf[0], cmd);
> > +			ret = -EIO;
> > +			goto end;
> > +		}
> > +		if (buf[1] != STATUS_SUCCESS) {
> > +			dev_err(&dev->udev->dev, "command %#x failed: %#x\n",
> > +				cmd, buf[1]);
> > +			ret = -EIO;
> > +			goto end;
> > +		}
> > +		if (rdata)
> > +			memcpy(rdata, buf + 4,
> > +			       min_t(int, rlen, CMD_PACKET_SIZE - 4));
> > +	}
> > +end:
> > +	kfree(buf);
> > +	return ret;
> > +}
> >
> > +#define rx_incomplete	(dev->data[0])
> > +#define rx_remainder	(dev->data[1])
> > +#define incomplete_data	(dev->data[2])
>
> This doesn't make the rest of the code particularly readable.

I agree. Maybe I should abuse data[0] as a pointer to private data...
This data[] array does not seem like a good thing. Various usbnet drivers 
abuse it in various ways. It should probably be removed and replaced by one 
priv pointer.

> > +static int cx82310_bind(struct usbnet *dev, struct usb_interface *intf)
> > +{
> > +	int ret;
> > +	char buf[15];
> > +	struct usb_device *udev = dev->udev;
> > +
> > +	/* avoid ADSL modems - continue only if iProduct is "USB NET CARD" */
> > +	if (udev->descriptor.iProduct &&
> > +	    usb_string(udev, udev->descriptor.iProduct, buf, sizeof(buf)) &&
>
> I'm not sure I like the assignment within the if condition here, although
> other drivers do it; ret is available to check the result.

Originally, it started as nested if blocks but it was looking too complex for 
such a simple thing (comparing two strings). So I changed it to this single 
if condition.

> > +	    strcmp(buf, "USB NET CARD")) {
> > +		dev_err(&udev->dev,
> > +			"probably an ADSL modem, use cxacru driver instead\n");
> > +		return -ENODEV;
> > +	}
> > +
> > +	ret = usbnet_get_endpoints(dev, intf);
> > +	if (ret)
> > +		return ret;
> > +
> > +	/*
> > +	 * this must not include ethernet header as the device can send partial
> > +	 * packets with no header (URB is at least 2 bytes long, so 2 is OK)
> > +	 */
> > +	dev->net->hard_header_len = 2;
> > +	/* we can send at most 1514 bytes of data (+ 2-byte header) per URB */
> > +	dev->hard_mtu = CX82310_MTU + dev->net->hard_header_len;
>
> Have you tried sending larger packets?
> With another 8 bytes it would support 802.1Q (VLAN).

Larger packets seem to be dropped. No surprise as the router firmware does not 
support VLANs either.

> > +	/* we can receive URBs up to 4KB from the device */
> > +	dev->rx_urb_size = 4096;
> > +
> > +	incomplete_data = (unsigned long) kmalloc(dev->hard_mtu, GFP_KERNEL);
> > +	if (!incomplete_data)
> > +		return -ENOMEM;
> > +
> > +	/* enable ethernet mode (?) */
> > +	ret = cx82310_cmd(dev, CMD_ETHERNET_MODE, true, "\x01", 1, NULL, 0);
> > +	if (ret) {
> > +		dev_err(&udev->dev, "unable to enable ethernet mode\n");
>
> I'd include the return value in the message, it can be useful to know if
> it was a timeout response or not.

Thanks, looks like a good idea.

-- 
Ondrej Zary
