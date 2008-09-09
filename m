From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 1/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Tue, 9 Sep 2008 14:56:19 +0100
Message-ID: <OF87B42A84.257AB13C-ON802574BF.004BC77A-802574BF.004C9105@smsc.com>
References: <1220966387.2381.42.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	ian.saturley@smsc.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:1739 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751617AbYIIN4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 09:56:49 -0400
In-Reply-To: <1220966387.2381.42.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Thanks for your feedback, many really good points there.

> > +static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 
*data)
> > +{
> > +   u32 *buf = kmalloc(4, GFP_KERNEL);
> > +   int ret;
> > +
> > +   BUG_ON(!dev);
> > +
> > +   if (!buf)
> > +      return -ENOMEM;
> > +
> > +   ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > +      USB_VENDOR_REQUEST_READ_REGISTER,
> > +      USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
> > +      00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
> > +
> > +   if (unlikely(ret < 0))
> > +      SMSC_WARNING("Failed to read register index 0x%08x", index);
> > +
> > +   le32_to_cpus(buf);
> > +   *data = *buf;
> > +   kfree(buf);
> > +
> > +   return ret;
> > +}
> 
> Why are you allocating a buffer on the heap?  What's wrong with
> 
> static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
> {
>    int ret;
> 
>    BUG_ON(!dev);
> 
>    ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
>       USB_VENDOR_REQUEST_READ_REGISTER,
>       USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
>       00, index, data, 4, USB_CTRL_GET_TIMEOUT);
> 
>    if (unlikely(ret < 0))
>       SMSC_WARNING("Failed to read register index 0x%08x", index);
> 
>    le32_to_cpus(data);
> 
>    return ret;
> }
> 
> ?

For the same reason dm9601.c and asix.c do - we're not allowed to do
usb transfers of data on stack.  It works on some architectures, but
breaks badly on others.

Peter Korsgaard fixed dm9601 for it here:

http://kerneltrap.org/mailarchive/linux-netdev/2008/7/14/2452854

As with dm9601, this is only used for config registers - nothing in
the fast path.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com
