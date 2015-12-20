From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] dccp: fix use-after-free after cloning struct dccp_sock
Date: Sun, 20 Dec 2015 21:53:27 +0100
Message-ID: <1450644807-852-1-git-send-email-vegard.nossum@oracle.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>
To: "David S. Miller" <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've observed various spew (KASAN, warnings, oopses, etc.) that seem to
stem from incorrect cloning of dccp_sock in dccp_create_openreq_child().

The problem is that struct dccp_sock's
  ->dccps_hc_rx_ackvec,
  ->dccps_hc_rx_ccid, and
  ->dccps_hc_tx_ccid
members are pointers to memory which is not reference counted and not
protected by any locks, so sharing them between original sock and the
clone seems like a bad idea.

The usual symptom would be a use-after-free which happens when an
operation on the original sock causes any of these pointers to be freed
followed by an operation on the cloned sock:

==================================================================
BUG: KASAN: use-after-free in dccp_sync_mss+0x45/0x160 at addr ffff880012c65780
Read of size 8 by task a.out/987
=============================================================================
BUG ccid2_hc_tx_sock (Tainted: G        W      ): kasan: bad access detected
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: Allocated in ccid_new+0x1b4/0x270 age=64589 cpu=0 pid=986
        ___slab_alloc+0x724/0x810
        __slab_alloc.isra.49+0x86/0xc0
        kmem_cache_alloc+0x25a/0x2d0
        ccid_new+0x1b4/0x270
        dccp_hdlr_ccid+0x26/0xe0
        __dccp_feat_activate+0xc3/0x180
        dccp_feat_activate_values+0x2fa/0x4c0
        dccp_rcv_state_process+0x814/0xa80
        dccp_v4_do_rcv+0x6a/0x100
        release_sock+0x168/0x330
        inet_stream_connect+0x6d/0x90
        SYSC_connect+0x1d0/0x200
        SyS_connect+0x11/0x20
        entry_SYSCALL_64_fastpath+0x12/0x71
INFO: Freed in ccid_hc_tx_delete+0x7d/0x90 age=11330 cpu=1 pid=989
        __slab_free+0x1f0/0x360
        kmem_cache_free+0x2b6/0x300
        ccid_hc_tx_delete+0x7d/0x90
        dccp_hdlr_ccid+0x65/0xe0
        __dccp_feat_activate+0xc3/0x180
        dccp_feat_activate_values+0x2fa/0x4c0
        dccp_create_openreq_child+0x1fc/0x290
        dccp_v4_request_recv_sock+0x67/0x430
        dccp_check_req+0x248/0x330
        dccp_v4_rcv+0x2a8/0xd50
        ip_local_deliver_finish+0x160/0x4c0
        ip_local_deliver+0x175/0x230
        ip_rcv_finish+0x119/0x750
        ip_rcv+0x678/0x960
        __netif_receive_skb_core+0xe64/0x1810
        __netif_receive_skb+0x41/0xf0
INFO: Slab 0xffffea00004b1800 objects=20 used=9 fp=0xffff880012c644c0 flags=0x100000000004080
INFO: Object 0xffff880012c65780 @offset=22400 fp=0xffff880012c60c80
[...]
CPU: 0 PID: 987 Comm: a.out Tainted: G    B   W       4.4.0-rc5+ #76
 ffffea00004b1800 ffff88001304fa40 ffffffff8169ed5b ffff88001422e800
 ffff88001304fa70 ffffffff812e36ec ffff88001422e800 ffffea00004b1800
 ffff880012c65780 000000000000ffff ffff88001304fa98 ffffffff812e946f
Call Trace:
 [<ffffffff8169ed5b>] dump_stack+0x8d/0xe2
 [<ffffffff812e36ec>] print_trailer+0x13c/0x1b0
 [<ffffffff812e946f>] object_err+0x3f/0x50
 [<ffffffff812f02c3>] kasan_report_error+0x2e3/0x6e0
 [<ffffffff8108d321>] ? kvm_clock_get_cycles+0x11/0x20
 [<ffffffff81e8fb33>] ? secure_dccp_sequence_number+0x133/0x1d0
 [<ffffffff812f0704>] kasan_report+0x44/0x50
 [<ffffffff82207155>] ? dccp_sync_mss+0x45/0x160
 [<ffffffff812ef403>] __asan_load8+0x93/0xe0
 [<ffffffff82207155>] dccp_sync_mss+0x45/0x160
 [<ffffffff822080df>] dccp_connect+0x7f/0x2a0
 [<ffffffff82217632>] dccp_v4_connect+0x612/0x960
 [<ffffffff81ff20a7>] __inet_stream_connect+0x1d7/0x6a0
 [<ffffffff8110438b>] ? preempt_count_sub+0x1b/0x170
 [<ffffffff824cd007>] ? _raw_spin_unlock_irqrestore+0x47/0x90
 [<ffffffff81ff1ed0>] ? inet_sendpage+0x200/0x200
 [<ffffffff811302c1>] ? __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
 [<ffffffff8110438b>] ? preempt_count_sub+0x1b/0x170
 [<ffffffff810baa41>] ? __local_bh_enable_ip+0x61/0x110
 [<ffffffff81ff25c1>] inet_stream_connect+0x51/0x90
 [<ffffffff81e671a0>] SYSC_connect+0x1d0/0x200
 [<ffffffff81ff2570>] ? __inet_stream_connect+0x6a0/0x6a0
 [<ffffffff81e66fd0>] ? ___sys_recvmsg+0x3d0/0x3d0
 [<ffffffff81384490>] ? SyS_epoll_create+0x1a0/0x1a0
 [<ffffffff813372e5>] ? __fget+0x115/0x180
 [<ffffffff8133739d>] ? __fget_light+0x4d/0xf0
 [<ffffffff813822e0>] ? ep_poll_wakeup_proc+0x30/0x30
 [<ffffffff81e69e71>] SyS_connect+0x11/0x20
 [<ffffffff824cdd6e>] entry_SYSCALL_64_fastpath+0x12/0x71

I'm not really sure if setting them to NULL is really the correct
solution -- maybe we should try to duplicate the pointed-to memory
instead?

Anyway, this is a tentative patch that explains the issue and fixes
this particular problem -- dccp fuzzing now runs for minutes rather
than seconds before encountering a crash. I haven't tested any
real world workloads on this patch.

Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 net/dccp/minisocks.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 1994f8a..3c349e7 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -115,6 +115,10 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
 		newdp->dccps_isr = dreq->dreq_isr;
 		newdp->dccps_gsr = dreq->dreq_gsr;
 
+		newdp->dccps_hc_rx_ackvec = NULL;
+		newdp->dccps_hc_rx_ccid = NULL;
+		newdp->dccps_hc_tx_ccid = NULL;
+
 		/*
 		 * Activate features: initialise CCIDs, sequence windows etc.
 		 */
-- 
1.9.1
