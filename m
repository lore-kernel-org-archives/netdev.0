From: Andy Lutomirski <luto@amacapital.net>
Subject: em1 is visible to iproute2 but not ethtool or tcpdump
Date: Thu, 14 Mar 2013 09:54:17 -0700
Message-ID: <CALCETrV0SP+z_acyRTV++uZCFafJ7h+Ef9_NQ1tKrqOAiiVt8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: e1000-devel@lists.sourceforge.net
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:39902 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab3CNQyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 12:54:37 -0400
Received: by mail-ve0-f174.google.com with SMTP id pb11so1869635veb.5
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 09:54:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My e1000e device is em1.  It has this rather strange behavior on
Fedora's 3.8.1 (although 3.7.something did the same thing, I believe):

$ ip link show dev em1
6: em1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN qlen 1000
    link/ether f0:de:f1:59:f6:c9 brd ff:ff:ff:ff:ff:ff
$ strace -e socket,ioctl ethtool em1
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
Settings for em1:
ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
Cannot get device settings: No such device
ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
Cannot get wake-on-lan settings: No such device
ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
Cannot get message level: No such device
ioctl(3, SIOCETHTOOL, 0x7fffa6c554d0)   = -1 ENODEV (No such device)
Cannot get link status: No such device
No data available
+++ exited with 75 +++
$ sudo tcpdump -i em1
tcpdump: em1: SIOETHTOOL(ETHTOOL_GTSO) ioctl failed: No such device

A sufficient number of rmmod/modprobe cycles will make it work.

This is, perhaps, helpful:

$ sudo ip link set dev em1 name foobar
RTNETLINK answers: Device or resource busy
$ sudo ip link set dev em1 down
$ sudo ip link set dev em1 name foobar
$ sudo ethtool foobar
Settings for foobar:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Speed: Unknown!
	Duplex: Unknown! (255)
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: Unknown
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000007 (7)
			       drv probe link
	Link detected: no
$ sudo ip link set dev foobar name em1
$ sudo ethtool em1
Settings for em1:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Full
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Speed: Unknown!
	Duplex: Unknown! (255)
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: Unknown
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000007 (7)
			       drv probe link
	Link detected: no
$

This bug (?) isn't a show-stopper, but it's rather annoying.  I
suspect a core networking bug, not an e1000e bug, but I cc'd the e1000
people just in case.
