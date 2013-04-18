From: Mark Jackson <mpfj-list@newflow.co.uk>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Thu, 18 Apr 2013 17:01:42 +0100
Message-ID: <517018E6.6080108@newflow.co.uk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <516B0098.4040809@mimc.co.uk> <516C33D2.4050105@ti.com> <516C38B9.50904@mimc.co.uk> <516C3A0D.70903@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercuryimc.plus.com ([80.229.200.144]:37679 "EHLO
	centos1.newflow.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932602Ab3DRQBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 12:01:44 -0400
In-Reply-To: <516C3A0D.70903@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/04/13 18:34, Mugunthan V N wrote:
> On 4/15/2013 10:58 PM, Mark Jackson wrote:
>> On 15/04/13 18:07, Mugunthan V N wrote:
>>> On 4/15/2013 12:46 AM, Mark Jackson wrote:
>>
>> <snip>
>>
>>>>
>>>> Notice that at the end, the nfs link appears to come back "ok", but
>>>> the "ps" command never completes.
>>>>
>>>> Any ideas of what's going on ?
>>>
>>> I have tried ping on both the interface fine. Will verify with ps again
>>> later in this week.
>>> Can you provide below details details
>>> - Are you using EVMsk or custom build EVM?
>>
>> This is a custom board (based on the BeagleBone design) with dual
>> Ethernet, NAND, NOR and FRAM.
>>
>> The dual emac thing is (one of) the last things to get signed off, so
>> I'm willing to assist in tracking this down.
> 
> After testing the scenario i may be able to send you an update later in
> this week.

I have made some progress ... I realised I was missing a (clearly rather
important !!) item in my .config file, namely CONFIG_TI_DAVINCI_EMAC.

I am now able to ping from our board to other systems on the network
(again, I've only tested eth0 at the moment).

However, I am unable to ping everything I should be able to !!

Here's my setup ...

# cat /etc/network/interfaces
# Configure Loopback
auto lo eth0 eth1
iface lo inet loopback
iface eth1 inet static
address 10.1.101.111
netmask 255.255.0.0
gateway 10.1.0.1
iface eth0 inet static
address 10.0.101.111
netmask 255.255.0.0
gateway 10.0.0.1

# ifconfig
eth0      Link encap:Ethernet  HWaddr C2:21:5E:B4:06:5E
          inet addr:10.0.101.111  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:67 errors:0 dropped:0 overruns:0 frame:0
          TX packets:62 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:8848 (8.6 KiB)  TX bytes:4290 (4.1 KiB)
          Interrupt:56

eth1      Link encap:Ethernet  HWaddr D6:2F:CF:39:22:4E
          inet addr:10.1.101.111  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:38 errors:0 dropped:0 overruns:0 frame:0
          TX packets:38 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:4022 (3.9 KiB)  TX bytes:4022 (3.9 KiB)

# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use
Iface
0.0.0.0         10.0.0.1        0.0.0.0         UG    0      0        0 eth0
10.0.0.0        0.0.0.0         255.255.0.0     U     0      0        0 eth0
10.1.0.0        0.0.0.0         255.255.0.0     U     0      0        0 eth1

I can ping a couple of units on 10.0.0.x ...

# ping 10.0.0.120
PING 10.0.0.120 (10.0.0.120): 56 data bytes
64 bytes from 10.0.0.120: seq=0 ttl=64 time=0.955 ms
64 bytes from 10.0.0.120: seq=1 ttl=64 time=0.676 ms
64 bytes from 10.0.0.120: seq=2 ttl=64 time=0.732 ms
64 bytes from 10.0.0.120: seq=3 ttl=64 time=0.762 ms

--- 10.0.0.120 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.676/0.781/0.955 ms
# ping 10.0.0.5
PING 10.0.0.5 (10.0.0.5): 56 data bytes
64 bytes from 10.0.0.5: seq=0 ttl=64 time=1.815 ms
64 bytes from 10.0.0.5: seq=1 ttl=64 time=0.458 ms
64 bytes from 10.0.0.5: seq=2 ttl=64 time=0.474 ms
64 bytes from 10.0.0.5: seq=3 ttl=64 time=0.345 ms
64 bytes from 10.0.0.5: seq=4 ttl=64 time=0.329 ms

--- 10.0.0.5 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.329/0.684/1.815 ms

But *not* my router on the same subnet ...

# ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1): 56 data bytes

--- 10.0.0.1 ping statistics ---
15 packets transmitted, 0 packets received, 100% packet loss

I am also unable to ping other equipment that exists:-

# ping 10.0.101.2
PING 10.0.101.2 (10.0.101.2): 56 data bytes

--- 10.0.101.2 ping statistics ---
6 packets transmitted, 0 packets received, 100% packet loss

# ping 10.0.200.2
PING 10.0.200.2 (10.0.200.2): 56 data bytes

--- 10.0.200.2 ping statistics ---
5 packets transmitted, 0 packets received, 100% packet loss

Just to prove these other item do exist, here's me pinging them from
another Linux VM (working off the same physical switch):-

mpfj@mpfj-nanobone:~/linux/linux-2.6$ ifconfig
eth0      Link encap:Ethernet  HWaddr 08:00:27:1e:0d:f5
          inet addr:10.0.0.120  Bcast:10.0.255.255  Mask:255.255.0.0
          inet6 addr: fe80::a00:27ff:fe1e:df5/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:135935 errors:0 dropped:0 overruns:0 frame:0
          TX packets:172692 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:109340858 (109.3 MB)  TX bytes:177519151 (177.5 MB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:3771 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3771 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:294818 (294.8 KB)  TX bytes:294818 (294.8 KB)

mpfj@mpfj-nanobone:~/linux/linux-2.6$ ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_req=1 ttl=255 time=0.453 ms
64 bytes from 10.0.0.1: icmp_req=2 ttl=255 time=0.445 ms
64 bytes from 10.0.0.1: icmp_req=3 ttl=255 time=0.488 ms
64 bytes from 10.0.0.1: icmp_req=4 ttl=255 time=0.471 ms
64 bytes from 10.0.0.1: icmp_req=5 ttl=255 time=0.460 ms
^C
--- 10.0.0.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 3998ms
rtt min/avg/max/mdev = 0.445/0.463/0.488/0.024 ms
mpfj@mpfj-nanobone:~/linux/linux-2.6$ ping 10.0.200.2
PING 10.0.200.2 (10.0.200.2) 56(84) bytes of data.
64 bytes from 10.0.200.2: icmp_req=1 ttl=64 time=2.09 ms
64 bytes from 10.0.200.2: icmp_req=2 ttl=64 time=1.17 ms
64 bytes from 10.0.200.2: icmp_req=3 ttl=64 time=0.994 ms
64 bytes from 10.0.200.2: icmp_req=4 ttl=64 time=0.920 ms
^C
--- 10.0.200.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 0.920/1.296/2.095/0.471 ms
mpfj@mpfj-nanobone:~/linux/linux-2.6$ ping 10.0.101.2
PING 10.0.101.2 (10.0.101.2) 56(84) bytes of data.
64 bytes from 10.0.101.2: icmp_req=1 ttl=64 time=1.48 ms
64 bytes from 10.0.101.2: icmp_req=2 ttl=64 time=0.939 ms
64 bytes from 10.0.101.2: icmp_req=3 ttl=64 time=0.946 ms
64 bytes from 10.0.101.2: icmp_req=4 ttl=64 time=1.04 ms
^C
--- 10.0.101.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 0.939/1.104/1.483/0.223 ms

When the pings fail, I am unable to see *any* activity on the network
(using wireshark).

Is there anything else I should try ?

Cheers
Mark J.
