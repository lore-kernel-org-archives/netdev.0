From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 06/46] percpu_rwlock: Rearrange the read-lock code to
 fastpath nested percpu readers
Date: Mon, 18 Feb 2013 18:09:07 +0530
Message-ID: <20130218123907.26245.37550.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we are dealing with a nester percpu reader, we can optimize away quite
a few costly operations. Improve that fastpath further, by avoiding the
unnecessary addition and subtraction of 'READER_PRESENT' to reader_refcnt,
by rearranging the code a bit.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 lib/percpu-rwlock.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/lib/percpu-rwlock.c b/lib/percpu-rwlock.c
index ce7e440..ed36531 100644
--- a/lib/percpu-rwlock.c
+++ b/lib/percpu-rwlock.c
@@ -80,23 +80,21 @@ void percpu_read_lock_irqsafe(struct percpu_rwlock *pcpu_rwlock)
 	preempt_disable();
 
 	/*
-	 * Let the writer know that a reader is active, even before we choose
-	 * our reader-side synchronization scheme.
-	 */
-	this_cpu_add(pcpu_rwlock->rw_state->reader_refcnt, READER_PRESENT);
-
-	/*
 	 * If we are already using per-cpu refcounts, it is not safe to switch
 	 * the synchronization scheme. So continue using the refcounts.
 	 */
 	if (reader_uses_percpu_refcnt(pcpu_rwlock)) {
 		this_cpu_inc(pcpu_rwlock->rw_state->reader_refcnt);
-		this_cpu_sub(pcpu_rwlock->rw_state->reader_refcnt,
-			     READER_PRESENT);
 		return;
 	}
 
 	/*
+	 * Let the writer know that a reader is active, even before we choose
+	 * our reader-side synchronization scheme.
+	 */
+	this_cpu_add(pcpu_rwlock->rw_state->reader_refcnt, READER_PRESENT);
+
+	/*
 	 * The write to 'reader_refcnt' must be visible before we read
 	 * 'writer_signal'.
 	 */
