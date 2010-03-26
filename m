From: Glen Turner <gdt@gdt.id.au>
Subject: UDP path MTU discovery
Date: Fri, 26 Mar 2010 10:32:31 +1030
Message-ID: <1269561751.2891.8.camel@ilion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:41199 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751963Ab0CZAhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 20:37:17 -0400
Received: from [192.168.253.186] (ilion.44ansell.gdt.id.au [192.168.253.186])
	(authenticated bits=0)
	by aix.gdt.id.au (8.14.2/8.14.2) with ESMTP id o2Q01956019444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 10:31:10 +1030
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[This is a second attempt to report this bug.]

Path MTU Discovery for UDP underperforms for IPv4 and fails
for IPv6 in Linux for transactional services like DHCP and
RADIUS running on jumbo frame interfaces.

These servers send packets with exponential back-off. UDP
Path MTU Discovery probes for the path MTU each time the
application sends a packet. So if you start with a high
enough interface MTU then the server application backoff
times get huge and the client gives up before the path
MTU is discovered.

This differs from TCP, where it is the kernel -- and not
the application -- which organises retransmission. On
receiving a ICMP Fragmentation Needed the kernel can
immediately re-probe the path MTU wiht no waiting for
an exponential timer to expire.

In IPv4 there is a work-around for the server, turn off
Path MTU Discovery and allow routers to fragment the packet
as needed. Looking at the code for the various transactional
servers (ISC DHCP, FreeRADIUS, RADIATOR, radsecproxy) they
all disable Path MTU Discovery on Linux. This workaround has
the side effect of hiding the problem, misleading people into
thinking that UDP Path MTU Discovery actually works for these
transactional servers.

In IPv6 routers do not fragment packets, so there is no work
around. Transactional servers which use UDP over IPv6 encounter
exponential backoffs within the application and the client
abandons the transaction. There is no way for the server to
know that the packet was lost due to Path MTU Discovery and
to immediately re-transmit it (without an exponential penalty)
so that the MTU can be probed again.

This can be viewed as a flaw in the RFC and in the sockets API
for which IPv6 has removed the common work-around.

Thank you, Glen

-- 
 Glen Turner
 www.gdt.id.au/~gdt

