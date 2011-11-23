From: paul bilke <fsmail@conspiracy.net>
Subject: Udp packets received with improper length
Date: Wed, 23 Nov 2011 14:14:04 -0600
Message-ID: <4ECD540C.60108@conspiracy.net>
Reply-To: fsmail@conspiracy.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway07.websitewelcome.com ([69.56.184.21]:45384 "EHLO
	gateway.websitewelcome.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751196Ab1KWUfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 15:35:47 -0500
Received: from phantom.websitewelcome.com (phantom.websitewelcome.com [174.120.148.130])
	by gateway.websitewelcome.com (Postfix) with ESMTP id A8C6E654F5978
	for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 14:14:07 -0600 (CST)
Received: from [71.113.245.211] (port=2160 helo=[10.10.10.160])
	by phantom.websitewelcome.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <fsmail@conspiracy.net>)
	id 1RTJCp-0007j8-7g
	for netdev@vger.kernel.org; Wed, 23 Nov 2011 14:14:07 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We recently updated an embedded powerpc platform from 2.6.32 to 2.6.37.  When deployed in the field devices with the new kernel have started receiving truncated UDP packets from their mates across noisy links.  To test we wrote a simple client and
server.  The client sends 512 byte packets with a sequence number to the server listening on a UDP socket.  On the client box we use netem to corrupt 100% of the packets sent(after transferring some data so arp cache is populated).  The server then
dumps the length received and the serial number from any packets that are received.   Netem sometimes corrupts bits in the source MAC address so these packets arrive with valid UDP checksums and are delivered to the user application.   With the
server running on the 2.6.32 box we send a few million packets to it and only receive packets that are exactly 512 bytes long.  When we do the same on the box running 2.6.37 we receive hundred of short packets, zero length and also 504 byte packets.
When I use TCPdump on the box running 2.6.37 the truncated packets have valid checksums (Source MAC was corrupted by NETEM) and are of proper length (554 byte ethernet frame, 540 Byte IP portion and 520 byte UDP length) but the userland receives 504
or 0 length in recvfrom. To see if this was just a powerpc related issue I repeated the test on x86 virtual machines.  A vm running 2.6.18 (Centos 5) receives only 512 byte packets.  On a vm running 2.6.40 (Fedora 15) I receive 512, 504 and 0 length
packets.
Below is a hex dump of a packet captured on the 2.6.37 box (its identical on the wire as captured by a probe) but is dispatched to the user application which receives it as a 504 byte packet.
This is problematic in our environment since the IP connectivity is typically a high error rate (Satellite or long haul microwave link).
I did not know if there is a known behavior change that was introduced after 2.6.32 (before .37) that would explain this behavior.

Any ideas what is going on here would be appreciated.
Paul Bilke

00e10c0000fe00115510132808004500
021c00004000401110360a0a0a450a0a
0a43b0971391020875b4323233333400
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000
