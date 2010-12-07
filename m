From: Ilya Loginov <isloginov@gmail.com>
Subject: WARNING at local_bh_enable while tcp_retransmit
Date: Tue, 7 Dec 2010 18:23:08 +0300
Message-ID: <20101207182308.664e171d.isloginov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:41538 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338Ab0LGPUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 10:20:37 -0500
Received: by ewy10 with SMTP id 10so22407ewy.4
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 07:20:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi, I am working on some network drivers.
	First one is raw netdevice for RapidIO packets. Second one is
Ethernet network device that encapsulates Ethernet traffic into RapidIO
messages.
	Ethernet device changes skb->dev to RapidIO device, calls
RapidIO create_header and calls dev_queue_xmit on skb.
	All works well for linear skb's but I have trouble with
multi-fragment skb's when frags have bad alignment. In that case my
controller RapidIO fails to transmit packets. While a bit internal tx
queue with descriptors of underlying RapidIO device overflows and it
returns NETDEV_TX_BUSY in start_xmit.
	TCP stack retransmits packets after timeout and I gets this:

------------[ cut here ]------------
WARNING: at kernel/softirq.c:143 local_bh_enable+0x150/0x158()
Modules linked in: rioth rsmp k128 [last unloaded: k128]
Call Trace:
[<ffffffff80022170>] dump_stack+0x8/0x48
[<ffffffff800518e8>] warn_slowpath_common+0x90/0xb8
[<ffffffff80059ca0>] local_bh_enable+0x150/0x158
[<ffffffff80303f04>] dev_queue_xmit+0x55c/0x730
[<c0000000000591b0>] rio_send+0x1b0/0x380 [rsmp]	<- Stack over RapidIO device (similar to can)
[<c000000000068364>] rioth_start_xmit+0x74/0x88 [rioth] <- Ethernet over RapidIO
[<ffffffff80303620>] dev_hard_start_xmit+0x350/0x578
[<ffffffff8031cff4>] sch_direct_xmit+0x214/0x3a8
[<ffffffff80303e20>] dev_queue_xmit+0x478/0x730
[<ffffffff80332ba8>] ip_finish_output+0x168/0x408
[<ffffffff803312ec>] ip_local_out+0x3c/0x58
[<ffffffff80331bf0>] ip_queue_xmit+0x230/0x4a0
[<ffffffff8034bce0>] tcp_transmit_skb+0x4a8/0xaa0
[<ffffffff8034dfb8>] tcp_retransmit_skb+0x260/0x698
[<ffffffff803504d8>] tcp_retransmit_timer+0x110/0x700
[<ffffffff80350cf0>] tcp_write_timer+0x228/0x278
[<ffffffff80062584>] run_timer_softirq+0x174/0x398
[<ffffffff80059804>] __do_softirq+0x174/0x270
[<ffffffff800599c8>] do_softirq+0xc8/0xf8
[<ffffffff80059d7c>] irq_exit+0x7c/0x88
[<ffffffff80001400>] ret_from_irq+0x0/0x4
[<ffffffff8001ed4c>] cpu_idle+0x1c/0xa0
[<ffffffff8049bc80>] start_kernel+0x518/0x628

---[ end trace cc7486cd1e47e9db ]---

	I watched bonding, but I could not realize why it didn't get
same warning. It use very similar scheme of work.

	Do you have any ideas?

-- 
Ilya Loginov <isloginov@gmail.com>
