From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with type/macro safety
Date: Fri, 15 Feb 2008 17:23:51 -0800
Message-ID: <20080216012351.GB8602@linux.vnet.ibm.com>
References: <20080213220024.GA30729@linux.vnet.ibm.com> <20080215164024.7fd356fa.akpm@linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	davem@davemloft.net, netdev@vger.kernel.org, dipankar@in.ibm.com,
	ego@in.ibm.com, herbert@gondor.apana.org.au
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932301AbYBPBYu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080215164024.7fd356fa.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 15, 2008 at 04:40:24PM -0800, Andrew Morton wrote:
> On Wed, 13 Feb 2008 14:00:24 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > Hello!
> > 
> > This is an updated version of the patch posted last November:
> > 
> > 	http://archives.free.net.ph/message/20071201.003721.cd6ff17c.en.html
> > 
> > This new version permits arguments with side effects, for example:
> > 
> > 	rcu_assign_pointer(global_p, p++);
> > 
> > and also verifies that the arguments are pointers, while still avoiding
> > the unnecessary memory barrier when assigning NULL to a pointer.
> > This memory-barrier avoidance means that rcu_assign_pointer() is now only
> > permitted for pointers (not array indexes), and so this version emits a
> > compiler warning if the first argument is not a pointer.  I built a "make
> > allyesconfig" version on an x86 system, and received no such warnings.
> > If RCU is ever applied to array indexes, then the second patch in this
> > series should be applied, and the resulting rcu_assign_index() be used.
> > 
> > Given the rather surprising history of subtlely broken implementations of
> > rcu_assign_pointer(), I took the precaution of generating a full set of
> > test cases and verified that memory barriers and compiler warnings were
> > emitted when required.  I guess it is the simple things that get you...
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> > 
> >  rcupdate.h |   16 ++++++++++++----
> >  1 file changed, 12 insertions(+), 4 deletions(-)
> > 
> > diff -urpNa -X dontdiff linux-2.6.24/include/linux/rcupdate.h linux-2.6.24-rap/include/linux/rcupdate.h
> > --- linux-2.6.24/include/linux/rcupdate.h	2008-01-24 14:58:37.000000000 -0800
> > +++ linux-2.6.24-rap/include/linux/rcupdate.h	2008-02-13 13:36:47.000000000 -0800
> > @@ -270,12 +270,20 @@ extern struct lockdep_map rcu_lock_map;
> >   * structure after the pointer assignment.  More importantly, this
> >   * call documents which pointers will be dereferenced by RCU read-side
> >   * code.
> > + *
> > + * Throws a compiler warning for non-pointer arguments.
> > + *
> > + * Does not insert a memory barrier for a NULL pointer.
> >   */
> >  
> > -#define rcu_assign_pointer(p, v)	({ \
> > -						smp_wmb(); \
> > -						(p) = (v); \
> > -					})
> > +#define rcu_assign_pointer(p, v)	\
> > +	({ \
> > +		typeof(*p) *_________p1 = (v); \
> > +		\
> > +		if (!__builtin_constant_p(v) || (_________p1 != NULL)) \
> > +			smp_wmb(); \
> > +		(p) = _________p1; \
> > +	})
> >  
> 
> umm...
> 
> net/netfilter/core.c: In function 'nf_register_afinfo':
> net/netfilter/core.c:39: warning: initialization discards qualifiers from pointer target type
> net/netfilter/nf_log.c: In function 'nf_log_register':
> net/netfilter/nf_log.c:37: warning: initialization discards qualifiers from pointer target type
> net/netfilter/nf_queue.c: In function 'nf_register_queue_handler':
> net/netfilter/nf_queue.c:38: warning: initialization discards qualifiers from pointer target type

Hmmm...  Netfilter compiles cleanly here.  My guess is that your gcc
is more fastidious about const declarations.  Could you please either
let me know what arch/gcc-settings you are using, or, alternatively,
see if the following patch fixes things up?  The comparison against
NULL should at least emit warnings for non-pointer types -- not as
good as an error, but better than emitting bogus warnings.

So I guess I should stick with simple things like preemptable RCU instead
of the much more difficult task of outsmarting gcc...

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 rcupdate.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- rcupdate.h.old	2008-02-15 17:18:50.000000000 -0800
+++ rcupdate.h	2008-02-15 17:18:52.000000000 -0800
@@ -176,7 +176,7 @@ struct rcu_head {
 
 #define rcu_assign_pointer(p, v) \
 	({ \
-		typeof(*p) *_________p1 = (v); \
+		typeof(p) _________p1 = (v); \
 		\
 		if (!__builtin_constant_p(v) || ((_________p1) != NULL)) \
 			smp_wmb(); \
