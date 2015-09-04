From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH 5/6] seccomp: add a way to attach a filter via eBPF fd
Date: Fri,  4 Sep 2015 10:04:23 -0600
Message-ID: <1441382664-17437-6-git-send-email-tycho.andersen@canonical.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:33170 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760093AbbIDQFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 12:05:47 -0400
Received: by igbkq10 with SMTP id kq10so19936810igb.0
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 09:05:46 -0700 (PDT)
In-Reply-To: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the final bit needed to support seccomp filters created via the bpf
syscall.

One concern with this patch is exactly what the interface should look like
for users, since seccomp()'s second argument is a pointer, we could ask
people to pass a pointer to the fd, but implies we might write to it which
seems impolite. Right now we cast the pointer (and force the user to cast
it), which generates ugly warnings. I'm not sure what the right answer is
here.

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
 include/linux/seccomp.h      |  3 +-
 include/uapi/linux/seccomp.h |  1 +
 kernel/seccomp.c             | 70 ++++++++++++++++++++++++++++++++++++--------
 3 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
index d1a86ed..a725dd5 100644
--- a/include/linux/seccomp.h
+++ b/include/linux/seccomp.h
@@ -3,7 +3,8 @@
 
 #include <uapi/linux/seccomp.h>
 
-#define SECCOMP_FILTER_FLAG_MASK	(SECCOMP_FILTER_FLAG_TSYNC)
+#define SECCOMP_FILTER_FLAG_MASK	(\
+	SECCOMP_FILTER_FLAG_TSYNC | SECCOMP_FILTER_FLAG_EBPF)
 
 #ifdef CONFIG_SECCOMP
 
diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 0f238a4..c29a423 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -16,6 +16,7 @@
 
 /* Valid flags for SECCOMP_SET_MODE_FILTER */
 #define SECCOMP_FILTER_FLAG_TSYNC	1
+#define SECCOMP_FILTER_FLAG_EBPF	(1 << 1)
 
 /*
  * All BPF programs must return a 32-bit value.
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index a2c5b32..9c6bea6 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -355,17 +355,6 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 
 	BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
 
-	/*
-	 * Installing a seccomp filter requires that the task has
-	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
-	 * This avoids scenarios where unprivileged tasks can affect the
-	 * behavior of privileged children.
-	 */
-	if (!task_no_new_privs(current) &&
-	    security_capable_noaudit(current_cred(), current_user_ns(),
-				     CAP_SYS_ADMIN) != 0)
-		return ERR_PTR(-EACCES);
-
 	/* Allocate a new seccomp_filter */
 	sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
 	if (!sfilter)
@@ -509,6 +498,48 @@ static void seccomp_send_sigsys(int syscall, int reason)
 	info.si_syscall = syscall;
 	force_sig_info(SIGSYS, &info, current);
 }
+
+#ifdef CONFIG_BPF_SYSCALL
+static struct seccomp_filter *seccomp_prepare_ebpf(const char __user *filter)
+{
+	/* XXX: this cast generates a warning. should we make people pass in
+	 * &fd, or is there some nicer way of doing this?
+	 */
+	u32 fd = (u32) filter;
+	struct seccomp_filter *ret;
+	struct bpf_prog *prog;
+
+	prog = bpf_prog_get(fd);
+	if (IS_ERR(prog))
+		return (struct seccomp_filter *) prog;
+
+	if (prog->type != BPF_PROG_TYPE_SECCOMP) {
+		bpf_prog_put(prog);
+		return ERR_PTR(-EINVAL);
+	}
+
+	ret = kzalloc(sizeof(*ret), GFP_KERNEL | __GFP_NOWARN);
+	if (!ret) {
+		bpf_prog_put(prog);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	ret->prog = prog;
+	atomic_set(&ret->usage, 1);
+
+	/* Intentionally don't bpf_prog_put() here, because the underlying prog
+	 * is refcounted too and we're holding a reference from the struct
+	 * seccomp_filter object.
+	 */
+
+	return ret;
+}
+#else
+static struct seccomp_filter *seccomp_prepare_ebpf(const char __user *filter)
+{
+	return ERR_PTR(-EINVAL);
+}
+#endif
 #endif	/* CONFIG_SECCOMP_FILTER */
 
 /*
@@ -775,8 +806,23 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	if (flags & ~SECCOMP_FILTER_FLAG_MASK)
 		return -EINVAL;
 
+	/*
+	 * Installing a seccomp filter requires that the task has
+	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
+	 * This avoids scenarios where unprivileged tasks can affect the
+	 * behavior of privileged children.
+	 */
+	if (!task_no_new_privs(current) &&
+	    security_capable_noaudit(current_cred(), current_user_ns(),
+				     CAP_SYS_ADMIN) != 0)
+		return -EACCES;
+
 	/* Prepare the new filter before holding any locks. */
-	prepared = seccomp_prepare_user_filter(filter);
+	if (flags & SECCOMP_FILTER_FLAG_EBPF)
+		prepared = seccomp_prepare_ebpf(filter);
+	else
+		prepared = seccomp_prepare_user_filter(filter);
+
 	if (IS_ERR(prepared))
 		return PTR_ERR(prepared);
 
-- 
2.1.4
