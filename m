From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] lib: fix data race in rhashtable_rehash_one
Date: Mon, 21 Sep 2015 10:08:50 +0200
Message-ID: <1442822930-35319-1-git-send-email-dvyukov@google.com>
Cc: kcc@google.com, andreyknvl@google.com, glider@google.com,
	ktsan@googlegroups.com, paulmck@linux.vnet.ibm.com,
	Dmitry Vyukov <dvyukov@google.com>
To: tgraf@suug.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rhashtable_rehash_one() uses plain writes to update entry->next,
while it is being concurrently accessed by readers.
Unfortunately, the compiler is within its rights to (for example) use
byte-at-a-time writes to update the pointer, which would fatally confuse
concurrent readers.

Use WRITE_ONCE to update entry->next in rhashtable_rehash_one().

The data race was found with KernelThreadSanitizer (KTSAN).

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
---
KTSAN report for the record:

ThreadSanitizer: data-race in netlink_lookup

Atomic read at 0xffff880480443bd0 of size 8 by thread 2747 on CPU 11:
 [<     inline     >] rhashtable_lookup_fast include/linux/rhashtable.h:543
 [<     inline     >] __netlink_lookup net/netlink/af_netlink.c:1026
 [<ffffffff81bd9a84>] netlink_lookup+0x134/0x1c0 net/netlink/af_netlink.c:1046
 [<     inline     >] netlink_getsockbyportid net/netlink/af_netlink.c:1616
 [<ffffffff81bdc701>] netlink_unicast+0x111/0x300 net/netlink/af_netlink.c:1812
 [<ffffffff81bdcdb9>] netlink_sendmsg+0x4c9/0x5f0 net/netlink/af_netlink.c:2443
 [<     inline     >] sock_sendmsg_nosec net/socket.c:610
 [<ffffffff81b5d6f3>] sock_sendmsg+0x83/0x90 net/socket.c:620
 [<ffffffff81b5e59f>] ___sys_sendmsg+0x3cf/0x3e0 net/socket.c:1952
 [<ffffffff81b5f6ac>] __sys_sendmsg+0x4c/0xb0 net/socket.c:1986
 [<     inline     >] SYSC_sendmsg net/socket.c:1997
 [<ffffffff81b5f740>] SyS_sendmsg+0x30/0x50 net/socket.c:1993
 [<ffffffff81ee3e11>] entry_SYSCALL_64_fastpath+0x31/0x95
arch/x86/entry/entry_64.S:188

Previous write at 0xffff880480443bd0 of size 8 by thread 213 on CPU 4:
 [<     inline     >] rhashtable_rehash_one lib/rhashtable.c:193
 [<     inline     >] rhashtable_rehash_chain lib/rhashtable.c:213
 [<     inline     >] rhashtable_rehash_table lib/rhashtable.c:257
 [<ffffffff8156f7e0>] rht_deferred_worker+0x3b0/0x6d0 lib/rhashtable.c:373
 [<ffffffff810b1d6e>] process_one_work+0x47e/0x930 kernel/workqueue.c:2036
 [<ffffffff810b22d0>] worker_thread+0xb0/0x900 kernel/workqueue.c:2170
 [<ffffffff810bba40>] kthread+0x150/0x170 kernel/kthread.c:209
 [<ffffffff81ee420f>] ret_from_fork+0x3f/0x70 arch/x86/entry/entry_64.S:529

Mutexes locked by thread 213:
Mutex 217217 is locked here:
 [<ffffffff81ee0407>] mutex_lock+0x57/0x70 kernel/locking/mutex.c:108
 [<ffffffff8156f475>] rht_deferred_worker+0x45/0x6d0 lib/rhashtable.c:363
 [<ffffffff810b1d6e>] process_one_work+0x47e/0x930 kernel/workqueue.c:2036
 [<ffffffff810b22d0>] worker_thread+0xb0/0x900 kernel/workqueue.c:2170
 [<ffffffff810bba40>] kthread+0x150/0x170 kernel/kthread.c:209
 [<ffffffff81ee420f>] ret_from_fork+0x3f/0x70 arch/x86/entry/entry_64.S:529

Mutex 431216 is locked here:
 [<     inline     >] __raw_spin_lock_bh include/linux/spinlock_api_smp.h:149
 [<ffffffff81ee3195>] _raw_spin_lock_bh+0x65/0x80 kernel/locking/spinlock.c:175
 [<     inline     >] spin_lock_bh include/linux/spinlock.h:317
 [<     inline     >] rhashtable_rehash_chain lib/rhashtable.c:212
 [<     inline     >] rhashtable_rehash_table lib/rhashtable.c:257
 [<ffffffff8156f616>] rht_deferred_worker+0x1e6/0x6d0 lib/rhashtable.c:373
 [<ffffffff810b1d6e>] process_one_work+0x47e/0x930 kernel/workqueue.c:2036
 [<ffffffff810b22d0>] worker_thread+0xb0/0x900 kernel/workqueue.c:2170
 [<ffffffff810bba40>] kthread+0x150/0x170 kernel/kthread.c:209
 [<ffffffff81ee420f>] ret_from_fork+0x3f/0x70 arch/x86/entry/entry_64.S:529

Mutex 432766 is locked here:
 [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:158
 [<ffffffff81ee37d0>] _raw_spin_lock+0x50/0x70 kernel/locking/spinlock.c:151
 [<     inline     >] rhashtable_rehash_one lib/rhashtable.c:186
 [<     inline     >] rhashtable_rehash_chain lib/rhashtable.c:213
 [<     inline     >] rhashtable_rehash_table lib/rhashtable.c:257
 [<ffffffff8156f79b>] rht_deferred_worker+0x36b/0x6d0 lib/rhashtable.c:373
 [<ffffffff810b1d6e>] process_one_work+0x47e/0x930 kernel/workqueue.c:2036
 [<ffffffff810b22d0>] worker_thread+0xb0/0x900 kernel/workqueue.c:2170
 [<ffffffff810bba40>] kthread+0x150/0x170 kernel/kthread.c:209
 [<ffffffff81ee420f>] ret_from_fork+0x3f/0x70 arch/x86/entry/entry_64.S:529
---
 lib/rhashtable.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index cc0c697..978624d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -188,9 +188,12 @@ static int rhashtable_rehash_one(struct rhashtable *ht, unsigned int old_hash)
 				      new_tbl, new_hash);
 
 	if (rht_is_a_nulls(head))
-		INIT_RHT_NULLS_HEAD(entry->next, ht, new_hash);
-	else
-		RCU_INIT_POINTER(entry->next, head);
+		head = (struct rhash_head *)rht_marker(ht, new_hash);
+	/* We don't insert any new nodes that were not previously accessible
+	 * to readers, so we don't need to use rcu_assign_pointer().
+	 * But entry is being concurrently accessed by readers, so we need to
+	 * use at least WRITE_ONCE. */
+	WRITE_ONCE(entry->next, head);
 
 	rcu_assign_pointer(new_tbl->buckets[new_hash], entry);
 	spin_unlock(new_bucket_lock);
-- 
2.6.0.rc0.131.gf624c3d
