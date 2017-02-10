From: Anoob Soman <anoob.soman@citrix.com>
Subject: [PATCH net] packet: Do not call fanout_release from atomic contexts
Date: Fri, 10 Feb 2017 12:39:44 +0000
Message-ID: <1486730384-18749-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
        Anoob Soman <anoob.soman@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56965 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752846AbdBJMkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 07:40:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6664498280cf ("packet: call fanout_release, while UNREGISTERING a
netdev"), unfortunately, introduced the following issues.

1. calling mutex_lock(&fanout_mutex) (fanout_release()) from inside
rcu_read-side critical section. rcu_read_lock disables preemption, most often,
which prohibits calling sleeping functions.

[  ] include/linux/rcupdate.h:560 Illegal context switch in RCU read-side critical section!
[  ]
[  ] rcu_scheduler_active = 1, debug_locks = 0
[  ] 4 locks held by ovs-vswitchd/1969:
[  ]  #0:  (cb_lock){++++++}, at: [<ffffffff8158a6c9>] genl_rcv+0x19/0x40
[  ]  #1:  (ovs_mutex){+.+.+.}, at: [<ffffffffa04878ca>] ovs_vport_cmd_del+0x4a/0x100 [openvswitch]
[  ]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81564157>] rtnl_lock+0x17/0x20
[  ]  #3:  (rcu_read_lock){......}, at: [<ffffffff81614165>] packet_notifier+0x5/0x3f0
[  ]
[  ] Call Trace:
[  ]  [<ffffffff813770c1>] dump_stack+0x85/0xc4
[  ]  [<ffffffff810c9077>] lockdep_rcu_suspicious+0x107/0x110
[  ]  [<ffffffff810a2da7>] ___might_sleep+0x57/0x210
[  ]  [<ffffffff810a2fd0>] __might_sleep+0x70/0x90
[  ]  [<ffffffff8162e80c>] mutex_lock_nested+0x3c/0x3a0
[  ]  [<ffffffff810de93f>] ? vprintk_default+0x1f/0x30
[  ]  [<ffffffff81186e88>] ? printk+0x4d/0x4f
[  ]  [<ffffffff816106dd>] fanout_release+0x1d/0xe0
[  ]  [<ffffffff81614459>] packet_notifier+0x2f9/0x3f0

2. calling mutex_lock(&fanout_mutex) inside spin_lock(&po->bind_lock).
"sleeping function called from invalid context"

[  ] BUG: sleeping function called from invalid context at kernel/locking/mutex.c:620
[  ] in_atomic(): 1, irqs_disabled(): 0, pid: 1969, name: ovs-vswitchd
[  ] INFO: lockdep is turned off.
[  ] Call Trace:
[  ]  [<ffffffff813770c1>] dump_stack+0x85/0xc4
[  ]  [<ffffffff810a2f52>] ___might_sleep+0x202/0x210
[  ]  [<ffffffff810a2fd0>] __might_sleep+0x70/0x90
[  ]  [<ffffffff8162e80c>] mutex_lock_nested+0x3c/0x3a0
[  ]  [<ffffffff816106dd>] fanout_release+0x1d/0xe0
[  ]  [<ffffffff81614459>] packet_notifier+0x2f9/0x3f0

3. calling dev_remove_pack(&fanout->prot_hook), from inside
spin_lock(&po->bind_lock) or rcu_read-side critical-section. dev_remove_pack()
-> synchronize_net(), which might sleep.

[  ] BUG: scheduling while atomic: ovs-vswitchd/1969/0x00000002
[  ] INFO: lockdep is turned off.
[  ] Call Trace:
[  ]  [<ffffffff813770c1>] dump_stack+0x85/0xc4
[  ]  [<ffffffff81186274>] __schedule_bug+0x64/0x73
[  ]  [<ffffffff8162b8cb>] __schedule+0x6b/0xd10
[  ]  [<ffffffff8162c5db>] schedule+0x6b/0x80
[  ]  [<ffffffff81630b1d>] schedule_timeout+0x38d/0x410
[  ]  [<ffffffff810ea3fd>] synchronize_sched_expedited+0x53d/0x810
[  ]  [<ffffffff810ea6de>] synchronize_rcu_expedited+0xe/0x10
[  ]  [<ffffffff8154eab5>] synchronize_net+0x35/0x50
[  ]  [<ffffffff8154eae3>] dev_remove_pack+0x13/0x20
[  ]  [<ffffffff8161077e>] fanout_release+0xbe/0xe0
[  ]  [<ffffffff81614459>] packet_notifier+0x2f9/0x3f0

4. fanout_release() races with calls from different CPU.

To fix the above problems, remove the call to fanout_release() under
rcu_read_lock(). Instead, call __dev_remove_pack(&fanout->prot_hook) and
netdev_run_todo will be happy that &dev->ptype_specific list is empty. In order
to achieve this, I moved dev_{add,remove}_pack() out of fanout_{add,release} to
__fanout_{link,unlink}. So, call to {,__}unregister_prot_hook() will make sure
fanout->prot_hook is removed as well.

Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
---
 net/packet/af_packet.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d56ee46..0eb7230 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1497,6 +1497,8 @@ static void __fanout_link(struct sock *sk, struct packet_sock *po)
 	f->arr[f->num_members] = sk;
 	smp_wmb();
 	f->num_members++;
+	if (f->num_members == 1)
+		dev_add_pack(&f->prot_hook);
 	spin_unlock(&f->lock);
 }
 
@@ -1513,6 +1515,8 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
 	BUG_ON(i >= f->num_members);
 	f->arr[i] = f->arr[f->num_members - 1];
 	f->num_members--;
+	if (f->num_members == 0)
+		__dev_remove_pack(&f->prot_hook);
 	spin_unlock(&f->lock);
 }
 
@@ -1687,7 +1691,6 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		match->prot_hook.func = packet_rcv_fanout;
 		match->prot_hook.af_packet_priv = match;
 		match->prot_hook.id_match = match_fanout_group;
-		dev_add_pack(&match->prot_hook);
 		list_add(&match->list, &fanout_list);
 	}
 	err = -EINVAL;
@@ -1726,7 +1729,6 @@ static void fanout_release(struct sock *sk)
 
 	if (atomic_dec_and_test(&f->sk_ref)) {
 		list_del(&f->list);
-		dev_remove_pack(&f->prot_hook);
 		fanout_release_data(f);
 		kfree(f);
 	}
@@ -3900,7 +3902,6 @@ static int packet_notifier(struct notifier_block *this,
 				}
 				if (msg == NETDEV_UNREGISTER) {
 					packet_cached_dev_reset(po);
-					fanout_release(sk);
 					po->ifindex = -1;
 					if (po->prot_hook.dev)
 						dev_put(po->prot_hook.dev);
-- 
2.7.4
