From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2009-08-04-14-22 uploaded
Date: Wed, 5 Aug 2009 00:06:11 -0700
Message-ID: <20090805000611.e8183608.akpm@linux-foundation.org>
References: <200908042125.n74LP9qY018119@imap1.linux-foundation.org>
	<20090805063946.GA1934@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Jiri Pirko <jpirko@redhat.com>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933631AbZHEHHF@vger.kernel.org>
In-Reply-To: <20090805063946.GA1934@darkstar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Aug 2009 14:39:46 +0800 Dave Young <hidave.darkstar@gmail.com> wrote:

> Hi andrew,
> 
> I see following lockdep warning with this release:
> 
> [    0.474144] INFO: trying to register non-static key.
> [    0.474144] the code is fine but needs lockdep annotation.
> [    0.474144] turning off the locking correctness validator.
> [    0.474144] Pid: 1, comm: swapper Not tainted 2.6.31-rc5-mm1 #7
> [    0.474144] Call Trace:
> [    0.474144]  [<c1047f1e>] register_lock_class+0x58/0x241
> [    0.474144]  [<c1049ab1>] __lock_acquire+0xac/0xb73
> [    0.474144]  [<c1076eb5>] ? __alloc_pages_nodemask+0xe2/0x483
> [    0.474144]  [<c1048b64>] ? mark_lock+0x1e/0x1c7
> [    0.474144]  [<c1048b64>] ? mark_lock+0x1e/0x1c7
> [    0.474144]  [<c1048d50>] ? mark_held_locks+0x43/0x5b
> [    0.474144]  [<c10940a6>] ? kmem_cache_alloc+0xac/0x11b
> [    0.474144]  [<c104a615>] lock_acquire+0x9d/0xc0
> [    0.474144]  [<c12b8b96>] ? netif_addr_lock_bh+0xd/0xf
> [    0.474144]  [<c1330feb>] _spin_lock_bh+0x20/0x2f
> [    0.474144]  [<c12b8b96>] ? netif_addr_lock_bh+0xd/0xf
> [    0.474144]  [<c12b8b96>] netif_addr_lock_bh+0xd/0xf
> [    0.474144]  [<c12bc3c3>] alloc_netdev_mq+0xf9/0x1a5
> [    0.474144]  [<c121f016>] ? loopback_setup+0x0/0x74
> [    0.474144]  [<c1578d49>] loopback_net_init+0x20/0x5d
> [    0.474144]  [<c12b7907>] register_pernet_operations+0x13/0x15
> [    0.474144]  [<c12b7970>] register_pernet_device+0x1f/0x47
> [    0.474144]  [<c157ee8d>] net_dev_init+0xfe/0x14d
> [    0.474144]  [<c1001137>] do_one_initcall+0x4a/0x11a
> [    0.474144]  [<c157ed8f>] ? net_dev_init+0x0/0x14d
> [    0.474144]  [<c1067e00>] ? register_irq_proc+0x64/0xa8
> [    0.474144]  [<c1067e97>] ? init_irq_proc+0x53/0x60
> [    0.474144]  [<c1557535>] kernel_init+0x129/0x17a
> [    0.474144]  [<c155740c>] ? kernel_init+0x0/0x17a
> [    0.474144]  [<c1003d47>] kernel_thread_helper+0x7/0x10

At a guess I'd say that alloc_netdev_mq()->dev_unicast_init() is doing
netif_addr_lock_bh()->spin_lock_bh(&dev->addr_list_lock) prior to
initialising add_list_lock.

Something like this might shut it up:

--- a/net/core/dev.c~a
+++ a/net/core/dev.c
@@ -5111,7 +5111,7 @@ struct net_device *alloc_netdev_mq(int s
 	if (dev_addr_init(dev))
 		goto free_tx;
 
-	dev_unicast_init(dev);
+	__hw_addr_init(&dev->uc);
 
 	dev_net_set(dev, &init_net);
 

but it'd be better to intialise this thing earlier like:

--- a/net/core/dev.c~a
+++ a/net/core/dev.c
@@ -4730,8 +4730,6 @@ int register_netdevice(struct net_device
 	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
 	BUG_ON(!net);
 
-	spin_lock_init(&dev->addr_list_lock);
-	netdev_set_addr_lockdep_class(dev);
 	netdev_init_queue_locks(dev);
 
 	dev->iflink = -1;
@@ -5107,6 +5105,8 @@ struct net_device *alloc_netdev_mq(int s
 
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
+	spin_lock_init(&dev->addr_list_lock);
+	netdev_set_addr_lockdep_class(dev);
 
 	if (dev_addr_init(dev))
 		goto free_tx;
_

but that might break register_netdevice() for netdevs which were
allocated via other means, dunno.

I would be pointing fingers at

: commit 31278e71471399beaff9280737e52b47db4dc345
: Author:     Jiri Pirko <jpirko@redhat.com>
: AuthorDate: Wed Jun 17 01:12:19 2009 +0000
: Commit:     David S. Miller <davem@davemloft.net>
: CommitDate: Thu Jun 18 00:29:08 2009 -0700
: 
:     net: group address list and its count
    
and politely suggesting that net developers enable lockdep when testing :)
