From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH net-next] seccomp, ptrace: add support for dumping seccomp filters
Date: Tue, 27 Oct 2015 09:23:59 +0900
Message-ID: <1445905439-25449-2-git-send-email-tycho.andersen@canonical.com>
References: <1445905439-25449-1-git-send-email-tycho.andersen@canonical.com>
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445905439-25449-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for dumping a process' (classic BPF) seccomp
filters via ptrace.

PTRACE_SECCOMP_GET_FILTER allows the tracer to dump the user's classic BPF
seccomp filters. addr should be an integer which represents the ith seccomp
filter (0 is the most recently installed filter). data should be a struct
sock_filter * with enough room for the ith filter, or NULL, in which case
the filter is not saved. The return value for this command is the number of
BPF instructions the program represents, or negative in the case of errors.
Command specific errors are ENOENT: which indicates that there is no ith
filter in this seccomp tree, and EMEDIUMTYPE, which indicates that the ith
filter was not installed as a classic BPF filter.

A caveat with this approach is that there is no way to get explicitly at
the heirarchy of seccomp filters, and users need to memcmp() filters to
decide which are inherited. This means that a task which installs two of
the same filter can potentially confuse users of this interface.

v2: * make save_orig const
    * check that the orig_prog exists (not necessary right now, but when
       grows eBPF support it will be)
    * s/n/filter_off and make it an unsigned long to match ptrace
    * count "down" the tree instead of "up" when passing a filter offset

v3: * don't take the current task's lock for inspecting its seccomp mode
    * use a 0x42** constant for the ptrace command value

v4: * don't copy to userspace while holding spinlocks

v5: * add another condition to WARN_ON

v6: * rebase on net-next

Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
Acked-by: Kees Cook <keescook@chromium.org>
CC: Will Drewry <wad@chromium.org>
Reviewed-by: Oleg Nesterov <oleg@redhat.com>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/seccomp.h     | 11 +++++++
 include/uapi/linux/ptrace.h |  2 ++
 kernel/ptrace.c             |  5 +++
 kernel/seccomp.c            | 76 ++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 93 insertions(+), 1 deletion(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index f426503..2296e6b 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -95,4 +95,15 @@ static inline void get_seccomp_filter(struct task_struct *tsk)
 	return;
 }
 #endif /* CONFIG_SECCOMP_FILTER */
+
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
+extern long seccomp_get_filter(struct task_struct *task,
+			       unsigned long filter_off, void __user *data);
+#else
+static inline long seccomp_get_filter(struct task_struct *task,
+				      unsigned long n, void __user *data)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_SECCOMP_FILTER && CONFIG_CHECKPOINT_RESTORE */
 #endif /* _LINUX_SECCOMP_H */
diff --git a/include/uapi/linux/ptrace.h b/include/uapi/linux/ptrace.h
index a7a6979..fb81065 100644
--- a/include/uapi/linux/ptrace.h
+++ b/include/uapi/linux/ptrace.h
@@ -64,6 +64,8 @@ struct ptrace_peeksiginfo_args {
 #define PTRACE_GETSIGMASK	0x420a
 #define PTRACE_SETSIGMASK	0x420b
 
+#define PTRACE_SECCOMP_GET_FILTER	0x420c
+
 /* Read signals from a shared (process wide) queue */
 #define PTRACE_PEEKSIGINFO_SHARED	(1 << 0)
 
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 787320d..b760bae 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -1016,6 +1016,11 @@ int ptrace_request(struct task_struct *child, long request,
 		break;
 	}
 #endif
+
+	case PTRACE_SECCOMP_GET_FILTER:
+		ret = seccomp_get_filter(child, addr, datavp);
+		break;
+
 	default:
 		break;
 	}
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 06858a7..580ac2d 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -347,6 +347,7 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
 	struct seccomp_filter *sfilter;
 	int ret;
+	const bool save_orig = config_enabled(CONFIG_CHECKPOINT_RESTORE);
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
@@ -370,7 +371,7 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 		return ERR_PTR(-ENOMEM);
 
 	ret = bpf_prog_create_from_user(&sfilter->prog, fprog,
-					seccomp_check_filter, false);
+					seccomp_check_filter, save_orig);
 	if (ret < 0) {
 		kfree(sfilter);
 		return ERR_PTR(ret);
@@ -867,3 +868,76 @@ long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
 	/* prctl interface doesn't have flags, so they are always zero. */
 	return do_seccomp(op, 0, uargs);
 }
+
+#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_CHECKPOINT_RESTORE)
+long seccomp_get_filter(struct task_struct *task, unsigned long filter_off,
+			void __user *data)
+{
+	struct seccomp_filter *filter;
+	struct sock_fprog_kern *fprog;
+	long ret;
+	unsigned long count = 0;
+
+	if (!capable(CAP_SYS_ADMIN) ||
+	    current->seccomp.mode != SECCOMP_MODE_DISABLED) {
+		return -EACCES;
+	}
+
+	spin_lock_irq(&task->sighand->siglock);
+	if (task->seccomp.mode != SECCOMP_MODE_FILTER) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	filter = task->seccomp.filter;
+	while (filter) {
+		filter = filter->prev;
+		count++;
+	}
+
+	if (filter_off >= count) {
+		ret = -ENOENT;
+		goto out;
+	}
+	count -= filter_off;
+
+	filter = task->seccomp.filter;
+	while (filter && count > 1) {
+		filter = filter->prev;
+		count--;
+	}
+
+	if (WARN_ON(count != 1 || !filter)) {
+		/* The filter tree shouldn't shrink while we're using it. */
+		ret = -ENOENT;
+		goto out;
+	}
+
+	fprog = filter->prog->orig_prog;
+	if (!fprog) {
+		/* This must be a new non-cBPF filter, since we save every
+		 * every cBPF filter's orig_prog above when
+		 * CONFIG_CHECKPOINT_RESTORE is enabled.
+		 */
+		ret = -EMEDIUMTYPE;
+		goto out;
+	}
+
+	ret = fprog->len;
+	if (!data)
+		goto out;
+
+	get_seccomp_filter(task);
+	spin_unlock_irq(&task->sighand->siglock);
+
+	if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fprog)))
+		ret = -EFAULT;
+
+	put_seccomp_filter(task);
+	return ret;
+
+out:
+	spin_unlock_irq(&task->sighand->siglock);
+	return ret;
+}
+#endif
-- 
2.5.0
