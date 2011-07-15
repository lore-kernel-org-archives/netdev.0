From: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Subject: [PATCH v2] connector: add an event for monitoring process tracers
Date: Fri, 15 Jul 2011 20:45:18 +0300
Message-ID: <1310751918-31579-1-git-send-email-vzapolskiy@gmail.com>
Cc: netdev@vger.kernel.org, Vladimir Zapolskiy <vzapolskiy@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"David S. Miller" <davem@davemloft.net>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:56283 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497Ab1GORpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 13:45:42 -0400
Received: by fxd18 with SMTP id 18so3142219fxd.11
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 10:45:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds a procfs connector event, which is emitted on every
successful process tracer attach or detach.

If some process connects to other one, kernelspace connector reports
process id and thread group id of both these involved processes. On
disconnection null process id is returned.

Such an event allows to create a simple automated userspace mechanism
to be aware about processes connecting to others, therefore predefined
process policies can be applied to them if needed.

Note, a detach signal is emitted only in case, if a tracer process
explicitly executes PTRACE_DETACH request. In other cases like tracee
or tracer exit detach event from proc connector is not reported.

Signed-off-by: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: David S. Miller <davem@davemloft.net>
---

Originally proposed change can be found here:
* http://patchwork.ozlabs.org/patch/104434/

This version of the change extends proc_ptrace_connector() argument
list, so it becomes possible to specify a ptrace request eliminating
process attach/detach race.

Also tracehook_tracer_task() function was renamed to ptrace_parent(),
but as far as proc_ptrace_connector(task, PTRACE_ATTACH) is called
from a tracer process itself, it becomes possible to get rid of that
call usage completely.

Oleg, I've rebased the change, and if you don't have objections, I'd
be glad, if you can apply this change upon your ptrace branch, thank
you in advance.

 drivers/connector/cn_proc.c |   35 +++++++++++++++++++++++++++++++++++
 include/linux/cn_proc.h     |   13 +++++++++++++
 kernel/ptrace.c             |    7 ++++++-
 3 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 2b46a7e..281902d 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -28,6 +28,7 @@
 #include <linux/init.h>
 #include <linux/connector.h>
 #include <linux/gfp.h>
+#include <linux/ptrace.h>
 #include <asm/atomic.h>
 #include <asm/unaligned.h>
 
@@ -166,6 +167,40 @@ void proc_sid_connector(struct task_struct *task)
 	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
 }
 
+void proc_ptrace_connector(struct task_struct *task, int ptrace_id)
+{
+	struct cn_msg *msg;
+	struct proc_event *ev;
+	struct timespec ts;
+	__u8 buffer[CN_PROC_MSG_SIZE];
+	struct task_struct *tracer;
+
+	if (atomic_read(&proc_event_num_listeners) < 1)
+		return;
+
+	msg = (struct cn_msg *)buffer;
+	ev = (struct proc_event *)msg->data;
+	get_seq(&msg->seq, &ev->cpu);
+	ktime_get_ts(&ts); /* get high res monotonic timestamp */
+	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
+	ev->what = PROC_EVENT_PTRACE;
+	ev->event_data.ptrace.process_pid  = task->pid;
+	ev->event_data.ptrace.process_tgid = task->tgid;
+	if (ptrace_id == PTRACE_ATTACH) {
+		ev->event_data.ptrace.tracer_pid  = current->pid;
+		ev->event_data.ptrace.tracer_tgid = current->tgid;
+	} else if (ptrace_id == PTRACE_DETACH) {
+		ev->event_data.ptrace.tracer_pid  = 0;
+		ev->event_data.ptrace.tracer_tgid = 0;
+	} else
+		return;
+
+	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
+	msg->ack = 0; /* not used */
+	msg->len = sizeof(*ev);
+	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
+}
+
 void proc_exit_connector(struct task_struct *task)
 {
 	struct cn_msg *msg;
diff --git a/include/linux/cn_proc.h b/include/linux/cn_proc.h
index 47dac5e..12c517b 100644
--- a/include/linux/cn_proc.h
+++ b/include/linux/cn_proc.h
@@ -53,6 +53,7 @@ struct proc_event {
 		PROC_EVENT_UID  = 0x00000004,
 		PROC_EVENT_GID  = 0x00000040,
 		PROC_EVENT_SID  = 0x00000080,
+		PROC_EVENT_PTRACE = 0x00000100,
 		/* "next" should be 0x00000400 */
 		/* "last" is the last process event: exit */
 		PROC_EVENT_EXIT = 0x80000000
@@ -95,6 +96,13 @@ struct proc_event {
 			__kernel_pid_t process_tgid;
 		} sid;
 
+		struct ptrace_proc_event {
+			__kernel_pid_t process_pid;
+			__kernel_pid_t process_tgid;
+			__kernel_pid_t tracer_pid;
+			__kernel_pid_t tracer_tgid;
+		} ptrace;
+
 		struct exit_proc_event {
 			__kernel_pid_t process_pid;
 			__kernel_pid_t process_tgid;
@@ -109,6 +117,7 @@ void proc_fork_connector(struct task_struct *task);
 void proc_exec_connector(struct task_struct *task);
 void proc_id_connector(struct task_struct *task, int which_id);
 void proc_sid_connector(struct task_struct *task);
+void proc_ptrace_connector(struct task_struct *task, int which_id);
 void proc_exit_connector(struct task_struct *task);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
@@ -124,6 +133,10 @@ static inline void proc_id_connector(struct task_struct *task,
 static inline void proc_sid_connector(struct task_struct *task)
 {}
 
+static inline void proc_ptrace_connector(struct task_struct *task,
+					 int ptrace_id)
+{}
+
 static inline void proc_exit_connector(struct task_struct *task)
 {}
 #endif	/* CONFIG_PROC_EVENTS */
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index d7ccc79..9de3ecf 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -23,6 +23,7 @@
 #include <linux/uaccess.h>
 #include <linux/regset.h>
 #include <linux/hw_breakpoint.h>
+#include <linux/cn_proc.h>
 
 
 static int ptrace_trapping_sleep_fn(void *flags)
@@ -305,9 +306,12 @@ unlock_tasklist:
 unlock_creds:
 	mutex_unlock(&task->signal->cred_guard_mutex);
 out:
-	if (!retval)
+	if (!retval) {
 		wait_on_bit(&task->jobctl, JOBCTL_TRAPPING_BIT,
 			    ptrace_trapping_sleep_fn, TASK_UNINTERRUPTIBLE);
+		proc_ptrace_connector(task, PTRACE_ATTACH);
+	}
+
 	return retval;
 }
 
@@ -415,6 +419,7 @@ static int ptrace_detach(struct task_struct *child, unsigned int data)
 	}
 	write_unlock_irq(&tasklist_lock);
 
+	proc_ptrace_connector(child, PTRACE_DETACH);
 	if (unlikely(dead))
 		release_task(child);
 
-- 
1.7.5.1

