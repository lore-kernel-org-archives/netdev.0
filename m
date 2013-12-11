From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/4] asix: C1 DUB-E100 double rx_urb_size to 4096
Date: Wed, 11 Dec 2013 11:30:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B747E@saturn3.aculab.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com> <1386759028-3534-5-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Dean Jenkins" <Dean_Jenkins@mentor.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55685 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750800Ab3LKLb5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 06:31:57 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23616-01 for <netdev@vger.kernel.org>;
 Wed, 11 Dec 2013 11:31:53 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386759028-3534-5-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Dean Jenkins
> It seems that for the C1 hardware variant of the D-Link DUB-E100
> that the rx_urb_size of 2048 is truncating IP fragmented packets due
> to multiple Ethernet frames being present in a single URB.
> 
> A simple ping test shows a loss of ping responses
> ping 172.17.0.10 -f -c 200 -s 1965
> (172.17.0.1 is the IP address of the target)
> 
> In the worse case, this test requires a 2049 byte data buffer size
> to hold the IN bulk transfer but the URB is 2048 in size so the last byte
> of the Ethernet frame is lost and the Ethernet frame is truncated.
> 
> This modification resolves "asix_rx_fixup() Bad Header" errors caused by
> truncation of the Ethernet frame due to the URB buffer being too small.
> 
> Therefore, increase the rx_urb_size to 4096 to accommodate
> multiple Ethernet frames being present in a single URB.

I don't think this will help - you've only moved the error.
If the hardware manages to feed over 4k of ethernet frame data
into a single usb bulk data frame it will still go wrong.

The rx code needs to keep the partial ethernet frame until the
next usb bulk data urb arrives.
(This only applies if the urb is a multiple of the usb packet size
and isn't known to have been terminated by a zero length block.)

This should work provided the urb size is a multiple of the usb
packet size - I don't know if a 1536 (3*512) skb fits into a 4k page.
If it doesn't you should probably allocate a 5k skb (8k memory).
(I don't believe there is any point allocating a size inbetween?)

USB3 devices (on USB3 ports) need to allocate buffers that are
multiples of 1k so that they can process very long bulk rx usb data.

	David
