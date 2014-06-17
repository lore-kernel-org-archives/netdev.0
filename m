From: Piotr Wilczek <p.wilczek@samsung.com>
Subject: [PATCH net-next 1/2] procfs: split proc_pid_status function
Date: Tue, 17 Jun 2014 15:24:37 +0200
Message-ID: <1403011478-20206-1-git-send-email-p.wilczek@samsung.com>
Cc: netdev@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>,
	Juho Son <juho80.son@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Piotr Wilczek <p.wilczek@samsung.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:9564 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932316AbaFQN1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 09:27:47 -0400
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N7B00HMOEQAYF00@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 17 Jun 2014 22:27:46 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split proc_pid_status function to get proces status with task locked elswere.
This allows to collect multiple process information with a single task lock.

Signed-off-by: Piotr Wilczek <p.wilczek@samsung.com>
---
 fs/proc/array.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 64db2bc..dcf9a28 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -356,24 +356,36 @@ static void task_cpus_allowed(struct seq_file *m, struct task_struct *task)
 	seq_putc(m, '\n');
 }
 
-int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
-			struct pid *pid, struct task_struct *task)
+int proc_pid_status_mm(struct seq_file *m, struct pid_namespace *ns,
+		       struct pid *pid, struct task_struct *task,
+		       struct mm_struct *mm)
 {
-	struct mm_struct *mm = get_task_mm(task);
-
 	task_name(m, task);
 	task_state(m, ns, pid, task);
 
-	if (mm) {
+	if (mm)
 		task_mem(m, mm);
-		mmput(mm);
-	}
+
 	task_sig(m, task);
 	task_cap(m, task);
 	task_seccomp(m, task);
 	task_cpus_allowed(m, task);
 	cpuset_task_status_allowed(m, task);
 	task_context_switch_counts(m, task);
+
+	return 0;
+}
+
+int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
+		    struct pid *pid, struct task_struct *task)
+{
+	struct mm_struct *mm = get_task_mm(task);
+
+	if (mm) {
+		proc_pid_status_mm(m, ns, pid, task, mm);
+		mmput(mm);
+	}
+
 	return 0;
 }
 
-- 
1.9.1
