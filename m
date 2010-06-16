From: Einar EL Lueck <ELELUECK@de.ibm.com>
Subject: ipv6: netif_carrier_(on|off) with traces afterwards
Date: Wed, 16 Jun 2010 15:29:49 +0200
Message-ID: <OF3A036420.64516D4F-ONC1257744.00492A34-C1257744.004A240B@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:46791 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755414Ab0FPN3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 09:29:52 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.1/8.13.1) with ESMTP id o5GDTpTK024728
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 13:29:51 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5GDTpTU1110200
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:29:51 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o5GDTogl022140
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:29:50 +0200
Received: from d12ml064.megacenter.de.ibm.com (d12ml064.megacenter.de.ibm.com [9.149.167.10])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id o5GDToX8022130
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:29:50 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
With IPv6 addresses configured and and a network card doing
netif_carrier_off|on we see afterwards in 2.6.34 on S/390 some traces in
fib.

Example sequence of operations:
ip -6 addr add fd00:10:30:49:4008:ffff:35:2/80 dev eth1
ip link set eth1 up
ip link set eth1 down
# the following lines have as effect netif_carrier_off and then on (among
other stuff)
echo 0 > /sys/bus/ccwgroup/drivers/qeth/devices/0.0.e300/online
echo 1 > /sys/bus/ccwgroup/drivers/qeth/devices/0.0.e300/online
# end of plugging
ip link set eth1  up
ip link set eth1 down
=> at this point we get the following trace:

Badness
at /home/autobuild/BUILD/linux-2.6.34-20100531/net/ipv6/ip6_fib.c:1160
Modules linked in: qeth_l2 sunrpc qeth_l3 binfmt_misc dm_multipath scsi_dh
dm_mod ipv6 qeth ccwgroup
CPU: 9 Not tainted 2.6.34-43.x.20100531-s390xperformance #1
Process ip (pid: 18144, task: 000000007c304238, ksp: 00000000033af428)
Krnl PSW : 0704200180000000 000003c0018c05a4 (fib6_del+0x60/0x3f8 [ipv6])
           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 EA:3
Krnl GPRS: 0000000000000000 0000000000000002 000000007b58a700
0000000000830398
           0000000000830398 0000000000000001 0000000000000000
0000000000830398
           000003c0018bba5e 00000000033af480 0000000071ff2780
000000007b58a700
           000003c0018a7000 000003c0018e4d50 00000000033af398
00000000033af2e0
Krnl Code: 000003c0018c0598: eb6ff1000004       lmg     %r6,%r15,256(%r15)
           000003c0018c059e: 07f4               bcr     15,%r4
           000003c0018c05a0: a7f40001           brc     15,3c0018c05a2
          >000003c0018c05a4: a728fffe           lhi     %r2,-2
           000003c0018c05a8: a7f4fff3           brc     15,3c0018c058e
           000003c0018c05ac: b90200aa           ltgr    %r10,%r10
           000003c0018c05b0: a784ffed           brc     8,3c0018c058a
           000003c0018c05b4: e32033b00020       cg      %r2,944(%r3)
Call Trace:
([<0000000000000020>] 0x20)
 [<000003c0018bb9c6>] __ip6_del_rt+0x6e/0xc8 [ipv6]
 [<000003c0018bba5e>] ip6_del_rt+0x3e/0x4c [ipv6]
 [<000003c0018b4448>] __ipv6_ifa_notify+0x13c/0x1d4 [ipv6]
 [<000003c0018b7072>] addrconf_ifdown+0x3b2/0x5f0 [ipv6]
 [<000003c0018b8b2c>] addrconf_notify+0xb4/0x944 [ipv6]
 [<00000000004fb6aa>] notifier_call_chain+0x5a/0xa0
 [<000000000016675a>] raw_notifier_call_chain+0x2a/0x3c
 [<0000000000459194>] __dev_notify_flags+0x88/0xac
 [<0000000000459200>] dev_change_flags+0x48/0x70
 [<00000000004664d4>] do_setlink+0x35c/0x60c
 [<00000000004678fa>] rtnl_newlink+0x446/0x574
 [<000000000047c89c>] netlink_rcv_skb+0xdc/0xf0
 [<00000000004671a8>] rtnetlink_rcv+0x3c/0x48
 [<000000000047c35e>] netlink_unicast+0x352/0x3ac
 [<000000000047cebe>] netlink_sendmsg+0x22a/0x35c
 [<00000000004414c4>] sock_sendmsg+0xdc/0x100
 [<00000000004417ca>] SyS_sendmsg+0x182/0x2d4
 [<000000000043f17c>] SyS_socketcall+0x150/0x338
 [<0000000000119346>] sysc_noemu+0x10/0x16
 [<0000004e1271c71a>] 0x4e1271c71a
Last Breaking-Event-Address:
 [<000003c0018c05a0>] fib6_del+0x5c/0x3f8 [ipv6]

Has anybody seen effects like this before on other platforms, or has
anybody suggestions for the root cause?

Thanks,
Einar.

