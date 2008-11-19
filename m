From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6
Date: Wed, 19 Nov 2008 11:01:30 +0100
Message-ID: <4923E3FA.7010402@krogh.cc>
References: <491FEAD5.4090205@krogh.cc> <17663.1226965523@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:59851 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbYKSKBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 05:01:42 -0500
In-Reply-To: <17663.1226965523@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This time answered with a configuration, that I have tested that works 
on 2.6.26.8. The setup is designed to run under dhcp. (small HPC-cluster).

Jay Vosburgh wrote:
> Jesper Krogh <jesper@krogh.cc> wrote:
> 
>> I have something that looks like a regression in bonding between 2.6.26.8
>> and 2.6.27.6 (I'll try the mid-steps later).
>>
>> Setup: LACP bond(mode=4,mmimon=100) with 3 NIC's and dhcp on top (static
>> ip didn't work either).
>>
>> Problem: The bond doesn't get up after bootup. Subsequence ifdown/ifup
>> brings it up.
> 
> 	What exactly does "doesn't get up" mean? 

I cant push any traffic through it.

> If you configure with
> a static IP, and it doesn't come up, what's in /proc/net/bonding/bond0?

# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008) 

 

Bonding Mode: IEEE 802.3ad Dynamic link aggregation 

Transmit Hash Policy: layer2 (0) 

MII Status: up 

MII Polling Interval (ms): 100 

Up Delay (ms): 0 

Down Delay (ms): 0 

 

802.3ad info 

LACP rate: slow 

Active Aggregator Info: 

         Aggregator ID: 1 

         Number of ports: 2 

         Actor Key: 17
         Partner Key: 3008
         Partner Mac Address: 02:04:96:34:88:6a

Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:1e:68:57:82:b2
Aggregator ID: 1

Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:1e:68:57:82:b3
Aggregator ID: 1

Slave Interface: eth2
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:1e:68:57:82:b0
Aggregator ID: 2

# ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:1e:68:57:82:b2
           inet addr:10.194.132.90  Bcast:10.194.133.255  Mask:255.255.254.0
           inet6 addr: fe80::21e:68ff:fe57:82b2/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:5241 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1314 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:382392 (373.4 KB)  TX bytes:126272 (123.3 KB)



doing ifdown bond0 && ifup bond0 brings it correctly up.

root@quad11:~# ping -c 1 -w 5 -W 5 sal
ping: unknown host sal
root@quad11:~# ifdown bond0 && ifup bond0
root@quad11:~# ping -c 1 -w 5 -W 5 sal
PING sal (10.194.133.13) 56(84) bytes of data.
64 bytes from sal (10.194.133.13): icmp_seq=1 ttl=64 time=0.106 ms

--- sal ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.106/0.106/0.106/0.000 ms
root@quad11:~#

 > When it's broken, does it stay broken if you wait a minute or two?

No. It newer comes up.

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
> That wouldn't necessarily cause DHCP to fail; 802.3ad is allowed to
> aggregate eth0 and eth1 and use them independently of eth2.
 >
> 	However, if eth0 and eth1 are incorrectly asserting carrier up
> (before autoneg is complete), then that could cause problems.  If that's
> the case, then checking /proc/net/bonding/bond0 should show the actual
> aggregation status.  If lacp is set to slow (the default), then it
> should try to reaggregate 30 seconds later, and that would clear up the
> aggregation.  DHCP would still need to restart, though.
> 	What distro are you using?  I just tried the bonding driver from
> the current net-next-2.6 mainline on recent SuSE and 802.3ad + DHCP
> works fine for me.  I'm using BCM 5704s (tg3).

>> The setup is a 3 NIC bond on a Sun X2200 dual-cpu Quad-core server.
>> I have similar bond on a X4600 where they works with 2.6.27.6 so I suspect
>> that the difference is that the X4600 has all NIC's from the
>> same vendor where as the X2200 has 2 Broadcom NIC's and 2 NVidia nics.
> 
> 	Which flavor (Broadcom or Nvidia) are the 3 devices that are the
> same?

The three NICS are mixed. 2 forcedeth Nvidia(eth0,eth1) and one Tigon3 
(Broadcom) (eth2).

-- 
Jesper
