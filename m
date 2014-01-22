From: Philippe Troin <phil@fifi.org>
Subject: Weirdness with combined SNAT/DNAT, bridging and promiscuous mode
Date: Tue, 21 Jan 2014 19:22:17 -0800
Message-ID: <1390360937.26514.24.camel@ceramic.home.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from granite.fifsource.com ([173.255.216.206]:34965 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaAVDaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 22:30:12 -0500
Received: from [172.17.1.2] (gw.fifi.org [50.0.150.98])
	(using SSLv3 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by granite.fifsource.com (Postfix) with ESMTPSA id E52BD406E
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 19:22:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran into a weird bridging issue that I wanted to share with this list.
This was found on Fedora 19 running with the latest 3.12.8.200.fc19
x86_64 kernel.

I have the following network (simplified):

  +-----+
  | ex1 |
  +-----+
     | 10.0.0.2/24
     |
     | 10.0.0.1/24
  +--------+
  | router |
  +--------+
     | 192.168.1.1/24
     |
     | 192.168.1.2/24
  +-----+
  | in1 |
  +-----+

Ex1 is on the exterior (internet), in1 on the interior sides.
I want to forward a port from 10.0.0.1:2222 to 192.168.1.2:22.
I use an iptables DNAT target on the router's nat PREROUTING chain, all
is fine, when I connect from ex1 to 10.0.0.1:2222, it works.

If I want to forward connections from router's 10.0.0.1:2222 to in's
192.168.1.2:22, I add the same rule DNAT to the OUTPUT chain.

If now I also want to allow connections from in1 to 10.0.0.1:2222 to be
looped back to in1's port 22, it's also possible by adding an extra SNAT
rule.

At this point, I have the following network scripts:

      * ex1
                ip link set up dev eth0
                ip addr add 10.0.0.2/24 dev eth0
                
      * router
                ip link set up dev eth0
                ip addr add 10.0.0.1/24 dev eth0
                ip link set up dev eth1
                ip addr add 192.168.1.1/24 dev eth1
                iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT --to-source 10.0.0.1
                iptables -t nat -A OUTPUT -p tcp -d 10.0.0.1 --dport 2222 -j DNAT --to 192.168.1.2:22
                iptables -t nat -A PREROUTING -p tcp -d 10.0.0.1 --dport 2222 -j DNAT --to 192.168.1.2:22
                iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -d 192.168.1.2 -p tcp --dport 22 -j SNAT --to-source 192.168.1.1
                sysctl net.ipv4.ip_forward=1
                
                
      * in1
                ip link set up dev eth0
                ip addr add 192.168.1.2/24 dev eth0
                ip route add 0.0.0.0/0 via 192.168.1.1

>From all three machines, connecting to 10.0.0.1:22 will forward the TCP
connection to 192.168.1.2:22.

Now, let's introduce a bridge. If make eth1 join a bridge br1, the
script for the router machine becomes:

        brctl addbr br1
        brctl addif br1 eth1
        
        ip link set up dev eth0
        ip addr add 10.0.0.1/24 dev eth0
        
        ip link set up dev eth1
        ip link set up dev br1
        ip addr add 192.168.1.1/24 dev br1
        
        iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT --to-source 10.0.0.1
        iptables -t nat -A OUTPUT -p tcp -d 10.0.0.1 --dport 2222 -j DNAT --to 192.168.1.2:22
        iptables -t nat -A PREROUTING -p tcp -d 10.0.0.1 --dport 2222 -j DNAT --to 192.168.1.2:22
        iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -d 192.168.1.2 -p tcp --dport 22 -j SNAT --to-source 192.168.1.1
        sysctl net.ipv4.ip_forward=1

And now, although I can connect to 10.0.0.1:22 fine from ex1 and router,
but connecting from in1 fails.
The connection hangs.
Tcpdump (without turning promiscuous mode on) shows that the syn packets
from in1 show up on router's eth1 interface, but are not visible to the
br1 bridge.  The MAC addresses on the frames seem to correct (both br1
and eth1 have the same MAC in this set-up, by default).

Oddly enough, turning on promiscuous mode on br1 makes everything work.
Changing promiscuous mode on eth1 has no effect.

Why would the promiscuous mode on the bridge itself change the behavior
of the iptables script above?

I could understand promiscuous mode and physical interface's MAC
filters, but I thought that promiscuous mode on a bridge interface was a
no-op.

A quick grep shows that IFF_PROMISC is used in the bridging code in
br_pass_frame_up() and br_handle_frame_finish(), both in br_input.c.

Am I supposed to turn on promiscuous mode on bridge interfaces, or is it
something else (bug in my iptables script, bug in bridging)?

Thanks for reading this long-winded email.
Phil.
