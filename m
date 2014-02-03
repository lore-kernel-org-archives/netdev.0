From: David Laight <David.Laight@ACULAB.COM>
Subject: usb interrupt storms from the ax88179 hardware
Date: Mon, 3 Feb 2014 17:17:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B7B42@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Freddy Xin <freddy@asix.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51622 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751134AbaBCRSF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 12:18:05 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28101-04 for <netdev@vger.kernel.org>;
 Mon,  3 Feb 2014 17:18:00 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On one system (an amd motherboard with the ASMedia xhci controller)
I'm seeing almost back to back USB (7 or 8 a second) 'interrupt'
packets from an ax88179 Ge card.
It may be that other systems behave similarly.
I'm sure this hadn't used to happen!

I don't know what the interrupt status means, the value (as LE u32)
is 0x900a1 0xe1cd6d79
The only bit the driver looks at is the 0x10000 bit in the first word.
This is the 'link up/down' flag.
The two halves of the second word are probably different fields, the
high bits appear after about a second.

Now I'd guess that the driver ought to be doing something about some
of these values. While in this mode transmits are delayed for anything
upto 100ms, at least for some time they do get sent.

However the processing of the 'link up/down' flag is clearly wrong.
The code currently does:

348         event = urb->transfer_buffer;
349         le32_to_cpus((void *)&event->intdata1);
350 
351         link = (((__force u32)event->intdata1) & AX_INT_PPLS_LINK) >> 16;
352 
353         if (netif_carrier_ok(dev->net) != link) {
354                 usbnet_link_change(dev, link, 1);
355                 netdev_info(dev->net, "ax88179 - Link status is: %d\n", link);
356         }

Which ends up doing repeated calls to usbnet_link_change() and confusing
that code a lot.

I presume there is some delay before the return value from netif_carrier_ok()
matches the set state.

I think the code should be remembering the link state locally.
It might also need to clear some other interrupt flags, only ASIX know
what they mean.

	David
