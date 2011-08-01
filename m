From: Joe Damato <joe@boundary.com>
Subject: [PATCH 1/2] Create a new connector proc_event for successful calls to connect.
Date: Mon,  1 Aug 2011 11:04:24 -0700
Message-ID: <1312221865-3012-2-git-send-email-joe@boundary.com>
References: <1312221865-3012-1-git-send-email-joe@boundary.com>
Cc: netdev@vger.kernel.org, Joe Damato <joe@boundary.com>
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46786 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab1HAS2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 14:28:20 -0400
Received: by gyh3 with SMTP id 3so3619682gyh.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 11:28:20 -0700 (PDT)
In-Reply-To: <1312221865-3012-1-git-send-email-joe@boundary.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Damato <joe@boundary.com>
---
 drivers/connector/cn_proc.c |   34 ++++++++++++++++++++++++++++++++++
 include/linux/cn_proc.h     |   22 +++++++++++++++++++++-
 net/socket.c                |    6 ++++++
 3 files changed, 61 insertions(+), 1 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 3ee1fdb..3e88d07 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -51,6 +51,40 @@ static inline void get_seq(__u32 *ts, int *cpu)
 	preempt_enable();
 }
 
+void proc_connect_connector(struct task_struct *task, struct socket *sock,
+			    struct sockaddr *addr, int addrlen)
+{
+	struct cn_msg *msg;
+	struct proc_event *ev;
+	__u8 buffer[CN_PROC_MSG_SIZE];
+	struct timespec ts;
+
+	if (atomic_read(&proc_event_num_listeners) < 1)
+		return;
+
+	msg = (struct cn_msg*)buffer;
+	ev = (struct proc_event*)msg->data;
+	get_seq(&msg->seq, &ev->cpu);
+	ktime_get_ts(&ts); /* get high res monotonic timestamp */
+	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
+	ev->what = PROC_EVENT_CONNECT;
+	ev->event_data.connect.process_pid = task->pid;
+	ev->event_data.connect.process_tgid = task->tgid;
+	ev->event_data.connect.protocol = sock->sk->sk_protocol;
+	ev->event_data.connect.address_len = addrlen;
+	memcpy(&ev->event_data.connect.address, addr, addrlen);
+
+	ev->event_data.connect.local_address_len = sizeof(struct __kernel_sockaddr_storage);
+	kernel_getsockname(sock, (struct sockaddr *) &ev->event_data.connect.local_address,
+			  &ev->event_data.connect.local_address_len);
+
+	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
+	msg->ack = 0; /* not used */
+	msg->len = sizeof(*ev);
+	/*  If cn_netlink_send() failed, the data is not sent */
+	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
+}
+
 void proc_fork_connector(struct task_struct *task)
 {
 	struct cn_msg *msg;
diff --git a/include/linux/cn_proc.h b/include/linux/cn_proc.h
index 12c517b..a49ed22 100644
--- a/include/linux/cn_proc.h
+++ b/include/linux/cn_proc.h
@@ -19,6 +19,7 @@
 #define CN_PROC_H
 
 #include <linux/types.h>
+#include <linux/socket.h>
 
 /*
  * Userspace sends this enum to register with the kernel that it is listening
@@ -54,7 +55,8 @@ struct proc_event {
 		PROC_EVENT_GID  = 0x00000040,
 		PROC_EVENT_SID  = 0x00000080,
 		PROC_EVENT_PTRACE = 0x00000100,
-		/* "next" should be 0x00000400 */
+		PROC_EVENT_CONNECT = 0x00000400,  
+		/* "next" should be 0x00000800 */
 		/* "last" is the last process event: exit */
 		PROC_EVENT_EXIT = 0x80000000
 	} what;
@@ -78,6 +80,16 @@ struct proc_event {
 			__kernel_pid_t process_tgid;
 		} exec;
 
+		struct connect_proc_event {
+			__kernel_pid_t process_pid;
+			__kernel_pid_t process_tgid;
+			struct __kernel_sockaddr_storage address;
+			int address_len;
+			struct __kernel_sockaddr_storage local_address;
+			int local_address_len;
+			int protocol;
+		} connect;
+
 		struct id_proc_event {
 			__kernel_pid_t process_pid;
 			__kernel_pid_t process_tgid;
@@ -119,6 +131,8 @@ void proc_id_connector(struct task_struct *task, int which_id);
 void proc_sid_connector(struct task_struct *task);
 void proc_ptrace_connector(struct task_struct *task, int which_id);
 void proc_exit_connector(struct task_struct *task);
+void proc_connect_connector(struct task_struct *task, struct socket *sock,
+			    struct sockaddr *addr, int addrlen);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
 {}
@@ -139,6 +153,12 @@ static inline void proc_ptrace_connector(struct task_struct *task,
 
 static inline void proc_exit_connector(struct task_struct *task)
 {}
+
+static inline void proc_connect_connector(struct task_struct *task,
+					  struct socket *sock,
+					  struct sockaddr *addr, int addrlen)
+{}
+
 #endif	/* CONFIG_PROC_EVENTS */
 #endif	/* __KERNEL__ */
 #endif	/* CN_PROC_H */
diff --git a/net/socket.c b/net/socket.c
index b1cbbcd..b4f9a6c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -88,6 +88,8 @@
 #include <linux/nsproxy.h>
 #include <linux/magic.h>
 #include <linux/slab.h>
+#include <linux/connector.h>
+#include <linux/cn_proc.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -1596,6 +1598,10 @@ SYSCALL_DEFINE3(connect, int, fd, struct sockaddr __user *, uservaddr,
 
 	err = sock->ops->connect(sock, (struct sockaddr *)&address, addrlen,
 				 sock->file->f_flags);
+
+	if (err == 0)
+	  proc_connect_connector(current, sock, (struct sockaddr *)&address, addrlen);
+
 out_put:
 	fput_light(sock->file, fput_needed);
 out:
-- 
1.7.4.1

