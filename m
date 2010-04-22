From: Dan Williams <dcbw@redhat.com>
Subject: Re: Subject: re-submit4 [ANNOUNCEMENT] NET: usb: sierra_net.c
 driver
Date: Thu, 22 Apr 2010 14:15:06 -0700
Message-ID: <1271970906.26097.72.camel@localhost.localdomain>
References: <1271963973.10035.6.camel@Linuxdev4-laptop>
	 <20100422194435.GA14544@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	dbrownell@users.sourceforge.net, davem@davemloft.net,
	rfiler@sierrawireless.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758815Ab0DVVPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 17:15:17 -0400
In-Reply-To: <20100422194435.GA14544@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-22 at 12:44 -0700, Greg KH wrote:
> On Thu, Apr 22, 2010 at 12:19:33PM -0700, Elina Pasheva wrote:
> > +static void sierra_net_send_cmd(struct usbnet *dev,
> > +		u8 *cmd, int cmdlen, const char * cmd_name)
> > +{
> > +	struct sierra_net_data *priv = sierra_net_get_private(dev);
> > +	int  status;
> > +
> > +	status = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
> > +			USB_CDC_SEND_ENCAPSULATED_COMMAND,
> > +			USB_DIR_OUT|USB_TYPE_CLASS|USB_RECIP_INTERFACE,	0,
> > +			priv->ifnum, cmd, cmdlen, 0);
> 
> No timeout?
> 
> > +		ifnum = priv->ifnum;
> > +		len = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > +				USB_CDC_GET_ENCAPSULATED_RESPONSE,
> > +				USB_DIR_IN|USB_TYPE_CLASS|USB_RECIP_INTERFACE,
> > +				0, ifnum, buf, SIERRA_NET_USBCTL_BUF_LEN, 0);
> 
> No timeout?
> 
> > +		if (unlikely(len < 0)) {
> > +			netdev_err(dev->net,
> > +				"usb_control_msg failed, status %d\n", len);
> 
> You don't need "unlikely", this is an extreemly slow path here.
> Also, what happens for a "short read"?  You don't handle that properly.

Is the code doc for usb_unlink_urb() in urb.c the best thing to look at
for how to handle short reads?  I assume that involves checking if the
returned error is -EREMOTEIO and if so, ignoring it?  I spent about an
hour googling and poking around in the kernel sources and couldn't find
much about how to handle short reads.  The only non-host-side driver
that cares about EREMOTEIO is misc/rio500.c, the rest is all under host/
or gadget/.

In the 3 places that this driver calls usb_control_msg(), the codepaths
don't need any special -EREMOTEIO handling.

Dan

