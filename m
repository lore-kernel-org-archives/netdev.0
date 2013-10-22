From: Alexei Starovoitov <ast@plumgrid.com>
Subject: BUG: scheduling while atomic dev_set_promiscuity->__dev_notify_flags
Date: Mon, 21 Oct 2013 18:04:57 -0700
Message-ID: <CAMEtUuy91zYJ=bj1dzfdqE8kqZ3rE1RgdR-PZYekSUg8_xoTBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:37752 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243Ab3JVBE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 21:04:58 -0400
Received: by mail-we0-f175.google.com with SMTP id t61so7439821wes.34
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 18:04:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

after commit 991fb3f74c "dev: always advertise rx_flags changes via netlink"
I'm seeing 'sleeping in atomic' bug.

Steps to reproduce:
ip tuntap add dev tap1 mode tap
ifconfig tap1 up
tcpdump -nei tap1
and in different terminal:
ip tuntap del dev tap1 mode tap

[  271.627994] device tap1 left promiscuous mode
[  271.639897] BUG: sleeping function called from invalid context at
mm/slub.c:940
[  271.664491] in_atomic(): 1, irqs_disabled(): 0, pid: 3394, name: ip
[  271.677525] INFO: lockdep is turned off.
[  271.690503] CPU: 0 PID: 3394 Comm: ip Tainted: G        W    3.12.0-rc3+ #73
[  271.703996] Hardware name: System manufacturer System Product
Name/P8Z77 WS, BIOS 3007 07/26/2012
[  271.731254]  ffffffff81a58506 ffff8807f0d57a58 ffffffff817544e5
ffff88082fa0f428
[  271.760261]  ffff8808071f5f40 ffff8807f0d57a88 ffffffff8108bad1
ffffffff81110ff8
[  271.790683]  0000000000000010 00000000000000d0 00000000000000d0
ffff8807f0d57af8
[  271.822332] Call Trace:
[  271.838234]  [<ffffffff817544e5>] dump_stack+0x55/0x76
[  271.854446]  [<ffffffff8108bad1>] __might_sleep+0x181/0x240
[  271.870836]  [<ffffffff81110ff8>] ? rcu_irq_exit+0x68/0xb0
[  271.887076]  [<ffffffff811a80be>] kmem_cache_alloc_node+0x4e/0x2a0
[  271.903368]  [<ffffffff810b4ddc>] ? vprintk_emit+0x1dc/0x5a0
[  271.919716]  [<ffffffff81614d67>] ? __alloc_skb+0x57/0x2a0
[  271.936088]  [<ffffffff810b4de0>] ? vprintk_emit+0x1e0/0x5a0
[  271.952504]  [<ffffffff81614d67>] __alloc_skb+0x57/0x2a0
[  271.968902]  [<ffffffff8163a0b2>] rtmsg_ifinfo+0x52/0x100
[  271.985302]  [<ffffffff8162ac6d>] __dev_notify_flags+0xad/0xc0
[  272.001642]  [<ffffffff8162ad0c>] __dev_set_promiscuity+0x8c/0x1c0
[  272.017917]  [<ffffffff81731ea5>] ? packet_notifier+0x5/0x380
[  272.033961]  [<ffffffff8162b109>] dev_set_promiscuity+0x29/0x50
[  272.049855]  [<ffffffff8172e937>] packet_dev_mc+0x87/0xc0
[  272.065494]  [<ffffffff81732052>] packet_notifier+0x1b2/0x380
[  272.080915]  [<ffffffff81731ea5>] ? packet_notifier+0x5/0x380
[  272.096009]  [<ffffffff81761c66>] notifier_call_chain+0x66/0x150
[  272.110803]  [<ffffffff8108503e>] __raw_notifier_call_chain+0xe/0x10
[  272.125468]  [<ffffffff81085056>] raw_notifier_call_chain+0x16/0x20
[  272.139984]  [<ffffffff81620190>] call_netdevice_notifiers_info+0x40/0x70
[  272.154523]  [<ffffffff816201d6>] call_netdevice_notifiers+0x16/0x20
[  272.168552]  [<ffffffff816224c5>] rollback_registered_many+0x145/0x240
[  272.182263]  [<ffffffff81622641>] rollback_registered+0x31/0x40
[  272.195369]  [<ffffffff816229c8>] unregister_netdevice_queue+0x58/0x90
[  272.208230]  [<ffffffff81547ca0>] __tun_detach+0x140/0x340
[  272.220686]  [<ffffffff81547ed6>] tun_chr_close+0x36/0x60

packet_notifier() does rcu_read_lock() before calling into packet_dev_mc() .

Not sure how to fix it cleanly, other than disabling a notify here.
Any suggestion?

Thanks
Alexei
