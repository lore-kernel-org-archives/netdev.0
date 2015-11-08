From: Ido Barkan <ibarkan@redhat.com>
Subject: Bridge does not forward packets to a tap device
Date: Sun, 8 Nov 2015 11:31:50 +0200
Message-ID: <CAFmWiaRA01GZpLAa8DNu3-iBBQNrXZA1quohVacSz3OPXkKw8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38539 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbbKHJcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 04:32:11 -0500
Received: by wmec201 with SMTP id c201so47451786wme.1
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 01:32:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We have this very disturbing issue on a few of our production servers,
which disconnects VMs
from their network.
* The Vms are part of an oVirt host so each vm is attached to a l2
bridge with a tap device.
* The bridge has an IP on it and is connected via a bond
Issue:
--------
when the machine pings outside to the host (8.8.8.8):
* arp who-has packets are sent to the bridge and forwarded but the
bridge is not forwarding the reply (is-at) (see tcpdump output in [1])

2 more interesting facts:
----------------------------------
* ping directly to the bridge ip succeeds.
* the host is a UCS host.

<Versions>:
[root@ucs1-b200-2 ~]# uname -r
2.6.32-573.7.1.el6.x86_64
[root@ucs1-b200-2 ~]# rpm -q libvirt
libvirt-0.10.2-54.el6.x86_64


<Network configuration on host>
[root@ucs1-b200-2 ~]# ip l
2: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq
master bond0 state UP qlen 1000
    link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq
master bond0 state UP qlen 1000
    link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
4: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP
    link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
5: rhevm: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 00:25:b5:0a:00:09 brd ff:ff:ff:ff:ff:ff
11: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UNKNOWN qlen 500
    link/ether fe:1a:4a:23:12:a0 brd ff:ff:ff:ff:ff:ff
************
[root@ucs1-b200-2 ~]# ip -4 a
5: rhevm: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    inet 10.35.19.149/22 brd 10.35.19.255 scope global rhevm
************
[root@ucs1-b200-2 ~]# brctl show
bridge name    bridge id        STP enabled    interfaces
rhevm        8000.0025b50a0009    no        bond0
                                                             vnet0
*************
[root@ucs1-b200-2 ~]# brctl showmacs rhevm | grep fe:1a:4a:23:12:a0
  2    fe:1a:4a:23:12:a0    yes           0.00

[1] tcpdump on the host
[root@ucs1-b200-2 ~]# tcpdump -n -i vnet0 "(host 10.35.16.244) and
(icmp or arp)"
tcpdump: WARNING: vnet0: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on vnet0, link-type EN10MB (Ethernet), capture size 65535 bytes
11:12:11.943033 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 28
11:12:11.943065 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 42
11:12:12.942992 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 28
11:12:12.943022 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 42
11:12:13.057004 ARP, Request who-has 10.35.19.254 tell 10.35.16.244, length 28
11:12:13.057037 ARP, Request who-has 10.35.19.254 tell 10.35.16.244, length 42
11:12:13.943049 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 28
11:12:13.943080 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 42
11:12:14.057043 ARP, Request who-has 10.35.19.254 tell 10.35.16.244, length 28
........
[root@ucs1-b200-2 ~]# tcpdump -n -i rhevm "(host 10.35.16.244) and
(icmp or arp)"
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on rhevm, link-type EN10MB (Ethernet), capture size 65535 bytes
11:12:50.072067 ARP, Request who-has 10.35.19.254 tell 10.35.16.244, length 28
11:12:50.072094 ARP, Request who-has 10.35.19.254 tell 10.35.16.244, length 42
11:12:50.072495 ARP, Reply 10.35.19.254 is-at 00:00:0c:07:ac:00, length 46
11:12:50.535085 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 28
11:12:50.535106 ARP, Request who-has 10.35.19.120 tell 10.35.16.244, length 42
11:12:50.535372 ARP, Reply 10.35.19.120 is-at 00:1a:4a:23:13:cb, length 42


-- 
Thanks,
Ido Barkan
