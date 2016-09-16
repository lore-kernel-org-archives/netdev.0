From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next 0/2] bnx2x: page allocation failure
Date: Fri, 16 Sep 2016 17:30:32 -0400
Message-ID: <cover.1474060371.git.jbaron@akamai.com>
Cc: Yuval.Mintz@qlogic.com, netdev@vger.kernel.org
To: davem@davemloft.net, Ariel.Elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:24805 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750945AbcIPVbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 17:31:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While configuring ~500 multicast addrs, we ran into high order
page allocation failures. They don't need to be high order, and
thus I'm proposing to split them into at most PAGE_SIZE allocations.

Below is a sample failure.

Thanks,

-Jason

[1201902.617882] bnx2x: [bnx2x_set_mc_list:12374(eth0)]Failed to create multicast MACs list: -12
[1207325.695021] kworker/1:0: page allocation failure: order:2, mode:0xc020
[1207325.702059] CPU: 1 PID: 15805 Comm: kworker/1:0 Tainted: G        W
[1207325.712940] Hardware name: SYNNEX CORPORATION 1x8-X4i SSD 10GE/S5512LE, BIOS V8.810 05/16/2013
[1207325.722284] Workqueue: events bnx2x_sp_rtnl_task [bnx2x]
[1207325.728206]  0000000000000000 ffff88012d873a78 ffffffff8267f7c7 000000000000c020
[1207325.736754]  0000000000000000 ffff88012d873b08 ffffffff8212f8e0 fffffffc00000003
[1207325.745301]  ffff88041ffecd80 ffff880400000030 0000000000000002 0000c0206800da13
[1207325.753846] Call Trace:
[1207325.756789]  [<ffffffff8267f7c7>] dump_stack+0x4d/0x63
[1207325.762426]  [<ffffffff8212f8e0>] warn_alloc_failed+0xe0/0x130
[1207325.768756]  [<ffffffff8213c898>] ? wakeup_kswapd+0x48/0x140
[1207325.774914]  [<ffffffff82132afc>] __alloc_pages_nodemask+0x2bc/0x970
[1207325.781761]  [<ffffffff82173691>] alloc_pages_current+0x91/0x100
[1207325.788260]  [<ffffffff8212fa1e>] alloc_kmem_pages+0xe/0x10
[1207325.794329]  [<ffffffff8214c9c8>] kmalloc_order+0x18/0x50
[1207325.800227]  [<ffffffff8214ca26>] kmalloc_order_trace+0x26/0xb0
[1207325.806642]  [<ffffffff82451c68>] ? _xfer_secondary_pool+0xa8/0x1a0
[1207325.813404]  [<ffffffff8217cfda>] __kmalloc+0x19a/0x1b0
[1207325.819142]  [<ffffffffa02fe975>] bnx2x_set_rx_mode_inner+0x3d5/0x590 [bnx2x]
[1207325.827000]  [<ffffffffa02ff52d>] bnx2x_sp_rtnl_task+0x28d/0x760 [bnx2x]
[1207325.834197]  [<ffffffff820695d4>] process_one_work+0x134/0x3c0
[1207325.840522]  [<ffffffff82069981>] worker_thread+0x121/0x460
[1207325.846585]  [<ffffffff82069860>] ? process_one_work+0x3c0/0x3c0
[1207325.853089]  [<ffffffff8206f039>] kthread+0xc9/0xe0
[1207325.858459]  [<ffffffff82070000>] ? notify_die+0x10/0x40
[1207325.864263]  [<ffffffff8206ef70>] ? kthread_create_on_node+0x180/0x180
[1207325.871288]  [<ffffffff826852d2>] ret_from_fork+0x42/0x70
[1207325.877183]  [<ffffffff8206ef70>] ? kthread_create_on_node+0x180/0x180


Jason Baron (2):
  bnx2x: allocate mac filtering 'mcast_list' in PAGE_SIZE increments
  bnx2x: allocate mac filtering pending list in PAGE_SIZE increments

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  85 ++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c   | 131 ++++++++++++++++-------
 2 files changed, 151 insertions(+), 65 deletions(-)

-- 
2.6.1
