From: Ben Greear <greearb@candelatech.com>
Subject: Routing issue in a strange configuration.
Date: Mon, 16 Jun 2003 12:10:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE1609.1020809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



I have a machine with eth1 IP 10.3.1.4 and eth2 with 10.3.2.4

I am using source-based routing, and have the eth1 & 2 ports connected
to another machine which is acting as a route (the other machine has 10.3.1.1 and 10.3.2.1
IP addresses).

I run ping with the -I option to bind it to eth1, but instead of sending
the arp and/or ICMP request to the gateway, it instead arps for the IP on
eth2.

The machines are running RedHat 9, and the problem exists in the
default 2.4.20-8 kernel.  I have not tried other kernels yet, so if you
think this is a RedHat only issue, I can try the stock kernel.


Here is the output from the machine that is attempting to send the traffic:

[root@localhost root]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:03:47:2B:39:CA
           inet addr:192.168.1.22  Bcast:192.168.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1362 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1345 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:100
           RX bytes:80208 (78.3 Kb)  TX bytes:1705206 (1.6 Mb)
           Interrupt:11 Base address:0xdf00 Memory:feafe000-feafe038

eth1      Link encap:Ethernet  HWaddr 00:03:47:2B:39:CB
           inet addr:10.3.1.4  Bcast:10.3.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:8 errors:0 dropped:0 overruns:0 frame:0
           TX packets:377 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:400
           RX bytes:596 (596.0 b)  TX bytes:16338 (15.9 Kb)
           Interrupt:11 Base address:0xde80 Memory:feafd000-feafd038

eth2      Link encap:Ethernet  HWaddr 00:50:C2:11:32:64
           inet addr:10.3.2.4  Bcast:10.3.2.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:3 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:100
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:11 Base address:0xbc00

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:1418 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1418 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:1938073 (1.8 Mb)  TX bytes:1938073 (1.8 Mb)


[root@localhost root]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
10.3.1.0        0.0.0.0         255.255.255.0   U     0      0        0 eth1
10.3.2.0        0.0.0.0         255.255.255.0   U     0      0        0 eth2
169.254.0.0     0.0.0.0         255.255.0.0     U     0      0        0 eth0
127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 lo
0.0.0.0         192.168.1.5     0.0.0.0         UG    0      0        0 eth0

[root@localhost root]# ip ru
0:      from all lookup local
32758:  from 10.3.2.4 lookup 2
32759:  from 10.3.1.4 lookup 1
32766:  from all lookup main
32767:  from all lookup 253

[root@localhost root]# ip route show table 1
10.3.1.0/24 via 10.3.1.4 dev eth1
default via 10.3.1.1 dev eth1
[root@localhost root]# ip route show table 2
10.3.2.0/24 via 10.3.2.4 dev eth2
default via 10.3.2.1 dev eth2


[root@localhost root]# ping -I eth1 10.3.1.1
PING 10.3.1.1 (10.3.1.1) from 10.3.1.4 eth1: 56(84) bytes of data.
64 bytes from 10.3.1.1: icmp_seq=1 ttl=64 time=0.167 ms
64 bytes from 10.3.1.1: icmp_seq=2 ttl=64 time=0.087 ms

#  The other interface on the router machine (same machine as I just pinged above)
[root@localhost root]# ping -I eth1 10.3.2.1
PING 10.3.2.1 (10.3.2.1) from 10.3.1.4 eth1: 56(84) bytes of data.
 From 10.3.1.4 icmp_seq=1 Destination Host Unreachable
 From 10.3.1.4 icmp_seq=3 Destination Host Unreachable

#  It is NOT using the default gateway for this traffic, but is instead
#  just trying to ARP.
[root@localhost root]# tcpdump -n -i eth1
tcpdump: listening on eth1
11:56:19.788336 arp who-has 10.3.2.1 tell 10.3.1.4
11:56:20.788134 arp who-has 10.3.2.1 tell 10.3.1.4
11:56:21.788149 arp who-has 10.3.2.1 tell 10.3.1.4
11:56:22.788379 arp who-has 10.3.2.1 tell 10.3.1.4




-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
