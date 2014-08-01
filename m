From: Peter Moody <pmoody@google.com>
Subject: [PATCH 1/2] security: create task_post_create callback.
Date: Thu, 31 Jul 2014 18:21:39 -0700
Message-ID: <1406856100-21674-2-git-send-email-pmoody@google.com>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
Cc: brandon.carpenter@pnnl.gov, casey@schaufler-ca.com,
	netdev@vger.kernel.org, Peter Moody <pmoody@google.com>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1406856100-21674-1-git-send-email-pmoody@google.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current LSM framework doesn't have a mechanism for accessing
a task after it's been created but before it's been started. This
patch adds a task_post_create callback so an LSM can access a newly
created task before it has actually started running.

Signed-off-by: Peter Moody <pmoody@google.com>
---
 include/linux/security.h | 8 ++++++++
 kernel/fork.c            | 1 +
 security/capability.c    | 5 +++++
 security/security.c      | 5 +++++
 4 files changed, 19 insertions(+)

diff --git a/include/linux/security.h b/include/linux/security.h
index 623f90e..58abf3b 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -668,6 +668,9 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	manual page for definitions of the @clone_flags.
  *	@clone_flags contains the flags indicating what should be shared.
  *	Return 0 if permission is granted.
+ * @task_post_create:
+ *	This hook allows a module to update or allocate a per-task security
+ *	structure.
  * @task_free:
  *	@task task being freed
  *	Handle release of task-related resources. (Note that this can be called
@@ -1566,6 +1569,7 @@ struct security_operations {
 	int (*file_open) (struct file *file, const struct cred *cred);
 
 	int (*task_create) (unsigned long clone_flags);
+	void (*task_post_create)(struct task_struct *task);
 	void (*task_free) (struct task_struct *task);
 	int (*cred_alloc_blank) (struct cred *cred, gfp_t gfp);
 	void (*cred_free) (struct cred *cred);
@@ -1840,6 +1844,7 @@ int security_file_send_sigiotask(struct task_struct *tsk,
 int security_file_receive(struct file *file);
 int security_file_open(struct file *file, const struct cred *cred);
 int security_task_create(unsigned long clone_flags);
+void security_task_post_create(struct task_struct *task);
 void security_task_free(struct task_struct *task);
 int security_cred_alloc_blank(struct cred *cred, gfp_t gfp);
 void security_cred_free(struct cred *cred);
@@ -2340,6 +2345,9 @@ static inline int security_task_create(unsigned long clone_flags)
 	return 0;
 }
 
+static inline void security_task_post_create(struct task_struct *task)
+{ }
+
 static inline void security_task_free(struct task_struct *task)
 { }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index ed4bc33..d6cca1c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1657,6 +1657,7 @@ long do_fork(unsigned long clone_flags,
 		struct completion vfork;
 		struct pid *pid;
 
+		security_task_post_create(p);
 		trace_sched_process_fork(current, p);
 
 		pid = get_task_pid(p, PIDTYPE_PID);
diff --git a/security/capability.c b/security/capability.c
index a74fde6..14d882f 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -369,6 +369,10 @@ static int cap_task_create(unsigned long clone_flags)
 	return 0;
 }
 
+static void cap_task_post_create(struct task_struct *task)
+{
+}
+
 static void cap_task_free(struct task_struct *task)
 {
 }
@@ -1013,6 +1017,7 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, file_receive);
 	set_to_cap_if_null(ops, file_open);
 	set_to_cap_if_null(ops, task_create);
+	set_to_cap_if_null(ops, task_post_create);
 	set_to_cap_if_null(ops, task_free);
 	set_to_cap_if_null(ops, cred_alloc_blank);
 	set_to_cap_if_null(ops, cred_free);
diff --git a/security/security.c b/security/security.c
index e41b1a8..42a7ec8 100644
--- a/security/security.c
+++ b/security/security.c
@@ -807,6 +807,11 @@ int security_task_create(unsigned long clone_flags)
 	return security_ops->task_create(clone_flags);
 }
 
+void security_task_post_create(struct task_struct *task)
+{
+	security_ops->task_post_create(task);
+}
+
 void security_task_free(struct task_struct *task)
 {
 #ifdef CONFIG_SECURITY_YAMA_STACKED
-- 
2.0.0.526.g5318336

