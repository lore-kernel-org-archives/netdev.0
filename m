From: Ben Greear <greearb@candelatech.com>
Subject: Re: ip rule and/or route problem in 2.6.37-rc5+
Date: Thu, 09 Dec 2010 22:19:06 -0800
Message-ID: <4D01C65A.6090200@candelatech.com>
References: <4D017D0D.50907@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46797 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab0LJGTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 01:19:15 -0500
In-Reply-To: <4D017D0D.50907@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2010 05:06 PM, Ben Greear wrote:
>
> This problem appears to have happened between 2.6.36.1 and 2.6.37-rc2.
> We haven't fully bisected the problem yet.
>
>
> The basic test:
>
> * one normal interface using DHCP
> * A second interface specified to use it's own routing table.
> * 'ip rules' to determine behaviour.
>
> After running these commands abelow, the system can no longer
> route out it's normal interface. It appears that the final line
> is the one that messes things up. If you flush table 10001 after
> that, things start working again.
>
> The 'pref 20' rule is also important. It should not have
> any affect on this ping, but it appears that it does, somehow.
> If you remove it, the problem also goes away, regardless of
> the routes in table 10001.
>
>
> ip rule add pref 512 lookup local
> ip rule del pref 0 lookup local
> ip link set eth2 up
> ip -4 addr add 172.16.0.102/24 broadcast 172.16.0.255 dev eth2
> ip rule add to 172.16.0.102 iif eth2 lookup local pref 10
> ip rule add iif eth2 lookup 10001 pref 20
> ip route add 172.16.0.0/24 dev eth2 table 10001
> ip route add unreachable 0/0 table 10001

Seems this is the commit that broke this behaviour:

4465b469008bc03b98a1b8df4e9ae501b6c69d4b is first bad commit
commit 4465b469008bc03b98a1b8df4e9ae501b6c69d4b
Author: Tom Herbert <therbert@google.com>
Date:   Sun May 23 19:54:12 2010 +0000

     ipv4: Allow configuring subnets as local addresses

     This patch allows a host to be configured to respond to any address in
     a specified range as if it were local, without actually needing to
     configure the address on an interface.  This is done through routing
     table configuration.  For instance, to configure a host to respond
     to any address in 10.1/16 received on eth0 as a local address we can do:

     ip rule add from all iif eth0 lookup 200
     ip route add local 10.1/16 dev lo proto kernel scope host src 127.0.0.1 table 200

     This host is now reachable by any 10.1/16 address (route lookup on
     input for packets received on eth0 can find the route).  On output, the
     rule will not be matched so that this host can still send packets to
     10.1/16 (not sent on loopback).  Presumably, external routing can be
     configured to make sense out of this.

     To make this work, we needed to modify the logic in finding the
     interface which is assigned a given source address for output
     (dev_ip_find).  We perform a normal fib_lookup instead of just a
     lookup on the local table, and in the lookup we ignore the input
     interface for matching.

     This patch is useful to implement IP-anycast for subnets of virtual
     addresses.

     Signed-off-by: Tom Herbert <therbert@google.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>


>
>
>
>
> [root@ct503-60 ~]# ping 192.168.100.1
> PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
> 64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.257 ms
> 64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.285 ms
> 
> --- 192.168.100.1 ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 1290ms
> rtt min/avg/max/mdev = 0.257/0.271/0.285/0.014 ms
> [root@ct503-60 ~]# ifconfig
> eth0 Link encap:Ethernet HWaddr 00:30:48:DA:60:1C
> inet addr:192.168.100.173 Bcast:192.168.100.255 Mask:255.255.255.0
> inet6 addr: fe80::230:48ff:feda:601c/64 Scope:Link
> UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
> RX packets:99 errors:0 dropped:0 overruns:0 frame:0
> TX packets:97 errors:0 dropped:0 overruns:0 carrier:0
> collisions:0 txqueuelen:1000
> RX bytes:10562 (10.3 KiB) TX bytes:9634 (9.4 KiB)
> Memory:fa7e0000-fa800000
>
> lo Link encap:Local Loopback
> inet addr:127.0.0.1 Mask:255.0.0.0
> inet6 addr: ::1/128 Scope:Host
> UP LOOPBACK RUNNING MTU:16436 Metric:1
> RX packets:54 errors:0 dropped:0 overruns:0 frame:0
> TX packets:54 errors:0 dropped:0 overruns:0 carrier:0
> collisions:0 txqueuelen:0
> RX bytes:5280 (5.1 KiB) TX bytes:5280 (5.1 KiB)
>
> [root@ct503-60 ~]# ip rule add pref 512 lookup local
> local[root@ct503-60 ~]# ip rule del pref 0 lookup local
> [root@ct503-60 ~]# ping 192.168.100.1
> PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
> 64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.266 ms
> 64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.238 ms
> 
> --- 192.168.100.1 ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 1101ms
> rtt min/avg/max/mdev = 0.238/0.252/0.266/0.014 ms
> [root@ct503-60 ~]# ip link set eth2 up
> adcast 172.16.0.255 dev eth2Dec 10 11:50:01 localhost kernel: e1000e 0000:08:00.0: irq 49 for MSI/MSI-X
> Dec 10 11:50:01 localhost kernel: e1000e 0000:08:00.0: irq 49 for MSI/MSI-X
> Dec 10 11:50:01 localhost kernel: ADDRCONF(NETDEV_UP): eth2: link is not ready
> 2root@ct503-60 ~]# ping 192.168.100.1
> PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
> 64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.247 ms
> Dec 10 11:50:04 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
> Dec 10 11:50:04 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
> 64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.271 ms
> 64 bytes from 192.168.100.1: icmp_seq=3 ttl=64 time=0.263 ms
> 
> --- 192.168.100.1 ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 2317ms
> rtt min/avg/max/mdev = 0.247/0.260/0.271/0.016 ms
> [root@ct503-60 ~]# ip rule add to 172.16.0.102 iif eth2 lookup local pref 10
> 001 pref 20[root@ct503-60 ~]# ip rule add iif eth2 lookup 10001 pref 20
> [root@ct503-60 ~]# ping 192.168.100.1
> PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
> 64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.346 ms
> Dec 10 11:50:14 localhost kernel: eth2: no IPv6 routers present
> 64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.251 ms
> 
> --- 192.168.100.1 ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 1245ms
> rtt min/avg/max/mdev = 0.251/0.298/0.346/0.050 ms
> [root@ct503-60 ~]# ip route add 172.16.0.0/24 dev eth2 table 10001
> 10001[root@ct503-60 ~]# ip route add unreachable 0/0 table 10001
> [root@ct503-60 ~]# ping 192.168.100.1
> connect: Invalid argument
> [root@ct503-60 ~]# ip route show
> 192.168.100.0/24 dev eth0 proto kernel scope link src 192.168.100.173
> 172.16.0.0/24 dev eth2 proto kernel scope link src 172.16.0.102
> 169.254.0.0/16 dev eth0 scope link metric 1003
> default via 192.168.100.1 dev eth0
> You have new mail in /var/spool/mail/root
> [root@ct503-60 ~]# ip route show table 10001
> 172.16.0.0/24 dev eth2 scope link
> unreachable default
> [root@ct503-60 ~]#
>
> [root@ct503-60 ~]# ip route flush table 10001
> [root@ct503-60 ~]# ping 192.168.100.1
> PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
> 64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=4.10 ms
> 64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.260 ms
> 
> --- 192.168.100.1 ping statistics ---
> 2 packets transmitted, 2 received, 0% packet loss, time 1300ms
> rtt min/avg/max/mdev = 0.260/2.181/4.102/1.921 ms
> [root@ct503-60 ~]#
>
>
> Thanks,
> Ben
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
