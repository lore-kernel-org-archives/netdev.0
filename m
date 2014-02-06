From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH] net: asix: fix bad header length bug
Date: Thu, 6 Feb 2014 23:41:21 +0100
Message-ID: <20140206224121.GB5251@lianli>
References: <1391691384-8486-1-git-send-email-emilgoode@gmail.com>
 <1391692768.2843.4.camel@X1Carbon.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B99F7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Igor Gnatenko' <i.gnatenko.brain@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:50404 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbaBFWjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:39:15 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B99F7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 06, 2014 at 03:28:13PM +0000, David Laight wrote:
> From: Igor Gnatenko
> > On Thu, 2014-02-06 at 13:56 +0100, Emil Goode wrote:
> > > The AX88772B occasionally send rx packets that cross urb boundaries
> > > and the remaining partial packet is sent with no header.
> > > When the buffer with a partial packet is of less number of octets
> > > than the value of hard_header_len the buffer is discarded by the
> > > usbnet module. This is causing dropped packages and error messages
> > > in dmesg.
> > >
> > > This can be reproduced by using ping with a packet size
> > > between 1965-1976.
> > >
> > > The bug has been reported here:
> > >
> > > https://bugzilla.kernel.org/show_bug.cgi?id=29082
> > >
> > > Signed-off-by: Emil Goode <emilgoode@gmail.com>
> > Reported-and-tested-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
> > > ---
> > >  drivers/net/usb/asix_devices.c |    1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > > diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
> > > index 9765a7d..120bb29 100644
> > > --- a/drivers/net/usb/asix_devices.c
> > > +++ b/drivers/net/usb/asix_devices.c
> > > @@ -455,6 +455,7 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
> > >  	dev->net->ethtool_ops = &ax88772_ethtool_ops;
> > >  	dev->net->needed_headroom = 4; /* cf asix_tx_fixup() */
> > >  	dev->net->needed_tailroom = 4; /* cf asix_tx_fixup() */
> > > +	dev->net->hard_header_len = 0; /* Partial packets have no header */
> 
> That is the wrong place for the fix.
> 
> It should only be done when rx_urb_size is set to a multiple of the usb
> packet size.
> That is only done for some of the supported devices.
> 
> In fact, if the rx_urb_size is a multiple of the usb frame size (or 1k)
> then maybe the usbnet code should assume that the driver is capable
> of processing ethernet frames that cross usb packet boundaries and
> not delete short packets at all - regardless of the hard_header_len.
> 
> 	David
>

I will do some more digging in the code, but the test of skb->len
against hard_header_len is done already in the completion callback
function passed to usb_fill_bulk_urb so it seems that buffers of less
than hard_header_len number of octets will be dropped regardless.

Best regards,

Emil Goode
