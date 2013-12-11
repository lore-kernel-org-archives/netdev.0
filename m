From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/4] asix: C1 DUB-E100 double rx_urb_size to 4096
Date: Wed, 11 Dec 2013 12:45:10 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B747F@saturn3.aculab.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com> <1386759028-3534-5-git-send-email-Dean_Jenkins@mentor.com> <AE90C24D6B3A694183C094C60CF0A2F6026B747E@saturn3.aculab.com> <52A85A7A.7010902@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Dean Jenkins" <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56935 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751867Ab3LKMqP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 07:46:15 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05241-04 for <netdev@vger.kernel.org>;
 Wed, 11 Dec 2013 12:46:09 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52A85A7A.7010902@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Dean Jenkins 
> On 11/12/13 12:30, David Laight wrote:
> >> From: Dean Jenkins
> >> It seems that for the C1 hardware variant of the D-Link DUB-E100
> >> that the rx_urb_size of 2048 is truncating IP fragmented packets due
> >> to multiple Ethernet frames being present in a single URB.
> >>
> >> A simple ping test shows a loss of ping responses
> >> ping 172.17.0.10 -f -c 200 -s 1965
> >> (172.17.0.1 is the IP address of the target)
> >>
> >> In the worse case, this test requires a 2049 byte data buffer size
> >> to hold the IN bulk transfer but the URB is 2048 in size so the last byte
> >> of the Ethernet frame is lost and the Ethernet frame is truncated.
> >>
> >> This modification resolves "asix_rx_fixup() Bad Header" errors caused by
> >> truncation of the Ethernet frame due to the URB buffer being too small.
> >>
> >> Therefore, increase the rx_urb_size to 4096 to accommodate
> >> multiple Ethernet frames being present in a single URB.
> > I don't think this will help - you've only moved the error.
> > If the hardware manages to feed over 4k of ethernet frame data
> > into a single usb bulk data frame it will still go wrong.

> I agree in principle, however, I have not seen any evidence of the 4K
> buffer being exceeded. I did a ping test of ping payloads from 0 to 5K
> bytes with no errors. Without the patch, the test fails at ping payloads
> of 1965 (and higher). The test causes IP fragmentation.

What happens if you force the USB speed below 480MHz?

> The patch certainly helps to avoid failures but perhaps there is a
> better solution ?
> 
> I checked with a USB protocol analyser that the C1 DUB-E100 sent a IN
> bulk transfer containing 2049 octets despite the RX URB size being 2048
> bytes long. Therefore, the last octet is lost. The current code fails
> because it waits for the next socket buffer which does not contain the
> missing byte, that octet had already been sent over the wire.
> 
> Could this be a symptom of a bug in USB bulk transfer handling ?

Looks like one.

My understanding (from trying to fix the xhci driver) is that a bulk
transfer is chopped into 512 byte chunks (for USB2). Transfers can
either be known fixed multiple of 512, or be terminated be a short block.
The hardware doesn't know which, but should advance to the next buffer
of a short block.
So the 2049 byte bulk transfer is four 512byte blocks and a 1 byte block.
If the receive URB are 512 bytes each, this should end up in 5 URB (etc).

Maybe the usb driver is 'cleverly' discarding the continuation blocks
when the rx urb are marked that short transfers are valid.

	David
