From: Jesper Derehag <jderehag@hotmail.com>
Subject: =?UTF-8?q?=5BPATCH=201/1=5D=20connector=3A=20Added=20coredumping=20event=20to=20the=20process=20connector?=
Date: Sat, 16 Mar 2013 11:50:50 +0100
Message-ID: <1363431050-24135-1-git-send-email-jderehag@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jesper Derehag <jderehag@hotmail.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:48549 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab3CPKvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 06:51:18 -0400
Received: by mail-la0-f48.google.com with SMTP id fq13so4501613lab.7
        for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 03:51:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Process connector can now also detect coredumping events. Could be used=
 for instance by process-managers that want to get notified immediatly =
at process crash instead of waiting for exit.

Signed-off-by: Jesper Derehag <jderehag@hotmail.com>
---
 drivers/connector/cn_proc.c  |   27 +++++++++++++++++++++++++++
 include/linux/cn_proc.h      |    4 ++++
 include/uapi/linux/cn_proc.h |    6 ++++--
 kernel/signal.c              |    2 ++
 4 filer =C3=A4ndrade, 37 till=C3=A4gg(+), 2 borttagningar(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 1110478..325f11c 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -232,6 +232,33 @@ void proc_comm_connector(struct task_struct *task)
 	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
 }
=20
+void proc_coredump_connector(struct task_struct *task)
+{
+	struct cn_msg *msg;
+	struct proc_event *ev;
+	__u8 buffer[CN_PROC_MSG_SIZE];
+	struct timespec ts;
+
+	if (atomic_read(&proc_event_num_listeners) < 1)
+		return;
+
+	msg =3D (struct cn_msg *)buffer;
+	ev =3D (struct proc_event *)msg->data;
+	get_seq(&msg->seq, &ev->cpu);
+	ktime_get_ts(&ts); /* get high res monotonic timestamp */
+	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
+	ev->what =3D PROC_EVENT_COREDUMP;
+	ev->event_data.exit.process_pid =3D task->pid;
+	ev->event_data.exit.process_tgid =3D task->tgid;
+	ev->event_data.exit.exit_code =3D task->exit_code;
+	ev->event_data.exit.exit_signal =3D task->exit_signal;
+
+	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
+	msg->ack =3D 0; /* not used */
+	msg->len =3D sizeof(*ev);
+	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
+}
+
 void proc_exit_connector(struct task_struct *task)
 {
 	struct cn_msg *msg;
diff --git a/include/linux/cn_proc.h b/include/linux/cn_proc.h
index 2c1bc1e..1d5b02a 100644
--- a/include/linux/cn_proc.h
+++ b/include/linux/cn_proc.h
@@ -26,6 +26,7 @@ void proc_id_connector(struct task_struct *task, int =
which_id);
 void proc_sid_connector(struct task_struct *task);
 void proc_ptrace_connector(struct task_struct *task, int which_id);
 void proc_comm_connector(struct task_struct *task);
+void proc_coredump_connector(struct task_struct *task);
 void proc_exit_connector(struct task_struct *task);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
@@ -48,6 +49,9 @@ static inline void proc_ptrace_connector(struct task_=
struct *task,
 					 int ptrace_id)
 {}
=20
+static inline void proc_coredump_connector(struct task_struct *task)
+{}
+
 static inline void proc_exit_connector(struct task_struct *task)
 {}
 #endif	/* CONFIG_PROC_EVENTS */
diff --git a/include/uapi/linux/cn_proc.h b/include/uapi/linux/cn_proc.=
h
index 0d7b499..a46caf1 100644
--- a/include/uapi/linux/cn_proc.h
+++ b/include/uapi/linux/cn_proc.h
@@ -55,8 +55,10 @@ struct proc_event {
 		PROC_EVENT_SID  =3D 0x00000080,
 		PROC_EVENT_PTRACE =3D 0x00000100,
 		PROC_EVENT_COMM =3D 0x00000200,
-		/* "next" should be 0x00000400 */
-		/* "last" is the last process event: exit */
+		/* "next" should be 0x00000400 */
+		/* "last" is the last process event: exit,
+		 * while "next to last" is coredumping event */
+		PROC_EVENT_COREDUMP =3D 0x40000000,
 		PROC_EVENT_EXIT =3D 0x80000000
 	} what;
 	__u32 cpu;
diff --git a/kernel/signal.c b/kernel/signal.c
index d63c79e..e591731 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -32,6 +32,7 @@
 #include <linux/user_namespace.h>
 #include <linux/uprobes.h>
 #include <linux/compat.h>
+#include <linux/cn_proc.h>
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
=20
@@ -2347,6 +2348,7 @@ relock:
 		if (sig_kernel_coredump(signr)) {
 			if (print_fatal_signals)
 				print_fatal_signal(info->si_signo);
+			proc_coredump_connector(current);
 			/*
 			 * If it was able to dump core, this kills all
 			 * other threads in the group and synchronizes with
--=20
1.7.10.4
