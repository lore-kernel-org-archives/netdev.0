From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: kernel panic when exiting a network namespace
Date: Wed, 02 Feb 2011 16:40:01 +0100
Message-ID: <4D497AD1.8080706@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:38814 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754458Ab1BBPkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 10:40:10 -0500
Received: from [192.168.254.145] (AToulouse-159-1-59-10.w92-134.abo.wanadoo.fr [92.134.210.10])
	(Authenticated sender: daniel.lezcano)
	by smtp1-g21.free.fr (Postfix) with ESMTPA id ED09D940072
	for <netdev@vger.kernel.org>; Wed,  2 Feb 2011 16:40:03 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

if we create a network namespace and a pair network device veth with one 
side within the new netns and the other side in the old netns, then when 
the new netns exits that leads to a beautiful kernel panic.

That does not appear when both side are in the same network namespace.

linux-swk0 login: BUG: unable to handle kernel paging request at 
ffff88003aacfce0
IP: [<ffffffff812d2ebc>] unregister_netdevice_queue+0x4d/0x85
PGD 160b063 PUD 160f063 PMD 1ffd3067 PTE 3aacf160
Oops: 0002 [#1] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/virtual/block/ram9/uevent
CPU 0
Modules linked in:

Pid: 5, comm: kworker/u:0 Not tainted 2.6.38-rc2+ #4 /Bochs
RIP: 0010:[<ffffffff812d2ebc>]  [<ffffffff812d2ebc>] 
unregister_netdevice_queue+0x4d/0x85
RSP: 0018:ffff88003ecf1ca0  EFLAGS: 00010282
RAX: ffff88003aacfcd8 RBX: ffff88003908b800 RCX: 0000000000000000
RDX: ffff88003aacfcd8 RSI: ffff88003ecf1ce0 RDI: ffff88003908b8b0
RBP: ffff88003ecf1cb0 R08: ffffffff816655e0 R09: 00014b8a6008606d
R10: 0000000000000002 R11: 0000000000000004 R12: ffff88003ecf1ce0
R13: ffff88003ecf1ce0 R14: ffff88003ecf1d60 R15: ffff8800394a17f0
FS:  0000000000000000(0000) GS:ffffffff8161b000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff88003aacfce0 CR3: 0000000039587000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/u:0 (pid: 5, threadinfo ffff88003ecf0000, task 
ffff88003ece1100)
Stack:
  ffff88003ecf1ce0 ffff8800397fd800 ffff88003ecf1cd0 ffffffff8129c570
  ffff88003908b800 ffff8800394a1740 ffff88003ecf1d20 ffffffff812d2f4c
  ffff88003ecf1ce0 ffff88003ecf1ce0 2222222222222222 ffffffff81665220
Call Trace:
  [<ffffffff8129c570>] veth_dellink+0x16/0x26
  [<ffffffff812d2f4c>] default_device_exit_batch+0x58/0xc1
  [<ffffffff812cd73d>] ? cleanup_net+0x0/0x192
  [<ffffffff812cd116>] ops_exit_list+0x4e/0x56
  [<ffffffff812cd82d>] cleanup_net+0xf0/0x192
  [<ffffffff81042a11>] process_one_work+0x24d/0x407
  [<ffffffff81042984>] ? process_one_work+0x1c0/0x407
  [<ffffffff81042ede>] worker_thread+0x1b8/0x30a
  [<ffffffff81042d26>] ? worker_thread+0x0/0x30a
  [<ffffffff81046072>] kthread+0x7c/0x84
  [<ffffffff810034b4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8139bebe>] ? restore_args+0x0/0x30
  [<ffffffff81045ff6>] ? kthread+0x0/0x84
  [<ffffffff810034b0>] ? kernel_thread_helper+0x0/0x10
Code: 48 c7 c7 3d a2 53 81 e8 ca 60 0c 00 e8 ce 5e 0c 00 4d 85 e4 74 26 
48 8b 93 b0 00 00 00 48 8b 83 b8 00 00 00 48 8d bb b0 00 00 00 <48> 89 
42 08 48 89 10 4c
  89 e2 49 8b 74 24 08 eb 1d 48 89 df e8
RIP  [<ffffffff812d2ebc>] unregister_netdevice_queue+0x4d/0x85
  RSP <ffff88003ecf1ca0>
CR2: ffff88003aacfce0
---[ end trace 66938c79ba1c0677 ]---



addr2line -e ./vmlinux ffffffff8129c570

==> net-2.6/drivers/net/veth.c:455

static void veth_dellink(struct net_device *dev, struct list_head *head)
{
     struct veth_priv *priv;
     struct net_device *peer;

     priv = netdev_priv(dev);
     peer = priv->peer;

     unregister_netdevice_queue(dev, head);
==>    unregister_netdevice_queue(peer, head); <==
}


