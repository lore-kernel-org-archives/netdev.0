From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 1 Mar 2016 08:56:50 -0800
Message-ID: <20160301165650.GN3577@linux.vnet.ibm.com>
References: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, rjw@rjwysocki.net,
	konrad.wilk@oracle.com, Ingo Molnar <mingo@kernel.org>,
	tj@kernel.org, davem@davemloft.net, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2016 at 11:26:25AM +0100, Peter Zijlstra wrote:
> 
> $ make tags
>   GEN     tags
> ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
> ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
> ctags: Warning: kernel/locking/lockdep.c:151: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
> ctags: Warning: kernel/workqueue.c:323: null expansion of name pattern "\1"
> ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
> ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"
> ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"
> 
> Which are all the result of the DEFINE_PER_CPU pattern:
> 
> scripts/tags.sh:200:	'/\<DEFINE_PER_CPU([^,]*, *\([[:alnum:]_]*\)/\1/v/'
> scripts/tags.sh:201:	'/\<DEFINE_PER_CPU_SHARED_ALIGNED([^,]*, *\([[:alnum:]_]*\)/\1/v/'
> 
> The below cures them. All except the workqueue one are within reasonable
> distance of the 80 char limit. TJ do you have any preference on how to
> fix the wq one, or shall we just not care its too long?
> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

For rcutorture, the initializers are zero.  Would it make more sense to
remove the initializers completely in favor of C's default initialization
as shown below?

							Thanx, Paul

------------------------------------------------------------------------

commit 9bd8e9f0c56cfc19ca5b68a73edd80b16bec4af8
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Tue Mar 1 08:52:19 2016 -0800

    rcutorture: Remove redundant initialization to zero
    
    The current code initializes the global per-CPU variables
    rcu_torture_count and rcu_torture_batch to zero.  However, C does this
    initialization by default, and explicit initialization of per-CPU
    variables now needs a different syntax if "make tags" is to work.
    This commit therefore removes the initialization.
    
    Reported-by: Peter Zijlstra <peterz@infradead.org>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/rcu/rcutorture.c b/kernel/rcu/rcutorture.c
index 1c2dc23ae07d..f5fd9acc0f9b 100644
--- a/kernel/rcu/rcutorture.c
+++ b/kernel/rcu/rcutorture.c
@@ -131,9 +131,9 @@ static unsigned long rcu_torture_current_version;
 static struct rcu_torture rcu_tortures[10 * RCU_TORTURE_PIPE_LEN];
 static DEFINE_SPINLOCK(rcu_torture_lock);
 static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_count) = { 0 };
+		      rcu_torture_count);
 static DEFINE_PER_CPU(long [RCU_TORTURE_PIPE_LEN + 1],
-		      rcu_torture_batch) = { 0 };
+		      rcu_torture_batch);
 static atomic_t rcu_torture_wcount[RCU_TORTURE_PIPE_LEN + 1];
 static atomic_t n_rcu_torture_alloc;
 static atomic_t n_rcu_torture_alloc_fail;

