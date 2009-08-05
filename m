From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] net: Fix spinlock use in alloc_netdev_mq()
Date: Wed, 5 Aug 2009 10:47:47 +0200
Message-ID: <20090805084746.GA3897@psychotron.englab.brq.redhat.com>
References: <20090804.125742.32009006.davem@davemloft.net> <20090805070205.GA8741@elte.hu> <20090805071411.GA9217@elte.hu> <20090805071658.GA14073@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50252 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933365AbZHEIsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 04:48:00 -0400
Content-Disposition: inline
In-Reply-To: <20090805071658.GA14073@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 05, 2009 at 09:16:58AM CEST, mingo@elte.hu wrote:
>
>From 6a0405d0e9b5e15bb81b8278b08fdb931a6e8837 Mon Sep 17 00:00:00 2001
>From: Ingo Molnar <mingo@elte.hu>
>Date: Wed, 5 Aug 2009 09:14:11 +0200
>Subject: [PATCH] net: Fix spinlock use in alloc_netdev_mq()
>
>-tip testing found this lockdep warning:
>
>[    2.272010] calling  net_dev_init+0x0/0x164 @ 1
>[    2.276033] device class 'net': registering
>[    2.280191] INFO: trying to register non-static key.
>[    2.284005] the code is fine but needs lockdep annotation.
>[    2.284005] turning off the locking correctness validator.
>[    2.284005] Pid: 1, comm: swapper Not tainted 2.6.31-rc5-tip #1145
>[    2.284005] Call Trace:
>[    2.284005]  [<7958eb4e>] ? printk+0xf/0x11
>[    2.284005]  [<7904f83c>] __lock_acquire+0x11b/0x622
>[    2.284005]  [<7908c9b7>] ? alloc_debug_processing+0xf9/0x144
>[    2.284005]  [<7904e2be>] ? mark_held_locks+0x3a/0x52
>[    2.284005]  [<7908dbc4>] ? kmem_cache_alloc+0xa8/0x13f
>[    2.284005]  [<7904e475>] ? trace_hardirqs_on_caller+0xa2/0xc3
>[    2.284005]  [<7904fdf6>] lock_acquire+0xb3/0xd0
>[    2.284005]  [<79489678>] ? alloc_netdev_mq+0xf5/0x1ad
>[    2.284005]  [<79591514>] _spin_lock_bh+0x2d/0x5d
>[    2.284005]  [<79489678>] ? alloc_netdev_mq+0xf5/0x1ad
>[    2.284005]  [<79489678>] alloc_netdev_mq+0xf5/0x1ad
>[    2.284005]  [<793a38f2>] ? loopback_setup+0x0/0x74
>[    2.284005]  [<798eecd0>] loopback_net_init+0x20/0x5d
>[    2.284005]  [<79483efb>] register_pernet_device+0x23/0x4b
>[    2.284005]  [<798f5c9f>] net_dev_init+0x115/0x164
>[    2.284005]  [<7900104f>] do_one_initcall+0x4a/0x11a
>[    2.284005]  [<798f5b8a>] ? net_dev_init+0x0/0x164
>[    2.284005]  [<79066f6d>] ? register_irq_proc+0x8c/0xa8
>[    2.284005]  [<798cc29a>] do_basic_setup+0x42/0x52
>[    2.284005]  [<798cc30a>] kernel_init+0x60/0xa1
>[    2.284005]  [<798cc2aa>] ? kernel_init+0x0/0xa1
>[    2.284005]  [<79003e03>] kernel_thread_helper+0x7/0x10
>[    2.284078] device: 'lo': device_add
>[    2.288248] initcall net_dev_init+0x0/0x164 returned 0 after 11718 usecs
>[    2.292010] calling  neigh_init+0x0/0x66 @ 1
>[    2.296010] initcall neigh_init+0x0/0x66 returned 0 after 0 usecs
>
>it's using an zero-initialized spinlock. This is a side-effect of:
>
>        dev_unicast_init(dev);
>
>in alloc_netdev_mq() making use of dev->addr_list_lock.
>
>The device has just been allocated freshly, it's not accessible
>anywhere yet so no locking is needed at all - in fact it's wrong
>to lock it here (the lock isnt initialized yet).

Yes this looks like the right approach. Sorry for this bug :(
>
>This bug was introduced via:
>
>| commit a6ac65db2329e7685299666f5f7b6093c7b0f3a0
>| Date:   Thu Jul 30 01:06:12 2009 +0000
>|
>|     net: restore the original spinlock to protect unicast list
>
>Signed-off-by: Ingo Molnar <mingo@elte.hu>
Acked-by: Jiri Pirko <jpirko@redhat.com>
>---
> net/core/dev.c |    2 --
> 1 files changed, 0 insertions(+), 2 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 43e61ba..6a94475 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4007,9 +4007,7 @@ static void dev_unicast_flush(struct net_device *dev)
> 
> static void dev_unicast_init(struct net_device *dev)
> {
>-	netif_addr_lock_bh(dev);
> 	__hw_addr_init(&dev->uc);
>-	netif_addr_unlock_bh(dev);
> }
> 
> 
