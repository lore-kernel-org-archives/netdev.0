From: Thomas Habets <thomas@habets.pp.se>
Subject: BUG: IPv6 stops working after a while, needs ip ne del command to
 reset
Date: Fri, 6 Aug 2010 10:25:03 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008060710390.10730@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from reptilian.habets.pp.se ([193.151.93.131]:2964 "EHLO
	reptilian.habets.pp.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756084Ab0HFI6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 04:58:54 -0400
Received: from red.crap.retrofitta.se (10.200.216.81.static.apv.siw.siwnet.net [81.216.200.10])
	by reptilian.habets.pp.se (Postfix) with ESMTP id B03C13C888
	for <netdev@vger.kernel.org>; Fri,  6 Aug 2010 10:25:05 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPv6 initially works, but when I leave it alone overnight I'm unable to 
ping even my default gw.

Static global IPv6 addresses configured on both ends. No access lists on 
either end.

Kernel version: 2.6.35 mainline (amd64) and 2.6.33.6.
Kernel config: http://pastebin.com/raw.php?i=Y6S8iKW7
Dist: Debian Lenny (5.0.5), nothing special to my knowledge.

I seem to have the same issue that Mikael Abrahamsson encountered with 
Ubuntu kernels 2.6.26.3, 2.6.26-5-generic and 2.6.27-2-generic, and 
mainline kernels 2.6.25, 2.6.26 and 2.6.27:
   https://bugs.launchpad.net/ubuntu/+source/linux/+bug/263260

He got IPv6 running again without rebooting using "networking stop, 
ifconfig eth0 down, networking start, kill dhclient", while I narrowed it 
down to just deleting the ipv6 neighbor (ip ne del..., see below). 
Rebooting also causes it to start working again.

It's very reproducible. I just leave it overnight and it breaks every 
time.

I am willing and able to try patches at any time, the box is not in 
production.

No iptables, no ip6tables. IP6tables support is not even compiled in.

NIC is "Broadcom Corporation NetXtreme BCM5715 Gigabit ethernet (rev a3)"
according to lspci.

Other end is a directly connected Cisco 7600 (routed port) that I have 
access to, but it's in production use. IPv4 works perfectly over this same 
port. Only lo and eth0 are UP.


Output when broken
------------------
$ uname -a
Linux XXXXX 2.6.35 #1 SMP Tue Aug 3 09:25:51 CEST 2010 x86_64
GNU/Linux

$ ip -6 a sh
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
     inet6 2a00:800:1000:64::1/128 scope global
        valid_lft forever preferred_lft forever
     inet6 ::1/128 scope host
        valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
     inet6 2a00:800:752:1::5c:2/112 scope global
        valid_lft forever preferred_lft forever
     inet6 fe80::224:81ff:fea3:4424/64 scope link
        valid_lft forever preferred_lft forever

(I have tried removing 2a00:800:1000:64::1/128 from lo, same issue)

$ ip -6 r sh
2a00:800:752:1::5c:0/112 dev eth0  proto kernel  metric 256  mtu 1500
advmss 14 hoplimit 4294967295 unreachable
2a00:800:1000:64::1 dev lo proto kernel  metric 256  error -101 mtu 16436 advmss 16376 hoplimit 
4294967295
fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
hoplimit 4294967295
default via 2a00:800:752:1::5c:1 dev eth0  metric 1024  mtu 1500 advmss 
1440 hoplimit 4294967295

$ ping6 2a00:800:752:1::5c:1
PING 2a00:800:752:1::5c:1(2a00:800:752:1::5c:1) 56 data bytes
^C
--- 2a00:800:752:1::5c:1 ping statistics ---
22 packets transmitted, 0 received, 100% packet loss, time 21006ms


# Tcpdpump on the problem machine shows mostly the pings, but also 
periodically some ND:

[...]
12:54:02.683672 00:24:81:a3:44:24 > 00:22:55:17:4b:80, ethertype IPv6
(0x86dd), length 118: 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, 
echo request, seq 12, length 64
12:54:02.693669 00:24:81:a3:44:24 > 00:22:55:17:4b:80, ethertype IPv6
(0x86dd), length 86: fe80::224:81ff:fea3:4424 > 2a00:800:752:1::5c:1: 
ICMP6, neighbor solicitation, who has 2a00:800:752:1::5c:1, length 32
12:54:02.693832 00:22:55:17:4b:80 > 00:24:81:a3:44:24, ethertype IPv6
(0x86dd), length 78: 2a00:800:752:1::5c:1 > fe80::224:81ff:fea3:4424: 
ICMP6, neighbor advertisement, tgt is 2a00:800:752:1::5c:1, length 24
12:54:03.683672 00:24:81:a3:44:24 > 00:22:55:17:4b:80, ethertype IPv6
(0x86dd), length 118: 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, 
echo request, seq 13, length 64
[...]

$ ip -6 ne
fe80::222:55ff:fe17:4b80 dev eth0 lladdr 00:22:55:17:4b:80 router STALE
2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router STALE


Fixing the adjacency
--------------------
$ ping6 2a00:800:752:1::5c:1
PING 2a00:800:752:1::5c:1(2a00:800:752:1::5c:1) 56 data bytes
^C
--- 2a00:800:752:1::5c:1 ping statistics ---
51 packets transmitted, 0 received, 100% packet loss, time 50006ms

$ sudo ip ne del 2a00:800:752:1::5c:1 dev eth0
$ ping6 2a00:800:752:1::5c:1
PING 2a00:800:752:1::5c:1(2a00:800:752:1::5c:1) 56 data bytes
64 bytes from 2a00:800:752:1::5c:1: icmp_seq=1 ttl=64 time=31.9 ms
64 bytes from 2a00:800:752:1::5c:1: icmp_seq=2 ttl=64 time=0.212 ms

$ ip -6 ne
fe80::222:55ff:fe17:4b80 dev eth0 lladdr 00:22:55:17:4b:80 router 
REACHABLE
2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router REACHABLE

(Note that after a few minutes it goes back to STALE, but pinging still 
works and brings back the state to REACHABLE, so it's not that it can't 
get out of STALE once there, it seems).

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
