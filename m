From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 04/10] seccomp: Split put_seccomp_filter() with put_seccomp()
Date: Thu, 25 Aug 2016 12:32:39 +0200
Message-ID: <1472121165-29071-5-git-send-email-mic@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
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
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4454-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
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
index 2296e6b2f690..29b20fe8fd4d 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -83,13 +83,14 @@ static inline int seccomp_mode(struct seccomp *s)
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
index 4a7ec0c6c88c..b23a71ec8003 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -235,7 +235,7 @@ void free_task(struct task_struct *tsk)
 	free_thread_stack(tsk->stack);
 	rt_mutex_debug_task_free(tsk);
 	ftrace_graph_exit_task(tsk);
-	put_seccomp_filter(tsk);
+	put_seccomp(tsk);
 	arch_release_task_struct(tsk);
 	free_task_struct(tsk);
 }
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 7002796f14a4..f1f475691c27 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -60,6 +60,8 @@ struct seccomp_filter {
 	struct bpf_prog *prog;
 };
 
+static void put_seccomp_filter(struct seccomp_filter *filter);
+
 /* Limit any path through the tree to 256KB worth of instructions. */
 #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
 
@@ -313,7 +315,7 @@ static inline void seccomp_sync_threads(void)
 		 * current's path will hold a reference.  (This also
 		 * allows a put before the assignment.)
 		 */
-		put_seccomp_filter(thread);
+		put_seccomp_filter(thread->seccomp.filter);
 		smp_store_release(&thread->seccomp.filter,
 				  caller->seccomp.filter);
 
@@ -475,10 +477,11 @@ static inline void seccomp_filter_free(struct seccomp_filter *filter)
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
@@ -487,6 +490,11 @@ void put_seccomp_filter(struct task_struct *tsk)
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
@@ -926,7 +934,7 @@ long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
 	if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fprog)))
 		ret = -EFAULT;
 
-	put_seccomp_filter(task);
+	put_seccomp_filter(task->seccomp.filter);
 	return ret;
 
 out:
-- 
2.8.1
