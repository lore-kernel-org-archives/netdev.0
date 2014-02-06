From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: asix: fix bad header length bug
Date: Thu, 6 Feb 2014 13:37:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B98CA@AcuExch.aculab.com>
References: <1391691384-8486-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Emil Goode' <emilgoode@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391691384-8486-1-git-send-email-emilgoode@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emil Goode
> The AX88772B occasionally send rx packets that cross urb boundaries
> and the remaining partial packet is sent with no header.
> When the buffer with a partial packet is of less number of octets
> than the value of hard_header_len the buffer is discarded by the
> usbnet module. This is causing dropped packages and error messages
> in dmesg.
> 
> This can be reproduced by using ping with a packet size
> between 1965-1976.

I think this can affect other USB ethernet drivers.
Probably most of the ones that explicitly set rx_urb_len.

The ax88179_178a driver sets massive 20k receive urb.
I've seen over 10k of data in a single urb, dunno if it
can actually generate more than 20k - possibly if the usb3 link
is loaded with other traffic.
It would be much more efficient for it to use an aligned 4k urb
and then merge the fragment into skbs.

Once you've set:
+	dev->net->hard_header_len = 0; /* Partial packets have no header */
try setting the mtu to a multiple of 1k.
There is a very odd check in usbnet_change_mtu() that tries to stop the
receive urb_length being a multiple of the usb packet size.

This code looks as though it is hoping that the usb controller will discard
any full length bulk messages after finding a short buffer.
I suspect that might be just wishful thinking!

	David
