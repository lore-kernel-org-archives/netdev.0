From: WeipingPan <panweiping3@gmail.com>
Subject: When can a net device get its setting correctly ?
Date: Mon, 31 Oct 2011 10:53:14 +0800
Message-ID: <4EAE0D9A.9060408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:51993 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645Ab1JaCvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2011 22:51:36 -0400
Received: by vcge1 with SMTP id e1so4473595vcg.19
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2011 19:51:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all,

BUG DESCRIPTION:
Zheng Liang(lzheng@redhat.com) found a problem that if we config bonding 
with arp monitor,
and enslave 10G cards, bonding driver cannot get the speed and duplex 
from them,
it will assume to be 100Mb/sec and Full.

I test kernel upstream, commit ec7ae517537a(Merge 
git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-2.6),
it also has this problem.
And not only 10G cards have this problem, when I use 1Gb(igb), the 
problem is the same.


[root@dell-p390n-01 ~]# uname -a
Linux dell-p390n-01.lab.bos.redhat.com 3.1.0+ #1 SMP Fri Oct 28 23:38:59 
EDT 2011 i686 i686 i386 GNU/Linux

[root@dell-p390n-01 ~]# dmesg |grep p4p1
udev: renamed network interface eth0 to p4p1
ADDRCONF(NETDEV_UP): p4p1: link is not ready
igb: p4p1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
ADDRCONF(NETDEV_CHANGE): p4p1: link becomes ready

[root@dell-p390n-01 ~]# ethtool p4p1
Settings for p4p1:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 1000Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 1
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: Unknown
         Supports Wake-on: pumbg
         Wake-on: d
         Current message level: 0x00000003 (3)
         Link detected: yes

[root@dell-p390n-01 ~]# modprobe bonding mode=1 arp_interval=100 
arp_ip_target=10.66.12.130
[root@dell-p390n-01 ~]# ifconfig bond0 up
[root@dell-p390n-01 ~]# ifenslave bond0 p4p1

[root@dell-p390n-01 ~]# dmesg
bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
bonding: ARP monitoring set to 100 ms, validate none, with 1 target(s):
bonding:  10.66.12.130
bonding:
ADDRCONF(NETDEV_UP): bond0: link is not ready
bonding: bond0: Warning: failed to get speed and duplex from p4p1, 
assumed to be 100Mb/sec and Full.<-----bug
bonding: bond0: making interface p4p1 the new active one.
bonding: bond0: first active interface up!
bonding: bond0: enslaving p4p1 as an active interface with an up link.
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
bonding: bond0: link status definitely down for interface p4p1, disabling it
bonding: bond0: now running without any active interface !
igb: p4p1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX


[root@dell-p390n-01 ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: None
MII Status: down
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 100
ARP IP target/s (n.n.n.n form): 10.66.12.130

Slave Interface: p4p1
MII Status: down
Speed: 100 Mbps <------ bug
Duplex: full
Link Failure Count: 1
Permanent HW addr: 00:1b:21:66:d8:a0
Slave queue ID: 0


But there is no such problem when use miimon.

[root@dell-p390n-01 ~]# modprobe bonding mode=1 miimon=100
[root@dell-p390n-01 ~]# ifconfig bond0 up
[root@dell-p390n-01 ~]# ifenslave bond0 p4p1
[root@dell-p390n-01 ~]# dmesg
bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
bonding: MII link monitoring set to 100 ms
ADDRCONF(NETDEV_UP): bond0: link is not ready
bonding: bond0: enslaving p4p1 as a backup interface with a down link.
igb: p4p1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
bonding: bond0: link status definitely up for interface p4p1, 1000 Mbps 
full duplex.
bonding: bond0: making interface p4p1 the new active one.
bonding: bond0: first active interface up!
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready


BUG ANALYSIS:
First, when uses arp monitor, the call trace is:
1485 int bond_enslave(struct net_device *bond_dev, struct net_device
*slave_dev)
1652         res = dev_open(slave_dev);
1761         if (bond_update_speed_duplex(new_slave) &&

And when calling bond_update_speed_duplex(), this message, "igb: p4p1 
NIC Link
is Up 1000 Mbps Full Duplex, Flow Control: RX", doesn't show up.
So I think even we call dev_open(), but the device is not ready to get its
setting.

Second, when uses miimon, the call trace is:
1485 int bond_enslave(struct net_device *bond_dev, struct net_device
*slave_dev)
1652         res = dev_open(slave_dev);

2419 static void bond_miimon_commit(struct bonding *bond)
2444                         bond_update_speed_duplex(slave);

And when calling bond_update_speed_duplex(), it gets correct setting.

QUESTION:
When can a net device get its setting correctly ?
Maybe dev_open() is not enough.

thanks
Weiping Pan
