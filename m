From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH] net: asix: fix bad header length bug
Date: Thu, 6 Feb 2014 16:02:26 +0100
Message-ID: <20140206150226.GA5251@lianli>
References: <1391691384-8486-1-git-send-email-emilgoode@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B98CA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:56229 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbaBFPAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 10:00:44 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B98CA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Thank's for the review.

On Thu, Feb 06, 2014 at 01:37:12PM +0000, David Laight wrote:
> From: Emil Goode
> > The AX88772B occasionally send rx packets that cross urb boundaries
> > and the remaining partial packet is sent with no header.
> > When the buffer with a partial packet is of less number of octets
> > than the value of hard_header_len the buffer is discarded by the
> > usbnet module. This is causing dropped packages and error messages
> > in dmesg.
> > 
> > This can be reproduced by using ping with a packet size
> > between 1965-1976.
> 
> I think this can affect other USB ethernet drivers.
> Probably most of the ones that explicitly set rx_urb_len.
> 
> The ax88179_178a driver sets massive 20k receive urb.

The ax88179_178a has it's own bind function, so I believe it's
not affected by this change.

> I've seen over 10k of data in a single urb, dunno if it
> can actually generate more than 20k - possibly if the usb3 link
> is loaded with other traffic.
> It would be much more efficient for it to use an aligned 4k urb
> and then merge the fragment into skbs.
> 
> Once you've set:
> +	dev->net->hard_header_len = 0; /* Partial packets have no header */
> try setting the mtu to a multiple of 1k.

I tried setting the mtu to 2000 and when using ping with a large enough
packet size to fill the urb to rx_urb_size all packages are dropped.

> There is a very odd check in usbnet_change_mtu() that tries to stop the
> receive urb_length being a multiple of the usb packet size.

This is very odd indeed!

>
> This code looks as though it is hoping that the usb controller will discard
> any full length bulk messages after finding a short buffer.
> I suspect that might be just wishful thinking!
> 
> 	David
> 
> 
> 
