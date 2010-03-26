From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP path MTU discovery
Date: Thu, 25 Mar 2010 17:53:11 -0700
Message-ID: <4BAC0577.7070803@hp.com>
References: <1269561751.2891.8.camel@ilion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:5556 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab0CZAxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 20:53:15 -0400
In-Reply-To: <1269561751.2891.8.camel@ilion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glen Turner wrote:
> [This is a second attempt to report this bug.]

Bugzilla somewhere?

> Path MTU Discovery for UDP underperforms for IPv4 and fails for IPv6 in Linux
> for transactional services like DHCP and RADIUS running on jumbo frame
> interfaces.
> 
> These servers send packets with exponential back-off. UDP Path MTU Discovery
> probes for the path MTU each time the application sends a packet. So if you
> start with a high enough interface MTU then the server application backoff 
> times get huge and the client gives up before the path MTU is discovered.
> 
> This differs from TCP, where it is the kernel -- and not the application --
> which organises retransmission. On receiving a ICMP Fragmentation Needed the
> kernel can immediately re-probe the path MTU wiht no waiting for an
> exponential timer to expire.
> 
> In IPv4 there is a work-around for the server, turn off Path MTU Discovery
> and allow routers to fragment the packet as needed. Looking at the code for
> the various transactional servers (ISC DHCP, FreeRADIUS, RADIATOR,
> radsecproxy) they all disable Path MTU Discovery on Linux. This workaround
> has the side effect of hiding the problem, misleading people into thinking
> that UDP Path MTU Discovery actually works for these transactional servers.
> 
> In IPv6 routers do not fragment packets, so there is no work around.
> Transactional servers which use UDP over IPv6 encounter exponential backoffs
> within the application and the client abandons the transaction. There is no
> way for the server to know that the packet was lost due to Path MTU Discovery
> and to immediately re-transmit it (without an exponential penalty) so that
> the MTU can be probed again.
> 
> This can be viewed as a flaw in the RFC and in the sockets API
> for which IPv6 has removed the common work-around.

So, presuming it is indeed a bug what form might a fix take? Are you suggesting 
there should be a way for an application to say "Please let me see/know about 
the ICMP messages?"  Is that option available on other platforms as a 
platform-specific extension?  I don't have the details, but the HP-UX 11i v3 
(11.31) netinet/udp.h file contains these:

#define UDP_RX_ICMP     0x02    /* boolean; get/set ICMP packets reception */
                                 /* Set to 1 if ICMP packets are to be received*/

#define UDP_RX_ICMP6    0x03    /* boolean; get/set ICMPv6 packets reception */
                                 /* Set to 1 if ICMPv6 packets are to be
                                    received */

and it does appear that they are in more places than just HP-UX - there are some 
hits for that for the old Apple Open Transport - which makes sense - it too had 
Mentat origins.

rick jones
