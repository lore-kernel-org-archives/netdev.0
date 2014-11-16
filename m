From: oskar@cetex.se
Subject: sysctl to clamp mtu on all application-initiated
 =?UTF-8?Q?sockets=3F?=
Date: Sun, 16 Nov 2014 01:28:43 +0100
Message-ID: <c630392f593e5a8891d09339cc4becf0@cetex.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.atellus.se ([217.68.32.43]:50432 "EHLO mail1.atellus.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754768AbaKPAhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 19:37:07 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail1.atellus.se (Postfix) with ESMTP id D1724C7048
	for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 01:28:43 +0100 (CET)
Received: from mail1.atellus.se ([127.0.0.1])
	by localhost (mail1.atellus.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZkXiVZK4IJXu for <netdev@vger.kernel.org>;
	Sun, 16 Nov 2014 01:28:43 +0100 (CET)
Received: from webmail.atellus.se (localhost [127.0.0.1])
	(Authenticated sender: oskar@cetex.se)
	by mail1.atellus.se (Postfix) with ESMTPA id 59DD6C7044
	for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 01:28:43 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm trying to setup routers that should be able to forward 
jumbo-packets, but applications should not get jumbo-capable sockets.

The major brands of routers support something like this. You set mtu 
for forwarding to something big (8192, 9000) but don't touch the system 
mtu of 1500.
Management-traffic, routing protocols and such communicate with 
<=1500byte packets, but the router can forward frames up to <big> mtu 
size if other machines feel like using them.

The only ways I've found to do this is either through mss-clamping in 
iptables (+ some iptables rule that drop other packets and return ICMP 
Packet too big), or update each route on the router with an MTU 
argument, but it feels clunky and i believe this will cause quite some 
overhead which would impact forwarding-performance of the router 
negatively, It's also not nice to change tcp packet values on the fly. 
(The MTU on routes-path is quite a lot of work when running IPv4 DHCP 
client + IPv6 RA-learned routes + full BGP table on multiple boxes, it's 
easy to miss something)

So, is it possible to create something like 
/proc/sys/net/ipv*/max_socket_mtu that would clamp the MTU of all 
created sockets to some nice value?

It should also be possible to override this clamping on a per-socket 
basis (and use up to link-layer MTU size) by setting a flag or such on 
the socket, for example tunnels.

I need to solve this some how for forwarding + VXLAN, but I believe 
this would also apply to and simplify management of other tunnel 
techniques. The tunnel interface should be able to transmit encapsulated 
packets using up to link-layer MTU size inside my datacenter/network, 
but applications on the same machine shouldn't when sending data 
somewhere since it would cause extra roundtrips / broken sessions when 
oversize packets are being dropped somewhere else in the network / on 
the Internet.

Best regards
Oskar Stenman
