From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v3 05/16] freezer: shorten freezer sleep time using exponential backoff
Date: Mon,  6 May 2013 16:50:10 -0700
Message-ID: <1367884221-20462-6-git-send-email-ccross@android.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

All tasks can easily be frozen in under 10 ms, switch to using
an initial 1 ms sleep followed by exponential backoff until
8 ms.  Also convert the printed time to ms instead of centiseconds.

Acked-by: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
---
 kernel/power/process.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/kernel/power/process.c b/kernel/power/process.c
index 98088e0..fc0df84 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -30,9 +30,10 @@ static int try_to_freeze_tasks(bool user_only)
 	unsigned int todo;
 	bool wq_busy = false;
 	struct timeval start, end;
-	u64 elapsed_csecs64;
-	unsigned int elapsed_csecs;
+	u64 elapsed_msecs64;
+	unsigned int elapsed_msecs;
 	bool wakeup = false;
+	int sleep_usecs = USEC_PER_MSEC;
 
 	do_gettimeofday(&start);
 
@@ -68,22 +69,25 @@ static int try_to_freeze_tasks(bool user_only)
 
 		/*
 		 * We need to retry, but first give the freezing tasks some
-		 * time to enter the refrigerator.
+		 * time to enter the refrigerator.  Start with an initial
+		 * 1 ms sleep followed by exponential backoff until 8 ms.
 		 */
-		msleep(10);
+		usleep_range(sleep_usecs / 2, sleep_usecs);
+		if (sleep_usecs < 8 * USEC_PER_MSEC)
+			sleep_usecs *= 2;
 	}
 
 	do_gettimeofday(&end);
-	elapsed_csecs64 = timeval_to_ns(&end) - timeval_to_ns(&start);
-	do_div(elapsed_csecs64, NSEC_PER_SEC / 100);
-	elapsed_csecs = elapsed_csecs64;
+	elapsed_msecs64 = timeval_to_ns(&end) - timeval_to_ns(&start);
+	do_div(elapsed_msecs64, NSEC_PER_MSEC);
+	elapsed_msecs = elapsed_msecs64;
 
 	if (todo) {
 		printk("\n");
-		printk(KERN_ERR "Freezing of tasks %s after %d.%02d seconds "
+		printk(KERN_ERR "Freezing of tasks %s after %d.%03d seconds "
 		       "(%d tasks refusing to freeze, wq_busy=%d):\n",
 		       wakeup ? "aborted" : "failed",
-		       elapsed_csecs / 100, elapsed_csecs % 100,
+		       elapsed_msecs / 1000, elapsed_msecs % 1000,
 		       todo - wq_busy, wq_busy);
 
 		if (!wakeup) {
@@ -96,8 +100,8 @@ static int try_to_freeze_tasks(bool user_only)
 			read_unlock(&tasklist_lock);
 		}
 	} else {
-		printk("(elapsed %d.%02d seconds) ", elapsed_csecs / 100,
-			elapsed_csecs % 100);
+		printk("(elapsed %d.%03d seconds) ", elapsed_msecs / 1000,
+			elapsed_msecs % 1000);
 	}
 
 	return todo ? -EBUSY : 0;
-- 
1.8.2.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
