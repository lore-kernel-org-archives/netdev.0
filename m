From: Ridge Kennedy <ridge.kennedy@alliedtelesis.co.nz>
Subject: [PATCH net-next] l2tp: Avoid schedule while atomic in exit_net
Date: Wed, 22 Feb 2017 14:59:49 +1300
Message-ID: <20170222015949.18641-1-ridge.kennedy@alliedtelesis.co.nz>
Cc: Ridge Kennedy <ridge.kennedy@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:45422 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753114AbdBVCAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 21:00:06 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id D4EA0805DD
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 15:00:02 +1300 (NZDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While destroying a network namespace that contains a L2TP tunnel a
"BUG: scheduling while atomic" can be observed.

Enabling lockdep shows that this is happening because l2tp_exit_net()
is calling l2tp_tunnel_closeall() (via l2tp_tunnel_delete()) from
within an RCU critical section.

l2tp_exit_net() takes rcu_read_lock_bh()
  << list_for_each_entry_rcu() >>
  l2tp_tunnel_delete()
    l2tp_tunnel_closeall()
      __l2tp_session_unhash()
        synchronize_rcu() << Illegal inside RCU critical section >>

BUG: sleeping function called from invalid context
in_atomic(): 1, irqs_disabled(): 0, pid: 86, name: kworker/u16:2
INFO: lockdep is turned off.
CPU: 2 PID: 86 Comm: kworker/u16:2 Tainted: G        W  O    4.4.6-at1 #2
Hardware name: Xen HVM domU, BIOS 4.6.1-xs125300 05/09/2016
Workqueue: netns cleanup_net
 0000000000000000 ffff880202417b90 ffffffff812b0013 ffff880202410ac0
 ffffffff81870de8 ffff880202417bb8 ffffffff8107aee8 ffffffff81870de8
 0000000000000c51 0000000000000000 ffff880202417be0 ffffffff8107b024
Call Trace:
 [<ffffffff812b0013>] dump_stack+0x85/0xc2
 [<ffffffff8107aee8>] ___might_sleep+0x148/0x240
 [<ffffffff8107b024>] __might_sleep+0x44/0x80
 [<ffffffff810b21bd>] synchronize_sched+0x2d/0xe0
 [<ffffffff8109be6d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8105c7bb>] ? __local_bh_enable_ip+0x6b/0xc0
 [<ffffffff816a1b00>] ? _raw_spin_unlock_bh+0x30/0x40
 [<ffffffff81667482>] __l2tp_session_unhash+0x172/0x220
 [<ffffffff81667397>] ? __l2tp_session_unhash+0x87/0x220
 [<ffffffff8166888b>] l2tp_tunnel_closeall+0x9b/0x140
 [<ffffffff81668c74>] l2tp_tunnel_delete+0x14/0x60
 [<ffffffff81668dd0>] l2tp_exit_net+0x110/0x270
 [<ffffffff81668d5c>] ? l2tp_exit_net+0x9c/0x270
 [<ffffffff815001c3>] ops_exit_list.isra.6+0x33/0x60
 [<ffffffff81501166>] cleanup_net+0x1b6/0x280
 ...

This bug can easily be reproduced with a few steps:

 $ sudo unshare -n bash  # Create a shell in a new namespace
 # ip link set lo up
 # ip addr add 127.0.0.1 dev lo
 # ip l2tp add tunnel remote 127.0.0.1 local 127.0.0.1 tunnel_id 1 \
    peer_tunnel_id 1 udp_sport 50000 udp_dport 50000
 # ip l2tp add session name foo tunnel_id 1 session_id 1 \
    peer_session_id 1
 # ip link set foo up
 # exit  # Exit the shell, in turn exiting the namespace
 $ dmesg
 ...
 [942121.089216] BUG: scheduling while atomic: kworker/u16:3/13872/0x00000200
 ...

To fix this, move the call to l2tp_tunnel_closeall() out of the RCU
critical section, and instead call it from l2tp_tunnel_del_work(), which
is running from the l2tp_wq workqueue.

Fixes: 2b551c6e7d5b ("l2tp: close sessions before initiating tunnel delete")
Signed-off-by: Ridge Kennedy <ridge.kennedy@alliedtelesis.co.nz>
---
 net/l2tp/l2tp_core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 85948c69b236..b58000efee73 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1317,6 +1317,9 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	struct sock *sk = NULL;
 
 	tunnel = container_of(work, struct l2tp_tunnel, del_work);
+
+	l2tp_tunnel_closeall(tunnel);
+
 	sk = l2tp_tunnel_sock_lookup(tunnel);
 	if (!sk)
 		goto out;
@@ -1639,7 +1642,6 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
 int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
 	l2tp_tunnel_inc_refcount(tunnel);
-	l2tp_tunnel_closeall(tunnel);
 	if (false == queue_work(l2tp_wq, &tunnel->del_work)) {
 		l2tp_tunnel_dec_refcount(tunnel);
 		return 1;
-- 
2.11.0
