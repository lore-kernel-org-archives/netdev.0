From: Bernhard Schmidt <berni@birkenwald.de>
Subject: VXLAN multicast receive not working
Date: Wed, 21 Nov 2012 23:27:27 +0000 (UTC)
Message-ID: <k8jo0v$8hn$1@ger.gmane.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:49868 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815Ab2KVW1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 17:27:24 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TbJhs-0008M8-HI
	for netdev@vger.kernel.org; Thu, 22 Nov 2012 00:27:48 +0100
Received: from nat64.discard.me.uk ([90.155.46.46])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 00:27:48 +0100
Received: from berni by nat64.discard.me.uk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 00:27:48 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm just trying to play with VXLAN a bit and wanted to build a Linux
gateway routing into seperate VXLAN segments.

Debian Wheezy, running 3.7-rc6, with current git HEAD of iproute2.
It's a VMware VM but that should not matter much.

Two vmxnet3 NICs, one with management and one with my VXLAN transport
network.

4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UNKNOWN qlen 1000
    link/ether 00:50:56:8e:0d:c8 brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.250/24 scope global eth1
    inet6 fe80::250:56ff:fe8e:dc8/64 scope link 
       valid_lft forever preferred_lft forever

In the same network segment are two VMware ESXi 5.0 hosts with Nexus
1000V for VLAN termination (10.0.0.1 and 10.0.0.2)

On top of that there is a VXLAN interface defined, with ID 12340 and
group 239.0.0.42.

6: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue
state UNKNOWN mode DEFAULT 
    link/ether f6:59:e7:db:82:92 brd ff:ff:ff:ff:ff:ff
    vxlan id 12340 group 239.0.0.42 dev eth1 port 32768 61000 ageing 300 

That interface has an address as well

6: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue
state UNKNOWN 
    link/ether f6:59:e7:db:82:92 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.1/24 scope global vxlan0
    inet6 fe80::f459:e7ff:fedb:8292/64 scope link 
       valid_lft forever preferred_lft forever

The same VXLAN domain is defined on the Nexus 1000V and a VM is attached
to it. When I send some broadcast traffic down vxlan0 (i.e. ping
10.1.1.2 which generates an ARP request) the VM sees the packet just
fine.

When I do it the other way around (the VM sends a broadcast ARP for
10.1.1.3) I see a packet coming into eth1 on the multicast group, but
vxlan0 stays silent. 

I have captured one of those packets, wireshark does not support
disecting it yet but in my eyes the packet is correct. I've put it
online at http://users.birkenwald.de/~berni/temp/vxlan.pcap

Weirdly enough, as soon as I populate the ARP and VXLAN forwarding table
by pinging back from the destination to the source (so the source can
learn both MAC->Nexthop for VXLAN and IP->MAC from the ARP request) it
starts working. 

To summarize, Multicast/Broadcast from N1k to Linux seems to be broken,
the encapsulated packet is seen on the Ethernet but the decapsulated
packet is not seen on vxlan0. Broadcast/Multicast in the other direction
works just fine as well as Unicast in both directions.

Thanks for any pointers,
Bernhard
