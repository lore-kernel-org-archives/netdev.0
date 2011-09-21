From: akpm@google.com
Subject: [patch 1/1] connector: add comm change event report to proc connector
Date: Wed, 21 Sep 2011 12:26:44 -0700
Message-ID: <201109211926.p8LJQk0P007038@hpaq6.eem.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@google.com, vzapolskiy@gmail.com,
	zbr@ioremap.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:57022 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab1IUT07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 15:26:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Subject: connector: add comm change event report to proc connector

Add an event to monitor comm value changes of tasks.  Such an event
becomes vital, if someone desires to control threads of a process in
different manner.

A natural characteristic of threads is its comm value, and helpfully
application developers have an opportunity to change it in runtime. 
Reporting about such events via proc connector allows to fine-grain
monitoring and control potentials, for instance a process control daemon
listening to proc connector and following comm value policies can place
specific threads to assigned cgroup partitions.

It might be possible to achieve a pale partial one-shot likeness without
this update, if an application changes comm value of a thread generator
task beforehand, then a new thread is cloned, and after that proc
connector listener gets the fork event and reads new thread's comm value
from procfs stat file, but this change visibly simplifies and extends the
matter.

Signed-off-by: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@google.com>
---

 drivers/connector/cn_proc.c |   26 ++++++++++++++++++++++++++
 include/linux/cn_proc.h     |   11 +++++++++++
 kernel/sys.c                |    1 +
 3 files changed, 38 insertions(+)

diff -puN drivers/connector/cn_proc.c~connector-add-comm-change-event-report-to-proc-connector drivers/connector/cn_proc.c
--- a/drivers/connector/cn_proc.c~connector-add-comm-change-event-report-to-proc-connector
+++ a/drivers/connector/cn_proc.c
@@ -205,6 +205,32 @@ void proc_ptrace_connector(struct task_s
 	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
 }
 
+void proc_comm_connector(struct task_struct *task)
+{
+	struct cn_msg *msg;
+	struct proc_event *ev;
+	struct timespec ts;
+	__u8 buffer[CN_PROC_MSG_SIZE];
+
+	if (atomic_read(&proc_event_num_listeners) < 1)
+		return;
+
+	msg = (struct cn_msg *)buffer;
+	ev = (struct proc_event *)msg->data;
+	get_seq(&msg->seq, &ev->cpu);
+	ktime_get_ts(&ts); /* get high res monotonic timestamp */
+	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
+	ev->what = PROC_EVENT_COMM;
+	ev->event_data.comm.process_pid  = task->pid;
+	ev->event_data.comm.process_tgid = task->tgid;
+	get_task_comm(ev->event_data.comm.comm, task);
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
diff -puN include/linux/cn_proc.h~connector-add-comm-change-event-report-to-proc-connector include/linux/cn_proc.h
--- a/include/linux/cn_proc.h~connector-add-comm-change-event-report-to-proc-connector
+++ a/include/linux/cn_proc.h
@@ -54,6 +54,7 @@ struct proc_event {
 		PROC_EVENT_GID  = 0x00000040,
 		PROC_EVENT_SID  = 0x00000080,
 		PROC_EVENT_PTRACE = 0x00000100,
+		PROC_EVENT_COMM = 0x00000200,
 		/* "next" should be 0x00000400 */
 		/* "last" is the last process event: exit */
 		PROC_EVENT_EXIT = 0x80000000
@@ -103,6 +104,12 @@ struct proc_event {
 			__kernel_pid_t tracer_tgid;
 		} ptrace;
 
+		struct comm_proc_event {
+			__kernel_pid_t process_pid;
+			__kernel_pid_t process_tgid;
+			char           comm[16];
+		} comm;
+
 		struct exit_proc_event {
 			__kernel_pid_t process_pid;
 			__kernel_pid_t process_tgid;
@@ -118,6 +125,7 @@ void proc_exec_connector(struct task_str
 void proc_id_connector(struct task_struct *task, int which_id);
 void proc_sid_connector(struct task_struct *task);
 void proc_ptrace_connector(struct task_struct *task, int which_id);
+void proc_comm_connector(struct task_struct *task);
 void proc_exit_connector(struct task_struct *task);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
@@ -133,6 +141,9 @@ static inline void proc_id_connector(str
 static inline void proc_sid_connector(struct task_struct *task)
 {}
 
+static inline void proc_comm_connector(struct task_struct *task)
+{}
+
 static inline void proc_ptrace_connector(struct task_struct *task,
 					 int ptrace_id)
 {}
diff -puN kernel/sys.c~connector-add-comm-change-event-report-to-proc-connector kernel/sys.c
--- a/kernel/sys.c~connector-add-comm-change-event-report-to-proc-connector
+++ a/kernel/sys.c
@@ -1760,6 +1760,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsi
 					      sizeof(me->comm) - 1) < 0)
 				return -EFAULT;
 			set_task_comm(me, comm);
+			proc_comm_connector(me);
 			return 0;
 		case PR_GET_NAME:
 			get_task_comm(comm, me);
_
