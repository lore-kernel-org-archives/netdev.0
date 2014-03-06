From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] [PATCH V6 net-next 0/5] xen-net{back, front}: Multiple transmit and receive queues
Date: Thu, 6 Mar 2014 17:52:59 +0100
Message-ID: <13310465521.20140306175259@eikelenboom.it>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	<paul.durrant@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <david.vrabel@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:59375 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921AbaCFQxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 11:53:07 -0500
In-Reply-To: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Monday, March 3, 2014, 12:47:44 PM, you wrote:


> This patch series implements multiple transmit and receive queues (i.e.
> multiple shared rings) for the xen virtual network interfaces.

> The series is split up as follows:
>  - Patches 1 and 3 factor out the queue-specific data for netback and
>     netfront respectively, and modify the rest of the code to use these
>     as appropriate.
>  - Patches 2 and 4 introduce new XenStore keys to negotiate and use
>    multiple shared rings and event channels, and code to connect these
>    as appropriate.
>  - Patch 5 documents the XenStore keys required for the new feature
>    in include/xen/interface/io/netif.h

> All other transmit and receive processing remains unchanged, i.e. there
> is a kthread per queue and a NAPI context per queue.

> The performance of these patches has been analysed in detail, with
> results available at:

> http://wiki.xenproject.org/wiki/Xen-netback_and_xen-netfront_multi-queue_performance_testing

> To summarise:
>   * Using multiple queues allows a VM to transmit at line rate on a 10
>     Gbit/s NIC, compared with a maximum aggregate throughput of 6 Gbit/s
>     with a single queue.
>   * For intra-host VM--VM traffic, eight queues provide 171% of the
>     throughput of a single queue; almost 12 Gbit/s instead of 6 Gbit/s.
>   * There is a corresponding increase in total CPU usage, i.e. this is a
>     scaling out over available resources, not an efficiency improvement.
>   * Results depend on the availability of sufficient CPUs, as well as the
>     distribution of interrupts and the distribution of TCP streams across
>     the queues.

> Queue selection is currently achieved via an L4 hash on the packet (i.e.
> TCP src/dst port, IP src/dst address) and is not negotiated between the
> frontend and backend, since only one option exists. Future patches to
> support other frontends (particularly Windows) will need to add some
> capability to negotiate not only the hash algorithm selection, but also
> allow the frontend to specify some parameters to this.

> Note that queue selection is a decision by the transmitting system about
> which queue to use for a particular packet. In general, the algorithm
> may differ between the frontend and the backend with no adverse effects.

> Queue-specific XenStore entries for ring references and event channels
> are stored hierarchically, i.e. under .../queue-N/... where N varies
> from 0 to one less than the requested number of queues (inclusive). If
> only one queue is requested, it falls back to the flat structure where
> the ring references and event channels are written at the same level as
> other vif information.

> V6:
> - Use 'max_queues' as the module param. name for both netback and netfront.

> V5:
> - Fix bug in xenvif_free() that could lead to an attempt to transmit an
>   skb after the queue structures had been freed.
> - Improve the XenStore protocol documentation in netif.h.
> - Fix IRQ_NAME_SIZE double-accounting for null terminator.
> - Move rx_gso_checksum_fixup stat into struct xenvif_stats (per-queue).
> - Don't initialise a local variable that is set in both branches (xspath).

> V4:
> - Add MODULE_PARM_DESC() for the multi-queue parameters for netback
>   and netfront modules.
> - Move del_timer_sync() in netfront to after unregister_netdev, which
>   restores the order in which these functions were called before applying
>   these patches.

> V3:
> - Further indentation and style fixups.

> V2:
> - Rebase onto net-next.
- Change queue->>number to queue->id.
> - Add atomic operations around the small number of stats variables that
>   are not queue-specific or per-cpu.
> - Fixup formatting and style issues.
> - XenStore protocol changes documented in netif.h.
> - Default max. number of queues to num_online_cpus().
> - Check requested number of queues does not exceed maximum.

> --
> Andrew J. Bennieston

Hi Andrew,

Just tried your series but i ran into this lockdep warning:

[    0.932289]
[    0.932293] =============================================
[    0.932297] [ INFO: possible recursive locking detected ]
[    0.932302] 3.14.0-rc5-20140306-xennext-netnext-bennie+ #1 Not tainted
[    0.932306] ---------------------------------------------
[    0.932311] xenwatch/26 is trying to acquire lock:
[    0.932315]  (&(&queue->rx_lock)->rlock){+.....}, at: [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
[    0.932328]
[    0.932328] but task is already holding lock:
[    0.932333]  (&(&queue->rx_lock)->rlock){+.....}, at: [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
[    0.932343]
[    0.932343] other info that might help us debug this:
[    0.932348]  Possible unsafe locking scenario:
[    0.932348]
[    0.932353]        CPU0
[    0.932355]        ----
[    0.932358]   lock(&(&queue->rx_lock)->rlock);
[    0.932363]   lock(&(&queue->rx_lock)->rlock);
[    0.932367]
[    0.932367]  *** DEADLOCK ***
[    0.932367]
[    0.932372]  May be due to missing lock nesting notation
[    0.932372]
[    0.932378] 3 locks held by xenwatch/26:
[    0.935540]  #0:  (xenwatch_mutex){+.+.+.}, at: [<ffffffff81581d96>] xenwatch_thread+0x86/0x130
[    0.935540]  #1:  (&(&queue->rx_lock)->rlock){+.....}, at: [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
[    0.935540]  #2:  (&(&queue->tx_lock)->rlock){......}, at: [<ffffffff817b3101>] netback_changed+0xc91/0xea0
[    0.935540]
[    0.935540] stack backtrace:
[    0.935540] CPU: 1 PID: 26 Comm: xenwatch Not tainted 3.14.0-rc5-20140306-xennext-netnext-bennie+ #1
[    0.935540]  ffffffff82766230 ffff88001eac3b98 ffffffff81b83684 ffff88001e97d870
[    0.935540]  ffffffff82766230 ffff88001eac3c68 ffffffff81115b7e 00000000000233a0
[    0.935540]  ffffffff00000003 ffffffff82766230 ffffffff82ca7ec0 5001f47aeae10000
[    0.935540] Call Trace:
[    0.935540]  [<ffffffff81b83684>] dump_stack+0x46/0x58
[    0.935540]  [<ffffffff81115b7e>] __lock_acquire+0x86e/0x2220
[    0.935540]  [<ffffffff811e40be>] ? kfree+0x1ee/0x200
[    0.935540]  [<ffffffff81117b9d>] lock_acquire+0xbd/0x150
[    0.935540]  [<ffffffff817b30f4>] ? netback_changed+0xc84/0xea0
[    0.935540]  [<ffffffff81b8c4fe>] ? mutex_unlock+0xe/0x10
[    0.935540]  [<ffffffff817b00f4>] ? xennet_release_tx_bufs+0x104/0x110
[    0.935540]  [<ffffffff81b8d7cf>] _raw_spin_lock_bh+0x3f/0x50
[    0.935540]  [<ffffffff817b30f4>] ? netback_changed+0xc84/0xea0
[    0.935540]  [<ffffffff817b30f4>] netback_changed+0xc84/0xea0
[    0.935540]  [<ffffffff815835f0>] xenbus_otherend_changed+0xb0/0xc0
[    0.935540]  [<ffffffff81581d10>] ? xs_watch+0x60/0x60
[    0.935540]  [<ffffffff815851d3>] backend_changed+0x13/0x20
[    0.935540]  [<ffffffff81581d55>] xenwatch_thread+0x45/0x130
[    0.935540]  [<ffffffff8110d590>] ? __init_waitqueue_head+0x60/0x60
[    0.935540]  [<ffffffff810ee394>] kthread+0xe4/0x100
[    0.935540]  [<ffffffff81b8ddb0>] ? _raw_spin_unlock_irq+0x30/0x50
[    0.935540]  [<ffffffff810ee2b0>] ? __init_kthread_worker+0x70/0x70
[    0.935540]  [<ffffffff81b8efbc>] ret_from_fork+0x7c/0xb0
[    0.935540]  [<ffffffff810ee2b0>] ? __init_kthread_worker+0x70/0x70



--
Sander
