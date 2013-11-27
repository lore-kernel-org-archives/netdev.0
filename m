From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net] af_packet: use spin_lock_bh() for sk_buff_head
Date: Wed, 27 Nov 2013 13:57:55 +0100
Message-ID: <1385557075-8896-1-git-send-email-vfalico@redhat.com>
Cc: jstancek@redhat.com, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135Ab3K0M5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 07:57:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While running a debug kernel, a warning of inconsistent lock state showed
up for sk->sk_receive_queue->lock between packet_set_ring() (actually,
static prb_shutdown_retire_blk_timer(), which does spin_lock()) and
sock_queue_rcv_skb(), which does spin_lock_irqsave().

Fix this by converting the spin_lock() used in
prb_shutdown_retire_blk_timer() to spin_lock_bh(), as it is used in
packet_set_ring().

CC: "David S. Miller" <davem@davemloft.net>
CC: Daniel Borkmann <dborkman@redhat.com>
CC: Willem de Bruijn <willemb@google.com>
CC: Phil Sutter <phil@nwl.cc>
CC: Eric Dumazet <edumazet@google.com>
Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    I'm not sure if it's the proper fix - as it might hide bigger problems,
    and I'm not really comfortable with the current mixing spin_lock_irqsave()
    and spin_lock_bh().
    
    The complete warning is:
    
    [ 1057.914735] =================================
    [ 1057.919091] [ INFO: inconsistent lock state ]
    [ 1057.923443] 3.13.0-rc1+ #1 Not tainted
    [ 1057.927186] ---------------------------------
    [ 1057.931536] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
    [ 1057.937541] dumpcap/9377 [HC0[0]:SC0[0]:HE1:SE1] takes:
    [ 1057.942764]  (&(&list->lock)->rlock){+.?...}, at: [<ffffffff81673ee0>] packet_set_ring+0x5a0/0x760
    [ 1057.951782] {IN-SOFTIRQ-W} state was registered at:
    [ 1057.956653]   [<ffffffff810d4c7b>] __lock_acquire+0x59b/0x1a80
    [ 1057.962509]   [<ffffffff810d6952>] lock_acquire+0xa2/0x1d0
    [ 1057.968001]   [<ffffffff816a3916>] _raw_spin_lock_irqsave+0x56/0x90
    [ 1057.974284]   [<ffffffff81545d55>] sock_queue_rcv_skb+0xe5/0x3a0
    [ 1057.980306]   [<ffffffff8164a749>] __udpv6_queue_rcv_skb+0x49/0x250
    [ 1057.986586]   [<ffffffff8164c0cb>] udpv6_queue_rcv_skb+0x24b/0x4e0
    [ 1057.992773]   [<ffffffff8164c7e7>] __udp6_lib_rcv+0x147/0x650
    [ 1057.998527]   [<ffffffff8164cd05>] udpv6_rcv+0x15/0x20
    [ 1058.003671]   [<ffffffff8162cc99>] ip6_input_finish+0x1e9/0x810
    [ 1058.009597]   [<ffffffff8162db52>] ip6_input+0x22/0x60
    [ 1058.014754]   [<ffffffff8162c86f>] ip6_rcv_finish+0x3f/0x280
    [ 1058.020419]   [<ffffffff8162d758>] ipv6_rcv+0x498/0x870
    [ 1058.025661]   [<ffffffff8155c312>] __netif_receive_skb_core+0x9f2/0xdb0
    [ 1058.032281]   [<ffffffff8155c6e8>] __netif_receive_skb+0x18/0x60
    [ 1058.038294]   [<ffffffff8155ec8e>] process_backlog+0xbe/0x1a0
    [ 1058.044048]   [<ffffffff8155e9c2>] net_rx_action+0x162/0x370
    [ 1058.049713]   [<ffffffff8107ae84>] __do_softirq+0x104/0x480
    [ 1058.055293]   [<ffffffff816aedbc>] do_softirq_own_stack+0x1c/0x30
    [ 1058.061393]   [<ffffffff8107b2ed>] do_softirq+0x7d/0x90
    [ 1058.066627]   [<ffffffff8107b495>] local_bh_enable+0xc5/0xd0
    [ 1058.072292]   [<ffffffff816287ee>] ip6_finish_output2+0x1fe/0x810
    [ 1058.078392]   [<ffffffff8162c426>] ip6_finish_output+0x96/0x220
    [ 1058.084317]   [<ffffffff8162c5ff>] ip6_output+0x4f/0x1e0
    [ 1058.089639]   [<ffffffff8166fc19>] ip6_local_out+0x29/0x90
    [ 1058.095139]   [<ffffffff8162a060>] ip6_push_pending_frames+0x2f0/0x4e0
    [ 1058.101680]   [<ffffffff81649719>] udp_v6_push_pending_frames+0x129/0x3d0
    [ 1058.108481]   [<ffffffff8164a296>] udpv6_sendmsg+0x6f6/0xae0
    [ 1058.114158]   [<ffffffff815e5aa7>] inet_sendmsg+0x107/0x220
    [ 1058.119738]   [<ffffffff8154005b>] sock_sendmsg+0x8b/0xc0
    [ 1058.125145]   [<ffffffff81540204>] SYSC_sendto+0x124/0x1d0
    [ 1058.130636]   [<ffffffff8154149e>] SyS_sendto+0xe/0x10
    [ 1058.135792]   [<ffffffff816ad3e9>] system_call_fastpath+0x16/0x1b
    [ 1058.141891] irq event stamp: 12417
    [ 1058.145287] hardirqs last  enabled at (12417): [<ffffffff816a16e0>] __mutex_unlock_slowpath+0xd0/0x1e0
    [ 1058.154603] hardirqs last disabled at (12416): [<ffffffff816a1656>] __mutex_unlock_slowpath+0x46/0x1e0
    [ 1058.163916] softirqs last  enabled at (12412): [<ffffffff81673c36>] packet_set_ring+0x2f6/0x760
    [ 1058.172616] softirqs last disabled at (12410): [<ffffffff816a2e28>] _raw_spin_lock_bh+0x18/0x80
    [ 1058.181314]
    [ 1058.181314] other info that might help us debug this:
    [ 1058.187829]  Possible unsafe locking scenario:
    [ 1058.187829]
    [ 1058.193739]        CPU0
    [ 1058.196188]        ----
    [ 1058.198634]   lock(&(&list->lock)->rlock);
    [ 1058.202756]   <Interrupt>
    [ 1058.205373]     lock(&(&list->lock)->rlock);
    [ 1058.209670]
    [ 1058.209670]  *** DEADLOCK ***
    [ 1058.209670]
    [ 1058.215580] 1 lock held by dumpcap/9377:
    [ 1058.219495]  #0:  (sk_lock-AF_PACKET){+.+.+.}, at: [<ffffffff81673b88>] packet_set_ring+0x248/0x760
    [ 1058.228612]
    [ 1058.228612] stack backtrace:
    [ 1058.232960] CPU: 1 PID: 9377 Comm: dumpcap Not tainted 3.13.0-rc1+ #1
    [ 1058.239390] Hardware name: Dell Inc. PowerEdge R210 II/09T7VV, BIOS 2.0.4 02/29/2012
    [ 1058.247117]  ffffffff82688fe0 ffff880132fedb78 ffffffff81699e80 ffff880138348000
    [ 1058.254569]  ffff880132fedbc8 ffffffff81693c09 0000000000000000 ffff880100000001
    [ 1058.262030]  ffffffff00000001 0000000000000004 ffff880138348000 ffffffff810d3360
    [ 1058.269488] Call Trace:
    [ 1058.271933]  [<ffffffff81699e80>] dump_stack+0x4d/0x66
    [ 1058.277072]  [<ffffffff81693c09>] print_usage_bug+0x1ec/0x1fd
    [ 1058.282815]  [<ffffffff810d3360>] ? print_shortest_lock_dependencies+0x1d0/0x1d0
    [ 1058.290196]  [<ffffffff810d3f5d>] mark_lock+0x21d/0x2a0
    [ 1058.295413]  [<ffffffff810d4ccf>] __lock_acquire+0x5ef/0x1a80
    [ 1058.301149]  [<ffffffff810d42fd>] ? trace_hardirqs_on+0xd/0x10
    [ 1058.306981]  [<ffffffff81022f83>] ? native_sched_clock+0x13/0x80
    [ 1058.312983]  [<ffffffff81022ff9>] ? sched_clock+0x9/0x10
    [ 1058.318287]  [<ffffffff81022f83>] ? native_sched_clock+0x13/0x80
    [ 1058.324290]  [<ffffffff81022ff9>] ? sched_clock+0x9/0x10
    [ 1058.329594]  [<ffffffff81022f83>] ? native_sched_clock+0x13/0x80
    [ 1058.335597]  [<ffffffff81022ff9>] ? sched_clock+0x9/0x10
    [ 1058.340899]  [<ffffffff810d6952>] lock_acquire+0xa2/0x1d0
    [ 1058.346287]  [<ffffffff81673ee0>] ? packet_set_ring+0x5a0/0x760
    [ 1058.352199]  [<ffffffff816a2dce>] _raw_spin_lock+0x3e/0x80
    [ 1058.357683]  [<ffffffff81673ee0>] ? packet_set_ring+0x5a0/0x760
    [ 1058.363599]  [<ffffffff81673ee0>] packet_set_ring+0x5a0/0x760
    [ 1058.369337]  [<ffffffff810d07dd>] ? trace_hardirqs_off+0xd/0x10
    [ 1058.375254]  [<ffffffff8167422d>] packet_release+0x18d/0x2e0
    [ 1058.380910]  [<ffffffff8153f55f>] sock_release+0x1f/0x90
    [ 1058.386214]  [<ffffffff8153f5e2>] sock_close+0x12/0x20
    [ 1058.391352]  [<ffffffff8120702d>] __fput+0xfd/0x310
    [ 1058.396229]  [<ffffffff8120728e>] ____fput+0xe/0x10
    [ 1058.401101]  [<ffffffff8109cdf4>] task_work_run+0xb4/0xe0
    [ 1058.406497]  [<ffffffff8101aaff>] do_notify_resume+0x9f/0xc0
    [ 1058.412153]  [<ffffffff816ad722>] int_signal+0x12/0x17

 net/packet/af_packet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ac27c86..ba2548b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -439,9 +439,9 @@ static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
 
 	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
 
-	spin_lock(&rb_queue->lock);
+	spin_lock_bh(&rb_queue->lock);
 	pkc->delete_blk_timer = 1;
-	spin_unlock(&rb_queue->lock);
+	spin_unlock_bh(&rb_queue->lock);
 
 	prb_del_retire_blk_timer(pkc);
 }
-- 
1.8.4
