From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 00/16] Transparent proxying patches, take six
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:53158 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbYJAPZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 11:25:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is the sixth round of transparent proxying patches recently
discussed on the Netfilter Workshop. Since the last incarnation [1]
we've added support for related ICMP packets in the socket
match. Should apply cleanly on top of net-next-2.6. Could you please
apply patches 1-11 (those touching core networking parts) and I'll ask
Patrick McHardy to take care of patches 12-16 (the Netfilter parts).

The aim of the patchset is to make non-locally bound sockets work both
for receiving and sending. The target is IPv4 TCP/UDP at the moment.

Speaking of the patches, there are two big parts:

 * Output path (patches 1-7): these modifications make it possible to
   send IPv4 datagrams with non-local source IP address by:

   - Introducing a new flowi flag (FLOWI_FLAG_ANYSRC) which disables
     source address checking in ip_route_output_slow(). This is
     also necessary for some of the tricks LVS does. [2]

   - Adding the IP_TRANSPARENT socket option (setting this requires
     CAP_NET_ADMIN to prevent source address spoofing).

   - Gluing these together across the TCP/UDP code.

 * Input path (patches 8-15): these changes add redirection support
   for TCP along with an iptables target implementing NAT-less traffic
   interception, and an iptables match to make ahead-of-time socket
   lookups on PREROUTING. These combined with a set of iptables rules
   and policy routing make non-locally bound sockets work.

   - IPv4 TCP and UDP input path is modified to use this stored socket
     reference if it's present.

   - Netfilter IPv4 defragmentation is split into a separate
     module. (This could make sense independently of tproxy and
     conntrack, for example to have a stateless firewall which still
     does fragment reassembly.)

   - The 'socket' iptables match does a socket lookup on the
     destination address and matches if a socket was found.

   - The 'TPROXY' iptables target provides a way to intercept traffic
     without NAT -- it does an ahead-of-time socket lookup on the
     configured address and caches the socket reference in the skb.

The last patch adds a short intro on how to use it. A trivial patch
for netcat demonstrating the necessary modifications for proxies is
available separately at [3]. Squid has support for it in the 3.HEAD
(3.1) branch.


References:
[1] http://lwn.net/Articles/254527/
[2] http://marc.info/?l=linux-netdev&m=118065358510836&...
[3] http://people.netfilter.org/hidden/tproxy/netcat-ip_trans...

-- 
KOVACS Krisztian


