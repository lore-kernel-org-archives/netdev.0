From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] fib_trie: rcu_assign_pointer warning fix
Date: Tue, 12 Feb 2008 08:07:29 -0800
Message-ID: <20080212160729.GA9157@linux.vnet.ibm.com>
References: <20080211.171645.74019568.davem@davemloft.net> <20080212085714.GB2582@ff.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762721AbYBLQIF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080212085714.GB2582@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 12, 2008 at 08:57:14AM +0000, Jarek Poplawski wrote:
> On 12-02-2008 02:16, David Miller wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Mon, 11 Feb 2008 16:59:54 -0800
> > 
> > linux-kernel added to CC:, any change to generic kernel infrastructure
> > should be posted there
> > 
> >> Eliminate warnings when rcu_assign_pointer is used with unsigned long.
> >> It is reasonable to use RCU with non-pointer values so allow it for general
> >> use.  Add a comment to explain the if test.
> >>
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >> ---
> >>  include/linux/rcupdate.h |   13 +++++++------
> >>  1 files changed, 7 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> >> index 37a642c..c44ac87 100644
> >> --- a/include/linux/rcupdate.h
> >> +++ b/include/linux/rcupdate.h
> >> @@ -172,14 +172,15 @@ struct rcu_head {
> >>   * structure after the pointer assignment.  More importantly, this
> >>   * call documents which pointers will be dereferenced by RCU read-side
> >>   * code.
> >> + *
> >> + * If value is the NULL (constant 0), then no barrier is needed.
> >>   */
> >>  
> >> -#define rcu_assign_pointer(p, v) \
> >> -	({ \
> >> -		if (!__builtin_constant_p(v) || \
> >> -		    ((v) != NULL)) \
> >> -			smp_wmb(); \
> >> -		(p) = (v); \
> >> +#define rcu_assign_pointer(p, v)			\
> >> +	({						\
> >> +		if (!(__builtin_constant_p(v) && v))	\
> 
> ...But, "If value is the NULL (constant 0)" we have:
> 
> if (!(1 && NULL != 0)) ==> if (!(0)) and the barrier is used?!

"All programmers are blind, especially me."

You are right, Jarek.  I ran this through gcc, and the following
comes close:

#define rcu_assign_pointer(p, v) \
	({ \
		if (!__builtin_constant_p(v) || (v)) \
			smp_wmb(); \
		(p) = (v); \
	})

But I am concerned about the following case:

	rcu_assign_pointer(global_index, 0);

	. . .

	x = global_array[rcu_dereference(global_index)];

Since arrays have a zero-th element, we would really want a memory
barrier in this case.

So how about leaving the index-unfriendly version of rcu_assign_pointer()
and adding an rcu_assign_index() as follows?

							Thanx, Paul

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 rcupdate.h |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff -urpNa -X dontdiff linux-2.6.24/include/linux/rcupdate.h linux-2.6.24-rai/include/linux/rcupdate.h
--- linux-2.6.24/include/linux/rcupdate.h	2008-01-24 14:58:37.000000000 -0800
+++ linux-2.6.24-rai/include/linux/rcupdate.h	2008-02-12 08:04:59.000000000 -0800
@@ -278,6 +278,24 @@ extern struct lockdep_map rcu_lock_map;
 					})
 
 /**
+ * rcu_assign_index - assign (publicize) a index of a newly
+ * initialized array elementg that will be dereferenced by RCU
+ * read-side critical sections.  Returns the value assigned.
+ *
+ * Inserts memory barriers on architectures that require them
+ * (pretty much all of them other than x86), and also prevents
+ * the compiler from reordering the code that initializes the
+ * structure after the index assignment.  More importantly, this
+ * call documents which indexes will be dereferenced by RCU read-side
+ * code.
+ */
+
+#define rcu_assign_index(p, v)	({ \
+					smp_wmb(); \
+					(p) = (v); \
+				})
+
+/**
  * synchronize_sched - block until all CPUs have exited any non-preemptive
  * kernel code sequences.
  *
