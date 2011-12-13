From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [PATCH] net: do not pass vlan pkts to real dev pkt handler also
Date: Mon, 12 Dec 2011 17:08:52 -0800
Message-ID: <1323738532.8333.7.camel@vi>
References: <20111212221923.5356.43629.stgit@vifc.jf.intel.com>
	 <20111212225622.GA7083@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	devel@open-fcoe.org, eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49234 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753685Ab1LMB45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 20:56:57 -0500
In-Reply-To: <20111212225622.GA7083@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-12-12 at 23:56 +0100, Jiri Pirko wrote: 
> Mon, Dec 12, 2011 at 11:19:23PM CET, vasu.dev@intel.com wrote:
> >The orig_dev has to be updated before going another round
> >for vlan pkts, otherwise currently unmodified real orig_dev
> >causes vlan pkt delivered to real orig_dev also.
> >
> >The fcoe stack doesn't expects its vlan pkts on real dev
> >and it causes crash in fcoe stack.
> 
> Could you please provide more info on where exactly it would crash and
> why?

Its in fcoe stack due to its fip rx skb list getting corrupt as same skb
instance getting queued twice without being cloned, though list was well
protected by its spin lock, it was queued on its two fcoe instances, one
on real dev and other on its vlan.

I could also handle this gracefully in fcoe stack by cloning but any
case netdev should not forward vlan pkt to its read dev pkt handler also
and that is getting fixed with this patch, so patch will restore
orig_dev uses for *only* vlan pkts as it was with recursive
__netif_receive_skb calling prior to commit 0dfe178.

Here is the detailed crash log:

[  340.679591] BUG: unable to handle kernel NULL pointer dereference at
0000000000000008
[  340.680112] IP: [<ffffffff815088a5>] skb_dequeue+0x55/0x90
[  340.680112] PGD 0
[  340.680112] Oops: 0002 [#1] SMP
[  340.680112] CPU 3
[  340.680112] Modules linked in: fcoe libfcoe libfc scsi_transport_fc
8021q e1000 virtio_balloon ixgbe mdio virtio_blk virtio_pci virtio_ring
virtio [last unloaded: scsi_wait_scan]
[  340.680112]
[  340.680112] Pid: 442, comm: kworker/3:1 Not tainted 3.2.0-rc4+ #53
Bochs Bochs
[  340.680112] RIP: 0010:[<ffffffff815088a5>]  [<ffffffff815088a5>]
skb_dequeue+0x55/0x90
[  340.680112] RSP: 0018:ffff88007c963c80  EFLAGS: 00010097
[  340.680112] RAX: 0000000000000282 RBX: ffff88007baee9b4 RCX:
0000000000000000
[  340.680112] RDX: 0000000000000000 RSI: 0000000000000286 RDI:
ffff88007baee9b4
[  340.680112] RBP: ffff88007c963ca0 R08: ffff88007c35ddc0 R09:
0000000000000001
[  340.680112] R10: 0000000000000006 R11: 0000000000000001 R12:
ffff88007bedca00
[  340.680112] R13: ffff88007baee9a0 R14: ffff88007c963d80 R15:
ffff88007baeea00
[  340.680112] FS:  0000000000000000(0000) GS:ffff88007fd80000(0000)
knlGS:0000000000000000
[  340.680112] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  340.680112] CR2: 0000000000000008 CR3: 0000000001c05000 CR4:
00000000000006e0
[  340.680112] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[  340.680112] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[  340.680112] Process kworker/3:1 (pid: 442, threadinfo
ffff88007c962000, task ffff88007c9f60b0)
[  340.680112] Stack:
[  340.680112]  ffff88007baee9a0 ffff88007baee8c0 ffff88007baee9a0
ffff88007bedca00
[  340.680112]  ffff88007c963df0 ffffffffa00af7a7 ffff88007baad4d4
ffffffff81060dee
[  340.680112]  0000000000000001 ffff88007c35ddc0 ffff88007c963fd8
0000000000000000
[  340.680112] Call Trace:
[  340.680112]  [<ffffffffa00af7a7>] fcoe_ctlr_recv_work+0x147/0x1870
[libfcoe]
[  340.680112]  [<ffffffff81060dee>] ? queue_delayed_work_on+0x9e/0x170
[  340.680112]  [<ffffffffa00af660>] ? fcoe_ctlr_vn_recv+0x9a0/0x9a0
[libfcoe]
[  340.680112]  [<ffffffff810612de>] process_one_work+0x11e/0x460
[  340.680112]  [<ffffffff81063af8>] worker_thread+0x178/0x400
[  340.680112]  [<ffffffff81063980>] ? manage_workers+0x210/0x210
[  340.680112]  [<ffffffff81068576>] kthread+0x96/0xa0
[  340.680112]  [<ffffffff81663c74>] kernel_thread_helper+0x4/0x10
[  340.680112]  [<ffffffff810684e0>] ? kthread_worker_fn+0x1a0/0x1a0
[  340.680112]  [<ffffffff81663c70>] ? gs_change+0xb/0xb
[  340.680112] Code: 65 00 4d 39 e5 74 4f 4d 85 e4 74 26 41 83 6d 10 01
49 8b 0c 24 49 8b 54 24 08 49 c7 04 24 00 00 00 00 49 c7 44 24 08 00 00
00 00
[  340.680112]  89 51 08 48 89 0a 48 89 c6 48 89 df e8 39 1b 15 00 4c 89
e0
[  340.680112] RIP  [<ffffffff815088a5>] skb_dequeue+0x55/0x90
[  340.680112]  RSP <ffff88007c963c80>
[  340.680112] CR2: 0000000000000008



Thanks
Vasu

> 
> Thanks.
> 
> Jirka
> 
> >
> >This wasn't issue untill __netif_receive_skb recursive calling
> >was removed with this commit 0dfe178, so this patch restores
> >orig_dev uses as it was prior to that commit but still w/o
> >recursive calling to __netif_receive_skb.
> >
> >Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> >---
> >
> > net/core/dev.c |    5 +++--
> > 1 files changed, 3 insertions(+), 2 deletions(-)
> >
> >diff --git a/net/core/dev.c b/net/core/dev.c
> >index f494675..adbcd7a 100644
> >--- a/net/core/dev.c
> >+++ b/net/core/dev.c
> >@@ -3222,9 +3222,10 @@ ncls:
> > 			ret = deliver_skb(skb, pt_prev, orig_dev);
> > 			pt_prev = NULL;
> > 		}
> >-		if (vlan_do_receive(&skb, !rx_handler))
> >+		if (vlan_do_receive(&skb, !rx_handler)) {
> >+			orig_dev = skb->dev;
> > 			goto another_round;
> >-		else if (unlikely(!skb))
> >+		} else if (unlikely(!skb))
> > 			goto out;
> > 	}
> > 
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
