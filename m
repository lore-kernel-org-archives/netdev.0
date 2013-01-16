From: Ben Greear <greearb@candelatech.com>
Subject: Repeatable kernel splat in 3.3.8+, related to ip_rcv_finish
Date: Tue, 15 Jan 2013 16:33:30 -0800
Message-ID: <50F5F55A.9090706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44230 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757809Ab3APAdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 19:33:31 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0G0XUNP008122
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 16:33:31 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a reproducible crash (5-15 minutes typically)
in a hacked 3.3.8+ kernel.  No proprietary modules, but my normal mix of
networking patches are applied, so it could be my fault.

The crash always appears to be in the ip_rcv_finish method.
On a pervious panic, the 'IP' was 0xFFFFFFFF, and I've seen
it be other similar values before.  I'm not sure what this
implies....

Test case is 2000 mac-vlans, resetting about 50 of them at a time
during bringup, while also driving lower-speed NFS traffic on a
mount for each of the already-reset mac-vlans.  It takes multiple
minutes for my app to fully reset all of the interfaces and start
traffic, and there are lots and lots of network changes going on
at or just previous to the crashes.

I need the nfs-bind-to-local-ip patches that I carry in my tree to
reproduce this, so I can't run this test on upstream kernels.
I will work on porting these into the 3.7 kernel for testing there
in the meantime.

Does this bug look familiar to anyone?


(gdb) l *(ip_rcv_finish+0x2ea)
0xffffffff814423e6 is in ip_rcv_finish (/home/greearb/git/linux-3.3.dev.y/net/ipv4/ip_input.c:365).
360					skb->len);
361		} else if (rt->rt_type == RTN_BROADCAST)
362			IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INBCAST,
363					skb->len);
364	
365		return dst_input(skb);
366	
367	drop:
368		kfree_skb(skb);
369		return NET_RX_DROP;
(gdb)


BUG: unable to handle kernel paging request at 0000001d00088000
IP: [<0000001d00088000>] 0x1d00087fff
PGD 372cb6067 PUD 0
Oops: 0010 [#1] PREEMPT SMP
CPU 11
Modules linked in: nfs nfs_acl auth_rpcgss fscache 8021q garp stp llc lockd sunrpc macvlan pktgen microcode pcspkr i2c_i801 i2c_core i7core_edac e1000e iTCO_wdt 
iTCO_vendor_support ioatdma igb dca edac_core uinput ipv6 [last unloaded: scsi_wait_scan]

Pid: 67, comm: ksoftirqd/11 Tainted: G           O 3.3.8+ #55 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<0000001d00088000>]  [<0000001d00088000>] 0x1d00087fff
RSP: 0018:ffff88040974dc78  EFLAGS: 00010286
RAX: ffff88038526e500 RBX: ffff88038526eb00 RCX: ffff88038526eb00
RDX: 0000000000000020 RSI: 0000000000000002 RDI: ffff88038526eb00
RBP: ffff88040974dca0 R08: ffffffff814420fc R09: 0000000000000000
R10: ffff88040974d710 R11: ffffffff80000000 R12: ffff880357f4fcfc
R13: ffff880409295000 R14: 0000000000000000 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff88041fd60000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000001d00088000 CR3: 00000003958bd000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksoftirqd/11 (pid: 67, threadinfo ffff88040974c000, task ffff880409741740)
Stack:
  ffffffff814423e6 ffff88038526eb00 ffffffff814420fc ffff880409295000
  0000000000000000 ffff88040974dcd0 ffffffff8144274e ffff880480000000
  ffff880409741740 ffff88038526eb00 ffff880409295000 ffff88040974dd00
Call Trace:
  [<ffffffff814423e6>] ? ip_rcv_finish+0x2ea/0x302
  [<ffffffff814420fc>] ? inet_del_protocol+0x37/0x37
eth3#739: no IPv6 routers present
  [<ffffffff8144274e>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff814429d9>] ip_rcv+0x237/0x262
  [<ffffffff8140ea4f>] __netif_receive_skb+0x477/0x4c0
  [<ffffffff8140eb8c>] process_backlog+0xf4/0x1d6
  [<ffffffff81410ae8>] net_rx_action+0xad/0x1e9
  [<ffffffff8105b105>] __do_softirq+0x86/0x12f
  [<ffffffff8105b261>] run_ksoftirqd+0xb3/0x1a6
  [<ffffffff8105b1ae>] ? __do_softirq+0x12f/0x12f
  [<ffffffff8105b1ae>] ? __do_softirq+0x12f/0x12f
  [<ffffffff8106da7d>] kthread+0x84/0x8c
  [<ffffffff814cc4e4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8106d9f9>] ? __init_kthread_worker+0x37/0x37
  [<ffffffff814cc4e0>] ? gs_change+0x13/0x13
Code:  Bad RIP value.
RIP  [<0000001d00088000>] 0x1d00087fff
  RSP <ffff88040974dc78>
CR2: 0000001d00088000
---[ end trace 1d145cfe9c5c5d55 ]---

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
