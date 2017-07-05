From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v2 1/9] net/netfilter/nf_conntrack_core: Fix net_conntrack_lock()
Date: Wed,  5 Jul 2017 16:31:35 -0700
Message-ID: <1499297503-23852-1-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170705232955.GA15992@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        <stable@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170705232955.GA15992@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Manfred Spraul <manfred@colorfullife.com>

As we want to remove spin_unlock_wait() and replace it with explicit
spin_lock()/spin_unlock() calls, we can use this to simplify the
locking.

In addition:
- Reading nf_conntrack_locks_all needs ACQUIRE memory ordering.
- The new code avoids the backwards loop.

Only slightly tested, I did not manage to trigger calls to
nf_conntrack_all_lock().

Fixes: b16c29191dc8
Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
Cc: <stable@vger.kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 net/netfilter/nf_conntrack_core.c | 44 +++++++++++++++++++++------------------
 1 file changed, 24 insertions(+), 20 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e847dbaa0c6b..1193565c38ae 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -96,19 +96,24 @@ static struct conntrack_gc_work conntrack_gc_work;
 
 void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
 {
+	/* 1) Acquire the lock */
 	spin_lock(lock);
-	while (unlikely(nf_conntrack_locks_all)) {
-		spin_unlock(lock);
 
-		/*
-		 * Order the 'nf_conntrack_locks_all' load vs. the
-		 * spin_unlock_wait() loads below, to ensure
-		 * that 'nf_conntrack_locks_all_lock' is indeed held:
-		 */
-		smp_rmb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
-		spin_unlock_wait(&nf_conntrack_locks_all_lock);
-		spin_lock(lock);
-	}
+	/* 2) read nf_conntrack_locks_all, with ACQUIRE semantics */
+	if (likely(smp_load_acquire(&nf_conntrack_locks_all) == false))
+		return;
+
+	/* fast path failed, unlock */
+	spin_unlock(lock);
+
+	/* Slow path 1) get global lock */
+	spin_lock(&nf_conntrack_locks_all_lock);
+
+	/* Slow path 2) get the lock we want */
+	spin_lock(lock);
+
+	/* Slow path 3) release the global lock */
+	spin_unlock(&nf_conntrack_locks_all_lock);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 
@@ -149,18 +154,17 @@ static void nf_conntrack_all_lock(void)
 	int i;
 
 	spin_lock(&nf_conntrack_locks_all_lock);
-	nf_conntrack_locks_all = true;
 
-	/*
-	 * Order the above store of 'nf_conntrack_locks_all' against
-	 * the spin_unlock_wait() loads below, such that if
-	 * nf_conntrack_lock() observes 'nf_conntrack_locks_all'
-	 * we must observe nf_conntrack_locks[] held:
-	 */
-	smp_mb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
+	nf_conntrack_locks_all = true;
 
 	for (i = 0; i < CONNTRACK_LOCKS; i++) {
-		spin_unlock_wait(&nf_conntrack_locks[i]);
+		spin_lock(&nf_conntrack_locks[i]);
+
+		/* This spin_unlock provides the "release" to ensure that
+		 * nf_conntrack_locks_all==true is visible to everyone that
+		 * acquired spin_lock(&nf_conntrack_locks[]).
+		 */
+		spin_unlock(&nf_conntrack_locks[i]);
 	}
 }
 
-- 
2.5.2
