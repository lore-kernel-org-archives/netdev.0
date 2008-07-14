From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 26-rc9-mmotm lockdep warning initializing loopback interface
Date: Sun, 13 Jul 2008 21:07:55 -0700
Message-ID: <20080713210755.ed9257aa.akpm@linux-foundation.org>
References: <4171.1215943203@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58032 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750763AbYGNEI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 00:08:29 -0400
In-Reply-To: <4171.1215943203@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Jul 2008 06:00:03 -0400 Valdis.Kletnieks@vt.edu wrote:

> I wonder if it's this chunk in linux-next.patch:
> 
>  void qdisc_lock_tree(struct net_device *dev)
> -       __acquires(dev->queue_lock)
> -       __acquires(dev->ingress_lock)
> +       __acquires(dev->tx_queue.lock)
> +       __acquires(dev->rx_queue.lock)
>  {
> -       spin_lock_bh(&dev->queue_lock);
> -       spin_lock(&dev->ingress_lock);
> +       spin_lock_bh(&dev->tx_queue.lock);
> +       spin_lock(&dev->rx_queue.lock);
>  }
> 
> For loopback, is tx_queue the same as rx_queue? That would explain this..
> 
> Found this in the dmesg:
> 
> [    0.418581] system 00:0b: iomem range 0xfed00000-0xfed003ff has been reserved
> [    0.421109]
> [    0.421110] =============================================
> [    0.421123] [ INFO: possible recursive locking detected ]
> [    0.421132] 2.6.26-rc9-mm1 #2
> [    0.421138] ---------------------------------------------
> [    0.421147] swapper/1 is trying to acquire lock:
> [    0.421154]  (&queue->lock){-...}, at: [<ffffffff804b81d5>] qdisc_lock_tree+0x27/0x2c
> [    0.421176]
> [    0.421177] but task is already holding lock:
> [    0.421186]  (&queue->lock){-...}, at: [<ffffffff804b81cd>] qdisc_lock_tree+0x1f/0x2c
> [    0.421205]
> [    0.421205] other info that might help us debug this:
> [    0.421216] 3 locks held by swapper/1:
> [    0.421221]  #0:  (net_mutex){--..}, at: [<ffffffff804a5557>] register_pernet_device+0x1a/0x5a
> [    0.421245]  #1:  (rtnl_mutex){--..}, at: [<ffffffff804b1fe0>] rtnl_lock+0x12/0x14
> [    0.421256]  #2:  (&queue->lock){-...}, at: [<ffffffff804b81cd>] qdisc_lock_tree+0x1f/0x2c
> [    0.421256]
> [    0.421256] stack backtrace:
> [    0.421256] Pid: 1, comm: swapper Not tainted 2.6.26-rc9-mm1 #2
> [    0.421256]
> [    0.421256] Call Trace:
> [    0.421256]  [<ffffffff8025b65c>] __lock_acquire+0xd70/0x1131
> [    0.421256]  [<ffffffff804b81d5>] ? qdisc_lock_tree+0x27/0x2c
> [    0.421256]  [<ffffffff8025bac2>] lock_acquire+0xa5/0xc9
> [    0.421256]  [<ffffffff804b81d5>] ? qdisc_lock_tree+0x27/0x2c
> [    0.421256]  [<ffffffff8055e61c>] _spin_lock+0x2f/0x3b
> [    0.421256]  [<ffffffff804b81d5>] qdisc_lock_tree+0x27/0x2c
> [    0.421256]  [<ffffffff804b8217>] dev_init_scheduler+0x11/0x94
> [    0.421256]  [<ffffffff804a992e>] register_netdevice+0x2e5/0x455
> [    0.421256]  [<ffffffff804a9ad8>] register_netdev+0x3a/0x48
> [    0.421256]  [<ffffffff807a2189>] loopback_net_init+0x40/0x7a
> [    0.421256]  [<ffffffff807a2137>] ? loopback_init+0x0/0x12
> [    0.421256]  [<ffffffff804a556a>] register_pernet_device+0x2d/0x5a
> [    0.421256]  [<ffffffff807a2147>] loopback_init+0x10/0x12
> [    0.421256]  [<ffffffff80781563>] do_one_initcall+0x47/0x141
> [    0.421256]  [<ffffffff802770e8>] ? register_irq_proc+0xd3/0xef
> [    0.421256]  [<ffffffff802f0000>] ? check_idq+0xff/0x197
> [    0.421270]  [<ffffffff80781784>] kernel_init+0x127/0x17b
> [    0.421270]  [<ffffffff8055debb>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [    0.421270]  [<ffffffff8020d349>] child_rip+0xa/0x11
> [    0.421270]  [<ffffffff8025a2de>] ? trace_hardirqs_on+0xd/0xf
> [    0.421270]  [<ffffffff8020c953>] ? restore_args+0x0/0x30
> [    0.421270]  [<ffffffff8078165d>] ? kernel_init+0x0/0x17b
> [    0.421270]  [<ffffffff8020d33f>] ? child_rip+0x0/0x11
> [    0.421270]
> [    0.421358] pci 0000:03:01.0: BAR 9 too large: 0x00000000000000-0x00000003ffffff
> [    0.421379] pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
> [    0.421389] pci 0000:00:01.0:   IO window: disabled
> [    0.421402] pci 0000:00:01.0:   MEM window: 0xed000000-0xefefffff
> [    0.421414] pci 0000:00:01.0:   PREFETCH window: 0x000000d0000000-0x000000dfffffff

Yup, it looks like that patch might be the culprit.

commit dc2b48475a0a36f8b3bbb2da60d3a006dc5c2c84
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Jul 8 17:18:23 2008 -0700

    netdev: Move queue_lock into struct netdev_queue.

<adds cc, runs away>

(thanks for doing all this stuff, btw - it directly subtracts from the
amount of time I need to spend doing next -mm.  Even better: it gives
others time to fix the things which you've found so next -mm
(mid-week?) will have lower latency and me-hassle).

(otoh, many of these problems are also in linux-next.  Who's testing
that?  Hopefully it's a weekend*summer thing.)

