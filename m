From: Konstantin Kuzov <master.nosferatu@gmail.com>
Subject: Re: BUG: MARK in OUTPUT + =?utf-8?b?aXBfdHVubmVs?= causes kernel panic
Date: Wed, 25 Sep 2013 08:31:52 +0000 (UTC)
Message-ID: <loom.20130925T095425-819@post.gmane.org>
References: <CAKfDRXgJwyhE6sg1Ej=S35A+-dnPiU9TBA69zb-n7hGXgG+Sxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:57667 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab3IYIfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 04:35:09 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VOkYo-00062a-V4
	for netdev@vger.kernel.org; Wed, 25 Sep 2013 10:35:03 +0200
Received: from 37.44.44.156 ([37.44.44.156])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 10:35:02 +0200
Received: from master.nosferatu by 37.44.44.156 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 10:35:02 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kristian Evensen <kristian.evensen <at> gmail.com> writes:

> When trying to tunnel traffic originating from the same machine as the
> tunnel endpoint, I am experiencing kernel panics for some types of
> traffic (ICMP and UDP). TCP seems not to be affected by this, at least
> I have not been able to trigger the panic.
> 
> I have one tunnel (without an IP address) and use policy routing to
> steer some traffic through the tunnels.
[...]
> An interesting thing is that I have seen different kernel panics being
> triggered. The other one I have seen has RIP pointing to
> e1000_xmit_frame() and the message "protocol 0800 is buggy". However,
> the one I have posted is by far the most common.
I'm experiencing the same issue on two different machines. It happens on any 
kernel starting from 3.10 when ip_tunnel/ip_tunnel_core were introduced.

But in my configuration I have addresses on tunnel interfaces and only doing 
masquerading on postrouting...

Same as you it triggers different kernel panics depends on which kernel 
modules involved (nic, vbox, etc...) here are some samples:
http://nosferatu.g0x.ru/pub/kerneloops/

But most common one looks like that:

[   81.797190] skbuff: skb_under_panic: text:ffffffff8170307f len:142 put:14 
head:ffff88040cd12a00 data:ffff88040cd129ee tail:0x7c end:0xc0 dev:v33
[   81.797240] ------------[ cut here ]------------
[   81.797256] kernel BUG at net/core/skbuff.c:126!
[   81.797272] invalid opcode: 0000 [#1] SMP 
[   81.797291] Modules linked in: ext2
[   81.797309] CPU: 0 PID: 4654 Comm: ffmpeg Not tainted 3.11.1 #3
[   81.797328] Hardware name: Gigabyte Technology Co., Ltd. Z68A-D3H-
B3/Z68A-D3H-B3, BIOS F13 03/20/2012
[   81.797356] task: ffff88040cd5bc80 ti: ffff880407c38000 task.ti: 
ffff880407c38000
[   81.797380] RIP: 0010:[<ffffffff81881a55>]  [<ffffffff81881a55>] 
skb_panic+0x5e/0x60
[   81.797411] RSP: 0000:ffff88041fa03898  EFLAGS: 00010296
[   81.797428] RAX: 0000000000000084 RBX: ffff88040a2bd300 RCX: 
0000000000000000
[   81.797450] RDX: ffff88041fa0eb48 RSI: ffff88041fa0d258 RDI: 
ffff88041fa0d258
[   81.797472] RBP: ffff88041fa038b8 R08: 0000000000000000 R09: 
00000000000003ca
[   81.797494] R10: 0000000000000001 R11: 0000000000aaaaaa R12: 
ffff88040b90aed8
[   81.797516] R13: 000000000000000e R14: ffff88040b90aee8 R15: 
0000000000000000
[   81.797538] FS:  00007ff3002a0740(0000) GS:ffff88041fa00000(0000) 
knlGS:0000000000000000
[   81.797564] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   81.797582] CR2: 0000000008212000 CR3: 000000040a097000 CR4: 
00000000000407f0
[   81.797604] Stack:
[   81.797613]  ffff88040cd129ee 000000000000007c 00000000000000c0 
ffff88040c71e000
[   81.797643]  ffff88041fa038c8 ffffffff816971d5 ffff88041fa03928 
ffffffff8170307f
[   81.797673]  ffffffff81ee10a0 ffff88040c71e000 ffff88040d79dfc0 
fe971fac81ee10a0
[   81.797703] Call Trace:
[   81.797713]  <IRQ> 
[   81.797721] 
[   81.797730]  [<ffffffff816971d5>] skb_push+0x35/0x40
[   81.797745]  [<ffffffff8170307f>] ip_finish_output+0x2af/0x3a0
[   81.797765]  [<ffffffff81703a98>] ip_output+0x88/0x90
[   81.797782]  [<ffffffff81703214>] ip_local_out+0x24/0x30
[   81.797801]  [<ffffffff8174291b>] iptunnel_xmit+0x17b/0x1b0
[   81.797820]  [<ffffffff81744560>] ip_tunnel_xmit+0x2e0/0x7d0
[   81.797839]  [<ffffffff8174a9ec>] ipip_tunnel_xmit+0x5c/0x70
[   81.797859]  [<ffffffff816a8240>] dev_hard_start_xmit+0x300/0x510
[   81.798750]  [<ffffffff81758668>] ? nf_nat_ipv4_out+0x58/0x100
[   81.799648]  [<ffffffff816a8718>] dev_queue_xmit+0x2c8/0x460
[   81.800543]  [<ffffffff816ae14c>] neigh_direct_output+0xc/0x10
[   81.801434]  [<ffffffff81702f7f>] ip_finish_output+0x1af/0x3a0
[   81.802337]  [<ffffffff81703a98>] ip_output+0x88/0x90
[   81.803243]  [<ffffffff81703214>] ip_local_out+0x24/0x30
[   81.804143]  [<ffffffff817044f4>] ip_send_skb+0x14/0x50
[   81.805040]  [<ffffffff81704562>] ip_push_pending_frames+0x32/0x40
[   81.805950]  [<ffffffff8172e1ae>] icmp_push_reply+0xee/0x120
[   81.806851]  [<ffffffff8172e969>] icmp_send+0x419/0x490
[   81.807750]  [<ffffffff816a6082>] ? __netif_receive_skb_core+0x622/0x7f0
[   81.808651]  [<ffffffff81077c00>] ? update_curr+0x10/0x160
[   81.809552]  [<ffffffff816b00e0>] ? neigh_invalidate+0x120/0x120
[   81.810445]  [<ffffffff816f933d>] ipv4_link_failure+0x1d/0x70
[   81.811333]  [<ffffffff8172c50d>] arp_error_report+0x2d/0x40
[   81.812217]  [<ffffffff816b004c>] neigh_invalidate+0x8c/0x120
[   81.813102]  [<ffffffff816b0316>] neigh_timer_handler+0x236/0x2a0
[   81.813989]  [<ffffffff8104fb3a>] call_timer_fn+0x3a/0x110
[   81.814883]  [<ffffffff816b00e0>] ? neigh_invalidate+0x120/0x120
[   81.815787]  [<ffffffff81050ea0>] run_timer_softirq+0x1c0/0x2a0
[   81.816695]  [<ffffffff81048ee9>] __do_softirq+0xe9/0x230
[   81.817605]  [<ffffffff81049185>] irq_exit+0x95/0xa0
[   81.818513]  [<ffffffff8102da75>] smp_apic_timer_interrupt+0x45/0x60
[   81.819431]  [<ffffffff8188feca>] apic_timer_interrupt+0x6a/0x70
[   81.820355]  <EOI> 
[   81.820363] 
[   81.821277]  [<ffffffff8188f312>] ? system_call_fastpath+0x16/0x1b
[   81.822208] Code: 00 00 48 89 44 24 10 8b 87 d0 00 00 00 48 89 44 24 08 
48 8b 87 e0 00 00 00 48 c7 c7 80 fa c5 81 48 89 04 24 31 c0 e8 94 95 ff ff 
<0f> 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 48 89 e5 0f 0b 55 
[   81.823365] RIP  [<ffffffff81881a55>] skb_panic+0x5e/0x60
[   81.824409]  RSP <ffff88041fa03898>

I also can't trace why that happens and strangely I can't reproduce that 
issue on virtualbox. Have you discovered anything more about this issue in 
past month?
