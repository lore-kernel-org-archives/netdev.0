From: Ben Greear <greearb@candelatech.com>
Subject: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 03 Feb 2014 12:37:52 -0800
Message-ID: <52EFFE20.5080500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58635 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbaBCUhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 15:37:53 -0500
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id s13KbqLD028807
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 12:37:52 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel has some additional patches, but not much to IPv6.

The bug is that when we have lots of mac-vlans on some ixgbe ports
(500 per interface in this case), and boot up the system with the ports unplugged,
we get this crash almost every time.  Boot-up is going to do normal bootup
stuff plus create and configure the 1000 mac-vlans, dump their routing
tables, etc.

We are using one routing table per network device, and some
ip rules.

If we plug in the ixgbe ports, we do not ever see a crash.

We have not yet tried reproducing it on other drivers, but I suspect
the issue is not related to ixgbe.

Any ideas on this one?


Reading symbols from /home/greearb/kernel/2.6/linux-3.9.x64/net/ipv6/ipv6.ko...done.
(gdb) l *(fib6_walk_continue+0xd3)
0x105c0 is in fib6_walk_continue (/home/greearb/git/linux-3.9.dev.y/net/ipv6/ip6_fib.c:1423).
1418				if (fn == w->root)
1419					return 0;
1420				pn = fn->parent;
1421				w->node = pn;
1422	#ifdef CONFIG_IPV6_SUBTREES
1423				if (FIB6_SUBTREE(pn) == fn) {
1424					WARN_ON(!(fn->fn_flags & RTN_ROOT));
1425					w->state = FWS_L;
1426					continue;
1427				}
(gdb)

[root@lanforge-13100125 ~]# BUG: unable to handle kernel NULL pointer
dereference at 0000000000000018
IP: [<ffffffffa00a75c0>] fib6_walk_continue+0xd3/0x13c [ipv6]
PGD 4017c4067 PUD 3f3a94067 PMD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in: nf_nat_ipv4 nf_nat fuse macvlan wanlink(O) pktgen
ip6table_filter ip6_tables ebtable_nat ebtables coretemp mperf intel_powerclamp
kvm_intel kvm iTCO_wdt iTCO_vendor_support microcode serio_raw joydev pcspkr
i2c_i801 lpc_ich e1000e ixgbe ptp pps_core mdio hwmon dca video shpchp uinput
ipv6 mgag200 i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded:
iptable_nat]
CPU 7
Pid: 26961, comm: ip Tainted: G         C O 3.9.11+ #134 Supermicro
X9SCI/X9SCA/X9SCI/X9SCA
RIP: 0010:[<ffffffffa00a75c0>]  [<ffffffffa00a75c0>]
fib6_walk_continue+0xd3/0x13c [ipv6]
RSP: 0018:ffff880400677a48  EFLAGS: 00010283
RAX: ffff8803f8b08698 RBX: ffff8803f88ea6c0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff880400677918 RDI: ffff8803f3dde058
RBP: ffff880400677a58 R08: ffff8803f3dde034 R09: ffff8803f3dde000
R10: ffffffff810ca37a R11: ffff88041d5adef8 R12: ffff8803f3a34500
R13: ffffffff81ab5780 R14: ffff8803f88ea6c0 R15: ffff88041bcfc200
FS:  00007f054b30b740(0000) GS:ffff88042fdc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000018 CR3: 00000003f3c8c000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ip (pid: 26961, threadinfo ffff880400676000, task ffff8803ff90aee0)
Stack:
 ffff880400677aa8 ffff8803f248dd00 ffff880400677ad8 ffffffffa00a7815
 ffff8803ff90aee0 ffff88041bcfc214 0000000200000000 0000000200000020
 ffff8803f3a34500 ffff8803f248dd00 ffffffff81ab5780 0000000000000e70
Call Trace:
 [<ffffffffa00a7815>] inet6_dump_fib+0x179/0x211 [ipv6]
 [<ffffffff81535b19>] netlink_dump+0x6b/0x1b2
 [<ffffffff81535e2c>] netlink_recvmsg+0x1cc/0x322
 [<ffffffff815205d9>] ? rtnetlink_rcv+0x2b/0x2d
 [<ffffffff814ff3f5>] __sock_recvmsg+0x6a/0x77
 [<ffffffff814ff473>] sock_recvmsg+0x71/0x8a
 [<ffffffff8150aea1>] ? copy_from_user+0x9/0xb
 [<ffffffff8150b207>] ? verify_iovec+0x54/0xa8
 [<ffffffff81500f59>] ___sys_recvmsg+0x13b/0x20d
 [<ffffffff811602ca>] ? handle_mm_fault+0x536/0x550
 [<ffffffff815ce8a6>] ? __do_page_fault+0x307/0x389
 [<ffffffff81162789>] ? remove_vma+0x5d/0x65
 [<ffffffff8116467d>] ? do_munmap+0x332/0x34c
 [<ffffffff81501323>] __sys_recvmsg+0x42/0x60
 [<ffffffff8150135a>] sys_recvmsg+0x19/0x1b
 [<ffffffff815d1c99>] system_call_fastpath+0x16/0x1b
Code: 89 43 2c e9 61 ff ff ff 48 89 df ff 53 38 85 c0 75 7d ff 43 30 e9 4f ff
ff ff c6 43 28 04 48 3b 43 10 74 69 48 8b 10 48 89 53 18 <48> 39 42 18 75 20 f6
40 2a 02 75 11 be 90 05 00 00 48 c7 c7 2a
RIP  [<ffffffffa00a75c0>] fib6_walk_continue+0xd3/0x13c [ipv6]
 RSP <ffff880400677a48>
CR2: 0000000000000018

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
