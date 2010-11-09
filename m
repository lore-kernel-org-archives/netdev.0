From: Ben Greear <greearb@candelatech.com>
Subject: Takes > 1 second to delete macvlan with global IPv6 address on it.
Date: Mon, 08 Nov 2010 16:20:22 -0800
Message-ID: <4CD893C6.2030803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51451 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab0KIAUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 19:20:23 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id oA90KMJ0020717
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 Nov 2010 16:20:22 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is on an otherwise lightly loaded 2.6.36 + hacks system, 12 physical interfaces,
and two VETH interfaces.

It's much faster to delete an interface when it has no IPv6 address:

[root@ct503-60 lanforge]# time ip link add link eth5 up name eth5#0 address 00:00:00:00:00:01 type macvlan

real	0m0.005s
user	0m0.001s
sys	0m0.004s
[root@ct503-60 lanforge]# time ip link delete eth5#0

real	0m0.033s
user	0m0.001s
sys	0m0.005s
[root@ct503-60 lanforge]# ip link add link eth5 up name eth5#0 address 00:00:00:00:00:01 type macvlan

[root@ct503-60 lanforge]# ip -6 addr add 2002::1/64 dev eth5#0
[root@ct503-60 lanforge]# time ip link delete eth5#0

real	0m1.030s
user	0m0.000s
sys	0m0.013s


Funny enough, if you explicitly remove the IPv6 addr first it seems
to run at normal speed (adding both operation's times together)

[root@ct503-60 lanforge]# ip link add link eth5 up name eth5#0 address 00:00:00:00:00:01 type macvlan
[root@ct503-60 lanforge]# ip -6 addr add 2002::1/64 dev eth5#0
[root@ct503-60 lanforge]# time ip -6 addr delete 2002::1/64 dev eth5#0

real	0m0.001s
user	0m0.000s
sys	0m0.001s
[root@ct503-60 lanforge]# time ip link delete eth5#0

real	0m0.028s
user	0m0.001s
sys	0m0.005s


Take it easy,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

