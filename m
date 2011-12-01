From: David Miller <davem@davemloft.net>
Subject: Re: Udp packets received with improper length
Date: Thu, 01 Dec 2011 14:11:36 -0500 (EST)
Message-ID: <20111201.141136.1615370877653045134.davem@davemloft.net>
References: <4ECD540C.60108@conspiracy.net>
	<4ED3FBE8.2010006@conspiracy.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
To: fsmail@conspiracy.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37064 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756147Ab1LATMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 14:12:44 -0500
In-Reply-To: <4ED3FBE8.2010006@conspiracy.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: paul bilke <fsmail@conspiracy.net>
Date: Mon, 28 Nov 2011 15:23:52 -0600

> On 11/23/2011 2:14 PM, paul bilke wrote:
>> We recently updated an embedded powerpc platform from 2.6.32 to 2.6.37.  When deployed in the field devices with the new kernel have started receiving truncated UDP packets from their mates across noisy links.  To test we wrote a simple client and
>> server.  The client sends 512 byte packets with a sequence number to the server listening on a UDP socket.  On the client box we use netem to corrupt 100% of the packets sent(after transferring some data so arp cache is populated).  The server then
>> dumps the length received and the serial number from any packets that are received.   Netem sometimes corrupts bits in the source MAC address so these packets arrive with valid UDP checksums and are delivered to the user application.   With the
>> server running on the 2.6.32 box we send a few million packets to it and only receive packets that are exactly 512 bytes long.  When we do the same on the box running 2.6.37 we receive hundred of short packets, zero length and also 504 byte packets.
>> When I use TCPdump on the box running 2.6.37 the truncate packets have valid checksums (Source MAC was corrupted by NETEM) and are of proper length (554 byte ethernet frame, 540 Byte IP portion and 520 byte UDP length) but the userland receives 504
>> or 0 length in recvfrom. To see if this was just a powerpc related issue I repeated the test on x86 virtual machines.  A vm running 2.6.18 (Centos 5) receives only 512 byte packets.  On a vm running 2.6.40 (Fedora 15) I receive 512, 504 and 0 length
>> packets.
> <clip>
> 
> Reverting commit 81d54ec8479a2c695760da81f05b5a9fb2dbe40a makes this problem disappear. The patch looks sane, the results are problematic.

I think that commit is buggy.  If we do a goto to "try_again", the length has already been
truncated the first time around, so the calculation is not the same as what the original code
calculates

And indeed, checksum errors are how we can end up taking this code path.

I'm reverting.
