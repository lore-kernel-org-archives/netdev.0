From: Feng Tang <feng.tang@intel.com>
Subject: Re: TCP_STREAM performance regression on commit b3613118
Date: Tue, 6 Mar 2012 16:11:17 +0800
Message-ID: <20120306081117.GA17375@feng-i7>
References: <1329472239.2861.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120217.133327.1178765872497293871.davem@davemloft.net>
 <1330656317.21053.1411.camel@debian>
 <20120301.220743.2174015405223036036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alex.shi@intel.com, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, tim.c.chen@intel.com,
	ying.huang@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120301.220743.2174015405223036036.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2012 at 10:07:43PM -0500, David Miller wrote:
> From: Alex Shi <alex.shi@intel.com>
> Date: Fri, 02 Mar 2012 10:45:17 +0800
> 
> > Add CC to tang feng, He is working on this issue. 
> 
> Is he?  I'm pretty sure this is due to the TCP receive window growing
> issue Eric Dumazet, Neal Cardwell and I are discussing in the thread
> starting at:
> 
> http://marc.info/?l=linux-netdev&m=132916352815286&w=2

Yes, probably, as we did find some clue related with the tcp_r/wmem.

Here is the regression we found:
On some machines, we found there is about 10% resgression of netperf
TCP-64K loopback test between 3.2 and 3.3-rc1. The exact test is:
./netperf -t TCP_STREAM -l 60 -H 127.0.0.1 -i 50,3 -I 99,5 -- -s 32768 -S 32768 -m 4096


The test machine is a 2 socket Quad Core Core 2 Duo server(2.66GHz) with
8 GB RAM. Following are the debug info (ifconfig/netstat -s/tcp_rwmem)
before and after the test: 

The most obvious differences I can see are:
1) 311 GB vs 241 GB from ifconfig
2) the difference of the tcp_r/wmem

Thanks,
Feng

----------------------------------------------------------
Before the test (v3.2)
===========================
ifconfig info
eth1      Link encap:Ethernet  HWaddr 00:30:48:7C:CF:72  
          inet addr:192.168.1.58  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::230:48ff:fe7c:cf72/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:947 errors:0 dropped:0 overruns:0 frame:0
          TX packets:253 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:76573 (74.7 KiB)  TX bytes:31034 (30.3 KiB)
          Memory:d8420000-d8440000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:197 errors:0 dropped:0 overruns:0 frame:0
          TX packets:197 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:21827 (21.3 KiB)  TX bytes:21827 (21.3 KiB)

netstat info
Ip:
    593 total packets received
    3 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    590 incoming packets delivered
    431 requests sent out
Icmp:
    7 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 7
    7 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 7
IcmpMsg:
        InType3: 7
        OutType3: 7
Tcp:
    7 active connections openings
    10 passive connection openings
    0 failed connection attempts
    0 connection resets received
    3 connections established
    371 segments received
    328 segments send out
    0 segments retransmited
    0 bad segments received.
    3 resets sent
Udp:
    87 packets received
    7 packets to unknown port received.
    0 packet receive errors
    94 packets sent
UdpLite:
tcp_rmem
4096	87380	4194304
tcp_wmem
4096	16384	4194304
=========================


After the test (v3.2)
===========================
ifconfig info
eth1      Link encap:Ethernet  HWaddr 00:30:48:7C:CF:72  
          inet addr:192.168.1.58  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::230:48ff:fe7c:cf72/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2278 errors:0 dropped:0 overruns:0 frame:0
          TX packets:690 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:174366 (170.2 KiB)  TX bytes:88711 (86.6 KiB)
          Memory:d8420000-d8440000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:54845546 errors:0 dropped:0 overruns:0 frame:0
          TX packets:54845546 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:334960558399 (311.9 GiB)  TX bytes:334960558399 (311.9 GiB)

netstat info
Ip:
    54846593 total packets received
    3 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    54846590 incoming packets delivered
    54846212 requests sent out
Icmp:
    7 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 7
    7 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 7
IcmpMsg:
        InType3: 7
        OutType3: 7
Tcp:
    21 active connections openings
    22 passive connection openings
    0 failed connection attempts
    0 connection resets received
    3 connections established
    54846182 segments received
    54846067 segments send out
    0 segments retransmited
    0 bad segments received.
    3 resets sent
Udp:
    126 packets received
    7 packets to unknown port received.
    0 packet receive errors
    134 packets sent
UdpLite:
tcp_rmem
4096	87380	4194304
tcp_wmem
4096	16384	4194304
=========================



Before the test (v3.3-rc1)
===========================
ifconfig info
eth1      Link encap:Ethernet  HWaddr 00:30:48:7C:CF:72  
          inet addr:192.168.1.58  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::230:48ff:fe7c:cf72/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:576 errors:0 dropped:0 overruns:0 frame:0
          TX packets:205 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:50045 (48.8 KiB)  TX bytes:27018 (26.3 KiB)
          Memory:d8420000-d8440000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:88 errors:0 dropped:0 overruns:0 frame:0
          TX packets:88 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:9613 (9.3 KiB)  TX bytes:9613 (9.3 KiB)

netstat info
Ip:
    365 total packets received
    3 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    362 incoming packets delivered
    278 requests sent out
Icmp:
    3 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 3
    3 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 3
IcmpMsg:
        InType3: 3
        OutType3: 3
Tcp:
    3 active connections openings
    6 passive connection openings
    0 failed connection attempts
    0 connection resets received
    3 connections established
    226 segments received
    206 segments send out
    0 segments retransmited
    0 bad segments received.
    3 resets sent
Udp:
    64 packets received
    3 packets to unknown port received.
    0 packet receive errors
    67 packets sent
UdpLite:
tcp_rmem
4096	87380	87380
tcp_wmem
4096	16384	65536
=========================


After the test (v3.3-rc1)
===========================
ifconfig info
eth1      Link encap:Ethernet  HWaddr 00:30:48:7C:CF:72  
          inet addr:192.168.1.58  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::230:48ff:fe7c:cf72/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1724 errors:0 dropped:0 overruns:0 frame:0
          TX packets:608 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:134666 (131.5 KiB)  TX bytes:79003 (77.1 KiB)
          Memory:d8420000-d8440000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:45143339 errors:0 dropped:0 overruns:0 frame:0
          TX packets:45143339 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:259440765641 (241.6 GiB)  TX bytes:259440765641 (241.6 GiB)

netstat info
Ip:
    45144169 total packets received
    3 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    45144166 incoming packets delivered
    45143928 requests sent out
Icmp:
    3 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 3
    3 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 3
IcmpMsg:
        InType3: 3
        OutType3: 3
Tcp:
    16 active connections openings
    17 passive connection openings
    0 failed connection attempts
    0 connection resets received
    3 connections established
    45143859 segments received
    45143814 segments send out
    0 segments retransmited
    0 bad segments received.
    3 resets sent
Udp:
    103 packets received
    3 packets to unknown port received.
    0 packet receive errors
    107 packets sent
UdpLite:
tcp_rmem
4096	87380	87380
tcp_wmem
4096	16384	65536
=========================
