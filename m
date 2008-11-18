From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6
Date: Tue, 18 Nov 2008 21:24:41 +0100
Message-ID: <49232489.4000504@krogh.cc>
References: <491FEAD5.4090205@krogh.cc> <17663.1226965523@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:45075 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465AbYKRUYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 15:24:39 -0500
In-Reply-To: <17663.1226965523@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Jesper Krogh <jesper@krogh.cc> wrote:
> 
>> I have something that looks like a regression in bonding between 2.6.26.8
>> and 2.6.27.6 (I'll try the mid-steps later).

There was something about that rc-27 could ruin my Intel NICs.. right? 
(I'll refrain from testing with those then).

>> Setup: LACP bond(mode=4,mmimon=100) with 3 NIC's and dhcp on top (static
>> ip didn't work either).
>>
>> Problem: The bond doesn't get up after bootup. Subsequence ifdown/ifup
>> brings it up.
> 
> 	What exactly does "doesn't get up" mean? 

Looks like this:
# ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:1e:68:57:82:b2
           inet6 addr: fe80::21e:68ff:fe57:82b2/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:74 errors:0 dropped:0 overruns:0 frame:0
           TX packets:17 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:5952 (5.8 KB)  TX bytes:1900 (1.8 KB)

(usually this would have been assigned an ip-address using dhcp, does 
that with 2.6.26.8, with the same configuration). Manually running 
dhclient on the interface doesn't bring it up either.

# dhclient bond0
Internet Systems Consortium DHCP Client V3.0.6
Copyright 2004-2007 Internet Systems Consortium.
All rights reserved.
For info, please visit http://www.isc.org/sw/dhcp/

Listening on LPF/bond0/00:1e:68:57:82:b2
Sending on   LPF/bond0/00:1e:68:57:82:b2
Sending on   Socket/fallback
DHCPDISCOVER on bond0 to 255.255.255.255 port 67 interval 6
DHCPDISCOVER on bond0 to 255.255.255.255 port 67 interval 14
DHCPDISCOVER on bond0 to 255.255.255.255 port 67 interval 9
DHCPDISCOVER on bond0 to 255.255.255.255 port 67 interval 2
No DHCPOFFERS received.
No working leases in persistent database - sleeping.

Booting up with static ip configuration it looks like this:

# ifconfig
bond0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00 

           inet addr:10.194.132.90  Bcast:10.194.133.255 
Mask:255.255.254.0
           UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1 

           RX packets:0 errors:0 dropped:0 overruns:0 frame:0 

           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0 

           collisions:0 txqueuelen:0 

           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

Apparently correct, but absolutely no traffic can go through the interface.

> If you configure with
> a static IP, and it doesn't come up, what's in /proc/net/bonding/bond0?

Configured with a static ip. ifconfig claims that the interface is up 
and configured with the ip-address.

# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: down
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
bond bond0 has no active aggregator

# ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00
           inet addr:10.194.132.90  Bcast:10.194.133.255  Mask:255.255.254.0
           UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


> When it's broken, does it stay broken if you wait a minute or two?

It remains broken.

>> I suspect it it timing related. The interface being configured before it's
>> ready:
>> root@quad01:~# dmesg | egrep '(dhc|bond)'
>> [   12.421963] bonding: MII link monitoring set to 100 ms
>> [   12.483370] bonding: bond0: enslaving eth0 as a backup interface with
>> an up link.
>> [   12.523372] bonding: bond0: enslaving eth1 as a backup interface with
>> an up link.
>> [   12.611731] bonding: bond0: enslaving eth2 as a backup interface with a
>> down link.
>> [   12.780816] warning: `dhclient3' uses 32-bit capabilities (legacy
>> support in use)
>> [   15.720491] bonding: bond0: link status definitely up for interface eth2.
>> [   87.800324] bond0: no IPv6 routers present
> 
> 	This looks like one of the slaves (eth2) took longer to assert
> carrier up (slower autoneg, perhaps) than the other two (eth0 and eth1).

no, that part is identical to the working kernel (2.6.26.8).

> That wouldn't necessarily cause DHCP to fail; 802.3ad is allowed to
> aggregate eth0 and eth1 and use them independently of eth2.
> 
> 	However, if eth0 and eth1 are incorrectly asserting carrier up
> (before autoneg is complete), then that could cause problems.  If that's
> the case, then checking /proc/net/bonding/bond0 should show the actual
> aggregation status.  If lacp is set to slow (the default), then it
> should try to reaggregate 30 seconds later, and that would clear up the
> aggregation.  DHCP would still need to restart, though.

it is set to "slow", but it doesn't come up 30 seconds later either.

> 	What distro are you using?  I just tried the bonding driver from
> the current net-next-2.6 mainline on recent SuSE and 802.3ad + DHCP
> works fine for me.  I'm using BCM 5704s (tg3).

Ubuntu Hardy (8.10)

>> The setup is a 3 NIC bond on a Sun X2200 dual-cpu Quad-core server.
>> I have similar bond on a X4600 where they works with 2.6.27.6 so I suspect
>> that the difference is that the X4600 has all NIC's from the
>> same vendor where as the X2200 has 2 Broadcom NIC's and 2 NVidia nics.
> 
> 	Which flavor (Broadcom or Nvidia) are the 3 devices that are the
> same?

# dmesg |grep eth
[    4.660852] forcedeth: Reverse Engineered nForce ethernet driver. 
Version 0.61.
[    4.661236] forcedeth 0000:00:08.0: PCI INT A -> Link[LMAC] -> GSI 23 
(level, low) -> IRQ 23
[    4.661240] forcedeth 0000:00:08.0: setting latency timer to 64
[    5.180512] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 2, 
addr 00:1e:68:57:82:b2
[    5.180516] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt 
timirq gbit lnktim msi desc-v3
[    5.180925] forcedeth 0000:00:09.0: PCI INT A -> Link[LMAD] -> GSI 22 
(level, low) -> IRQ 22
[    5.180929] forcedeth 0000:00:09.0: setting latency timer to 64
[    5.700460] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @ 3, 
addr 00:1e:68:57:82:b3
[    5.700463] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt 
timirq gbit lnktim msi desc-v3
[    7.844263] eth2: Tigon3 [partno(BCM95715) rev 9003 PHY(5714)] 
(PCIX:133MHz:64-bit) 10/100/1000Base-T Ethernet 00:1e:68:57:82:b0
[    7.844266] eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] 
WireSpeed[1] TSOcap[1]
[    7.844268] eth2: dma_rwctrl[76148000] dma_mask[40-bit]
[    7.864612] eth3: Tigon3 [partno(BCM95715) rev 9003 PHY(5714)] 
(PCIX:133MHz:64-bit) 10/100/1000Base-T Ethernet 00:1e:68:57:82:b1
[    7.864615] eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] 
WireSpeed[1] TSOcap[1]
[    7.864617] eth3: dma_rwctrl[76148000] dma_mask[40-bit]
[    7.870445] Driver 'sd' needs updating - please use bus_type methods


I'm doing a bond of eth0, eth1 and eth2

-- 
Jesper Krogh
