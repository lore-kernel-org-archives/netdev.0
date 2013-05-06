From: Colin Cross <ccross@android.com>
Subject: [PATCH v3 14/16] nanosleep: use freezable blocking call
Date: Mon,  6 May 2013 16:50:19 -0700
Message-ID: <1367884221-20462-15-git-send-email-ccross@android.com>
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
	Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid waking up every thread sleeping in a nanosleep call during
suspend and resume by calling a freezable blocking call.  Previous
patches modified the freezer to avoid sending wakeups to threads
that are blocked in freezable blocking calls.

This call was selected to be converted to a freezable call because
it doesn't hold any locks or release any resources when interrupted
that might be needed by another freezing task or a kernel driver
during suspend, and is a common site where idle userspace tasks are
blocked.

Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Colin Cross <ccross@android.com>
---
 kernel/hrtimer.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index 14be27f..e036276 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -47,6 +47,7 @@
 #include <linux/sched/sysctl.h>
 #include <linux/sched/rt.h>
 #include <linux/timer.h>
+#include <linux/freezer.h>
 
 #include <asm/uaccess.h>
 
@@ -1525,7 +1526,7 @@ static int __sched do_nanosleep(struct hrtimer_sleeper *t, enum hrtimer_mode mod
 			t->task = NULL;
 
 		if (likely(t->task))
-			schedule();
+			freezable_schedule();
 
 		hrtimer_cancel(&t->timer);
 		mode = HRTIMER_MODE_ABS;
-- 
1.8.2.1
