From: Joe Damato <joe@boundary.com>
Subject: [PATCH 2/2] Create a new connector proc_event for successful calls to accept.
Date: Mon,  1 Aug 2011 11:04:25 -0700
Message-ID: <1312221865-3012-3-git-send-email-joe@boundary.com>
References: <1312221865-3012-1-git-send-email-joe@boundary.com>
Cc: netdev@vger.kernel.org, Joe Damato <joe@boundary.com>
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:40014 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab1HAS2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 14:28:34 -0400
Received: by ywn13 with SMTP id 13so883719ywn.19
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2011 11:28:34 -0700 (PDT)
In-Reply-To: <1312221865-3012-1-git-send-email-joe@boundary.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Damato <joe@boundary.com>
---
 drivers/connector/cn_proc.c |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/cn_proc.h     |   19 ++++++++++++++++++-
 net/socket.c                |    3 +++
 3 files changed, 57 insertions(+), 1 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 3e88d07..1106014 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -85,6 +85,42 @@ void proc_connect_connector(struct task_struct *task, struct socket *sock,
 	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
 }
 
+void proc_accept_connector(struct task_struct *task, struct socket *sock,
+			   struct sockaddr *addr, int addrlen)
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
+	ev->what = PROC_EVENT_ACCEPT;
+	ev->event_data.accept.process_pid = task->pid;
+	ev->event_data.accept.process_tgid = task->tgid;
+	ev->event_data.accept.protocol = sock->sk->sk_protocol;
+	ev->event_data.accept.address_len = addrlen;
+	memcpy(&ev->event_data.accept.address, addr, addrlen);
+
+	ev->event_data.accept.local_address_len = sizeof(struct __kernel_sockaddr_storage);
+	kernel_getsockname(sock, (struct sockaddr *) &ev->event_data.accept.local_address,
+			  &ev->event_data.accept.local_address_len);
+
+	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
+	msg->ack = 0; /* not used */
+	msg->len = sizeof(*ev);
+	/*  If cn_netlink_send() failed, the data is not sent */
+	cn_netlink_send(msg, CN_IDX_PROC, GFP_KERNEL);
+
+	return;
+}
+
 void proc_fork_connector(struct task_struct *task)
 {
 	struct cn_msg *msg;
diff --git a/include/linux/cn_proc.h b/include/linux/cn_proc.h
index a49ed22..d68a3de 100644
--- a/include/linux/cn_proc.h
+++ b/include/linux/cn_proc.h
@@ -56,7 +56,8 @@ struct proc_event {
 		PROC_EVENT_SID  = 0x00000080,
 		PROC_EVENT_PTRACE = 0x00000100,
 		PROC_EVENT_CONNECT = 0x00000400,  
-		/* "next" should be 0x00000800 */
+		PROC_EVENT_ACCEPT = 0x00000800,  
+		/* "next" should be 0x00001000 */
 		/* "last" is the last process event: exit */
 		PROC_EVENT_EXIT = 0x80000000
 	} what;
@@ -90,6 +91,16 @@ struct proc_event {
 			int protocol;
 		} connect;
 
+		struct accept_proc_event {
+			__kernel_pid_t process_pid;
+			__kernel_pid_t process_tgid;
+			struct sockaddr_storage address;
+			int address_len;
+			struct __kernel_sockaddr_storage local_address;
+			int local_address_len;
+			int protocol;
+		} accept;
+
 		struct id_proc_event {
 			__kernel_pid_t process_pid;
 			__kernel_pid_t process_tgid;
@@ -133,6 +144,8 @@ void proc_ptrace_connector(struct task_struct *task, int which_id);
 void proc_exit_connector(struct task_struct *task);
 void proc_connect_connector(struct task_struct *task, struct socket *sock,
 			    struct sockaddr *addr, int addrlen);
+void proc_accept_connector(struct task_struct *task, struct socket *sock,
+			   struct sockaddr *addr, int addrlen);
 #else
 static inline void proc_fork_connector(struct task_struct *task)
 {}
@@ -159,6 +172,10 @@ static inline void proc_connect_connector(struct task_struct *task,
 					  struct sockaddr *addr, int addrlen)
 {}
 
+static inline void proc_accept_connector(struct task_struct *task,
+					 struct socket *sock,
+					 struct sockaddr *addr, int addrlen)
+{}
 #endif	/* CONFIG_PROC_EVENTS */
 #endif	/* __KERNEL__ */
 #endif	/* CN_PROC_H */
diff --git a/net/socket.c b/net/socket.c
index b4f9a6c..d21a266 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1544,6 +1544,9 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 			goto out_fd;
 	}
 
+	proc_accept_connector(current, newsock,
+			      (struct sockaddr *)&address, len);
+
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	fd_install(newfd, newfile);
-- 
1.7.4.1

