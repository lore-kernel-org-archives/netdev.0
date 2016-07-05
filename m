From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 22/24] rcu: Suppress sparse warnings for
 rcu_dereference_raw()
Date: Tue, 05 Jul 2016 14:14:49 +0100
Message-ID: <146772448920.21657.6989233498278959646.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Data structures that are used both with and without RCU protection
are difficult to write in a sparse-clean manner.  If you mark the
relevant pointers with __rcu, sparse will complain about all non-RCU
uses, but if you don't mark those pointers, sparse will complain about
all RCU uses.

This commit therefore suppresses sparse warnings for rcu_dereference_raw(),
allowing mixed-protection data structures to avoid these warnings.

Reported-by: David Howells <dhowells@redhat.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/rcupdate.h |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 5f1533e3d032..85830e6c797b 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -611,6 +611,12 @@ static inline void rcu_preempt_sleep_check(void)
 	rcu_dereference_sparse(p, space); \
 	((typeof(*p) __force __kernel *)(p)); \
 })
+#define rcu_dereference_raw(p) \
+({ \
+	/* Dependency order vs. p above. */ \
+	typeof(p) ________p1 = lockless_dereference(p); \
+	((typeof(*p) __force __kernel *)(________p1)); \
+})
 
 /**
  * RCU_INITIALIZER() - statically initialize an RCU-protected global variable
@@ -729,8 +735,6 @@ static inline void rcu_preempt_sleep_check(void)
 	__rcu_dereference_check((p), (c) || rcu_read_lock_sched_held(), \
 				__rcu)
 
-#define rcu_dereference_raw(p) rcu_dereference_check(p, 1) /*@@@ needed? @@@*/
-
 /*
  * The tracing infrastructure traces RCU (we want that), but unfortunately
  * some of the RCU checks causes tracing to lock up the system.
