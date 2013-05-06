From: Colin Cross <ccross@android.com>
Subject: [PATCH v3 07/16] freezer: convert freezable helpers to freezer_do_not_count()
Date: Mon,  6 May 2013 16:50:12 -0700
Message-ID: <1367884221-20462-8-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Colin Cross <ccross@android.com>,
	Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Len Brown <len.brown@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Freezing tasks will wake up almost every userspace task from
where it is blocking and force it to run until it hits a
call to try_to_sleep(), generally on the exit path from the syscall
it is blocking in.  On resume each task will run again, usually
restarting the syscall and running until it hits the same
blocking call as it was originally blocked in.

Convert the existing wait_event_freezable* wrappers to use
freezer_do_not_count().  Combined with a previous patch,
these tasks will not run during suspend or resume unless they wake
up for another reason, in which case they will run until they hit
the try_to_freeze() in freezer_count(), and then continue processing
the wakeup after tasks are thawed.

This results in a small change in behavior, previously a race
between freezing and a normal wakeup would be won by the wakeup,
now the task will freeze and then handle the wakeup after thawing.

Signed-off-by: Colin Cross <ccross@android.com>
---
v3:
   split this out of the patch that adds new freezable helpers

 include/linux/freezer.h | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index bcf9e65..c71337af 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -228,27 +228,19 @@ static inline bool freezer_should_skip(struct task_struct *p)
 #define wait_event_freezable(wq, condition)				\
 ({									\
 	int __retval;							\
-	for (;;) {							\
-		__retval = wait_event_interruptible(wq, 		\
-				(condition) || freezing(current));	\
-		if (__retval || (condition))				\
-			break;						\
-		try_to_freeze();					\
-	}								\
+	freezer_do_not_count();						\
+	__retval = wait_event_interruptible(wq, (condition));		\
+	freezer_count();						\
 	__retval;							\
 })
 
 #define wait_event_freezable_timeout(wq, condition, timeout)		\
 ({									\
 	long __retval = timeout;					\
-	for (;;) {							\
-		__retval = wait_event_interruptible_timeout(wq,		\
-				(condition) || freezing(current),	\
-				__retval); 				\
-		if (__retval <= 0 || (condition))			\
-			break;						\
-		try_to_freeze();					\
-	}								\
+	freezer_do_not_count();						\
+	__retval = wait_event_interruptible_timeout(wq,	(condition),	\
+				__retval);				\
+	freezer_count();						\
 	__retval;							\
 })
 
-- 
1.8.2.1
