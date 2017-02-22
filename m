From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v5 05/10] seccomp: Split put_seccomp_filter() with put_seccomp()
Date: Wed, 22 Feb 2017 02:26:27 +0100
Message-ID: <20170222012632.4196-6-mic@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@k
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:38467 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753710AbdBVB2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:28:02 -0500
In-Reply-To: <20170222012632.4196-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The semantic is unchanged. This will be useful for the Landlock
integration with seccomp (next commit).

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Will Drewry <wad@chromium.org>
---
 include/linux/seccomp.h |  4 ++--
 kernel/fork.c           |  2 +-
 kernel/seccomp.c        | 18 +++++++++++++-----
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index ecc296c137cd..e25aee2cdfc0 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -77,10 +77,10 @@ static inline int seccomp_mode(struct seccomp *s)
 #endif /* CONFIG_SECCOMP */
 
 #ifdef CONFIG_SECCOMP_FILTER
-extern void put_seccomp_filter(struct task_struct *tsk);
+extern void put_seccomp(struct task_struct *tsk);
 extern void get_seccomp_filter(struct task_struct *tsk);
 #else  /* CONFIG_SECCOMP_FILTER */
-static inline void put_seccomp_filter(struct task_struct *tsk)
+static inline void put_seccomp(struct task_struct *tsk)
 {
 	return;
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 11c5c8ab827c..a4f0d0e8aeb2 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -352,7 +352,7 @@ void free_task(struct task_struct *tsk)
 #endif
 	rt_mutex_debug_task_free(tsk);
 	ftrace_graph_exit_task(tsk);
-	put_seccomp_filter(tsk);
+	put_seccomp(tsk);
 	arch_release_task_struct(tsk);
 	if (tsk->flags & PF_KTHREAD)
 		free_kthread_struct(tsk);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index f7ce79a46050..06f2f3ee454c 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -62,6 +62,8 @@ struct seccomp_filter {
 /* Limit any path through the tree to 256KB worth of instructions. */
 #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
 
+static void put_seccomp_filter(struct seccomp_filter *filter);
+
 /*
  * Endianness is explicitly ignored and left for BPF program authors to manage
  * as per the specific architecture.
@@ -312,7 +314,7 @@ static inline void seccomp_sync_threads(void)
 		 * current's path will hold a reference.  (This also
 		 * allows a put before the assignment.)
 		 */
-		put_seccomp_filter(thread);
+		put_seccomp_filter(thread->seccomp.filter);
 		smp_store_release(&thread->seccomp.filter,
 				  caller->seccomp.filter);
 
@@ -474,10 +476,11 @@ static inline void seccomp_filter_free(struct seccomp_filter *filter)
 	}
 }
 
-/* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
-void put_seccomp_filter(struct task_struct *tsk)
+/* put_seccomp_filter - decrements the ref count of a filter */
+static void put_seccomp_filter(struct seccomp_filter *filter)
 {
-	struct seccomp_filter *orig = tsk->seccomp.filter;
+	struct seccomp_filter *orig = filter;
+
 	/* Clean up single-reference branches iteratively. */
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
@@ -486,6 +489,11 @@ void put_seccomp_filter(struct task_struct *tsk)
 	}
 }
 
+void put_seccomp(struct task_struct *tsk)
+{
+	put_seccomp_filter(tsk->seccomp.filter);
+}
+
 /**
  * seccomp_send_sigsys - signals the task to allow in-process syscall emulation
  * @syscall: syscall number to send to userland
@@ -897,7 +905,7 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
 	if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fprog)))
 		ret = -EFAULT;
 
-	put_seccomp_filter(task);
+	put_seccomp_filter(task->seccomp.filter);
 	return ret;
 
 out:
-- 
2.11.0
