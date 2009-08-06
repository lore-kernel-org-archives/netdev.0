From: akpm@linux-foundation.org
Subject: [patch 1/1] proc connector: add event for process becoming session leader
Date: Thu, 06 Aug 2009 16:05:47 -0700
Message-ID: <200908062305.n76N5lZj005259@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	scott@ubuntu.com, johnpol@2ka.mipt.ru, matthltc@us.ibm.com,
	oleg@tv-sign.ru
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59456 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756867AbZHFXGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:06:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott James Remnant <scott@ubuntu.com>

The act of a process becoming a session leader is a useful signal to a
supervising init daemon such as Upstart.

While a daemon will normally do this as part of the process of becoming a
daemon, it is rare for its children to do so.  When the children do, it is
nearly always a sign that the child should be considered detached from the
parent and not supervised along with it.

The poster-child example is OpenSSH; the per-login children call setsid()
so that they may control the pty connected to them.  If the primary daemon
dies or is restarted, we do not want to consider the per-login children
and want to respawn the primary daemon without killing the children.

This patch adds a new PROC_SID_EVENT and associated structure to the
proc_event event_data union, it arranges for this to be emitted when the
special PIDTYPE_SID pid is set.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Scott James Remnant <scott@ubuntu.com>
Acked-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/connector/cn_proc.c |   25 +++++++++++++++++++++++++
 include/linux/cn_proc.h     |   10 ++++++++++
 kernel/exit.c               |    4 +++-
 3 files changed, 38 insertions(+), 1 deletion(-)

diff -puN drivers/connector/cn_proc.c~proc-connector-add-event-for-process-becoming-session-leader drivers/connector/cn_proc.c
--- a/drivers/connector/cn_proc.c~proc-connector-add-event-for-process-becoming-session-leader
+++ a/drivers/connector/cn_proc.c
@@ -139,6 +139,31 @@ void proc_id_connector(struct task_struc
 	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
 }
 
+void proc_sid_connector(struct task_struct *task)
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
+	ev->what = PROC_EVENT_SID;
+	ev->event_data.sid.process_pid = task->pid;
+	ev->event_data.sid.process_tgid = task->tgid;
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
diff -puN include/linux/cn_proc.h~proc-connector-add-event-for-process-becoming-session-leader include/linux/cn_proc.h
--- a/include/linux/cn_proc.h~proc-connector-add-event-for-process-becoming-session-leader
+++ a/include/linux/cn_proc.h
@@ -52,6 +52,7 @@ struct proc_event {
 		PROC_EVENT_EXEC = 0x00000002,
 		PROC_EVENT_UID  = 0x00000004,
 		PROC_EVENT_GID  = 0x00000040,
+		PROC_EVENT_SID  = 0x00000080,
 		/* "next" should be 0x00000400 */
 		/* "last" is the last process event: exit */
 		PROC_EVENT_EXIT = 0x80000000
@@ -89,6 +90,11 @@ struct proc_event {
 			} e;
 		} id;
 
+		struct sid_proc_event {
+			__kernel_pid_t process_pid;
+			__kernel_pid_t process_tgid;
+		} sid;
+
 		struct exit_proc_event {
 			__kernel_pid_t process_pid;
 			__kernel_pid_t process_tgid;
@@ -102,6 +108,7 @@ struct proc_event {
 void proc_fork_connector(struct task_struct *task);
 void proc_exec_connector(struct task_struct *task);
 void proc_id_connector(struct task_struct *task, int which_id);
+void proc_sid_connector(struct task_struct *task);
 void proc_exit_connector(struct task_struct *task);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
@@ -114,6 +121,9 @@ static inline void proc_id_connector(str
 				     int which_id)
 {}
 
+static inline void proc_sid_connector(struct task_struct *task)
+{}
+
 static inline void proc_exit_connector(struct task_struct *task)
 {}
 #endif	/* CONFIG_PROC_EVENTS */
diff -puN kernel/exit.c~proc-connector-add-event-for-process-becoming-session-leader kernel/exit.c
--- a/kernel/exit.c~proc-connector-add-event-for-process-becoming-session-leader
+++ a/kernel/exit.c
@@ -359,8 +359,10 @@ void __set_special_pids(struct pid *pid)
 {
 	struct task_struct *curr = current->group_leader;
 
-	if (task_session(curr) != pid)
+	if (task_session(curr) != pid) {
 		change_pid(curr, PIDTYPE_SID, pid);
+		proc_sid_connector(curr);
+	}
 
 	if (task_pgrp(curr) != pid)
 		change_pid(curr, PIDTYPE_PGID, pid);
_
