From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 1/1] usb: Tell xhci when usb data might be	misaligned
Date: Fri, 31 Jan 2014 09:30:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B5567@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6B5486@AcuExch.aculab.com>
 <20140130161721.25560.qmail@stuge.se>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B553D@AcuExch.aculab.com>
 <20140130163508.27016.qmail@stuge.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>
To: 'Peter Stuge' <peter@stuge.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58442 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751006AbaAaJae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 04:30:34 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00339-05 for <netdev@vger.kernel.org>;
 Fri, 31 Jan 2014 09:30:30 +0000 (GMT)
In-Reply-To: <20140130163508.27016.qmail@stuge.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Stuge
> But what about that alignment? It seems that userspace
> needs to start caring about alignment with xhci, right?

No because there is a copy_to/from_user() in the middle.

The ehci/ohci/uhci all require that fragments be a multiple of the
usb message size (512 bytes for USB2).
So everything (until very recently) would always supply suitable
aligned buffers. Mostly they are page aligned.

For those who haven't read the xhci spec carefully:

The xhci controller removes the requirement on dma segments being
aligned to usb messages.
However there are two alignment requirements:
1) dma segments must not cross 64k address boundaries.
   This is documented clearly, even though it is a slight pain.
   You'd have thought the address counter could have more than
   16 bits these days!
   There only 17 bits for the length, but a length restriction
   would be less of a problem.
2) The v1.00 version of the specification adds that the end of
   the transfer ring can only occur at a 'TD fragment' boundary.
   These are aligned with the payload 'bursts' - which can be
   sixteen 1k packets.
I think that breaking the second of these causes a usb message
be split into two small pieces - which will terminate bulk xfers.
The asix USB3 Ge silicon gets very confused when this happens.

	David
