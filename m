From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC 01/26] netfilter: Replace spin_unlock_wait() with lock/unlock pair
Date: Thu, 29 Jun 2017 17:01:09 -0700
Message-ID: <1498780894-8253-1-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, <coreteam@netfilter.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59864 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752139AbdF3ABp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 20:01:45 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5TNx7Xf012429
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 20:01:45 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bd34cdexk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 20:01:44 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Thu, 29 Jun 2017 20:01:43 -0400
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore replaces the spin_unlock_wait() calls
in nf_conntrack_lock() and nf_conntrack_all_lock() with spin_lock()
followed immediately by spin_unlock().  These functions do not appear
to be invoked on any fastpaths.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Florian Westphal <fw@strlen.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <netfilter-devel@vger.kernel.org>
Cc: <coreteam@netfilter.org>
Cc: <netdev@vger.kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 net/netfilter/nf_conntrack_core.c | 26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e847dbaa0c6b..9f997859d160 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -99,15 +99,11 @@ void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
 	spin_lock(lock);
 	while (unlikely(nf_conntrack_locks_all)) {
 		spin_unlock(lock);
-
-		/*
-		 * Order the 'nf_conntrack_locks_all' load vs. the
-		 * spin_unlock_wait() loads below, to ensure
-		 * that 'nf_conntrack_locks_all_lock' is indeed held:
-		 */
-		smp_rmb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
-		spin_unlock_wait(&nf_conntrack_locks_all_lock);
+		/* Wait for nf_conntrack_locks_all_lock holder to release ... */
+		spin_lock(&nf_conntrack_locks_all_lock);
+		spin_unlock(&nf_conntrack_locks_all_lock);
 		spin_lock(lock);
+		/* ... and retry. */
 	}
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
@@ -150,17 +146,11 @@ static void nf_conntrack_all_lock(void)
 
 	spin_lock(&nf_conntrack_locks_all_lock);
 	nf_conntrack_locks_all = true;
-
-	/*
-	 * Order the above store of 'nf_conntrack_locks_all' against
-	 * the spin_unlock_wait() loads below, such that if
-	 * nf_conntrack_lock() observes 'nf_conntrack_locks_all'
-	 * we must observe nf_conntrack_locks[] held:
-	 */
-	smp_mb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
-
 	for (i = 0; i < CONNTRACK_LOCKS; i++) {
-		spin_unlock_wait(&nf_conntrack_locks[i]);
+		/* Wait for any current holder to release lock. */
+		spin_lock(&nf_conntrack_locks[i]);
+		spin_unlock(&nf_conntrack_locks[i]);
+		/* Next acquisition will see nf_conntrack_locks_all == true. */
 	}
 }
 
-- 
2.5.2
