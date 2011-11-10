From: Jiang Wang <Jiang.Wang@riverbed.com>
Subject: 82574 link speed problem
Date: Thu, 10 Nov 2011 21:45:39 +0000
Message-ID: <CEE05A0D7856E14880AD5560634EBEA82AA5C212@365EXCH-MBX-P5.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Prasanna Panchamukhi <Prasanna.Panchamukhi@riverbed.com>
To: "bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"jeffrey.e.pieper@intel.com" <jeffrey.e.pieper@intel.com>,
	"e1000-dev
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([208.70.196.44]:6085 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932444Ab1KJVzL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 16:55:11 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I found a link speed problem for 82574L NIC on a server machine. The NIC sometimes shows as 100Mbps and sometimes shows as 1Gbps when connected to the same switch with 1Gbps capability. Following are the details:

The NIC is set to use auto negotiation, and from the ethtool, I can see it supports and advertises all the 10, 100 and 1000 Mbps speeds. At the beginning, the link speed is 1Gbps, then I disable WOL (ethtool -s eth1 wol d). Next I run following script:

ifconfig ethx down
sleep y
ifconfig ethx up

When y is less than 10 seconds, the speed after up is 1Gbps. When y is more than 13 seconds, the speed becomes 100 Mbps. This is very reliable. I run the script many times and the link speed always depends on the sleep time. I read the link speed from both ethtool and dmesg, and I also verified the speed from the switch (Netgear FS726T). 

Following is ethtool output:
ethtool eth5
Settings for eth5:
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
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        MDI-X: off
        Supports Wake-on: pumbg
        Wake-on: d
        Current message level: 0x00000001 (1)
                               drv
        Link detected: yes


Following is from dmesg:

commands:
#if down
sleep 3
#if up

dmesg log below:

Nov 10 10:03:21 localhost avahi-daemon[3703]: Withdrawing address record for fe80::20e:b6ff:fe9a:f694 on eth5.
Nov 10 10:03:24 localhost kernel: ADDRCONF(NETDEV_UP): eth5: link is not ready
Nov 10 10:03:26 localhost kernel: e1000e: eth5 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
Nov 10 10:03:26 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
Nov 10 10:03:28 localhost avahi-daemon[3703]: New relevant interface eth5.IPv6 for mDNS.
Nov 10 10:03:28 localhost avahi-daemon[3703]: Joining mDNS multicast group on interface eth5.IPv6 with address fe80::20e:b6ff:fe9a:f694.
Nov 10 10:03:28 localhost avahi-daemon[3703]: Registering new address record for fe80::20e:b6ff:fe9a:f694 on eth5.
Nov 10 10:05:32 localhost avahi-daemon[3703]: Interface eth5.IPv6 no longer relevant for mDNS.
Nov 10 10:05:32 localhost avahi-daemon[3703]: Leaving mDNS multicast group on interface eth5.IPv6 with address fe80::20e:b6ff:fe9a:f694.


commands:
#if down
sleep 13
#if up

dmesg log below:

Nov 10 10:05:32 localhost avahi-daemon[3703]: Withdrawing address record for fe80::20e:b6ff:fe9a:f694 on eth5.
Nov 10 10:05:45 localhost kernel: ADDRCONF(NETDEV_UP): eth5: link is not ready
Nov 10 10:05:47 localhost kernel: e1000e: eth5 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
Nov 10 10:05:47 localhost kernel: e1000e 0000:04:00.0: eth5: 10/100 speed: disabling TSO
Nov 10 10:05:47 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
Nov 10 10:05:49 localhost avahi-daemon[3703]: New relevant interface eth5.IPv6 for mDNS.
Nov 10 10:05:49 localhost avahi-daemon[3703]: Joining mDNS multicast group on interface eth5.IPv6 with address fe80::20e:b6ff:fe9a:f694.

The kernel I am using is vanilla Linux 3.0.8 and the e1000e driver is 1.6.3-NAPI downloaded from sourceforge. I also tested with CentOS5.5 and Ubuntu 11.04, and the same problem exists.  In addition, I tried to connect to the different port on the switch, connect to another port on the same machine, and connect to a laptop. All showed the same problem.

If WOL is not disabled, there is no problem. But in my case, I need to disable WOL. When WOL is disabled, the PHY will be shutdown after ifconfig down. 

To debug, I print out the PHY_1000T_STATUS register in the e1000e_watchdog_task. When the speed is 1G, this register has some value like 0x2c00, 0x7c00, or 0x7800. It means the NIC detects the link partner has 1G capability.  When the speed becomes 100 M, the PHY_1000T_STATUS is always 0x4000. But the link party (the switch) doesn't change. Only difference is the sleep time between down/up the NIC. I also print out the E1000_POEMB (offset 0XF10), which is correct, 0x30d. 

Following is the log for ifdown, sleep3, ifup (this time, I used a different NIC):

Nov  9 10:51:31 localhost kernel: ====iterations is 1, interval is 0
Nov  9 10:51:31 localhost kernel: ret: 0, PHY_AUTONEG_ADV 0xde1
Nov  9 10:51:31 localhost kernel: ret: 0, PHY_LP_ABILITY 0xc5e1
Nov  9 10:51:31 localhost kernel: ret: 0, PHY_AUTONEG_EXP 0xf
Nov  9 10:51:31 localhost kernel: ret: 0, PHY_1000T_CTRL 0x200
Nov  9 10:51:31 localhost kernel: ret: 0, PHY_1000T_STATUS 0x4000
Nov  9 10:51:31 localhost kernel: ret: 0, PHY_EXT_STATUS 0x3000
Nov  9 10:51:31 localhost kernel: watchdog ret
Nov  9 10:51:32 localhost kernel: watchdog: start
Nov  9 10:51:32 localhost kernel: ====iterations is 1, interval is 0
Nov  9 10:51:32 localhost kernel: ret: 0, PHY_AUTONEG_ADV 0xde1
Nov  9 10:51:32 localhost kernel: ret: 0, PHY_LP_ABILITY 0xc5e1
Nov  9 10:51:32 localhost kernel: ret: 0, PHY_AUTONEG_EXP 0xf
Nov  9 10:51:32 localhost kernel: ret: 0, PHY_1000T_CTRL 0x200
Nov  9 10:51:32 localhost kernel: ret: 0, PHY_1000T_STATUS 0x2c00
Nov  9 10:51:32 localhost kernel: ret: 0, PHY_EXT_STATUS 0x3000
Nov  9 10:51:32 localhost kernel: e1000e: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
Nov  9 10:51:32 localhost kernel: watchdog ret
Nov  9 10:51:32 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
Nov  9 10:51:33 localhost avahi-daemon[3777]: New relevant interface eth6.IPv6 for mDNS.
Nov  9 10:51:33 localhost avahi-daemon[3777]: Joining mDNS multicast group on interface eth6.IPv6 with address fe80::21b:21ff:fec5:f92f.
Nov  9 10:51:33 localhost avahi-daemon[3777]: Registering new address record for fe80::21b:21ff:fec5:f92f on eth6.
Nov  9 10:51:34 localhost kernel: ====iterations is 1, interval is 0
Nov  9 10:51:34 localhost kernel: ret: 0, PHY_AUTONEG_ADV 0xde1


Following is the log for ifdown, sleep 13, ifup:

Nov  9 10:52:57 localhost kernel: ====iterations is 1, interval is 0
Nov  9 10:52:57 localhost kernel: ADDRCONF(NETDEV_UP): eth6: link is not ready
Nov  9 10:52:57 localhost kernel: ret: 0, PHY_AUTONEG_ADV 0xde1
Nov  9 10:52:57 localhost kernel: ret: 0, PHY_LP_ABILITY 0x0
Nov  9 10:52:57 localhost kernel: ret: 0, PHY_AUTONEG_EXP 0x4
Nov  9 10:52:57 localhost kernel: ret: 0, PHY_1000T_CTRL 0x200
Nov  9 10:52:57 localhost kernel: ret: 0, PHY_1000T_STATUS 0x0
Nov  9 10:52:57 localhost kernel: ret: 0, PHY_EXT_STATUS 0x3000
Nov  9 10:52:57 localhost kernel: watchdog ret
Nov  9 10:52:59 localhost kernel: watchdog: start
Nov  9 10:52:59 localhost kernel: ====iterations is 1, interval is 0
Nov  9 10:52:59 localhost kernel: ret: 0, PHY_AUTONEG_ADV 0xde1
Nov  9 10:52:59 localhost kernel: ret: 0, PHY_LP_ABILITY 0xc5e1
Nov  9 10:52:59 localhost kernel: ret: 0, PHY_AUTONEG_EXP 0xf
Nov  9 10:52:59 localhost kernel: ret: 0, PHY_1000T_CTRL 0x200
Nov  9 10:52:59 localhost kernel: ret: 0, PHY_1000T_STATUS 0x4000
Nov  9 10:52:59 localhost kernel: ret: 0, PHY_EXT_STATUS 0x3000
Nov  9 10:52:59 localhost kernel: e1000e: eth6 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
Nov  9 10:52:59 localhost kernel: e1000e 0000:04:00.0: eth6: 10/100 speed: disabling TSO
Nov  9 10:52:59 localhost kernel: watchdog ret
Nov  9 10:52:59 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
Nov  9 10:53:00 localhost avahi-daemon[3777]: New relevant interface eth6.IPv6 for mDNS.
Nov  9 10:53:00 localhost avahi-daemon[3777]: Joining mDNS multicast group on interface eth6.IPv6 with address fe80::21b:21ff:fec5:f92f.
Nov  9 10:53:00 localhost avahi-daemon[3777]: Registering new address record for fe80::21b:21ff:fec5:f92f on eth6.


Also, I tried to modify the auto negotiation and only advertise speed 1G, then the speed can stay in 1G even after sleeping for a long time.

I am not sure how to proceed to identify which component is wrong and how to solve this problem. Please give me some suggestions. I am happy to do more tests or try different patches. Thanks.

Regards,

Jiang


-------------------------------------
Jiang Wang
Member of Technical Staff
Riverbed Technology
Tel: (408) 522-5109
Email: Jiang.Wang@riverbed.com
www.riverbed.com
