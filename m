From: Erik Slagter <erik@slagter.name>
Subject: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Wed, 20 Jun 2007 13:56:09 +0200
Message-ID: <467915D9.3030900@slagter.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from erik-slagter.demon.nl ([83.160.41.216]:46021 "EHLO
	artemis.slagter.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754765AbXFTMKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 08:10:37 -0400
Received: from [10.8.2.26] (autemslap.sys.pc.wlz.nl [10.8.2.26])
	by artemis.slagter.name (Postfix) with ESMTP id DD4FE1A34B58
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 13:56:09 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have kind of a difficult problem with my USB network adapter. It used
to work using kernel 2.6.20.3, more or less, I needed to insert and
remove the network cable from the device frequently to get it working,
but then, at least, it worked.

Now, using 2.6.22-rc2 it's not working anymore, at all. Ethtool shows
"link up", tshark shows received packets, but any traffic sent to it
seems to be discarded somewhere.

First I tested it directly connected to an intel GB nic (which I tend to
trust), then I tested it connected to an "el cheapo" GB switch, all the
same problem. Finally I connected it to another nic on the same machine
(netgear PC card GB nic), directly.

Then I did a broadcast flood ping on both interfaces (to circumvent arp
resolving), using -I eth1 and -I eth2 respectively, while running tshark
on both interfaces. The result is that when I run the ping on the
working nic, tshark on both interfaces show traffic. When I run the ping
on the USB nic, tstark only shows traffic on the USB nic.

This suggests that the USB is not actually (physically) sending data. On
the other hand, the network activity led on the working nic does show
full activity while running the ping from the USB nic. I am not too
familiar with this matter, but to me this looks like the packets are
actually output, but malformed in a way that the receiver discards them.
Having tested this with multiple "receiving" nics it can't be an issue
to a specific nic.

To rule out the possibility of the nic being defective, I connected the
USB nic to a windows computer. There it works, although the ethernet
connection is a bit flaky (just like it seems...).

Then I did a diff on the respective kernel sources of 2.6.20.3 and
2.6.22-rc2 (asix.c and usbnet.c), I found a few changes, but they do not
seem to be related to my problem.

I am the and of my repertoire here, can anyone please do some
suggestions for further testing or even better, fix it ;-)

Thanx.

Data:

skylla root:~ $ ethtool -i eth2
driver: asix
version: 14-Jun-2006
firmware-version: ASIX AX88178 USB 2.0 Ethernet
bus-info: usb-0000:00:1d.7-7

skylla root:~ $ ethtool eth2
Settings for eth2:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 24
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pg
        Wake-on: d
        Current message level: 0x00000007 (7)
        Link detected: yes

skylla root:~ $ lsusb
Bus 005 Device 055: ID 1737:0039
Bus 005 Device 054: ID 04a5:7008 Acer Peripherals Inc. (now BenQ Corp.)
Bus 005 Device 053: ID 046d:c00e Logitech, Inc. M-BJ69 Optical Wheel Mouse
Bus 005 Device 052: ID 05e3:0605 Genesys Logic, Inc. USB 2.0 Hub [ednet]
Bus 005 Device 001: ID 0000:0000
Bus 004 Device 001: ID 0000:0000
Bus 003 Device 001: ID 0000:0000
Bus 002 Device 005: ID 413c:8103 Dell Computer Corp. Wireless 350 Bluetooth
Bus 002 Device 001: ID 0000:0000
Bus 001 Device 001: ID 0000:0000

skylla root:~ $ ifconfig
eth0      Link encap:Ethernet  HWaddr ***********
          inet addr:********  Bcast:10.15.255.255  Mask:255.248.0.0
          inet6 addr: fe80::211:43ff:fe7a:6534/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:438135 errors:0 dropped:0 overruns:0 frame:0
          TX packets:157631 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:456581138 (435.4 MiB)  TX bytes:11777994 (11.2 MiB)
          Interrupt:18

eth1      Link encap:Ethernet  HWaddr ************
          inet addr:10.255.0.1  Bcast:10.255.0.255  Mask:255.255.255.0
          inet6 addr: fe80::214:6cff:fe87:a2c7/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7651 errors:0 dropped:0 overruns:0 frame:0
          TX packets:5184 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:806726 (787.8 KiB)  TX bytes:3941441 (3.7 MiB)
          Interrupt:17 Base address:0xc000

eth2      Link encap:Ethernet  HWaddr *************
          inet addr:10.255.0.2  Bcast:10.255.0.255  Mask:255.255.255.0
          inet6 addr: fe80::212:17ff:fef2:1a17/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:26414 errors:38 dropped:0 overruns:0 frame:38
          TX packets:27449 errors:120 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2074027 (1.9 MiB)  TX bytes:18700283 (17.8 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:27439 errors:0 dropped:0 overruns:0 frame:0
          TX packets:27439 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:13216214 (12.6 MiB)  TX bytes:13216214 (12.6 MiB)

eth0 = internal broadcom 100Mb nic, not used here
eth1 = netgear pccard Gb nic, used for testing
eth2 = linksys Gigabit USB2.0 adapter

