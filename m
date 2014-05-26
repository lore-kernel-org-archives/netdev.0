From: Gioacchino Mazzurco <gmazzurco89@gmail.com>
Subject: Linux 802.1ad VLAN unexpected beaviour
Date: Mon, 26 May 2014 21:39:12 +0200
Message-ID: <2537748.74g6mjFNSk@vaio-gio>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45963 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbaEZTjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 15:39:18 -0400
Received: by mail-we0-f174.google.com with SMTP id k48so8524055wev.19
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 12:39:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All!

As part of my GSoC project I am implementing 802.1ad support for netifd, while 
testing this new code I encountered a very strange behavior on linux kernel, 
the netifd tests just made me notice the unexpected behavior, but are not 
involved in the problem and doesn't are needed to reproduce it.

Interfaces created as 802.1ad VLAN appear to the system as 802.1ad but seems 
they are injecting on the cable 802.1q frames instead of 802.1ad ones.

I have tested various version of linux kernel from 3.10 (the one in wich this 
feature was introtuced) to 3.12.13 and everyone were affected, so it doesn't 
seems to me a regression or something fixed in newer release.

Following how to reproduce the unexpected behavior and some output from my 
commandline.

My setup have two linux host connected by ethernet cable.

#### On host A 

# first configure the vlan interface

ip link add link eth0 test1 type vlan proto 802.1ad id 1000
ip link set up dev test1

# then send some traffic on that new device with
ping6 ff02::3%test1

# on another window on the same device sniff what seems is going out from eth0

tcpdump -n -e -vv -ttt -i eth0 not tcp port 23 and not arp

# the output will be something like that:
OUTPUT<<

tcpdump: WARNING: eth0: no IPv4 address assigned
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535 
bytes
00:00:00.000000 00:15:6d:9f:48:72 > 33:33:00:00:00:03, ethertype 802.1Q-QinQ 
(0x88a8), length 122: vlan 1000, p 0, ethertype IPv6, (hlim 1, next-header 
ICMPv6 (58) payload length: 64) fe80::215:6dff:fe9f:4872 > ff02::3: [icmp6 sum 
ok] ICMP6, echo request, seq 1
00:00:01.005251 00:15:6d:9f:48:72 > 33:33:00:00:00:03, ethertype 802.1Q-QinQ 
(0x88a8), length 122: vlan 1000, p 0, ethertype IPv6, (hlim 1, next-header 
ICMPv6 (58) payload length: 64) fe80::215:6dff:fe9f:4872 > ff02::3: [icmp6 sum 
ok] ICMP6, echo request, seq 2
00:00:00.999914 00:15:6d:9f:48:72 > 33:33:00:00:00:03, ethertype 802.1Q-QinQ 
(0x88a8), length 122: vlan 1000, p 0, ethertype IPv6, (hlim 1, next-header 
ICMPv6 (58) payload length: 64) fe80::215:6dff:fe9f:4872 > ff02::3: [icmp6 sum 
ok] ICMP6, echo request, seq 3

OUTPUT

# as you can see the ethertype is the expected one 802.1Q-QinQ (0x88a8) == 
802.1ad


# on host B

# at the same time run tcpdump on host B with similar parameters

tcpdump -n -e -vv -ttt -i ethernet0 not tcp port 23 and not arp

# you will see something like that:

OUTPUT<<

tcpdump: listening on ethernet0, link-type EN10MB (Ethernet), capture size 
65535 bytes
00:00:00.000000 00:15:6d:9f:48:72 > 33:33:00:00:00:03, ethertype 802.1Q 
(0x8100), length 122: vlan 1000, p 0, ethertype IPv6, (hlim 1, next-header 
ICMPv6 (58) payload length: 64) fe80::215:6dff:fe9f:4872 > ff02::3: [icmp6 sum 
ok] ICMP6, echo request, seq 1
00:00:01.005301 00:15:6d:9f:48:72 > 33:33:00:00:00:03, ethertype 802.1Q 
(0x8100), length 122: vlan 1000, p 0, ethertype IPv6, (hlim 1, next-header 
ICMPv6 (58) payload length: 64) fe80::215:6dff:fe9f:4872 > ff02::3: [icmp6 sum 
ok] ICMP6, echo request, seq 2
00:00:01.000044 00:15:6d:9f:48:72 > 33:33:00:00:00:03, ethertype 802.1Q 
(0x8100), length 122: vlan 1000, p 0, ethertype IPv6, (hlim 1, next-header 
ICMPv6 (58) payload length: 64) fe80::215:6dff:fe9f:4872 > ff02::3: [icmp6 sum 
ok] ICMP6, echo request, seq 3
00:00:01.000014 00:15:6d:9f:48:72 > 33:33:00:00:00:03, ethertype 802.1Q 
(0x8100), length 122: vlan 1000, p 0, ethertype IPv6, (hlim 1, next-header 
ICMPv6 (58) payload length: 64) fe80::215:6dff:fe9f:4872 > ff02::3: [icmp6 sum 
ok] ICMP6, echo request, seq 4
 
OUTPUT

# as you can see the ethertype is not the expected one 802.1Q (0x8100) != 
802.1ad

# Inverting Host A and B give same behavior

Thanks for help and attention :)
