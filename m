From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH resent] Documentation: rw_lock lessons learned
Date: Tue, 10 Nov 2009 18:06:46 -0800
Message-ID: <20091110180646.2e5859a8@nehalam>
References: <4AF9C540.5090403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756977AbZKKCHF@vger.kernel.org>
In-Reply-To: <4AF9C540.5090403@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Nov 2009 14:55:44 -0500
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> In recent weeks, two different network projects erroneously
> strayed down the rw_lock path.  Update the Documentation
> based upon comments in those threads.
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>    Documentation/spinlocks.txt |   14 ++++++++++++++
>    1 files changed, 14 insertions(+), 0 deletions(-)
> 

I would rather see the text in Documentation/spinlocks give an explaination
as to why reader/writer locks are normally not desirable. 

The whole document needs work to make it a developer document, rather than
a historical mail thread..  A good document says what should be done today,
and does not have old junk or ask the reader to overly new context
on old information.



--- a/Documentation/spinlocks.txt	2009-11-10 17:47:03.801984416 -0800
+++ b/Documentation/spinlocks.txt	2009-11-10 18:01:00.779749888 -0800
@@ -1,73 +1,8 @@
-SPIN_LOCK_UNLOCKED and RW_LOCK_UNLOCKED defeat lockdep state tracking and
-are hence deprecated.
+Lesson 1: Spin locks
 
-Please use DEFINE_SPINLOCK()/DEFINE_RWLOCK() or
-__SPIN_LOCK_UNLOCKED()/__RW_LOCK_UNLOCKED() as appropriate for static
-initialization.
-
-Most of the time, you can simply turn:
-
-	static spinlock_t xxx_lock = SPIN_LOCK_UNLOCKED;
-
-into:
-
-	static DEFINE_SPINLOCK(xxx_lock);
-
-Static structure member variables go from:
-
-	struct foo bar {
-		.lock	=	SPIN_LOCK_UNLOCKED;
-	};
-
-to:
-
-	struct foo bar {
-		.lock	=	__SPIN_LOCK_UNLOCKED(bar.lock);
-	};
-
-Declaration of static rw_locks undergo a similar transformation.
-
-Dynamic initialization, when necessary, may be performed as
-demonstrated below.
-
-   spinlock_t xxx_lock;
-   rwlock_t xxx_rw_lock;
-
-   static int __init xxx_init(void)
-   {
-   	spin_lock_init(&xxx_lock);
-	rwlock_init(&xxx_rw_lock);
-	...
-   }
-
-   module_init(xxx_init);
-
-The following discussion is still valid, however, with the dynamic
-initialization of spinlocks or with DEFINE_SPINLOCK, etc., used
-instead of SPIN_LOCK_UNLOCKED.
-
------------------------
-
-On Fri, 2 Jan 1998, Doug Ledford wrote:
-> 
-> I'm working on making the aic7xxx driver more SMP friendly (as well as
-> importing the latest FreeBSD sequencer code to have 7895 support) and wanted
-> to get some info from you.  The goal here is to make the various routines
-> SMP safe as well as UP safe during interrupts and other manipulating
-> routines.  So far, I've added a spin_lock variable to things like my queue
-> structs.  Now, from what I recall, there are some spin lock functions I can
-> use to lock these spin locks from other use as opposed to a (nasty)
-> save_flags(); cli(); stuff; restore_flags(); construct.  Where do I find
-> these routines and go about making use of them?  Do they only lock on a
-> per-processor basis or can they also lock say an interrupt routine from
-> mucking with a queue if the queue routine was manipulating it when the
-> interrupt occurred, or should I still use a cli(); based construct on that
-> one?
-
-See <asm/spinlock.h>. The basic version is:
-
-   spinlock_t xxx_lock = SPIN_LOCK_UNLOCKED;
+The most basic primitive for locking is spinlock.
 
+static DEFINE_SPINLOCK(xxx_lock);
 
 	unsigned long flags;
 
@@ -141,13 +76,17 @@ Lesson 2: reader-writer spinlocks.
 
 If your data accesses have a very natural pattern where you usually tend
 to mostly read from the shared variables, the reader-writer locks
-(rw_lock) versions of the spinlocks are often nicer. They allow multiple
+(rw_lock) versions of the spinlocks are sometimes useful. They allow multiple
 readers to be in the same critical region at once, but if somebody wants
-to change the variables it has to get an exclusive write lock. The
-routines look the same as above:
+to change the variables it has to get an exclusive write lock.
+
+NOTE! reader-writer locks require more atomic memory operations than
+simple spinlocks, so unless the reader critical secition is long you
+are better off just using spinlocks.
 
-   rwlock_t xxx_lock = RW_LOCK_UNLOCKED;
+The routines look the same as above:
 
+static DEFINE_RWLOCK(xxx_lock);
 
 	unsigned long flags;
 
@@ -159,12 +98,15 @@ routines look the same as above:
 	.. read and write exclusive access to the info ...
 	write_unlock_irqrestore(&xxx_lock, flags);
 
-The above kind of lock is useful for complex data structures like linked
+The above kind of lock might useful for complex data structures like linked
 lists etc, especially when you know that most of the work is to just
 traverse the list searching for entries without changing the list itself,
 for example. Then you can use the read lock for that kind of list
 traversal, which allows many concurrent readers. Anything that _changes_
-the list will have to get the write lock. 
+the list will have to get the write lock.
+
+NOTE! RCU is better for that most read only access, but requires
+correct operations (see Documentation/RCU/listRCU.txt)
 
 Note: you cannot "upgrade" a read-lock to a write-lock, so if you at _any_
 time need to do any changes (even if you don't do it every time), you have
@@ -233,4 +175,45 @@ indeed), while write-locks need to prote
 
 		Linus
 
+Reference information:
+
+* Older code used SPIN_LOCK_UNLOCKED and RW_LOCK_UNLOCKED to initialize
+  locks, but this is now deprecated because it interferes with the
+  lockdep state tracking. Please use DEFINE_SPINLOCK()/DEFINE_RWLOCK() or
+  __SPIN_LOCK_UNLOCKED()/__RW_LOCK_UNLOCKED() as appropriate for static
+  initialization.
+
+  Most of the time, you can simply turn:
+	static spinlock_t xxx_lock = SPIN_LOCK_UNLOCKED;
+  into:
+	static DEFINE_SPINLOCK(xxx_lock);
+
+  Static structure member variables go from:
+
+	struct foo bar {
+		.lock	=	SPIN_LOCK_UNLOCKED;
+	};
+
+  to:
+
+	struct foo bar {
+		.lock	=	__SPIN_LOCK_UNLOCKED(bar.lock);
+	};
+
+  Declaration of static rw_locks undergo a similar transformation.
+
+  Dynamic initialization, when necessary, may be performed as
+  demonstrated below.
+
+   spinlock_t xxx_lock;
+   rwlock_t xxx_rw_lock;
+
+   static int __init xxx_init(void)
+   {
+   	spin_lock_init(&xxx_lock);
+	rwlock_init(&xxx_rw_lock);
+	...
+   }
+
+   module_init(xxx_init);
 
