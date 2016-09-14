From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 10/22] seccomp: Split put_seccomp_filter() with put_seccomp()
Date: Wed, 14 Sep 2016 09:24:03 +0200
Message-ID: <20160914072415.26021-11-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4594-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

The semantic is unchanged. This will be useful for the Landlock
integration with seccomp (next commit).

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Will Drewry <wad@chromium.org>
---
 include/linux/seccomp.h |  5 +++--
 kernel/fork.c           |  2 +-
 kernel/seccomp.c        | 18 +++++++++++++-----
 3 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index a0459a7315ce..ffdab7cdd162 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -102,13 +102,14 @@ static inline int seccomp_mode(struct seccomp *s)
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
+
 static inline void get_seccomp_filter(struct task_struct *tsk)
 {
 	return;
diff --git a/kernel/fork.c b/kernel/fork.c
index 3584f521e3a6..99df46f157cf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -276,7 +276,7 @@ void free_task(struct task_struct *tsk)
 	free_thread_stack(tsk);
 	rt_mutex_debug_task_free(tsk);
 	ftrace_graph_exit_task(tsk);
-	put_seccomp_filter(tsk);
+	put_seccomp(tsk);
 	arch_release_task_struct(tsk);
 	free_task_struct(tsk);
 }
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 1867bbfa7c6c..92b15083b1b2 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -36,6 +36,8 @@
 /* Limit any path through the tree to 256KB worth of instructions. */
 #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
 
+static void put_seccomp_filter(struct seccomp_filter *filter);
+
 /*
  * Endianness is explicitly ignored and left for BPF program authors to manage
  * as per the specific architecture.
@@ -286,7 +288,7 @@ static inline void seccomp_sync_threads(void)
 		 * current's path will hold a reference.  (This also
 		 * allows a put before the assignment.)
 		 */
-		put_seccomp_filter(thread);
+		put_seccomp_filter(thread->seccomp.filter);
 		smp_store_release(&thread->seccomp.filter,
 				  caller->seccomp.filter);
 
@@ -448,10 +450,11 @@ static inline void seccomp_filter_free(struct seccomp_filter *filter)
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
@@ -460,6 +463,11 @@ void put_seccomp_filter(struct task_struct *tsk)
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
@@ -871,7 +879,7 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
 	if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fprog)))
 		ret = -EFAULT;
 
-	put_seccomp_filter(task);
+	put_seccomp_filter(task->seccomp.filter);
 	return ret;
 
 out:
-- 
2.9.3
