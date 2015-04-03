From: Alexei Potashnik <alexei@purestorage.com>
Subject: RE: neigh use-after-free
Date: Fri, 3 Apr 2015 13:52:39 -0700
Message-ID: <35adab927f1bade6afd57e62a8720205@mail.gmail.com>
References: <20150403202753.GF32724@Sligo.logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joern Engel <joern@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog105.obsmtp.com ([74.125.245.78]:40345 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752189AbbDCU6J convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 16:58:09 -0400
Received: by widjs5 with SMTP id js5so32321413wid.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 13:58:07 -0700 (PDT)
In-Reply-To: <20150403202753.GF32724@Sligo.logfs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would this be an appropriate solution:

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b49e8ba..38265f2 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -168,7 +168,8 @@ static int neigh_forced_gc(struct neigh_table *tbl)

 static void neigh_add_timer(struct neighbour *n, unsigned long when)
 {
-       neigh_hold(n);
+       if (!atomic_inc_not_zero(&n->refcnt))
+               return;
        if (unlikely(mod_timer(&n->timer, when))) {
                printk("NEIGH: BUG, double timer add, state is %x\n",
                       n->nud_state);

Alexei

-----Original Message-----
=46rom: J=C3=B6rn Engel [mailto:joern@purestorage.com]
Sent: Friday, April 03, 2015 1:28 PM
To: David S. Miller
Cc: netdev@vger.kernel.org; Alexei Potashnik
Subject: neigh use-after-free

After hunting down a mystery crash in the timer code, we added a debug
patch (attached) and got two useful backtraces.

[ 4974.815900] ------------[ cut here ]------------ [ 4974.815914]
WARNING: at include/net/neighbour.h:315 neigh_hold.part.26+0x1e/0x27()
[ 4974.815987] CPU: 47 PID: 9066 Comm: iscsi_ttx-8 Tainted: G          =
 O
3.10.59+
[ 4974.815989] Hardware name:    /0X3D66, BIOS 2.0.19 08/29/2013
[ 4974.815990]  0000000000000009 ffff884d472e1828 ffffffff8163baae
ffff884d472e1860 [ 4974.815998]  ffffffff8103f141 ffff884e267e0c00
ffff884d55121ef0 ffff884e267e0c28 [ 4974.816001]  0000000000000000
ffff887f0aad2b58 ffff884d472e1870 ffffffff8103f21a [ 4974.816004] Call
Trace:
[ 4974.816012]  [<ffffffff8163baae>] dump_stack+0x19/0x1b [ 4974.816017=
]
[<ffffffff8103f141>] warn_slowpath_common+0x61/0x80 [ 4974.816019]
[<ffffffff8103f21a>] warn_slowpath_null+0x1a/0x20 [ 4974.816021]
[<ffffffff8163de95>] neigh_hold.part.26+0x1e/0x27 [ 4974.816027]
[<ffffffff8155f08c>] neigh_add_timer+0x3c/0x60 [ 4974.816029]
[<ffffffff8155f1ab>] __neigh_event_send+0xfb/0x220 [ 4974.816031]
[<ffffffff8155f40b>] neigh_resolve_output+0x13b/0x220 [ 4974.816038]
[<ffffffff8158c950>] ip_finish_output+0x1b0/0x3b0 [ 4974.816040]
[<ffffffff8158ddd8>] ip_output+0x58/0x90 [ 4974.816042]
[<ffffffff8158d5a5>] ip_local_out+0x25/0x30 [ 4974.816045]
[<ffffffff8158d8f7>] ip_queue_xmit+0x137/0x380 [ 4974.816051]
[<ffffffff815a47a5>] tcp_transmit_skb+0x445/0x8a0 [ 4974.816054]
[<ffffffff815a4d40>] tcp_write_xmit+0x140/0xb00 [ 4974.816058]
[<ffffffff815a59ae>] __tcp_push_pending_frames+0x2e/0xc0
[ 4974.816062]  [<ffffffff81597198>] tcp_sendmsg+0x118/0xd90 [
4974.816070]  [<ffffffff81278b55>] ? debug_object_deactivate+0x115/0x17=
0
[ 4974.816076]  [<ffffffff815bf434>] inet_sendmsg+0x64/0xb0 [ 4974.8160=
80]
[<ffffffff8153da56>] sock_sendmsg+0x76/0x90 [ 4974.816086]
[<ffffffff81046e89>] ? local_bh_enable_ip+0x89/0xf0 [ 4974.816092]
[<ffffffff81641d75>] ? _raw_spin_lock_irqsave+0x25/0x60 [ 4974.816095]
[<ffffffff8153daa7>] kernel_sendmsg+0x37/0x50 [ 4974.816106]
[<ffffffffa06e6536>] tx_data+0xb6/0x160 [iscsi_target_mod] [ 4974.81611=
1]
[<ffffffffa06e661a>] iscsit_send_tx_data+0x3a/0x90 [iscsi_target_mod] [
4974.816116]  [<ffffffffa06e899d>]
iscsit_send_unsolicited_nopin+0x7d/0x170 [iscsi_target_mod] [ 4974.8161=
21]
[<ffffffffa06e92c5>] iscsit_immediate_queue+0x355/0x4c0 [iscsi_target_m=
od]
[ 4974.816126]  [<ffffffffa06ebb08>] ? iscsi_target_tx_thread+0xe8/0x24=
0
[iscsi_target_mod] [ 4974.816131]  [<ffffffffa06ebb16>]
iscsi_target_tx_thread+0xf6/0x240 [iscsi_target_mod] [ 4974.816135]
[<ffffffff810657e0>] ? wake_up_bit+0x30/0x30 [ 4974.816140]
[<ffffffffa06eba20>] ? iscsit_thread_get_cpumask+0x30/0x30
[iscsi_target_mod] [ 4974.816142]  [<ffffffff81064aa0>] kthread+0xc0/0x=
d0
[ 4974.816145]  [<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x1=
20
[ 4974.816150]  [<ffffffff8164a56c>] ret_from_fork+0x7c/0xb0 [
4974.816152]  [<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x120
[ 4974.816153] ---[ end trace 1e6b1f72dd5d5dc7 ]--- [ 4974.885829]
------------[ cut here ]------------ [ 4974.885841] WARNING: at
lib/debugobjects.c:260 debug_print_object+0x83/0xa0() [ 4974.885846]
ODEBUG: free active (active state 0) object type: timer_list hint:
neigh_timer_handler+0x0/0x310
[ 4974.885920] CPU: 46 PID: 240 Comm: ksoftirqd/46 Tainted: G        W =
 O
3.10.59+
[ 4974.885923]  0000000000000009 ffff883f268edc18 ffffffff8163baae
ffff883f268edc50 [ 4974.885927]  ffffffff8103f141 ffff884d77102f28
ffffffff81e356e0 ffffffff81b70b74 [ 4974.885932]  ffffffff83113a10
0000000000000001 ffff883f268edcb0 ffffffff8103f1ac [ 4974.885935] Call
Trace:
[ 4974.885942]  [<ffffffff8163baae>] dump_stack+0x19/0x1b [ 4974.885946=
]
[<ffffffff8103f141>] warn_slowpath_common+0x61/0x80 [ 4974.885948]
[<ffffffff8103f1ac>] warn_slowpath_fmt+0x4c/0x50 [ 4974.885950]
[<ffffffff81278233>] debug_print_object+0x83/0xa0 [ 4974.885953]
[<ffffffff815604d0>] ? neigh_periodic_work+0x1f0/0x1f0 [ 4974.885956]
[<ffffffff8127936b>] debug_check_no_obj_freed+0x20b/0x250
[ 4974.885959]  [<ffffffff810bd901>] ? rcu_process_callbacks+0x261/0x5f=
0 [
4974.885963]  [<ffffffff81142840>] kfree+0x90/0x160 [ 4974.885965]
[<ffffffff810bd901>] rcu_process_callbacks+0x261/0x5f0 [ 4974.885969]
[<ffffffff81047e3f>] __do_softirq+0xff/0x250 [ 4974.885971]
[<ffffffff81047fcd>] run_ksoftirqd+0x3d/0x60 [ 4974.885974]
[<ffffffff8106c95f>] smpboot_thread_fn+0xff/0x1a0 [ 4974.885977]
[<ffffffff8106c860>] ? lg_local_lock_cpu+0x40/0x40 [ 4974.885980]
[<ffffffff81064aa0>] kthread+0xc0/0xd0 [ 4974.885983]
[<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x120
[ 4974.885988]  [<ffffffff8164a56c>] ret_from_fork+0x7c/0xb0 [
4974.885991]  [<ffffffff810649e0>] ? kthread_create_on_node+0x120/0x120
[ 4974.885992] ---[ end trace 1e6b1f72dd5d5dc8 ]---

neigh_add_timer() takes a reference on an object that already had a
refcount of zero, so neigh_destroy() was called and, module an rcu grac=
e
period, the object has been freed.  That's bad.

Alexei suspects the problem might be in ip_finish_output2().
__ipv4_neigh_lookup_noref() is done inside rcu_read_lock_bh(), so it
should be safe.  Unless we schedule a timer and therefore access the
object after rcu_read_unlock_bh().

Maybe someone more familiar with the code has an idea?

J=C3=B6rn

--
Money can buy bandwidth, but latency is forever.
-- John R. Mashey
