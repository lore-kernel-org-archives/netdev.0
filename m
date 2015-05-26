From: Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] cgroup: report cgroup release event to proc connector
Date: Tue, 26 May 2015 23:07:31 +0100
Message-ID: <1432678051-4372-2-git-send-email-dimitri.j.ledkov@intel.com>
References: <1432678051-4372-1-git-send-email-dimitri.j.ledkov@intel.com>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432678051-4372-1-git-send-email-dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds a call to proc_cgrelease_connector at check_for_release
time. It is done when cgroup becomes dead, regardless of the
notify_on_release status.

This is thus compatible with both current & unified cgroups hierarchy,
and the decision which cgroups to emit events for is offloaded to the
proc connector API.

Specifically, if there are no listeners, no events are emitted. If
only certain events are desired, the userspace proc connector listener
can filter them in the userspace or install a BPF on the socket to
ignore things it doesn't care about.

Signed-off-by: Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 kernel/cgroup.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 469dd54..c52e584 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -57,6 +57,7 @@
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
 #include <linux/kthread.h>
 #include <linux/delay.h>
+#include <linux/cn_proc.h>
 
 #include <linux/atomic.h>
 
@@ -5307,9 +5308,12 @@ void cgroup_exit(struct task_struct *tsk)
 
 static void check_for_release(struct cgroup *cgrp)
 {
-	if (notify_on_release(cgrp) && !cgroup_has_tasks(cgrp) &&
-	    !css_has_online_children(&cgrp->self) && !cgroup_is_dead(cgrp))
-		schedule_work(&cgrp->release_agent_work);
+	if (!cgroup_has_tasks(cgrp) &&
+	    !css_has_online_children(&cgrp->self) && !cgroup_is_dead(cgrp)) {
+		proc_cgrelease_connector(cgrp);
+		if (notify_on_release(cgrp))
+			schedule_work(&cgrp->release_agent_work);
+	}
 }
 
 /*
-- 
2.1.4
