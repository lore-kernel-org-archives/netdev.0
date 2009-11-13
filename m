From: Kevin Shanahan <kmshanah@disenchant.net>
Subject: Problem with VLANs and via-velocity driver
Date: Fri, 13 Nov 2009 14:02:17 +1030
Message-ID: <20091113033217.GQ838@cubit>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail05.adl2.internode.on.net ([203.16.214.145]:40641 "EHLO
	ipmail05.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755544AbZKMDh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 22:37:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've had some problems with getting a fairly simple (I thought) VLAN
configuration working with the on board Via NICs on my Via M700
board. Looks like as soon as a tagged VLAN interface is added, the
underlying "raw" (untagged) interface stops responding.

E.g. this is my desired setup on eth1:

Untagged VLAN: 10.193.38.0/24
  cubert (Linux 2.6.30.5) - 10.193.38.254
  switch (HP ProCurve)    - 10.193.38.1

Tagged VLAN (101): 10.193.39.192/26
  cubert (Linux)       - 10.193.39.254
  switch (HP ProCurve) - 10.193.39.193

Starting with just eth1 configured, VLAN interfaces are down:

cubert:~# ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:40:63:fa:bb:80  
          inet addr:10.193.38.254  Bcast:10.193.38.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4504 errors:0 dropped:0 overruns:0 frame:0
          TX packets:453 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:49136 (47.9 KiB)  TX bytes:21066 (20.5 KiB)
          Interrupt:36 Base address:0xdc00 

cubert:~# ping 10.193.38.1
PING 10.193.38.1 (10.193.38.1) 56(84) bytes of data.
64 bytes from 10.193.38.1: icmp_seq=1 ttl=64 time=0.885 ms
64 bytes from 10.193.38.1: icmp_seq=2 ttl=64 time=0.889 ms
^C
--- 10.193.38.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.885/0.887/0.889/0.002 ms
cubert:~# 

So far so good...

cubert:~# ifup vlan101
Set name-type for VLAN subsystem. Should be visible in /proc/net/vlan/config
Added VLAN with VID == 101 to IF -:eth1:-
cubert:~# ifconfig vlan101
vlan101   Link encap:Ethernet  HWaddr 00:40:63:fa:bb:80  
          inet addr:10.193.39.254  Bcast:10.193.39.255  Mask:255.255.255.192
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

cubert:~# ping 10.193.39.193
PING 10.193.39.193 (10.193.39.193) 56(84) bytes of data.
64 bytes from 10.193.39.193: icmp_seq=1 ttl=64 time=4.24 ms
64 bytes from 10.193.39.193: icmp_seq=2 ttl=64 time=1.11 ms
^C
--- 10.193.39.193 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 1.116/2.681/4.247/1.566 ms
cubert:~# 

Also looking good, however:

cubert:~# ping 10.193.38.1
PING 10.193.38.1 (10.193.38.1) 56(84) bytes of data.
^C
--- 10.193.38.1 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1010ms

And eth1 won't respond again until I take down vlan101 and eth1 and
bring eth1 back up again.

cubert:~# ifdown vlan101
Removed VLAN -:vlan101:-
cubert:~# ping 10.193.38.1
PING 10.193.38.1 (10.193.38.1) 56(84) bytes of data.
^C
--- 10.193.38.1 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1011ms

cubert:~# ifdown eth1
cubert:~# ifup eth1
cubert:~# ping 10.193.38.1
PING 10.193.38.1 (10.193.38.1) 56(84) bytes of data.
64 bytes from 10.193.38.1: icmp_seq=1 ttl=64 time=0.869 ms
64 bytes from 10.193.38.1: icmp_seq=2 ttl=64 time=0.947 ms
^C
--- 10.193.38.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 0.869/0.908/0.947/0.039 ms

Here is my configuration in /etc/network/interfaces (Debian/Lenny):

iface eth1 inet static
	address 10.193.38.254
	netmask 255.255.255.0
	broadcast 10.193.38.255
	network 10.193.38.0

iface vlan101 inet static
	address 10.193.39.254
	netmask 255.255.255.192
	broadcast 10.193.39.255
	network 10.193.39.192
	vlan_raw_device eth1

A bit of searching found a few references to similar problems going
back a few years (2005, 2007). Sounded like there were some driver
issues, but it wasn't clear from the messages I found whether they
were believed to be fixed or not. I tried the same test using a
differnt NIC with the tg3 driver and there were no problems, so it
looks to me like it's still a via-velocity issue. Unfortunately I
don't have room to add NICs to this machine and need to use the on
board Via hardware.

This is the network hardware on the non-working Via board:

cubert:~# lspci -k
...
02:00.0 Ethernet controller: VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter (rev 82)
	Kernel driver in use: via-velocity
03:00.0 Ethernet controller: VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter (rev 82)
	Kernel driver in use: via-velocity

And on my laptop where this same config does work:

kulgan:~# lspci -k
...
09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5752 Gigabit Ethernet PCI Express (rev 02)
	Subsystem: Dell Device 01d6
	Kernel driver in use: tg3

I understand that it's not best practice to combine tagged and
untagged frames on the same link (something to do with VLAN hopping
attacks), so perhaps this is not a priority to fix. However, I'm happy
to test patches if there are any.

Regards,
Kevin Shanahan.
