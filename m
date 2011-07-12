From: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Subject: [PATCH] connector: add an event for monitoring process tracers
Date: Tue, 12 Jul 2011 23:32:37 +0300
Message-ID: <1310502757-32103-1-git-send-email-vzapolskiy@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>,
	Roland McGrath <roland@redhat.com>, netdev@vger.kernel.org,
	Vladimir Zapolskiy <vzapolskiy@gmail.com>
To: Evgeniy Polyakov <zbr@ioremap.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36573 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488Ab1GLUja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 16:39:30 -0400
Received: by bwd5 with SMTP id 5so4333577bwd.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 13:39:28 -0700 (PDT)
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

Note, a detach signal is not emitted, if a tracer process terminates
without explicit PTRACE_DETACH request. Such cases can be covered
listening to PROC_EVENT_EXIT connector events.

Signed-off-by: Vladimir Zapolskiy <vzapolskiy@gmail.com>
---
 drivers/connector/cn_proc.c |   38 ++++++++++++++++++++++++++++++++++++++
 include/linux/cn_proc.h     |   12 ++++++++++++
 kernel/ptrace.c             |    6 ++++++
 3 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 2b46a7e..44f9881 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -28,6 +28,7 @@
 #include <linux/init.h>
 #include <linux/connector.h>
 #include <linux/gfp.h>
+#include <linux/tracehook.h>
 #include <asm/atomic.h>
 #include <asm/unaligned.h>
 
@@ -166,6 +167,43 @@ void proc_sid_connector(struct task_struct *task)
 	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
 }
 
+void proc_ptrace_connector(struct task_struct *task)
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
+
+	rcu_read_lock();
+	tracer = tracehook_tracer_task(task);
+	if (tracer) {
+		ev->event_data.ptrace.tracer_pid  = tracer->pid;
+		ev->event_data.ptrace.tracer_tgid = tracer->tgid;
+	} else {
+		ev->event_data.ptrace.tracer_pid  = 0;
+		ev->event_data.ptrace.tracer_tgid = 0;
+	}
+	rcu_read_unlock();
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
index 47dac5e..03013ad 100644
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
+void proc_ptrace_connector(struct task_struct *task);
 void proc_exit_connector(struct task_struct *task);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
@@ -124,6 +133,9 @@ static inline void proc_id_connector(struct task_struct *task,
 static inline void proc_sid_connector(struct task_struct *task)
 {}
 
+static inline void proc_ptrace_connector(struct task_struct *task)
+{}
+
 static inline void proc_exit_connector(struct task_struct *task)
 {}
 #endif	/* CONFIG_PROC_EVENTS */
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 2df1157..9238b5d 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -23,6 +23,7 @@
 #include <linux/uaccess.h>
 #include <linux/regset.h>
 #include <linux/hw_breakpoint.h>
+#include <linux/cn_proc.h>
 
 
 /*
@@ -260,6 +261,9 @@ out:
 	if (wait_trap)
 		wait_event(current->signal->wait_chldexit,
 			   !(task->group_stop & GROUP_STOP_TRAPPING));
+	if (!retval)
+		proc_ptrace_connector(task);
+
 	return retval;
 }
 
@@ -365,6 +369,8 @@ static int ptrace_detach(struct task_struct *child, unsigned int data)
 	}
 	write_unlock_irq(&tasklist_lock);
 
+	proc_ptrace_connector(child);
+
 	if (unlikely(dead))
 		release_task(child);
 
-- 
1.7.5.1

