From: Nitin Hande <nitin.hande@gmail.com>
Subject: Recv path on bonding driver question
Date: Wed, 24 Nov 2004 10:43:12 -0800
Message-ID: <78a6df57041124104367acffe0@mail.gmail.com>
Reply-To: Nitin Hande <nitin.hande@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello All,
 
 I am new to Linux networking code. I am trying to understand recv path
 of a packet after bonding. I have a regular peer ether interface
 connected over a switch. On one side I enslave one of the ether
 interface, so I get the following setup:
 
 bond0     Link encap:Ethernet  HWaddr 00:09:3D:00:3D:3B
           inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
           inet6 addr: fe80::200:ff:fe00:0/64 Scope:Link
           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
           RX packets:13783 errors:0 dropped:0 overruns:0 frame:0
           TX packets:757 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:1308089 (1.2 Mb)  TX bytes:76076 (74.2 Kb)
 
 eth1      Link encap:Ethernet  HWaddr 00:09:3D:00:3D:3B
           inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
           inet6 addr: fe80::209:3dff:fe00:3d3b/64 Scope:Link
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
           RX packets:13783 errors:0 dropped:0 overruns:0 frame:0
           TX packets:757 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1308089 (1.2 Mb)  TX bytes:76076 (74.2 Kb)
           Interrupt:26
 
 The other side remains a plain ether interface.
 Peer side:
 eth0      Link encap:Ethernet  HWaddr 00:09:3D:00:1D:5F
           inet addr:192.168.1.6  Bcast:192.168.1.255  Mask:255.255.255.0
           inet6 addr: fe80::209:3dff:fe00:1d5f/64 Scope:Link
           UP BROADCAST NOTRAILERS RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:569584 errors:0 dropped:0 overruns:0 frame:0
           TX packets:262048 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:46057796 (43.9 Mb)  TX bytes:29189722 (27.8 Mb)
           Interrupt:25
 
 While I ping from 192.168.1.6 to 192.168.1.1, ping works fine. Now, if I
 run tcpdump on eth1 interface, I only see the icmp replies getting out
 of interface.
 
 sins-stinger-04:/var/tmp/linux-2.6.9 # ping 192.168.1.1
 PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
 64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=1.07 ms
 64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.091 ms
 64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.095 ms
 64 bytes from 192.168.1.1: icmp_seq=4 ttl=64 time=0.085 ms
 64 bytes from 192.168.1.1: icmp_seq=5 ttl=64 time=0.083 ms
 
 --- 192.168.1.1 ping statistics ---
 5 packets transmitted, 5 received, 0% packet loss, time 4000ms
 rtt min/avg/max/mdev = 0.083/0.286/1.078/0.396 ms
 -------------
 sins-stinger-8:/var/tmp/linux-2.6.9/ # tcpdump -xv -i eth1 -n icmp
 tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96
 bytes
 15:04:31.433060 IP (tos 0x0, ttl  64, id 25225, offset 0, flags [none],
 length: 84) 192.168.1.1 > 192.168.1.6: icmp 64: echo reply seq 1
 			 4500 0054 6289 0000 4001 94c8 c0a8 0101
 			 c0a8 0106 0000 65b1 fd69 0001 2db4 a341
 			 0000 0000 011b 0c00 0000 0000 1011 1213
 			 1415 1617 1819 1a1b 1c1d 1e1f 2021 2223
 			 2425 2627 2829 2a2b 2c2d 2e2f 3031 3233
 			 3435
 15:04:32.432857 IP (tos 0x0, ttl  64, id 25226, offset 0, flags [none],
 length: 84) 192.168.1.1 > 192.168.1.6: icmp 64: echo reply seq 2
 			 4500 0054 628a 0000 4001 94c7 c0a8 0101
 			 c0a8 0106 0000 2bad fd69 0002 2eb4 a341
 			 0000 0000 3a1e 0c00 0000 0000 1011 1213
 			 1415 1617 1819 1a1b 1c1d 1e1f 2021 2223
 			 2425 2627 2829 2a2b 2c2d 2e2f 3031 3233
 			 3435
 15:04:33.432709 IP (tos 0x0, ttl  64, id 25227, offset 0, flags [none],
 length: 84) 192.168.1.1 > 192.168.1.6: icmp 64: echo reply seq 3
 			 4500 0054 628b 0000 4001 94c6 c0a8 0101
 			 c0a8 0106 0000 afac fd69 0003 2fb4 a341
 			 0000 0000 b51d 0c00 0000 0000 1011 1213
 			 1415 1617 1819 1a1b 1c1d 1e1f 2021 2223
 			 2425 2627 2829 2a2b 2c2d 2e2f 3031 3233
 
 My question is seems like netdev_set_master(??) makes some routing
 socket changes etc in the Linux kernel. How does that affect
 the receive path such that one cannot see the incoming icmp request on
 the actual interface after bonding ? And then why can one see the packet
 in the outgoing path? Any ideas ??
 
 Thanks in advance.
 Nitin
