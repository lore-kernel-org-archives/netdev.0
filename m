From: Aaron Campbell <aaron@monkey.org>
Subject: [PATCH] connector: fix out-of-order cn_proc netlink message delivery
Date: Fri, 24 Jun 2016 10:05:32 -0300
Message-ID: <1466773532-16596-1-git-send-email-aaron@monkey.org>
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
	Jon DeVree <nuxi@vault24.org>,
	Aaron Campbell <aaron@monkey.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0210.b.hostedemail.com ([64.98.42.210]:42846 "EHLO
	smtprelay.b.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751315AbcFXNOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 09:14:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The proc connector messages include a sequence number, allowing userspace
programs to detect lost messages.  However, performing this detection is
currently more difficult than necessary, since netlink messages can be
delivered to the application out-of-order.  To fix this, leave pre-emption
disabled during cn_netlink_send(), and use GFP_NOWAIT.

The following was written as a test case.  Building the kernel w/ make -j32
proved a reliable way to generate out-of-order cn_proc messages.

int
main(int argc, char *argv[])
{
	static uint32_t last_seq[CPU_SETSIZE], seq;
	int cpu, fd;
	struct sockaddr_nl sa;
	struct __attribute__((aligned(NLMSG_ALIGNTO))) {
		struct nlmsghdr nl_hdr;
		struct __attribute__((__packed__)) {
			struct cn_msg cn_msg;
			struct proc_event cn_proc;
		};
	} rmsg;
	struct __attribute__((aligned(NLMSG_ALIGNTO))) {
		struct nlmsghdr nl_hdr;
		struct __attribute__((__packed__)) {
			struct cn_msg cn_msg;
			enum proc_cn_mcast_op cn_mcast;
		};
	} smsg;

	fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR);
	if (fd < 0) {
		perror("socket");
	}

	sa.nl_family = AF_NETLINK;
	sa.nl_groups = CN_IDX_PROC;
	sa.nl_pid = getpid();
	if (bind(fd, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
		perror("bind");
	}

	memset(&smsg, 0, sizeof(smsg));
	smsg.nl_hdr.nlmsg_len = sizeof(smsg);
	smsg.nl_hdr.nlmsg_pid = getpid();
	smsg.nl_hdr.nlmsg_type = NLMSG_DONE;
	smsg.cn_msg.id.idx = CN_IDX_PROC;
	smsg.cn_msg.id.val = CN_VAL_PROC;
	smsg.cn_msg.len = sizeof(enum proc_cn_mcast_op);
	smsg.cn_mcast = PROC_CN_MCAST_LISTEN;
	if (send(fd, &smsg, sizeof(smsg), 0) != sizeof(smsg)) {
		perror("send");
	}

	while (recv(fd, &rmsg, sizeof(rmsg), 0) == sizeof(rmsg)) {
		cpu = rmsg.cn_proc.cpu;
		if (cpu < 0) {
			continue;
		}
		seq = rmsg.cn_msg.seq;
		if ((last_seq[cpu] != 0) && (seq != last_seq[cpu] + 1)) {
			printf("out-of-order seq=%d on cpu=%d\n", seq, cpu);
		}
		last_seq[cpu] = seq;
	}

	/* NOTREACHED */

	perror("recv");

	return -1;
}

Signed-off-by: Aaron Campbell <aaron@monkey.org>
---
 drivers/connector/cn_proc.c | 43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 15d06fc..b02f9c6 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -56,11 +56,21 @@ static struct cb_id cn_proc_event_id = { CN_IDX_PROC, CN_VAL_PROC };
 /* proc_event_counts is used as the sequence number of the netlink message */
 static DEFINE_PER_CPU(__u32, proc_event_counts) = { 0 };
 
-static inline void get_seq(__u32 *ts, int *cpu)
+static inline void send_msg(struct cn_msg *msg)
 {
 	preempt_disable();
-	*ts = __this_cpu_inc_return(proc_event_counts) - 1;
-	*cpu = smp_processor_id();
+
+	msg->seq = __this_cpu_inc_return(proc_event_counts) - 1;
+	((struct proc_event *)msg->data)->cpu = smp_processor_id();
+
+	/*
+	 * Preemption remains disabled during send to ensure the messages are
+	 * ordered according to their sequence numbers.
+	 *
+	 * If cn_netlink_send() fails, the data is not sent.
+	 */
+	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_NOWAIT);
+
 	preempt_enable();
 }
 
@@ -77,7 +87,6 @@ void proc_fork_connector(struct task_struct *task)
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 	ev->what = PROC_EVENT_FORK;
 	rcu_read_lock();
@@ -92,8 +101,7 @@ void proc_fork_connector(struct task_struct *task)
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	/*  If cn_netlink_send() failed, the data is not sent */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 void proc_exec_connector(struct task_struct *task)
@@ -108,7 +116,6 @@ void proc_exec_connector(struct task_struct *task)
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 	ev->what = PROC_EVENT_EXEC;
 	ev->event_data.exec.process_pid = task->pid;
@@ -118,7 +125,7 @@ void proc_exec_connector(struct task_struct *task)
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 void proc_id_connector(struct task_struct *task, int which_id)
@@ -150,14 +157,13 @@ void proc_id_connector(struct task_struct *task, int which_id)
 		return;
 	}
 	rcu_read_unlock();
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 
 	memcpy(&msg->id, &cn_proc_event_id, sizeof(msg->id));
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 void proc_sid_connector(struct task_struct *task)
@@ -172,7 +178,6 @@ void proc_sid_connector(struct task_struct *task)
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 	ev->what = PROC_EVENT_SID;
 	ev->event_data.sid.process_pid = task->pid;
@@ -182,7 +187,7 @@ void proc_sid_connector(struct task_struct *task)
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 void proc_ptrace_connector(struct task_struct *task, int ptrace_id)
@@ -197,7 +202,6 @@ void proc_ptrace_connector(struct task_struct *task, int ptrace_id)
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 	ev->what = PROC_EVENT_PTRACE;
 	ev->event_data.ptrace.process_pid  = task->pid;
@@ -215,7 +219,7 @@ void proc_ptrace_connector(struct task_struct *task, int ptrace_id)
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 void proc_comm_connector(struct task_struct *task)
@@ -230,7 +234,6 @@ void proc_comm_connector(struct task_struct *task)
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 	ev->what = PROC_EVENT_COMM;
 	ev->event_data.comm.process_pid  = task->pid;
@@ -241,7 +244,7 @@ void proc_comm_connector(struct task_struct *task)
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 void proc_coredump_connector(struct task_struct *task)
@@ -256,7 +259,6 @@ void proc_coredump_connector(struct task_struct *task)
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 	ev->what = PROC_EVENT_COREDUMP;
 	ev->event_data.coredump.process_pid = task->pid;
@@ -266,7 +268,7 @@ void proc_coredump_connector(struct task_struct *task)
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 void proc_exit_connector(struct task_struct *task)
@@ -281,7 +283,6 @@ void proc_exit_connector(struct task_struct *task)
 	msg = buffer_to_cn_msg(buffer);
 	ev = (struct proc_event *)msg->data;
 	memset(&ev->event_data, 0, sizeof(ev->event_data));
-	get_seq(&msg->seq, &ev->cpu);
 	ev->timestamp_ns = ktime_get_ns();
 	ev->what = PROC_EVENT_EXIT;
 	ev->event_data.exit.process_pid = task->pid;
@@ -293,7 +294,7 @@ void proc_exit_connector(struct task_struct *task)
 	msg->ack = 0; /* not used */
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 /*
@@ -325,7 +326,7 @@ static void cn_proc_ack(int err, int rcvd_seq, int rcvd_ack)
 	msg->ack = rcvd_ack + 1;
 	msg->len = sizeof(*ev);
 	msg->flags = 0; /* not used */
-	cn_netlink_send(msg, 0, CN_IDX_PROC, GFP_KERNEL);
+	send_msg(msg);
 }
 
 /**
-- 
2.7.4
