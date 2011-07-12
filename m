From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: bonding and IPv6 "doesn't work"?
Date: Tue, 12 Jul 2011 18:05:41 +0200
Message-ID: <4E1C70D5.6060806@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.virtall.com ([178.63.195.102]:41422 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab1GLQFo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 12:05:44 -0400
Received: from mail.virtall.com (localhost [127.0.0.1])
	by mail.virtall.com (Postfix) with ESMTP id 4565E365E1A
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 18:05:42 +0200 (CEST)
Received: from [192.168.10.145] (e183095092.adsl.alicedsl.de [85.183.95.92])
	by mail.virtall.com (Postfix) with ESMTPSA id E43B0365E10
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 18:05:41 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to make bonding work with IPv6, using 2.6.39.3 kernel.


Unfortunately, it doesn't seem to work without some rather unintuitive 
workarounds.


I make a bond0 of two interfaces, eth0 and eth1.

As soon as I assign them a IPv6 address, I can see the following message 
in dmesg:

bond0: IPv6 duplicate address 2a01:4f8:120:14c4::1247 detected!



I'm not able to reach any host in the internet:

# assign an IP address
ip -6 addr add 2a01:4f8:120:14c4::1247/64 dev bond0
ip -6 route add 2a01:4f8:120:14c4::15 dev bond0
ip -6 route add default via 2a01:4f8:120:14c4::15

# ping a host in the internet
ping6 -c 1 kernel.org
PING kernel.org(pub1.kernel.org) 56 data bytes

--- kernel.org ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms




However if I start bonding with just one interface, add IPv6 address to 
it, then use ifenslave to add a second interface, I'm able to reach the 
hosts in the internet.

# restart network
/etc/init.d/network restart

# remove eth1 from bonding
ifenslave -d bond0 eth1

# assign an IP address
ip -6 addr add 2a01:4f8:120:14c4::1247/64 dev bond0
ip -6 route add 2a01:4f8:120:14c4::15 dev bond0
ip -6 route add default via 2a01:4f8:120:14c4::15

# add eth1 to bonding
ifenslave bond0 eth1


# ping a host in the internet
ping6 -c 1 kernel.org
PING kernel.org(pub4.kernel.org) 56 data bytes
64 bytes from pub4.kernel.org: icmp_seq=0 ttl=49 time=61.6 ms

--- kernel.org ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 61.645/61.645/61.645/0.000 ms, pipe 2


This is 100% reproducible - is it expected?

I've tried setting these sysctl values, but it didn't help:

net.ipv6.conf.eth0.accept_dad = 0
net.ipv6.conf.eth1.accept_dad = 0



# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.0 (June 2, 2010)

Bonding Mode: load balancing (round-robin)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth0
MII Status: up
Speed: 100 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 72:d2:6e:8e:07:4d
Slave queue ID: 0

Slave Interface: eth1
MII Status: up
Speed: 100 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 6a:f2:e9:64:01:76
Slave queue ID: 0


-- 
Tomasz Chmielewski
http://wpkg.org
