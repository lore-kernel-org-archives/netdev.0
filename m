From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 00/14] Transparent Proxying Patches, Take 5
Date: Sat, 13 Oct 2007 19:28:57 +0200
Message-ID: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:45511 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755729AbXJMSjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 14:39:40 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV00DSL1TB9V10@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:27:12 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This is the fifth round of transparent proxying patches following
recent discussion on netfilter-devel [1,2].

The aim of the patchset is to make non-locally bound sockets work both
for receiving and sending. The target is IPv4 TCP/UDP at the moment.

Speaking of the patches, there are two big parts:

 * Output path (patches 1-6): these modifications make it possible to
   send IPv4 datagrams with non-local source IP address by:

   - Introducing a new flowi flag (FLOWI_FLAG_ANYSRC) which disables
     source address checking in ip_route_output_slow(). This is
     also necessary for some of the tricks LVS does. [3]

   - Adding the IP_TRANSPARENT socket option (setting this requires
     CAP_NET_ADMIN to prevent source address spoofing).

   - Gluing these together across the TCP/UDP code.

 * Input path (patches 7-13): these changes add redirection support
   for TCP along with an iptables target implementing NAT-less traffic
   interception, and an iptables match to make ahead-of-time socket
   lookups on PREROUTING. These combined with a set of iptables rules
   and policy routing make non-locally bound sockets work.

   - Netfilter IPv4 defragmentation is split into a separate
     module. It's not particularly pretty but I see no other way of
     making sure the 'socket' match gets no fragmented IPv4 packets.

   - The 'socket' iptables match does a socket lookup on the
     destination address and matches if a socket was found.

   - The 'TPROXY' iptables target provides a way to intercept traffic
     without NAT -- it does an ahead-of-time socket lookup on the
     configured address and caches the socket reference in the skb.

   - IPv4 TCP and UDP input path is modified to use this stored socket
     reference if it's present.

The last patch adds a short intro on how to use it. A trivial patch
for netcat demonstrating the necessary modifications for proxies is
available separately at [4].


References:
[1] http://marc.info/?l=netfilter-devel&m=119118672703285&w=2
[2] http://marc.info/?l=netfilter-devel&m=119135774918622&w=2
[3] http://marc.info/?l=linux-netdev&m=118065358510836&w=2
[4] http://people.netfilter.org/hidden/tproxy/netcat-ip_transparent-support.patch

-- 
KOVACS Krisztian
