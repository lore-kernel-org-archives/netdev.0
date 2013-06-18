From: Sergey <sepron@gmail.com>
Subject: redirect host vs ip route cache
Date: Tue, 18 Jun 2013 12:42:56 +0000 (UTC)
Message-ID: <loom.20130618T142341-689@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:54761 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404Ab3FRMpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 08:45:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UovHT-0001JV-0w
	for netdev@vger.kernel.org; Tue, 18 Jun 2013 14:45:05 +0200
Received: from ippool.alpari.ru ([ippool.alpari.ru])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 14:45:03 +0200
Received: from sepron by ippool.alpari.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 14:45:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys,

the network scheme is the following:

Servers in network 10.0.0.0/24 -> 10.0.0.1 (core) -> 10.0.0.2 (router with 
NAT to 1.2.3.4) -> internet

As you might have guessed I have the problem with "router with NAT".
It is Debian with kernel 3.2.0-0.bpo.4-amd64.

When I try to ping/telnet/etc. I get a problem.

Example:

Server 10.0.0.123 ping 4.2.2.4:

# ping 4.2.2.4
PING 4.2.2.4 (4.2.2.4) 56(84) bytes of data.
>From 10.0.0.1: icmp_seq=3 Redirect Host(New nexthop: 10.0.0.2)
>From 1.2.3.4 icmp_seq=1 Destination Host Unreachable 

On 10.0.0.2 we can see in ip route cache:

10.0.0.123 from 4.2.2.4 dev eth0  src 1.2.3.4
    cache  ipid 0x3837 rtt 75ms rttvar 60ms cwnd 10 iif eth0.635
4.2.2.4 from 10.0.0.123 tos lowdelay via 10.0.0.2 dev eth0.635  src 10.0.0.2 
    cache <src-direct,redirected>  ipid 0x6955 iif eth0
4.2.2.4 from 10.0.0.123 via 10.0.0.2 dev eth0.635  src 10.0.0.2 
    cache <src-direct>  ipid 0x6955 iif eth0
4.2.2.4 via 10.0.0.2 dev eth0.635  src 1.2.3.4
    cache <redirected>  ipid 0x6955
local 1.2.3.4 from 4.2.2.4 dev lo  src 1.2.3.4 
    cache <local>  ipid 0xec85 iif eth0.635

After that, I can flush route cache and everything works fine. When 
everything works, route cache looks like this:

4.2.2.4 via 1.2.3.1 dev eth0.635  src 1.2.3.4
    cache  ipid 0x6955
local 1.2.3.4 from 4.2.2.4 dev lo  src 1.2.3.4 
    cache <local>  ipid 0xecb1 iif eth0.635
10.0.0.123 from 4.2.2.4 dev eth0  src 1.2.3.4 
    cache  ipid 0x386f rtt 75ms rttvar 60ms cwnd 10 iif eth0.635
4.2.2.4 from 10.0.0.123 via 1.2.3.1 dev eth0.635  src 10.0.0.2 
    cache <src-direct>  ipid 0x6955 iif eth0



1) When I tell 10.0.0.123 to use 10.0.0.2 as the default gateway - 
everything works like a charm, without flushing the cache
2) When I have FreeBSD server as 10.0.0.2 - everything works perfectly. 
Bloody route cache.

--
Regards,
Sergey
