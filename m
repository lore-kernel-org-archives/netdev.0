From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Mon, 08 May 2006 10:28:32 +0200
Message-ID: <BAY103-F1D9D892CDA10889FCB525B2A80@phx.gbl>
References: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f1.bay103.hotmail.com ([65.54.174.11]:49038 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S932183AbWEHI2h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 04:28:37 -0400
In-Reply-To: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>However, the fact that the tcpdump causes more chunky packets to
>make it through could be an indication that there is a bug somewhere
>in our NAT/IPsec code or at least a suboptimal memory allocation
>strategy that's somehow avoided when AF_PACKET pins the skb down.

Ciao Herbert,

I have discovered another tricky behaviour. Take a look:

root@Mimosa:~# ping 10.49.59.23
PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.
64 bytes from 10.49.59.23: icmp_seq=1 ttl=247 time=91.9 ms
64 bytes from 10.49.59.23: icmp_seq=2 ttl=247 time=49.3 ms
64 bytes from 10.49.59.23: icmp_seq=3 ttl=247 time=106 ms
64 bytes from 10.49.59.23: icmp_seq=4 ttl=247 time=74.3 ms

--- 10.49.59.23 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2998ms
rtt min/avg/max/mdev = 49.316/80.460/106.257/21.241 ms
root@Mimosa:~# cd /tmp/
root@Mimosa:/tmp# tcpdump -v -p -n ip host 10.49.59.23 > 
/tmp/NULL-10.49.59.23 &
[1] 18981
root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB (Ethernet), 
capture size 96 bytes

root@Mimosa:/tmp# ping 10.49.59.23
PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.

--- 10.49.59.23 ping statistics ---
8 packets transmitted, 0 received, 100% packet loss, time 6999ms

root@Mimosa:/tmp# fg
tcpdump -v -p -n ip host 10.49.59.23 >/tmp/NULL-10.49.59.23
101 packets captured
101 packets received by filter
0 packets dropped by kernel
root@Mimosa:/tmp# ping 10.49.59.23
PING 10.49.59.23 (10.49.59.23) 56(84) bytes of data.

--- 10.49.59.23 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2000ms

root@Mimosa:/tmp# cat NULL-10.49.59.23
10:09:44.401764 IP (tos 0x0, ttl 127, id 494, offset 0, flags [DF], length: 
482) 172.22.1.84.1064 > 10.49.59.23.3218: P 2911920500:2911920942(442) ack 
1338762722 win 32148
10:09:44.482254 IP (tos 0x0, ttl  52, id 49677, offset 0, flags [none], 
length: 40) 10.49.59.23.3218 > 172.29.128.1.1064: . [tcp sum ok] ack 
2911920942 win 65535
10:09:45.152849 IP (tos 0x0, ttl  52, id 49827, offset 0, flags [none], 
length: 184) 10.49.59.23.3218 > 172.29.128.1.1064: P 0:144(144) ack 1 win 
65535
10:09:45.341709 IP (tos 0x0, ttl 127, id 495, offset 0, flags [DF], length: 
40) 172.22.1.84.1064 > 10.49.59.23.3218: . [tcp sum ok] ack 145 win 32004
10:09:47.028958 IP (tos 0x0, ttl 247, id 50107, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 1
10:09:48.029890 IP (tos 0x0, ttl 247, id 50365, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 2
10:09:49.026640 IP (tos 0x0, ttl 247, id 50565, offset 0, flags [none], 
length: 84) 10.49.59.23 > 172.29.128.1: icmp 64: echo reply seq 3

root@Mimosa:/tmp# ip r s
172.30.30.30 via 85.32.35.1 dev eth0
85.32.35.1 dev eth0  scope link
85.36.58.168/29 dev eth0  proto kernel  scope link  src 85.36.58.174
81.113.185.96/27 via 85.32.35.1 dev eth0
85.32.35.0/27 dev eth1  scope link
172.22.1.0/24 via 85.32.35.1 dev eth0  src 172.18.1.254
172.18.1.0/24 dev eth2  proto kernel  scope link  src 172.18.1.254
172.25.5.0/24 via 85.32.35.1 dev eth0
172.25.1.0/24 via 85.32.35.1 dev eth0
172.21.1.0/24 via 85.32.35.1 dev eth0
172.17.1.0/24 via 85.32.35.1 dev eth0
172.23.4.0/23 via 85.32.35.1 dev eth0
172.23.2.0/23 via 85.32.35.1 dev eth0
172.23.0.0/23 via 85.32.35.1 dev eth0
172.16.0.0/23 via 85.32.35.1 dev eth0
10.0.0.0/8 via 85.32.35.1 dev eth0  src 172.29.128.1
127.0.0.0/8 dev lo  scope link
default via 85.32.35.1 dev eth0  metric 1

After running 'tcpdump ip host x.y.z.w', 'ping x.y.z.w' reply
doesn't appear anymore on mimosa console.


