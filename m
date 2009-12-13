From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v3] Documentation: rw_lock lessons learned
Date: Sun, 13 Dec 2009 15:12:46 -0500
Message-ID: <4B254ABE.9040002@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060409040306060103030800"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Clark <sclark46@earthlink.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754161AbZLMUMx@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060409040306060103030800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In recent months, two different network projects erroneously
strayed down the rw_lock path.  Update the Documentation
based upon comments by Eric Dumazet and Paul E. McKenney in
those threads.

Further updates await somebody else with more expertise.

Changes:
  - Merged with extensive content by Stephen Hemminger.
  - Fix one of the comments by Linus Torvalds.

Signed-off-by: William.Allen.Simpson@gmail.com
Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
  Documentation/spinlocks.txt |  184 ++++++++++++++++++++-----------------------
  1 files changed, 84 insertions(+), 100 deletions(-)

--------------060409040306060103030800
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="spinlocks.txt.v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="spinlocks.txt.v3.patch"

diff --git a/Documentation/spinlocks.txt b/Documentation/spinlocks.txt
index 619699d..1d6bd79 100644
--- a/Documentation/spinlocks.txt
+++ b/Documentation/spinlocks.txt
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
 
@@ -75,13 +10,11 @@ See <asm/spinlock.h>. The basic version is:
 	... critical section here ..
 	spin_unlock_irqrestore(&xxx_lock, flags);
 
-and the above is always safe. It will disable interrupts _locally_, but the
+The above is always safe. It will disable interrupts _locally_, but the
 spinlock itself will guarantee the global lock, so it will guarantee that
 there is only one thread-of-control within the region(s) protected by that
-lock. 
-
-Note that it works well even under UP - the above sequence under UP
-essentially is just the same as doing a
+lock. This works well even under UP. The above sequence under UP
+essentially is just the same as doing
 
 	unsigned long flags;
 
@@ -91,15 +24,13 @@ essentially is just the same as doing a
 
 so the code does _not_ need to worry about UP vs SMP issues: the spinlocks
 work correctly under both (and spinlocks are actually more efficient on
-architectures that allow doing the "save_flags + cli" in one go because I
-don't export that interface normally).
+architectures that allow doing the "save_flags + cli" in one operation).
+
+   NOTE! Implications of spin_locks for memory are further described in:
 
-NOTE NOTE NOTE! The reason the spinlock is so much faster than a global
-interrupt lock under SMP is exactly because it disables interrupts only on
-the local CPU. The spin-lock is safe only when you _also_ use the lock
-itself to do locking across CPU's, which implies that EVERYTHING that
-touches a shared variable has to agree about the spinlock they want to
-use.
+     Documentation/memory-barriers.txt
+       (5) LOCK operations.
+       (6) UNLOCK operations.
 
 The above is usually pretty simple (you usually need and want only one
 spinlock for most things - using more than one spinlock can make things a
@@ -120,20 +51,24 @@ and another sequence that does
 then they are NOT mutually exclusive, and the critical regions can happen
 at the same time on two different CPU's. That's fine per se, but the
 critical regions had better be critical for different things (ie they
-can't stomp on each other). 
+can't stomp on each other).
 
 The above is a problem mainly if you end up mixing code - for example the
 routines in ll_rw_block() tend to use cli/sti to protect the atomicity of
 their actions, and if a driver uses spinlocks instead then you should
-think about issues like the above..
+think about issues like the above.
 
 This is really the only really hard part about spinlocks: once you start
 using spinlocks they tend to expand to areas you might not have noticed
 before, because you have to make sure the spinlocks correctly protect the
 shared data structures _everywhere_ they are used. The spinlocks are most
-easily added to places that are completely independent of other code (ie
-internal driver data structures that nobody else ever touches, for
-example). 
+easily added to places that are completely independent of other code (for
+example, internal driver data structures that nobody else ever touches).
+
+   NOTE! The spin-lock is safe only when you _also_ use the lock itself
+   to do locking across CPU's, which implies that EVERYTHING that
+   touches a shared variable has to agree about the spinlock they want
+   to use.
 
 ----
 
@@ -141,13 +76,17 @@ Lesson 2: reader-writer spinlocks.
 
 If your data accesses have a very natural pattern where you usually tend
 to mostly read from the shared variables, the reader-writer locks
-(rw_lock) versions of the spinlocks are often nicer. They allow multiple
+(rw_lock) versions of the spinlocks are sometimes useful. They allow multiple
 readers to be in the same critical region at once, but if somebody wants
-to change the variables it has to get an exclusive write lock. The
-routines look the same as above:
+to change the variables it has to get an exclusive write lock.
 
-   rwlock_t xxx_lock = RW_LOCK_UNLOCKED;
+   NOTE! reader-writer locks require more atomic memory operations than
+   simple spinlocks.  Unless the reader critical section is long, you
+   are better off just using spinlocks.
+
+The routines look the same as above:
 
+   rwlock_t xxx_lock = RW_LOCK_UNLOCKED;
 
 	unsigned long flags;
 
@@ -159,18 +98,21 @@ routines look the same as above:
 	.. read and write exclusive access to the info ...
 	write_unlock_irqrestore(&xxx_lock, flags);
 
-The above kind of lock is useful for complex data structures like linked
-lists etc, especially when you know that most of the work is to just
-traverse the list searching for entries without changing the list itself,
-for example. Then you can use the read lock for that kind of list
-traversal, which allows many concurrent readers. Anything that _changes_
-the list will have to get the write lock. 
+The above kind of lock may be useful for complex data structures like
+linked lists, especially searching for entries without changing the list
+itself.  The read lock allows many concurrent readers.  Anything that
+_changes_ the list will have to get the write lock.
+
+   NOTE! RCU is better for list traversal, but requires careful
+   attention to design detail (see Documentation/RCU/listRCU.txt).
 
-Note: you cannot "upgrade" a read-lock to a write-lock, so if you at _any_
+Also, you cannot "upgrade" a read-lock to a write-lock, so if you at _any_
 time need to do any changes (even if you don't do it every time), you have
-to get the write-lock at the very beginning. I could fairly easily add a
-primitive to create a "upgradeable" read-lock, but it hasn't been an issue
-yet. Tell me if you'd want one. 
+to get the write-lock at the very beginning.
+
+   NOTE! We are working hard to remove reader-writer spinlocks in most
+   cases, so please don't add a new one without consensus.  (Instead, see
+   Documentation/RCU/rcu.txt for complete information.)
 
 ----
 
@@ -233,4 +175,46 @@ indeed), while write-locks need to protect themselves against interrupts.
 
 		Linus
 
+----
+
+Reference information:
+
+For dynamic initialization, use spin_lock_init() or rwlock_init() as
+appropriate:
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
 
+For static initialization, use DEFINE_SPINLOCK() / DEFINE_RWLOCK() or
+__SPIN_LOCK_UNLOCKED() / __RW_LOCK_UNLOCKED() as appropriate.
+
+SPIN_LOCK_UNLOCKED and RW_LOCK_UNLOCKED are deprecated.  These interfere
+with lockdep state tracking.
+
+Most of the time, you can simply turn:
+	static spinlock_t xxx_lock = SPIN_LOCK_UNLOCKED;
+into:
+	static DEFINE_SPINLOCK(xxx_lock);
+
+Static structure member variables go from:
+
+	struct foo bar {
+		.lock	=	SPIN_LOCK_UNLOCKED;
+	};
+
+to:
+
+	struct foo bar {
+		.lock	=	__SPIN_LOCK_UNLOCKED(bar.lock);
+	};
+
+Declaration of static rw_locks undergo a similar transformation.
-- 
1.6.3.3


--------------060409040306060103030800--
