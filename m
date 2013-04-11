From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH RFC] spinlock: split out debugging check from spin_lock_mutex
Date: Thu, 11 Apr 2013 11:18:06 -0400
Message-ID: <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
References: <5166BDAA.3000603@acm.org>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55037 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432Ab3DKPS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 11:18:26 -0400
In-Reply-To: <5166BDAA.3000603@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bart, this patch should fix your problem.  Could you please test it and confirm?

Bart Van Assche recently reported a warning to me:

<IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
 [<ffffffff814761dd>] mutex_trylock+0x16d/0x180
 [<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
 [<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
 [<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
 [<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
 [<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
 [<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
 [<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
 [<ffffffff8103fb76>] console_unlock+0x2d6/0x450
 [<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
 [<ffffffff8146f9f6>] printk+0x4d/0x4f
 [<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]

This resulted from my commit ca99ca14c which introduced a mutex_trylock
operation in a path that could execute in interrupt context.  When mutex
debugging is enabled, the above warns the user when we are in fact exectuting in
interrupt context.

I think this is a false positive however.  The check is intended to catch users
who might be issuing sleeping calls in irq context, but the use of mutex_trylock
here is guaranteed not to sleep.

We could fix this by replacing the DEBUG_LOCK_WARN_ON check in spin_lock_mutex
with a __might_sleep call in the appropriate parent mutex operations, but for
the sake of effiency (which It seems is why the check was put in the spin lock
code only when debug is enabled), lets split the spin_lock_mutex call into two
components, where the outer component does the debug checking.  Then
mutex_trylock can just call the inner part as its callable from irq context
safely.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Bart Van Assche <bvanassche@acm.org>
CC: Bart Van Assche <bvanassche@acm.org>
CC: David Miller <davem@davemloft.net>
CC: netdev@vger.kernel.org
---
 kernel/mutex-debug.h | 11 +++++++++--
 kernel/mutex.c       |  4 ++--
 kernel/mutex.h       |  2 ++
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/kernel/mutex-debug.h b/kernel/mutex-debug.h
index 0799fd3..bd0d80a 100644
--- a/kernel/mutex-debug.h
+++ b/kernel/mutex-debug.h
@@ -37,13 +37,20 @@ static inline void mutex_clear_owner(struct mutex *lock)
 	lock->owner = NULL;
 }
 
-#define spin_lock_mutex(lock, flags)			\
+#define spin_lock_mutex_raw(lock, flags)		\
 	do {						\
 		struct mutex *l = container_of(lock, struct mutex, wait_lock); \
 							\
-		DEBUG_LOCKS_WARN_ON(in_interrupt());	\
 		local_irq_save(flags);			\
 		arch_spin_lock(&(lock)->rlock.raw_lock);\
+	} while (0)
+
+#define spin_lock_mutex(lock, flags)			\
+	do {						\
+		struct mutex *l = container_of(lock, struct mutex, wait_lock); \
+							\
+		DEBUG_LOCKS_WARN_ON(in_interrupt());	\
+		spin_lock_mutex_raw(lock, flags);	\
 		DEBUG_LOCKS_WARN_ON(l->magic != l);	\
 	} while (0)
 
diff --git a/kernel/mutex.c b/kernel/mutex.c
index 52f2301..5c012c7 100644
--- a/kernel/mutex.c
+++ b/kernel/mutex.c
@@ -431,7 +431,7 @@ static inline int __mutex_trylock_slowpath(atomic_t *lock_count)
 	unsigned long flags;
 	int prev;
 
-	spin_lock_mutex(&lock->wait_lock, flags);
+	spin_lock_mutex_raw(&lock->wait_lock, flags);
 
 	prev = atomic_xchg(&lock->count, -1);
 	if (likely(prev == 1)) {
@@ -443,7 +443,7 @@ static inline int __mutex_trylock_slowpath(atomic_t *lock_count)
 	if (likely(list_empty(&lock->wait_list)))
 		atomic_set(&lock->count, 0);
 
-	spin_unlock_mutex(&lock->wait_lock, flags);
+	spin_unlock_mutex_raw(&lock->wait_lock, flags);
 
 	return prev == 1;
 }
diff --git a/kernel/mutex.h b/kernel/mutex.h
index 4115fbf..af6ffb4 100644
--- a/kernel/mutex.h
+++ b/kernel/mutex.h
@@ -11,6 +11,8 @@
 
 #define spin_lock_mutex(lock, flags) \
 		do { spin_lock(lock); (void)(flags); } while (0)
+#define spin_lock_mutex_raw(lock, flags) spin_lock_mutex((lock), (flags))
+
 #define spin_unlock_mutex(lock, flags) \
 		do { spin_unlock(lock); (void)(flags); } while (0)
 #define mutex_remove_waiter(lock, waiter, ti) \
-- 
1.8.1.4
