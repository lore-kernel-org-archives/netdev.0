From: Ben Greear <greearb@candelatech.com>
Subject: Re: Repeatable kernel splat in 3.3.8+, related to ip_rcv_finish
Date: Tue, 15 Jan 2013 18:00:54 -0800
Message-ID: <50F609D6.9080300@candelatech.com>
References: <50F5F55A.9090706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38815 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757823Ab3APCAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 21:00:55 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0G20sxo014964
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 18:00:54 -0800
In-Reply-To: <50F5F55A.9090706@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2013 04:33 PM, Ben Greear wrote:
> I have a reproducible crash (5-15 minutes typically)
> in a hacked 3.3.8+ kernel.  No proprietary modules, but my normal mix of
> networking patches are applied, so it could be my fault.

I see something similar in 3.7.2+.

But, still with my patches applied.  I'll work on a minimal patch set
tomorrow to just fix up NFS how I need it and see if it's still reproducible...

(gdb) l *(ip_rcv_finish+0x2b7)
0xffffffff8149c933 is in ip_rcv_finish (/home/greearb/git/linux-3.7.dev.y/net/ipv4/ip_input.c:373).
368					skb->len);
369		} else if (rt->rt_type == RTN_BROADCAST)
370			IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INBCAST,
371					skb->len);
372	
373		return dst_input(skb);
374	
375	drop:
376		kfree_skb(skb);
377		return NET_RX_DROP;
(gdb)


BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<          (null)>]           (null)
PGD 0
Oops: 0010 [#1] PREEMPT SMP
Modules linked in: nfnetlink_log nfnetlink bluetooth nfsv4 auth_rpcgss nfs fscache 8021q garp stp llc loe
CPU 10
Pid: 70, comm: rcuc/10 Tainted: G        WC O 3.7.2+ #25 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
RSP: 0018:ffff88041fd43d90  EFLAGS: 00010286
RAX: ffff8803527eaf00 RBX: ffff8803e1e47100 RCX: ffff8803e1e47100
RDX: 0000000000000002 RSI: 0000000000000002 RDI: ffff8803e1e47100
RBP: ffff88041fd43db8 R08: ffffffff8149c67c R09: ffff88041fd43d80
R10: ffffffff81a6f280 R11: ffff8803fff62940 R12: ffff8803dfa5f8fc
R13: ffff8803e1e47100 R14: ffff88040d38e000 R15: 0000000000000008
FS:  0000000000000000(0000) GS:ffff88041fd40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rcuc/10 (pid: 70, threadinfo ffff88040d018000, task ffff88040d7fdcc0)
Stack:
  ffffffff8149c933 ffff8803e1e47100 ffffffff8149c67c ffff8803e1e47100
  ffff88040d38e000 ffff88041fd43de8 ffffffff8149cc98 0000000080000000
  ffff88040d4e3e38 ffff8803e1e47100 ffff88040d38e000 ffff88041fd43e18
Call Trace:
  <IRQ>
  [<ffffffff8149c933>] ? ip_rcv_finish+0x2b7/0x2cf
  [<ffffffff8149c67c>] ? inet_del_protocol+0x37/0x37
  [<ffffffff8149cc98>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff8149cf23>] ip_rcv+0x237/0x268
  [<ffffffff81468c29>] __netif_receive_skb+0x4da/0x583
  [<ffffffff810a7535>] ? __wake_up_common+0x45/0x77
  [<ffffffff81468dc8>] process_backlog+0xf6/0x1d7
  [<ffffffff8146b17e>] net_rx_action+0xad/0x20c
  [<ffffffff8108d292>] __do_softirq+0x9c/0x161
  [<ffffffff8152aa1c>] call_softirq+0x1c/0x30
  <EOI>
  [<ffffffff8100bd21>] do_softirq+0x41/0x7e
  [<ffffffff8108d413>] _local_bh_enable_ip+0x7a/0x9f
  [<ffffffff8108d450>] local_bh_enable+0xd/0x11
  [<ffffffff810ef54e>] rcu_cpu_kthread+0xe6/0x11f
  [<ffffffff810a6f3b>] smpboot_thread_fn+0x253/0x258
  [<ffffffff810a6ce8>] ? test_ti_thread_flag.clone.0+0x11/0x11
  [<ffffffff8109ff60>] kthread+0xbf/0xc7
  [<ffffffff8109fea1>] ? __init_kthread_worker+0x37/0x37
  [<ffffffff8152977c>] ret_from_fork+0x7c/0xb0
  [<ffffffff8109fea1>] ? __init_kthread_worker+0x37/0x37
Code:  Bad RIP value.
RIP  [<          (null)>]           (null)
  RSP <ffff88041fd43d90>
CR2: 0000000000000000
BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<          (null)>]           (null)
PGD 0
Oops: 0010 [#2] PREEMPT SMP
Modules linked in: nfnetlink_log nfnetlink bluetooth nfsv4 auth_rpcgss nfs fscache 8021q garp stp llc loe
CPU 10
Pid: 72, comm: migration/10 Tainted: G        WC O 3.7.2+ #25 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
RSP: 0018:ffff88040d01d990  EFLAGS: 00010286
RAX: ffff8803527eaf00 RBX: ffff8803e1e46f00 RCX: ffff8803e1e46f00
RDX: 0000000000000002 RSI: 0000000000000002 RDI: ffff8803e1e46f00
RBP: ffff88040d01d9b8 R08: ffffffff8149c67c R09: ffff88040d01d980
R10: dead000000200200 R11: dead000000100100 R12: ffff8803dfa5acfc
R13: ffff8803e1e46f00 R14: ffff88040d38e000 R15: 0000000000000008
FS:  0000000000000000(0000) GS:ffff88041fd40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001a0b000 CR4: 00000000000007e0


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
