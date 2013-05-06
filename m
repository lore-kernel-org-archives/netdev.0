From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v3 06/16] freezer: skip waking up tasks with PF_FREEZER_SKIP set
Date: Mon,  6 May 2013 16:50:11 -0700
Message-ID: <1367884221-20462-7-git-send-email-ccross@android.com>
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
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1367884221-20462-1-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Android goes through suspend/resume very often (every few seconds when
on a busy wifi network with the screen off), and a significant portion
of the energy used to go in and out of suspend is spent in the
freezer.  If a task has called freezer_do_not_count(), don't bother
waking it up.  If it happens to wake up later it will call
freezer_count() and immediately enter the refrigerator.

Combined with patches to convert freezable helpers to use
freezer_do_not_count() and convert common sites where idle userspace
tasks are blocked to use the freezable helpers, this reduces the
time and energy required to suspend and resume.

Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
---
v2:  move check to freeze_task()

 kernel/freezer.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/kernel/freezer.c b/kernel/freezer.c
index c38893b..8b2afc1 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -110,6 +110,18 @@ bool freeze_task(struct task_struct *p)
 {
 	unsigned long flags;
 
+	/*
+	 * This check can race with freezer_do_not_count, but worst case that
+	 * will result in an extra wakeup being sent to the task.  It does not
+	 * race with freezer_count(), the barriers in freezer_count() and
+	 * freezer_should_skip() ensure that either freezer_count() sees
+	 * freezing == true in try_to_freeze() and freezes, or
+	 * freezer_should_skip() sees !PF_FREEZE_SKIP and freezes the task
+	 * normally.
+	 */
+	if (freezer_should_skip(p))
+		return false;
+
 	spin_lock_irqsave(&freezer_lock, flags);
 	if (!freezing(p) || frozen(p)) {
 		spin_unlock_irqrestore(&freezer_lock, flags);
-- 
1.8.2.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
