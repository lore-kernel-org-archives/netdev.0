From: Meelis Roos <mroos@linux.ee>
Subject: ipv6 routing broken in 2.6.17-rc3,4
Date: Mon, 15 May 2006 09:18:19 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:56753 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S932241AbWEOGSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 02:18:21 -0400
Received: from math.ut.ee (localhost [IPv6:::1])
	by math.ut.ee (8.12.8+Sun/8.12.8/math-1.2) with ESMTP id k4F6IKK7002020
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 09:18:20 +0300 (EEST)
Received: from localhost (mroos@localhost)
	by math.ut.ee (8.12.8+Sun/8.12.2/Submit) with ESMTP id k4F6IKdq002016
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 09:18:20 +0300 (EEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On my home 6to4 gw, ipv6 routing seems to be broken and everything is 
sent to 6to4 tunnel (the default route). It worked with 
fine for a long time and with 2.6.17-rc2-g4d5c34ec and it's broken with 
vmlinuz-2.6.17-rc3-g3cd73eed and 2.6.17-rc4-g9be2f7c3 (yesterdays 
kernel).

Example (I add an unreachable route to an ipv6 address to force going 
there by ipv4 and it still uses the route):

vaarikas:~# ip -6 route add unreachable 2001:7a8:1:5::14
vaarikas:~# ping6 2001:7a8:1:5::14
PING 2001:7a8:1:5::14(2001:7a8:1:5::14) 56 data bytes
64 bytes from 2001:7a8:1:5::14: icmp_seq=1 ttl=55 time=56.7 ms
64 bytes from 2001:7a8:1:5::14: icmp_seq=2 ttl=55 time=55.5 ms

--- 2001:7a8:1:5::14 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 55.573/56.155/56.738/0.628 ms
vaarikas:~# ip -6 route
::/96 via :: dev tun6to4  metric 256  expires 21332659sec mtu 1480 advmss 1420 hoplimit 4294967295
unreachable 2001:7a8:1:5::14 dev lo  metric 1024  expires 21334221sec error -101 mtu 16436 advmss 16376 hoplimit 4294967295
2002:5283:297e:2::/64 dev eth0  metric 256  expires 21332659sec mtu 1500 advmss 1440 hoplimit 4294967295
2002:5283:297e::/48 dev tun6to4  metric 256  expires 21332659sec mtu 1480 advmss 1420 hoplimit 4294967295
2000::/3 via ::192.88.99.1 dev tun6to4  metric 1  expires 21332659sec mtu 1480 advmss 1420 hoplimit 4294967295
fe80::/64 dev eth0  metric 256  expires 21332650sec mtu 1500 advmss 1440 hoplimit 4294967295
fe80::/64 dev eth1  metric 256  expires 21332654sec mtu 1500 advmss 1440 hoplimit 4294967295
fe80::/64 dev tun6to4  metric 256  expires 21332659sec mtu 1480 advmss 1420 hoplimit 4294967295
ff00::/8 dev eth1  metric 256  expires 21332654sec mtu 1500 advmss 1440 hoplimit 4294967295
ff00::/8 dev tun6to4  metric 256  expires 21332659sec mtu 1480 advmss 1420 hoplimit 4294967295
ff00::/8 dev eth0  metric 256  expires 21332650sec mtu 1500 advmss 1440 hoplimit 4294967295
unreachable default dev lo  proto none  metric -1  error -101 hoplimit 255

Additional example: nothing goes in the direction of eth0, the packets 
that should go there also go to tun6to4 interface as confirmed by 
tcpdump. I have a laptop on eth0 and when I tracepath6 some external 
address, I get this from tun4to4 device on the gw:

vaarikas:~# tcpdump -n -s 1500 -vv -i tun6to4
tcpdump: WARNING: tun6to4: no IPv4 address assigned
tcpdump: listening on tun6to4, link-type RAW (Raw IP), capture size 1500 bytes
09:14:08.053137 IP6 (hlim 64, next-header: ICMPv6 (58), length: 1240) 2002:5283:297e::42 > 2002:5283:297e:2:210:60ff:fe5a:d6f5: [icmp6 sum ok] ICMP6, time exceeded in-transit, length 1240 for 2001:ad0::10
09:14:09.050230 IP6 (hlim 64, next-header: ICMPv6 (58), length: 1240) 2002:5283:297e::42 > 2002:5283:297e:2:210:60ff:fe5a:d6f5: [icmp6 sum ok] ICMP6, time exceeded in-transit, length 1240 for 2001:ad0::10
09:14:10.091294 IP6 (hlim 64, next-header: ICMPv6 (58), length: 1240) 2002:5283:297e::42 > 2002:5283:297e:2:210:60ff:fe5a:d6f5: [icmp6 sum ok] ICMP6, time exceeded in-transit, length 1240 for 2001:ad0::10
09:14:11.090985 IP6 (hlim 64, next-header: ICMPv6 (58), length: 1240) 2002:5283:297e::42 > 2002:5283:297e:2:210:60ff:fe5a:d6f5: [icmp6 sum ok] ICMP6, packet too big, length 1240, mtu 1480
09:14:12.090354 IP6 (hlim 64, next-header: ICMPv6 (58), length: 1240) 2002:5283:297e::42 > 2002:5283:297e:2:210:60ff:fe5a:d6f5: [icmp6 sum ok] ICMP6, packet too big, length 1240, mtu 1480
09:14:13.090373 IP6 (hlim 64, next-header: ICMPv6 (58), length: 1240) 2002:5283:297e::42 > 2002:5283:297e:2:210:60ff:fe5a:d6f5: [icmp6 sum ok] ICMP6, packet too big, length 1240, mtu 1480
09:14:14.091355 IP6 (hlim 64, next-header: ICMPv6 (58), length: 1240) 2002:5283:297e::42 > 2002:5283:297e:2:210:60ff:fe5a:d6f5: [icmp6 sum ok] ICMP6, packet too big, length 1240, mtu 1480
...

-- 
Meelis Roos (mroos@linux.ee)
