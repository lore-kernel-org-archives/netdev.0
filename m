From: "David Laight" <David.Laight@ACULAB.COM>
Subject: Disabling TCP slow start after idle
Date: Mon, 14 Nov 2011 10:16:19 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEBF@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50974 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753541Ab1KNKSG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 05:18:06 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15450-06 for <netdev@vger.kernel.org>;
 Mon, 14 Nov 2011 10:18:00 +0000 (GMT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(oOriginally sent to linux-kernel@, but suggested I report here.)

We have some connections that suffer very badly from the TCP
'slow start' algorithm. These are connections that will
always be local - they may be MAC-Switch-MAC using RGMII
crossover, they might also be connected via an external
switch. In either case the RTT is most likely to be almost
zero, certainly below 1ms.

The traffic is single packets (carrying another protocol)
so we have Nagle disabled and the send and receive sides
run separately. So the traffic is neither bulk, nor
command/response.

This means that there is very rarely any unacked data,
so almost every packet is sent using 'slow start'.

If the external switch drops a packet (they do!) then
slow start stops more packets being sent, and nothing
progresses for about 1.5 seconds by which time there
is a significant amount of traffic queued and, in some
cases, data has to be discarded.

Similar issues happen if the receiving system decides
to defer the ack until a timer tick (instead of
sending one after every second packet). In this case
only 4 packets are sent. (We fixed this one be sending
a software ACK every 4 packets.)

Quite cleary the 'slow start' algorithm just doesn't
work in these cases.

I found this https://lkml.org/lkml/2010/4/9/427
discussion about a socket option to disable slow start.
But it seems that some people are completely against the idea.
I'd have thought that the global option would be more of a
problem - since that will affect ftp connections to remote
hosts where slow start is alomost certainly benefitial.

I'd have thought it would be sensible to allow one (or more)
of the following (either as a sysctl, socket option, or
code change):
1) Disable slow start for the local subnet.
2) Disable slow start for connections with very low RTT.
3) Disable slow start for a minimum period with no traffic
   (after the last packet is acked).

I'm not sure of the resolution used by the Linux RTT
calculations. I know NetBSD had a recent set of patches
to fix calculation errors with low RTT because the code
had been written when all RTT were much longer.

	David
