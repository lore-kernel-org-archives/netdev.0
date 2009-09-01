From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: 2.6.31 ARP related problems with multiple macvlan NICs
Date: Tue, 1 Sep 2009 14:30:28 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0909011347350.19568@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:53691 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752013AbZIALag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 07:30:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using multiple (e.g 2) macvlan devices set over the same uplink NIC
and 2.6.31-rc7 I can get only one of the macvlan devices to respond on
arp request where the same scheme works fine on 2.6.29.1 and 2.6.30.

The only devices for which the system responds on ARP request is the
first match in the routing table, e.g mv0 below. Next are the commands
I am using to set the environment that reproduces the problem.

Looking on net/ipv4/arp.c I do someting that may be related which
was commited for 2.6.30 and reverted for -stable and .31 so the
fact that this test actually works with 2.6.29.1/2.6.30 makes me
think that the problem I see is not directly connected to the "ipv4: arp
announce, arp_proxy and windows ip conflict verification" commit/revert.

The problem is also not directly related to macvlan, I think, e.g
I have the same issue when having multiple veth pairs connected
to a bridge, only ping to/through the first routing hit works.

Or.

--> setup things

ip link add link eth3 address 00:19:d1:29:d2:00 mv0 type macvlan
ip link add link eth3 address 00:19:d1:29:d2:01 mv1 type macvlan

ifconfig mv0 20.20.49.10/16 up
ifconfig mv1 20.20.49.11/16 up

sysctl -w net.ipv4.conf.eth3.arp_ignore=1
sysctl -w net.ipv4.conf.mv0.arp_ignore=1
sysctl -w net.ipv4.conf.mv1.arp_ignore=1

--> try to a ping remote node from either of the interfaces
--> only the ping that goes through the first routing hit (mv0) works

# ping -I mv0 20.20.49.1 -f -c 100 -q
100 packets transmitted, 100 received, 0% packet loss, time 3ms

# ping -I mv1 20.20.49.1 -f -c 100 -q
100 packets transmitted, 0 received, 100% packet loss, time 1187ms

--> try to ping both interfaces from the remote node, same problem
# ping 20.20.49.10 -f -c 100 -q
100 packets transmitted, 100 received, 0% packet loss, time 2ms

# ping 20.20.49.11 -f -c 100 -q
100 packets transmitted, 0 received, +3 errors, 100% packet loss, time 1187ms, pipe 3


