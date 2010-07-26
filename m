From: Sridhar Samudrala <sri@us.ibm.com>
Subject: list_add() corruption when updating timer in __nf_ct_refresh_acct()
Date: Mon, 26 Jul 2010 14:48:55 -0700
Message-ID: <1280180935.2138.66.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: kaber@trash.net, eric.dumazet@gmail.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:37729 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754699Ab0GZVs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jul 2010 17:48:59 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6QLUoah008493
	for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 17:30:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6QLmxQB092520
	for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 17:48:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6QLmvc9004288
	for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 18:48:58 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing list_add() corruption warnings followed by BUG in
kernel/timer.c:951 in cascade() routine with 2.6.32 based kernel
when running networking stress tests.

The list_add() warning is as follows.
<4>list_add corruption. prev->next should be next (c0000000bedc51e0),
but was
c00000007add7f88. (prev=c0000000bedc51e0).
<0>------------[ cut here ]------------
<3>Badness at lib/list_debug.c:30
<4>NIP: c0000000002e5c60 LR: c0000000002e5c5c CTR: 0000000000000001
<4>REGS: c00000000ede71c0 TRAP: 0700   Not tainted 
(2.6.32-44.el6.bk070910.ppc64)
<4>MSR: 8000000000029032 <EE,ME,CE,IR,DR>  CR: 28882042  XER: 20000010
<4>TASK = c0000000becc3110[0] 'swapper' THREAD: c0000000bed40000 CPU: 3
<4>GPR00: c0000000002e5c5c c00000000ede7440 c000000000e8cd08 0000000000000079 
<4>GPR04: 0000000000000000 ffffffffffffffff 0000000000000005 0000000000080000 
<4>GPR08: 0000000000145915 c000000000884fe8 00000000001458a1 0000000000c40000 
<4>GPR12: 0000000028882042 c000000000f62b00 0000000000000062 c0000000bc02e610 
<4>GPR16: c0000000bc02e580 0000000000000000 c00000000ede7d60 0000000000001158 
<4>GPR20: c0000000b40d06f0 0000000000000002 ffffffff80000000 0000000000000014 
<4>GPR24: 0000000000000000 c000000000f4aee8 c0000000206f9330 0000000000000001 
<4>GPR28: c0000000206f93b8 c0000000bedc51e0 c000000000e2f490 c0000000bedc51e0 
<4>NIP [c0000000002e5c60] .__list_add+0xa0/0xb0
<4>LR [c0000000002e5c5c] .__list_add+0x9c/0xb0
<4>Call Trace:
<4>[c00000000ede7440] [c0000000002e5c5c] .__list_add+0x9c/0xb0 (unreliable)
<4>[c00000000ede74d0] [c0000000000a0580] .internal_add_timer+0xc0/0x180
<4>[c00000000ede7540] [c0000000000a1fec] .mod_timer_pending+0x15c/0x2a0
<4>[c00000000ede75f0] [c0000000004dbb3c] .__nf_ct_refresh_acct+0x12c/0x150
<4>[c00000000ede76a0] [c000000000544fec] .icmp_packet+0x2c/0x50
<4>[c00000000ede7720] [c0000000004de024] .nf_conntrack_in+0x3c4/0xba0
<4>[c00000000ede7850] [c0000000005442d4] .ipv4_conntrack_in+0x24/0x40
<4>[c00000000ede78c0] [c0000000004d8a3c] .nf_iterate+0xbc/0x130
<4>[c00000000ede7980] [c0000000004d8b44] .nf_hook_slow+0x94/0x180
<4>[c00000000ede7a50] [c0000000004f160c] .ip_rcv+0x29c/0x3c0
<4>[c00000000ede7af0] [c0000000004a6850] .netif_receive_skb+0x480/0x7f0
<4>[c00000000ede7bc0] [d0000000012e4a58] .ixgbe_clean_rx_irq+0x5e8/0x940
[ixgbe]
<4>[c00000000ede7cf0] [d0000000012e5dd4] .ixgbe_clean_rxtx_many+0x124/0x280
[ixgbe]
<4>[c00000000ede7dc0] [c0000000004a7788] .net_rx_action+0x168/0x2e0
<4>[c00000000ede7eb0] [c0000000000951cc] .__do_softirq+0x11c/0x290
<4>[c00000000ede7f90] [c0000000000318d8] .call_do_softirq+0x14/0x24
<4>[c0000000bed43970] [c00000000000e560] .do_softirq+0xf0/0x110
<4>[c0000000bed43a10] [c000000000094ef4] .irq_exit+0xb4/0xc0
<4>[c0000000bed43a90] [c00000000000e7c4] .do_IRQ+0x144/0x230
<4>[c0000000bed43b40] [c000000000004800] hardware_interrupt_entry+0x18/0x98
<4>--- Exception: 501 at .cpu_idle+0x14c/0x1d0
<4>    LR = .cpu_idle+0x14c/0x1d0
<4>[c0000000bed43e30] [c000000000015880] .cpu_idle+0x140/0x1d0 (unreliable)
<4>[c0000000bed43ee0] [c0000000005916f4] .start_secondary+0x350/0x388
<4>[c0000000bed43f90] [c000000000008264] .start_secondary_prolog+0x10/0x14
<4>Instruction dump:
<4>4e800020 e87e8010 7fe6fb78 482a666d 60000000 0fe00000 4bffffb0 e87e8018 
<4>7fe4fb78 7fa6eb78 482a6651 60000000 <0fe00000> 4bffffa0 60000000 60000000 

I have seen a similar bug report last year 
 http://thread.gmane.org/gmane.linux.kernel/851897/focus=853216

Based on the discussion then, it looks like that issue was addressed using the 
following 3 patches.
[PATCH] netfilter: nf_conntrack: death_by_timeout() fix
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=8cc20198cfccd06cef705c14fd50bde603e2e306
[PATCH] netfilter: nf_conntrack: fix confirmation race condition
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=5c8ec910e789a92229978d8fd1fce7b62e8ac711
[PATCH] netfilter: nf_conntrack: fix conntrack lookup race
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=8d8890b7751387f58ce0a6428773de2fbc0fd596

All these patches went into 2.6.32. But we are still seeing this list 
corruption issue. Is it possible that there is still a race condition 
that is not completely addressed with these patches?

We tried Eric's patch that was posted originally as a RFC patch here
  http://thread.gmane.org/gmane.linux.kernel/851897/focus=853235
This seems to help although more testing is required.
 
Thanks for any help identifying any other patches that went in recently
that could address this issue or any patches for testing.

Thanks
Sridhar





