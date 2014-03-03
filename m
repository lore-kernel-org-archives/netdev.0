From: David Laight <David.Laight@ACULAB.COM>
Subject: ax88179_178a problems on AMD platform with ASMedia xhci controller
Date: Mon, 3 Mar 2014 17:08:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CF469@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40598 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752636AbaCCRI3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 12:08:29 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04633-03 for <netdev@vger.kernel.org>;
 Mon,  3 Mar 2014 17:08:25 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just installed the latest 3.14.0-rc5 kernel on an AMD box that
has the ASMedia 1042 xhci controller and an ASX ax88179 USB3 Ge card.

This is still working as badly as it did last time I tried it.
(When I added a lot of diagnostics to try to find out what was wrong.)

When I ran 'ifconfig eth1 192.168.x.x' the kernel message buffer
is spammed with messages from the generic ethernet code reporting:
    "kevent 4 may have been missed".
This is because ax88179_status(...) contains:
	if (netif_carrier_ok() != link) {
		usbnet_link_change(...);
		...
but the corresponding netif_carrier_on() doesn't happen until
much later (possibly for the same reason that transmits are delayed).
I think the hardware reports its status every 128ms.

If I ping the interface (from the only other system on that ethernet
network), the ping times vary, but are typically larger than 20ms and
anything upto 200ms (some outward ones are faster).
I did add some diagnostics a while ago (rc2 ish) and thought the delays
were in the transmit path.

dmesg also gets spammed with "ERROR Transfer event TRB DMA ptr not part of
current TD". I don't remember looking at why (for this case).

I've just looked t the ping timings closely. The elapsed times (ms) are:
7, 30, 53, 76, 99, 122, 18, 41, 64, 87, 110, 5, 28 ...
So each response is about 22ms later than the previous on - until the delay
would exceed 128ms, when 128ms is removed.
So something is only looking at something every 128ms.

This might be related to the status indications every 128ms, but I
thought I'd determined that the delay was between the tx setup and
end of tx interrupt.

I don't have a USB3 monitor, and the USB2 one I have has an unusable
graphical interface.

In any case this all makes this combination completely unusable.

I was planning on doing some tests for link TRBs - but it doesn't
work well enough to even attempt those.

	David
