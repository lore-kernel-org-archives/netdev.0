From: Chris Madden <chris@reflexsecurity.com>
Subject: Oops in filter add
Date: Mon, 19 Mar 2007 16:10:29 -0400
Message-ID: <45FEEE35.6090606@reflexsecurity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, tgraf@suug.ch, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:55824 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbXCSUlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 16:41:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi-

We're experiencing an oops when we attempt to add a filter to an ingress
qdisc while heavy traffic is passing through the device being
manipulated.    Currently, we're using 2.6.20.3.  Here is the setup:

We have traffic coming in a device, say, eth1.  While traffic comes in,
we use tc to add an ingress queuing discipline with "tc qdisc add dev
eth1 handle ffff: ingress".  This works, and a "tc qdisc show" confirms
that it is in place.

Its hard to boil down exactly where things are going wrong, but it seems
to center around adding a basic match filter to the ingress path we
created above.  

I did some digging, and it appears the filter add isn't mutexed right.  
Inside net/core/dev.c, ing_filter, I see:

        spin_lock(&dev->ingress_lock);
        if ((q = dev->qdisc_ingress) != NULL)
            result = q->enqueue(skb, q);
        spin_unlock(&dev->ingress_lock);

And unless I'm missing something, this is the only place this lock is
used ( other than initialization ).  In net/sched/cls_api.c, I see we do
qdisc_lock_tree/qdisc_unlock_tree (which locks dev->queue_lock).  As
near as I can tell, this is our problem ( our mutexes don't prohibit
manipulation while packets are flowing ).

It doesn't happen every time, but if we have a script that adds/removes
qdiscs and filters, and run a few hundred megabit through the interface,
it dies eventually.  I've been trying to puzzle out the locking myself,
but I fear I've been less than successful.
 
Oops below:

 [<c0220681>] tc_classify+0x34/0xbc
 [<f8a4d10b>] ingress_enqueue+0x16/0x55 [sch_ingress]
 [<c021451e>] netif_receive_skb+0x1de/0x2bf
 [<f88a6169>] e1000_clean_rx_irq+0x35b/0x42c [e1000]
 [<f88a5e0e>] e1000_clean_rx_irq+0x0/0x42c [e1000]
 [<f88a519b>] e1000_clean+0x6e/0x23d [e1000]
 [<c0215ed7>] net_rx_action+0xd5/0x1c6
 [<c011cafc>] __do_softirq+0x5d/0xba
 [<c0104c7f>] do_softirq+0x59/0xa9
 [<f8a50194>] basic_dump+0x0/0x115 [cls_basic]
 [<c022458e>] tcf_em_tree_dump+0x14d/0x2ff
 [<c01341db>] handle_fasteoi_irq+0x0/0xa0
 [<c0104d70>] do_IRQ+0xa1/0xb9
 [<c010367f>] common_interrupt+0x23/0x28
 [<f8a50497>] basic_change+0x167/0x370 [cls_basic]
 [<c02220df>] tc_ctl_tfilter+0x3ec/0x469
 [<c0221cf3>] tc_ctl_tfilter+0x0/0x469
 [<c021b250>] rtnetlink_rcv_msg+0x1b3/0x1d8
 [<c0221378>] tc_dump_qdisc+0x0/0xfe
 [<c02259cd>] netlink_run_queue+0x50/0xbe
 [<c021b09d>] rtnetlink_rcv_msg+0x0/0x1d8
 [<c021b05c>] rtnetlink_rcv+0x25/0x3d
 [<c0225e14>] netlink_data_ready+0x12/0x4c
 [<c0224e0e>] netlink_sendskb+0x19/0x30
 [<c0225df6>] netlink_sendmsg+0x242/0x24e
 [<c020ba1f>] sock_sendmsg+0xbc/0xd4
 [<c0128325>] autoremove_wake_function+0x0/0x35
 [<c0128325>] autoremove_wake_function+0x0/0x35
 [<c021180e>] verify_iovec+0x3e/0x70
 [<c020bbcb>] sys_sendmsg+0x194/0x1f9
 [<c0112bde>] __wake_up+0x32/0x43
 [<c022506a>] netlink_insert+0x106/0x110
 [<c022513b>] netlink_autobind+0xc7/0xe3
 [<c0226356>] netlink_bind+0x8d/0x127
 [<c013f61b>] do_wp_page+0x149/0x36c
 [<c015d17b>] d_alloc+0x138/0x17a
 [<c0140a24>] __handle_mm_fault+0x756/0x7a6
 [<c020ca68>] sys_socketcall+0x223/0x242
 [<c0263d8b>] do_page_fault+0x0/0x525
 [<c0102ce4>] syscall_call+0x7/0xb

Chris Madden
Reflex Security
