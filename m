From: Glen Turner <gdt@gdt.id.au>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Fri, 21 Dec 2007 01:11:35 +1030
Message-ID: <1198161695.6154.47.camel@andromache>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
	 <Pine.LNX.4.64.0712181818360.4422@fbirervta.pbzchgretzou.qr>
	 <83a51e120712181009pf954f43mcb63ea4dab638458@mail.gmail.com>
	 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
	 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
	 <4768123A.7040603@cosmosbay.com>
	 <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
	 <47682F8C.20205@cosmosbay.com>
	 <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
	 <47694FCC.1020507@cosmosbay.com>
	 <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
	 <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Nichols <jamesnichols3@gmail.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:36960 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751048AbXLTOsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 09:48:33 -0500
In-Reply-To: <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[speculation by network engineer -- not kernel hacker -- follows]

> The router could be sooo crappy that it drops all packets from
> TCP streams that have SACK enabled and the client has opened
> 200+ SACK connections previously... something like that?

As far as any third party is concerned the existing TCP connections
continue to have negotiated "SACK Permitted". Only new connections
will not negotiate this.  So "router crappiness" promptly disappearing
doesn't seem too likely (a way I could see this happening is if the
Linux box sends a Ack for each connection and this clears out Sack
datastructures on the third party).

But I'd be very surprised if the router is acting as anything more
that a network-layer device. It might perhaps have some soft connection
state being used for generating accounting records.  Being Cisco
it's probably a switch-router, so it might carry some per-port hard
state for validating source IP addresses and ARPs on each port.

The firewall is much more likely to be carrying per-flow Sack
state. The Cisco PIX had a bug with SACK handling (CSCse14419,
fixed in 7.0(7), 7.1(2.34), 7.2(2.2), 8.0(0.141) but perhaps it
has regressed). A simple trace either side of the firewall will
show the inconsistency between the TCP sequence number (which
gets randomised) and the Sack sequence number (which didn't).
You could disable the TCP Sequence Number Randomisation feature
and see if the fault reoccurs.

You'd probably should also investigate the Linux kernel,
especially the size and locks of the components of the Sack data
structures and what happens to those data structures after Sack is
disabled (presumably the Sack data structure is in some unhappy
circumstance, and disabling Sack allows the data to be discarded,
magically unclaging the box).

In the absence of the reporter wanting to dump the kernel's
core, how about a patch to print the Sack datastructure when
the command to disable Sack is received by the kernel?
Maybe just print the last 16b of the IP address?

Best wishes, Glen

