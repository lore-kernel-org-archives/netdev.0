From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC 35/48] Audit: Log task related audit message to proper
	user namespace
Date: Tue, 7 May 2013 10:20:56 +0800
Message-ID: <1367893269-9308-36-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now, we can log task related audit message to the user namespace
which the task belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/auditsc.c | 114 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 64 insertions(+), 50 deletions(-)

diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 544eb82..3c5ced9 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1185,7 +1185,8 @@ void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
 
 EXPORT_SYMBOL(audit_log_task_info);
 
-static int audit_log_pid_context(struct audit_context *context, pid_t pid,
+static int audit_log_pid_context(struct user_namespace *ns,
+				 struct audit_context *context, pid_t pid,
 				 kuid_t auid, kuid_t uid, unsigned int sessionid,
 				 u32 sid, char *comm)
 {
@@ -1194,13 +1195,13 @@ static int audit_log_pid_context(struct audit_context *context, pid_t pid,
 	u32 len;
 	int rc = 0;
 
-	ab = audit_log_start(context, GFP_KERNEL, AUDIT_OBJ_PID);
+	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_OBJ_PID);
 	if (!ab)
 		return rc;
 
 	audit_log_format(ab, "opid=%d oauid=%d ouid=%d oses=%d", pid,
-			 from_kuid(&init_user_ns, auid),
-			 from_kuid(&init_user_ns, uid), sessionid);
+			 from_kuid(ns, auid),
+			 from_kuid(ns, uid), sessionid);
 	if (security_secid_to_secctx(sid, &ctx, &len)) {
 		audit_log_format(ab, " obj=(none)");
 		rc = 1;
@@ -1210,7 +1211,7 @@ static int audit_log_pid_context(struct audit_context *context, pid_t pid,
 	}
 	audit_log_format(ab, " ocomm=");
 	audit_log_untrustedstring(ab, comm);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 
 	return rc;
 }
@@ -1240,6 +1241,7 @@ static int audit_log_single_execve_arg(struct audit_context *context,
 	size_t len, len_left, to_send;
 	size_t max_execve_audit_len = MAX_EXECVE_AUDIT_LEN;
 	unsigned int i, has_cntl = 0, too_long = 0;
+	struct user_namespace *ns;
 	int ret;
 
 	/* strnlen_user includes the null we don't want to send */
@@ -1293,6 +1295,7 @@ static int audit_log_single_execve_arg(struct audit_context *context,
 	if (len > max_execve_audit_len)
 		too_long = 1;
 
+	ns = current_user_ns();
 	/* rewalk the argument actually logging the message */
 	for (i = 0; len_left > 0; i++) {
 		int room_left;
@@ -1310,8 +1313,9 @@ static int audit_log_single_execve_arg(struct audit_context *context,
 			room_left -= to_send;
 		if (room_left < 0) {
 			*len_sent = 0;
-			audit_log_end(*ab);
-			*ab = audit_log_start(context, GFP_KERNEL, AUDIT_EXECVE);
+			audit_log_end_ns(ns, *ab);
+			*ab = audit_log_start_ns(ns, context,
+						 GFP_KERNEL, AUDIT_EXECVE);
 			if (!*ab)
 				return 0;
 		}
@@ -1429,12 +1433,13 @@ static void audit_log_fcaps(struct audit_buffer *ab, struct audit_names *name)
 		audit_log_format(ab, " cap_fe=%d cap_fver=%x", name->fcap.fE, name->fcap_ver);
 }
 
-static void show_special(struct audit_context *context, int *call_panic)
+static void show_special(struct user_namespace *ns,
+			 struct audit_context *context, int *call_panic)
 {
 	struct audit_buffer *ab;
 	int i;
 
-	ab = audit_log_start(context, GFP_KERNEL, context->type);
+	ab = audit_log_start_ns(ns, context, GFP_KERNEL, context->type);
 	if (!ab)
 		return;
 
@@ -1465,9 +1470,9 @@ static void show_special(struct audit_context *context, int *call_panic)
 			}
 		}
 		if (context->ipc.has_perm) {
-			audit_log_end(ab);
-			ab = audit_log_start(context, GFP_KERNEL,
-					     AUDIT_IPC_SET_PERM);
+			audit_log_end_ns(ns, ab);
+			ab = audit_log_start_ns(ns, context, GFP_KERNEL,
+						AUDIT_IPC_SET_PERM);
 			if (unlikely(!ab))
 				return;
 			audit_log_format(ab,
@@ -1523,14 +1528,15 @@ static void show_special(struct audit_context *context, int *call_panic)
 				 context->mmap.flags);
 		break; }
 	}
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
 
-static void audit_log_name(struct audit_context *context, struct audit_names *n,
+static void audit_log_name(struct user_namespace *ns,
+			   struct audit_context *context, struct audit_names *n,
 			   int record_num, int *call_panic)
 {
 	struct audit_buffer *ab;
-	ab = audit_log_start(context, GFP_KERNEL, AUDIT_PATH);
+	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_PATH);
 	if (!ab)
 		return; /* audit_panic has been called */
 
@@ -1565,8 +1571,8 @@ static void audit_log_name(struct audit_context *context, struct audit_names *n,
 				 MAJOR(n->dev),
 				 MINOR(n->dev),
 				 n->mode,
-				 from_kuid(&init_user_ns, n->uid),
-				 from_kgid(&init_user_ns, n->gid),
+				 from_kuid(ns, n->uid),
+				 from_kgid(ns, n->gid),
 				 MAJOR(n->rdev),
 				 MINOR(n->rdev));
 	}
@@ -1585,7 +1591,7 @@ static void audit_log_name(struct audit_context *context, struct audit_names *n,
 
 	audit_log_fcaps(ab, n);
 
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
 
 static void audit_log_exit(struct audit_context *context, struct task_struct *tsk)
@@ -1594,11 +1600,12 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 	struct audit_buffer *ab;
 	struct audit_aux_data *aux;
 	struct audit_names *n;
+	struct user_namespace *ns = task_cred_xxx(tsk, user_ns);
 
 	/* tsk == current */
 	context->personality = tsk->personality;
 
-	ab = audit_log_start(context, GFP_KERNEL, AUDIT_SYSCALL);
+	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_SYSCALL);
 	if (!ab)
 		return;		/* audit_panic has been called */
 	audit_log_format(ab, "arch=%x syscall=%d",
@@ -1620,11 +1627,11 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 
 	audit_log_task_info(ab, tsk);
 	audit_log_key(ab, context->filterkey);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 
 	for (aux = context->aux; aux; aux = aux->next) {
 
-		ab = audit_log_start(context, GFP_KERNEL, aux->type);
+		ab = audit_log_start_ns(ns, context, GFP_KERNEL, aux->type);
 		if (!ab)
 			continue; /* audit_panic has been called */
 
@@ -1650,28 +1657,28 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 			break; }
 
 		}
-		audit_log_end(ab);
+		audit_log_end_ns(ns, ab);
 	}
 
 	if (context->type)
-		show_special(context, &call_panic);
+		show_special(ns, context, &call_panic);
 
 	if (context->fds[0] >= 0) {
-		ab = audit_log_start(context, GFP_KERNEL, AUDIT_FD_PAIR);
+		ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_FD_PAIR);
 		if (ab) {
 			audit_log_format(ab, "fd0=%d fd1=%d",
 					context->fds[0], context->fds[1]);
-			audit_log_end(ab);
+			audit_log_end_ns(ns, ab);
 		}
 	}
 
 	if (context->sockaddr_len) {
-		ab = audit_log_start(context, GFP_KERNEL, AUDIT_SOCKADDR);
+		ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_SOCKADDR);
 		if (ab) {
 			audit_log_format(ab, "saddr=");
 			audit_log_n_hex(ab, (void *)context->sockaddr,
 					context->sockaddr_len);
-			audit_log_end(ab);
+			audit_log_end_ns(ns, ab);
 		}
 	}
 
@@ -1679,7 +1686,8 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 		struct audit_aux_data_pids *axs = (void *)aux;
 
 		for (i = 0; i < axs->pid_count; i++)
-			if (audit_log_pid_context(context, axs->target_pid[i],
+			if (audit_log_pid_context(ns, context,
+						  axs->target_pid[i],
 						  axs->target_auid[i],
 						  axs->target_uid[i],
 						  axs->target_sessionid[i],
@@ -1689,28 +1697,28 @@ static void audit_log_exit(struct audit_context *context, struct task_struct *ts
 	}
 
 	if (context->target_pid &&
-	    audit_log_pid_context(context, context->target_pid,
+	    audit_log_pid_context(ns, context, context->target_pid,
 				  context->target_auid, context->target_uid,
 				  context->target_sessionid,
 				  context->target_sid, context->target_comm))
 			call_panic = 1;
 
 	if (context->pwd.dentry && context->pwd.mnt) {
-		ab = audit_log_start(context, GFP_KERNEL, AUDIT_CWD);
+		ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_CWD);
 		if (ab) {
 			audit_log_d_path(ab, " cwd=", &context->pwd);
-			audit_log_end(ab);
+			audit_log_end_ns(ns, ab);
 		}
 	}
 
 	i = 0;
 	list_for_each_entry(n, &context->names_list, list)
-		audit_log_name(context, n, i++, &call_panic);
+		audit_log_name(ns, context, n, i++, &call_panic);
 
 	/* Send end of event record to help user space know we are finished */
-	ab = audit_log_start(context, GFP_KERNEL, AUDIT_EOE);
+	ab = audit_log_start_ns(ns, context, GFP_KERNEL, AUDIT_EOE);
 	if (ab)
-		audit_log_end(ab);
+		audit_log_end_ns(ns, ab);
 	if (call_panic)
 		audit_panic("error converting sid to string");
 }
@@ -2327,8 +2335,9 @@ int audit_set_loginuid(kuid_t loginuid)
 	sessionid = atomic_inc_return(&session_id);
 	if (context && context->in_syscall) {
 		struct audit_buffer *ab;
+		struct user_namespace *ns = current_user_ns();
 
-		ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_LOGIN);
+		ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_LOGIN);
 		if (ab) {
 			audit_log_format(ab, "login pid=%d uid=%u "
 				"old auid=%u new auid=%u"
@@ -2338,7 +2347,7 @@ int audit_set_loginuid(kuid_t loginuid)
 				from_kuid(&init_user_ns, task->loginuid),
 				from_kuid(&init_user_ns, loginuid),
 				task->sessionid, sessionid);
-			audit_log_end(ab);
+			audit_log_end_ns(ns, ab);
 		}
 	}
 	task->sessionid = sessionid;
@@ -2560,8 +2569,9 @@ int __audit_signal_info(int sig, struct task_struct *t)
 	struct task_struct *tsk = current;
 	struct audit_context *ctx = tsk->audit_context;
 	kuid_t uid = current_uid(), t_uid = task_uid(t);
+	int audit_pid = current_user_ns()->audit.pid;
 
-	if (init_user_ns.audit.pid && t->tgid == init_user_ns.audit.pid) {
+	if (audit_pid && t->tgid == audit_pid) {
 		if (sig == SIGTERM || sig == SIGHUP || sig == SIGUSR1 || sig == SIGUSR2) {
 			audit_sig_pid = tsk->pid;
 			if (uid_valid(tsk->loginuid))
@@ -2683,7 +2693,8 @@ void __audit_mmap_fd(int fd, int flags)
 	context->type = AUDIT_MMAP;
 }
 
-static void audit_log_task(struct audit_buffer *ab)
+static void audit_log_task(struct user_namespace *ns,
+			   struct audit_buffer *ab)
 {
 	kuid_t auid, uid;
 	kgid_t gid;
@@ -2694,18 +2705,19 @@ static void audit_log_task(struct audit_buffer *ab)
 	current_uid_gid(&uid, &gid);
 
 	audit_log_format(ab, "auid=%u uid=%u gid=%u ses=%u",
-			 from_kuid(&init_user_ns, auid),
-			 from_kuid(&init_user_ns, uid),
-			 from_kgid(&init_user_ns, gid),
+			 from_kuid(ns, auid),
+			 from_kuid(ns, uid),
+			 from_kgid(ns, gid),
 			 sessionid);
 	audit_log_task_context(ab);
 	audit_log_format(ab, " pid=%d comm=", current->pid);
 	audit_log_untrustedstring(ab, current->comm);
 }
 
-static void audit_log_abend(struct audit_buffer *ab, char *reason, long signr)
+static void audit_log_abend(struct user_namespace *ns,
+			    struct audit_buffer *ab, char *reason, long signr)
 {
-	audit_log_task(ab);
+	audit_log_task(ns, ab);
 	audit_log_format(ab, " reason=");
 	audit_log_string(ab, reason);
 	audit_log_format(ab, " sig=%ld", signr);
@@ -2720,34 +2732,36 @@ static void audit_log_abend(struct audit_buffer *ab, char *reason, long signr)
 void audit_core_dumps(long signr)
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns = current_user_ns();
 
-	if (!audit_enabled)
+	if (!audit_enabled_ns(ns))
 		return;
 
 	if (signr == SIGQUIT)	/* don't care for those */
 		return;
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_ANOM_ABEND);
 	if (unlikely(!ab))
 		return;
-	audit_log_abend(ab, "memory violation", signr);
-	audit_log_end(ab);
+	audit_log_abend(ns, ab, "memory violation", signr);
+	audit_log_end_ns(ns, ab);
 }
 
 void __audit_seccomp(unsigned long syscall, long signr, int code)
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns = current_user_ns();
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_SECCOMP);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_SECCOMP);
 	if (unlikely(!ab))
 		return;
-	audit_log_task(ab);
+	audit_log_task(ns, ab);
 	audit_log_format(ab, " sig=%ld", signr);
 	audit_log_format(ab, " syscall=%ld", syscall);
 	audit_log_format(ab, " compat=%d", is_compat_task());
 	audit_log_format(ab, " ip=0x%lx", KSTK_EIP(current));
 	audit_log_format(ab, " code=0x%x", code);
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
 
 struct list_head *audit_killed_trees(void)
-- 
1.8.1.4
