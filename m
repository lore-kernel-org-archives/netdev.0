From: akpm@linux-foundation.org
Subject: [patch 2/2] proc_fork_connector: a lockless ->real_parent usage is not safe
Date: Thu, 28 Jul 2011 13:54:25 -0700
Message-ID: <201107282054.p6SKsPtJ007979@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, oleg@redhat.com,
	johnpol@2ka.mipt.ru, vzapolskiy@gmail.com, zbr@ioremap.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48773 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755177Ab1G1Uyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 16:54:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oleg Nesterov <oleg@redhat.com>

proc_fork_connector() uses ->real_parent lockless.  This is not safe if
copy_process() was called with CLONE_THREAD or CLONE_PARENT, in this case
the parent != current can go away at any moment.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Evgeniy Polyakov <zbr@ioremap.net>
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/connector/cn_proc.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff -puN drivers/connector/cn_proc.c~proc_fork_connector-a-lockless-real_parent-usage-is-not-safe drivers/connector/cn_proc.c
--- a/drivers/connector/cn_proc.c~proc_fork_connector-a-lockless-real_parent-usage-is-not-safe
+++ a/drivers/connector/cn_proc.c
@@ -57,6 +57,7 @@ void proc_fork_connector(struct task_str
 	struct proc_event *ev;
 	__u8 buffer[CN_PROC_MSG_SIZE];
 	struct timespec ts;
+	struct task_struct *parent;
 
 	if (atomic_read(&proc_event_num_listeners) < 1)
 		return;
@@ -67,8 +68,11 @@ void proc_fork_connector(struct task_str
 	ktime_get_ts(&ts); /* get high res monotonic timestamp */
 	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
 	ev->what = PROC_EVENT_FORK;
-	ev->event_data.fork.parent_pid = task->real_parent->pid;
-	ev->event_data.fork.parent_tgid = task->real_parent->tgid;
+	rcu_read_lock();
+	parent = rcu_dereference(task->real_parent);
+	ev->event_data.fork.parent_pid = parent->pid;
+	ev->event_data.fork.parent_tgid = parent->tgid;
+	rcu_read_unlock();
 	ev->event_data.fork.child_pid = task->pid;
 	ev->event_data.fork.child_tgid = task->tgid;
 
_
