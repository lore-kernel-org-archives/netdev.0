From: Jay Cliburn <jcliburn@gmail.com>
Subject: [net-next-2.6] Null pointer dereference in dev_gso_skb_destructor()
Date: Sun, 5 Oct 2008 13:24:10 -0500
Message-ID: <20081005132410.3a6faf95@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jacliburn@bellsouth.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.244]:26980 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756265AbYJESYQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 14:24:16 -0400
Received: by hs-out-0708.google.com with SMTP id 4so843696hsl.5
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 11:24:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears as though the following net-next-2.6 commit (pulled Oct 1
2008) exposes a null pointer dereference in
dev.c:dev_gso_skb_destructor().

commit 242f8bfefe4bed626df4e4727ac8f315d80b567a
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Sep 22 22:15:30 2008 -0700

    pkt_sched: Make qdisc->gso_skb a list.
    
    The idea is that we can use this to get rid of
    ->requeue().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

>From what I can tell, dev_gso_skb_descructor() is being handed an skb
with skb->next set to NULL.  I verified this by inserting a BUG_ON as
indicated here.

static void dev_gso_skb_destructor(struct sk_buff *skb)
{
	struct dev_gso_cb *cb;

	BUG_ON(!skb->next);  <---------

	do {
		struct sk_buff *nskb = skb->next;

		skb->next = nskb->next;
		nskb->next = NULL;
		kfree_skb(nskb);
	} while (skb->next);

	cb = DEV_GSO_CB(skb);
	if (cb->destructor)
		cb->destructor(skb);
}

Sure enough, I hit the BUG_ON, but unfortunately no trace was produced.

I don't know enough about net core to understand why, but I encounter
the bug only when commit 242f8bfe is applied (as confirmed by
git-bisect). Due to merge conflicts, I'm unable to revert the commit.

This is reproducible using bog standard iperf runs (iperf -s at one
end, iperf -c <addr> at the other).  The oops occurs at the client end.

NB: I just verified the bug is present in current net-next-2.6 (HEAD
e69c4e0f1210450841e40716894ba6a877b31d52).

Here's the oops captured from a serial console.

[  737.313347] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
[  737.314127] IP: [<ffffffff81222025>] dev_gso_skb_destructor+0x14/0x3e
[  737.314127] PGD aade8067 PUD aace4067 PMD 0 
[  737.314127] Oops: 0000 [1] SMP DEBUG_PAGEALLOC
[  737.314127] CPU 1 
[  737.314127] Modules linked in: atl1 sit tunnel4 fuse nf_conntrack_ipv4 ipt_REJECT iptable_filter ip_tables ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state nf_conntrack ip6tabl]
[  737.314127] Pid: 8298, comm: iperf Not tainted 2.6.27-rc8 #4
[  737.314127] RIP: 0010:[<ffffffff81222025>]  [<ffffffff81222025>] dev_gso_skb_destructor+0x14/0x3e
[  737.314127] RSP: 0018:ffff8800be5d38f8  EFLAGS: 00010296
[  737.314127] RAX: 0000000000000100 RBX: ffff8800c8d564e8 RCX: ffff8800c8d564e8
[  737.314127] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000000
[  737.314127] RBP: ffff8800be5d3908 R08: 0000000000000001 R09: ffff8800d3c52ca0
[  737.314127] R10: 0000000000000001 R11: ffff8800be5d3958 R12: ffff8800c8d564e8
[  737.314127] R13: ffff8800d0c1e588 R14: ffff8800d3c520a0 R15: ffff8800d0c1e578
[  737.314127] FS:  0000000040f4c950(0063) GS:ffff8800d78474b0(0000) knlGS:0000000000000000
[  737.314127] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  737.314127] CR2: 0000000000000000 CR3: 00000000aacc0000 CR4: 00000000000006e0
[  737.314127] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  737.314127] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  737.314127] Process iperf (pid: 8298, threadinfo ffff8800be5d2000, task ffff8800c46e5e80)
[  737.314127] Stack:  ffff8800c8d564e8 ffff8800c8d564e8 ffff8800be5d3928 ffffffff8121d89f
[  737.314127]  ffff8800be5d3958 ffff8800c8d564e8 ffff8800be5d3948 ffffffff8121cdd8
[  737.314127]  ffff8800c8d564e8 ffff8800aaddfb80 ffff8800be5d3958 ffffffff8121ce73
[  737.314127] Call Trace:
[  737.314127]  [<ffffffff8121d89f>] skb_release_head_state+0x6d/0xcb
[  737.314127]  [<ffffffff8121cdd8>] __kfree_skb+0x16/0x85
[  737.314127]  [<ffffffff8121ce73>] kfree_skb+0x2c/0x2e
[  737.314127]  [<ffffffff8122393e>] dev_hard_start_xmit+0x284/0x295
[  737.314127]  [<ffffffff812335dc>] __qdisc_run+0x124/0x23d
[  737.314127]  [<ffffffff81223de5>] dev_queue_xmit+0x383/0x4bb
[  737.314127]  [<ffffffff81223baf>] ? dev_queue_xmit+0x14d/0x4bb
[  737.314127]  [<ffffffff81249218>] ip_finish_output+0x213/0x258
[  737.314127]  [<ffffffff812492fd>] ip_output+0xa0/0xa5
[  737.314127]  [<ffffffff812483cf>] ip_local_out+0x25/0x29
[  737.314127]  [<ffffffff81248c4f>] ip_queue_xmit+0x2e9/0x33f
[  737.314127]  [<ffffffff8124fd46>] ? sk_stream_alloc_skb+0x3d/0xf2
[  737.314127]  [<ffffffff81259724>] tcp_transmit_skb+0x616/0x659
[  737.314127]  [<ffffffff8125c0d8>] __tcp_push_pending_frames+0x747/0x85d
[  737.314127]  [<ffffffff812a6d82>] ? _spin_unlock_bh+0x34/0x38
[  737.314127]  [<ffffffff81218e6f>] ? release_sock+0x36/0xdb
[  737.314127]  [<ffffffff81250747>] tcp_sendmsg+0x94c/0xa6a
[  737.314127]  [<ffffffff81216273>] sock_aio_write+0x13c/0x150
[  737.314127]  [<ffffffff8105345d>] ? lock_hrtimer_base+0x2a/0x50
[  737.314127]  [<ffffffff81149999>] ? _raw_spin_lock+0x68/0x10a
[  737.314127]  [<ffffffff810b1476>] do_sync_write+0xec/0x132
[  737.314127]  [<ffffffff810505f1>] ? autoremove_wake_function+0x0/0x3d
[  737.314127]  [<ffffffff810b2534>] ? fget_light+0x50/0xe4
[  737.314127]  [<ffffffff8110de7c>] ? security_file_permission+0x16/0x18
[  737.314127]  [<ffffffff810b1def>] vfs_write+0xc6/0x15c
[  737.314127]  [<ffffffff810b1f53>] sys_write+0x4c/0x75
[  737.314127]  [<ffffffff8100c19a>] system_call_fastpath+0x16/0x1b
[  737.314127] 
[  737.314127] 
[  737.314127] Code: ff ff 4c 89 e7 4d 8b 24 24 4c 39 ef 75 c9 5b 41 5c 41 5d 41 5e c9 c3 55 48 89 e5 53 48 83 ec 08 e8 61 9f de ff 48 89 fb 48 8b 3b <48> 8b 07 48 89 03 48 c7 07  
[  737.314127] RIP  [<ffffffff81222025>] dev_gso_skb_destructor+0x14/0x3e
[  737.314127]  RSP <ffff8800be5d38f8>
[  737.314127] CR2: 0000000000000000
[  738.502779] ---[ end trace df7cc55b4ac2d88b ]---
[  738.516617] Kernel panic - not syncing: Aiee, killing interrupt handler!

--
Jay
