From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: [PATCH net 1/1 V2] hyperv: Fix a bug in netvsc_start_xmit()
Date: Mon, 29 Sep 2014 19:31:54 +0100
Message-ID: <20140929183154.GA5942@sucs.org>
References: <1411967803-29233-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1411967803-29233-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 28, 2014 at 10:16:43PM -0700, K. Y. Srinivasan wrote:
> After the packet is successfully sent, we should not touch the skb 
> as it may have been freed. This patch is based on the work done by 
> Long Li <longli@microsoft.com>.
> 
> In this version of the patch I have fixed issues pointed out by David.
> David, please queue this up for stable.

This patch resolves the following panic I privately reported to KY on September
3rd 2014:

BUG: unable to handle kernel paging request at ffff8800edeb8068
IP: [<ffffffff814e77ec>] netvsc_start_xmit+0x6ac/0x7c0
PGD 2db0067 PUD 2075be067 PMD 20744e067 PTE 80000000edeb8060
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 3.17.0-rc2.x86_64-00099-g92578ea #139
Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
task: ffff8801fb1b1350 ti: ffff8801fb248000 task.ti: ffff8801fb248000
RIP: 0010:[<ffffffff814e77ec>]  [<ffffffff814e77ec>] netvsc_start_xmit+0x6ac/0x7c0
RSP: 0018:ffff8801fb24b808  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8800efb437c8 RCX: 000000000007f000
RDX: 00000000000782a0 RSI: 000000000000e880 RDI: 000000000007eee8
RBP: ffff8801fb24b850 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
R13: ffff8800edeb8000 R14: ffff8800f11b22a0 R15: ffff8800efb47d0e
FS:  0000000000000000(0000) GS:ffff880206c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff8800edeb8068 CR3: 00000001f6d3d000 CR4: 00000000000406f0
Stack:
 ffff8800efb43834 ffffffff00000042 ffff8800f11b22a0 0000000081d23300
 0000000000000042 ffff8800f11b22a0 0000000000000002 ffff8801f4866a60
 ffff8800edeb8000 ffff8801fb24b8a8 ffffffff815ce528 ffff8800f1164f40
Call Trace:
 [<ffffffff815ce528>] dev_hard_start_xmit+0x348/0x630
 [<ffffffff815ef67a>] sch_direct_xmit+0x7a/0x290
 [<ffffffff815ceb1c>] __dev_queue_xmit+0x30c/0x690
 [<ffffffff815ce868>] ? __dev_queue_xmit+0x58/0x690
 [<ffffffff815ceeb0>] dev_queue_xmit+0x10/0x20
 [<ffffffff8160e6e7>] ip_finish_output+0xaa7/0xc70
 [<ffffffff8160eba8>] ? ip_output+0x98/0xf0
 [<ffffffff8160eba8>] ip_output+0x98/0xf0
 [<ffffffff8160cb71>] ip_local_out_sk+0x71/0xa0
 [<ffffffff8160d19a>] ip_queue_xmit+0x38a/0x480
 [<ffffffff8160ce15>] ? ip_queue_xmit+0x5/0x480
 [<ffffffff81625d69>] tcp_transmit_skb+0x7e9/0x880
 [<ffffffff81628bf7>] tcp_send_ack+0x117/0x120
 [<ffffffff8161bdf8>] __tcp_ack_snd_check+0x58/0xc0
 [<ffffffff81622692>] tcp_rcv_established+0x3f2/0x6e0
 [<ffffffff8162d124>] tcp_v4_do_rcv+0xb4/0x350
 [<ffffffff8162e571>] tcp_v4_rcv+0x631/0xc30
 [<ffffffff81607dc0>] ? ip_local_deliver_finish+0x40/0x2d0
 [<ffffffff81607ed8>] ip_local_deliver_finish+0x158/0x2d0
 [<ffffffff81607dc0>] ? ip_local_deliver_finish+0x40/0x2d0
 [<ffffffff816081f1>] ip_local_deliver+0x51/0x90
 [<ffffffff81607cae>] ip_rcv_finish+0x3ae/0x480
 [<ffffffff8160854c>] ip_rcv+0x31c/0x3a0
 [<ffffffff815ca951>] __netif_receive_skb_core+0x681/0x790
 [<ffffffff815ca37c>] ? __netif_receive_skb_core+0xac/0x790
 [<ffffffff815caab7>] __netif_receive_skb+0x57/0x80
 [<ffffffff815cabaa>] process_backlog+0xca/0x190
 [<ffffffff815cf9e8>] net_rx_action+0x88/0x210
 [<ffffffff81075303>] __do_softirq+0x183/0x320
 [<ffffffff810754c9>] run_ksoftirqd+0x29/0x80
 [<ffffffff810929c7>] smpboot_thread_fn+0x1e7/0x210
 [<ffffffff8169d545>] ? schedule+0x65/0x70
 [<ffffffff810927e0>] ? in_egroup_p+0x40/0x40
 [<ffffffff8108e3a8>] kthread+0xf8/0x100
 [<ffffffff8108e2b0>] ? __kthread_unpark+0x50/0x50
 [<ffffffff816a323c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8108e2b0>] ? __kthread_unpark+0x50/0x50
Code: 4b f2 ff ff 41 01 c6 44 39 7d d4 7f c2 44 89 73 58 4c 8b 75 c8 48 89 de 49 8b be 40 0a 00 00 e8 8b 11 00 00 85 c0 41 89 c4 75 1c <41> 8b 45 68 49 83 86 10 01 00 00 01 49 01 86 20 01 00 00 eb 3f
RIP  [<ffffffff814e77ec>] netvsc_start_xmit+0x6ac/0x7c0
 RSP <ffff8801fb24b808>
CR2: ffff8800edeb8068
---[ end trace 62e7c6df1a71f4a8 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
---[ end Kernel panic - not syncing: Fatal exception in interrupt

So
Tested-by: Sitsofe Wheeler <sitsofe@yahoo.com>

But I'm still seeing oopses like the following:

BUG: unable to handle kernel paging request at ffff8800ec0b9073
IP: [<ffffffff814e8b63>] netvsc_select_queue+0x53/0x160
PGD 2db3067 PUD 2075be067 PMD 20745d067 PTE 80000000ec0b9060
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
CPU: 6 PID: 556 Comm: arping Not tainted 3.17.0-rc7.x86_64-00012-gb6beb72-dirty #145
Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
task: ffff8801f3619350 ti: ffff8801f99ac000 task.ti: ffff8801f99ac000
RIP: 0010:[<ffffffff814e8b63>]  [<ffffffff814e8b63>] netvsc_select_queue+0x53/0x160
RSP: 0018:ffff8801f99afc60  EFLAGS: 00010202
RAX: 0000000000000000 RBX: ffff8800f1231160 RCX: 000000000000ffff
RDX: ffff8800ec0a9068 RSI: ffff8801f357f3c0 RDI: ffff8800f1231160
RBP: ffff8801f99afc88 R08: 000000000000002a R09: 0000000000000000
R10: ffff8800f12333d8 R11: 0000000000000008 R12: ffff8801f357f3c0
R13: 0000000000000000 R14: ffff8801f97b6f60 R15: ffff8801f357f3c0
FS:  00007fb7a6fbb740(0000) GS:ffff880206cc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff8800ec0b9073 CR3: 00000001f3518000 CR4: 00000000000406e0
Stack:
 ffffffff81698f81 ffff8800f1231160 000000000000001c 0000000000000000
 ffff8801f97b6f60 ffff8801f99afd48 ffffffff8169ccec ffff8801f99afcb0
 ffffffff816bbf87 0000000000000001 ffff8801f99afdb8 000000000000001c
Call Trace:
 [<ffffffff81698f81>] ? packet_pick_tx_queue+0x31/0xa0
 [<ffffffff8169ccec>] packet_sendmsg+0xc1c/0xdd0
 [<ffffffff816bbf87>] ? _raw_spin_unlock+0x27/0x40
 [<ffffffff81090fca>] ? prepare_creds+0x3a/0x170
 [<ffffffff815cd978>] sock_sendmsg+0x88/0xb0
 [<ffffffff811856d3>] ? might_fault+0xa3/0xb0
 [<ffffffff8118568a>] ? might_fault+0x5a/0xb0
 [<ffffffff815cdaae>] SYSC_sendto+0x10e/0x150
 [<ffffffff8118568a>] ? might_fault+0x5a/0xb0
 [<ffffffff816bcc95>] ? sysret_check+0x22/0x5d
 [<ffffffff810b97dd>] ? trace_hardirqs_on_caller+0x17d/0x210
 [<ffffffff8139da5e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff815cea8e>] SyS_sendto+0xe/0x10
 [<ffffffff816bcc69>] system_call_fastpath+0x16/0x1b
Code: 00 4d 85 d2 0f 84 16 01 00 00 44 8b 9f 8c 03 00 00 31 c0 41 83 fb 01 0f 86 15 01 00 00 0f b7 8e b4 00 00 00 48 8b 96 c0 00 00 00 <66
RIP  [<ffffffff814e8b63>] netvsc_select_queue+0x53/0x160
 RSP <ffff8801f99afc60>
CR2: ffff8800ec0b9073
---[ end trace 63f1b336a04f57aa ]---

-- 
Sitsofe | http://sucs.org/~sits/
