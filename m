From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH RFC 01/26] netfilter: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Thu, 6 Jul 2017 20:43:28 +0200
Message-ID: <ee509620-8ba5-be45-743e-f077a457c01d@colorfullife.com>
References: <Pine.LNX.4.44L0.1707031543170.2027-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------564DE116543083334572D59F"
Cc: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, tj@kernel.org, arnd@arndb.de,
        linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, parri.andrea@gmail.com,
        torvalds@linux-foundation.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, coreteam@netfilter.org,
        1vier1@web.de
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1707031543170.2027-100000@iolanthe.rowland.org>
Content-Language: en-US
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------564DE116543083334572D59F
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Alan,

On 07/03/2017 09:57 PM, Alan Stern wrote:
>
> (Alternatively, you could make nf_conntrack_all_unlock() do a
> lock+unlock on all the locks in the array, just like
> nf_conntrack_all_lock().  But of course, that would be a lot less
> efficient.)
Hmmmm.

Someone with a weakly ordered system who can test this?
semop() has a very short hotpath.

Either with aim9.shared_memory.ops_per_sec or

#sem-scalebench -t 10 -m 0
https://github.com/manfred-colorfu/ipcscale/blob/master/sem-scalebench.cpp
--
     Manfred

--------------564DE116543083334572D59F
Content-Type: text/x-patch;
 name="0002-ipc-sem.c-avoid-smp_load_acuqire-in-the-hot-path.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-ipc-sem.c-avoid-smp_load_acuqire-in-the-hot-path.patch"

>From b549e0281b66124b62aa94543f91b0e616abaf52 Mon Sep 17 00:00:00 2001
From: Manfred Spraul <manfred@colorfullife.com>
Date: Thu, 6 Jul 2017 20:05:44 +0200
Subject: [PATCH 2/2] ipc/sem.c: avoid smp_load_acuqire() in the hot-path

Alan Stern came up with an interesting idea:
If we perform a spin_lock()/spin_unlock() pair in the slow path, then
we can skip the smp_load_acquire() in the hot path.

What do you think?

* When we removed the smp_mb() from the hot path, it was a user space
  visible speed-up of 11%:

  https://lists.01.org/pipermail/lkp/2017-February/005520.html

* On x86, there is no improvement - as smp_load_acquire is READ_ONCE().

* Slowing down the slow path should not hurt:
  Due to the hysteresis code, the slow path is at least factor 10
  rarer than it was before.

Especially: Who is able to test it?

Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
Cc: Alan Stern <stern@rowland.harvard.edu>
---
 ipc/sem.c | 33 +++++++++++++++++++--------------
 1 file changed, 19 insertions(+), 14 deletions(-)

diff --git a/ipc/sem.c b/ipc/sem.c
index 947dc23..75a4358 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -186,16 +186,15 @@ static int sysvipc_sem_proc_show(struct seq_file *s, void *it);
  *	* either local or global sem_lock() for read.
  *
  * Memory ordering:
- * Most ordering is enforced by using spin_lock() and spin_unlock().
+ * All ordering is enforced by using spin_lock() and spin_unlock().
  * The special case is use_global_lock:
  * Setting it from non-zero to 0 is a RELEASE, this is ensured by
- * using smp_store_release().
- * Testing if it is non-zero is an ACQUIRE, this is ensured by using
- * smp_load_acquire().
- * Setting it from 0 to non-zero must be ordered with regards to
- * this smp_load_acquire(), this is guaranteed because the smp_load_acquire()
- * is inside a spin_lock() and after a write from 0 to non-zero a
- * spin_lock()+spin_unlock() is done.
+ * performing spin_lock()/spin_lock() on every semaphore before setting to
+ * non-zero.
+ * Setting it from 0 to non-zero is an ACQUIRE, this is ensured by
+ * performing spin_lock()/spin_lock() on every semaphore after setting to
+ * non-zero.
+ * Testing if it is non-zero is within spin_lock(), no need for a barrier.
  */
 
 #define sc_semmsl	sem_ctls[0]
@@ -325,13 +324,20 @@ static void complexmode_tryleave(struct sem_array *sma)
 		return;
 	}
 	if (sma->use_global_lock == 1) {
+		int i;
+		struct sem *sem;
 		/*
 		 * Immediately after setting use_global_lock to 0,
-		 * a simple op can start. Thus: all memory writes
-		 * performed by the current operation must be visible
-		 * before we set use_global_lock to 0.
+		 * a simple op can start.
+		 * Perform a full lock/unlock, to guarantee memory
+		 * ordering.
 		 */
-		smp_store_release(&sma->use_global_lock, 0);
+		for (i = 0; i < sma->sem_nsems; i++) {
+			sem = sma->sem_base + i;
+			spin_lock(&sem->lock);
+			spin_unlock(&sem->lock);
+		}
+		sma->use_global_lock = 0;
 	} else {
 		sma->use_global_lock--;
 	}
@@ -379,8 +385,7 @@ static inline int sem_lock(struct sem_array *sma, struct sembuf *sops,
 		 */
 		spin_lock(&sem->lock);
 
-		/* pairs with smp_store_release() */
-		if (!smp_load_acquire(&sma->use_global_lock)) {
+		if (!sma->use_global_lock) {
 			/* fast path successful! */
 			return sops->sem_num;
 		}
-- 
2.9.4


--------------564DE116543083334572D59F--
