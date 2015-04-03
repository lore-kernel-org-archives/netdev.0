From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: neigh use-after-free
Date: Fri, 3 Apr 2015 13:27:53 -0700
Message-ID: <20150403202753.GF32724@Sligo.logfs.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Alexei Potashnik <alexei@purestorage.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog114.obsmtp.com ([74.125.245.96]:41808 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752574AbbDCUee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 16:34:34 -0400
Received: by pdea3 with SMTP id a3so80355449pde.3
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 13:34:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

After hunting down a mystery crash in the timer code, we added a debug
patch (attached) and got two useful backtraces.

[ 4974.815900] ------------[ cut here ]------------
[ 4974.815914] WARNING: at include/net/neighbour.h:315 neigh_hold.part.26+0x1e/0x27()
[ 4974.815987] CPU: 47 PID: 9066 Comm: iscsi_ttx-8 Tainted: G           O 3.10.59+
[ 4974.815989] Hardware name:    /0X3D66, BIOS 2.0.19 08/29/2013
[ 4974.815990]  0000000000000009 ffff884d472e1828 ffffffff8163baae ffff884d472e1860
[ 4974.815998]  ffffffff8103f141 ffff884e267e0c00 ffff884d55121ef0 ffff884e267e0c28
[ 4974.816001]  0000000000000000 ffff887f0aad2b58 ffff884d472e1870 ffffffff8103f21a
[ 4974.816004] Call Trace:
[ 4974.816012]  [<ffffffff8163baae>] dump_stack+0x19/0x1b
[ 4974.816017]  [<ffffffff8103f141>] warn_slowpath_common+0x61/0x80
[ 4974.816019]  [<ffffffff8103f21a>] warn_slowpath_null+0x1a/0x20
[ 4974.816021]  [<ffffffff8163de95>] neigh_hold.part.26+0x1e/0x27
[ 4974.816027]  [<ffffffff8155f08c>] neigh_add_timer+0x3c/0x60
[ 4974.816029]  [<ffffffff8155f1ab>] __neigh_event_send+0xfb/0x220
[ 4974.816031]  [<ffffffff8155f40b>] neigh_resolve_output+0x13b/0x220
[ 4974.816038]  [<ffffffff8158c950>] ip_finish_output+0x1b0/0x3b0
[ 4974.816040]  [<ffffffff8158ddd8>] ip_output+0x58/0x90
[ 4974.816042]  [<ffffffff8158d5a5>] ip_local_out+0x25/0x30
[ 4974.816045]  [<ffffffff8158d8f7>] ip_queue_xmit+0x137/0x380
[ 4974.816051]  [<ffffffff815a47a5>] tcp_transmit_skb+0x445/0x8a0
[ 4974.816054]  [<ffffffff815a4d40>] tcp_write_xmit+0x140/0xb00
[ 4974.816058]  [<ffffffff815a59ae>] __tcp_push_pending_frames+0x2e/0xc0
[ 4974.816062]  [<ffffffff81597198>] tcp_sendmsg+0x118/0xd90
[ 4974.816070]  [<ffffffff81278b55>] ? debug_object_deactivate+0x115/0x170
[ 4974.816076]  [<ffffffff815bf434>] inet_sendmsg+0x64/0xb0
[ 4974.816080]  [<ffffffff8153da56>] sock_sendmsg+0x76/0x90
[ 4974.816086]  [<ffffffff81046e89>] ? local_bh_enable_ip+0x89/0xf0
[ 4974.816092]  [<ffffffff81641d75>] ? _raw_spin_lock_irqsave+0x25/0x60
[ 4974.816095]  [<ffffffff8153daa7>] kernel_sendmsg+0x37/0x50
[ 4974.816106]  [<ffffffffa06e6536>] tx_data+0xb6/0x160 [iscsi_target_mod]
[ 4974.816111]  [<ffffffffa06e661a>] iscsit_send_tx_data+0x3a/0x90 [iscsi_target_mod]
[ 4974.816116]  [<ffffffffa06e899d>] iscsit_send_unsolicited_nopin+0x7d/0x170 [iscsi_target_mod]
[ 4974.816121]  [<ffffffffa06e92c5>] iscsit_immediate_queue+0x355/0x4c0 [iscsi_target_mod]
[ 4974.816126]  [<ffffffffa06ebb08>] ? iscsi_target_tx_thread+0xe8/0x240 [iscsi_target_mod]
[ 4974.816131]  [<ffffffffa06ebb16>] iscsi_target_tx_thread+0xf6/0x240 [iscsi_target_mod]
[ 4974.816135]  [<ffffffff810657e0>] ? wake_up_bit+0x30/0x30
[ 4974.816140]  [<ffffffffa06eba20>] ? iscsit_thread_get_cpumask+0x30/0x30 [iscsi_target_mod]
[ 4974.816142]  [<ffffffff81064aa0>] kthread+0xc0/0xd0
[ 4974.816145]  [<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x120
[ 4974.816150]  [<ffffffff8164a56c>] ret_from_fork+0x7c/0xb0
[ 4974.816152]  [<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x120
[ 4974.816153] ---[ end trace 1e6b1f72dd5d5dc7 ]---
[ 4974.885829] ------------[ cut here ]------------
[ 4974.885841] WARNING: at lib/debugobjects.c:260 debug_print_object+0x83/0xa0()
[ 4974.885846] ODEBUG: free active (active state 0) object type: timer_list hint: neigh_timer_handler+0x0/0x310
[ 4974.885920] CPU: 46 PID: 240 Comm: ksoftirqd/46 Tainted: G        W  O 3.10.59+
[ 4974.885923]  0000000000000009 ffff883f268edc18 ffffffff8163baae ffff883f268edc50
[ 4974.885927]  ffffffff8103f141 ffff884d77102f28 ffffffff81e356e0 ffffffff81b70b74
[ 4974.885932]  ffffffff83113a10 0000000000000001 ffff883f268edcb0 ffffffff8103f1ac
[ 4974.885935] Call Trace:
[ 4974.885942]  [<ffffffff8163baae>] dump_stack+0x19/0x1b
[ 4974.885946]  [<ffffffff8103f141>] warn_slowpath_common+0x61/0x80
[ 4974.885948]  [<ffffffff8103f1ac>] warn_slowpath_fmt+0x4c/0x50
[ 4974.885950]  [<ffffffff81278233>] debug_print_object+0x83/0xa0
[ 4974.885953]  [<ffffffff815604d0>] ? neigh_periodic_work+0x1f0/0x1f0
[ 4974.885956]  [<ffffffff8127936b>] debug_check_no_obj_freed+0x20b/0x250
[ 4974.885959]  [<ffffffff810bd901>] ? rcu_process_callbacks+0x261/0x5f0
[ 4974.885963]  [<ffffffff81142840>] kfree+0x90/0x160
[ 4974.885965]  [<ffffffff810bd901>] rcu_process_callbacks+0x261/0x5f0
[ 4974.885969]  [<ffffffff81047e3f>] __do_softirq+0xff/0x250
[ 4974.885971]  [<ffffffff81047fcd>] run_ksoftirqd+0x3d/0x60
[ 4974.885974]  [<ffffffff8106c95f>] smpboot_thread_fn+0xff/0x1a0
[ 4974.885977]  [<ffffffff8106c860>] ? lg_local_lock_cpu+0x40/0x40
[ 4974.885980]  [<ffffffff81064aa0>] kthread+0xc0/0xd0
[ 4974.885983]  [<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x120
[ 4974.885988]  [<ffffffff8164a56c>] ret_from_fork+0x7c/0xb0
[ 4974.885991]  [<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x120
[ 4974.885992] ---[ end trace 1e6b1f72dd5d5dc8 ]---

neigh_add_timer() takes a reference on an object that already had a
refcount of zero, so neigh_destroy() was called and, module an rcu
grace period, the object has been freed.  That's bad.

Alexei suspects the problem might be in ip_finish_output2().
__ipv4_neigh_lookup_noref() is done inside rcu_read_lock_bh(), so it
should be safe.  Unless we schedule a timer and therefore access the
object after rcu_read_unlock_bh().

Maybe someone more familiar with the code has an idea?

Jörn

--
Money can buy bandwidth, but latency is forever.
-- John R. Mashey

--YiEDa0DAkWCtVeE4
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="net-Check-for-neighbor-refcount-bugs.patch"

>From c61f1fd27e19d6614dcb381b4d8e7bac0429e412 Mon Sep 17 00:00:00 2001
From: Joern Engel <joern@logfs.org>
Date: Thu, 2 Apr 2015 15:19:57 -0700
Subject: [PATCH] net: Check for neighbor refcount bugs

Debugging why we crash in the timer softirq without this is pretty
painful.  Should be low-overhead and give a more meaningful backtrace.

Signed-off-by: Joern Engel <joern@logfs.org>
---
 include/net/neighbour.h | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 7e748ad8b50c..a19d02bb336c 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -297,8 +297,10 @@ static inline struct neigh_parms *neigh_parms_clone(struct neigh_parms *parms)
 
 static inline void neigh_release(struct neighbour *neigh)
 {
-	if (atomic_dec_and_test(&neigh->refcnt))
+	if (atomic_dec_and_test(&neigh->refcnt)) {
+		WARN_ON_ONCE(timer_pending(&neigh->timer));
 		neigh_destroy(neigh);
+	}
 }
 
 static inline struct neighbour * neigh_clone(struct neighbour *neigh)
@@ -308,7 +310,10 @@ static inline struct neighbour * neigh_clone(struct neighbour *neigh)
 	return neigh;
 }
 
-#define neigh_hold(n)	atomic_inc(&(n)->refcnt)
+static inline void neigh_hold(struct neighbour *neigh)
+{
+	WARN_ON_ONCE(atomic_inc_return(&neigh->refcnt) == 1);
+}
 
 static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
-- 
2.1.4


--YiEDa0DAkWCtVeE4--
