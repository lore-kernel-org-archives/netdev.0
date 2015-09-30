From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v3 3/5] seccomp: add a ptrace command to get seccomp filter fds
Date: Wed, 30 Sep 2015 12:13:38 -0600
Message-ID: <1443636820-17083-4-git-send-email-tycho.andersen@canonical.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I just picked 40 for the constant out of thin air, but there may be a more
appropriate value for this. Also, we return EINVAL when there is no filter
for the index the user requested, but ptrace also returns EINVAL for
invalid commands, making it slightly awkward to test whether or not the
kernel supports this feature. It can still be done via,

if (is_in_mode_filter(pid)) {
	int fd;

	fd = ptrace(PTRACE_SECCOMP_GET_FILTER_FD, pid, NULL, 0);
	if (fd < 0 && errno == -EINVAL)
		/* not supported */

	...
}

since being in SECCOMP_MODE_FILTER implies that there is at least one
filter. If there is a more appropriate errno (ESRCH collides as well with
ptrace) to give here that may be better.

Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
CC: Kees Cook <keescook@chromium.org>
CC: Will Drewry <wad@chromium.org>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/seccomp.h     |  9 +++++++++
 include/uapi/linux/ptrace.h |  2 ++
 kernel/ptrace.c             |  4 ++++
 kernel/seccomp.c            | 28 ++++++++++++++++++++++++++++
 4 files changed, 43 insertions(+)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index f426503..637d91f 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -95,4 +95,13 @@ static inline void get_seccomp_filter(struct task_struct *tsk)
 	return;
 }
 #endif /* CONFIG_SECCOMP_FILTER */
+
+#if defined(CONFIG_CHECKPOINT_RESTORE) && defined(CONFIG_SECCOMP_FILTER)
+extern long seccomp_get_filter_fd(struct task_struct *task, long data);
+#else
+static inline long seccomp_get_filter_fd(struct task_struct *task, long data)
+{
+	return -EINVAL;
+}
+#endif /* CONFIG_CHECKPOINT_RESTORE && CONFIG_SECCOMP_FILTER */
 #endif /* _LINUX_SECCOMP_H */
diff --git a/include/uapi/linux/ptrace.h b/include/uapi/linux/ptrace.h
index a7a6979..3271f5a 100644
--- a/include/uapi/linux/ptrace.h
+++ b/include/uapi/linux/ptrace.h
@@ -23,6 +23,8 @@
 
 #define PTRACE_SYSCALL		  24
 
+#define PTRACE_SECCOMP_GET_FILTER_FD 40
+
 /* 0x4200-0x4300 are reserved for architecture-independent additions.  */
 #define PTRACE_SETOPTIONS	0x4200
 #define PTRACE_GETEVENTMSG	0x4201
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 787320d..aede440 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -1016,6 +1016,10 @@ int ptrace_request(struct task_struct *child, long request,
 		break;
 	}
 #endif
+
+	case PTRACE_SECCOMP_GET_FILTER_FD:
+		return seccomp_get_filter_fd(child, data);
+
 	default:
 		break;
 	}
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 6f0465c..7275ce0 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -1058,3 +1058,31 @@ long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
 	/* prctl interface doesn't have flags, so they are always zero. */
 	return do_seccomp(op, 0, uargs);
 }
+
+#if defined(CONFIG_CHECKPOINT_RESTORE) && defined(CONFIG_SECCOMP_FILTER)
+long seccomp_get_filter_fd(struct task_struct *task, long n)
+{
+	struct seccomp_filter *filter;
+	long fd;
+
+	if (task->seccomp.mode != SECCOMP_MODE_FILTER)
+		return -EINVAL;
+
+	filter = task->seccomp.filter;
+	while (n > 0 && filter) {
+		filter = filter->prev;
+		n--;
+	}
+
+	if (!filter)
+		return -EINVAL;
+
+	atomic_inc(&filter->usage);
+	fd = anon_inode_getfd("seccomp", &seccomp_fops, filter,
+			      O_RDONLY | O_CLOEXEC);
+	if (fd < 0)
+		seccomp_filter_decref(filter);
+
+	return fd;
+}
+#endif
-- 
2.5.0
